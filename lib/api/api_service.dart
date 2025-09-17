import 'dart:convert';
import 'dart:io'; // Used for SocketException
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/schedule_model.dart';
import '../models/user_profile_model.dart';

class ApiService {
  // IMPORTANT: Replace this with your computer's actual local IP address
  static const String _baseUrl = 'http://10.51.15.60:8000'; // Example IP

  // --- USER PROFILE METHODS ---

  static Future<void> createUserProfile({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/users');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'email': email,
          'displayName': displayName ?? 'New Chela User',
        }),
      );
    } on SocketException {
      print('Network error: Failed to connect to the server.');
    } catch (e) {
      print('ApiService.createUserProfile Error: $e');
    }
  }
  
  static Future<UserProfile> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');
    
    try {
      final url = Uri.parse('$_baseUrl/users/${user.uid}');
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final Map<String, dynamic>? data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        // Correctly combine data from Auth and Firestore
        return UserProfile.fromJson(user.uid, user.email!, data);
      } else {
        throw Exception('Failed to load profile. Status code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection and IP address.');
    } catch (e) {
      print('ApiService.getUserProfile Error: $e');
      rethrow; // Rethrow the exception to be handled by the UI
    }
  }

  static Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final url = Uri.parse('$_baseUrl/users/${user.uid}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profileData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('ApiService.updateUserProfile Error: $e');
      return false;
    }
  }


  // --- SCHEDULE METHODS ---

  static Future<List<ScheduledEvent>> getSchedule() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    try {
      final url = Uri.parse('$_baseUrl/schedule/${user.uid}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ScheduledEvent.fromJson(json)).toList();
      }
    } catch (e) {
      print('ApiService.getSchedule Error: $e');
    }
    return [];
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