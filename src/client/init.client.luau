--[[
	Client du jeu - Point d'entrée principal
	Architecture modulaire professionnelle

	Structure:
	- controllers/ : Logique métier (gestion des événements)
	- ui/          : Interfaces utilisateur (affichage)
	- effects/     : Effets visuels (animations, caméra)
]]

local Players = game:GetService("Players")

local player = Players.LocalPlayer

print("🚀 === DÉMARRAGE DU CLIENT ===")

-- ============================================================================
-- CHARGEMENT DES MODULES
-- ============================================================================

-- Gestionnaires
local SoundManager = require(script:WaitForChild("SoundManager", 10))

-- Attendre que les dossiers soient chargés (avec timeout de 10 secondes)
local effectsFolder = script:WaitForChild("effects", 10)
local uiFolder = script:WaitForChild("ui", 10)
local controllersFolder = script:WaitForChild("Controllers", 10)

if not effectsFolder then
	error("❌ Dossier 'effects' introuvable!")
end
if not uiFolder then
	error("❌ Dossier 'ui' introuvable!")
end
if not controllersFolder then
	error("❌ Dossier 'controllers' introuvable!")
end

-- Effets visuels
local CollectEffects = require(effectsFolder:WaitForChild("CollectEffects"))
local CameraEffects = require(effectsFolder:WaitForChild("CameraEffects"))

-- Interfaces utilisateur
local ScoreUI = require(uiFolder:WaitForChild("ScoreUI"))
local RoundUI = require(uiFolder:WaitForChild("RoundUI"))
local EndScreenUI = require(uiFolder:WaitForChild("EndScreenUI"))
local TimerUI = require(uiFolder:WaitForChild("TimerUI"))
local CompassUI = require(uiFolder:WaitForChild("CompassUI"))
local AdminUI = require(uiFolder:WaitForChild("AdminUI"))

-- Contrôleurs (logique)
local CoinController = require(controllersFolder:WaitForChild("CoinController"))
local RoundController = require(controllersFolder:WaitForChild("RoundController"))
local DoorController = require(controllersFolder:WaitForChild("DoorController"))
local CompassController = require(controllersFolder:WaitForChild("CompassController"))

print("✅ Modules chargés")

-- ============================================================================
-- INITIALISATION DES INTERFACES
-- ============================================================================

-- Créer les interfaces utilisateur
ScoreUI.create()
RoundUI.create()

print("✅ Interfaces créées")

-- ============================================================================
-- INITIALISATION DES CONTRÔLEURS
-- ============================================================================

-- Injecter les dépendances dans les contrôleurs
CoinController.initialize({
	SoundManager = SoundManager,
	CollectEffects = CollectEffects,
	CameraEffects = CameraEffects
})

RoundController.initialize({
	SoundManager = SoundManager,
	RoundUI = RoundUI,
	EndScreenUI = EndScreenUI,
	TimerUI = TimerUI
})

DoorController.initialize({
	SoundManager = SoundManager
})

CompassController.initialize({
	CompassUI = CompassUI
})

print("✅ Contrôleurs initialisés")

-- ============================================================================
-- CONNEXION AUX ÉVÉNEMENTS SERVEUR
-- ============================================================================

-- Connecter tous les contrôleurs aux événements
CoinController.connect()
RoundController.connect()
DoorController.connect()
CompassController.connect()

print("✅ Événements connectés")

-- ============================================================================
-- ÉCOUTE DU SCORE (LEADERSTATS)
-- ============================================================================

local leaderstats = player:WaitForChild("leaderstats", 10)
if leaderstats then
	local coins = leaderstats:WaitForChild("Coins", 5)

	if coins then
		-- Mise à jour du score quand il change
		coins.Changed:Connect(function()
			ScoreUI.update(coins.Value)
		end)

		-- Mise à jour initiale
		ScoreUI.update(coins.Value)
		print("✅ Score initialisé:", coins.Value)
	end
end

-- ============================================================================
-- INTERFACE ADMIN (SI APPLICABLE)
-- ============================================================================

task.spawn(function()
	task.wait(3) -- Attendre que l'attribut soit défini

	if player:GetAttribute("IsAdmin") then
		print("👑 Mode admin activé")
		AdminUI.create()
	end
end)

-- ============================================================================
-- CLIENT PRÊT
-- ============================================================================

print("✅ === CLIENT PRÊT ===")
print("🎮 Prêt à jouer!")
