class NoteStorageException implements Exception {
  NoteStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
