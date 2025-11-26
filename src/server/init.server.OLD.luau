--[[
	Serveur du jeu - Système de grille 12x12 avec graphe orienté
	Monde partagé persistant avec génération procédurale
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminCommands = require(script.AdminCommands)
local RoundManager = require(script.RoundManager)

print("🚀 === DÉMARRAGE DU SERVEUR - SYSTÈME DE ROUNDS ===")

-- Configuration
local CONFIG = {
	COIN_VALUE = 10,
	ROOM_SIZE = 50,
	ROOM_SPACING = 50, -- Espacement entre les salles
	DOOR_SIZE = Vector3.new(8, 10, 2),
	MIN_COINS_PER_ROOM = 3,
	MAX_COINS_PER_ROOM = 8,
	MIN_OBSTACLES = 0,
	MAX_OBSTACLES = 5,
	GRID_SIZE = 12,
	MIN_PATH_LENGTH = 10, -- Distance minimum O → Z
}

local COLORS = {
	FLOOR = Color3.fromRGB(85, 160, 85),
	WALL = Color3.fromRGB(70, 140, 70),
	DOOR_ACTIVE = Color3.fromRGB(100, 200, 255),
	DOOR_INACTIVE = Color3.fromRGB(60, 60, 60),
	OBSTACLE = Color3.fromRGB(120, 90, 70),
	START_ZONE = Color3.fromRGB(100, 255, 100),
	END_ZONE = Color3.fromRGB(255, 200, 50),
}

local COIN_COLORS = {
	Color3.fromRGB(255, 200, 50),   -- Doré
	Color3.fromRGB(80, 200, 255),   -- Bleu ciel
	Color3.fromRGB(255, 100, 200),  -- Rose
	Color3.fromRGB(150, 255, 100),  -- Vert
	Color3.fromRGB(200, 100, 255),  -- Violet
}

-- Créer RemoteEvents
local remoteFolder = Instance.new("Folder")
remoteFolder.Name = "Remotes"
remoteFolder.Parent = ReplicatedStorage

local coinCollectedEvent = Instance.new("RemoteEvent")
coinCollectedEvent.Name = "CoinCollected"
coinCollectedEvent.Parent = remoteFolder

local gameEndedEvent = Instance.new("RemoteEvent")
gameEndedEvent.Name = "GameEnded"
gameEndedEvent.Parent = remoteFolder

local compassEvent = Instance.new("RemoteEvent")
compassEvent.Name = "CompassToggle"
compassEvent.Parent = remoteFolder

local roundStateEvent = Instance.new("RemoteEvent")
roundStateEvent.Name = "RoundStateChanged"
roundStateEvent.Parent = remoteFolder

local doorTeleportEvent = Instance.new("RemoteEvent")
doorTeleportEvent.Name = "DoorTeleport"
doorTeleportEvent.Parent = remoteFolder

print("✅ RemoteEvents créés")

-- Grille du monde (partagée par tous les joueurs)
local worldGrid = {}
for x = 0, CONFIG.GRID_SIZE - 1 do
	worldGrid[x] = {}
	for y = 0, CONFIG.GRID_SIZE - 1 do
		worldGrid[x][y] = nil -- nil = pas encore générée
	end
end

-- Positions des joueurs dans la grille
local playerPositions = {}

-- État du jeu (dans une table pour partager les références)
local gameState = {
	gameEnded = false,
	startPos = {x = 6, y = 6}, -- Centre de la grille
	endPos = nil, -- Sera calculé
}

-- Alias pour compatibilité
local startPos = gameState.startPos
local endPos = gameState.endPos

-- Convertir coordonnées grille → position 3D
local function gridToWorld(x, y)
	local offset = CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING
	return Vector3.new(
		(x - startPos.x) * offset,
		0,
		(y - startPos.y) * offset
	)
end

-- Créer le leaderboard
local function setupLeaderboard(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	local rooms = Instance.new("IntValue")
	rooms.Name = "Salles"
	rooms.Value = 0
	rooms.Parent = leaderstats

	print("👤 Leaderboard créé pour:", player.Name)
end

-- Créer une étoile 3D (pièce)
local function createCoin(position, parentRoom)
	local starModel = Instance.new("Model")
	starModel.Name = "Coin"

	local color = COIN_COLORS[math.random(1, #COIN_COLORS)]

	-- Centre
	local center = Instance.new("Part")
	center.Name = "Center"
	center.Shape = Enum.PartType.Ball
	center.Size = Vector3.new(2, 2, 2)
	center.Material = Enum.Material.SmoothPlastic
	center.Color = color
	center.Anchored = true
	center.CanCollide = false
	center.Position = position
	center.Parent = starModel

	-- Pointes de l'étoile
	for i = 0, 5 do
		local angle = math.rad(i * 60)
		local spike = Instance.new("Part")
		spike.Name = "Spike" .. i
		spike.Size = Vector3.new(0.5, 0.5, 2)
		spike.Material = Enum.Material.SmoothPlastic
		spike.Color = color
		spike.Anchored = true
		spike.CanCollide = false

		local offsetX = math.cos(angle) * 1.5
		local offsetZ = math.sin(angle) * 1.5
		spike.Position = position + Vector3.new(offsetX, 0, offsetZ)
		spike.Orientation = Vector3.new(0, math.deg(angle), 0)
		spike.Parent = starModel
	end

	-- Highlight
	local highlight = Instance.new("Highlight")
	highlight.FillColor = color
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0.9
	highlight.Parent = starModel

	-- ClickDetector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 25
	clickDetector.Parent = center

	-- Gérer le clic
	clickDetector.MouseClick:Connect(function(player)
		if starModel.Parent then
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local coinsValue = leaderstats:FindFirstChild("Coins")
				if coinsValue then
					coinsValue.Value = coinsValue.Value + CONFIG.COIN_VALUE
					coinCollectedEvent:FireClient(player, CONFIG.COIN_VALUE, color)
					print("💰", player.Name, "a collecté une étoile!")
					starModel:Destroy()
				end
			end
		end
	end)

	starModel.Parent = parentRoom

	-- Animation de rotation
	task.spawn(function()
		local rotation = 0
		local time = 0

		while starModel.Parent do
			rotation = rotation + 2
			time = time + 0.05

			center.Orientation = Vector3.new(0, rotation, 0)

			for _, child in pairs(starModel:GetChildren()) do
				if child:IsA("BasePart") and child.Name:match("Spike") then
					local offset = child.Position - center.Position
					local angle = math.rad(rotation)
					local newX = offset.X * math.cos(angle) - offset.Z * math.sin(angle)
					local newZ = offset.X * math.sin(angle) + offset.Z * math.cos(angle)

					child.Position = center.Position + Vector3.new(newX, offset.Y, newZ)

					local spikeNum = tonumber(child.Name:match("%d+"))
					child.Orientation = Vector3.new(0, rotation + (spikeNum * 60), 0)
				end
			end

			local floatOffset = math.sin(time * 2) * 0.5
			center.Position = position + Vector3.new(0, floatOffset, 0)

			task.wait(0.03)
		end
	end)

	return starModel
end

-- Créer un obstacle
local function createObstacle(position, parentRoom)
	local obstacle = Instance.new("Part")
	obstacle.Name = "Obstacle"
	obstacle.Size = Vector3.new(
		math.random(3, 6),
		math.random(3, 8),
		math.random(3, 6)
	)
	obstacle.Position = position
	obstacle.Anchored = true
	obstacle.Material = Enum.Material.SmoothPlastic
	obstacle.Color = COLORS.OBSTACLE
	obstacle.Parent = parentRoom

	return obstacle
end

-- Créer une porte
local function createDoor(roomWorldPos, direction, isActive, targetX, targetY, roomFolder)
	local doorModel = Instance.new("Model")
	doorModel.Name = "Door_" .. direction

	-- Position de la porte selon la direction
	local doorPositions = {
		North = {Vector3.new(0, 5, -CONFIG.ROOM_SIZE/2), Vector3.new(0, 0, 0)},
		South = {Vector3.new(0, 5, CONFIG.ROOM_SIZE/2), Vector3.new(0, 180, 0)},
		East = {Vector3.new(CONFIG.ROOM_SIZE/2, 5, 0), Vector3.new(0, 90, 0)},
		West = {Vector3.new(-CONFIG.ROOM_SIZE/2, 5, 0), Vector3.new(0, -90, 0)},
	}

	local relPos = doorPositions[direction][1]
	local orientation = doorPositions[direction][2]
	local position = roomWorldPos + relPos

	-- Cadre de la porte
	local frame = Instance.new("Part")
	frame.Name = "Frame"
	frame.Size = CONFIG.DOOR_SIZE
	frame.Position = position
	frame.Orientation = orientation
	frame.Anchored = true
	frame.Material = Enum.Material.SmoothPlastic
	frame.Color = isActive and COLORS.DOOR_ACTIVE or COLORS.DOOR_INACTIVE
	frame.Transparency = isActive and 0.3 or 0.7
	frame.CanCollide = not isActive
	frame.Parent = doorModel

	if isActive then
		-- Zone de téléportation
		local trigger = Instance.new("Part")
		trigger.Name = "Trigger"
		trigger.Size = Vector3.new(CONFIG.DOOR_SIZE.X, CONFIG.DOOR_SIZE.Y, 4)
		trigger.Position = position
		trigger.Orientation = orientation
		trigger.Anchored = true
		trigger.Transparency = 1
		trigger.CanCollide = false
		trigger.Parent = doorModel

		-- Effet visuel
		local glow = Instance.new("PointLight")
		glow.Brightness = 2
		glow.Range = 20
		glow.Color = COLORS.DOOR_ACTIVE
		glow.Parent = frame

		-- Détection de toucher
		local debounce = {}
		trigger.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = Players:GetPlayerFromCharacter(character)

			if player and character:FindFirstChild("HumanoidRootPart") then
				if debounce[player.UserId] then return end
				debounce[player.UserId] = true

				print("🚪", player.Name, "passe par la porte", direction, "vers", targetX, targetY)

				-- Déclencher le son de téléportation côté client
				doorTeleportEvent:FireClient(player)

				-- Téléporter vers la salle cible
				teleportPlayerToRoom(player, targetX, targetY)

				task.wait(2)
				debounce[player.UserId] = false
			end
		end)
	end

	doorModel.Parent = roomFolder
	return doorModel
end

-- Terminer la partie pour tous les joueurs (maintenant géré par RoundManager)
local function endGameForAll(winner)
	-- Déléguer au RoundManager avec le gameState global
	RoundManager.endRound(winner, gameState)
end

-- Créer une salle à des coordonnées données
local function createRoomAt(x, y, doorConfig)
	if worldGrid[x][y] then
		print("⚠️ Salle", x, y, "existe déjà")
		return worldGrid[x][y]
	end

	print("🔨 Création salle à", x, y)

	local roomWorldPos = gridToWorld(x, y)
	local isEndRoom = gameState.endPos and (x == gameState.endPos.x and y == gameState.endPos.y)
	local isStartRoom = (x == gameState.startPos.x and y == gameState.startPos.y)

	-- Créer un nouveau dossier pour la salle
	local roomFolder = Instance.new("Folder")
	roomFolder.Name = "Room_" .. x .. "_" .. y
	roomFolder.Parent = workspace

	-- Sol
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(CONFIG.ROOM_SIZE, 2, CONFIG.ROOM_SIZE)
	floor.Position = roomWorldPos + Vector3.new(0, -1, 0)
	floor.Anchored = true
	floor.Material = Enum.Material.SmoothPlastic
	if isEndRoom then
		floor.Color = COLORS.END_ZONE
	elseif isStartRoom then
		floor.Color = COLORS.START_ZONE
	else
		floor.Color = COLORS.FLOOR
	end
	floor.Parent = roomFolder

	-- Murs (bordures visibles)
	local wallHeight = 3
	local walls = {
		{size = Vector3.new(CONFIG.ROOM_SIZE, wallHeight, 1), pos = Vector3.new(0, wallHeight/2, -CONFIG.ROOM_SIZE/2)},
		{size = Vector3.new(CONFIG.ROOM_SIZE, wallHeight, 1), pos = Vector3.new(0, wallHeight/2, CONFIG.ROOM_SIZE/2)},
		{size = Vector3.new(1, wallHeight, CONFIG.ROOM_SIZE), pos = Vector3.new(CONFIG.ROOM_SIZE/2, wallHeight/2, 0)},
		{size = Vector3.new(1, wallHeight, CONFIG.ROOM_SIZE), pos = Vector3.new(-CONFIG.ROOM_SIZE/2, wallHeight/2, 0)},
	}

	for i, wallData in ipairs(walls) do
		local wall = Instance.new("Part")
		wall.Name = "Wall" .. i
		wall.Size = wallData.size
		wall.Position = roomWorldPos + wallData.pos
		wall.Anchored = true
		wall.Material = Enum.Material.SmoothPlastic
		wall.Color = COLORS.WALL
		wall.Parent = roomFolder
	end

	-- Murs épais de séparation (bloquent la vue entre salles)
	local separationWallHeight = 40
	local separationWallThickness = 15

	-- Mur de séparation Nord (entre cette salle et celle au nord)
	local sepNorth = Instance.new("Part")
	sepNorth.Name = "SeparationNorth"
	sepNorth.Size = Vector3.new(CONFIG.ROOM_SIZE + separationWallThickness * 2, separationWallHeight, separationWallThickness)
	sepNorth.Position = roomWorldPos + Vector3.new(0, separationWallHeight/2, -(CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2)
	sepNorth.Anchored = true
	sepNorth.Material = Enum.Material.SmoothPlastic
	sepNorth.Color = Color3.fromRGB(50, 50, 60)
	sepNorth.Parent = roomFolder

	-- Mur de séparation Sud
	local sepSouth = Instance.new("Part")
	sepSouth.Name = "SeparationSouth"
	sepSouth.Size = Vector3.new(CONFIG.ROOM_SIZE + separationWallThickness * 2, separationWallHeight, separationWallThickness)
	sepSouth.Position = roomWorldPos + Vector3.new(0, separationWallHeight/2, (CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2)
	sepSouth.Anchored = true
	sepSouth.Material = Enum.Material.SmoothPlastic
	sepSouth.Color = Color3.fromRGB(50, 50, 60)
	sepSouth.Parent = roomFolder

	-- Mur de séparation Est
	local sepEast = Instance.new("Part")
	sepEast.Name = "SeparationEast"
	sepEast.Size = Vector3.new(separationWallThickness, separationWallHeight, CONFIG.ROOM_SIZE + separationWallThickness * 2)
	sepEast.Position = roomWorldPos + Vector3.new((CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2, separationWallHeight/2, 0)
	sepEast.Anchored = true
	sepEast.Material = Enum.Material.SmoothPlastic
	sepEast.Color = Color3.fromRGB(50, 50, 60)
	sepEast.Parent = roomFolder

	-- Mur de séparation Ouest
	local sepWest = Instance.new("Part")
	sepWest.Name = "SeparationWest"
	sepWest.Size = Vector3.new(separationWallThickness, separationWallHeight, CONFIG.ROOM_SIZE + separationWallThickness * 2)
	sepWest.Position = roomWorldPos + Vector3.new(-(CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2, separationWallHeight/2, 0)
	sepWest.Anchored = true
	sepWest.Material = Enum.Material.SmoothPlastic
	sepWest.Color = Color3.fromRGB(50, 50, 60)
	sepWest.Parent = roomFolder

	-- Coins décoratifs (piliers aux 4 coins)
	local cornerSize = Vector3.new(separationWallThickness, separationWallHeight + 5, separationWallThickness)
	local cornerPositions = {
		Vector3.new((CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2, (separationWallHeight + 5)/2, (CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2),
		Vector3.new(-(CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2, (separationWallHeight + 5)/2, (CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2),
		Vector3.new((CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2, (separationWallHeight + 5)/2, -(CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2),
		Vector3.new(-(CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2, (separationWallHeight + 5)/2, -(CONFIG.ROOM_SIZE + CONFIG.ROOM_SPACING)/2),
	}

	for i, cornerPos in ipairs(cornerPositions) do
		local pillar = Instance.new("Part")
		pillar.Name = "Pillar" .. i
		pillar.Size = cornerSize
		pillar.Position = roomWorldPos + cornerPos
		pillar.Anchored = true
		pillar.Material = Enum.Material.SmoothPlastic
		pillar.Color = Color3.fromRGB(40, 40, 50)
		pillar.Parent = roomFolder

		-- Sommet du pilier (pyramide)
		local top = Instance.new("Part")
		top.Name = "PillarTop" .. i
		top.Size = Vector3.new(separationWallThickness + 2, 4, separationWallThickness + 2)
		top.Position = roomWorldPos + cornerPos + Vector3.new(0, (separationWallHeight + 5)/2 + 2, 0)
		top.Anchored = true
		top.Material = Enum.Material.SmoothPlastic
		top.Color = Color3.fromRGB(60, 60, 70)
		top.Parent = roomFolder
	end

	-- Barrières invisibles hautes (au-dessus des murs pour empêcher de sauter par-dessus)
	local topBarrierHeight = 20
	local topBarriers = {
		{size = Vector3.new(CONFIG.ROOM_SIZE, topBarrierHeight, 2), pos = Vector3.new(0, separationWallHeight + topBarrierHeight/2, -CONFIG.ROOM_SIZE/2)},
		{size = Vector3.new(CONFIG.ROOM_SIZE, topBarrierHeight, 2), pos = Vector3.new(0, separationWallHeight + topBarrierHeight/2, CONFIG.ROOM_SIZE/2)},
		{size = Vector3.new(2, topBarrierHeight, CONFIG.ROOM_SIZE), pos = Vector3.new(CONFIG.ROOM_SIZE/2, separationWallHeight + topBarrierHeight/2, 0)},
		{size = Vector3.new(2, topBarrierHeight, CONFIG.ROOM_SIZE), pos = Vector3.new(-CONFIG.ROOM_SIZE/2, separationWallHeight + topBarrierHeight/2, 0)},
	}

	for i, barrierData in ipairs(topBarriers) do
		local barrier = Instance.new("Part")
		barrier.Name = "TopBarrier" .. i
		barrier.Size = barrierData.size
		barrier.Position = roomWorldPos + barrierData.pos
		barrier.Anchored = true
		barrier.Transparency = 1
		barrier.CanCollide = true
		barrier.Parent = roomFolder
	end

	if isEndRoom then
		-- Créer la zone de fin
		local endZone = Instance.new("Part")
		endZone.Name = "EndZone"
		endZone.Size = Vector3.new(15, 1, 15)
		endZone.Position = roomWorldPos + Vector3.new(0, 0.5, 0)
		endZone.Anchored = true
		endZone.Material = Enum.Material.SmoothPlastic
		endZone.Color = Color3.fromRGB(255, 220, 100)
		endZone.Parent = roomFolder

		-- Texte de fin
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.new(0, 300, 0, 100)
		billboardGui.StudsOffset = Vector3.new(0, 8, 0)
		billboardGui.Parent = endZone

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "🏆 ARRIVÉE 🏆"
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextSize = 36
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextStrokeTransparency = 0.5
		textLabel.Parent = billboardGui

		-- Détection du toucher pour terminer la partie
		endZone.Touched:Connect(function(hit)
			print("🔍 DEBUG: Zone Z touchée par:", hit.Name, "Parent:", hit.Parent and hit.Parent.Name or "nil")

			if gameState.gameEnded then
				print("⚠️ Round déjà terminé, ignoré")
				return
			end

			local character = hit.Parent
			local touchingPlayer = Players:GetPlayerFromCharacter(character)

			if touchingPlayer and character:FindFirstChild("Humanoid") then
				gameState.gameEnded = true
				print("🏆🏆🏆", touchingPlayer.Name, "a atteint l'arrivée! Fin du round!")
				print("🔄 Appel de endGameForAll...")
				endGameForAll(touchingPlayer)
			else
				print("❌ Pas un joueur valide (touchingPlayer:", touchingPlayer, ")")
			end
		end)

		print("🏆 Salle de fin créée à", x, y)
	else
		-- Générer des pièces (sauf salle de départ)
		if not isStartRoom then
			local numCoins = math.random(CONFIG.MIN_COINS_PER_ROOM, CONFIG.MAX_COINS_PER_ROOM)
			for i = 1, numCoins do
				local randomX = math.random(-CONFIG.ROOM_SIZE/2 + 10, CONFIG.ROOM_SIZE/2 - 10)
				local randomZ = math.random(-CONFIG.ROOM_SIZE/2 + 10, CONFIG.ROOM_SIZE/2 - 10)
				local coinPos = roomWorldPos + Vector3.new(randomX, 3, randomZ)
				createCoin(coinPos, roomFolder)
			end

			-- Générer des obstacles
			local numObstacles = math.random(CONFIG.MIN_OBSTACLES, CONFIG.MAX_OBSTACLES)
			for i = 1, numObstacles do
				local randomX = math.random(-CONFIG.ROOM_SIZE/2 + 10, CONFIG.ROOM_SIZE/2 - 10)
				local randomZ = math.random(-CONFIG.ROOM_SIZE/2 + 10, CONFIG.ROOM_SIZE/2 - 10)
				local obstaclePos = roomWorldPos + Vector3.new(randomX, 4, randomZ)
				createObstacle(obstaclePos, roomFolder)
			end
		end
	end

	-- Créer les portes selon la configuration
	if doorConfig then
		for direction, config in pairs(doorConfig) do
			if config.exists then
				createDoor(roomWorldPos, direction, config.active, config.targetX, config.targetY, roomFolder)
			end
		end
	end

	-- Sauvegarder dans la grille
	worldGrid[x][y] = {
		folder = roomFolder,
		x = x,
		y = y,
		isEndRoom = isEndRoom,
		isStartRoom = isStartRoom,
		doors = doorConfig or {}
	}

	return worldGrid[x][y]
end


-- Téléporter un joueur vers une salle
function teleportPlayerToRoom(player, x, y)
	if gameState.gameEnded then return end

	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Générer la salle si elle n'existe pas
	if not worldGrid[x][y] then
		-- Calculer quelles portes cette salle devrait avoir
		local doorConfig = generateDoorConfig(x, y)
		createRoomAt(x, y, doorConfig)
	end

	-- Téléporter le joueur (spawn à hauteur sécurisée)
	local roomWorldPos = gridToWorld(x, y)
	hrp.CFrame = CFrame.new(roomWorldPos + Vector3.new(0, 10, 0))

	-- Mettre à jour la position du joueur
	local oldPos = playerPositions[player.UserId]
	playerPositions[player.UserId] = {x = x, y = y}

	-- Incrémenter le compteur de salles si changement
	if oldPos and (oldPos.x ~= x or oldPos.y ~= y) then
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local rooms = leaderstats:FindFirstChild("Salles")
			if rooms then
				rooms.Value = rooms.Value + 1
			end
		end
	end

	print("📍", player.Name, "est maintenant à", x, y)
end

-- Générer la configuration des portes pour une salle
function generateDoorConfig(x, y)
	local config = {
		North = {exists = false, active = false, targetX = x, targetY = y - 1},
		South = {exists = false, active = false, targetX = x, targetY = y + 1},
		East = {exists = false, active = false, targetX = x + 1, targetY = y},
		West = {exists = false, active = false, targetX = x - 1, targetY = y},
	}

	-- Salle de fin = pas de portes
	if gameState.endPos and x == gameState.endPos.x and y == gameState.endPos.y then
		return config
	end

	-- Toujours une porte vers l'arrivée (chemin principal)
	if not gameState.endPos then return config end

	local dx = gameState.endPos.x - x
	local dy = gameState.endPos.y - y

	-- Priorité: se rapprocher de Z
	if math.abs(dx) > math.abs(dy) then
		-- Aller vers Est ou Ouest
		if dx > 0 and x + 1 < CONFIG.GRID_SIZE then
			config.East.exists = true
			config.East.active = true
		elseif dx < 0 and x - 1 >= 0 then
			config.West.exists = true
			config.West.active = true
		end
	else
		-- Aller vers Nord ou Sud
		if dy > 0 and y + 1 < CONFIG.GRID_SIZE then
			config.South.exists = true
			config.South.active = true
		elseif dy < 0 and y - 1 >= 0 then
			config.North.exists = true
			config.North.active = true
		end
	end

	-- Ajouter 1-2 portes supplémentaires (exploration alternative)
	local numExtraDoors = math.random(1, 2)
	local directions = {"North", "South", "East", "West"}

	for i = 1, numExtraDoors do
		local randomDir = directions[math.random(1, #directions)]
		local doorData = config[randomDir]

		-- Vérifier que la cible est dans la grille
		if doorData.targetX >= 0 and doorData.targetX < CONFIG.GRID_SIZE and
		   doorData.targetY >= 0 and doorData.targetY < CONFIG.GRID_SIZE then
			doorData.exists = true
			doorData.active = true
		end
	end

	return config
end

-- Générer le chemin principal O → Z
local function generateMainPath()
	print("🗺️ Génération du chemin principal...")

	-- Choisir une position pour Z à au moins 10 salles de distance
	local attempts = 0
	repeat
		endPos = {
			x = math.random(0, CONFIG.GRID_SIZE - 1),
			y = math.random(0, CONFIG.GRID_SIZE - 1)
		}
		local distance = math.abs(endPos.x - startPos.x) + math.abs(endPos.y - startPos.y)
		attempts = attempts + 1
	until distance >= CONFIG.MIN_PATH_LENGTH or attempts > 100

	print("📍 Départ O:", startPos.x, startPos.y)
	print("📍 Arrivée Z:", endPos.x, endPos.y)
	print("📏 Distance:", math.abs(endPos.x - startPos.x) + math.abs(endPos.y - startPos.y))

	-- Créer la salle de départ
	local startDoorConfig = generateDoorConfig(startPos.x, startPos.y)
	createRoomAt(startPos.x, startPos.y, startDoorConfig)

	-- Créer la salle d'arrivée
	createRoomAt(endPos.x, endPos.y, {})

	print("✅ Chemin principal généré")
end

-- Configuration de l'éclairage
local function setupLighting()
	local lighting = game:GetService("Lighting")
	lighting.Brightness = 1.5
	lighting.Ambient = Color3.fromRGB(70, 80, 100)
	lighting.OutdoorAmbient = Color3.fromRGB(100, 120, 140)
	lighting.GlobalShadows = true
	lighting.ClockTime = 14
	lighting.GeographicLatitude = 45
	lighting.ShadowSoftness = 0.2

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.2
	bloom.Size = 15
	bloom.Threshold = 0.8
	bloom.Parent = lighting

	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Brightness = 0
	colorCorrection.Contrast = 0.1
	colorCorrection.Saturation = 0.2
	colorCorrection.Parent = lighting

	print("✅ Éclairage configuré")
end

-- Quand un joueur rejoint
Players.PlayerAdded:Connect(function(player)
	setupLeaderboard(player)

	-- Vérifier si admin
	if AdminCommands.isAdmin(player) then
		print("👑 ADMIN connecté:", player.Name)
		-- Message de bienvenue admin
		task.wait(2)
		player:SetAttribute("IsAdmin", true)
	end

	-- Écouter les commandes (via le chat)
	player.Chatted:Connect(function(message)
		if message:sub(1, 1) == "/" then
			print("💬", player.Name, ":", message)

			-- Utiliser le gameState global pour les commandes (ajout de fonctions supplémentaires)
			local cmdGameState = {
				CONFIG = CONFIG,
				worldGrid = worldGrid,
				playerPositions = playerPositions,
				startPos = gameState.startPos,
				endPos = gameState.endPos,
				gameEnded = gameState.gameEnded,
				teleportPlayerToRoom = teleportPlayerToRoom,
				endGameForAll = endGameForAll,
				compassEvent = compassEvent,
			}

			local success, result = AdminCommands.executeCommand(player, message, cmdGameState)
			if success then
				print("✅", result)
			else
				print("❌", result)
				warn(player.Name .. " - " .. result)
			end
		end
	end)

	player.CharacterAdded:Connect(function(character)
		task.wait(1) -- Attendre que le personnage soit complètement chargé
		teleportPlayerToRoom(player, startPos.x, startPos.y)
	end)
end)

-- Quand un joueur part
Players.PlayerRemoving:Connect(function(player)
	playerPositions[player.UserId] = nil
end)

-- Initialiser
setupLighting()

-- NE PAS générer le chemin principal ici, le RoundManager s'en charge
-- generateMainPath()

-- Ajouter les fonctions et dépendances au gameState pour le RoundManager
gameState.CONFIG = CONFIG
gameState.worldGrid = worldGrid
gameState.playerPositions = playerPositions
gameState.teleportPlayerToRoom = teleportPlayerToRoom
gameState.createRoomAt = createRoomAt
gameState.generateDoorConfig = generateDoorConfig
gameState.gameEndedEvent = gameEndedEvent
gameState.roundStateEvent = roundStateEvent

-- Démarrer le système de rounds
RoundManager.initialize(gameState)

print("✅ === SERVEUR PRÊT ===")
print("🎮 Système de rounds actif!")
print("🗺️ Monde partagé persistant entre tous les joueurs!")
