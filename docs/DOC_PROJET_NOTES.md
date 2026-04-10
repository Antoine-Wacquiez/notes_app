# Documentation rapide du projet

## Sujet

Le projet consiste a recreer les bases de l'application **Notes d'Apple** avec Flutter.
L'objectif n'est pas de copier toute l'application officielle, mais de proposer une version propre, claire, moderne et fonctionnelle qui reprend les usages principaux.
Le projet est pense ici comme une application **100% front-end** : on ne developpe pas de backend.

## Objectif global

Construire une application mobile Flutter permettant de :

- afficher une liste de dossiers
- afficher les notes d'un dossier
- creer, modifier et supprimer une note
- rechercher une note
- gerer un theme clair/sombre
- avoir une interface inspiree d'Apple Notes

Le projet doit aussi respecter les criteres du devoir : structure propre, gestion d'erreurs, tests unitaires, connexion a une API externe et application prete au deploiement.
La logique de donnees sera geree directement dans l'application avec du stockage local ou des donnees mockees selon le besoin.

---

## Etat actuel du projet (ce qui est vraiment implemente)

Cette section decrit **l’implementation reelle** telle qu’elle existe dans le code du projet.

### Fonctionnalites principales

- **Dossiers** : creation, renommage, recherche, comptage des notes par dossier
  - UI : `lib/screens/ecran_dossiers.dart`
  - Donnees : `lib/models/dossier.dart`
  - Acces / logique : `lib/repositories/folder_repository.dart`
  - Stockage : `lib/services/folder_local_storage.dart`
- **Notes** : creation, edition, suppression (swipe), suppression multiple (mode selection), recherche
  - UI liste : `lib/screens/ecran_principal.dart`
  - UI edition : `lib/screens/ecran_detail.dart`
  - Widget ligne : `lib/widgets/note_list_tile.dart`
  - Donnees : `lib/models/note.dart`
  - Acces / logique : `lib/repositories/note_repository.dart`
  - Stockage : `lib/services/note_local_storage.dart`
- **Tri & affichage des dates** :
  - tri par **date de creation** (par defaut), par **date de modification**, ou par **titre**
  - regroupement par **mois** quand le tri est une date (en-tetes plus gros + gras)
  - “Aujourd’hui” si la note est du jour (liste + detail)
  - UI : `lib/screens/ecran_principal.dart`
  - format date : `lib/utils/note_date_format.dart`
- **Checklist (taches dans une note)** :
  - modele : `lib/models/note_check_item.dart`
  - edition + sauvegarde : `lib/screens/ecran_detail.dart`
- **API externe (citations)** :
  - service : `lib/services/citation_service.dart` (DummyJSON, compatible Web/CORS)
  - integration UI : `lib/screens/ecran_detail.dart`
  - modele : `lib/models/citation.dart`
- **Persistance locale** (SharedPreferences + JSON) :
  - notes : `lib/services/note_local_storage.dart`
  - dossiers : `lib/services/folder_local_storage.dart`
  - exceptions : `lib/services/note_storage_exception.dart`
  - donnees demo au premier lancement (option) : `lib/data/demo_notes.dart`

### Tests existants

- Recherche + persistance simulee via fake storage : `test/services/note_repository_test.dart`
- Format date (inclut “Aujourd’hui” + titres de sections mois) : `test/utils/note_date_format_test.dart`
- Autres tests selon le repo : dossier, widgets, etc. dans `test/`

---

## Ce qu'on doit reproduire de Notes d'Apple

### Fonctionnalites minimum attendues

1. **Ecran des dossiers**
  - afficher plusieurs dossiers ou categories
  - nombre de notes par dossier
  - navigation vers la liste des notes
2. **Ecran liste des notes**
  - afficher le titre
  - afficher un extrait du contenu
  - afficher la date de derniere modification
  - possibilite de supprimer une note
  - barre de recherche
