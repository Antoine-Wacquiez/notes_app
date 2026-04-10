import '../models/note.dart';

List<Note> buildDemoNotes() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  var id = 10001;

  Note n(String title, String content, DateTime when, {String folderId = 'notes'}) {
    return Note(
      id: id++,
      title: title,
      content: content,
      folderId: folderId,
      createdAt: when,
      updatedAt: when,
    );
  }

  return [
    n(
      'Planification projet',
      'Découper les tâches et préparer la démo.',
      today.subtract(const Duration(days: 1, hours: 2)),
    ),
    n(
      'Courses',
      'Lait, œufs, riz, café.',
      today.subtract(const Duration(days: 5, hours: 4)),
    ),
    n(
      'Idées',
      'Améliorer l’UI et vérifier les erreurs.',
      DateTime(now.year, _monthBefore(now.month, 1), 18, 11, 30),
    ),
    n(
      'Lecture',
      'Articles Flutter + bonnes pratiques tests.',
      DateTime(now.year, _monthBefore(now.month, 2), 7, 9, 10),
    ),
    n(
      'Archive',
      'Notes anciennes pour tester le tri.',
      DateTime(now.year - 1, 11, 12, 16, 45),
    ),
  ];
}

int _monthBefore(int currentMonth, int offset) {
  var m = currentMonth - offset;
  while (m < 1) {
    m += 12;
  }
  return m;
}
