# 🗺️ Roguelike Multiplayer - Jeu de Salles Procédurales

Un jeu roguelike multijoueur avec génération procédurale de salles, système de graphe 12x12, et commandes admin professionnelles!

## 🎮 Gameplay

### Concept
- **Monde partagé**: Tous les joueurs explorent le même graphe de salles
- **Génération procédurale**: Les salles se créent à la demande quand tu passes les portes
- **Course vers l'arrivée**: Le premier à atteindre la salle Z (arrivée) termine la partie pour tous
- **Collecte de pièces**: Ramasse des étoiles colorées pour gagner des points

### Objectif
1. Partir de la salle O (départ - verte)
2. Explorer les salles en passant par les portes bleues brillantes
3. Collecter un maximum de pièces (étoiles 3D animées)
4. Trouver et atteindre la salle Z (arrivée - dorée)

## 🏗️ Système de Graphe

### Grille 12x12
- 144 salles possibles
- Point O (départ): Centre de la grille (6, 6)
- Point Z (arrivée): Généré à minimum 10 salles de distance
- Chaque salle = 50x50 studs
- Espacement = 50 studs entre salles

### Génération Procédurale
- **À la demande**: Les salles ne sont créées que quand un joueur passe une porte
- **Persistantes**: Une salle créée reste dans le monde
- **Partagées**: Tous les joueurs voient les mêmes salles
- **Portes intelligentes**: Toujours au moins une porte mène vers Z

### Séparation Visuelle
- **Murs épais** (15 studs) entre chaque salle
- **Hauteur** de 40 studs (bloque complètement la vue)
- **Piliers décoratifs** aux 4 coins
- **Style low-poly** cohérent

## 👑 Système Admin

### Commandes Disponibles

#### Navigation
- `/tp [x] [y]` - Téléporter à une salle spécifique
- `/pos` - Afficher ta position dans la grille
- `/compass` - **Toggle boussole** pointant vers l'arrivée

#### Gestion Joueurs
- `/players` - Lister tous les joueurs et leurs positions
- `/givecoins [nom] [montant]` - Donner des coins à un joueur
- `/setcoins [montant]` - Définir ton propre score

#### Debug
- `/showgrid` - Afficher la grille 12x12 dans la console
- `/help` - Liste de toutes les commandes

#### Partie
- `/endgame` - Terminer la partie immédiatement

### Interface Admin
- **Badge rouge** "👑 ADMIN" en haut à gauche
- **Panneau cliquable** avec liste des commandes
- **Utilisation**: Tape les commandes dans le chat Roblox

### Ajouter des Admins
Édit: `src/server/AdminCommands.luau`
```lua
AdminCommands.ADMINS = {
    ["HiShikuro"] = true,  -- Par nom
    ["AutreNom"] = true,
    [123456789] = true,    -- Par UserId
}
```

## 🧭 Boussole vers Z

### Commande: `/compass`
Active/désactive une boussole au centre de l'écran qui:
- **Pointe toujours vers la salle Z** (arrivée)
- **Affiche la distance** en nombre de salles
- **Cercle doré** avec flèche rouge
- **Texte "🏆 ARRIVÉE"** en haut

## 🚀 Installation

