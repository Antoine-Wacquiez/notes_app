import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:notes_app/services/citation_service.dart';
import 'package:notes_app/utils/user_messages.dart';

void main() {
  group('CitationService (API HTTP)', () {
    test('succès 200 : parse quote + author', () async {
      final payload = {
        'id': 1,
        'quote': 'Hello',
        'author': 'World',
      };
      final client = MockClient(
        (_) async => http.Response(jsonEncode(payload), 200),
      );
      final service = CitationService(httpClient: client);
      final c = await service.recupererAleatoire();
      expect(c.texte, 'Hello');
      expect(c.auteur, 'World');
    });

    test('échec : code HTTP 500', () async {
      final client = MockClient(
        (_) async => http.Response('err', 500),
      );
      final service = CitationService(httpClient: client);
      expect(
        () => service.recupererAleatoire(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains(UserMessages.erreurServeur) &&
                e.toString().contains('500'),
          ),
        ),
      );
    });

    test('échec : quote vide', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'quote': '', 'author': 'A'}),
          200,
        ),
      );
      final service = CitationService(httpClient: client);
      expect(
        () => service.recupererAleatoire(),
        throwsA(isA<Exception>()),
      );
    });

    test('échec : ClientException', () async {
      final client = MockClient(
        (request) async => throw http.ClientException('fail', request.url),
      );
      final service = CitationService(httpClient: client);
      expect(
        () => service.recupererAleatoire(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains(UserMessages.erreurReseau),
          ),
        ),
      );
    });
  });
}
