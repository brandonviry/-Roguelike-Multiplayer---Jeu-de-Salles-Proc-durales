# 📂 Système de Commandes Modulaire - Documentation

## 🎯 Vue d'ensemble

Le système de commandes a été **complètement refactorisé** pour être modulaire, extensible et facile à maintenir.

### Avant
```
❌ Toutes les commandes dans AdminCommands.luau (300 lignes)
❌ Difficile d'ajouter une nouvelle commande
❌ Code répétitif et difficile à maintenir
```

### Après
```
✅ Chaque commande = 1 fichier indépendant
✅ Chargement automatique via CommandRegistry
✅ Système d'aliases intégré
✅ Template pour créer rapidement de nouvelles commandes
```

---

## 📁 Structure

```
src/server/
├── AdminCommands.luau              # Gestionnaire principal (104 lignes)
│
└── commands/                       # 📂 Dossier des commandes
    ├── README.md                   # Documentation du système
    ├── _CommandTemplate.luau       # Template pour nouvelles commandes
    ├── CommandRegistry.luau        # Système d'enregistrement automatique
    │
    ├── TeleportCommand.luau        # /tp [x] [y]
    ├── PositionCommand.luau        # /pos
    ├── PlayersCommand.luau         # /players
    ├── GiveCoinsCommand.luau       # /givecoins [nom] [montant]
    ├── SetCoinsCommand.luau        # /setcoins [montant]
    ├── CompassCommand.luau         # /compass
    ├── ShowGridCommand.luau        # /showgrid
    ├── EndGameCommand.luau         # /endgame
    └── HelpCommand.luau            # /help
```

---

## 🚀 Ajouter une nouvelle commande (3 étapes)

### 1. Copier le template
```bash
# Dans le dossier commands/
cp _CommandTemplate.luau MaCommandeCommand.luau
```

### 2. Modifier le fichier
```lua
--[[
    Commande: /speed
    Changer la vitesse de déplacement
]]

local SpeedCommand = {}

SpeedCommand.metadata = {
    name = "speed",
    description = "Changer ta vitesse de déplacement",
    usage = "/speed [vitesse]",
    adminOnly = true,
    aliases = {"walkspeed", "ws"},
}

function SpeedCommand.execute(player, args, gameState)
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

return SpeedCommand
```

### 3. C'est tout !
La commande sera **automatiquement chargée** au démarrage du serveur. Pas besoin de modifier quoi que ce soit d'autre !

---

## 🔧 Comment ça fonctionne ?

### Architecture

```
┌─────────────────────────────────────────────────────┐
│ AdminCommands.luau                                  │
│ - Vérifie les permissions                           │
│ - Parse les messages du chat                        │
│ - Délègue l'exécution au CommandRegistry            │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ CommandRegistry.luau                                │
│ - Scanne le dossier commands/                       │
│ - Charge automatiquement toutes les commandes       │
│ - Gère les aliases (raccourcis)                     │
│ - Exécute les commandes avec gestion d'erreurs      │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ Commandes individuelles (*.Command.luau)            │
│ - TeleportCommand.luau → /tp                        │
│ - SpeedCommand.luau → /speed                        │
│ - etc.                                              │
└─────────────────────────────────────────────────────┘
```

### Flux d'exécution

```
1. Joueur tape dans le chat: "/tp 5 10"
   ↓
2. AdminCommands.executeCommand() détecte le "/"
   ↓
3. Parse: commandName = "tp", args = ["5", "10"]
   ↓
4. Vérifie si le joueur est admin
   ↓
5. CommandRegistry:ExecuteCommand("tp", args, gameState)
   ↓
6. CommandRegistry trouve TeleportCommand
   ↓
7. Vérifie les permissions (adminOnly?)
   ↓
8. Exécute TeleportCommand.execute(player, args, gameState)
   ↓
9. Retourne (success: true, message: "Téléporté à...")
   ↓
10. Affiche le résultat dans la console
```

---

## 📋 Commandes actuellement disponibles