### Prérequis
- [Rojo](https://rojo.space/) installé
- Roblox Studio
- Plugin Rojo dans Studio

### Lancer le Jeu

1. **Terminal**:
   ```bash
   cd testRob
   rojo serve
   ```

2. **Roblox Studio**:
   - Ouvrir Studio
   - Plugin Rojo → Connect (port 34872)
   - Play (F5)

3. **En Jeu**:
   - Tu spawns dans la salle O (verte)
   - Traverse les portes bleues brillantes
   - Collecte les étoiles colorées (clique dessus)
   - Trouve la salle Z (dorée) pour gagner!

## 📁 Structure du Projet

```
testRob/
├── src/
│   ├── server/
│   │   ├── init.server.luau       # Serveur principal + graphe
│   │   └── AdminCommands.luau     # Système de commandes admin
│   │
│   └── client/
│       └── init.client.luau       # Client + UI + boussole
│
├── default.project.json            # Config Rojo
├── selene.toml                     # Linter Roblox
└── README.md
```

## 🎨 Style Visuel Low-Poly

### Couleurs des Salles
- **Départ (O)**: Vert clair `RGB(100, 255, 100)`
- **Arrivée (Z)**: Doré `RGB(255, 200, 50)`
- **Normale**: Vert herbe `RGB(85, 160, 85)`
- **Murs**: Gris foncé `RGB(50, 50, 60)`
- **Piliers**: Gris `RGB(40, 40, 50)`

### Portes
- **Actives**: Bleu brillant `RGB(100, 200, 255)` + lumière
- **Inactives**: Gris `RGB(60, 60, 60)` + bloquées

### Étoiles (Pièces)
- 5 couleurs aléatoires
- Forme étoile 3D à 6 pointes
- Animation de rotation + flottement
- Highlight coloré autour

## ⚙️ Configuration

### Gameplay
Dans `src/server/init.server.luau`:
```lua
local CONFIG = {
    COIN_VALUE = 10,              -- Points par pièce
    ROOM_SIZE = 50,               -- Taille des salles
    ROOM_SPACING = 50,            -- Espacement
    MIN_COINS_PER_ROOM = 3,       -- Min pièces/salle
    MAX_COINS_PER_ROOM = 8,       -- Max pièces/salle
    MIN_OBSTACLES = 0,            -- Min obstacles/salle
    MAX_OBSTACLES = 5,            -- Max obstacles/salle
    GRID_SIZE = 12,               -- Taille grille
    MIN_PATH_LENGTH = 10,         -- Distance min O→Z
}
```

## 📊 Leaderboard

Deux statistiques trackées:
- **Coins**: Score total de pièces collectées
- **Salles**: Nombre de salles visitées

## 🏆 Fin de Partie

Quand un joueur atteint la salle Z:
1. **Partie terminée** pour TOUS les joueurs
2. **Écran de fin** s'affiche pour tous
3. **Classement** des joueurs par coins
4. **1ère place** avec fond doré
5. **Affichage** du gagnant et des scores

## 🎯 Fonctionnalités Techniques

### Serveur
- ✅ Génération procédurale de salles
- ✅ Graphe orienté 12x12
- ✅ Système de portes intelligent (toujours un chemin vers Z)
- ✅ Monde partagé persistant
- ✅ Système de permissions admin
- ✅ Commandes via chat
- ✅ RemoteEvents pour client/serveur

### Client
- ✅ UI moderne avec score en haut à droite
- ✅ Effets visuels (cercles colorés, camera shake)
- ✅ Écran de fin avec classement
- ✅ Interface admin professionnelle
- ✅ Boussole interactive vers Z
- ✅ Animations fluides

## 🔧 Debug

### Console Serveur
- `🚀` Démarrage
- `🗺️` Génération de la grille
- `🔨` Création de salle
- `🚪` Passage de porte
- `📍` Position joueur
- `💰` Collecte de pièce
- `🏆` Fin de partie
- `👑` Admin connecté
- `💬` Commande exécutée

### Console Client
- `✅` Systèmes prêts
- `💰` Collecte confirmée
- `🧭` Boussole toggle
- `🏆` Fin de partie

## 🐛 Troubleshooting

**Portes ne fonctionnent pas:**
- Vérifie la console Output pour les logs
- Les portes grises sont inactives (normalement)

**Pas de pièces dans une salle:**
- La salle de départ (O) n'a pas de pièces
- La salle d'arrivée (Z) n'a pas de pièces

**Commandes admin ne marchent pas:**
- Vérifie que ton nom est dans `AdminCommands.ADMINS`
- Les commandes doivent être tapées dans le **chat Roblox**
- Commence toujours par `/`

**Boussole ne s'affiche pas:**
- Tape `/compass` dans le chat
- Vérifie que tu es admin
- Retape `/compass` pour toggle

## 🎮 Tips de Gameplay

1. **Explore intelligemment**: Les portes pointent vers Z
2. **Collecte en route**: Ne perds pas de temps à tout ramasser
3. **Mémorise le chemin**: Tu peux revenir en arrière
4. **Course finale**: Quand tu vois la salle dorée, fonce!

## 📝 Crédits

- **Admin**: HiShikuro
- **Architecture**: Graphe orienté + Génération procédurale
- **Style**: Low-poly sans textures (SmoothPlastic)
- **Framework**: Rojo + Luau

---

🎮 **Bon jeu et que le meilleur gagne!**
