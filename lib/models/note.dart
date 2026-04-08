class Note {
  int id;
  String title;
  String content;
  DateTime updatedAt;
  String folderId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    DateTime? updatedAt,
    this.folderId = 'notes',
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw is int ? idRaw : (idRaw as num).toInt();
    return Note(
      id: id,
      title: (json['title'] ?? json['titre'] ?? 'Sans titre') as String,
      content: (json['content'] ?? json['body'] ?? json['contenu'] ?? '') as String,
      updatedAt: _parseDate(json['updatedAt'] ?? json['date']),
      folderId: (json['folderId'] ?? 'notes') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
      'folderId': folderId,
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
}
