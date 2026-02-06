class Note {
  int id;
  String titre;
  String contenu;
  DateTime date;

  Note({
    required this.id,
    required this.titre,
    required this.contenu,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      titre: json['title'] ?? 'Sans titre',
      contenu: json['body'] ?? '',
    );
  }
}
