import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiService {

  static Future<String> ask(String prompt, {int? courseId}) async {
    final base = dotenv.env['API_BASE_URL'];
    if (base != null && base.isNotEmpty) {
      try {
  

  final baseClean = base.replaceAll(RegExp(r"/+$"), "");
        final uri = Uri.parse('$baseClean/chat/send');

        final headers = {'Content-Type': 'application/json'};
        // Read AUTH_TOKEN and strip surrounding single/double quotes if present.
        final rawToken = dotenv.env['AUTH_TOKEN'];
        String? token;
        if (rawToken != null && rawToken.isNotEmpty) {
          token = rawToken;
          if (token.length > 1) {
            final first = token[0];
            final last = token[token.length - 1];
            if ((first == "'" && last == "'") || (first == '"' && last == '"')) {
              token = token.substring(1, token.length - 1);
            }
          }
        }
        if (token != null && token.isNotEmpty) {
          headers['Auth-token'] = token;
        }

        final Map<String, dynamic> body = {'message': prompt};
        if (courseId != null) body['course_id'] = courseId;

        final resp = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        ).timeout(Duration(seconds: 10));

        // (debug prints removed)

        if (resp.statusCode == 200) {
          // Try to decode JSON first. The backend may return:
          //  - a JSON object {"response": "..."} (current API)
          //  - a JSON object {"answer": "..."} (legacy API)
          //  - a JSON string: "..." (FastAPI serializes plain str as JSON string)
          //  - plain text (non-JSON)
          try {
            final data = jsonDecode(resp.body);
            if (data is Map) {
              final responseText = data['response'] ?? data['answer'];
              if (responseText != null) {
                return responseText.toString();
              }
            }
            if (data is String) {
              return data;
            }
          } catch (_) {
            // Not JSON — return plain text response
            return resp.body;
          }
        }
      } catch (e) {
        // ignore and fallback to mock
      }
    }

    // Fallback mocked AI behaviour: simple canned answers based on keywords.
    return _mockedAnswer(prompt);
  }

  static String _mockedAnswer(String prompt) {
    final p = prompt.toLowerCase();
    if (p.contains('physical agents') || p.contains('agents')) {
      return 'It refers to the use of natural elements and physical principles for treatment, such as heat, cold, water, light, and electricity, among others.';
    }
    if (p.contains('manual') || p.contains('massage') || p.contains('manual techniques')) {
      return 'Includes massages and testing and evaluations to measure muscle strength, range of motion, and function.';
    }
    if (p.contains('duration') || p.contains('how long')) {
      return 'The course duration is typically listed in the course details; check the Duration section for exact hours.';
    }
    // Generic fallback
    return 'I can help with course topics, summaries and examples. Could you be more specific about what you want to know?';
  }
}
