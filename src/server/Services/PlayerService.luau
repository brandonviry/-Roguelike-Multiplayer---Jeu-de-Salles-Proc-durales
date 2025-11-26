--[[
	PlayerService
	Gère les joueurs, leur leaderboard et leurs données
]]

local Players = game:GetService("Players")

local PlayerService = {}
PlayerService.Players = {}

-- Initialiser le service
function PlayerService:Init()
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerJoined(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerLeft(player)
	end)

	print("✅ PlayerService initialisé")
end

-- Quand un joueur rejoint
function PlayerService:OnPlayerJoined(player)
	-- Créer le leaderboard
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	local streak = Instance.new("IntValue")
	streak.Name = "Streak"
	streak.Value = 0
	streak.Parent = leaderstats

	-- Sauvegarder les données du joueur
	self.Players[player.UserId] = {
		Player = player,
		Coins = coins,
		Streak = streak,
		JoinTime = os.time(),
	}

	print("👤 Joueur rejoint:", player.Name)
end

-- Quand un joueur part
function PlayerService:OnPlayerLeft(player)
	self.Players[player.UserId] = nil
	print("👋 Joueur parti:", player.Name)
end

-- Ajouter des pièces à un joueur
function PlayerService:AddCoins(player, amount)
	local playerData = self.Players[player.UserId]
	if playerData then
		playerData.Coins.Value = playerData.Coins.Value + amount
		playerData.Streak.Value = playerData.Streak.Value + 1
		return true
	end
	return false
end

-- Obtenir les données d'un joueur
function PlayerService:GetPlayerData(player)
	return self.Players[player.UserId]
end

-- Réinitialiser le streak
function PlayerService:ResetStreak(player)
	local playerData = self.Players[player.UserId]
	if playerData then
		playerData.Streak.Value = 0
	end
end

return PlayerService
