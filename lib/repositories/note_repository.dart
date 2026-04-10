import '../models/note.dart';
import '../services/note_local_storage.dart';
import '../services/note_storage_exception.dart';
import '../utils/user_messages.dart';

class NoteRepository {
  NoteRepository({NoteLocalStorage? localStorage})
    : _localStorage =
          localStorage ?? NoteLocalStorage(seedDemoWhenEmpty: true);

  final NoteLocalStorage _localStorage;

  Future<List<Note>> recupererNotes() async {
    try {
      return await _localStorage.load();
    } on NoteStorageException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(UserMessages.erreurChargementNotes);
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    try {
      await _localStorage.save(notes);
    } on NoteStorageException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(UserMessages.erreurSauvegardeNotes);
    }
  }

  List<Note> filtrerParRecherche(Iterable<Note> notes, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return List<Note>.from(notes);
    }
    return notes
        .where(
          (n) =>
              n.titre.toLowerCase().contains(q) ||
              n.contenu.toLowerCase().contains(q),
        )
        .toList();
  }
}
