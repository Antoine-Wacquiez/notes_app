import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/note.dart';
import '../utils/user_messages.dart';

/// Appel HTTP distant (démo / import). Gestion d’erreurs réseau explicite.
class NoteService {
  NoteService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';
  static const Duration _timeout = Duration(seconds: 12);

  Future<List<Note>> recupererNotes() async {
    final uri = Uri.parse(_baseUrl);
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is! List<dynamic>) {
          throw Exception(UserMessages.erreurServeur);
        }
        return body.take(10).map((json) {
          final map = Map<String, dynamic>.from(json as Map);
          return Note.fromJson(map);
        }).toList();
      }
      throw Exception(
        '${UserMessages.erreurServeur} (code ${response.statusCode})',
      );
    } on TimeoutException catch (e, st) {
      debugPrint('NoteService timeout: $e\n$st');
      throw Exception('Délai dépassé. ${UserMessages.erreurReseau}');
    } on http.ClientException catch (e, st) {
      debugPrint('NoteService ClientException: $e\n$st');
      throw Exception(UserMessages.erreurReseau);
    } on FormatException catch (e, st) {
      debugPrint('NoteService FormatException: $e\n$st');
      throw Exception(UserMessages.erreurServeur);
    } catch (e, st) {
      debugPrint('NoteService: $e\n$st');
      if (e is Exception) rethrow;
      throw Exception(UserMessages.erreurReseau);
    }
  }
}
