# 📁 Structure Complète du Projet

## 🎯 Vue d'ensemble

Voici la structure finale du projet après refactorisation.

```
testRob/
├── 📄 README.md                          # Guide utilisateur du jeu
├── 📄 ARCHITECTURE.md                    # Documentation technique complète
├── 📄 REFACTORING_SUMMARY.md             # Résumé de la refactorisation
├── 📄 PROJECT_STRUCTURE.md               # Ce fichier
├── 📄 Note.md                            # Notes de développement
│
├── ⚙️ default.project.json               # Configuration Rojo
├── ⚙️ rokit.toml                         # Configuration Rokit
├── ⚙️ selene.toml                        # Configuration Selene (linter)
├── 📄 .gitignore
│
└── 📂 src/
    ├── 📂 shared/                        # Code partagé serveur/client
    │   ├── Config.luau                   # (Ancien) Configuration client
    │   └── RemoteEvents.luau             # (Ancien) Gestion remotes
    │
    ├── 📂 server/                        # ⭐ CODE SERVEUR (REFACTORISÉ)
    │   ├── 🎮 init.server.luau           # Point d'entrée (149 lignes)
    │   ├── 👑 AdminCommands.luau         # Système de commandes admin
    │   ├── 🎯 RoundManager.luau          # Gestion des rounds (REFACTORISÉ)
    │   │
    │   ├── 📂 Config/                    # ⚙️ Configuration
    │   │   └── ServerConfig.luau         # Configuration centralisée
    │   │
    │   ├── 📂 Services/                  # 🔧 Services du jeu
    │   │   ├── RemoteService.luau        # ⭐ Gestion des RemoteEvents
    │   │   ├── GridService.luau          # ⭐ Gestion de la grille 12x12
    │   │   ├── PlayerManager.luau        # ⭐ Gestion des joueurs
    │   │   ├── LightingService.luau      # ⭐ Configuration de l'éclairage
    │   │   ├── CoinService.luau          # (Ancien) Service de pièces
    │   │   ├── PlayerService.luau        # (Ancien) Service joueurs
    │   │   └── WorldService.luau         # (Ancien) Service monde
    │   │
    │   └── 📂 Modules/                   # 🏭 Modules métier
    │       ├── EntityFactory.luau        # ⭐ Fabrique d'entités
    │       ├── RoomFactory.luau          # ⭐ Fabrique de salles
    │       ├── PathfindingService.luau   # ⭐ Génération des chemins
    │       └── WorldManager.luau         # ⭐ Orchestrateur du monde
    │
    └── 📂 client/                        # 💻 CODE CLIENT
        ├── init.client.luau              # Point d'entrée client
        ├── SoundManager.luau             # Gestion des sons
        │
        ├── 📂 Controllers/               # Contrôleurs client
        │   ├── UIController.luau
        │   ├── EffectsController.luau
        │   ├── SoundController.luau
        │   ├── CoinController.luau
        │   ├── DoorController.luau
        │   ├── CompassController.luau
        │   └── RoundController.luau
        │
        ├── 📂 effects/                   # Effets visuels
        │   ├── CollectEffects.luau
        │   └── CameraEffects.luau
        │
        └── 📂 ui/                        # Interfaces utilisateur
            ├── ScoreUI.luau
            ├── RoundUI.luau
            ├── EndScreenUI.luau
            ├── TimerUI.luau
            ├── CompassUI.luau
            └── AdminUI.luau
```

---

## 🆕 Nouveaux fichiers (Architecture refactorisée)

### Configuration
✅ **Config/ServerConfig.luau**
- Configuration centralisée de tout le jeu
- Remplace les constantes hardcodées

### Services (Couche de base)
✅ **Services/RemoteService.luau**
- Gestion centralisée des RemoteEvents
- API propre pour communiquer avec le client

✅ **Services/GridService.luau**
- Gestion de la grille 12x12
- Positions des joueurs et des salles
- Conversions grille ↔ monde

