import 'note_check_item.dart';

class Note {
  int id;
  String title;
  String content;
  DateTime updatedAt;
  DateTime createdAt;
  String folderId;
  List<NoteCheckItem> checklist;

  Note({
    required this.id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.folderId = 'notes',
    List<NoteCheckItem>? checklist,
  })  : updatedAt = updatedAt ?? DateTime.now(),
        createdAt = createdAt ?? updatedAt ?? DateTime.now(),
        checklist = checklist ?? [];

  factory Note.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw is int ? idRaw : (idRaw as num).toInt();
    final updated = _parseDate(json['updatedAt'] ?? json['date']);
    final created = _parseDate(json['createdAt']);
    return Note(
      id: id,
      title: (json['title'] ?? json['titre'] ?? 'Sans titre') as String,
      content: (json['content'] ?? json['body'] ?? json['contenu'] ?? '') as String,
      createdAt: created ?? updated ?? DateTime.now(),
      updatedAt: updated ?? DateTime.now(),
      folderId: (json['folderId'] ?? 'notes') as String,
      checklist: _parseChecklist(json['checklist']),
    );
  }

  static List<NoteCheckItem> _parseChecklist(dynamic raw) {
    if (raw is! List<dynamic>) return [];
    final out = <NoteCheckItem>[];
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        out.add(NoteCheckItem.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {}
    }
    return out;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'folderId': folderId,
      'checklist': checklist.map((e) => e.toJson()).toList(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String get titre => title;
  set titre(String value) => title = value;

  String get contenu => content;
  set contenu(String value) => content = value;

  DateTime get date => updatedAt;
  set date(DateTime value) => updatedAt = value;

  /// Aperçu pour la liste (texte + indices liste / pièces jointes).
  String resumePourListe() {
    final parts = <String>[];
    final t = contenu.replaceAll('\n', ' ').trim();
    if (t.isNotEmpty) parts.add(t);
    if (checklist.isNotEmpty) {
      parts.add('${checklist.length} tâche${checklist.length > 1 ? 's' : ''}');
    }
    return parts.join(' · ');
  }
}
