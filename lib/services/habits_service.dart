import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitsService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  HabitsService(this._db, this._auth);

  String get _uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _habitLogCol =>
      _db.collection('users').doc(_uid).collection('habitLog');

  Future<Map<String, bool>> getHabits() async {
    final doc = await _userRef.get();
    final data = doc.data();
    final habits = (data?['habits'] as Map<String, dynamic>?) ?? {};
    return habits.map((k, v) => MapEntry(k, (v as bool?) ?? false));
  }

  Future<void> setHabit(String key, bool value) async {
    await _userRef.set({
      'habits': {key: value},
    }, SetOptions(merge: true));
  }

  Future<void> logHabitCompletion(String key) async {
    await _habitLogCol.add({
      'habitId': key,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setAll(Map<String, bool> habits) async {
    await _userRef.set({'habits': habits}, SetOptions(merge: true));
  }
}

final habitsServiceProvider = Provider<HabitsService>((ref) {
  return HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