✅ **Services/PlayerManager.luau**
- Gestion des joueurs
- Leaderboard (Coins, Salles)
- Stats et classements

✅ **Services/LightingService.luau**
- Configuration de l'éclairage
- Effets visuels (Bloom, ColorCorrection)

### Modules (Couche métier)
✅ **Modules/EntityFactory.luau**
- Création des pièces (coins)
- Création des obstacles
- Création des portes

✅ **Modules/RoomFactory.luau**
- Création de salles complètes
- Sol, murs, piliers
- Population (coins + obstacles)

✅ **Modules/PathfindingService.luau**
- Génération intelligente des portes
- Garantit un chemin vers Z
- Distance Manhattan

✅ **Modules/WorldManager.luau**
- Orchestrateur principal
- Téléportation des joueurs
- Gestion de la fin de partie
- Reset du monde

### Fichiers refactorisés
✅ **init.server.luau**
- Réduit de 795 → 149 lignes (81% de réduction)
- Orchestre l'initialisation
- Point d'entrée propre

✅ **RoundManager.luau**
- Refactorisé pour utiliser WorldManager
- API orientée objet (`:Init()`, `:StartNewRound()`)
- Utilise ServerConfig

---

## 📝 Anciens fichiers (à nettoyer éventuellement)

### Services/
- ⚠️ **CoinService.luau** - Ancien service, remplacé par EntityFactory
- ⚠️ **PlayerService.luau** - Ancien service, remplacé par PlayerManager
- ⚠️ **WorldService.luau** - Ancien service, remplacé par WorldManager + LightingService

### Shared/
- ⚠️ **Config.luau** - Ancien système de config (utilisé par le client ?)
- ⚠️ **RemoteEvents.luau** - Ancien système (remplacé par RemoteService)

**Note:** Ces fichiers peuvent être supprimés si non utilisés par le client.

---

## 🎯 Fichiers principaux par responsabilité

### 🎮 Orchestration
```
init.server.luau              → Point d'entrée, initialise tout
RoundManager.luau             → Gère le cycle des rounds
WorldManager.luau             → Coordonne le monde de jeu
```

### ⚙️ Configuration
```
Config/ServerConfig.luau      → Toutes les constantes du jeu
```

### 🔧 Services (Infrastructure)
```
Services/RemoteService.luau   → Communication client/serveur
Services/GridService.luau     → Grille 12x12 + positions
Services/PlayerManager.luau   → Joueurs + leaderboard
Services/LightingService.luau → Éclairage + effets visuels
```

### 🏭 Modules (Logique métier)
```
Modules/EntityFactory.luau    → Création d'entités
Modules/RoomFactory.luau      → Création de salles
Modules/PathfindingService.luau → Génération de chemins
Modules/WorldManager.luau     → Orchestration du monde
```

### 👑 Systèmes additionnels
```
AdminCommands.luau            → Commandes admin
```

---

## 📊 Statistiques

### Lignes de code (estimées)

| Fichier                          | Lignes | Rôle                    |
|----------------------------------|--------|-------------------------|
| **init.server.luau**             | 149    | Orchestrateur           |
| **Config/ServerConfig.luau**     | 70     | Configuration           |
| **Services/RemoteService.luau**  | 72     | RemoteEvents            |
| **Services/GridService.luau**    | 152    | Grille + positions      |
| **Services/PlayerManager.luau**  | 133    | Joueurs + leaderboard   |
| **Services/LightingService.luau**| 50     | Éclairage               |
| **Modules/EntityFactory.luau**   | 220    | Création d'entités      |
| **Modules/RoomFactory.luau**     | 270    | Création de salles      |
| **Modules/PathfindingService.luau** | 80  | Génération chemins      |
| **Modules/WorldManager.luau**    | 170    | Orchestration monde     |
| **RoundManager.luau**            | 109    | Gestion rounds          |
| **AdminCommands.luau**           | 300    | Commandes admin         |

**Total: ~1,775 lignes** réparties sur **12 modules** au lieu d'un seul fichier !

---

## 🔄 Flux d'exécution

