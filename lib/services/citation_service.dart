import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/citation.dart';
import '../utils/user_messages.dart';

/// Récupère une citation via [DummyJSON](https://dummyjson.com/docs/quotes#quotes-random).

class CitationService {
  CitationService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://dummyjson.com/quotes/random';
  static const Duration _timeout = Duration(seconds: 12);

  Future<Citation> recupererAleatoire() async {
    final uri = Uri.parse(_baseUrl);
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw Exception(
          '${UserMessages.erreurServeur} (code ${response.statusCode})',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw Exception(UserMessages.erreurServeur);
      }
      final body = Map<String, dynamic>.from(decoded);
      final texte = body['quote'] ?? body['content'];
      final auteur = body['author'];
      if (texte is! String || texte.trim().isEmpty) {
        throw Exception(UserMessages.erreurServeur);
      }
      final auteurStr = auteur is String ? auteur : '';
      return Citation(texte: texte.trim(), auteur: auteurStr.trim());
    } on TimeoutException catch (e, st) {
      debugPrint('CitationService timeout: $e\n$st');
      throw Exception('Délai dépassé. ${UserMessages.erreurReseau}');
    } on http.ClientException catch (e, st) {
      debugPrint('CitationService ClientException: $e\n$st');
      throw Exception(UserMessages.erreurReseau);
    } on FormatException catch (e, st) {
      debugPrint('CitationService FormatException: $e\n$st');
      throw Exception(UserMessages.erreurServeur);
    } catch (e, st) {
      debugPrint('CitationService: $e\n$st');
      if (e is Exception) rethrow;
      throw Exception(UserMessages.erreurReseau);
    }
  }
}
