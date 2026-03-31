import '../models/note.dart';
import '../services/note_service.dart';

class NoteRepository {
  final NoteService _noteService;

  NoteRepository({NoteService? noteService})
    : _noteService = noteService ?? NoteService();

  Future<List<Note>> recupererNotes() {
    return _noteService.recupererNotes();
  }
}
