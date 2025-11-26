--[[
	Système de gestion des sons
	Tous les sons du jeu centralisés ici
]]

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local SoundManager = {}

-- IDs des sons Roblox gratuits (Asset Library)
SoundManager.Sounds = {
	-- Sons de gameplay
	CoinCollect = "rbxassetid://84506415901088",      -- Son cristallin de collecte
	DoorTeleport = "rbxassetid://123796710194563",     -- Whoosh de téléportation

	-- Sons de round
	Victory = "rbxassetid://9041812129",          -- Fanfare de victoire
	RoundStart = "rbxassetid://17832323382",       -- Son de début

	-- Timer
	TimerTick = "rbxassetid://9043366464",        -- Tick chaque seconde
	TimerWarning = "rbxassetid://9063147354",     -- Alerte 10 secondes

	-- Musique
	GameMusic = "rbxassetid://72734512335337",        -- Musique d'ambiance (boucle)
	EndMusic = "rbxassetid://1843463175",         -- Musique de fin
}

-- Volume par défaut
SoundManager.DefaultVolume = {
	CoinCollect = 0.5,
	DoorTeleport = 0.4,
	Victory = 0.7,
	RoundStart = 0.6,
	TimerTick = 0.3,
	TimerWarning = 0.8,
	GameMusic = 0.2,
	EndMusic = 0.3,
}

-- Créer un son local (joué uniquement pour le client)
function SoundManager.playLocalSound(soundName, parent, pitch)
	local soundId = SoundManager.Sounds[soundName]
	if not soundId then
		warn("❌ Son introuvable:", soundName)
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = SoundManager.DefaultVolume[soundName] or 0.5
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = parent or SoundService

	sound:Play()

	-- Détruire le son après lecture
	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	return sound
end

-- Jouer un son avec variation de pitch (pour éviter la monotonie)
function SoundManager.playVariedSound(soundName, parent)
	local pitch = math.random(90, 110) / 100  -- Variation de 0.9 à 1.1
	return SoundManager.playLocalSound(soundName, parent, pitch)
end

-- Créer une musique en boucle
function SoundManager.createLoopingMusic(soundName, parent)
	local soundId = SoundManager.Sounds[soundName]
	if not soundId then
		warn("❌ Musique introuvable:", soundName)
		return
	end

	local music = Instance.new("Sound")
	music.Name = soundName
	music.SoundId = soundId
	music.Volume = SoundManager.DefaultVolume[soundName] or 0.3
	music.Looped = true
	music.Parent = parent or SoundService

	return music
end

-- Fade in d'une musique
function SoundManager.fadeIn(sound, duration)
	if not sound then return end

	local targetVolume = SoundManager.DefaultVolume[sound.Name] or 0.3
	sound.Volume = 0
	sound:Play()

	TweenService:Create(sound, TweenInfo.new(duration or 2), {
		Volume = targetVolume
	}):Play()
end

-- Fade out d'une musique
function SoundManager.fadeOut(sound, duration)
	if not sound then return end

	local tween = TweenService:Create(sound, TweenInfo.new(duration or 2), {
		Volume = 0
	})

	tween:Play()
	tween.Completed:Connect(function()
		sound:Stop()
	end)
end

-- Stop tous les sons
function SoundManager.stopAll()
	for _, sound in ipairs(SoundService:GetChildren()) do
		if sound:IsA("Sound") then
			sound:Stop()
		end
	end
end

return SoundManager
