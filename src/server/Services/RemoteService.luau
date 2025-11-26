--[[
	RemoteService
	Gestion centralisée de tous les RemoteEvents
	Créé au démarrage du serveur et accessible par tous les modules
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteService = {}
RemoteService.Remotes = {}

-- Initialiser tous les RemoteEvents
function RemoteService:Init()
	print("🔌 Initialisation RemoteService...")

	-- Créer le dossier principal
	local remoteFolder = Instance.new("Folder")
	remoteFolder.Name = "Remotes"
	remoteFolder.Parent = ReplicatedStorage

	-- Définir tous les remotes nécessaires
	local remoteNames = {
		"CoinCollected",      -- Quand un joueur collecte une pièce
		"GameEnded",          -- Quand la partie se termine
		"CompassToggle",      -- Toggle de la boussole
		"RoundStateChanged",  -- Changement d'état du round
		"DoorTeleport",       -- Téléportation via porte
	}

	-- Créer chaque RemoteEvent
	for _, remoteName in ipairs(remoteNames) do
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = remoteName
		remoteEvent.Parent = remoteFolder

		self.Remotes[remoteName] = remoteEvent
		print("  ✅ RemoteEvent créé:", remoteName)
	end

	print("✅ RemoteService initialisé - " .. #remoteNames .. " remotes créés")
	return self
end

-- Récupérer un remote spécifique
function RemoteService:Get(remoteName)
	local remote = self.Remotes[remoteName]
	if not remote then
		warn("⚠️ RemoteEvent introuvable:", remoteName)
	end
	return remote
end

-- Fire à tous les clients
function RemoteService:FireAllClients(remoteName, ...)
	local remote = self:Get(remoteName)
	if remote then
		remote:FireAllClients(...)
	end
end

-- Fire à un client spécifique
function RemoteService:FireClient(remoteName, player, ...)
	local remote = self:Get(remoteName)
	if remote then
		remote:FireClient(player, ...)
	end
end

-- Connecter un handler à un remote
function RemoteService:OnServerEvent(remoteName, handler)
	local remote = self:Get(remoteName)
	if remote then
		remote.OnServerEvent:Connect(handler)
	end
end

return RemoteService
