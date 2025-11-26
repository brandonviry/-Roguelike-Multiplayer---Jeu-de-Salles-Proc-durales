--[[
	RoomFactory
	Fabrique de salles complètes
	Responsable de créer toute la structure d'une salle
]]

local ServerConfig = require(script.Parent.Parent.Config.ServerConfig)

local RoomFactory = {}

-- Initialiser la factory
function RoomFactory:Init(gridService, entityFactory)
	self.gridService = gridService
	self.entityFactory = entityFactory
	print("🏗️ RoomFactory initialisé")
	return self
end

-- Créer une salle complète à une position donnée
function RoomFactory:CreateRoom(x, y, doorConfig, teleportCallback)
	-- Vérifier si la salle existe déjà
	if self.gridService:RoomExists(x, y) then
		print("⚠️ Salle", x, y, "existe déjà")
		return self.gridService:GetRoom(x, y)
	end

	print("🔨 Création salle à", x, y)

	local roomWorldPos = self.gridService:GridToWorld(x, y)
	local isEndRoom = self.gridService:IsEndRoom(x, y)
	local isStartRoom = self.gridService:IsStartRoom(x, y)

	-- Créer le dossier de la salle
	local roomFolder = Instance.new("Folder")
	roomFolder.Name = "Room_" .. x .. "_" .. y
	roomFolder.Parent = workspace

	-- Créer les composants de la salle
	self:CreateFloor(roomFolder, roomWorldPos, isStartRoom, isEndRoom)
	self:CreateDecorationWalls(roomFolder, roomWorldPos)
	self:CreateSeparationWalls(roomFolder, roomWorldPos)
	self:CreatePillars(roomFolder, roomWorldPos)
	self:CreateTopBarriers(roomFolder, roomWorldPos)

	-- Contenu de la salle
	if isEndRoom then
		self:CreateEndZone(roomFolder, roomWorldPos)
	elseif not isStartRoom then
		-- Générer pièces et obstacles (pas dans les salles spéciales)
		self:PopulateRoom(roomFolder, roomWorldPos)
	end

	-- Créer les portes
	if doorConfig then
		for direction, config in pairs(doorConfig) do
			if config.exists then
				self.entityFactory:CreateDoor(
					roomWorldPos,
					direction,
					config.active,
					config.targetX,
					config.targetY,
					roomFolder,
					teleportCallback
				)
			end
		end
	end

	-- Sauvegarder la salle dans la grille
	local roomData = {
		folder = roomFolder,
		x = x,
		y = y,
		isEndRoom = isEndRoom,
		isStartRoom = isStartRoom,
		doors = doorConfig or {}
	}

	self.gridService:SetRoom(x, y, roomData)
	return roomData
end

-- Créer le sol de la salle
function RoomFactory:CreateFloor(roomFolder, roomWorldPos, isStartRoom, isEndRoom)
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(ServerConfig.Grid.ROOM_SIZE, 2, ServerConfig.Grid.ROOM_SIZE)
	floor.Position = roomWorldPos + Vector3.new(0, -1, 0)
	floor.Anchored = true
	floor.Material = Enum.Material.SmoothPlastic

	if isEndRoom then
		floor.Color = ServerConfig.Colors.END_ZONE
	elseif isStartRoom then
		floor.Color = ServerConfig.Colors.START_ZONE
	else
		floor.Color = ServerConfig.Colors.FLOOR
	end

	floor.Parent = roomFolder
end

-- Créer les petits murs décoratifs
function RoomFactory:CreateDecorationWalls(roomFolder, roomWorldPos)
	local wallHeight = ServerConfig.Walls.SMALL_WALL_HEIGHT
	local roomSize = ServerConfig.Grid.ROOM_SIZE

	local walls = {
		{size = Vector3.new(roomSize, wallHeight, 1), pos = Vector3.new(0, wallHeight/2, -roomSize/2)},
		{size = Vector3.new(roomSize, wallHeight, 1), pos = Vector3.new(0, wallHeight/2, roomSize/2)},
		{size = Vector3.new(1, wallHeight, roomSize), pos = Vector3.new(roomSize/2, wallHeight/2, 0)},
		{size = Vector3.new(1, wallHeight, roomSize), pos = Vector3.new(-roomSize/2, wallHeight/2, 0)},
	}

	for i, wallData in ipairs(walls) do
		local wall = Instance.new("Part")
		wall.Name = "Wall" .. i
		wall.Size = wallData.size
		wall.Position = roomWorldPos + wallData.pos
		wall.Anchored = true
		wall.Material = Enum.Material.SmoothPlastic
		wall.Color = ServerConfig.Colors.WALL
		wall.Parent = roomFolder
	end
end

-- Créer les murs épais de séparation
function RoomFactory:CreateSeparationWalls(roomFolder, roomWorldPos)
	local wallHeight = ServerConfig.Walls.HEIGHT
	local thickness = ServerConfig.Walls.THICKNESS
	local roomSize = ServerConfig.Grid.ROOM_SIZE
	local spacing = ServerConfig.Grid.ROOM_SPACING

	local separationWalls = {
		{
			name = "SeparationNorth",
			size = Vector3.new(roomSize + thickness * 2, wallHeight, thickness),
			pos = Vector3.new(0, wallHeight/2, -(roomSize + spacing)/2)
		},
		{
			name = "SeparationSouth",
			size = Vector3.new(roomSize + thickness * 2, wallHeight, thickness),
			pos = Vector3.new(0, wallHeight/2, (roomSize + spacing)/2)
		},
		{
			name = "SeparationEast",
			size = Vector3.new(thickness, wallHeight, roomSize + thickness * 2),
			pos = Vector3.new((roomSize + spacing)/2, wallHeight/2, 0)
		},
		{
			name = "SeparationWest",
			size = Vector3.new(thickness, wallHeight, roomSize + thickness * 2),
			pos = Vector3.new(-(roomSize + spacing)/2, wallHeight/2, 0)
		},
	}

	for _, wallData in ipairs(separationWalls) do
		local wall = Instance.new("Part")
		wall.Name = wallData.name
		wall.Size = wallData.size
		wall.Position = roomWorldPos + wallData.pos
		wall.Anchored = true
		wall.Material = Enum.Material.SmoothPlastic
		wall.Color = ServerConfig.Colors.SEPARATION_WALL
		wall.Parent = roomFolder
	end
