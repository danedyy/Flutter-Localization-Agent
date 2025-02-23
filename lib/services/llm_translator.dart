import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_localization_agent/flutter_localization_agent.dart';
import 'package:flutter_localization_agent/services/api_exception.dart';
import 'package:http/http.dart' as http;

/// Abstract interface for LLM-based translators.
abstract class LLMTranslator {
  /// Translates or processes text using the LLM.
  Future<Map<String, String>> processTranslation({
    required Map<String, String> input,
    required Language targetLanguage,
  });
}

/// Enum for selecting the Large Language Model.
enum LLM {
  /// Gemini API - https://ai.google.dev/gemini-api/docs
  gemini,
}

/// Factory for creating LLM translators.
class LLMTranslatorFactory {
  /// Creates an LLMTranslator instance based on the selected LLM and API key.
  static LLMTranslator createTranslator(LLM llm, String apiKey) {
    switch (llm) {
      case LLM.gemini:
        return GeminiTranslator(apiKey);
    }
  }
}

/// Gemini translator using Google gemini-1.5-flash API.
class GeminiTranslator implements LLMTranslator {
  final String apiKey;

  GeminiTranslator(this.apiKey);

  @override
  Future<Map<String, String>> processTranslation({
    required Map<String, String> input,
    required Language targetLanguage,
  }) async {
    if (apiKey.isEmpty) throw Exception('Gemini API key is required');
    try {
      log('Translating with Gemini API');
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {
                      "text":
                          "Translate the *values* of the following JSON object to ${targetLanguage.code} which is ${targetLanguage.name}. Keep the JSON structure and keys unchanged. The JSON object is: ```json\n${jsonEncode(input)}\n```",
                    },
                  ],
                },
              ],

              "generationConfig": {"response_mime_type": "application/json"},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final candidates = decodedResponse['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null) {
                try {
                  // Attempt to parse the translated text as JSON
                  return Map<String, String>.from(jsonDecode(text));
                } catch (e) {
                  throw FormatException('Unexpected response format');
                }
              }
            }
          }
        }
        throw FormatException('Unexpected response format');
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
