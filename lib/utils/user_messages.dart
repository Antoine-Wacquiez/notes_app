class UserMessages {
  UserMessages._();

  static const String erreurChargementNotes =
      'Impossible de charger tes notes. Réessaie dans un instant.';

  static const String erreurSauvegardeNotes =
      'Impossible d’enregistrer tes notes. Réessaie dans un instant.';

  static const String noteVide =
      'Ajoute un titre, du texte, une tâche ou une pièce jointe avant d’enregistrer.';

  static const String pieceJointeTropVolumineuse =
      'Ce fichier est trop volumineux pour cet appareil ou le navigateur.';

  static const String pieceJointeLectureImpossible =
      'Impossible de lire ce fichier. Réessaie.';

  static const String dossierNomVide = 'Donne un nom au dossier.';

  static const String dossierSupprimeNotesDeplacees =
      'Les notes de ce dossier ont été déplacées vers « Notes ».';

  static const String erreurReseau =
      'Pas de connexion ou serveur injoignable. Vérifie ta connexion.';

  static const String erreurServeur = 'Le serveur a renvoyé une erreur.';

  static const String erreurComptageNotes =
      'Impossible de mettre à jour le nombre de notes.';

  static const String bientotDisponible = 'Bientôt disponible.';

  static String depuisErreur(Object e) {
    final s = e.toString();
    if (s.startsWith('Exception: ')) {
      return s.substring(11);
    }
    return s;
  }
}
