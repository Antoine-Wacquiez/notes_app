# Présentation (≈ 15 minutes) — `notes_app`

Objectif : te donner un **script prêt à lire** (avec timing), pour présenter **point par point** ce qui a été fait, en montrant l’app et en reliant chaque fonctionnalité au code.

> Conseil : fais la démo en conditions réelles (mode clair/sombre, recherche, tri, etc.). Garde cette doc ouverte pendant la présentation.

---

## 0) Intro (0:00 → 1:00)

### Ce que tu dis

- “On présente vous ducoup une application Flutter inspirée d’Apple Notes.”
- “Le but était de faire une app **front-end only** avec une logique produit : dossiers, notes, recherche, persistance locale, et une **API externe** pour valider le critère du devoir.”
- “On va d’abord montrer le parcours utilisateur, puis expliquer l’architecture, la persistance, l’API, la gestion d’erreurs et les tests.”

### Ce que tu montres

- L’écran **Dossiers**.
- Le style général (proche Notes).

---

## 1) Parcours utilisateur global (1:00 → 2:30)

### Ce que tu dis

- “L’app s’organise comme Apple Notes : on arrive sur les dossiers, puis on ouvre un dossier pour voir ses notes.”
- “Dans un dossier, on peut créer une note, l’éditer, la supprimer, rechercher, et trier.”

### Ce que tu montres (rapide)

- Ouvrir un dossier.
- Ouvrir une note.
- Revenir en arrière.

### Fichiers à citer

- UI dossiers : `lib/screens/ecran_dossiers.dart`
- UI liste notes : `lib/screens/ecran_principal.dart`
- UI détail note : `lib/screens/ecran_detail.dart`

---

## 2) Dossiers (2:30 → 4:30)

### Ce que tu dis

- “Les dossiers sont persistés localement et affichent le **nombre de notes** qu’ils contiennent.”
- “On peut créer,  un dossier.”
- “Le dossier par défaut **‘Notes’** ne peut pas être supprimé.”
- “Si on supprime un dossier, ses notes sont **déplacées** vers le dossier ‘Notes’.”

### Démo (à faire)

- Créer un dossier (“Cours”, “Perso”…).
- Renommer.
- Supprimer un dossier contenant des notes → montrer le déplacement.

### Points techniques (résumé)

- “Stockage des dossiers : SharedPreferences en JSON (id + name).”
- “Le comptage est recalculé à partir des notes.”

### Fichiers à citer

- Écran + dialogues : `lib/screens/ecran_dossiers.dart`
- Logique dossiers + comptage : `lib/repositories/folder_repository.dart`
- Stockage dossiers : `lib/services/folder_local_storage.dart`
- Modèle : `lib/models/dossier.dart`

---

## 3) Notes : CRUD + UX suppression (4:30 → 7:30)

### Ce que tu dis

- “Dans un dossier, on affiche la liste des notes.”
- “On peut créer une note, la modifier, et la supprimer.”
- “La suppression se fait au choix : swipe (simple) ou mode sélection (multi-suppression).”
- “En suppression simple, on a un **Undo** via SnackBar.”

### Démo (à faire)

- Créer une nouvelle note (bouton).
- Écrire titre + contenu.
- Revenir → la note apparaît.
- Swipe pour supprimer → Annuler.
- Activer “Sélectionner des notes” → supprimer plusieurs.

### Fichiers à citer

- Liste + actions : `lib/screens/ecran_principal.dart`
- Édition + sauvegarde : `lib/screens/ecran_detail.dart`
- Rendu d’une ligne : `lib/widgets/note_list_tile.dart`
- Modèle note : `lib/models/note.dart`

---

## 4) Recherche + Tri + Regroupement par mois + “Aujourd’hui” (7:30 → 10:00)

### Ce que tu dis

- “La recherche filtre en direct sur le **titre et le contenu**.”
- “Le tri est disponible : date de création (par défaut), date de modification, ou titre.”
- “Quand le tri est une date, l’affichage est regroupé **par mois** comme Apple Notes.”
- “Si une note est du jour, on affiche **‘Aujourd’hui’** dans la liste et ‘Aujourd’hui à HH:mm’ dans le détail.”

### Démo (à faire)

