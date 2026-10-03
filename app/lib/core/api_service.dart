import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000'; // Android emulator localhost
    } else {
      return 'http://127.0.0.1:8000'; // iOS emulator / Desktop
    }
  }

  static Future<Map<String, String>> _getHeaders([String? token]) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Fallback to reading from SharedPreferences if no token passed explicitly
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('jwt_token');
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final headers = await _getHeaders(token);
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> postForm(
      String endpoint, Map<String, String> body) async {
    // Specifically for OAuth2 application/x-www-form-urlencoded
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };

    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body,
    );
  }

  static Future<http.Response> get(String endpoint, {String? token}) async {
    final headers = await _getHeaders(token);
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  static Future<http.Response> delete(String endpoint, {String? token}) async {
    final headers = await _getHeaders(token);
    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final headers = await _getHeaders(token);
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
