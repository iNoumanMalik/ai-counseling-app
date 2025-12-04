import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  JournalService(this._db, this._auth);

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _entriesCol =>
      _db.collection('journal').doc(_uid).collection('entries');

  Future<void> addOrUpdateEntry({
    required String id,
    String? title,
    required String content,
    required String date,
  }) async {
    await _entriesCol.doc(id).set({
      'title': title,
      'content': content,
      'date': date,
    }, SetOptions(merge: true));
  }

  Future<void> deleteEntry(String id) async {
    await _entriesCol.doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> listEntries() async {
    final qs = await _entriesCol.orderBy('date', descending: true).get();
    return qs.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'title': data['title'],
        'content': data['content'],
        'date': data['date'],
      };
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> entriesStream() {
    return _entriesCol.orderBy('date', descending: true).snapshots().map(
      (qs) => qs.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'title': data['title'],
          'content': data['content'],
          'date': data['date'],
        };
      }).toList(),
    );
  }
}

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final journalEntriesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(journalServiceProvider).entriesStream();
});
