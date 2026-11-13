# MesMots - Règles de développement

## Principes de code

### Réutilisabilité
- **Prioriser la création de widgets réutilisables** plutôt que de dupliquer du code
- Extraire les composants UI communs dans `lib/shared/widgets/`
- Utiliser des paramètres pour rendre les widgets configurables

### Style de design
- L'application utilise un style **Mr. Square** avec :
  - Fond turquoise avec formes flottantes
  - Boutons/cartes colorés avec ombre 3D (offset sans blur)
  - Effet de pression animé (translation + réduction de l'ombre)
  - Police Fredoka
  - Palette : Orange, Rose, Bleu, Magenta, Coral

### Couleurs
- Toutes les couleurs sont définies dans `lib/core/constants/app_colors.dart`
- Ne jamais hardcoder de couleurs directement dans les widgets

### Widgets existants à réutiliser
- `ColorfulButton` : Bouton coloré avec effet 3D
- `GradientBackground` : Fond turquoise avec formes flottantes
- `AppHeader` : En-tête avec titre et actions
- `ParentSpaceButton` : Bouton rond aux couleurs du thème avec le symbole parent (SVG), ouvre l'espace parent
- `AppInput` : Champ de saisie avec effet 3D

## Structure
```
lib/
├── core/constants/     # Couleurs, dimensions, typographie
├── shared/widgets/     # Widgets réutilisables
├── features/           # Fonctionnalités (Clean Architecture)
```
