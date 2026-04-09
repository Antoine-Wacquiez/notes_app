import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/services/note_local_storage.dart';
import 'package:notes_app/services/note_storage_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Note note(int id, String title, String content) => Note(
        id: id,
        title: title,
        content: content,
      );

  group('NoteLocalStorage', () {
    test('load : préférences vides → liste vide', () async {
      final storage = NoteLocalStorage();
      expect(await storage.load(), isEmpty);
    });

    test('save puis load : round-trip', () async {
      final storage = NoteLocalStorage();
      final notes = [note(1, 'A', 'a'), note(2, 'B', 'b')];
      await storage.save(notes);
      final loaded = await storage.load();
      expect(loaded.length, 2);
      expect(loaded.first.id, 1);
      expect(loaded.first.title, 'A');
      expect(loaded.last.contenu, 'b');
    });

    test('load : entrées JSON invalides ignorées, notes valides conservées', () async {
      final prefs = await SharedPreferences.getInstance();
      final corrupt = jsonEncode([
        {'id': 1, 'title': 'OK', 'content': 'x', 'updatedAt': DateTime.now().toIso8601String(), 'folderId': 'notes'},
        'pas une map',
      ]);
      await prefs.setString('notes_app_v1_notes', corrupt);
      final storage = NoteLocalStorage();
      final loaded = await storage.load();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'OK');
    });

    test('load : JSON qui n’est pas une liste → NoteStorageException', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notes_app_v1_notes', '"hello"');
      final storage = NoteLocalStorage();
      await expectLater(
        storage.load(),
        throwsA(isA<NoteStorageException>()),
      );
    });
  });
}
