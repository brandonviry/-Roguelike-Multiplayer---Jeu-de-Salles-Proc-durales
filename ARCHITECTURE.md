# 🏗️ Architecture du Projet - Documentation Technique

## 📋 Vue d'ensemble

Ce projet a été refactorisé selon une **architecture modulaire professionnelle** suivant les principes **SOLID** et les meilleures pratiques de développement logiciel.

## 🎯 Principes appliqués

### 1. **Separation of Concerns (SoC)**
Chaque module a une responsabilité unique et bien définie.

### 2. **Dependency Injection**
Les dépendances sont injectées lors de l'initialisation, facilitant les tests et la maintenance.

### 3. **Single Responsibility Principle (SRP)**
Chaque classe/module ne fait qu'une seule chose.

### 4. **Don't Repeat Yourself (DRY)**
La configuration est centralisée, évitant la duplication.

---

## 📁 Structure du projet

```
src/server/
├── init.server.luau                # 🎮 Orchestrateur principal
├── AdminCommands.luau              # 👑 Système de commandes admin
├── RoundManager.luau               # 🎯 Gestion des rounds
│
├── Config/
│   └── ServerConfig.luau           # ⚙️ Configuration centralisée
│
├── Services/
│   ├── RemoteService.luau          # 🔌 Gestion des RemoteEvents
│   ├── GridService.luau            # 🗺️ Gestion de la grille 12x12
│   ├── PlayerManager.luau          # 👥 Gestion des joueurs
│   └── LightingService.luau        # 💡 Configuration de l'éclairage
│
└── Modules/
    ├── EntityFactory.luau          # 🏭 Fabrique d'entités (coins, portes, obstacles)
    ├── RoomFactory.luau            # 🏗️ Fabrique de salles complètes
    ├── PathfindingService.luau     # 🧭 Génération des chemins
    └── WorldManager.luau           # 🌍 Orchestrateur du monde
```

---

## 📦 Description des modules

### 🎮 **init.server.luau**
**Rôle:** Point d'entrée du serveur, orchestre l'initialisation de tous les modules.

**Responsabilités:**
- Importer tous les modules
- Initialiser les services dans le bon ordre
- Gérer les événements joueurs (PlayerAdded, PlayerRemoving)
- Démarrer le système de rounds

**Ordre d'initialisation:**
1. Services de base (Remote, Grid, Player, Lighting)
2. Modules de fabrication (Entity, Room, Pathfinding)
3. WorldManager (orchestrateur)
4. RoundManager (système de rounds)

---

### ⚙️ **Config/ServerConfig.luau**
**Rôle:** Configuration centralisée de tout le jeu.

**Contient:**
- `Grid` - Configuration de la grille (taille, espacement, etc.)
- `Gameplay` - Paramètres de gameplay (coins, obstacles, portes)
- `Colors` - Toutes les couleurs du jeu
- `CoinColors` - Palette de couleurs des pièces
- `Walls` - Configuration des murs et séparations
- `Rounds` - Durées et délais des rounds

**Avantages:**
- Modification facile des valeurs
- Pas de "magic numbers" dans le code
- Configuration unique partagée par tous les modules

---

### 🔌 **Services/RemoteService.luau**
**Rôle:** Gestion centralisée de tous les RemoteEvents.

**API:**
```lua
RemoteService:Init()                              -- Créer tous les remotes
RemoteService:Get(remoteName)                     -- Récupérer un remote
RemoteService:FireAllClients(remoteName, ...)     -- Envoyer à tous
RemoteService:FireClient(remoteName, player, ...) -- Envoyer à un joueur
```

**Remotes créés:**
- `CoinCollected` - Collection de pièce
- `GameEnded` - Fin de partie
- `CompassToggle` - Toggle de la boussole
- `RoundStateChanged` - Changement d'état du round
- `DoorTeleport` - Téléportation via porte

---

### 🗺️ **Services/GridService.luau**
**Rôle:** Gestion de la grille 12x12 et des positions.

**API:**
```lua
GridService:Init()                                -- Initialiser la grille
GridService:GridToWorld(x, y)                     -- Convertir grille → monde
GridService:RoomExists(x, y)                      -- Vérifier existence
GridService:GetRoom(x, y)                         -- Récupérer une salle
GridService:SetRoom(x, y, roomData)               -- Enregistrer une salle
GridService:ClearAllRooms()                       -- Nettoyer la grille
GridService:GenerateNewEndPosition()              -- Générer position Z
GridService:UpdatePlayerPosition(userId, x, y)    -- MAJ position joueur
GridService:IsValidPosition(x, y)                 -- Vérifier validité
GridService:IsStartRoom(x, y)                     -- Est-ce la salle O ?
GridService:IsEndRoom(x, y)                       -- Est-ce la salle Z ?
```

