# Démo — application Notes

## Objectif

Montrer en 2–3 minutes : navigation, CRUD notes, recherche, persistance locale, appel API (citation).

## Préparation

- Lancer avec un **port web fixe** pour la persistance :  
  `flutter run -d chrome --web-port=8080`
- Connexion Internet pour le bouton **Ajouter une citation**.

## Parcours suggéré

1. **Dossiers**  
   - Montrer le dossier « Notes » et le compteur (si chargé).

2. **Liste des notes**  
   - Créer 2–3 notes (bouton crayon en bas à droite).  
   - Utiliser la **barre de recherche** sur un mot du titre ou du contenu.  
   - Glisser une note pour **supprimer** (avec annulation possible via la barre).

3. **Édition**  
   - Ouvrir une note.  
   - **Ajouter une citation** : le texte s’insère dans le corps.  
   - **OK** pour enregistrer.

4. **Persistance**  
   - Fermer l’onglet ou l’app, rouvrir la même URL (`http://localhost:8080`) : les notes sont toujours là.

5. **Thème** (optionnel)  
   - Depuis l’écran Dossiers, basculer clair / sombre via l’icône en bas.

## Limites connues (à mentionner si question)

- **Web** : le stockage dépend de l’origine (hôte + port) ; changer de port = données « vides ».  
- **Citations** : API tierce ; en cas d’erreur, un message réseau s’affiche.
