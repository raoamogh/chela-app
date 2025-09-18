// lib/models/assignment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String id;
  final String subjectName;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final int priority; // 1 (low) - 5 (high)
  final List<int> reminderHoursBefore; // NEW FIELD: List of hours before due date

  Assignment({
    required this.id,
    required this.subjectName,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 3,
    this.reminderHoursBefore = const [24], // Default to 24 hours before for new assignments
  });

  // Factory constructor to create an Assignment from a Firestore DocumentSnapshot
  factory Assignment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Assignment(
      id: doc.id,
      subjectName: data['subjectName'] ?? 'Unknown Subject',
      title: data['title'] ?? 'No Title',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      priority: data['priority'] ?? 3,
      // Read reminderHoursBefore, defaulting to [24] if not present or null
      reminderHoursBefore: List<int>.from(data['reminderHoursBefore'] ?? [24]),
    );
  }

  // Method to convert an Assignment object to a Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'subjectName': subjectName,
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'priority': priority,
      'reminderHoursBefore': reminderHoursBefore, // Write the list to Firestore
    };
  }

  // NOTE: The copyWith extension is now located in assignment_provider.dart
  // to keep the model class focused solely on data structure and serialization.
}