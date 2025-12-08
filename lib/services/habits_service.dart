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

  CollectionReference<Map<String, dynamic>> get _habitDefsCol =>
      _db.collection('users').doc(_uid).collection('habitDefs');

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

  Future<List<Map<String, dynamic>>> listHabitDefs() async {
    final qs = await _habitDefsCol.get();
    return qs.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> addHabitDef({required String id, required String label, required int iconCodePoint}) async {
    await _habitDefsCol.doc(id).set({
      'label': label,
      'icon': iconCodePoint,
    });
  }

  Future<void> deleteHabitDef(String id) async {
    await _habitDefsCol.doc(id).delete();
  }

  Future<void> removeHabitKey(String id) async {
    await _userRef.update({'habits.$id': FieldValue.delete()});
  }
}

final habitsServiceProvider = Provider<HabitsService>((ref) {
  return HabitsService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
