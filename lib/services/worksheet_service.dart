import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorksheetService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  WorksheetService(this._db, this._auth);

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _entriesCol =>
      _db.collection('worksheets').doc(_uid).collection('entries');

  Future<void> saveEntry({
    required String worksheetId,
    required Map<String, dynamic> data,
  }) async {
    await _entriesCol.add({
      'worksheetId': worksheetId,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> listEntries() async {
    final qs = await _entriesCol.orderBy('timestamp', descending: true).get();
    return qs.docs.map((d) {
      final m = d.data();
      return {
        'id': d.id,
        'worksheetId': m['worksheetId'],
        'data': m['data'],
        'date': (m['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
      };
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> entriesStream() {
    return _entriesCol.orderBy('timestamp', descending: true).snapshots().map(
      (qs) => qs.docs.map((d) {
        final m = d.data();
        return {
          'id': d.id,
          'worksheetId': m['worksheetId'],
          'data': m['data'],
          'date': (m['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
        };
      }).toList(),
    );
  }
}

final worksheetServiceProvider = Provider<WorksheetService>((ref) {
  return WorksheetService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final worksheetEntriesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(worksheetServiceProvider).entriesStream();
});