**Données stockées:**
- `worldGrid[x][y]` - Matrice 12x12 des salles
- `playerPositions` - Table des positions joueurs
- `startPos` - Position de départ (O)
- `endPos` - Position d'arrivée (Z)

---

### 👥 **Services/PlayerManager.luau**
**Rôle:** Gestion des joueurs, leaderboard et statistiques.

**API:**
```lua
PlayerManager:Init()                              -- Connecter événements
PlayerManager:CreateLeaderboard(player)           -- Créer leaderboard
PlayerManager:AddCoins(player, amount)            -- Ajouter des coins
PlayerManager:IncrementRoomsVisited(player)       -- +1 salle visitée
PlayerManager:ResetPlayerStats(player)            -- Reset un joueur
PlayerManager:ResetAllPlayers()                   -- Reset tous les joueurs
PlayerManager:CreateLeaderboard(winner)           -- Créer classement final
PlayerManager:GetPlayerStats(player)              -- Obtenir stats
```

**Stats trackées:**
- `Coins` - Score de pièces collectées
- `Salles` - Nombre de salles visitées

---

### 💡 **Services/LightingService.luau**
**Rôle:** Configuration de l'éclairage et des effets visuels.

**Configure:**
- Éclairage de base (brightness, ambient, shadows)
- Bloom effect
- Color correction

---

### 🏭 **Modules/EntityFactory.luau**
**Rôle:** Fabrique pour créer toutes les entités du jeu.

**API:**
```lua
EntityFactory:Init(remoteService, playerManager)
EntityFactory:CreateCoin(position, parentRoom)
EntityFactory:CreateObstacle(position, parentRoom)
EntityFactory:CreateDoor(roomWorldPos, direction, isActive, targetX, targetY, roomFolder, teleportCallback)
```

**Entités créées:**
- **Coins (étoiles 3D)** - Avec animation, highlight, ClickDetector
- **Obstacles** - Blocs aléatoires
- **Portes** - Actives (avec trigger) ou inactives

---

### 🏗️ **Modules/RoomFactory.luau**
**Rôle:** Fabrique pour créer des salles complètes.

**API:**
```lua
RoomFactory:Init(gridService, entityFactory)
RoomFactory:CreateRoom(x, y, doorConfig, teleportCallback)
```

**Composants d'une salle:**
- Sol (coloré selon type : O, Z, normale)
- Murs décoratifs (petits murs 3 studs)
- Murs de séparation (épais, 40 studs de haut)
- Piliers aux coins (avec sommets)
- Barrières invisibles (anti-saut)
- Pièces et obstacles (sauf salles spéciales)
- Portes (selon configuration)
- Zone de fin (salle Z uniquement)

---

### 🧭 **Modules/PathfindingService.luau**
**Rôle:** Génération intelligente des configurations de portes.

**API:**
```lua
PathfindingService:Init(gridService)
PathfindingService:GenerateDoorConfig(x, y)
PathfindingService:IsValidTarget(x, y)
PathfindingService:ManhattanDistance(x1, y1, x2, y2)
PathfindingService:GetDirectionTo(fromX, fromY, toX, toY)
```

**Algorithme:**
1. Garantir au moins une porte vers Z (chemin principal)
2. Ajouter 1-2 portes aléatoires (exploration)
3. Vérifier que toutes les cibles sont dans la grille

---

### 🌍 **Modules/WorldManager.luau**
**Rôle:** Orchestrateur principal du monde de jeu.

**API:**
```lua
WorldManager:Init(dependencies)
WorldManager:TeleportPlayerToRoom(player, x, y)
WorldManager:EndGame(winner)
WorldManager:ResetWorld()
WorldManager:CreateMainRooms()
WorldManager:TeleportAllPlayersToStart()
WorldManager:GetGameState()  -- Pour AdminCommands
```

**Responsabilités:**
- Coordonner tous les modules
- Gérer la téléportation des joueurs
- Créer les salles à la demande
- Gérer la fin de partie
- Reset le monde entre rounds

---

### 🎯 **RoundManager.luau**
**Rôle:** Gestion du cycle de vie des rounds.

**API:**
```lua
RoundManager:Init(worldManager, remoteService)
RoundManager:StartNewRound()
RoundManager:EndRound(winner)
RoundManager:Start()  -- Démarrer le système
```

**Cycle:**
```
WAITING (15s) → PLAYING → ENDED (15s) → WAITING → ...
```

**États:**
- `WAITING` - Attente entre rounds
- `PLAYING` - Round en cours
- `ENDED` - Résultats affichés

---

### 👑 **AdminCommands.luau**
**Rôle:** Système de commandes pour les administrateurs.

**Commandes disponibles:**
- `/tp [x] [y]` - Téléporter à une salle
- `/pos` - Afficher position actuelle
- `/players` - Lister tous les joueurs
- `/givecoins [nom] [montant]` - Donner des coins
- `/setcoins [montant]` - Modifier son score
- `/compass` - Toggle boussole vers Z
- `/showgrid` - Afficher la grille
- `/endgame` - Terminer la partie
- `/help` - Liste des commandes

