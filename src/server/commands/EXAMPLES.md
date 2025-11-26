# 💡 Exemples de Commandes - Guide Pratique

## 🎯 Exemples prêts à l'emploi

Voici des exemples de commandes que vous pouvez copier-coller et adapter.

---

## 1. Commande simple (sans arguments)

### Exemple: Commande Ping

**Fichier:** `PingCommand.luau`

```lua
--[[
    Commande: /ping
    Tester la connexion au serveur
]]

local PingCommand = {}

PingCommand.metadata = {
    name = "ping",
    description = "Tester la connexion",
    usage = "/ping",
    adminOnly = false,  -- Accessible à tous
}

function PingCommand.execute(player, args, gameState)
    return true, "Pong! 🏓 Le serveur répond"
end

return PingCommand
```

**Utilisation:** `/ping`

---

## 2. Commande avec un argument

### Exemple: Changer la vitesse

**Fichier:** `SpeedCommand.luau`

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
    -- Validation
    local speed = tonumber(args[1])
    if not speed then
        return false, "Usage: /speed [vitesse] - Exemple: /speed 50"
    end

    -- Obtenir le personnage
    local character = player.Character
    if not character then
        return false, "Personnage introuvable"
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return false, "Humanoid introuvable"
    end

    -- Modifier la vitesse
    humanoid.WalkSpeed = speed
    return true, "Vitesse définie à " .. speed
end

return SpeedCommand
```

**Utilisation:** `/speed 50` ou `/ws 100`

---

## 3. Commande avec plusieurs arguments

### Exemple: Donner un item

**Fichier:** `GiveItemCommand.luau`

```lua
--[[
    Commande: /giveitem
    Donner un item à un joueur
]]

local Players = game:GetService("Players")

local GiveItemCommand = {}

GiveItemCommand.metadata = {
    name = "giveitem",
    description = "Donner un item à un joueur",
    usage = "/giveitem [joueur] [item] [quantité]",
    adminOnly = true,
    aliases = {"item"},
}

function GiveItemCommand.execute(player, args, gameState)
    local targetName = args[1]
    local itemName = args[2]
    local quantity = tonumber(args[3]) or 1

    -- Validation
    if not targetName or not itemName then
        return false, "Usage: /giveitem [joueur] [item] [quantité]"
    end

    -- Trouver le joueur
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer then
        return false, "Joueur introuvable: " .. targetName
    end

    -- Logique pour donner l'item (exemple)
    print("Donner", quantity, itemName, "à", targetName)

    return true, "Donné " .. quantity .. "x " .. itemName .. " à " .. targetName
end

return GiveItemCommand
```

**Utilisation:** `/giveitem Player1 Sword 5`

---

## 4. Commande toggle (activer/désactiver)

### Exemple: Mode God

**Fichier:** `GodmodeCommand.luau`

```lua
--[[
    Commande: /god
    Activer/désactiver le mode invincible
]]

local GodmodeCommand = {}

GodmodeCommand.metadata = {
    name = "god",
    description = "Toggle mode invincible",
    usage = "/god",
    adminOnly = true,
    aliases = {"godmode", "invincible"},
}

-- Table pour stocker l'état par joueur
local godmodePlayers = {}

function GodmodeCommand.execute(player, args, gameState)
    local character = player.Character
    if not character then
        return false, "Personnage introuvable"
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return false, "Humanoid introuvable"
    end

    -- Toggle le godmode
    if godmodePlayers[player.UserId] then
        -- Désactiver
        godmodePlayers[player.UserId] = false
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        return true, "Godmode désactivé"
    else
        -- Activer
        godmodePlayers[player.UserId] = true
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        return true, "Godmode activé"
    end
end

return GodmodeCommand
```

**Utilisation:** `/god` (toggle on/off)

---

## 5. Commande avec choix (options)

### Exemple: Changer le temps

**Fichier:** `TimeCommand.luau`

```lua
--[[
    Commande: /time
    Changer l'heure du jour
]]

local Lighting = game:GetService("Lighting")

local TimeCommand = {}

TimeCommand.metadata = {
    name = "time",
    description = "Changer l'heure du jour",
    usage = "/time [day|night|dawn|dusk|HH:MM]",
    adminOnly = true,
}

