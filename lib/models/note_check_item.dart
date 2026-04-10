class NoteCheckItem {
  int id;
  String label;
  bool checked;

  NoteCheckItem({
    required this.id,
    required this.label,
    this.checked = false,
  });

  factory NoteCheckItem.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw is int ? idRaw : (idRaw as num).toInt();
    return NoteCheckItem(
      id: id,
      label: (json['label'] ?? '') as String,
      checked: json['checked'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'checked': checked,
      };

  NoteCheckItem copy() =>
      NoteCheckItem(id: id, label: label, checked: checked);
}
