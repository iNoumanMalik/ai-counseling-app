import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  UserService(this._db, this._auth);

  String get _uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users').doc(_uid);

  Future<void> createOrUpdateProfile({required String name}) async {
    final now = FieldValue.serverTimestamp();
    await _userRef.set({
      'name': name,
      'createdAt': now,
    }, SetOptions(merge: true));
  }

  Future<void> updateHabits(Map<String, bool> habits) async {
    await _userRef.set({'habits': habits}, SetOptions(merge: true));
  }

  Future<void> updateLastMood(String mood) async {
    await _userRef.set({'lastMood': mood}, SetOptions(merge: true));
  }

  Future<void> updateHabitStreak(int streak) async {
    await _userRef.set({'habitStreak': streak}, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final doc = await _userRef.get();
    return doc.data();
  }

  Stream<Map<String, dynamic>?> userDataStream() {
    return _userRef.snapshots().map((s) => s.data());
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final userDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return ref.read(userServiceProvider).userDataStream();
});
