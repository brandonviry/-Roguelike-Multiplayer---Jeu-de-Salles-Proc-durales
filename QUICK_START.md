# 🚀 Quick Start - Guide Rapide du Développeur

## 🎯 Vous êtes un nouveau développeur sur ce projet ?

Bienvenue ! Ce guide vous permettra de comprendre rapidement l'architecture et de commencer à développer.

---

## 📚 Documentations disponibles

| Fichier | Description | Quand le lire ? |
|---------|-------------|----------------|
| **README.md** | Guide utilisateur et gameplay | Pour comprendre le jeu |
| **ARCHITECTURE.md** | Documentation technique complète | Pour comprendre l'architecture |
| **REFACTORING_SUMMARY.md** | Résumé de la refactorisation | Pour comprendre les changements |
| **PROJECT_STRUCTURE.md** | Structure des fichiers | Pour naviguer dans le projet |
| **QUICK_START.md** | Ce guide | Pour démarrer rapidement |

---

## ⚡ Démarrage rapide (5 minutes)

### 1. Comprendre l'architecture (30 secondes)

```
Architecture en couches:

init.server.luau (Point d'entrée)
     ↓
Config (Configuration centralisée)
     ↓
Services (Infrastructure: Remote, Grid, Player, Lighting)
     ↓
Modules (Logique métier: Entity, Room, Pathfinding, World)
     ↓
RoundManager (Cycle de jeu)
```

### 2. Les 3 fichiers les plus importants (1 minute)

1. **[init.server.luau](src/server/init.server.luau)** - Point d'entrée, orchestration
2. **[Config/ServerConfig.luau](src/server/Config/ServerConfig.luau)** - Toute la configuration
3. **[Modules/WorldManager.luau](src/server/Modules/WorldManager.luau)** - Logique principale

### 3. Lancer le jeu (1 minute)

```bash
# Terminal
cd testRob
rojo serve

# Roblox Studio
# Plugin Rojo → Connect (port 34872)
# Play (F5)
```

### 4. Modifier une valeur (30 secondes)

```lua
-- Config/ServerConfig.luau
ServerConfig.Gameplay.COIN_VALUE = 20  -- Modifier ici
```

Sauvegardez → Rojo sync → Testez !

### 5. Comprendre un module (2 minutes)

Tous les modules suivent cette structure :

```lua
local MonModule = {}

-- Initialiser avec dépendances
function MonModule:Init(dependencies)
    self.dep1 = dependencies.dep1
    print("✅ MonModule initialisé")
    return self
end

-- Méthodes publiques
function MonModule:MaMethode(param)
    -- Logique ici
end

return MonModule
```

---

## 🗺️ Navigation rapide

### Je veux modifier...

| Quoi ? | Fichier |
|--------|---------|
| Les valeurs de configuration | [Config/ServerConfig.luau](src/server/Config/ServerConfig.luau) |
| La création de pièces | [Modules/EntityFactory.luau](src/server/Modules/EntityFactory.luau) |
| La création de salles | [Modules/RoomFactory.luau](src/server/Modules/RoomFactory.luau) |
| La génération de portes | [Modules/PathfindingService.luau](src/server/Modules/PathfindingService.luau) |
| La téléportation | [Modules/WorldManager.luau](src/server/Modules/WorldManager.luau) |
| Les rounds | [RoundManager.luau](src/server/RoundManager.luau) |
| Les commandes admin | [AdminCommands.luau](src/server/AdminCommands.luau) |
| Les RemoteEvents | [Services/RemoteService.luau](src/server/Services/RemoteService.luau) |
| La grille | [Services/GridService.luau](src/server/Services/GridService.luau) |
| Les joueurs | [Services/PlayerManager.luau](src/server/Services/PlayerManager.luau) |
| L'éclairage | [Services/LightingService.luau](src/server/Services/LightingService.luau) |

---

## 💡 Cas d'usage courants

### Cas 1: Changer le nombre de pièces par salle

```lua
-- Config/ServerConfig.luau
ServerConfig.Gameplay = {
    MIN_COINS_PER_ROOM = 5,  -- Avant: 3
    MAX_COINS_PER_ROOM = 15, -- Avant: 8
}
```

### Cas 2: Ajouter un nouveau type d'obstacle

