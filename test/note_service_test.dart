import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/main.dart'; // <--- Vérifie que c'est bien le nom de ton projet

void main() {
  group('Tests Logiciels Note', () {
    test('Conversion JSON vers Objet Note', () {
      final json = {'id': 1, 'title': 'Achat pomme', 'body': 'Granny Smith'};
      final note = Note.fromJson(json);

      expect(note.id, 1);
      expect(note.titre, 'Achat pomme');
      expect(note.contenu, 'Granny Smith');
    });
  });
}