| Commande | Fichier | Aliases | Description |
|----------|---------|---------|-------------|
| `/tp [x] [y]` | TeleportCommand.luau | `teleport` | Téléporter à une salle |
| `/pos` | PositionCommand.luau | `position`, `where` | Afficher position actuelle |
| `/players` | PlayersCommand.luau | `list`, `who` | Lister tous les joueurs |
| `/givecoins [nom] [montant]` | GiveCoinsCommand.luau | `give` | Donner des coins |
| `/setcoins [montant]` | SetCoinsCommand.luau | `setmoney` | Modifier son score |
| `/compass` | CompassCommand.luau | `boussole` | Toggle boussole vers Z |
| `/showgrid` | ShowGridCommand.luau | `grid`, `map` | Afficher la grille |
| `/endgame` | EndGameCommand.luau | `end`, `stop` | Terminer la partie |
| `/help` | HelpCommand.luau | `?`, `commands` | Liste des commandes |

---

## 🎨 Structure d'une commande

### Métadonnées
```lua
CommandeName.metadata = {
    name = "exemple",           -- Nom de la commande (REQUIS)
    description = "...",         -- Description courte (REQUIS)
    usage = "/exemple [args]",   -- Usage avec exemples (REQUIS)
    adminOnly = true,            -- Réservée aux admins ? (REQUIS)
    aliases = {"ex", "test"},    -- Raccourcis (OPTIONNEL)
}
```

### Fonction execute
```lua
function CommandeName.execute(player, args, gameState)
    -- Validation des arguments
    if not args[1] then
        return false, "Usage: " .. CommandeName.metadata.usage
    end

    -- Votre logique ici
    -- ...

    -- Retourner (success: boolean, message: string)
    return true, "Succès!"
end
```

### Paramètres disponibles

**player** - Le joueur qui exécute la commande
```lua
player.Name         -- Nom du joueur
player.UserId       -- ID unique
player.Character    -- Modèle 3D du personnage
```

**args** - Tableau des arguments
```lua
-- Si l'utilisateur tape: /tp 5 10
args[1] = "5"
args[2] = "10"
```

**gameState** - État du jeu
```lua
gameState.CONFIG                        -- Configuration
gameState.worldGrid                     -- Grille 12x12
gameState.playerPositions               -- Positions joueurs
gameState.startPos                      -- Position départ (O)
gameState.endPos                        -- Position arrivée (Z)
gameState.gameEnded                     -- Booléen
gameState.teleportPlayerToRoom(p, x, y) -- Fonction
gameState.endGameForAll(winner)         -- Fonction
gameState.compassEvent                  -- RemoteEvent
```

---

## 🔍 Debug

### Vérifier le chargement des commandes

Au démarrage du serveur, vous devriez voir :
```
👑 Initialisation AdminCommands...
📋 Initialisation CommandRegistry...
  ✅ Commande enregistrée: tp
    📎 Alias: teleport → tp
  ✅ Commande enregistrée: pos
    📎 Alias: position → pos
    📎 Alias: where → pos
  ✅ Commande enregistrée: players
  ...
✅ CommandRegistry initialisé - 9 commande(s) chargée(s)
✅ AdminCommands initialisé
```

### Tester une commande

1. **Devenir admin**
   ```lua
   -- Dans AdminCommands.luau
   AdminCommands.ADMINS = {
       ["VotreNomRoblox"] = true,
   }
   ```

2. **Lancer le jeu** et taper `/help`

3. **Vérifier la console** pour voir la liste

### Erreurs courantes

**"Commande inconnue"**
- Vérifier que le fichier est bien dans `commands/`
- Vérifier que le nom du fichier se termine par `Command.luau`
- Vérifier que `metadata.name` est défini

**"Cette commande est réservée aux administrateurs"**
- Vérifier que votre nom est dans `AdminCommands.ADMINS`
- Vérifier que `adminOnly = false` si la commande doit être publique

**"Erreur lors de l'exécution"**
- Ajouter des `print()` dans votre commande pour débugger
- Vérifier que vous retournez bien `(success, message)`

---

## 💡 Exemples de commandes personnalisées

### Commande simple (sans arguments)
```lua
-- PingCommand.luau
local PingCommand = {}

PingCommand.metadata = {
    name = "ping",
    description = "Tester la connexion",
    usage = "/ping",
    adminOnly = false,
}

function PingCommand.execute(player, args, gameState)
    return true, "Pong! 🏓 Serveur répond correctement"
end

return PingCommand
```

