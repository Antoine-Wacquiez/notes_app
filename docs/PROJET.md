# Documentation du projet `notes_app`

Ce document décrit **toutes les fonctionnalités mises en place** et où elles se trouvent dans le code (classes, fichiers, responsabilités).

## Vue d’ensemble

- **Objectif** : une application type “Notes” avec **dossiers**, **recherche**, **persistance locale**, **checklist**, et une fonctionnalité “bonus” de **citation**.
- **Architecture** (simple et lisible) :
  - **UI** : `lib/screens/*`, `lib/widgets/*`
  - **Données** : `lib/models/*`
  - **Accès aux données** : `lib/repositories/*`
  - **Persistance / services** : `lib/services/*`
  - **Utilitaires (format date, etc.)** : `lib/utils/*`
  - **Tests** : `test/*`

## 1) Dossiers (création, renommage, suppression, comptage)

### Ce qui est fait

- **Lister les dossiers** et afficher le **nombre de notes** par dossier.
- **Rechercher** un dossier par nom.
- **Créer** un dossier.

### Où dans le code

- **Écran dossiers** : `lib/screens/ecran_dossiers.dart`
  - Liste, recherche, dialogues (nouveau dossier / renommer / supprimer).
  - Navigation vers `EcranPrincipal` avec `folderId` / `folderName`.
- **Repository** : `lib/repositories/folder_repository.dart`
  - `recupererDossiersAvecComptage()` : charge dossiers + notes, calcule `noteCount`.
  - `ajouterDossier()`, `renommerDossier()`, `supprimerDossier()`.
- **Stockage local** : `lib/services/folder_local_storage.dart`
  - Stocke **id + name** (le comptage est recalculé).
  - Crée et persiste un dossier par défaut :
    - `id: 'notes'`, `name: 'Notes'`.

## 2) Notes (création, édition, suppression)

### Ce qui est fait

- **Créer** une note (bouton en bas à droite).
- **Éditer** une note (taper sur une note).
- **Supprimer** une note :
  - par **swipe** (hors mode sélection),
  - ou via **suppression multiple** (mode sélection).
- **Undo** après suppression simple (SnackBar “Annuler”).

### Où dans le code

- **Écran liste de notes (d’un dossier)** : `lib/screens/ecran_principal.dart`
  - Chargement, affichage, gestion du tri, suppression, sélection multiple.
  - Persistance après modifications via `_persisterToutesLesNotes()`.
- **Écran détail** : `lib/screens/ecran_detail.dart`
  - Edition titre/contenu.
  - Sauvegarde via `Navigator.pop(context, true)` (l’écran parent persiste ensuite).
- **Widget ligne de note** : `lib/widgets/note_list_tile.dart`
  - Affiche titre + sous-titre (date + résumé).

## 3) Tri, regroupement par mois, “Aujourd’hui”

### Ce qui est fait

- **Tri** des notes :
  - par **date de création** (par défaut),
  - par **date de modification**,
  - par **titre (A–Z)**.
- **Regroupement par mois** dans la liste quand le tri est une date :
  - sections “Avril”, “Février”, “Décembre”… (titre plus gros et en gras).
- **Libellé “Aujourd’hui”** :
  - dans la liste, si une note est du jour → affiche **“Aujourd’hui”**,
  - sur l’écran détail → affiche **“Aujourd’hui à HH:mm”**.

### Où dans le code

- **UI (liste + sections mois)** : `lib/screens/ecran_principal.dart`
  - Tri par défaut : `_TriNotes _tri = _TriNotes.dateCreation;`
  - Regroupement : `_grouperNotesParMois(...)`
  - Affichage sections : `Text(sec.titre, style: ...)` (fontSize plus grand + gras)
- **Format date** : `lib/utils/note_date_format.dart`
  - `formatDateRelativeListe(...)`
  - `formatDateRelativeDetail(...)`
  - `titreSectionMois(year, month, ...)`
  - Comparaison “même jour” en **heure locale** (`toLocal()`).
