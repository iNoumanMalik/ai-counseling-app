import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounselorService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CounselorService(this._db, this._auth);

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('savedCounselors').doc(_uid).collection('items');

  Future<void> saveCounselor({
    required String counselorId,
    required String name,
    required String link,
  }) async {
    await _col.doc(counselorId).set({
      'name': name,
      'link': link,
    });
  }

  Future<void> removeCounselor(String counselorId) async {
    await _col.doc(counselorId).delete();
  }

  Future<List<Map<String, dynamic>>> listSaved() async {
    final qs = await _col.get();
    return qs.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Stream<List<Map<String, dynamic>>> savedStream() {
    return _col.snapshots().map(
      (qs) => qs.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }
}

final counselorServiceProvider = Provider<CounselorService>((ref) {
  return CounselorService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final savedCounselorsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(counselorServiceProvider).savedStream();
});