function TimeCommand.execute(player, args, gameState)
    local timeArg = args[1]

    if not timeArg then
        return false, "Usage: /time [day|night|dawn|dusk|HH:MM]"
    end

    -- Présets
    local presets = {
        day = 12,
        noon = 12,
        night = 0,
        midnight = 0,
        dawn = 6,
        sunrise = 6,
        dusk = 18,
        sunset = 18,
    }

    local timeValue = presets[timeArg:lower()]

    if timeValue then
        Lighting.ClockTime = timeValue
        return true, "Heure définie à " .. timeArg
    else
        -- Parser HH:MM
        local hour, minute = timeArg:match("(%d+):(%d+)")
        if hour and minute then
            local time = tonumber(hour) + (tonumber(minute) / 60)
            Lighting.ClockTime = time
            return true, "Heure définie à " .. timeArg
        else
            return false, "Format invalide. Utilisez: day, night, dawn, dusk ou HH:MM"
        end
    end
end

return TimeCommand
```

**Utilisation:**
- `/time day`
- `/time night`
- `/time 14:30`

---

## 6. Commande avec RemoteEvent

### Exemple: Notification personnalisée

**Fichier:** `NotifyCommand.luau`

```lua
--[[
    Commande: /notify
    Envoyer une notification à un joueur
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotifyCommand = {}

NotifyCommand.metadata = {
    name = "notify",
    description = "Envoyer une notification à un joueur",
    usage = "/notify [joueur] [message]",
    adminOnly = true,
}

function NotifyCommand.execute(player, args, gameState)
    local targetName = args[1]

    if not targetName then
        return false, "Usage: /notify [joueur] [message]"
    end

    -- Récupérer le reste comme message
    local message = table.concat(args, " ", 2)
    if message == "" then
        message = "Notification de " .. player.Name
    end

    -- Trouver le joueur
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer then
        return false, "Joueur introuvable: " .. targetName
    end

    -- Envoyer via RemoteEvent (à créer dans RemoteService)
    local notifyEvent = ReplicatedStorage.Remotes:FindFirstChild("NotifyPlayer")
    if notifyEvent then
        notifyEvent:FireClient(targetPlayer, message, player.Name)
        return true, "Notification envoyée à " .. targetName
    else
        return false, "RemoteEvent 'NotifyPlayer' introuvable"
    end
end

return NotifyCommand
```

**Utilisation:** `/notify Player1 Hello!`

---

## 7. Commande pour modifier le gameState

### Exemple: Changer la position de l'arrivée

**Fichier:** `MoveFinishCommand.luau`

```lua
--[[
    Commande: /movefinish
    Déplacer la position de l'arrivée (Z)
]]

local MoveFinishCommand = {}

MoveFinishCommand.metadata = {
    name = "movefinish",
    description = "Déplacer l'arrivée à une nouvelle position",
    usage = "/movefinish [x] [y]",
    adminOnly = true,
    aliases = {"movez", "moveend"},
}

function MoveFinishCommand.execute(player, args, gameState)
    local x = tonumber(args[1])
    local y = tonumber(args[2])

    -- Validation
    if not x or not y then
        return false, "Usage: /movefinish [x] [y]"
    end

    if x < 0 or x >= gameState.CONFIG.GRID_SIZE or
       y < 0 or y >= gameState.CONFIG.GRID_SIZE then
        return false, "Coordonnées invalides (0-" .. (gameState.CONFIG.GRID_SIZE - 1) .. ")"
    end

    -- Sauvegarder l'ancienne position
    local oldX, oldY = gameState.endPos.x, gameState.endPos.y

    -- Modifier la position
    gameState.endPos.x = x
    gameState.endPos.y = y

    return true, "Arrivée déplacée de (" .. oldX .. ", " .. oldY .. ") vers (" .. x .. ", " .. y .. ")"
end

return MoveFinishCommand
```

**Utilisation:** `/movefinish 10 10`

---

## 8. Commande de liste/info

### Exemple: Statistiques du serveur

**Fichier:** `StatsCommand.luau`

```lua
--[[
    Commande: /stats
    Afficher les statistiques du serveur
]]

local Players = game:GetService("Players")

local StatsCommand = {}

StatsCommand.metadata = {
    name = "stats",
    description = "Afficher les statistiques du serveur",
    usage = "/stats",
    adminOnly = true,
    aliases = {"info", "status"},
}

function StatsCommand.execute(player, args, gameState)
    local output = "📊 STATISTIQUES DU SERVEUR:\n"

    -- Joueurs
    local playerCount = #Players:GetPlayers()
    output = output .. "👥 Joueurs connectés: " .. playerCount .. "\n"

    -- Salles
    local roomCount = 0
    for x = 0, gameState.CONFIG.GRID_SIZE - 1 do
        for y = 0, gameState.CONFIG.GRID_SIZE - 1 do
            if gameState.worldGrid[x][y] then
                roomCount = roomCount + 1
            end
        end
    end
    output = output .. "🗺️ Salles générées: " .. roomCount .. "/" .. (gameState.CONFIG.GRID_SIZE * gameState.CONFIG.GRID_SIZE) .. "\n"

    -- État du jeu
    output = output .. "🎮 Partie en cours: " .. (gameState.gameEnded and "Non" or "Oui") .. "\n"

    -- Positions
    output = output .. "🟢 Départ: (" .. gameState.startPos.x .. ", " .. gameState.startPos.y .. ")\n"
    output = output .. "🏆 Arrivée: (" .. gameState.endPos.x .. ", " .. gameState.endPos.y .. ")\n"

    print(output)
    return true, "Statistiques affichées dans la console"
end

return StatsCommand
```

**Utilisation:** `/stats`

---

## 9. Commande complexe avec sous-commandes

### Exemple: Système de configuration

**Fichier:** `ConfigCommand.luau`

```lua
--[[
    Commande: /config
    Modifier la configuration du jeu en temps réel
]]

local ConfigCommand = {}

ConfigCommand.metadata = {
    name = "config",
    description = "Modifier la configuration du jeu",
    usage = "/config [get|set] [key] [value]",
    adminOnly = true,
    aliases = {"cfg", "setting"},
}

function ConfigCommand.execute(player, args, gameState)
    local action = args[1]

    if not action then
        return false, "Usage: /config [get|set] [key] [value]"
    end

    if action:lower() == "get" then
        local key = args[2]
        if not key then
            -- Afficher toute la config
            local output = "⚙️ CONFIGURATION:\n"
            for k, v in pairs(gameState.CONFIG) do
                output = output .. k .. " = " .. tostring(v) .. "\n"
            end
            print(output)
            return true, "Configuration affichée dans la console"
        else
            -- Afficher une clé spécifique
            local value = gameState.CONFIG[key:upper()]
            if value ~= nil then
                return true, key .. " = " .. tostring(value)
            else
                return false, "Clé inconnue: " .. key
            end
        end

    elseif action:lower() == "set" then
        local key = args[2]
        local value = args[3]

        if not key or not value then
            return false, "Usage: /config set [key] [value]"
        end

        -- Valider et convertir
        local numValue = tonumber(value)
        if numValue then
            value = numValue
        elseif value:lower() == "true" then
            value = true
        elseif value:lower() == "false" then
            value = false
        end

        -- Modifier la config
        local upperKey = key:upper()
        if gameState.CONFIG[upperKey] ~= nil then
            local oldValue = gameState.CONFIG[upperKey]
            gameState.CONFIG[upperKey] = value
            return true, key .. " modifié: " .. tostring(oldValue) .. " → " .. tostring(value)
        else
            return false, "Clé inconnue: " .. key
        end

    else
        return false, "Action invalide. Utilisez: get ou set"
    end
end

return ConfigCommand
```

**Utilisation:**
- `/config get`
- `/config get COIN_VALUE`
- `/config set COIN_VALUE 20`

---

## 🎓 Conseils

1. **Commencez simple** - Commandez par une commande sans arguments
2. **Validez toujours** - Vérifiez que les arguments sont corrects
3. **Messages clairs** - Donnez des messages d'erreur utiles
4. **Testez** - Essayez votre commande dans le jeu
5. **Documentez** - Ajoutez des commentaires explicatifs

---

**Bon développement ! 🚀**
