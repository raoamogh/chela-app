// lib/providers/assignment_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/assignment_model.dart';
import '../api/notification_service.dart'; // Import your notification service

part 'assignment_provider.g.dart';

@riverpod
class AssignmentNotifier extends _$AssignmentNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Getter to easily access the NotificationService instance
  NotificationService get _notificationService => ref.read(notificationServiceProvider);

  // The build method provides a stream of Assignment lists.
  // It automatically handles loading and re-loading assignments when data changes.
  @override
  Stream<List<Assignment>> build() {
    final user = _auth.currentUser;
    if (user == null) {
      // If no user is logged in, return an empty stream
      return Stream.value([]);
    }

    // Listen to changes in the 'assignments' collection for the current user
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('assignments')
        .orderBy('dueDate', descending: false) // Order by due date
        .snapshots()
        .map((snapshot) {
            final assignments = snapshot.docs
                .map((doc) => Assignment.fromFirestore(doc))
                .toList();
            // After loading, update (schedule/cancel) all relevant reminders
            _updateAllAssignmentReminders(assignments);
            return assignments;
        });
  }

  // --- NEW METHOD: Manages all reminders for all assignments ---
  // This method ensures that all active assignments have their reminders scheduled
  // and completed/deleted assignments have theirs cancelled.
  void _updateAllAssignmentReminders(List<Assignment> assignments) async {
    // A robust system might track notification IDs to only cancel/reschedule changed ones.
    // For simplicity, we'll cancel all assignment-related notifications and reschedule
    // based on the current list of assignments. This is okay for now but can be optimized
    // if performance becomes an issue with a very large number of assignments.
    
    // 1. Get all current pending notifications from our plugin
    final pendingNotifications = await _notificationService.flutterLocalNotificationsPlugin.pendingNotificationRequests();
    
    // 2. Identify and cancel notifications that belong to assignments
    // This helps clean up old reminders (e.g., if reminder options changed)
    for (var pending in pendingNotifications) {
      if (pending.payload != null && pending.payload!.startsWith('assignment_')) {
        await _notificationService.cancelNotification(pending.id);
      }
    }

    // 3. Schedule reminders for all active assignments based on their current reminder settings
    for (var assignment in assignments) {
      _scheduleRemindersFor(assignment);
    }
  }

  // --- UPDATED METHOD: Schedules multiple reminders for a single assignment ---
  // This method now iterates through `assignment.reminderHoursBefore`
  // and schedules a notification for each specified interval.
  void _scheduleRemindersFor(Assignment assignment) {
    // If the assignment is marked as completed, ensure all its reminders are cancelled
    if (assignment.isCompleted) {
      for (int hoursBefore in assignment.reminderHoursBefore) {
        _notificationService.cancelNotification(_generateNotificationId(assignment.id, hoursBefore));
      }
      return; // No need to schedule if completed
    }

    // Iterate through each desired reminder interval
    for (int hoursBefore in assignment.reminderHoursBefore) {
      final int notificationId = _generateNotificationId(assignment.id, hoursBefore);
      final DateTime reminderTime = assignment.dueDate.subtract(Duration(hours: hoursBefore));

      // Only schedule if the reminder time is in the future
      if (reminderTime.isAfter(DateTime.now())) {
        _notificationService.scheduleNotification(
          notificationId,
          'Chela Reminder: ${assignment.subjectName}', // Main title
          '${assignment.title} is due ${_getFriendlyTime(hoursBefore)}!', // Body message
          reminderTime,
          'assignment_${assignment.id}', // Payload for when the user taps the notification
        );
      } else {
        // If the reminder time is in the past, ensure it's cancelled if it somehow existed
        _notificationService.cancelNotification(notificationId);
      }
    }
  }

  // --- HELPER: Generates a unique notification ID for each reminder ---
  // This ensures that an assignment can have multiple distinct notifications,
  // and each can be cancelled/updated independently.
  int _generateNotificationId(String assignmentId, int hoursBefore) {
    // Combine assignment ID hash with hoursBefore to make a unique ID.
    // Multiplying the hash by a large prime and adding hoursBefore helps
    // ensure uniqueness and avoid collisions.
    return assignmentId.hashCode * 31 + hoursBefore;
  }

  // --- HELPER: Provides a user-friendly string for reminder times ---
  String _getFriendlyTime(int hours) {
    if (hours == 1) return 'in 1 hour';
    if (hours < 24) return 'in $hours hours';
    if (hours == 24) return 'tomorrow';
    if (hours == 24 * 7) return 'in 1 week';
    int days = hours ~/ 24;
    return 'in $days day${days > 1 ? 's' : ''}';
  }

  // --- CRUD Operations ---

  // Adds a new assignment to Firestore and schedules its reminders.
  Future<void> addAssignment(Assignment assignment) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid).collection('assignments').doc();
    // Assign the Firestore-generated ID to the new assignment object
    final newAssignment = assignment.copyWith(id: docRef.id);
    await docRef.set(newAssignment.toFirestore());
    
    // Schedule reminders immediately after adding
    _scheduleRemindersFor(newAssignment);
  }

  // Updates an existing assignment in Firestore and re-schedules its reminders.
  Future<void> updateAssignment(Assignment assignment) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('assignments').doc(assignment.id).update(assignment.toFirestore());
    
    // Re-schedule reminders to reflect any changes (e.g., due date, reminder options)
    _scheduleRemindersFor(assignment);
  }

  // Deletes an assignment from Firestore and cancels all its associated reminders.
  Future<void> deleteAssignment(String assignmentId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Before deleting, fetch the assignment to get its reminder settings
    // so we can accurately cancel all associated notifications.
    final assignmentDoc = await _firestore.collection('users').doc(user.uid).collection('assignments').doc(assignmentId).get();
    if (assignmentDoc.exists) {
      final assignment = Assignment.fromFirestore(assignmentDoc);
      // Cancel each reminder associated with this assignment
      for (int hoursBefore in assignment.reminderHoursBefore) {
          _notificationService.cancelNotification(_generateNotificationId(assignmentId, hoursBefore));
      }
    }
    
    await _firestore.collection('users').doc(user.uid).collection('assignments').doc(assignmentId).delete();
  }
}

// --- Extension for Assignment model to provide a copyWith method ---
// This method helps in creating new Assignment objects with updated fields
// without having to manually copy all fields.
extension AssignmentCopyWith on Assignment {
  Assignment copyWith({
    String? id,
    String? subjectName,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    int? priority,
    List<int>? reminderHoursBefore, // Include the new field here
  }) {
    return Assignment(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      reminderHoursBefore: reminderHoursBefore ?? this.reminderHoursBefore, // Use the new field
    );
  }
}