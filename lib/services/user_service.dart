import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class UserService {
  // Base URL de ejemplo; sustituye por la real
  static const String _baseUrl = 'https://api.example.com';

  static Map<String, String> _defaultHeaders(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // GET /users/me
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final resp = await http.get(Uri.parse('$_baseUrl/users/me'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to load profile: ${resp.statusCode}');
  }

  // PUT /users/me
  static Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> data) async {
    final resp = await http.put(Uri.parse('$_baseUrl/users/me'), headers: {..._defaultHeaders(token), 'Content-Type': 'application/json'}, body: json.encode(data));
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to update profile: ${resp.statusCode}');
  }

  // POST /users/me/avatar
  static Future<Map<String, dynamic>> uploadAvatar(String token, File file) async {
    final uri = Uri.parse('$_baseUrl/users/me/avatar');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_defaultHeaders(token));
    final multipartFile = await http.MultipartFile.fromPath('avatar', file.path);
    request.files.add(multipartFile);
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to upload avatar: ${resp.statusCode}');
  }

  // DELETE /users/me/avatar
  static Future<bool> deleteAvatar(String token) async {
    final resp = await http.delete(Uri.parse('$_baseUrl/users/me/avatar'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200 || resp.statusCode == 204) return true;
    throw HttpException('Failed to delete avatar: ${resp.statusCode}');
  }

  // POST /auth/logout
  static Future<Map<String, dynamic>> logout(String token) async {
    final resp = await http.post(Uri.parse('$_baseUrl/auth/logout'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) return json.decode(resp.body) as Map<String, dynamic>;
    throw HttpException('Failed to logout: ${resp.statusCode}');
  }
}
