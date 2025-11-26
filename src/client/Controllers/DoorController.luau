--[[
	DoorController - Contrôleur des portes
	Gère le son de téléportation quand on passe une porte
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DoorController = {}

-- Dépendances
local SoundManager = nil

-- Initialiser le contrôleur
function DoorController.initialize(deps)
	SoundManager = deps.SoundManager
end

-- Gérer la téléportation
function DoorController.onDoorTeleport()
	print("🚪 Téléportation par porte")

	-- Son de téléportation
	if SoundManager then
		SoundManager.playLocalSound("DoorTeleport")
	end
end

-- Connecter aux événements
function DoorController.connect()
	local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
	if not remotesFolder then
		warn("❌ DoorController: Impossible de trouver le dossier Remotes!")
		return
	end

	local doorTeleportEvent = remotesFolder:WaitForChild("DoorTeleport", 5)
	if doorTeleportEvent then
		doorTeleportEvent.OnClientEvent:Connect(function()
			DoorController.onDoorTeleport()
		end)
	end

	print("✅ DoorController connecté")
end

return DoorController
