/// Erreur liée à la lecture ou l’écriture locale des notes.
class NoteStorageException implements Exception {
  NoteStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
