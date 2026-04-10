import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_colors.dart';
import '../utils/note_date_format.dart';

class NoteListTile extends StatelessWidget {
  final Note note;
  final Color couleurTexte;
  final VoidCallback onTap;
  final bool selectionMode;
  final bool selected;

  const NoteListTile({
    super.key,
    required this.note,
    required this.couleurTexte,
    required this.onTap,
    this.selectionMode = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: selectionMode
          ? Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.jauneNotes : Colors.grey.shade500,
              size: 26,
            )
          : null,
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
          "${formatDateRelativeListe(note.date)}  ${note.resumePourListe()}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
      ),
    );
  }
}
