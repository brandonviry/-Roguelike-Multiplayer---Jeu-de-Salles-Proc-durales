--[[
	Gestion centralisée des RemoteEvents
	Garantit que client et serveur utilisent les mêmes événements
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

-- Créer le dossier de remotes (serveur uniquement)
function RemoteEvents.Initialize()
	if game:GetService("RunService"):IsServer() then
		local remoteFolder = Instance.new("Folder")
		remoteFolder.Name = "Remotes"
		remoteFolder.Parent = ReplicatedStorage

		-- Créer les RemoteEvents
		local coinCollected = Instance.new("RemoteEvent")
		coinCollected.Name = "CoinCollected"
		coinCollected.Parent = remoteFolder

		local coinSpawned = Instance.new("RemoteEvent")
		coinSpawned.Name = "CoinSpawned"
		coinSpawned.Parent = remoteFolder

		print("✅ RemoteEvents initialisés")
	end
end

-- Attendre et récupérer les remotes (client et serveur)
function RemoteEvents.Get()
	local remoteFolder = ReplicatedStorage:WaitForChild("Remotes")

	return {
		CoinCollected = remoteFolder:WaitForChild("CoinCollected"),
		CoinSpawned = remoteFolder:WaitForChild("CoinSpawned"),
	}
end

return RemoteEvents