- **Affichage dans une ligne de note** : `lib/widgets/note_list_tile.dart`
  - `${formatDateRelativeListe(note.date)}  ${note.resumePourListe()}`

### Pourquoi un mois peut être “en haut”

La liste est triée en **ordre décroissant** (le plus récent d’abord). Si une note a un `createdAt` plus récent (ex. en décembre), la section “Décembre” passe avant “Avril”.

## 4) Recherche (notes + dossiers)

### Ce qui est fait

- Recherche **instantanée** :
  - **dans les notes** (titre + contenu),
  - **dans les dossiers** (nom).

### Où dans le code

- **Notes** :
  - UI : `lib/screens/ecran_principal.dart` (`TextEditingController` + `_filtrerNotes`)
  - Moteur : `lib/repositories/note_repository.dart` → `filtrerParRecherche(...)`
- **Dossiers** : `lib/screens/ecran_dossiers.dart` → `_dossiersFiltres`

## 5) Checklist (tâches dans une note)

### Ce qui est fait

- Une note peut contenir une **liste de tâches** (checklist) avec état coché/non coché.
- Lors de la sauvegarde :
  - les entrées vides sont filtrées,
  - la checklist est copiée proprement dans la note.

### Où dans le code

- Modèle : `lib/models/note_check_item.dart`
- Intégration note : `lib/models/note.dart` (`List<NoteCheckItem> checklist`)
- UI et logique : `lib/screens/ecran_detail.dart`
  - `_checkItems`, `_checkCtrls`, `_syncChecklistDepuisControleurs()`

## 6) Persistance locale (notes + dossiers)

### Ce qui est fait

- Les **notes** et **dossiers** sont persistés localement en **JSON** dans `SharedPreferences`.
- Robustesse :
  - gestion d’erreurs dédiée via `NoteStorageException`,
  - messages utilisateur centralisés.
- Données de démo :
  - si `seedDemoWhenEmpty: true`, au premier lancement sans notes, l’app **injecte des notes de démonstration**.

### Où dans le code

- Notes :
  - stockage : `lib/services/note_local_storage.dart`
  - repo : `lib/repositories/note_repository.dart`
  - démo : `lib/data/demo_notes.dart`
- Dossiers :
  - stockage : `lib/services/folder_local_storage.dart`
  - repo : `lib/repositories/folder_repository.dart`
- Exceptions : `lib/services/note_storage_exception.dart`
- Messages : `lib/utils/user_messages.dart`

## 7) Citations (appel réseau)

### Ce qui est fait

- Récupération d’une **citation aléatoire** via DummyJSON (meilleure compatibilité CORS en Web).
- Gestion d’erreurs (timeout, client exception, format JSON, etc.) avec messages utilisateur.

### Où dans le code

- Service : `lib/services/citation_service.dart`
- UI (chargement/affichage dans l’éditeur) : `lib/screens/ecran_detail.dart`
- Modèle : `lib/models/citation.dart`

## 8) Tests automatisés

### Ce qui est fait

- Tests unitaires sur :
  - le filtrage de recherche des notes,
  - la persistance simulée du repository (via fake storage),
  - le formatage des dates (“Aujourd’hui”, mois, année).

### Où dans le code

- `test/services/note_repository_test.dart`
- `test/utils/note_date_format_test.dart`
- (et autres tests présents dans `test/`)

## 9) Dépendances principales

Déclarées dans `pubspec.yaml` :

- `shared_preferences` : persistance locale JSON
- `http` : appels réseau (citations)

## 10) Points pratiques (développement)

- Si `flutter pub get` échoue avec `Failed host lookup: 'pub.dev'` :
  - vérifier DNS / proxy / VPN / pare-feu.
- Le Web peut avoir des contraintes (CORS) : d’où l’utilisation d’une API de citations compatible navigateur.

