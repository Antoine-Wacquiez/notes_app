import '../models/dossier.dart';
import '../services/folder_local_storage.dart';
import '../services/note_storage_exception.dart';
import '../utils/user_messages.dart';
import 'note_repository.dart';

class FolderRepository {
  FolderRepository({
    FolderLocalStorage? folderStorage,
    NoteRepository? noteRepository,
  })  : _folderStorage = folderStorage ?? FolderLocalStorage(),
        _noteRepository = noteRepository ?? NoteRepository();

  final FolderLocalStorage _folderStorage;
  final NoteRepository _noteRepository;

  Future<List<Dossier>> recupererDossiersAvecComptage() async {
    try {
      final dossiers = await _folderStorage.load();
      final notes = await _noteRepository.recupererNotes();
      return dossiers
          .map(
            (d) => Dossier(
              id: d.id,
              name: d.name,
              noteCount: notes.where((n) => n.folderId == d.id).length,
            ),
          )
          .toList();
    } on NoteStorageException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception(UserMessages.erreurChargementNotes);
    }
  }

  Future<void> enregistrerOrdreEtNoms(List<Dossier> dossiers) async {
    try {
      await _folderStorage.save(dossiers);
    } on NoteStorageException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('Impossible d’enregistrer les dossiers.');
    }
  }

  Future<void> ajouterDossier(String nom) async {
    final n = nom.trim();
    if (n.isEmpty) return;
    final list = await _folderStorage.load();
    final id = 'fld_${DateTime.now().microsecondsSinceEpoch}';
    await _folderStorage.save([...list, Dossier(id: id, name: n, noteCount: 0)]);
  }

  Future<void> renommerDossier(String id, String nouveauNom) async {
    final n = nouveauNom.trim();
    if (n.isEmpty) return;
    final list = await _folderStorage.load();
    final updated = list
        .map(
          (d) => d.id == id ? Dossier(id: d.id, name: n, noteCount: d.noteCount) : d,
        )
        .toList();
    await _folderStorage.save(updated);
  }

  Future<void> supprimerDossier(String id) async {
    if (id == 'notes') {
      throw Exception('Le dossier « Notes » ne peut pas être supprimé.');
    }
    final list = await _folderStorage.load();
    if (!list.any((d) => d.id == id)) return;

    final notes = await _noteRepository.recupererNotes();
    for (final note in notes) {
      if (note.folderId == id) {
        note.folderId = 'notes';
      }
    }
    await _noteRepository.saveNotes(notes);

    await _folderStorage.save(list.where((d) => d.id != id).toList());
  }
}
