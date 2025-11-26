--[[
	PlayerManager
	Gestion des joueurs : leaderboard, stats, événements
]]

local Players = game:GetService("Players")

local PlayerManager = {}

-- Initialiser le service
function PlayerManager:Init()
	print("👥 Initialisation PlayerManager...")

	-- Créer le leaderboard pour les joueurs déjà connectés
	for _, player in ipairs(Players:GetPlayers()) do
		self:CreateLeaderboard(player)
		print("👤 Joueur déjà présent:", player.Name)
	end

	-- Connecter les événements pour les futurs joueurs
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerJoined(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerLeft(player)
	end)

	print("✅ PlayerManager initialisé")
	return self
end

-- Quand un joueur rejoint
function PlayerManager:OnPlayerJoined(player)
	self:CreateLeaderboard(player)
	print("👤 Joueur rejoint:", player.Name)
end

-- Quand un joueur part
function PlayerManager:OnPlayerLeft(player)
	print("👋 Joueur parti:", player.Name)
end

-- Créer le leaderboard pour un joueur
function PlayerManager:CreateLeaderboard(player)
	print("🔧 CreateLeaderboard appelé pour:", player.Name)

	-- Vérifier s'il existe déjà
	local existing = player:FindFirstChild("leaderstats")
	if existing then
		print("⚠️ leaderstats existe déjà pour", player.Name, "- suppression...")
		existing:Destroy()
	end

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

	print("  📊 Leaderboard créé pour:", player.Name)
	print("  📊 Vérification: leaderstats?", player:FindFirstChild("leaderstats") ~= nil)
	print("  📊 Vérification: Coins?", leaderstats:FindFirstChild("Coins") ~= nil)
end

-- Ajouter des pièces à un joueur
function PlayerManager:AddCoins(player, amount)
	print("🔍 AddCoins appelé pour", player.Name, "montant:", amount)

	local leaderstats = player:FindFirstChild("leaderstats")
	print("🔍 leaderstats trouvé?", leaderstats ~= nil)

	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		print("🔍 Coins trouvé?", coins ~= nil)

		if coins then
			local oldValue = coins.Value
			coins.Value = coins.Value + amount
			print("✅ Coins mis à jour:", oldValue, "→", coins.Value)
			return true
		else
			warn("❌ Pas de 'Coins' dans leaderstats!")
		end
	else
		warn("❌ Pas de 'leaderstats' pour", player.Name)
	end
	return false
end

-- Incrémenter le compteur de salles visitées
function PlayerManager:IncrementRoomsVisited(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rooms = leaderstats:FindFirstChild("Salles")
		if rooms then
			rooms.Value = rooms.Value + 1
			return true
		end
	end
	return false
end

-- Reset les stats d'un joueur
function PlayerManager:ResetPlayerStats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		local rooms = leaderstats:FindFirstChild("Salles")

		if coins then coins.Value = 0 end
		if rooms then rooms.Value = 0 end

		print("  🔄 Stats reset pour:", player.Name)
		return true
	end
	return false
end

-- Reset tous les joueurs
function PlayerManager:ResetAllPlayers()
	print("📊 Reset des scores de tous les joueurs...")
	local count = 0

	for _, player in ipairs(Players:GetPlayers()) do
		if self:ResetPlayerStats(player) then
			count = count + 1
		end
	end

	print("✅ " .. count .. " joueur(s) reset")
end

-- Créer le classement pour la fin de round
function PlayerManager:GetFinalLeaderboard(winner)
	local leaderboard = {}

	for _, player in ipairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local coins = leaderstats:FindFirstChild("Coins")
			local rooms = leaderstats:FindFirstChild("Salles")

			if coins and rooms then
				table.insert(leaderboard, {
					player = player,
					coins = coins.Value,
					rooms = rooms.Value,
					isWinner = (player == winner)
				})
			end
		end
	end

	-- Trier par coins (décroissant)
	table.sort(leaderboard, function(a, b)
		return a.coins > b.coins
	end)

	return leaderboard
end

-- Obtenir les stats d'un joueur
function PlayerManager:GetPlayerStats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end

	local coins = leaderstats:FindFirstChild("Coins")
	local rooms = leaderstats:FindFirstChild("Salles")

	return {
		coins = coins and coins.Value or 0,
		rooms = rooms and rooms.Value or 0,
	}
end

return PlayerManager