### Démarrage serveur
```
1. init.server.luau démarre
   ↓
2. Initialise Config
   ↓
3. Initialise Services (Remote, Grid, Player, Lighting)
   ↓
4. Initialise Modules (Entity, Room, Pathfinding, World)
   ↓
5. Initialise RoundManager
   ↓
6. Démarre le premier round
```

### Cycle d'un round
```
1. RoundManager:StartNewRound()
   ↓
2. WorldManager:ResetWorld()
   ├─ GridService:ClearAllRooms()
   ├─ GridService:GenerateNewEndPosition()
   └─ PlayerManager:ResetAllPlayers()
   ↓
3. WorldManager:CreateMainRooms()
   ├─ RoomFactory:CreateRoom(O)
   └─ RoomFactory:CreateRoom(Z)
   ↓
4. WorldManager:TeleportAllPlayersToStart()
   ↓
5. Joueurs jouent...
   ↓
6. Un joueur atteint Z
   ↓
7. WorldManager:EndGame(winner)
   ↓
8. RoundManager:EndRound(winner)
   ↓
9. Attente 15s
   ↓
10. Retour à l'étape 1
```

---

## 🎨 Conventions de nommage

### Fichiers
- **PascalCase** pour les modules : `EntityFactory.luau`
- **camelCase** pour les instances : `entityFactory`

### Fonctions
- **PascalCase** pour les méthodes publiques : `:Init()`, `:CreateRoom()`
- **camelCase** pour les fonctions privées locales

### Variables
- **camelCase** pour les variables : `remoteService`
- **UPPER_CASE** pour les constantes : `GRID_SIZE`

---

## 📚 Documentation

### Fichiers de documentation
- 📄 **README.md** - Guide utilisateur et gameplay
- 📄 **ARCHITECTURE.md** - Documentation technique détaillée
- 📄 **REFACTORING_SUMMARY.md** - Résumé de la refactorisation
- 📄 **PROJECT_STRUCTURE.md** - Structure du projet (ce fichier)

### Documentation dans le code
Tous les modules contiennent :
- En-tête avec description du rôle
- Commentaires pour les sections importantes
- Documentation des APIs publiques

---

## 🧹 Nettoyage suggéré

### Fichiers à potentiellement supprimer
Si non utilisés par le client :
```
src/shared/Config.luau
src/shared/RemoteEvents.luau
src/server/Services/CoinService.luau
src/server/Services/PlayerService.luau
src/server/Services/WorldService.luau
```

### Backups à conserver (pour rollback si besoin)
```
src/server/init.server.OLD.luau
src/client/init.client.OLD_BACKUP.luau
```

---

## 🚀 Pour aller plus loin

### Prochaines améliorations
1. **Tests unitaires** - Créer `tests/` avec des tests pour chaque module
2. **Types Luau** - Ajouter des types pour meilleure vérification
3. **Documentation API** - Générer une doc automatique
4. **CI/CD** - Pipeline de tests automatiques
5. **Profiling** - Optimiser les performances

### Nouvelles fonctionnalités
1. **Système de crafting** - Ajouter un nouveau module
2. **Ennemis IA** - EntityFactory + AIController
3. **Boss fights** - RoomFactory pour salles spéciales
4. **Power-ups** - Nouveau type d'entité

---

## 🎓 Ce que cette architecture permet

### ✅ Développement parallèle
Plusieurs développeurs peuvent travailler sur différents modules sans conflit.

### ✅ Tests isolés
Chaque module peut être testé indépendamment.

### ✅ Réutilisation
Les services génériques peuvent être réutilisés dans d'autres projets.

### ✅ Maintenance facile
Bug dans les portes ? → Regarder EntityFactory.
Bug dans la grille ? → Regarder GridService.

### ✅ Extensibilité
Nouvelle fonctionnalité ? → Créer un nouveau module.

---

**Architecture conçue avec ❤️ pour être professionnelle, maintenable et scalable.**

*Dernière mise à jour: 2025 - Architecture Modulaire v2.0*