```lua
-- 1. Modules/EntityFactory.luau
function EntityFactory:CreateSpikeObstacle(position, parentRoom)
    local spike = Instance.new("Part")
    spike.Name = "Spike"
    spike.Size = Vector3.new(2, 8, 2)
    spike.Position = position
    spike.Color = Color3.fromRGB(255, 0, 0)
    spike.Anchored = true
    spike.Parent = parentRoom

    -- Dégâts au toucher
    spike.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.Health - 10
        end
    end)

    return spike
end

-- 2. Modules/RoomFactory.luau
function RoomFactory:PopulateRoom(roomFolder, roomWorldPos)
    -- ... code existant pour pièces et obstacles ...

    -- Ajouter des spikes (20% de chance)
    if math.random() < 0.2 then
        local pos = roomWorldPos + Vector3.new(
            math.random(-20, 20),
            4,
            math.random(-20, 20)
        )
        self.entityFactory:CreateSpikeObstacle(pos, roomFolder)
    end
end
```

### Cas 3: Ajouter une nouvelle commande admin

```lua
-- AdminCommands.luau
AdminCommands.commands.speed = {
    description = "Changer ta vitesse de déplacement",
    usage = "/speed [vitesse]",
    adminOnly = true,
    execute = function(player, args, gameState)
        local speed = tonumber(args[1])

        if not speed then
            return false, "Usage: /speed [vitesse]"
        end

        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speed
                return true, "Vitesse définie à " .. speed
            end
        end

        return false, "Personnage introuvable"
    end
}
```

### Cas 4: Ajouter un nouveau RemoteEvent

```lua
-- 1. Services/RemoteService.luau
function RemoteService:Init()
    -- ...
    local remoteNames = {
        "CoinCollected",
        "GameEnded",
        "CompassToggle",
        "RoundStateChanged",
        "DoorTeleport",
        "PlayerDamaged",  -- ← Nouveau
    }
    -- ...
end

-- 2. L'utiliser dans un module
function EntityFactory:CreateSpikeObstacle(position, parentRoom)
    -- ...
    spike.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            -- Envoyer au client
            self.remoteService:FireClient("PlayerDamaged", player, 10)
        end
    end)
end
```

---

## 🏗️ Architecture en détail (10 minutes de lecture)

### Flux d'initialisation

```
init.server.luau démarre
  │
  ├─ 1. Importe tous les modules
  │    • Config/ServerConfig
  │    • Services/*
  │    • Modules/*
  │    • RoundManager
  │    • AdminCommands
  │
  ├─ 2. Initialise les services de base
  │    • RemoteService:Init()
  │    • GridService:Init()
  │    • PlayerManager:Init()
  │    • LightingService:Init()
  │
  ├─ 3. Initialise les modules métier
  │    • EntityFactory:Init(remote, player)
  │    • RoomFactory:Init(grid, entity)
  │    • PathfindingService:Init(grid)
  │
  ├─ 4. Initialise WorldManager
  │    • WorldManager:Init({
  │        gridService,
  │        remoteService,
  │        playerManager,
  │        roomFactory,
  │        pathfindingService
  │      })
  │
  ├─ 5. Initialise RoundManager
  │    • RoundManager:Init(worldManager, remoteService)
  │
  ├─ 6. Connecte les événements joueurs
  │    • PlayerAdded
  │    • PlayerRemoving
  │    • CharacterAdded
  │
  └─ 7. Démarre le jeu
       • RoundManager:Start()
```

### Dépendances entre modules

```
GridService ──┐
              ├─→ WorldManager ──→ RoundManager
RemoteService ┤                         ↓
PlayerManager ┘                    init.server.luau
                                         ↓
EntityFactory ┐                    Players events
              ├─→ RoomFactory
GridService ──┘
      ↓
PathfindingService
```

---

## 🎓 Principes à respecter

### ✅ DO (À faire)

1. **Modifier la config dans ServerConfig.luau**
   ```lua
   ServerConfig.Gameplay.COIN_VALUE = 20
   ```

2. **Injecter les dépendances**
   ```lua
   function MyModule:Init(dependencies)
       self.service = dependencies.service
   end
   ```

3. **Utiliser les services existants**
   ```lua
   self.remoteService:FireAllClients("MyEvent", data)
   ```

4. **Créer des fonctions courtes et focalisées**
   ```lua
   function MyModule:DoOneThing()
       -- Une seule responsabilité
   end
   ```

5. **Documenter votre code**
   ```lua
   --[[
       MyFunction
       Description de ce que fait la fonction
   ]]
   function MyModule:MyFunction()
   ```

