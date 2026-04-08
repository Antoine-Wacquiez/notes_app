import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/citation.dart';

void main() {
  test('Citation.asTextePourNote formate texte et auteur', () {
    const c = Citation(texte: 'Hello world', auteur: 'Auteur');
    expect(c.asTextePourNote(), '« Hello world »\n— Auteur');
  });

  test('Citation auteur vide → Anonyme', () {
    const c = Citation(texte: 'Seul', auteur: '');
    expect(c.asTextePourNote(), '« Seul »\n— Anonyme');
  });
}
