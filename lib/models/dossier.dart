class Dossier {
  final String id;
  final String name;
  final int noteCount;

  const Dossier({
    required this.id,
    required this.name,
    this.noteCount = 0,
  });

  factory Dossier.fromJson(Map<String, dynamic> json) {
    return Dossier(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      noteCount: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'noteCount': noteCount,
    };
  }

  String get nom => name;
  int get nombreNotes => noteCount;
}
