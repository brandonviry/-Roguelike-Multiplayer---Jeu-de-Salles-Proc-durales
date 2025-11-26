--[[
	WorldManager
	Orchestrateur principal du monde de jeu
	Coordonne toutes les interactions entre les modules
]]

local Players = game:GetService("Players")
local ServerConfig = require(script.Parent.Parent.Config.ServerConfig)

local WorldManager = {}

-- Initialiser le WorldManager avec toutes ses dépendances
function WorldManager:Init(dependencies)
	print("🌍 Initialisation WorldManager...")

	-- Injecter les dépendances
	self.gridService = dependencies.gridService
	self.remoteService = dependencies.remoteService
	self.playerManager = dependencies.playerManager
	self.roomFactory = dependencies.roomFactory
	self.pathfindingService = dependencies.pathfindingService

	-- État du jeu
	self.gameEnded = false

	print("✅ WorldManager initialisé")
	return self
end

-- Téléporter un joueur vers une salle
function WorldManager:TeleportPlayerToRoom(player, x, y)
	if self.gameEnded then
		print("⚠️ Jeu terminé, téléportation annulée")
		return
	end

	local character = player.Character
	if not character then
		warn("⚠️ Character introuvable pour", player.Name)
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		warn("⚠️ HumanoidRootPart introuvable pour", player.Name)
		return
	end

	-- Créer la salle si elle n'existe pas
	if not self.gridService:RoomExists(x, y) then
		local doorConfig = self.pathfindingService:GenerateDoorConfig(x, y)
		self.roomFactory:CreateRoom(x, y, doorConfig, function(p, tx, ty)
			self:TeleportPlayerToRoom(p, tx, ty)
		end)
	end

	-- Téléporter le joueur
	local roomWorldPos = self.gridService:GridToWorld(x, y)
	hrp.CFrame = CFrame.new(roomWorldPos + Vector3.new(0, 10, 0))

	-- Mettre à jour la position
	local hasChangedRoom = self.gridService:UpdatePlayerPosition(player.UserId, x, y)

	-- Incrémenter le compteur de salles visitées
	if hasChangedRoom then
		self.playerManager:IncrementRoomsVisited(player)
	end

	print("📍", player.Name, "téléporté à la salle", x, y)
end

-- Terminer la partie pour tous les joueurs
-- NOTE: Cette méthode est interceptée par le hook dans init.server.luau
-- et redirigée vers RoundManager:EndRound()
function WorldManager:EndGame(winner)
	print("🎯 WorldManager:EndGame appelé (normalement intercepté par hook)")
	print("🎯 Winner:", winner and winner.Name or "nil")

	if self.gameEnded then
		print("⚠️ Partie déjà terminée")
		return
	end

	print("🏆 === FIN DE PARTIE ===")
	print("🏆 Gagnant:", winner.Name)

	self.gameEnded = true

	-- Le reste de la logique est géré par RoundManager via le hook
	warn("⚠️ WorldManager:EndGame appelé directement sans hook! Cela ne devrait pas arriver.")
end

-- Créer la zone de fin avec détection de toucher
function WorldManager:SetupEndZoneDetection(endZone, x, y)
	print("🎯 Configuration détection EndZone pour salle", x, y)
	print("🎯 EndZone part:", endZone:GetFullName())

	endZone.Touched:Connect(function(hit)
		print("👆 EndZone touchée par:", hit:GetFullName())

		if self.gameEnded then
			print("⚠️ Jeu déjà terminé, ignoré")
			return
		end

		local character = hit.Parent
		local touchingPlayer = Players:GetPlayerFromCharacter(character)

		if touchingPlayer and character:FindFirstChild("Humanoid") then
			print("🏆 " .. touchingPlayer.Name .. " a atteint l'arrivée!")
			print("🏆 Appel de EndGame...")
			-- Le RoundManager s'occupera de la fin de partie
			self:EndGame(touchingPlayer)
		else
			print("⚠️ Touch non valide - pas un joueur ou pas d'humanoid")
		end
	end)

	print("✅ .Touched event connecté avec succès")
end

