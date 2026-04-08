# Notes (Flutter)

Application de prise de notes avec dossiers, recherche, stockage local (`SharedPreferences`) et insertion de citations via API (DummyJSON).

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (SDK ^3.9.2)

## Lancer le projet

```bash
cd notes_app
flutter pub get
flutter run -d chrome --web-port=8080
```

Pour le **bureau Windows** : `flutter run -d windows`

Pour les **tests** :

```bash
flutter test
flutter analyze
```

## Démo (scénario rapide)

1. Écran **Dossiers** → ouvrir **Notes**.
2. Créer une note (icône crayon), renseigner titre / texte, **OK**.
3. Vérifier la **recherche** dans la barre du haut.
4. Ouvrir une note → **Ajouter une citation** (nécessite Internet).
5. Fermer l’app et rouvrir : les notes **persistent** (même origine `localhost` en web, ex. port fixe).

Voir aussi `docs/DEMO.md` pour le détail du parcours de présentation.

## Documentation projet

- `docs/DOC_PROJET_NOTES.md` — vision produit / technique  
- `docs/TICKETS_PROJET_NOTES.md` — tickets et périmètre
