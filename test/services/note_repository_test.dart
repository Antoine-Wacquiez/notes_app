import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/repositories/note_repository.dart';
import 'package:notes_app/services/note_local_storage.dart';

/// Stockage en mémoire pour tester le dépôt sans I/O réel.
class FakeNoteLocalStorage extends NoteLocalStorage {
  FakeNoteLocalStorage([List<Note>? initial])
      : _notes = List.from(initial ?? []),
        super();

  List<Note> _notes;

  @override
  Future<List<Note>> load() async => List.from(_notes);

  @override
  Future<void> save(List<Note> notes) async {
    _notes = List.from(notes);
  }
}

void main() {
  Note n(int id, String title, String content) => Note(
        id: id,
        title: title,
        content: content,
      );

  group('NoteRepository.filtrerParRecherche', () {
    final repo = NoteRepository(localStorage: FakeNoteLocalStorage());

    test('vide ou espaces → toutes les notes', () {
      final notes = [n(1, 'A', 'x'), n(2, 'B', 'y')];
      expect(repo.filtrerParRecherche(notes, ''), notes);
      expect(repo.filtrerParRecherche(notes, '   '), notes);
    });

    test('filtre par titre', () {
      final notes = [n(1, 'Courses', 'lait'), n(2, 'Travail', 'réunion')];
      final r = repo.filtrerParRecherche(notes, 'cour');
      expect(r.length, 1);
      expect(r.first.id, 1);
    });

    test('filtre par contenu', () {
      final notes = [n(1, 'A', 'mot de passe'), n(2, 'B', 'rien')];
      final r = repo.filtrerParRecherche(notes, 'passe');
      expect(r.length, 1);
      expect(r.first.id, 1);
    });

    test('aucun résultat', () {
      final notes = [n(1, 'A', 'b')];
      expect(repo.filtrerParRecherche(notes, 'zzz'), isEmpty);
    });
  });

  group('NoteRepository persistance (création / mise à jour / suppression)', () {
    test('création : save une note puis load retrouve le contenu', () async {
      final fake = FakeNoteLocalStorage();
      final repo = NoteRepository(localStorage: fake);
      expect(await repo.recupererNotes(), isEmpty);

      await repo.saveNotes([n(10, 'Titre', 'Corps')]);
      final loaded = await repo.recupererNotes();
      expect(loaded.length, 1);
      expect(loaded.first.id, 10);
      expect(loaded.first.titre, 'Titre');
      expect(loaded.first.contenu, 'Corps');
    });

    test('modification : met à jour une note existante', () async {
      final note = n(1, 'Ancien', 'texte');
      final fake = FakeNoteLocalStorage([note]);
      final repo = NoteRepository(localStorage: fake);

      final list = await repo.recupererNotes();
      list.first.title = 'Nouveau titre';
      list.first.content = 'Nouveau corps';
      await repo.saveNotes(list);

      final again = await repo.recupererNotes();
      expect(again.single.titre, 'Nouveau titre');
      expect(again.single.contenu, 'Nouveau corps');
    });

    test('suppression : liste réduite après save', () async {
      final fake = FakeNoteLocalStorage([
        n(1, 'a', 'a'),
        n(2, 'b', 'b'),
      ]);
      final repo = NoteRepository(localStorage: fake);

      var list = await repo.recupererNotes();
      list.removeWhere((x) => x.id == 1);
      await repo.saveNotes(list);

      final loaded = await repo.recupererNotes();
      expect(loaded.length, 1);
      expect(loaded.single.id, 2);
    });
  });
}
