--[[
	GridService
	Gestion de la grille 12x12 du monde
	Responsable de :
	- Stockage de la grille
	- Positions des joueurs
	- Conversion coordonnées grille <-> monde
]]

local ServerConfig = require(script.Parent.Parent.Config.ServerConfig)

local GridService = {}

-- Initialiser le service
function GridService:Init()
	print("🗺️ Initialisation GridService...")

	-- Créer la grille vide
	self.worldGrid = {}
	for x = 0, ServerConfig.Grid.SIZE - 1 do
		self.worldGrid[x] = {}
		for y = 0, ServerConfig.Grid.SIZE - 1 do
			self.worldGrid[x][y] = nil
		end
	end

	-- Positions des joueurs
	self.playerPositions = {}

	-- Positions spéciales
	self.startPos = {x = 6, y = 6} -- Centre de la grille
	self.endPos = nil -- Sera défini par round

	print("✅ GridService initialisé - Grille " .. ServerConfig.Grid.SIZE .. "x" .. ServerConfig.Grid.SIZE)
	return self
end

-- Convertir coordonnées grille → position 3D monde
function GridService:GridToWorld(x, y)
	local offset = ServerConfig.Grid.ROOM_SIZE + ServerConfig.Grid.ROOM_SPACING
	return Vector3.new(
		(x - self.startPos.x) * offset,
		0,
		(y - self.startPos.y) * offset
	)
end

-- Vérifier si une salle existe
function GridService:RoomExists(x, y)
	return self.worldGrid[x] and self.worldGrid[x][y] ~= nil
end

-- Récupérer une salle
function GridService:GetRoom(x, y)
	if not self:RoomExists(x, y) then
		return nil
	end
	return self.worldGrid[x][y]
end

-- Enregistrer une salle
function GridService:SetRoom(x, y, roomData)
	self.worldGrid[x][y] = roomData
end

-- Détruire toutes les salles (reset du round)
function GridService:ClearAllRooms()
	print("🗑️ Nettoyage de la grille...")
	local count = 0

	for x = 0, ServerConfig.Grid.SIZE - 1 do
		for y = 0, ServerConfig.Grid.SIZE - 1 do
			if self.worldGrid[x][y] then
				local room = self.worldGrid[x][y]
				if room.folder then
					room.folder:Destroy()
					count = count + 1
				end
				self.worldGrid[x][y] = nil
			end
		end
	end

	print("✅ " .. count .. " salles détruites")
end

-- Générer une nouvelle position pour l'arrivée (Z)
function GridService:GenerateNewEndPosition()
	local attempts = 0
	local newEndPos

	repeat
		newEndPos = {
			x = math.random(0, ServerConfig.Grid.SIZE - 1),
			y = math.random(0, ServerConfig.Grid.SIZE - 1)
		}

		local distance = math.abs(newEndPos.x - self.startPos.x) +
		                 math.abs(newEndPos.y - self.startPos.y)
		attempts = attempts + 1

		-- Distance minimale respectée ou trop de tentatives
		if distance >= ServerConfig.Grid.MIN_PATH_LENGTH or attempts > 100 then
			break
		end
	until false

	self.endPos = newEndPos
	print("📍 Nouvelle arrivée Z générée:", self.endPos.x, self.endPos.y)
	return self.endPos
end

-- Mettre à jour la position d'un joueur
function GridService:UpdatePlayerPosition(userId, x, y)
	local oldPos = self.playerPositions[userId]
	self.playerPositions[userId] = {x = x, y = y}

	-- Retourner true si le joueur a changé de salle
	if oldPos then
		return (oldPos.x ~= x or oldPos.y ~= y)
	end
	return false
end

-- Récupérer la position d'un joueur
function GridService:GetPlayerPosition(userId)
	return self.playerPositions[userId]
end

-- Supprimer la position d'un joueur
function GridService:RemovePlayerPosition(userId)
	self.playerPositions[userId] = nil
end

-- Vérifier si une position est valide dans la grille
function GridService:IsValidPosition(x, y)
	return x >= 0 and x < ServerConfig.Grid.SIZE and
	       y >= 0 and y < ServerConfig.Grid.SIZE
end

-- Vérifier si une position est la salle de départ
function GridService:IsStartRoom(x, y)
	return x == self.startPos.x and y == self.startPos.y
end

-- Vérifier si une position est la salle d'arrivée
function GridService:IsEndRoom(x, y)
	return self.endPos and (x == self.endPos.x and y == self.endPos.y)
end

-- Obtenir les statistiques de la grille
function GridService:GetStats()
	local totalRooms = 0
	for x = 0, ServerConfig.Grid.SIZE - 1 do
		for y = 0, ServerConfig.Grid.SIZE - 1 do
			if self.worldGrid[x][y] then
				totalRooms = totalRooms + 1
			end
		end
	end

	return {
		gridSize = ServerConfig.Grid.SIZE,
		totalPossibleRooms = ServerConfig.Grid.SIZE * ServerConfig.Grid.SIZE,
		generatedRooms = totalRooms,
		startPos = self.startPos,
		endPos = self.endPos,
	}
end

return GridService
