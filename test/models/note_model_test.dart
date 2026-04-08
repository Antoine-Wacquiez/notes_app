import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/note.dart';

void main() {
  group('Note', () {
    test('round-trip JSON', () {
      final note = Note(
        id: 1,
        title: 'Titre',
        content: 'Contenu',
        folderId: 'notes',
      );
      final json = note.toJson();
      final restored = Note.fromJson(json);
      expect(restored.id, note.id);
      expect(restored.title, note.title);
      expect(restored.content, note.content);
      expect(restored.folderId, note.folderId);
    });
  });
}