3. **Ecran detail / edition**
  - creer une nouvelle note
  - modifier une note existante
  - sauvegarde automatique ou via bouton
  - titre + contenu
4. **UX proche d'Apple Notes**
  - interface simple
  - couleurs sobres
  - typographie lisible
  - animations ou transitions legeres si possible

## Perimetre conseille pour le devoir

Pour rester realiste et efficace, on peut viser un **MVP** puis ajouter des bonus.

### MVP

- création dossier
- CRUD des notes
- stockage local
- recherche
- theme clair/sombre
- gestion d'erreurs
- tests unitaires sur les services

### Bonus

- tri par date ou titre

## Proposition technique

### Stack

- **Flutter** pour l'application mobile
- **Provider**, **Riverpod** ou **Bloc** pour l'etat
- **Hive**, **Isar**, **SharedPreferences** ou fichiers JSON pour le stockage local
- **http** ou **dio** pour l'API externe
- **go_router** si on veut une navigation plus propre

### Important : pas de backend

Le projet ne necessite pas de backend maison.
On garde toute la logique dans l'application Flutter :

- donnees locales pour les notes et dossiers
- services Flutter pour lire/ecrire les donnees
- appel direct a une API externe seulement pour valider le critere du devoir

Autrement dit :

- pas de serveur Node, Java, PHP, Python, etc.
- pas de base de donnees distante obligatoire
- pas d'API REST a construire

### Architecture conseillee

Organisation simple et claire :

- `lib/models`
- `lib/services`
- `lib/repositories`
- `lib/screens`
- `lib/widgets`
- `lib/theme`
- `lib/utils`

Exemple de responsabilites :

- `models` : objets `Note`, `Folder`
- `services` : stockage local, appels API
- `repositories` : logique d'acces aux donnees
- `screens` : pages de l'application
- `widgets` : composants reutilisables

## Comment repondre aux criteres du devoir

Cette partie repond **directement** aux points de la diapo “CRITERE D’EVALUATION”.

### 1. Choix du projet valide

Le projet est clair : refaire les bases de **Notes d'Apple** en Flutter avec une vraie logique produit.

### 2. Connexion a une API externe

Comme le projet reste en front uniquement, l'API externe doit etre consommee **directement depuis Flutter**.
Comme Notes d'Apple n'utilise pas naturellement une API publique simple, il faut ajouter une fonctionnalite coherente. Exemples :

- API de citations pour inserer une citation dans une note
- API de traduction pour traduire le contenu d'une note
- API de date/jour ou de geolocalisation pour enrichir une note

La solution retenue pour le projet sera :

- **API de citations**
- bouton "Ajouter une inspiration"
- une citation est recuperee puis inseree dans la note

Donc on respecte le critere "API externe" sans creer de backend.

### Mise en oeuvre retenue

Dans l'application :

- un bouton permettra d'ajouter automatiquement une citation
- Flutter fera un appel HTTP vers une API publique de citations
- la reponse sera transformee en texte exploitable
- la citation sera ajoutee dans le contenu d'une note
- en cas d'echec, un message d'erreur sera affiche

Cette solution est simple, rapide a developper et facile a justifier lors de la presentation du projet.

### 3. Gestion d'erreurs

Il faudra gerer au minimum :

- erreur reseau lors de l'appel API
- erreur de sauvegarde locale
- note vide ou titre vide
- dossier introuvable

Concretement :

- afficher des `SnackBar`
- afficher un message vide ou erreur dans les listes
- entourer les appels critiques avec `try/catch`

#### Mise en place dans le code

- Messages utilisateurs centralises : `lib/utils/user_messages.dart`
- Erreurs stockage local isolees : `lib/services/note_storage_exception.dart`
- Stockage notes/dossiers avec `try/catch` et messages propres :
  - `lib/services/note_local_storage.dart`
  - `lib/services/folder_local_storage.dart`
- Repositories qui exposent des `Exception` “propres” :
  - `lib/repositories/note_repository.dart`
  - `lib/repositories/folder_repository.dart`
