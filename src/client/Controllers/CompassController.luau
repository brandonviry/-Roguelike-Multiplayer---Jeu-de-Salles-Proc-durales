--[[
	CompassController - Contrôleur de la boussole
	Gère l'affichage de la boussole pointant vers Z
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CompassController = {}

-- Dépendances
local CompassUI = nil

-- Initialiser le contrôleur
function CompassController.initialize(deps)
	CompassUI = deps.CompassUI
end

-- Gérer le toggle de la boussole
function CompassController.onCompassToggle(dx, dy, distance)
	if CompassUI then
		CompassUI.toggle(dx, dy, distance)
	end
end

-- Connecter aux événements
function CompassController.connect()
	local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
	if not remotesFolder then
		warn("❌ CompassController: Impossible de trouver le dossier Remotes!")
		return
	end

	local compassEvent = remotesFolder:WaitForChild("CompassToggle", 5)
	if compassEvent then
		compassEvent.OnClientEvent:Connect(function(dx, dy, distance)
			CompassController.onCompassToggle(dx, dy, distance)
		end)
	end

	print("✅ CompassController connecté")
end

return CompassController
