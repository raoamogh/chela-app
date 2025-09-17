import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/schedule_model.dart';

class ApiService {
  // IMPORTANT: Replace this with your computer's actual local IP address
  static const String _baseUrl = 'http://10.116.223.152:8000'; // Example IP

  static Future<void> createUserProfile({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/users');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'email': email,
          'displayName': displayName ?? 'New Chela User',
        }),
      );
      if (response.statusCode == 200) {
        print("User profile created in backend successfully.");
      } else {
        print("Failed to create user profile in backend: ${response.body}");
      }
    } catch (e) {
      print('ApiService.createUserProfile Error: $e');
    }
  }

  static Future<List<ScheduledEvent>> getSchedule() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final url = Uri.parse('$_baseUrl/schedule/${user.uid}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ScheduledEvent.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      print('ApiService.getSchedule Error: $e');
      return [];
    }
  }

  static Future<ScheduledEvent?> addTask(CreateScheduledEvent event) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final url = Uri.parse('$_baseUrl/schedule/${user.uid}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toJson()),
      );
      if (response.statusCode == 200) {
        return ScheduledEvent.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('ApiService.addTask Error: $e');
    }
    return null;
  }

  static Future<bool> completeTask(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final url = Uri.parse('$_baseUrl/schedule/${user.uid}/$eventId/complete');
      final response = await http.put(url);
      return response.statusCode == 200;
    } catch (e) {
      print('ApiService.completeTask Error: $e');
      return false;
    }
  }

  static Future<bool> undoCompleteTask(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final url = Uri.parse('$_baseUrl/schedule/${user.uid}/$eventId/undo');
      final response = await http.put(url);
      return response.statusCode == 200;
    } catch (e) {
      print('ApiService.undoCompleteTask Error: $e');
      return false;
    }
  }
}