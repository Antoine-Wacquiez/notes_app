# Tickets projet Flutter Notes

## But du document

Ce document sert a repartir le travail proprement sur le projet.
Chaque ticket indique :

- la feature concernee
- le ou les dossiers dans lesquels travailler
- ce qu'il faut faire concretement
- le resultat attendu

Le but est d'eviter de coder partout sans organisation.

## Organisation conseillee du projet

Structure recommandee :

- `lib/models` : modeles de donnees
- `lib/services` : appels API, stockage local, logique technique
- `lib/repositories` : acces aux donnees
- `lib/screens` : pages de l'application
- `lib/widgets` : composants reutilisables
- `lib/theme` : couleurs, themes, styles
- `test/services` : tests unitaires des services

## Regles de travail

- ne pas mettre toute la logique dans `main.dart`
- chaque feature doit etre rangee dans le bon dossier
- separer l'interface et la logique metier
- faire des noms de fichiers et classes clairs
- tester au minimum les services importants

## Tickets

### Ticket 1 - Structure du projet

- **Feature** : architecture de base
- **Dossiers concernes** : `lib/models`, `lib/services`, `lib/repositories`, `lib/screens`, `lib/widgets`, `lib/theme`
- **Objectif** : mettre en place une base propre pour le projet
- **Travail a faire** :
  - creer les dossiers manquants
  - reorganiser les fichiers si besoin
  - sortir la logique inutile de `main.dart`
  - preparer une navigation simple entre les ecrans
- **Livrable attendu** :
  - projet lisible
  - structure claire
  - point d'entree propre

### Ticket 2 - Modeles de donnees

- **Feature** : gestion des objets de l'application
- **Dossier concerne** : `lib/models`
- **Objectif** : creer les modeles principaux
- **Travail a faire** :
  - creer un modele `Note`
  - creer un modele `Folder` ou `Dossier`
  - ajouter les champs utiles
  - prevoir la conversion depuis/vers JSON si besoin
- **Champs conseilles pour `Note`** :
  - `id`
  - `title`
  - `content`
  - `updatedAt`
  - `folderId`
- **Champs conseilles pour `Folder`** :
  - `id`
  - `name`
  - `noteCount`
- **Livrable attendu** :
  - modeles reutilisables
  - donnees bien structurees

### Ticket 3 - Theme de l'application

- **Feature** : theme clair / sombre
- **Dossier concerne** : `lib/theme`
- **Objectif** : centraliser le style de l'application
- **Travail a faire** :
  - sortir les couleurs du `main.dart`
  - creer un theme clair
  - creer un theme sombre
  - garder une identite visuelle proche de Notes d'Apple
- **Livrable attendu** :
  - themes reutilisables
  - code plus propre

### Ticket 4 - Ecran des dossiers

- **Feature** : liste des dossiers
- **Dossiers concernes** : `lib/screens`, `lib/widgets`
- **Objectif** : afficher les dossiers de notes
- **Travail a faire** :
  - creer ou finaliser l'ecran des dossiers
  - afficher le nom de chaque dossier
  - afficher le nombre de notes
  - permettre la navigation vers les notes d'un dossier
- **Livrable attendu** :
  - ecran fonctionnel
  - navigation claire

### Ticket 5 - Ecran liste des notes

- **Feature** : affichage des notes
- **Dossiers concernes** : `lib/screens`, `lib/widgets`
- **Objectif** : afficher toutes les notes d'un dossier
- **Travail a faire** :
  - creer l'ecran liste des notes
  - afficher titre, extrait et date
  - ajouter la suppression d'une note
  - gerer l'etat vide s'il n'y a aucune note
- **Livrable attendu** :
  - liste fluide
  - interface propre

### Ticket 6 - Creation et edition d'une note

- **Feature** : CRUD de base
- **Dossiers concernes** : `lib/screens`, `lib/widgets`, `lib/models`
- **Objectif** : permettre de creer et modifier une note
- **Travail a faire** :
  - creer l'ecran detail d'une note
  - ajouter les champs titre et contenu
  - gerer la sauvegarde
  - gerer la modification d'une note existante
- **Livrable attendu** :
  - note editable
  - comportement simple et fiable

### Ticket 7 - Stockage local

