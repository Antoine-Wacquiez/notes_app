import '../models/note.dart';
import '../services/note_local_storage.dart';
import '../services/note_storage_exception.dart';
import '../utils/user_messages.dart';

/// Point d’accès aux notes : lecture / écriture locale uniquement.
class NoteRepository {
  NoteRepository({NoteLocalStorage? localStorage})
    : _localStorage = localStorage ?? NoteLocalStorage();

  final NoteLocalStorage _localStorage;

  /// Charge les notes persistées (liste vide si aucune donnée).
  Future<List<Note>> recupererNotes() async {
    try {
      return await _localStorage.load();
    } on NoteStorageException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(UserMessages.erreurChargementNotes);
    }
  }

  /// Remplace l’ensemble des notes sur le disque.
  Future<void> saveNotes(List<Note> notes) async {
    try {
      await _localStorage.save(notes);
    } on NoteStorageException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(UserMessages.erreurSauvegardeNotes);
    }
  }

  /// Filtre les notes par titre ou contenu (insensible à la casse).
  ///
  /// [query] vide ou uniquement des espaces : retourne une copie de la liste source.
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
