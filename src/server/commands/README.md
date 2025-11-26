# 📂 Commands - Système de Commandes Modulaire

## 🎯 Architecture

Chaque commande est un **module indépendant** dans ce dossier.

### Structure d'une commande

```lua
--[[
    Commande: /macommande
    Description: Ce que fait la commande
    Usage: /macommande [arg1] [arg2]
]]

local MaCommande = {}

-- Métadonnées de la commande
MaCommande.metadata = {
    name = "macommande",              -- Nom de la commande (sans /)
    description = "Description courte",
    usage = "/macommande [arg1] [arg2]",
    adminOnly = true,                 -- true si réservée aux admins
    aliases = {"mc", "cmd"},          -- Noms alternatifs (optionnel)
}

-- Exécution de la commande
function MaCommande.execute(player, args, gameState)
    -- Logique de la commande ici

    -- Retourner (success: boolean, message: string)
    return true, "Commande exécutée avec succès"
end

return MaCommande
```

---

## 📋 Commandes disponibles

| Fichier | Commande | Description | Admin Only |
|---------|----------|-------------|------------|
| `TeleportCommand.luau` | `/tp [x] [y]` | Téléporter à une salle | ✅ |
| `PositionCommand.luau` | `/pos` | Afficher position actuelle | ✅ |
| `PlayersCommand.luau` | `/players` | Lister tous les joueurs | ✅ |
| `GiveCoinsCommand.luau` | `/givecoins [nom] [montant]` | Donner des coins | ✅ |
| `SetCoinsCommand.luau` | `/setcoins [montant]` | Modifier son score | ✅ |
| `CompassCommand.luau` | `/compass` | Toggle boussole vers Z | ✅ |
| `ShowGridCommand.luau` | `/showgrid` | Afficher la grille | ✅ |
| `EndGameCommand.luau` | `/endgame` | Terminer la partie | ✅ |
| `HelpCommand.luau` | `/help` | Liste des commandes | ❌ |

---

## ➕ Ajouter une nouvelle commande

### 1. Créer le fichier
```bash
# Créer un nouveau fichier dans ce dossier
touch src/server/commands/MaCommandeCommand.luau
```

### 2. Utiliser le template
Copiez le contenu de `_CommandTemplate.luau` et modifiez-le.

### 3. C'est tout !
Le système `CommandRegistry` détecte automatiquement les nouvelles commandes.

---

## 🔧 API disponible pour les commandes

### `gameState`
Objet contenant l'état du jeu :

```lua
gameState.CONFIG                   -- Configuration du jeu
gameState.worldGrid                -- Grille 12x12
gameState.playerPositions          -- Positions des joueurs
gameState.startPos                 -- Position de départ (O)
gameState.endPos                   -- Position d'arrivée (Z)
gameState.gameEnded                -- Booléen: partie terminée ?
gameState.teleportPlayerToRoom(player, x, y)  -- Fonction
gameState.endGameForAll(winner)    -- Fonction
gameState.compassEvent             -- RemoteEvent
```

### `args`
Tableau des arguments passés à la commande :

```lua
-- Si l'utilisateur tape: /tp 5 10
args[1] = "5"
args[2] = "10"
```

### Services disponibles
```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
```

---

## 📖 Exemples

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
    return true, "Pong! 🏓"
end

return PingCommand
```

### Commande avec arguments
```lua
-- SpeedCommand.luau
local SpeedCommand = {}

SpeedCommand.metadata = {
    name = "speed",
    description = "Changer sa vitesse",
    usage = "/speed [vitesse]",
    adminOnly = true,
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

### Commande avec validation complexe
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
        return false, "Joueur '" .. targetName .. "' introuvable"
    end

    if targetPlayer == player then
        return false, "Tu ne peux pas te kick toi-même !"
    end

    local reason = table.concat(args, " ", 2) or "Aucune raison"
    targetPlayer:Kick("Expulsé par " .. player.Name .. ": " .. reason)

    return true, targetName .. " a été expulsé"
end

return KickCommand
```

---

## 🎨 Bonnes pratiques

### ✅ DO (À faire)

1. **Une commande = un fichier**
   ```
   TeleportCommand.luau
   SpeedCommand.luau
   ```

2. **Nommer le fichier avec `Command` à la fin**
   ```
   ✅ TeleportCommand.luau
   ❌ Teleport.luau
   ```

3. **Valider les arguments**
   ```lua
   if not args[1] then
       return false, "Argument manquant"
   end
   ```

4. **Retourner des messages clairs**
   ```lua
   return true, "Téléporté à la salle (5, 10)"
   return false, "Coordonnées invalides"
   ```

5. **Documenter en haut du fichier**
   ```lua
   --[[
       Commande: /tp
       Description: Téléporter à une salle
       Usage: /tp [x] [y]
   ]]
   ```

### ❌ DON'T (À éviter)

1. **Ne pas mettre plusieurs commandes dans un fichier**
2. **Ne pas oublier les métadonnées**
3. **Ne pas oublier de retourner (success, message)**
4. **Ne pas faire de require() complexes**
5. **Ne pas modifier gameState directement**

---

## 🔍 Debug

### Tester une commande
```lua
-- Ajouter des prints dans votre commande
function MyCommand.execute(player, args, gameState)
    print("🔍 DEBUG: MyCommand appelée par", player.Name)
    print("🔍 DEBUG: Args:", table.concat(args, ", "))

    -- Votre logique

    print("✅ DEBUG: MyCommand terminée")
    return true, "OK"
end
```

### Vérifier que la commande est chargée
Dans la console, après le démarrage du serveur :
```
✅ Commande enregistrée: tp
✅ Commande enregistrée: pos
✅ Commande enregistrée: help
...
```

---

## 🚀 Système automatique

Le `CommandRegistry` :
1. **Scan automatiquement** ce dossier
2. **Charge toutes les commandes** (fichiers *Command.luau)
3. **Enregistre les métadonnées**
4. **Gère l'exécution** et les permissions

Vous n'avez **rien à configurer** ! Juste ajouter un fichier ici.

---

**Architecture conçue pour être extensible et facile à maintenir !** 🎉
