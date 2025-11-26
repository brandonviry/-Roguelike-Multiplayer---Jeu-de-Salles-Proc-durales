--[[
	RoundController - Contrôleur des rounds
	Gère la logique des rounds (démarrage, fin, musique)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundController = {}

-- Dépendances
local SoundManager = nil
local RoundUI = nil
local EndScreenUI = nil
local TimerUI = nil

local currentRoundNumber = 0
local gameMusic = nil
local timerTickSound = nil

-- Initialiser le contrôleur
function RoundController.initialize(deps)
	SoundManager = deps.SoundManager
	RoundUI = deps.RoundUI
	EndScreenUI = deps.EndScreenUI
	TimerUI = deps.TimerUI
end

-- Gérer le changement d'état du round
function RoundController.onRoundStateChanged(state, roundNumber, extraData)
	print("🔄 État du round changé:", state, "Round:", roundNumber or "N/A")

	-- Mettre à jour l'UI
	if RoundUI then
		RoundUI.updateState(state, roundNumber, extraData)
	end

	-- Gestion de la musique et des sons
	if state == "STARTED" then
		currentRoundNumber = roundNumber

		-- Arrêter le son du timer si il joue encore
		if timerTickSound then
			timerTickSound:Stop()
			timerTickSound:Destroy()
			timerTickSound = nil
		end

		-- Son de démarrage du round
		if SoundManager then
			SoundManager.playLocalSound("RoundStart")

			-- Démarrer la musique d'ambiance
			if not gameMusic then
				gameMusic = SoundManager.createLoopingMusic("GameMusic")
			end
			if gameMusic then
				SoundManager.fadeIn(gameMusic, 2)
			end
		end

	elseif state == "ENDED" then
		-- Fade out de la musique d'ambiance
		if SoundManager and gameMusic then
			SoundManager.fadeOut(gameMusic, 2)
		end
	end
end

-- Gérer la fin de partie
function RoundController.onGameEnded(winnerName, leaderboard)
	print("🏆 Fin de round! Gagnant:", winnerName)

	-- Jouer le son de victoire
	if SoundManager then
		SoundManager.playLocalSound("Victory")
	end

	-- Créer l'écran de fin
	if EndScreenUI then
		local endScreenGui, overlay, mainFrame = EndScreenUI.show(winnerName, leaderboard)

		-- Démarrer le son du timer (tick en boucle)
		if SoundManager then
			timerTickSound = SoundManager.createLoopingMusic("TimerTick")
			if timerTickSound then
				timerTickSound:Play()
			end
		end

		-- Créer le timer sur l'écran de fin
		if TimerUI then
			TimerUI.create(endScreenGui, 30, function(timeLeft)
				-- Son d'alerte à 10 secondes
				if SoundManager and timeLeft == 10 then
					SoundManager.playLocalSound("TimerWarning")
				end
			end, function()
				-- Fermer l'écran à la fin du timer
				if endScreenGui and endScreenGui.Parent then
					print("🗑️ Fermeture automatique de l'écran de fin")
					-- Animer la fermeture
					local TweenService = game:GetService("TweenService")
					if overlay then
						TweenService:Create(overlay, TweenInfo.new(0.5), {
							BackgroundTransparency = 1
						}):Play()
					end
					if mainFrame then
						TweenService:Create(mainFrame, TweenInfo.new(0.5), {
							BackgroundTransparency = 1
						}):Play()
					end
					task.wait(0.5)
					endScreenGui:Destroy()
				end
			end)
		end
	end
end

-- Connecter aux événements
function RoundController.connect()
	local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
	if not remotesFolder then
		warn("❌ RoundController: Impossible de trouver le dossier Remotes!")
		return
	end

	-- Écouter les changements d'état de round
	local roundStateEvent = remotesFolder:WaitForChild("RoundStateChanged", 5)
	if roundStateEvent then
		roundStateEvent.OnClientEvent:Connect(function(state, roundNumber, extraData)
			RoundController.onRoundStateChanged(state, roundNumber, extraData)
		end)
	end

	-- Écouter les fins de partie
	local gameEndedEvent = remotesFolder:WaitForChild("GameEnded", 5)
	if gameEndedEvent then
		gameEndedEvent.OnClientEvent:Connect(function(winnerName, leaderboard)
			RoundController.onGameEnded(winnerName, leaderboard)
		end)
	end

	print("✅ RoundController connecté")
end

return RoundController
