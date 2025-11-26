--[[
	SoundController
	Gère tous les sons du jeu
]]

local SoundService = game:GetService("SoundService")

local SoundController = {}
SoundController.Sounds = {}

-- IDs de sons Roblox gratuits
local SOUND_IDS = {
	COLLECT = "rbxassetid://5104945592", -- Son de collecte
	SUCCESS = "rbxassetid://6895079853", -- Son de succès
	AMBIENT = "rbxassetid://1837849285", -- Musique d'ambiance
}

-- Initialiser
function SoundController:Init()
	self:LoadSounds()
	self:PlayAmbient()
	print("✅ SoundController initialisé")
end

-- Charger les sons
function SoundController:LoadSounds()
	-- Son de collecte
	local collectSound = Instance.new("Sound")
	collectSound.Name = "CollectSound"
	collectSound.SoundId = SOUND_IDS.COLLECT
	collectSound.Volume = 0.5
	collectSound.Parent = SoundService

	self.Sounds.Collect = collectSound

	-- Son de succès (streak)
	local successSound = Instance.new("Sound")
	successSound.Name = "SuccessSound"
	successSound.SoundId = SOUND_IDS.SUCCESS
	successSound.Volume = 0.6
	successSound.Parent = SoundService

	self.Sounds.Success = successSound

	-- Musique d'ambiance
	local ambientMusic = Instance.new("Sound")
	ambientMusic.Name = "AmbientMusic"
	ambientMusic.SoundId = SOUND_IDS.AMBIENT
	ambientMusic.Volume = 0.2
	ambientMusic.Looped = true
	ambientMusic.Parent = SoundService

	self.Sounds.Ambient = ambientMusic
end

-- Jouer un son de collecte
function SoundController:PlayCollect(pitch)
	pitch = pitch or 1

	local sound = self.Sounds.Collect
	if sound then
		sound.PlaybackSpeed = pitch
		sound:Play()
	end
end

-- Jouer un son de succès
function SoundController:PlaySuccess()
	local sound = self.Sounds.Success
	if sound then
		sound:Play()
	end
end

-- Jouer la musique d'ambiance
function SoundController:PlayAmbient()
	local sound = self.Sounds.Ambient
	if sound then
		sound:Play()
	end
end

-- Arrêter la musique d'ambiance
function SoundController:StopAmbient()
	local sound = self.Sounds.Ambient
	if sound then
		sound:Stop()
	end
end

return SoundController
