import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoodService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  MoodService(this._db, this._auth);

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _entriesCol =>
      _db.collection('moods').doc(_uid).collection('entries');

  Future<void> saveMood(String mood, {int? intensity, String? note, List<String>? tags}) async {
    final entryRef = _entriesCol.doc();
    await entryRef.set({
      'mood': mood,
      'intensity': intensity,
      'note': note,
      'tags': tags,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getMoodHistory() async {
    final qs = await _entriesCol.orderBy('timestamp', descending: true).get();
    return qs.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'mood': data['mood'],
        'intensity': data['intensity'],
        'note': data['note'],
        'tags': (data['tags'] as List?)?.map((e) => e.toString()).toList(),
        'date': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
      };
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> moodHistoryStream() {
    return _entriesCol.orderBy('timestamp', descending: true).snapshots().map(
      (qs) => qs.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'mood': data['mood'],
          'intensity': data['intensity'],
          'note': data['note'],
          'tags': (data['tags'] as List?)?.map((e) => e.toString()).toList(),
          'date': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
        };
      }).toList(),
    );
  }
}

final moodServiceProvider = Provider<MoodService>((ref) {
  return MoodService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final moodHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(moodServiceProvider).moodHistoryStream();
});
