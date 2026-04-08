/// Textes affichés à l’utilisateur (erreurs, validations).
class UserMessages {
  UserMessages._();

  static const String erreurChargementNotes =
      'Impossible de charger tes notes. Réessaie dans un instant.';

  static const String erreurSauvegardeNotes =
      'Impossible d’enregistrer tes notes. Réessaie dans un instant.';

  static const String noteVide =
      'Ajoute un titre ou du texte avant d’enregistrer.';

  static const String erreurReseau =
      'Pas de connexion ou serveur injoignable. Vérifie ta connexion.';

  static const String erreurServeur = 'Le serveur a renvoyé une erreur.';

  static const String erreurComptageNotes =
      'Impossible de mettre à jour le nombre de notes.';

  static const String bientotDisponible = 'Bientôt disponible.';

  /// Extrait un texte lisible depuis une [Exception] ou autre erreur.
  static String depuisErreur(Object e) {
    final s = e.toString();
    if (s.startsWith('Exception: ')) {
      return s.substring(11);
    }
    return s;
  }
}