- Rechercher un mot-clé.
- Changer le tri (création / modification / titre).
- Montrer les sections “Avril”, “Février”… (en-têtes gros/gras).
- Montrer une note du jour : “Aujourd’hui”.

### Points techniques (résumé)

- “La mise en forme des dates est centralisée dans un utilitaire.”
- “On compare les dates en local (`toLocal()`) pour respecter le fuseau de l’appareil.”

### Fichiers à citer

- Tri + regroupement : `lib/screens/ecran_principal.dart`
- Format dates + titres de section : `lib/utils/note_date_format.dart`
- Recherche notes : `lib/repositories/note_repository.dart` (`filtrerParRecherche`)
- Affichage sous-titre : `lib/widgets/note_list_tile.dart`

---

## 5) Checklist (tâches dans une note) (10:00 → 11:00)

### Ce que tu dis

- “Chaque note peut contenir une checklist de tâches.”
- “À la sauvegarde, on nettoie les entrées vides et on conserve les tâches renseignées quelles que soient l'état.”

### Démo (à faire)

- Ajouter 2–3 tâches.
- Cocher une tâche.
- Revenir à la liste, rouvrir → les états sont conservés.

### Fichiers à citer

- Modèle : `lib/models/note_check_item.dart`
- Intégration et UI : `lib/screens/ecran_detail.dart`
- Stockage dans la note : `lib/models/note.dart` (champ `checklist`)

---

## 6) Persistance locale (11:00 → 12:45)

### Ce que tu dis

- “L’app est 100% locale : notes et dossiers sont persistés via SharedPreferences en JSON.”
- “On a une gestion d’erreurs dédiée : exceptions de stockage + messages utilisateur centralisés.”
- “En cas de souci de chargement, l’UI affiche un état d’erreur avec ‘Réessayer’.”

### Démo (option si tu as le temps)

- Montrer qu’après redémarrage, les notes/dossiers sont encore là.

### Fichiers à citer

- Notes storage : `lib/services/note_local_storage.dart`
- Dossiers storage : `lib/services/folder_local_storage.dart`
- Exception dédiée : `lib/services/note_storage_exception.dart`
- Messages : `lib/utils/user_messages.dart`
- UI état erreur (liste notes) : `lib/screens/ecran_principal.dart`

---

## 7) Connexion à une API externe (citations) (12:45 → 13:45)

### Ce que tu dis

- “Pour le critère ‘connexion à une API externe’, on a intégré un service de citations.”
- “On appelle DummyJSON (meilleure compatibilité CORS en Flutter Web), avec timeout et gestion d’erreurs.”
- “La citation peut être insérée dans une note.”

### Démo (si réseau OK)

- Appuyer sur “Citation” → afficher la citation, et l’insérer dans le contenu.

### Fichiers à citer

- Service API : `lib/services/citation_service.dart`
- Intégration UI : `lib/screens/ecran_detail.dart`
- Modèle : `lib/models/citation.dart`

---

## 8) Tests unitaires (13:45 → 14:30)

### Ce que tu dis

- “On a ajouté des tests unitaires sur les services/logiciels clés.”
- “Exemple : filtrage de recherche + persistance simulée et formatage des dates (‘Aujourd’hui’, titres de mois).”

### Ce que tu montres (si possible)

- Lancer `flutter test` (ou montrer le dossier `test/` si pas de réseau).

### Fichiers à citer

- Tests repository notes : `test/services/note_repository_test.dart`
- Tests format date : `test/utils/note_date_format_test.dart`

---

## 9) Appli prête au déploiement + conclusion (14:30 → 15:00)

### Ce que tu dis

- “On a préparé le projet pour être déployable en **release**.”
- “Sur Android, une release doit être **signée** : on a ajouté la configuration de signature via `key.properties` et `build.gradle.kts`.”
- “On peut ensuite générer un APK de release (`flutter build apk --release`).”
- “En résumé : dossiers + notes + recherche/tri + persistance locale + API externe + tests.”
- “L’app est stable, lisible, et répond aux critères d’évaluation.”

### Ce que tu montres (option)

- Montrer rapidement que `build/app/outputs/flutter-apk/app-release.apk` existe.

### Fichiers à citer

- `android/app/build.gradle.kts`
- `android/key.properties` (sans afficher les mots de passe en public)

---

