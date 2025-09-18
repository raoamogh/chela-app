import 'package:cloud_firestore/cloud_firestore.dart';

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class TimetableEntry {
  final String id; // Unique ID for Firestore document
  final String subjectName;
  final String? location; // e.g., "Lecture Hall 1", "Online"
  final DayOfWeek day;
  final DateTime startTime; // Store only time component, but needs a full DateTime for operations
  final DateTime endTime;   // Store only time component

  TimetableEntry({
    required this.id,
    required this.subjectName,
    this.location,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  // Factory constructor to create TimetableEntry from Firestore document
  factory TimetableEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TimetableEntry(
      id: doc.id,
      subjectName: data['subjectName'] ?? '',
      location: data['location'],
      day: DayOfWeek.values.firstWhere(
        (e) => e.toString() == 'DayOfWeek.${data['day']}',
        orElse: () => DayOfWeek.monday, // Default to Monday if not found
      ),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
    );
  }

  // Convert TimetableEntry to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'subjectName': subjectName,
      'location': location,
      'day': day.name, // Store enum as string
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    };
  }
}