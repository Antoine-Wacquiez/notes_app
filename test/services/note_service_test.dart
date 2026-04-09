import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:notes_app/services/note_service.dart';
import 'package:notes_app/utils/user_messages.dart';

void main() {
  group('NoteService (API HTTP)', () {
    test('succès 200 : parse les posts', () async {
      final payload = [
        {
          'id': 1,
          'title': 't1',
          'body': 'c1',
          'userId': 1,
        },
      ];
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        return http.Response(jsonEncode(payload), 200);
      });
      final service = NoteService(httpClient: client);
      final notes = await service.recupererNotes();
      expect(notes.length, 1);
      expect(notes.first.titre, 't1');
      expect(notes.first.contenu, 'c1');
    });

    test('échec : code HTTP ≠ 200', () async {
      final client = MockClient(
        (_) async => http.Response('Not Found', 404),
      );
      final service = NoteService(httpClient: client);
      expect(
        () => service.recupererNotes(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains(UserMessages.erreurServeur) &&
                e.toString().contains('404'),
          ),
        ),
      );
    });

    test('échec : corps JSON invalide (pas une liste)', () async {
      final client = MockClient(
        (_) async => http.Response('{}', 200),
      );
      final service = NoteService(httpClient: client);
      expect(
        () => service.recupererNotes(),
        throwsA(isA<Exception>()),
      );
    });

    test('échec : ClientException', () async {
      final client = MockClient(
        (request) async => throw http.ClientException('offline', request.url),
      );
      final service = NoteService(httpClient: client);
      expect(
        () => service.recupererNotes(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains(UserMessages.erreurReseau),
          ),
        ),
      );
    });
  });
}
