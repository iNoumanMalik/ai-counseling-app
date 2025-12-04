import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeditationService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  MeditationService(this._db, this._auth);

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _tracksCol =>
      _db.collection('meditation').doc(_uid).collection('tracks');

  Future<void> markCompleted(String trackId, bool completed) async {
    await _tracksCol.doc(trackId).set({'completed': completed}, SetOptions(merge: true));
  }

  Future<Map<String, bool>> listCompletions() async {
    final qs = await _tracksCol.get();
    final result = <String, bool>{};
    for (final d in qs.docs) {
      result[d.id] = (d.data()['completed'] as bool?) ?? false;
    }
    return result;
  }
}

final meditationServiceProvider = Provider<MeditationService>((ref) {
  return MeditationService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
