# 📋 DEV_CONTEXT.md - Contexte de Développement

> **Projet**: Roguelike Multijoueur Roblox
> **Dernière mise à jour**: 2025-01-13
> **Statut**: Phase 1 Terminée - Phase 2 En Planification

---

## 📊 Table des Matières

1. [Réalisations Actuelles](#-réalisations-actuelles-phase-1)
2. [Architecture du Projet](#-architecture-du-projet)
3. [Nouvelles Fonctionnalités à Implémenter](#-nouvelles-fonctionnalités-phase-2)
4. [Guide de Réalisation](#-guide-de-réalisation)
5. [Conventions et Standards](#-conventions-et-standards)

---

## ✅ Réalisations Actuelles (Phase 1)

### 🏗️ Refactorisation Majeure

#### Serveur - Architecture Modulaire
Le fichier monolithique `init.server.luau` (795 lignes) a été refactorisé en une architecture propre et maintenable:

**Configuration Centralisée**
- `src/server/Config/ServerConfig.luau` - Toutes les constantes du jeu

**Services** (`src/server/Services/`)
- `RemoteService.luau` - Gestion automatique des RemoteEvents
- `GridService.luau` - Grille 12x12, positions des joueurs
- `PlayerManager.luau` - Leaderboard, statistiques, scores
- `LightingService.luau` - Configuration de l'éclairage

**Modules** (`src/server/Modules/`)
- `EntityFactory.luau` - Création des pièces, obstacles, portes
- `RoomFactory.luau` - Création complète des salles
- `PathfindingService.luau` - Génération intelligente des portes
- `WorldManager.luau` - Orchestrateur principal du monde

**Système de Gestion**
- `RoundManager.luau` - Gestion du cycle des rounds
- `init.server.luau` - Orchestrateur principal (149 lignes, -81%)

#### Système de Commandes Modulaire

Chaque commande = 1 fichier dans `src/server/commands/`:

**Commandes Existantes**:
- `/tp [x] [y]` - Téléportation
- `/pos` - Position actuelle
- `/players` - Liste des joueurs
- `/givecoins [nom] [montant]` - Donner des coins
- `/setcoins [montant]` - Définir ses coins
- `/compass` - Toggle boussole
- `/showgrid` - Afficher la grille
- `/endgame` - Terminer la partie
- `/restartforall` - Redémarrer le jeu
- `/help` - Aide

**Système de Chargement**:
- `CommandRegistry.luau` - Chargement automatique
- Support des aliases
- Permissions admin
- Template pour nouvelles commandes

#### Client - Architecture MVC

Déjà refactorisé proprement:

**Contrôleurs** (`src/client/Controllers/`)
- CoinController, RoundController, DoorController, CompassController, etc.

**Interface Utilisateur** (`src/client/ui/`)
- ScoreUI, RoundUI, EndScreenUI, TimerUI, CompassUI, AdminUI

**Effets** (`src/client/effects/`)
- CollectEffects, CameraEffects

### 🎮 Fonctionnalités Actuelles

#### Système de Monde Procédural
- Grille 12x12 de salles
- Salle de départ (S) aléatoire
- Salle d'arrivée (Z) aléatoire avec distance minimum
- Génération procédurale des portes intelligentes
- Au moins une porte pointe toujours vers Z

#### Système de Jeu
- **Rounds automatiques**: Cycle Attente → Jeu → Résultats
- **Collecte de pièces**: Collecte automatique en passant dessus (système `.Touched`)
- **Leaderboard en temps réel**: Coins et salles visitées
- **Système de portes**: Téléportation entre salles avec effets
- **Détection de fin**: Toucher la zone Z termine le round
- **Barrières invisibles**: Empêchent de tomber dans le vide (500 studs de haut)

#### Système de Pièces (Coins)
- Étoiles 3D rotatives avec animation de flottement
- 8 couleurs différentes aléatoires
- 3-8 pièces par salle (configurable)
- Valeur: 10 coins par pièce
- Collecte automatique par contact

---

## 🏛️ Architecture du Projet

### Structure des Fichiers

```
testRob/
├── src/
│   ├── server/
│   │   ├── Config/
│   │   │   └── ServerConfig.luau        # Configuration centralisée
│   │   ├── Services/
│   │   │   ├── RemoteService.luau       # Gestion RemoteEvents
│   │   │   ├── GridService.luau         # Grille monde
│   │   │   ├── PlayerManager.luau       # Joueurs & scores
│   │   │   └── LightingService.luau     # Éclairage
│   │   ├── Modules/
│   │   │   ├── EntityFactory.luau       # Entités du jeu
│   │   │   ├── RoomFactory.luau         # Salles complètes
│   │   │   ├── PathfindingService.luau  # Génération portes
│   │   │   └── WorldManager.luau        # Orchestrateur monde
│   │   ├── commands/
│   │   │   ├── CommandRegistry.luau     # Chargement auto
│   │   │   ├── _CommandTemplate.luau    # Template
│   │   │   ├── TeleportCommand.luau
│   │   │   ├── RestartForAllCommand.luau
│   │   │   └── ... (9 commandes)
│   │   ├── RoundManager.luau            # Gestion rounds
│   │   ├── AdminCommands.luau           # Système commandes
│   │   └── init.server.luau             # Orchestrateur principal
│   └── client/
│       ├── Controllers/                  # Logique MVC
│       ├── ui/                          # Interfaces
│       ├── effects/                     # Effets visuels
│       └── init.client.luau             # Orchestrateur client
├── ARCHITECTURE.md                       # Doc architecture serveur
├── CLIENT_ARCHITECTURE.md                # Doc architecture client
├── COMMANDS_SYSTEM.md                    # Doc système commandes
├── README.md                             # Vue d'ensemble
└── DEV_CONTEXT.md                        # Ce fichier
```

### Principes de Design

**SOLID**:
- ✅ Single Responsibility - Chaque module a une responsabilité unique
- ✅ Open/Closed - Extensible sans modification
- ✅ Dependency Injection - Services injectés lors de l'initialisation
- ✅ Interface Segregation - APIs claires et minimales

**Patterns**:
- Factory Pattern (EntityFactory, RoomFactory)
- Service Locator (RemoteService)
- Command Pattern (CommandRegistry)
- MVC (Client)
- Facade (WorldManager)

---

## 🚀 Nouvelles Fonctionnalités (Phase 2)

### 1. ⚔️ Système de Combat

#### 1.1 Barre de Vie
**Style**: Inspirée de Wakfu
- Design élégant avec animations
- Affichage HP actuel/max
- Régénération progressive hors combat
- Effets visuels lors de dégâts/soins

**Spécifications techniques**:
```lua
PlayerStats = {
    maxHP = 100,
    currentHP = 100,
    regenRate = 2, -- HP/seconde hors combat
    regenDelay = 5, -- Secondes sans dégâts avant regen
}
```

#### 1.2 Barre de Sorts

**Sort 1: Coup d'Épée (Basique)**
- Coût: 0 coins
- Dégâts: 15 HP
- Cooldown: 1 seconde
- Portée: 5 studs (mêlée)
- Animation: Slash d'épée

**Sort 2: Tranchant (Épée Forte)**
- Coût: 10 coins
- Dégâts: 35 HP
- Cooldown: 3 secondes
- Portée: 5 studs (mêlée)
- Animation: Slash puissant avec trainée

**Sort 3: Tir à Distance (Glock)**
- Coût: 30 coins
- Dégâts: 25 HP
- Cooldown: 2 secondes
- Portée: 50 studs
- Monocible
- Projectile: Balle rapide avec trail

**Sort 4: Zone (Grenade)**
- Coût: 50 coins
- Dégâts: 40 HP (centre), 20 HP (bords)
- Cooldown: 8 secondes
- Portée lancer: 30 studs
- Rayon explosion: 15 studs
- Animation: Arc de lancer + explosion

**Sort 5: Bouclier**
- Coût: 20 coins
- Effet: Absorbe 50 HP de dégâts
- Durée: 5 secondes
- Cooldown: 10 secondes
- Visuel: Bulle brillante autour du joueur

**Système de Coins pour Sorts**:
- Les coins servent à la fois de score ET de monnaie pour les sorts
- Utiliser un sort déduit les coins du joueur
- Équilibrage: collecter des pièces = pouvoir utiliser des sorts puissants

### 2. 🪨 Obstacles Cassables

**Transformation des obstacles marron**:
- HP par obstacle: 30-60 HP (selon taille)
- Récompense destruction: 10 coins
- Animation de destruction progressive
- Particules de débris
- Peut bloquer le passage → stratégie de destruction

**Implémentation**:
```lua
Obstacle = {
    maxHP = 45,
    currentHP = 45,
    material = "Wood",
    drops = {coins = 10}
}
```

### 3. 🎯 Système de Pièges

#### Types de Pièges

**Piège de Dégâts (Rouge)**
- Visuel: Néon carré rouge
- Effet: 10 HP/seconde au contact
- Taille: 5x0.5x5 studs
- Génération: 0-2 par salle (20% des salles)

**Piège de Ralentissement (Cyan)**
- Visuel: Néon carré cyan
- Effet: Vitesse × 0.25 (très lent)
- Durée: Tant que sur le piège
- Taille: 5x0.5x5 studs
- Génération: 0-1 par salle (15% des salles)

**Boost de Vitesse (Jaune)**
- Visuel: Néon carré jaune brillant
- Effet: Vitesse × 1.25
- Durée: Tant que sur le piège
- Taille: 5x0.5x5 studs
- Génération: 0-1 par salle (15% des salles)

**Règles de Génération**:
- Maximum 2 pièges par salle
- Jamais dans la salle de départ (S)
- Jamais dans la salle d'arrivée (Z)
- Placement aléatoire mais pas devant les portes
- Distance minimum entre pièges: 10 studs

### 4. 👾 Système de Mobs

#### Caractéristiques des Mobs

**Types de Mobs**:

1. **Guerrier Mêlée**
   - HP: 60
   - Sorts: Coup d'Épée, Tranchant
   - Comportement: Agressif, charge le joueur

2. **Tireur à Distance**
   - HP: 40
   - Sorts: Tir à Distance
   - Comportement: Garde distance, kite

3. **Tank**
   - HP: 100
   - Sorts: Coup d'Épée, Bouclier
   - Comportement: Défensif, protège zone

4. **Grenadier**
   - HP: 50
   - Sorts: Zone (Grenade), Tir à Distance
   - Comportement: Reste à distance moyenne

**IA de Combat** (Simple mais Efficace):
```lua
AI_FSM = {
    IDLE = "Patrouille aléatoire dans la salle",
    DETECT = "Détecte joueur dans rayon 30 studs",
    CHASE = "Poursuit jusqu'à portée du sort",
    ATTACK = "Utilise sort disponible",
    RETREAT = "Recule si HP < 30%",
    DEAD = "Meurt et drop loot"
}
```

**Drops**:
- 20-50 coins (aléatoire)
- Particules brillantes
- Son de victoire

**Génération**:
- 0-3 mobs par salle normale
- Jamais dans S et Z
- Probabilité: 40% des salles
- Spawn aléatoire dans la salle

---

## 📖 Guide de Réalisation

### Phase 2.1 - Système de Combat (Priorité 1)

#### Étape 1: Créer le Système de Vie
**Fichiers à créer**:
- `src/server/Services/HealthService.luau`
- `src/client/ui/HealthBarUI.luau`

**Responsabilités**:
```lua
-- HealthService (Serveur)
- Gérer HP de tous les joueurs/mobs
- Appliquer dégâts avec validation
- Gérer régénération
- Notifier clients des changements HP

-- HealthBarUI (Client)
- Créer barre de vie style Wakfu
- Animer changements HP
- Afficher effets visuels dégâts/soins
```

**RemoteEvents nécessaires**:
- `HealthChanged` (Server → Client)
- `TakeDamage` (Server → Client pour effets)
- `PlayerDied` (Server → All Clients)

#### Étape 2: Créer le Système de Sorts
**Fichiers à créer**:
- `src/server/Services/SpellService.luau`
- `src/server/Modules/Spells/` (dossier)
  - `BasicSlash.luau`
  - `PowerSlash.luau`
  - `Gunshot.luau`
  - `Grenade.luau`
  - `Shield.luau`
- `src/client/Controllers/SpellController.luau`
- `src/client/ui/SpellBarUI.luau`

**Architecture des Sorts**:
```lua
-- Template de Sort
Spell = {
    metadata = {
        name = "BasicSlash",
        displayName = "Coup d'Épée",
        icon = "rbxassetid://...",
        cost = 0,
        cooldown = 1,
        range = 5,
        damageType = "melee",
    },

    canCast = function(caster)
        -- Vérifier coins, cooldown, conditions
    end,

    cast = function(caster, target)
        -- Logique du sort côté serveur
    end,

    animate = function(caster, target)
        -- Effets visuels côté client
    end
}
```

**Système de Cooldown**:
```lua
PlayerCooldowns = {
    [playerId] = {
        ["BasicSlash"] = tick() + 1,
        ["PowerSlash"] = tick() + 3,
        -- ...
    }
}
```

#### Étape 3: Interface de Sorts
**SpellBarUI**:
- 5 boutons en bas de l'écran
- Icônes + raccourcis clavier (1-5)
- Affichage coût en coins
- Animation de cooldown circulaire
- Feedback visuel: disponible/en cooldown/pas assez de coins

### Phase 2.2 - Obstacles Cassables (Priorité 2)

#### Étape 1: Modifier EntityFactory
**Fichier**: `src/server/Modules/EntityFactory.luau`

Ajouter dans `CreateObstacle()`:
```lua
function EntityFactory:CreateDestructibleObstacle(position, parentRoom)
    local obstacle = self:CreateObstacle(position, parentRoom) -- Existant

    -- Ajouter système HP
    local maxHP = math.random(30, 60)
    obstacle:SetAttribute("MaxHP", maxHP)
    obstacle:SetAttribute("CurrentHP", maxHP)
    obstacle:SetAttribute("IsDestructible", true)
    obstacle:SetAttribute("CoinReward", 10)

    -- Ajouter SelectionBox pour feedback visuel
    local selection = Instance.new("SelectionBox")
    selection.LineThickness = 0.05
    selection.Color3 = Color3.fromRGB(139, 69, 19) -- Marron
    selection.Adornee = obstacle
    selection.Parent = obstacle

    return obstacle
end
```

#### Étape 2: Gérer Dégâts aux Obstacles
**Ajouter dans SpellService**:
```lua
function SpellService:DamageObstacle(obstacle, damage)
    local currentHP = obstacle:GetAttribute("CurrentHP")
    local newHP = math.max(0, currentHP - damage)

    obstacle:SetAttribute("CurrentHP", newHP)

    if newHP <= 0 then
        self:DestroyObstacle(obstacle)
    else
        -- Effets visuels de dégâts
        self:PlayObstacleDamageEffect(obstacle)
    end
end

function SpellService:DestroyObstacle(obstacle)
    -- Particules de débris
    -- Son de destruction
    -- Drop coins
    local reward = obstacle:GetAttribute("CoinReward")
    -- Notifier joueurs proches
    obstacle:Destroy()
end
```

### Phase 2.3 - Système de Pièges (Priorité 3)

#### Étape 1: Créer TrapFactory
**Fichier**: `src/server/Modules/TrapFactory.luau`

```lua
local TrapFactory = {}

function TrapFactory:Init(healthService)
    self.healthService = healthService
    return self
end

function TrapFactory:CreateDamageTrap(position, parentRoom)
    local trap = Instance.new("Part")
    trap.Name = "DamageTrap"
    trap.Size = Vector3.new(5, 0.5, 5)
    trap.Position = position
    trap.Anchored = true
    trap.CanCollide = false
    trap.Material = Enum.Material.Neon
    trap.Color = Color3.fromRGB(255, 0, 0) -- Rouge
    trap.Transparency = 0.3
    trap.Parent = parentRoom

    -- Système de damage tick
    local playersInTrap = {}

    trap.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player and not playersInTrap[player.UserId] then
            playersInTrap[player.UserId] = true
            self:StartDamageTick(player, trap)
        end
    end)

    trap.TouchEnded:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            playersInTrap[player.UserId] = nil
        end
    end)

    return trap
end

function TrapFactory:StartDamageTick(player, trap)
    task.spawn(function()
        while trap.Parent and playersInTrap[player.UserId] do
            self.healthService:Damage(player, 10, "trap")
            task.wait(1) -- 10 HP/sec
        end
    end)
end

-- Méthodes similaires pour CreateSlowTrap et CreateSpeedTrap
```

#### Étape 2: Intégrer dans RoomFactory
**Modifier**: `src/server/Modules/RoomFactory.luau`

Ajouter méthode `PopulateTraps()`:
```lua
function RoomFactory:PopulateTraps(roomFolder, roomWorldPos, x, y)
    -- Ne pas générer dans S et Z
    if self.gridService:IsStartRoom(x, y) or self.gridService:IsEndRoom(x, y) then
        return
    end

    -- Probabilités
    local roll = math.random()
    local trapCount = 0

    if roll < 0.20 then -- 20% pour piège de dégâts
        local pos = self:GetRandomRoomPosition(roomWorldPos)
        self.trapFactory:CreateDamageTrap(pos, roomFolder)
        trapCount = trapCount + 1
    end

    if trapCount < 2 and math.random() < 0.15 then -- 15% pour slow
        local pos = self:GetRandomRoomPosition(roomWorldPos)
        self.trapFactory:CreateSlowTrap(pos, roomFolder)
        trapCount = trapCount + 1
    end

    if trapCount < 2 and math.random() < 0.15 then -- 15% pour speed
        local pos = self:GetRandomRoomPosition(roomWorldPos)
        self.trapFactory:CreateSpeedTrap(pos, roomFolder)
    end
end
```

### Phase 2.4 - Système de Mobs (Priorité 4)

#### Étape 1: Créer MobFactory
**Fichier**: `src/server/Modules/MobFactory.luau`

```lua
local MobFactory = {}

function MobFactory:CreateMob(mobType, position, parentRoom)
    local mobData = ServerConfig.Mobs[mobType]

    -- Créer le modèle du mob (simple pour commencer)
    local mobModel = Instance.new("Model")
    mobModel.Name = mobType

    local torso = Instance.new("Part")
    torso.Name = "HumanoidRootPart"
    torso.Size = Vector3.new(2, 3, 1)
    torso.Position = position
    torso.Anchored = false
    torso.Color = mobData.color
    torso.Parent = mobModel

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = mobData.maxHP
    humanoid.Health = mobData.maxHP
    humanoid.WalkSpeed = mobData.speed
    humanoid.Parent = mobModel

    -- Attributs personnalisés
    mobModel:SetAttribute("MobType", mobType)
    mobModel:SetAttribute("CoinDrop", math.random(20, 50))

    mobModel.Parent = parentRoom

    -- Démarrer l'IA
    self:StartAI(mobModel, mobData)

    return mobModel
end
```

#### Étape 2: Créer MobAI
**Fichier**: `src/server/Systems/MobAI.luau`

```lua
local MobAI = {}

function MobAI:Init(mobModel, mobData)
    self.model = mobModel
    self.data = mobData
    self.state = "IDLE"
    self.target = nil
    self.lastAttack = 0

    task.spawn(function()
        self:Run()
    end)
end

function MobAI:Run()
    while self.model.Parent do
        if self.state == "IDLE" then
            self:StateIdle()
        elseif self.state == "DETECT" then
            self:StateDetect()
        elseif self.state == "CHASE" then
            self:StateChase()
        elseif self.state == "ATTACK" then
            self:StateAttack()
        elseif self.state == "RETREAT" then
            self:StateRetreat()
        end

        task.wait(0.5) -- FSM tick rate
    end
end

function MobAI:StateIdle()
    -- Détecter joueurs à proximité (30 studs)
    local nearestPlayer = self:FindNearestPlayer(30)
    if nearestPlayer then
        self.target = nearestPlayer
        self.state = "CHASE"
    else
        -- Patrouille aléatoire
        self:WanderRandomly()
    end
end

function MobAI:StateChase()
    if not self.target or not self.target.Character then
        self.state = "IDLE"
        return
    end

    local distance = self:GetDistanceToTarget()

    -- À portée d'attaque?
    if distance <= self.data.attackRange then
        self.state = "ATTACK"
    else
        -- Continuer la poursuite
        self:MoveTowards(self.target.Character.HumanoidRootPart.Position)
    end
end

function MobAI:StateAttack()
    -- Utiliser un sort disponible
    local spell = self:ChooseBestSpell()
    if spell and tick() - self.lastAttack > spell.cooldown then
        self:CastSpell(spell)
        self.lastAttack = tick()
    end

    -- Vérifier si toujours à portée
    local distance = self:GetDistanceToTarget()
    if distance > self.data.attackRange then
        self.state = "CHASE"
    end
end

function MobAI:StateRetreat()
    -- HP < 30%
    local humanoid = self.model:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health / humanoid.MaxHealth > 0.3 then
        self.state = "CHASE" -- Retour au combat
    else
        -- Fuir
        self:FleeFrom(self.target.Character.HumanoidRootPart.Position)
    end
end
```

#### Étape 3: Intégrer dans RoomFactory
```lua
function RoomFactory:PopulateMobs(roomFolder, roomWorldPos, x, y)
    -- Pas de mobs dans S et Z
    if self.gridService:IsStartRoom(x, y) or self.gridService:IsEndRoom(x, y) then
        return
    end

    -- 40% des salles ont des mobs
    if math.random() > 0.4 then return end

    local mobCount = math.random(1, 3)
    local mobTypes = {"MeleeWarrior", "RangedShooter", "Tank", "Grenadier"}

    for i = 1, mobCount do
        local mobType = mobTypes[math.random(1, #mobTypes)]
        local pos = self:GetRandomRoomPosition(roomWorldPos)
        self.mobFactory:CreateMob(mobType, pos, roomFolder)
    end
end
```

---

## 📐 Conventions et Standards

### Nomenclature

**Fichiers**:
- Services: `NomService.luau`
- Modules: `NomModule.luau`
- Commandes: `NomCommand.luau`
- UI: `NomUI.luau`

**Variables**:
- camelCase pour variables locales: `localVariable`
- PascalCase pour modules/classes: `MyModule`
- UPPER_SNAKE pour constantes: `MAX_PLAYERS`

**Fonctions**:
- camelCase: `myFunction()`
- Méthodes avec `:` pour OOP: `object:method()`

### Structure de Code

**Ordre dans un fichier**:
```lua
-- 1. Header comment
--[[
    Nom du Module
    Description
]]

-- 2. Requires
local Module1 = require(...)
local Module2 = require(...)

-- 3. Déclaration du module
local MyModule = {}

-- 4. Constantes locales
local CONSTANT = 10

-- 5. Méthodes publiques
function MyModule:Init()
end

function MyModule:PublicMethod()
end

-- 6. Méthodes privées (local)
local function privateHelper()
end

-- 7. Export
return MyModule
```

### Gestion d'Erreurs

**Toujours utiliser pcall pour le code critique**:
```lua
local success, result = pcall(function()
    return dangerousOperation()
end)

if not success then
    warn("Erreur:", result)
    return fallbackValue
end
```

### Logs et Débogage

**Emojis pour les logs** (déjà utilisés):
- 🔧 Initialisation
- ✅ Succès
- ❌ Erreur
- ⚠️ Avertissement
- 🔍 Debug
- 💰 Coins/Économie
- 🎯 Combat/Sorts
- 👾 Mobs
- 🏆 Victoire

### RemoteEvents

**Convention de nommage**:
- PascalCase: `CoinCollected`, `SpellCast`, `MobDied`
- Descriptifs et clairs

**Sécurité**:
- Toujours valider côté serveur
- Limiter le taux d'appel (rate limiting)
- Vérifier les permissions

### Performance

**Bonnes pratiques**:
- Utiliser `task.wait()` au lieu de `wait()`
- Éviter les boucles infinies sans wait
- Nettoyer les connexions d'événements
- Utiliser des Object Pools pour les projectiles
- Limiter le nombre d'effets visuels simultanés

---

## 🎯 Ordre d'Implémentation Recommandé

### Sprint 1 (Fondations Combat) - ~2-3 jours
1. HealthService (serveur)
2. HealthBarUI (client)
3. Système de dégâts basique
4. Tests avec commande `/damage`

### Sprint 2 (Sorts Basiques) - ~3-4 jours
1. SpellService architecture
2. Sort 1: BasicSlash
3. Sort 2: PowerSlash
4. SpellBarUI
5. Tests et équilibrage

### Sprint 3 (Sorts Avancés) - ~3-4 jours
1. Sort 3: Gunshot (projectiles)
2. Sort 4: Grenade (zone)
3. Sort 5: Shield (buff)
4. Système de cooldown UI
5. Équilibrage final

### Sprint 4 (Obstacles) - ~2 jours
1. Obstacles destructibles
2. Effets de destruction
3. Système de drops
4. Tests et équilibrage

### Sprint 5 (Pièges) - ~2-3 jours
1. TrapFactory
2. 3 types de pièges
3. Génération procédurale
4. Effets visuels

### Sprint 6 (Mobs) - ~4-5 jours
1. MobFactory
2. MobAI (FSM basique)
3. 4 types de mobs
4. Système de drops
5. Tests et équilibrage IA

### Sprint 7 (Polish & Balance) - ~2-3 jours
1. Équilibrage global
2. Feedback visuels/sonores
3. Tests de gameplay complet
4. Corrections de bugs
5. Optimisation

---

## 📞 Points de Contact Architecture

### Hooks Importants

**init.server.luau**:
```lua
-- Ligne 133: Hook EndGame
worldManager.EndGame = function(_self, winner)
    roundManager:EndRound(winner)
end

-- Ligne 169: Hook RestartGame
worldManager.restartGame = restartGameCompletely
```

**WorldManager:GetGameState()**:
- Retourne un objet avec toutes les fonctions accessibles aux commandes
- Ajouter nouvelles fonctions ici pour les commandes

**RemoteService**:
- Ajouter nouveaux RemoteEvents dans `Init()` pour phase 2

### Services à Étendre

**PlayerManager**:
- Ajouter gestion HP
- Ajouter stats de combat (kills, deaths)

**EntityFactory**:
- Ajouter création projectiles
- Ajouter effets visuels sorts

**RoomFactory**:
- Ajouter appels TrapFactory
- Ajouter appels MobFactory

---

## ✅ Checklist Phase 2

### Système de Combat
- [ ] HealthService créé
- [ ] HealthBarUI style Wakfu
- [ ] Système de régénération
- [ ] SpellService architecture
- [ ] 5 sorts implémentés
- [ ] SpellBarUI fonctionnelle
- [ ] Système de cooldown
- [ ] Déduction coins pour sorts
- [ ] Animations et effets

### Obstacles Destructibles
- [ ] Système HP pour obstacles
- [ ] Dégâts aux obstacles
- [ ] Animation destruction
- [ ] Drops de coins
- [ ] Feedback visuel

### Pièges
- [ ] TrapFactory créé
- [ ] Piège dégâts (rouge)
- [ ] Piège ralentissement (cyan)
- [ ] Piège vitesse (jaune)
- [ ] Génération procédurale équilibrée
- [ ] Effets visuels néons

### Mobs
- [ ] MobFactory créé
- [ ] MobAI FSM basique
- [ ] 4 types de mobs
- [ ] Mobs utilisent sorts joueurs
- [ ] Système de drops
- [ ] Génération procédurale
- [ ] Équilibrage IA

### Tests & Polish
- [ ] Équilibrage dégâts global
- [ ] Équilibrage coûts sorts
- [ ] Équilibrage génération ennemis/pièges
- [ ] Tests multijoueur
- [ ] Performance OK
- [ ] Pas de bugs critiques

---

## 📝 Notes de Développement

### Problèmes Résolus (Phase 1)

1. **Conflit de noms**: `PlayerManager:CreateLeaderboard()` utilisé deux fois
   - Solution: Renommé en `GetFinalLeaderboard()`

2. **Collecte de coins ne fonctionnait pas**: ClickDetector avec CanCollide=false
   - Solution: Zone de trigger invisible séparée

3. **Leaderstats non créés**: Joueurs connectés avant init
   - Solution: Boucle sur `Players:GetPlayers()` dans `Init()`

4. **Barrières invisibles trop basses**: Joueurs tombaient dans le vide
   - Solution: Hauteur augmentée à 500 studs depuis le sol

5. **EndZone detection cassée**: Circular call entre WorldManager et RoundManager
   - Solution: Hook dans init.server.luau pour redirection propre

### Points d'Attention Phase 2

- **Performance**: Limite de mobs/projectiles simultanés
- **Sécurité**: Valider toutes les actions côté serveur (anti-cheat)
- **Réseau**: Minimiser les RemoteEvent calls (batch updates)
- **Équilibrage**: Playtester régulièrement avec plusieurs joueurs
- **Compatibilité**: Tester sur PC et mobile

---

**Fin du DEV_CONTEXT.md** - Bonne chance pour la Phase 2! 🚀
