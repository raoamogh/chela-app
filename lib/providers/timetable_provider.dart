import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/timetable_entry_model.dart'; // Import the new model

part 'timetable_provider.g.dart'; // For code generation

@riverpod
class TimetableNotifier extends _$TimetableNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<List<TimetableEntry>> build() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]); // No user, no timetable
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('timetable')
        .orderBy('day', descending: false) // Order by day
        .orderBy('startTime', descending: false) // Then by start time
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimetableEntry.fromFirestore(doc))
            .toList());
  }

  Future<void> addEntry(TimetableEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('timetable')
        .add(entry.toFirestore());
  }

  Future<void> updateEntry(TimetableEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('timetable')
        .doc(entry.id)
        .update(entry.toFirestore());
  }

  Future<void> deleteEntry(String entryId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('timetable')
        .doc(entryId)
        .delete();
  }
}