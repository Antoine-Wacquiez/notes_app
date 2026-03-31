import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteListTile extends StatelessWidget {
  final Note note;
  final Color couleurTexte;
  final VoidCallback onTap;

  const NoteListTile({
    super.key,
    required this.note,
    required this.couleurTexte,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        note.titre.isEmpty ? 'Nouvelle note' : note.titre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: couleurTexte,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          "${note.date.hour.toString().padLeft(2, '0')}:${note.date.minute.toString().padLeft(2, '0')}  ${note.contenu.replaceAll('\n', ' ')}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
      ),
    );
  }
}