---

## 🔄 Flux de données

### Démarrage du serveur
```
init.server.luau
  ↓
1. RemoteService:Init()
2. GridService:Init()
3. PlayerManager:Init()
4. LightingService:Init()
  ↓
5. EntityFactory:Init(remote, player)
6. RoomFactory:Init(grid, entity)
7. PathfindingService:Init(grid)
  ↓
8. WorldManager:Init({dependencies})
  ↓
9. RoundManager:Init(world, remote)
  ↓
10. RoundManager:Start()
```

### Démarrage d'un round
```
RoundManager:StartNewRound()
  ↓
WorldManager:ResetWorld()
  ↓ GridService:ClearAllRooms()
  ↓ GridService:GenerateNewEndPosition()
  ↓ PlayerManager:ResetAllPlayers()
  ↓
WorldManager:CreateMainRooms()
  ↓ PathfindingService:GenerateDoorConfig(O)
  ↓ RoomFactory:CreateRoom(O)
  ↓ RoomFactory:CreateRoom(Z)
  ↓
WorldManager:TeleportAllPlayersToStart()
```

### Joueur passe une porte
```
Porte touchée
  ↓
EntityFactory trigger
  ↓
WorldManager:TeleportPlayerToRoom(player, x, y)
  ↓
GridService:RoomExists(x, y) ?
  NON → PathfindingService:GenerateDoorConfig(x, y)
      → RoomFactory:CreateRoom(x, y)
  ↓
Téléportation
  ↓
GridService:UpdatePlayerPosition(userId, x, y)
  ↓
PlayerManager:IncrementRoomsVisited(player)
```

### Fin de partie
```
Joueur touche zone Z
  ↓
WorldManager:EndGame(winner)
  ↓
RoundManager:EndRound(winner)
  ↓
PlayerManager:CreateLeaderboard(winner)
  ↓
RemoteService:FireAllClients("GameEnded", ...)
  ↓
Attente 15s
  ↓
RoundManager:StartNewRound()
```

---

## 🎨 Avantages de cette architecture

### ✅ **Maintenabilité**
- Code organisé et facile à comprendre
- Chaque module a une responsabilité claire
- Modifications localisées (pas d'effet domino)

### ✅ **Testabilité**
- Modules indépendants
- Dépendances injectées
- Facile de mocker pour les tests

### ✅ **Scalabilité**
- Facile d'ajouter de nouvelles fonctionnalités
- Pas de couplage fort entre modules
- Architecture extensible

### ✅ **Réutilisabilité**
- Modules peuvent être réutilisés dans d'autres projets
- Interfaces claires et documentées

### ✅ **Lisibilité**
- Code auto-documenté
- Nomenclature cohérente
- Structure logique

---

## 🔧 Comment ajouter une nouvelle fonctionnalité

### Exemple : Ajouter un nouveau type d'obstacle

1. **Modifier la configuration**
```lua
-- Config/ServerConfig.luau
ServerConfig.Gameplay.NEW_OBSTACLE_CHANCE = 0.3
```

2. **Ajouter la logique dans EntityFactory**
```lua
-- Modules/EntityFactory.luau
function EntityFactory:CreateSpecialObstacle(position, parentRoom)
    -- Logique de création
end
```

3. **Utiliser dans RoomFactory**
```lua
-- Modules/RoomFactory.luau
function RoomFactory:PopulateRoom(roomFolder, roomWorldPos)
    -- Ajouter un appel à CreateSpecialObstacle
    if math.random() < ServerConfig.Gameplay.NEW_OBSTACLE_CHANCE then
        self.entityFactory:CreateSpecialObstacle(pos, roomFolder)
    end
end
```

Pas besoin de toucher aux autres modules ! 🎉

---

## 📊 Métriques du code

### Avant refactorisation
- **1 fichier monolithique** : `init.server.luau` (795 lignes)
- Tout mélangé : configuration, logique, création, gestion
- Difficile à maintenir et tester

### Après refactorisation
- **15 modules** bien organisés
- **~150 lignes** par module en moyenne
- Responsabilités claires et séparées
- Architecture professionnelle

---

## 🚀 Prochaines améliorations possibles

1. **Tests unitaires** - Ajouter des tests pour chaque module
2. **Logging système** - Service de logs centralisé
3. **Métriques de performance** - Profiler les opérations coûteuses
4. **Save/Load système** - Persistance des données
5. **Event Bus** - Communication découplée entre modules
6. **Object Pooling** - Réutilisation des entités pour performances

---

## 📚 Ressources

- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection)
- [Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)

---

**Auteur:** Refactorisation professionnelle par Claude
**Date:** 2025
**Version:** 2.0 - Architecture Modulaire