end

-- Créer les piliers aux coins
function RoomFactory:CreatePillars(roomFolder, roomWorldPos)
	local wallHeight = ServerConfig.Walls.HEIGHT
	local thickness = ServerConfig.Walls.THICKNESS
	local roomSize = ServerConfig.Grid.ROOM_SIZE
	local spacing = ServerConfig.Grid.ROOM_SPACING

	local cornerSize = Vector3.new(thickness, wallHeight + 5, thickness)
	local cornerPositions = {
		Vector3.new((roomSize + spacing)/2, (wallHeight + 5)/2, (roomSize + spacing)/2),
		Vector3.new(-(roomSize + spacing)/2, (wallHeight + 5)/2, (roomSize + spacing)/2),
		Vector3.new((roomSize + spacing)/2, (wallHeight + 5)/2, -(roomSize + spacing)/2),
		Vector3.new(-(roomSize + spacing)/2, (wallHeight + 5)/2, -(roomSize + spacing)/2),
	}

	for i, cornerPos in ipairs(cornerPositions) do
		-- Pilier principal
		local pillar = Instance.new("Part")
		pillar.Name = "Pillar" .. i
		pillar.Size = cornerSize
		pillar.Position = roomWorldPos + cornerPos
		pillar.Anchored = true
		pillar.Material = Enum.Material.SmoothPlastic
		pillar.Color = ServerConfig.Colors.PILLAR
		pillar.Parent = roomFolder

		-- Sommet du pilier
		local top = Instance.new("Part")
		top.Name = "PillarTop" .. i
		top.Size = Vector3.new(thickness + 2, 4, thickness + 2)
		top.Position = roomWorldPos + cornerPos + Vector3.new(0, (wallHeight + 5)/2 + 2, 0)
		top.Anchored = true
		top.Material = Enum.Material.SmoothPlastic
		top.Color = ServerConfig.Colors.PILLAR_TOP
		top.Parent = roomFolder
	end
end

-- Créer les barrières invisibles en hauteur
function RoomFactory:CreateTopBarriers(roomFolder, roomWorldPos)
	local barrierHeight = ServerConfig.Walls.TOP_BARRIER_HEIGHT
	local roomSize = ServerConfig.Grid.ROOM_SIZE

	-- Barrières qui vont du sol jusqu'au ciel (empêchent de sauter par-dessus)
	local topBarriers = {
		{size = Vector3.new(roomSize, barrierHeight, 2), pos = Vector3.new(0, barrierHeight/2, -roomSize/2)},
		{size = Vector3.new(roomSize, barrierHeight, 2), pos = Vector3.new(0, barrierHeight/2, roomSize/2)},
		{size = Vector3.new(2, barrierHeight, roomSize), pos = Vector3.new(roomSize/2, barrierHeight/2, 0)},
		{size = Vector3.new(2, barrierHeight, roomSize), pos = Vector3.new(-roomSize/2, barrierHeight/2, 0)},
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
end

-- Créer la zone d'arrivée (salle Z)
function RoomFactory:CreateEndZone(roomFolder, roomWorldPos)
	local Players = game:GetService("Players")

	local endZone = Instance.new("Part")
	endZone.Name = "EndZone"
	endZone.Size = Vector3.new(15, 1, 15)
	endZone.Position = roomWorldPos + Vector3.new(0, 0.5, 0)
	endZone.Anchored = true
	endZone.Material = Enum.Material.SmoothPlastic
	endZone.Color = Color3.fromRGB(255, 220, 100)
	endZone.Parent = roomFolder

	-- Billboard texte
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

	print("🏆 Salle de fin créée avec zone de trigger")
end

-- Peupler une salle (pièces + obstacles)
function RoomFactory:PopulateRoom(roomFolder, roomWorldPos)
	local roomSize = ServerConfig.Grid.ROOM_SIZE

	-- Générer des pièces
	local numCoins = math.random(
		ServerConfig.Gameplay.MIN_COINS_PER_ROOM,
		ServerConfig.Gameplay.MAX_COINS_PER_ROOM
	)

	for i = 1, numCoins do
		local randomX = math.random(-roomSize/2 + 10, roomSize/2 - 10)
		local randomZ = math.random(-roomSize/2 + 10, roomSize/2 - 10)
		local coinPos = roomWorldPos + Vector3.new(randomX, 3, randomZ)
		self.entityFactory:CreateCoin(coinPos, roomFolder)
	end

	-- Générer des obstacles
	local numObstacles = math.random(
		ServerConfig.Gameplay.MIN_OBSTACLES,
		ServerConfig.Gameplay.MAX_OBSTACLES
	)

	for i = 1, numObstacles do
		local randomX = math.random(-roomSize/2 + 10, roomSize/2 - 10)
		local randomZ = math.random(-roomSize/2 + 10, roomSize/2 - 10)
		local obstaclePos = roomWorldPos + Vector3.new(randomX, 4, randomZ)
		self.entityFactory:CreateObstacle(obstaclePos, roomFolder)
	end
end

return RoomFactory
