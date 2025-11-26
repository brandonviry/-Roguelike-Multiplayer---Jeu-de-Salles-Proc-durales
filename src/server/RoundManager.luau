--[[
	Système de gestion des rounds
	Gère le cycle: Round → Résultats → Reset → Nouveau Round
	REFACTORISÉ pour utiliser WorldManager
]]

local ServerConfig = require(script.Parent.Config.ServerConfig)

local RoundManager = {}

-- États possibles
RoundManager.States = {
	WAITING = "WAITING",     -- Attente entre rounds (15 secondes)
	PLAYING = "PLAYING",     -- Round en cours
	ENDED = "ENDED",         -- Round terminé, affichage résultats
}

-- État actuel
RoundManager.currentState = RoundManager.States.WAITING
RoundManager.currentRound = 0
RoundManager.roundWinner = nil

-- Durées (en secondes)
RoundManager.WAITING_TIME = ServerConfig.Rounds.WAITING_TIME
RoundManager.RESULTS_TIME = ServerConfig.Rounds.RESULTS_TIME

-- Initialiser avec les dépendances
function RoundManager:Init(worldManager, remoteService, playerManager)
	self.worldManager = worldManager
	self.remoteService = remoteService
	self.playerManager = playerManager
	print("🎮 RoundManager initialisé")
	return self
end

-- Commencer un nouveau round
function RoundManager:StartNewRound()
	print("🔄 === NOUVEAU ROUND ===")

	self.currentRound = self.currentRound + 1
	self.currentState = self.States.PLAYING
	self.roundWinner = nil

	-- Reset le monde via WorldManager
	self.worldManager:ResetWorld()

	-- Créer les salles principales
	self.worldManager:CreateMainRooms()

	-- Téléporter tous les joueurs
	self.worldManager:TeleportAllPlayersToStart()

	-- Notifier tous les clients
	self.remoteService:FireAllClients("RoundStateChanged", "STARTED", self.currentRound)

	print("✅ Round", self.currentRound, "commencé!")
	print("🏁 Première personne à atteindre Z gagne!")
end

-- Terminer le round
function RoundManager:EndRound(winner)
	print("🎯 RoundManager:EndRound appelé avec winner:", winner and winner.Name or "nil")

	if self.currentState ~= self.States.PLAYING then
		print("⚠️ Round déjà terminé ou pas en cours (état:", self.currentState, ")")
		return -- Round déjà terminé
	end

	print("🏆 === FIN DU ROUND", self.currentRound, "===")
	print("🏆 Gagnant:", winner.Name)

	self.currentState = self.States.ENDED
	self.roundWinner = winner

	-- Marquer le jeu comme terminé dans WorldManager
	self.worldManager.gameEnded = true

	-- Créer le leaderboard via PlayerManager
	local leaderboard = self.playerManager:GetFinalLeaderboard(winner)

	print("📊 Classement final:")
	for i, entry in ipairs(leaderboard) do
		local prefix = entry.isWinner and "👑" or "  "
		print(prefix, i .. ".", entry.player.Name, "-", entry.coins, "coins,", entry.rooms, "salles")
	end

	-- Envoyer les résultats aux clients
	self.remoteService:FireAllClients("GameEnded", winner.Name, leaderboard)

	-- Notifier le changement d'état
	self.remoteService:FireAllClients("RoundStateChanged", "ENDED", self.currentRound, winner.Name)

	-- Attendre avant de commencer le prochain round
	print("⏳ Prochain round dans", self.WAITING_TIME, "secondes...")

	task.wait(self.RESULTS_TIME)

	-- État d'attente
	self.currentState = self.States.WAITING
	self.remoteService:FireAllClients("RoundStateChanged", "WAITING", self.WAITING_TIME)

	-- Compte à rebours
	for i = self.WAITING_TIME, 1, -1 do
		print("⏱️", i, "secondes avant le prochain round...")
		task.wait(1)
	end

	-- Démarrer le nouveau round
	self:StartNewRound()
end

-- Démarrer le système de rounds
function RoundManager:Start()
	print("🎮 Démarrage du système de rounds...")

	-- Attendre quelques secondes pour que les joueurs se connectent
	print("⏳ Démarrage dans", ServerConfig.Rounds.START_DELAY, "secondes...")
	task.wait(ServerConfig.Rounds.START_DELAY)

	-- Démarrer le premier round
	self:StartNewRound()
end

return RoundManager