### ❌ DON'T (À éviter)

1. **Hardcoder des valeurs**
   ```lua
   ❌ local coinValue = 10
   ✅ local coinValue = ServerConfig.Gameplay.COIN_VALUE
   ```

2. **Créer des RemoteEvents manuellement**
   ```lua
   ❌ local remote = Instance.new("RemoteEvent")
   ✅ local remote = remoteService:Get("MyRemote")
   ```

3. **Accéder directement à la grille**
   ```lua
   ❌ local room = worldGrid[x][y]
   ✅ local room = gridService:GetRoom(x, y)
   ```

4. **Mettre de la logique dans init.server.luau**
   ```lua
   ❌ init.server.luau avec 500 lignes de logique
   ✅ init.server.luau orchestre, la logique est dans les modules
   ```

5. **Coupler fortement les modules**
   ```lua
   ❌ require(script.Parent.Parent.OtherModule)
   ✅ Injection de dépendances via :Init()
   ```

---

## 🐛 Debugging

### Console Output

Lors du démarrage, vous devriez voir :

```
🚀 === DÉMARRAGE DU SERVEUR - ARCHITECTURE MODULAIRE ===
🔧 Initialisation des services...
🔌 Initialisation RemoteService...
  ✅ RemoteEvent créé: CoinCollected
  ✅ RemoteEvent créé: GameEnded
  ...
✅ RemoteService initialisé - 5 remotes créés
🗺️ Initialisation GridService...
✅ GridService initialisé - Grille 12x12
👥 Initialisation PlayerManager...
✅ PlayerManager initialisé
💡 Initialisation LightingService...
✅ LightingService initialisé
🏭 EntityFactory initialisé
🏗️ RoomFactory initialisé
🧭 PathfindingService initialisé
🌍 Initialisation WorldManager...
✅ WorldManager initialisé
🎮 RoundManager initialisé
✅ Tous les services initialisés
✅ === SERVEUR PRÊT ===
🎮 Système de rounds actif!
🗺️ Monde partagé persistant - Grille 12x12
👑 Admins configurés: 1
🎮 Démarrage du système de rounds...
⏳ Démarrage dans 5 secondes...
```

### Problèmes courants

| Erreur | Cause probable | Solution |
|--------|----------------|----------|
| "Module not found" | Mauvais chemin de require | Vérifier les chemins dans init.server.luau |
| "attempt to index nil" | Service non initialisé | Vérifier l'ordre d'initialisation |
| "RemoteEvent not found" | Nom incorrect | Vérifier remoteNames dans RemoteService |
| Salles ne se créent pas | Erreur dans RoomFactory | Ajouter des prints dans CreateRoom() |
| Joueurs pas téléportés | Erreur dans WorldManager | Vérifier TeleportPlayerToRoom() |

### Ajouter des logs de debug

```lua
-- Dans n'importe quel module
function MyModule:MyFunction()
    print("🔍 DEBUG: MyFunction appelée avec", param)

    -- Votre code

    print("✅ DEBUG: MyFunction terminée")
end
```

---

## 📖 Ressources d'apprentissage

### Documentation
- **ARCHITECTURE.md** - Détails techniques complets
- **REFACTORING_SUMMARY.md** - Avant/Après de la refactorisation

### Concepts importants
- **Dependency Injection** - Comment les modules reçoivent leurs dépendances
- **Factory Pattern** - EntityFactory et RoomFactory
- **Service Locator** - RemoteService
- **Separation of Concerns** - Chaque module = une responsabilité

---

## 🎯 Checklist du développeur

Avant de committer votre code :

- [ ] J'ai utilisé ServerConfig au lieu de hardcoder
- [ ] J'ai documenté mes fonctions
- [ ] J'ai testé en jeu
- [ ] J'ai vérifié la console Output (pas d'erreurs)
- [ ] Mon code suit les conventions de nommage
- [ ] J'ai injecté les dépendances au lieu de require direct
- [ ] J'ai mis à jour la documentation si nécessaire

---

## 🚀 Prêt à développer ?

1. **Lisez [ARCHITECTURE.md](ARCHITECTURE.md)** pour comprendre en détail
2. **Explorez le code** en commençant par init.server.luau
3. **Testez** en modifiant une valeur dans ServerConfig
4. **Créez** votre première fonctionnalité !

---

**Bon développement ! 🎮**

*Si vous avez des questions, consultez ARCHITECTURE.md ou PROJECT_STRUCTURE.md*
