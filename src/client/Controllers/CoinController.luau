--[[
	CoinController - Contrôleur de collecte de pièces
	Gère la logique quand le joueur collecte une pièce
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoinController = {}

-- Dépendances (injectées depuis init.client)
local SoundManager = nil
local CollectEffects = nil
local CameraEffects = nil

-- Initialiser le contrôleur avec ses dépendances
function CoinController.initialize(deps)
	SoundManager = deps.SoundManager
	CollectEffects = deps.CollectEffects
	CameraEffects = deps.CameraEffects
end

-- Gérer l'événement de collecte
function CoinController.onCoinCollected(amount, color)
	print("💰 Collecté! +" .. amount .. " coins")

	-- Son de collecte avec variation de pitch
	if SoundManager then
		SoundManager.playVariedSound("CoinCollect")
	end

	-- Effets visuels
	if CollectEffects then
		CollectEffects.showCircle(color)
	end

	if CameraEffects then
		CameraEffects.shake()
	end
end

-- Connecter aux événements
function CoinController.connect()
	local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
	if not remotesFolder then
		warn("❌ CoinController: Impossible de trouver le dossier Remotes!")
		return
	end

	local coinCollectedEvent = remotesFolder:WaitForChild("CoinCollected", 5)
	if not coinCollectedEvent then
		warn("❌ CoinController: Impossible de trouver CoinCollected!")
		return
	end

	-- Écouter les collectes
	coinCollectedEvent.OnClientEvent:Connect(function(amount, color)
		CoinController.onCoinCollected(amount, color)
	end)

	print("✅ CoinController connecté")
end

return CoinController
