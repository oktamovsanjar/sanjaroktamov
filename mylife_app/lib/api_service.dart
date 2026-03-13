import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // If running in Android emulator, localhost is 10.0.2.2
  // Otherwise use localhost. For production, replace with actual server IP/Domain.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  static Future<List<dynamic>> getTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks/'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
    return [];
  }

  static Future<void> addTask(String title) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/tasks/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title}),
      );
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  static Future<void> completeTask(int taskId) async {
    try {
      await http.put(Uri.parse('$baseUrl/tasks/$taskId/complete'));
    } catch (e) {
      debugPrint('Error completing task: $e');
    }
  }
  
  static Future<void> deleteTask(int taskId) async {
    try {
      await http.delete(Uri.parse('$baseUrl/tasks/$taskId'));
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  static Future<List<dynamic>> getHabits() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/habits/'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching habits: $e');
    }
    return [];
  }

  static Future<void> addHabit(String title, {String frequency = "daily"}) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/habits/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'frequency': frequency}),
      );
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
  }
}
