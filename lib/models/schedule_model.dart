import 'package:flutter/material.dart';

class ScheduledEvent {
  final String id;
  final String subject;
  final String startTime;
  final String endTime;
  final Color color;
  final String location;
  bool isCompleted;

  ScheduledEvent({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.location,
    required this.isCompleted,
  });

  factory ScheduledEvent.fromJson(Map<String, dynamic> json) {
    return ScheduledEvent(
      id: json['id'],
      subject: json['subject'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      color: _colorFromHex(json['color']),
      location: json['location'],
      isCompleted: json['isCompleted'],
    );
  }

  static Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";
    return Color(int.parse(hexColor, radix: 16));
  }
}

// This is the completed class definition
class CreateScheduledEvent {
  final String subject;
  final String startTime;
  final String endTime;
  final String color;
  final String location;

  CreateScheduledEvent({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'startTime': startTime,
    'endTime': endTime,
    'color': color,
    'location': location,
  };
}