- **Feature** : persistance des donnees
- **Dossiers concernes** : `lib/services`, `lib/repositories`
- **Objectif** : conserver les notes sans backend
- **Travail a faire** :
  - choisir une solution simple : `Hive`, `SharedPreferences` ou fichier JSON
  - enregistrer les notes localement
  - charger les notes au lancement
  - gerer la suppression et la mise a jour
- **Livrable attendu** :
  - les notes restent apres fermeture de l'app

### Ticket 8 - Recherche de notes

- **Feature** : recherche
- **Dossiers concernes** : `lib/screens`, `lib/widgets`, `lib/repositories`
- **Objectif** : retrouver facilement une note
- **Travail a faire** :
  - ajouter une barre de recherche
  - filtrer les notes par titre ou contenu
  - afficher le resultat en temps reel si possible
- **Livrable attendu** :
  - recherche simple et utile

### Ticket 9 - Gestion d'erreurs

- **Feature** : robustesse de l'application
- **Dossiers concernes** : `lib/services`, `lib/screens`
- **Objectif** : eviter les plantages et informer l'utilisateur
- **Travail a faire** :
  - ajouter des `try/catch` dans les services
  - afficher des `SnackBar` ou messages propres
  - gerer les cas de note vide, erreur reseau, erreur de sauvegarde
- **Livrable attendu** :
  - application plus stable
  - messages utilisateurs clairs

### Ticket 10 - API externe de citations

- **Feature** : integration API externe
- **Dossiers concernes** : `lib/services`, `lib/screens`
- **Objectif** : valider le critere d'appel a une API externe
- **Travail a faire** :
  - creer un service HTTP pour recuperer une citation
  - ajouter un bouton `Ajouter une citation`
  - inserer la citation dans une note
  - gerer le cas d'erreur reseau
- **Livrable attendu** :
  - appel API fonctionnel
  - integration simple et demonstrable

### Ticket 11 - Tests unitaires

- **Feature** : qualite du code
- **Dossier concerne** : `test/services`
- **Objectif** : tester la logique importante
- **Travail a faire** :
  - tester la creation / modification / suppression d'une note
  - tester la recherche
  - tester les services de stockage
  - tester le service API en succes et en echec
- **Livrable attendu** :
  - quelques tests utiles et propres

### Ticket 12 - Finition et livraison

- **Feature** : finalisation du projet
- **Dossiers concernes** : tout le projet
- **Objectif** : rendre une application presentable
- **Travail a faire** :
  - corriger les bugs restants
  - verifier le design
  - nettoyer le code
  - verifier que tout compile
  - preparer la demo
- **Livrable attendu** :
  - projet propre
  - version prete a presenter

## Repartition conseillee pour ton collegue

Si ton collegue doit prendre des tickets bien separes, tu peux lui donner par exemple :

- `Ticket 2` : modeles
- `Ticket 7` : stockage local
- `Ticket 10` : API de citations
- `Ticket 11` : tests unitaires

Pourquoi :

- ce sont des tickets assez techniques
- ils touchent des dossiers clairs
- ils se melangent moins avec le design des ecrans

Et toi, tu peux garder :

- `Ticket 3` : theme
- `Ticket 4` : ecran dossiers
- `Ticket 5` : liste des notes
- `Ticket 6` : creation / edition
- `Ticket 8` : recherche
- `Ticket 9` : gestion d'erreurs
- `Ticket 12` : finition

## Ordre de priorite

Ordre conseille :

1. `Ticket 1`
2. `Ticket 2`
3. `Ticket 3`
4. `Ticket 4`
5. `Ticket 5`
6. `Ticket 6`
7. `Ticket 7`
8. `Ticket 8`
9. `Ticket 9`
10. `Ticket 10`
11. `Ticket 11`
12. `Ticket 12`

## Tickets minimum pour avoir une version rendable

Si jamais vous manquez de temps, il faut absolument finir :

- `Ticket 1`
- `Ticket 2`
- `Ticket 4`
- `Ticket 5`
- `Ticket 6`
- `Ticket 7`
- `Ticket 9`
- `Ticket 10`
- `Ticket 11`

Avec ca, vous avez une version simple mais defendable pour le devoir.