### Commande avec validation
```lua
-- KickCommand.luau
local Players = game:GetService("Players")

local KickCommand = {}

KickCommand.metadata = {
    name = "kick",
    description = "Expulser un joueur",
    usage = "/kick [nom] [raison]",
    adminOnly = true,
}

function KickCommand.execute(player, args, gameState)
    local targetName = args[1]

    if not targetName then
        return false, "Usage: /kick [nom] [raison]"
    end

    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer then
        return false, "Joueur introuvable: " .. targetName
    end

    if targetPlayer == player then
        return false, "Tu ne peux pas te kick toi-même !"
    end

    local reason = table.concat(args, " ", 2) or "Aucune raison"
    targetPlayer:Kick("Expulsé: " .. reason)

    return true, targetName .. " a été expulsé"
end

return KickCommand
```

### Commande avancée
```lua
-- FlyCommand.luau
local FlyCommand = {}

FlyCommand.metadata = {
    name = "fly",
    description = "Activer/désactiver le vol",
    usage = "/fly",
    adminOnly = true,
    aliases = {"flight"},
}

-- Table pour stocker l'état du vol par joueur
local flyingPlayers = {}

function FlyCommand.execute(player, args, gameState)
    local character = player.Character
    if not character then
        return false, "Personnage introuvable"
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return false, "Humanoid introuvable"
    end

    -- Toggle le vol
    if flyingPlayers[player.UserId] then
        -- Désactiver le vol
        flyingPlayers[player.UserId] = false
        humanoid.PlatformStand = false
        return true, "Vol désactivé"
    else
        -- Activer le vol
        flyingPlayers[player.UserId] = true
        humanoid.PlatformStand = true

        -- Créer le BodyVelocity pour le vol
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = character.HumanoidRootPart

        return true, "Vol activé! Utilise WASD + Espace/Shift"
    end
end

return FlyCommand
```

---

## 🎓 Bonnes pratiques

### ✅ DO

1. **Toujours valider les arguments**
   ```lua
   if not args[1] then
       return false, "Argument manquant"
   end
   ```

2. **Messages d'erreur clairs**
   ```lua
   return false, "Usage: /tp [x] [y] - Coordonnées entre 0 et 11"
   ```

3. **Documenter la commande**
   ```lua
   --[[
       Commande: /tp
       Description: Téléporter à une salle
       Usage: /tp [x] [y]
   ]]
   ```

4. **Utiliser des aliases pertinents**
   ```lua
   aliases = {"teleport", "warp", "goto"}
   ```

5. **Retourner toujours (success, message)**
   ```lua
   return true, "Opération réussie"
   return false, "Erreur: ..."
   ```

### ❌ DON'T

1. **Ne pas oublier les métadonnées**
2. **Ne pas mettre plusieurs commandes dans un fichier**
3. **Ne pas faire de `require()` complexes**
4. **Ne pas modifier `gameState` directement** (utiliser les fonctions fournies)
5. **Ne pas oublier de tester**

---

## 🚀 Avantages du nouveau système

### ✅ Extensibilité
Ajouter une commande = créer un fichier. Aucune modification ailleurs.

### ✅ Maintenabilité
Chaque commande est isolée. Facile de modifier ou supprimer.

### ✅ Lisibilité
Code clair, structure cohérente, facile à comprendre.

### ✅ Réutilisabilité
Les commandes peuvent être copiées dans d'autres projets.

### ✅ Collaboration
Plusieurs développeurs peuvent travailler sur différentes commandes sans conflit.

### ✅ Aliases
Système d'aliases intégré pour plusieurs noms de commande.

---

## 📖 Ressources

- **[commands/README.md](src/server/commands/README.md)** - Documentation détaillée
- **[commands/_CommandTemplate.luau](src/server/commands/_CommandTemplate.luau)** - Template à copier
- **[AdminCommands.luau](src/server/AdminCommands.luau)** - Gestionnaire principal
- **[CommandRegistry.luau](src/server/commands/CommandRegistry.luau)** - Système d'enregistrement

---

**Système de commandes modulaire - Extensible et professionnel ! 🎉**

*Créé avec l'architecture modulaire v2.0*