- UI qui affiche un ecran d’erreur + bouton “Reessayer” sur la liste de notes :
  - `lib/screens/ecran_principal.dart`

### 4. Tests unitaires des services

Tester surtout :

- creation / suppression / modification d'une note
- recherche de notes
- recuperation des donnees depuis le stockage local
- appel API externe avec succes / echec

#### Mise en place dans le code

- Tests repository notes (recherche + persistance via fake storage) :
  - `test/services/note_repository_test.dart`
- Tests format date (inclut “Aujourd’hui” + titres de mois) :
  - `test/utils/note_date_format_test.dart`

### 5. Application prete au deploiement

Cela veut dire :

- pas de code brouillon
- pas de bug bloquant
- navigation fonctionnelle
- app testable de bout en bout
- icone, nom d'app, splash si possible
- mode release sans erreurs

#### Note “pret au deploiement”

- Le projet est structure et peut etre build en release (Android/iOS/Desktop/Web selon cible).
- Pour Android release, la signature se configure via keystore (voir consignes de cours : `android/app/build.gradle(.kts)` + `key.properties`).

### 6. Code structure et clair

Il faudra :

- separer UI et logique metier
- eviter de tout mettre dans `main.dart`
- donner des noms explicites aux classes et methodes
- reutiliser des widgets

#### Mise en place dans le code

- Separation par dossiers : `models/`, `services/`, `repositories/`, `screens/`, `widgets/`, `utils/`
- Widgets reutilisables :
  - `lib/widgets/note_list_tile.dart`
  - `lib/widgets/dossier_tile.dart`
  - `lib/widgets/barre_recherche_notes.dart`

### 7. Participation

Ce point depend du contexte du cours (presence, rendu, participation orale). Le projet contient :

- une fonctionnalite principale complete (notes + dossiers)
- plusieurs bonus techniques (selection multiple, regroupement par mois, “Aujourd’hui”, API citations)

---

## Bonus (diapo)

### Theme sombre/clair

- **Implemente** (toggle dans l’UI des dossiers).
- Point d’entree : `lib/screens/ecran_dossiers.dart` (bouton mode clair/sombre)
- Les ecrans utilisent `isDark` pour adapter couleurs (ex. `EcranPrincipal`, `EcranDetail`).

### i18n (plusieurs langues)

- **Non implemente** a ce stade (l’app est en francais).
- Si demande : on peut ajouter `flutter_localizations` + fichiers `arb`.

### Firebase (secrets, monitoring, etc.)

- **Non implemente** (projet 100% local).
- Si demande : ajout de Crashlytics pour le monitoring + gestion des secrets via variables d’environnement / `--dart-define`.

## Plan de developpement conseille

### Etape 1

Mettre en place la structure du projet :

- modeles
- navigation
- theme
- stockage local
- faux jeux de donnees ou persistance locale

### Etape 2

Construire les ecrans principaux :

- dossiers
- liste des notes
- detail d'une note

### Etape 3

Ajouter la logique :

- CRUD
- recherche
- tri
- gestion des erreurs

### Etape 4

Ajouter l'API externe.

### Etape 5

Ajouter les tests unitaires.

### Etape 6

Faire la finition :

- UI plus propre
- icone
- responsive
- verification finale

## Livrable attendu a la fin

Une application Flutter qui :

- ressemble a une version simplifiee de Notes d'Apple
- permet de gerer des notes facilement
- utilise du stockage local
- consomme au moins une API externe
- gere les erreurs proprement
- contient des tests unitaires de services

## Conclusion

Le projet doit etre vu comme une **reproduction fonctionnelle simplifiee** de Notes d'Apple, pas comme une copie parfaite.
Dans ce cadre, une approche **front-end only** est largement suffisante si elle est propre et bien justifiee.
Le plus important pour le devoir est d'avoir :

- une application utile et propre
- une architecture claire
- une API externe bien integree
- des tests
- une bonne presentation finale

