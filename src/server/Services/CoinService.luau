--[[
	CoinService
	Gère le spawn, la collecte et la destruction des pièces
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local RemoteEvents = require(ReplicatedStorage.Shared.RemoteEvents)

local CoinService = {}
CoinService.ActiveCoins = {}
CoinService.Remotes = nil
CoinService.PlayerService = nil

-- Initialiser le service
function CoinService:Init(playerService)
	self.PlayerService = playerService
	self.Remotes = RemoteEvents.Get()

	-- Démarrer le spawn automatique
	task.spawn(function()
		self:SpawnLoop()
	end)

	print("✅ CoinService initialisé")
end

-- Créer une pièce 3D stylisée
function CoinService:CreateCoin()
	if #self.ActiveCoins >= Config.Gameplay.MAX_COINS then
		return
	end

	local coinModel = Instance.new("Model")
	coinModel.Name = "Coin"

	local color = Config.Colors.COINS[math.random(1, #Config.Colors.COINS)]

	-- Centre de l'étoile
	local center = Instance.new("Part")
	center.Name = "Center"
	center.Shape = Enum.PartType.Ball
	center.Size = Vector3.new(1.5, 1.5, 1.5)
	center.Material = Enum.Material.SmoothPlastic
	center.Color = color
	center.Anchored = true
	center.CanCollide = false
	center.CastShadow = true

	-- Position aléatoire
	local randomX = math.random(Config.World.SPAWN_AREA.MIN.X, Config.World.SPAWN_AREA.MAX.X)
	local randomY = math.random(Config.World.SPAWN_AREA.MIN.Y, Config.World.SPAWN_AREA.MAX.Y)
	local randomZ = math.random(Config.World.SPAWN_AREA.MIN.Z, Config.World.SPAWN_AREA.MAX.Z)
	center.Position = Vector3.new(randomX, randomY, randomZ)
	center.Parent = coinModel

	-- Créer des pointes autour (style étoile 3D)
	for i = 0, 5 do
		local angle = math.rad(i * 60)
		local spike = Instance.new("Part")
		spike.Name = "Spike" .. i
		spike.Shape = Enum.PartType.Block
		spike.Size = Vector3.new(0.5, 0.5, 2)
		spike.Material = Enum.Material.SmoothPlastic
		spike.Color = color
		spike.Anchored = true
		spike.CanCollide = false
		spike.CastShadow = true

		local offsetX = math.cos(angle) * 1.5
		local offsetZ = math.sin(angle) * 1.5
		spike.Position = center.Position + Vector3.new(offsetX, 0, offsetZ)
		spike.Orientation = Vector3.new(0, math.deg(angle), 0)
		spike.Parent = coinModel
	end

	-- Ajouter un highlight pour meilleure visibilité
	local highlight = Instance.new("Highlight")
	highlight.FillColor = color
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0.8
	highlight.Parent = coinModel

	-- ClickDetector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = Config.Gameplay.CLICK_DISTANCE
	clickDetector.Parent = center

	-- Gestion de la collecte
	clickDetector.MouseClick:Connect(function(player)
		self:CollectCoin(coinModel, player, color)
	end)

	-- Données de la pièce
	local coinData = {
		Model = coinModel,
		Center = center,
		Color = color,
		SpawnTime = tick(),
		BasePosition = Vector3.new(randomX, randomY, randomZ),
	}

	coinModel.Parent = Workspace
	table.insert(self.ActiveCoins, coinData)

	-- Animation
	self:AnimateCoin(coinData)

	-- Auto-destruction après un certain temps
	task.delay(Config.Gameplay.COIN_LIFETIME, function()
		if coinModel.Parent then
			self:RemoveCoin(coinData)
		end
	end)

	return coinData
end

-- Collecter une pièce
function CoinService:CollectCoin(coinModel, player, color)
	if not coinModel.Parent then return end

	-- Ajouter les pièces au joueur
	if self.PlayerService:AddCoins(player, Config.Gameplay.COIN_VALUE) then
		-- Notifier le client
		self.Remotes.CoinCollected:FireClient(player, Config.Gameplay.COIN_VALUE, color)

		-- Effet de collecte sur le serveur
		self:CreateCollectionEffect(coinModel:FindFirstChild("Center").Position, color)

		-- Retirer la pièce
		for i, coinData in ipairs(self.ActiveCoins) do
			if coinData.Model == coinModel then
				table.remove(self.ActiveCoins, i)
				break
			end
		end

		coinModel:Destroy()
	end
end

-- Créer un effet de collecte
function CoinService:CreateCollectionEffect(position, color)
	local effect = Instance.new("Part")
	effect.Shape = Enum.PartType.Ball
	effect.Size = Vector3.new(0.5, 0.5, 0.5)
	effect.Material = Enum.Material.Neon
	effect.Color = color
	effect.Anchored = true
	effect.CanCollide = false
	effect.Position = position
	effect.Parent = Workspace

	-- Animation d'expansion
	task.spawn(function()
		for i = 1, 10 do
			effect.Size = effect.Size + Vector3.new(0.5, 0.5, 0.5)
			effect.Transparency = effect.Transparency + 0.1
			task.wait(0.03)
		end
		effect:Destroy()
	end)
end

-- Animer une pièce
function CoinService:AnimateCoin(coinData)
	task.spawn(function()
		local rotation = 0
		local time = 0

		while coinData.Model.Parent do
			time = time + 0.05
			rotation = rotation + Config.Animation.COIN_ROTATION_SPEED

			-- Rotation de tout le modèle
			for _, part in ipairs(coinData.Model:GetChildren()) do
				if part:IsA("BasePart") then
					local offset = part.Position - coinData.Center.Position
					local angle = math.rad(rotation)
					local newOffsetX = offset.X * math.cos(angle) - offset.Z * math.sin(angle)
					local newOffsetZ = offset.X * math.sin(angle) + offset.Z * math.cos(angle)

					part.Position = coinData.Center.Position + Vector3.new(newOffsetX, offset.Y, newOffsetZ)

					if part.Name:match("Spike") then
						local spikeIndex = tonumber(part.Name:match("%d+"))
						part.Orientation = Vector3.new(0, rotation + (spikeIndex * 60), 0)
					end
				end
			end

			-- Flottement
			local yOffset = math.sin(time * Config.Animation.COIN_FLOAT_SPEED) * Config.Animation.COIN_FLOAT_AMPLITUDE
			coinData.Center.Position = coinData.BasePosition + Vector3.new(0, yOffset, 0)

			task.wait(0.03)
		end
	end)
end

-- Retirer une pièce
function CoinService:RemoveCoin(coinData)
	for i, data in ipairs(self.ActiveCoins) do
		if data == coinData then
			table.remove(self.ActiveCoins, i)
			break
		end
	end

	if coinData.Model.Parent then
		coinData.Model:Destroy()
	end
end

-- Boucle de spawn
function CoinService:SpawnLoop()
	while true do
		self:CreateCoin()
		task.wait(Config.Gameplay.SPAWN_INTERVAL)
	end
end

return CoinService
