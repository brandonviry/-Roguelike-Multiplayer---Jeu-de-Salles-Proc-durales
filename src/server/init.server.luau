--[[
	🎮 SERVER PRINCIPAL - ARCHITECTURE MODULAIRE REFACTORISÉE

	Ce fichier orchestre tous les modules du jeu.
	Il initialise les services dans le bon ordre et gère les dépendances.

	Architecture:
	├── Config (configuration centralisée)
	├── Services (RemoteService, GridService, PlayerManager, LightingService)
	├── Modules (EntityFactory, RoomFactory, PathfindingService, WorldManager)
	├── RoundManager (gestion des rounds)
	└── AdminCommands (commandes admin)
]]

local Players = game:GetService("Players")

print("🚀 === DÉMARRAGE DU SERVEUR - ARCHITECTURE MODULAIRE ===")

-- ============================================================================
-- IMPORTS DES MODULES
-- ============================================================================

-- Configuration
local ServerConfig = require(script.Config.ServerConfig)

-- Services
local RemoteService = require(script.Services.RemoteService)
local GridService = require(script.Services.GridService)
local PlayerManager = require(script.Services.PlayerManager)
local LightingService = require(script.Services.LightingService)

-- Modules
local EntityFactory = require(script.Modules.EntityFactory)
local RoomFactory = require(script.Modules.RoomFactory)
local PathfindingService = require(script.Modules.PathfindingService)
local WorldManager = require(script.Modules.WorldManager)

-- Systèmes
local RoundManager = require(script.RoundManager)
local AdminCommands = require(script.AdminCommands)

-- ============================================================================
-- INITIALISATION DES SERVICES (ORDRE IMPORTANT)
-- ============================================================================

print("🔧 Initialisation des services...")

-- 1. Services de base
local remoteService = RemoteService:Init()
local gridService = GridService:Init()
local playerManager = PlayerManager:Init()
LightingService:Init() -- Pas besoin de stocker, juste initialiser

-- 2. Modules de fabrication
local entityFactory = EntityFactory:Init(remoteService, playerManager)
local roomFactory = RoomFactory:Init(gridService, entityFactory)
local pathfindingService = PathfindingService:Init(gridService)

-- 3. WorldManager (orchestrateur principal)
local worldManager = WorldManager:Init({
	gridService = gridService,
	remoteService = remoteService,
	playerManager = playerManager,
	roomFactory = roomFactory,
	pathfindingService = pathfindingService,
})

-- 4. RoundManager
local roundManager = RoundManager:Init(worldManager, remoteService, playerManager)

-- 5. AdminCommands (charger toutes les commandes)
AdminCommands.init()

print("✅ Tous les services initialisés")

-- ============================================================================
-- GESTION DES JOUEURS
-- ============================================================================

-- Quand un joueur rejoint
Players.PlayerAdded:Connect(function(player)
	-- Vérifier si c'est un admin
	if AdminCommands.isAdmin(player) then
		print("👑 ADMIN connecté:", player.Name)
		task.wait(2)
		player:SetAttribute("IsAdmin", true)
	end

	-- Écouter les commandes dans le chat
	player.Chatted:Connect(function(message)
		if message:sub(1, 1) == "/" then
			print("💬", player.Name, ":", message)

			-- Récupérer le gameState pour les commandes admin
			local gameState = worldManager:GetGameState()

			local success, result = AdminCommands.executeCommand(player, message, gameState)
			if success then
				print("✅", result)
			else
				print("❌", result)
				warn(player.Name .. " - " .. result)
			end
		end
	end)

	-- Quand le personnage spawn
	player.CharacterAdded:Connect(function(_character)
		task.wait(1) -- Attendre que le personnage soit complètement chargé

		-- Téléporter au spawn si on est en round
		if roundManager.currentState == RoundManager.States.PLAYING then
			worldManager:TeleportPlayerToRoom(
				player,
				gridService.startPos.x,
				gridService.startPos.y
			)
		end
	end)
end)

-- Quand un joueur part
Players.PlayerRemoving:Connect(function(player)
	gridService:RemovePlayerPosition(player.UserId)
end)

-- ============================================================================
-- DÉTECTION DE FIN DE PARTIE
-- ============================================================================

-- Hook la détection de fin de partie dans le WorldManager
print("🔗 Installation du hook EndGame...")
worldManager.EndGame = function(_self, winner)
	print("🎯 Hook EndGame appelé! Winner:", winner and winner.Name or "nil")
	print("🎯 Redirection vers RoundManager:EndRound...")
	-- Terminer le round via RoundManager
	roundManager:EndRound(winner)
end
print("✅ Hook EndGame installé")

-- Hook pour redémarrer complètement le jeu
print("🔗 Installation du hook RestartGame...")
local function restartGameCompletely()
	print("🔄 === REDÉMARRAGE COMPLET DU JEU ===")

	-- 1. Forcer l'état du round à WAITING pour arrêter tout
	roundManager.currentState = RoundManager.States.WAITING
	print("✅ Round arrêté")

	-- 2. Reset le monde (détruit toutes les salles, reset les positions)
	worldManager:ResetWorld()
	print("✅ Monde réinitialisé")

	-- 3. Notifier tous les clients
	remoteService:FireAllClients("RoundStateChanged", "WAITING", 3)
	print("✅ Clients notifiés")

	-- 4. Attendre un peu pour que les joueurs voient le message
	task.wait(3)

	-- 5. Démarrer un nouveau round immédiatement
	roundManager:StartNewRound()
	print("✅ Nouveau round démarré")

	print("🎉 === REDÉMARRAGE TERMINÉ ===")
end

-- Installer le hook dans worldManager
worldManager.restartGame = restartGameCompletely
print("✅ Hook RestartGame installé")

-- ============================================================================
-- DÉMARRAGE DU JEU
-- ============================================================================

print("✅ === SERVEUR PRÊT ===")
print("🎮 Système de rounds actif!")
print("🗺️ Monde partagé persistant - Grille " .. ServerConfig.Grid.SIZE .. "x" .. ServerConfig.Grid.SIZE)
print("👑 Admins configurés:", #AdminCommands.ADMINS or 0)
print("")

-- Démarrer le système de rounds
roundManager:Start()

print("🎯 Le jeu a démarré!")
