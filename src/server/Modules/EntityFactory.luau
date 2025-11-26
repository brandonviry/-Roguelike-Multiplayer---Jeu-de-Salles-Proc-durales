--[[
	EntityFactory
	Fabrique d'entités : pièces, obstacles, portes
	Responsable de créer tous les objets du jeu
]]

local Players = game:GetService("Players")
local ServerConfig = require(script.Parent.Parent.Config.ServerConfig)

local EntityFactory = {}

-- Initialiser la factory
function EntityFactory:Init(remoteService, playerManager)
	self.remoteService = remoteService
	self.playerManager = playerManager
	print("🏭 EntityFactory initialisé")
	return self
end

--[[
	CRÉATION DES PIÈCES (COINS)
]]

-- Créer une étoile 3D (pièce collectible)
function EntityFactory:CreateCoin(position, parentRoom)
	local starModel = Instance.new("Model")
	starModel.Name = "Coin"

	local color = ServerConfig.CoinColors[math.random(1, #ServerConfig.CoinColors)]

	-- Centre de l'étoile
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

	-- Créer les 6 pointes de l'étoile
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

	-- Effet de highlight
	local highlight = Instance.new("Highlight")
	highlight.FillColor = color
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0.9
	highlight.Parent = starModel

	-- Zone de trigger invisible pour la collecte (plus large que le centre)
	local trigger = Instance.new("Part")
	trigger.Name = "Trigger"
	trigger.Size = Vector3.new(6, 6, 6) -- Zone de collecte plus grande
	trigger.Position = position
	trigger.Anchored = true
	trigger.Transparency = 1
	trigger.CanCollide = false
	trigger.Parent = starModel

	-- Détection de toucher pour la collecte automatique
	local debounce = {}
	local collected = false

	trigger.Touched:Connect(function(hit)
		if collected then return end

		-- Trouver le character (peut être hit.Parent ou hit.Parent.Parent pour les accessoires)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)

		-- Si pas trouvé, peut-être que hit est un accessoire (ex: cheveux)
		if not player and character and character.Parent then
			character = character.Parent
			player = Players:GetPlayerFromCharacter(character)
		end

		-- Vérifier que c'est bien un joueur avec un Humanoid
		if player and character and character:FindFirstChild("Humanoid") then
			-- Vérifier le debounce pour éviter la double collecte
			if debounce[player.UserId] then return end
			debounce[player.UserId] = true

			-- Marquer comme collecté immédiatement
			collected = true

			-- Ajouter les pièces au joueur
			print("🔍 Tentative d'ajout de", ServerConfig.Gameplay.COIN_VALUE, "coins pour", player.Name)
			print("🔍 Leaderstats existe?", player:FindFirstChild("leaderstats") ~= nil)

			if self.playerManager:AddCoins(player, ServerConfig.Gameplay.COIN_VALUE) then
				self.remoteService:FireClient("CoinCollected", player, ServerConfig.Gameplay.COIN_VALUE, color)
				print("💰", player.Name, "a collecté une étoile (+", ServerConfig.Gameplay.COIN_VALUE, "coins)!")
				starModel:Destroy()
			else
				warn("❌ Échec de l'ajout de pièces pour", player.Name)
				warn("❌ Le joueur n'a pas de leaderstats! Création manuelle...")

				-- Debug: vérifier que playerManager existe
				print("🔍 self.playerManager existe?", self.playerManager ~= nil)
				print("🔍 Type de playerManager:", type(self.playerManager))
				print("🔍 CreateLeaderboard existe?", self.playerManager and self.playerManager.CreateLeaderboard ~= nil)

				-- Créer le leaderstats s'il n'existe pas
				if self.playerManager and self.playerManager.CreateLeaderboard then
					print("🔧 Appel de CreateLeaderboard...")
					local success, err = pcall(function()
						self.playerManager:CreateLeaderboard(player)
					end)
					if success then
						print("✅ CreateLeaderboard réussi")
					else
						warn("❌ Erreur dans CreateLeaderboard:", err)
					end
				else
					warn("❌ playerManager ou CreateLeaderboard n'existe pas!")
				end

				-- Attendre un frame pour que l'objet soit réellement créé
				task.wait()

				-- Réessayer
				if self.playerManager:AddCoins(player, ServerConfig.Gameplay.COIN_VALUE) then
					self.remoteService:FireClient("CoinCollected", player, ServerConfig.Gameplay.COIN_VALUE, color)
					print("💰", player.Name, "a collecté une étoile (+", ServerConfig.Gameplay.COIN_VALUE, "coins)!")
					starModel:Destroy()
				else
					warn("❌ Échec même après création du leaderstats!")
					collected = false -- Permettre une nouvelle tentative
				end
			end

			-- Reset debounce après un délai
			task.delay(0.5, function()
				debounce[player.UserId] = false
			end)
		end
	end)

	starModel.Parent = parentRoom

	-- Animation de rotation et flottement
	self:AnimateCoin(starModel, center, position)

	return starModel
end

-- Animer une pièce (rotation + flottement)
function EntityFactory:AnimateCoin(starModel, center, originalPosition)
	task.spawn(function()
		local rotation = 0
		local time = 0

		while starModel.Parent do
			rotation = rotation + 2
			time = time + 0.05

			center.Orientation = Vector3.new(0, rotation, 0)

			-- Rotation des pointes autour du centre
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

			-- Flottement vertical
			local floatOffset = math.sin(time * 2) * 0.5
			center.Position = originalPosition + Vector3.new(0, floatOffset, 0)

			task.wait(0.03)
		end
	end)
end

--[[
	CRÉATION DES OBSTACLES
]]

-- Créer un obstacle aléatoire
function EntityFactory:CreateObstacle(position, parentRoom)
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
	obstacle.Color = ServerConfig.Colors.OBSTACLE
	obstacle.Parent = parentRoom

	return obstacle
end

--[[
	CRÉATION DES PORTES
]]

-- Créer une porte dans une direction donnée
function EntityFactory:CreateDoor(roomWorldPos, direction, isActive, targetX, targetY, roomFolder, teleportCallback)
	local doorModel = Instance.new("Model")
	doorModel.Name = "Door_" .. direction

	-- Positions et orientations selon la direction
	local doorPositions = {
		North = {Vector3.new(0, 5, -ServerConfig.Grid.ROOM_SIZE/2), Vector3.new(0, 0, 0)},
		South = {Vector3.new(0, 5, ServerConfig.Grid.ROOM_SIZE/2), Vector3.new(0, 180, 0)},
		East = {Vector3.new(ServerConfig.Grid.ROOM_SIZE/2, 5, 0), Vector3.new(0, 90, 0)},
		West = {Vector3.new(-ServerConfig.Grid.ROOM_SIZE/2, 5, 0), Vector3.new(0, -90, 0)},
	}

	local relPos = doorPositions[direction][1]
	local orientation = doorPositions[direction][2]
	local position = roomWorldPos + relPos

	-- Cadre de la porte
	local frame = Instance.new("Part")
	frame.Name = "Frame"
	frame.Size = ServerConfig.Gameplay.DOOR_SIZE
	frame.Position = position
	frame.Orientation = orientation
	frame.Anchored = true
	frame.Material = Enum.Material.SmoothPlastic
	frame.Color = isActive and ServerConfig.Colors.DOOR_ACTIVE or ServerConfig.Colors.DOOR_INACTIVE
	frame.Transparency = isActive and 0.3 or 0.7
	frame.CanCollide = not isActive
	frame.Parent = doorModel

	-- Si la porte est active, créer la zone de téléportation
	if isActive then
		self:CreateDoorTrigger(doorModel, position, orientation, direction, targetX, targetY, teleportCallback)

		-- Effet lumineux
		local glow = Instance.new("PointLight")
		glow.Brightness = 2
		glow.Range = 20
		glow.Color = ServerConfig.Colors.DOOR_ACTIVE
		glow.Parent = frame
	end

	doorModel.Parent = roomFolder
	return doorModel
end

-- Créer la zone de trigger pour une porte
function EntityFactory:CreateDoorTrigger(doorModel, position, orientation, direction, targetX, targetY, teleportCallback)
	local trigger = Instance.new("Part")
	trigger.Name = "Trigger"
	trigger.Size = Vector3.new(ServerConfig.Gameplay.DOOR_SIZE.X, ServerConfig.Gameplay.DOOR_SIZE.Y, 4)
	trigger.Position = position
	trigger.Orientation = orientation
	trigger.Anchored = true
	trigger.Transparency = 1
	trigger.CanCollide = false
	trigger.Parent = doorModel

	-- Debounce pour éviter les triggers multiples
	local debounce = {}

	trigger.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)

		if player and character:FindFirstChild("HumanoidRootPart") then
			if debounce[player.UserId] then return end
			debounce[player.UserId] = true

			print("🚪", player.Name, "passe par la porte", direction, "vers", targetX, targetY)

			-- Son de téléportation
			self.remoteService:FireClient("DoorTeleport", player)

			-- Téléporter le joueur
			if teleportCallback then
				teleportCallback(player, targetX, targetY)
			end

			task.wait(2)
			debounce[player.UserId] = false
		end
	end)
end

return EntityFactory
