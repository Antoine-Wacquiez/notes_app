class Citation {
  const Citation({
    required this.texte,
    required this.auteur,
  });

  final String texte;
  final String auteur;

  String asTextePourNote() {
    final auteurAffiche = auteur.trim().isEmpty ? 'Anonyme' : auteur.trim();
    return '« $texte »\n— $auteurAffiche';
  }
}