-- Réinitialiser le monde pour un nouveau round
function WorldManager:ResetWorld()
	print("🔄 Reset du monde...")

	-- Clear la grille
	self.gridService:ClearAllRooms()

	-- Générer nouvelle position Z
	self.gridService:GenerateNewEndPosition()

	-- Reset le flag de fin
	self.gameEnded = false

	-- Reset les joueurs
	self.playerManager:ResetAllPlayers()

	print("✅ Monde réinitialisé")
end

-- Créer les salles de départ et d'arrivée
function WorldManager:CreateMainRooms()
	print("🏗️ Création des salles principales...")

	local startPos = self.gridService.startPos
	local endPos = self.gridService.endPos

	-- Salle de départ (O)
	local startDoorConfig = self.pathfindingService:GenerateDoorConfig(startPos.x, startPos.y)
	self.roomFactory:CreateRoom(startPos.x, startPos.y, startDoorConfig, function(p, tx, ty)
		self:TeleportPlayerToRoom(p, tx, ty)
	end)

	-- Salle d'arrivée (Z)
	self.roomFactory:CreateRoom(endPos.x, endPos.y, {}, nil)

	-- Setup la détection de fin sur la zone Z
	print("🔍 Recherche de la zone de fin...")
	local endRoom = self.gridService:GetRoom(endPos.x, endPos.y)
	if endRoom and endRoom.folder then
		print("✅ Dossier de salle Z trouvé:", endRoom.folder:GetFullName())
		local endZone = endRoom.folder:FindFirstChild("EndZone")
		if endZone then
			print("✅ EndZone trouvée! Configuration de la détection...")
			self:SetupEndZoneDetection(endZone, endPos.x, endPos.y)
			print("✅ Détection EndZone configurée avec succès")
		else
			warn("❌ EndZone non trouvée dans le dossier!")
		end
	else
		warn("❌ Dossier de salle Z non trouvé!")
	end

	print("✅ Salles principales créées")
end

-- Téléporter tous les joueurs au spawn
function WorldManager:TeleportAllPlayersToStart()
	print("🚀 Téléportation de tous les joueurs au spawn...")

	task.wait(2) -- Attendre que les salles soient prêtes

	for _, player in ipairs(Players:GetPlayers()) do
		self:TeleportPlayerToRoom(player, self.gridService.startPos.x, self.gridService.startPos.y)
	end

	print("✅ Tous les joueurs téléportés")
end

-- Obtenir les données de l'état du jeu (pour les commandes admin)
function WorldManager:GetGameState()
	-- Créer une structure compatible avec l'ancien système
	local config = {
		COIN_VALUE = ServerConfig.Gameplay.COIN_VALUE,
		ROOM_SIZE = ServerConfig.Grid.ROOM_SIZE,
		ROOM_SPACING = ServerConfig.Grid.ROOM_SPACING,
		DOOR_SIZE = ServerConfig.Gameplay.DOOR_SIZE,
		MIN_COINS_PER_ROOM = ServerConfig.Gameplay.MIN_COINS_PER_ROOM,
		MAX_COINS_PER_ROOM = ServerConfig.Gameplay.MAX_COINS_PER_ROOM,
		MIN_OBSTACLES = ServerConfig.Gameplay.MIN_OBSTACLES,
		MAX_OBSTACLES = ServerConfig.Gameplay.MAX_OBSTACLES,
		GRID_SIZE = ServerConfig.Grid.SIZE,
		MIN_PATH_LENGTH = ServerConfig.Grid.MIN_PATH_LENGTH,
	}

	return {
		CONFIG = config,
		worldGrid = self.gridService.worldGrid,
		playerPositions = self.gridService.playerPositions,
		startPos = self.gridService.startPos,
		endPos = self.gridService.endPos,
		gameEnded = self.gameEnded,
		teleportPlayerToRoom = function(player, x, y)
			self:TeleportPlayerToRoom(player, x, y)
		end,
		endGameForAll = function(winner)
			self:EndGame(winner)
		end,
		restartGame = function()
			-- Appeler le hook installé par init.server.luau sur self
			if self.restartGame then
				self.restartGame()
			else
				warn("⚠️ restartGame appelé mais pas de hook installé!")
			end
		end,
		compassEvent = self.remoteService:Get("CompassToggle"),
	}
end

return WorldManager
