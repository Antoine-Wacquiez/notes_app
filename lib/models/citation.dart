/// Citation renvoyée par l’API externe (texte + auteur).
class Citation {
  const Citation({
    required this.texte,
    required this.auteur,
  });

  final String texte;
  final String auteur;

  /// Texte prêt à être inséré dans le corps d’une note.
  String asTextePourNote() {
    final auteurAffiche = auteur.trim().isEmpty ? 'Anonyme' : auteur.trim();
    return '« $texte »\n— $auteurAffiche';
  }
}
