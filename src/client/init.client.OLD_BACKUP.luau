--[[
	Client du jeu - Version simple et 100% fonctionnelle
	Interface et effets visuels
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Charger le système de sons
local SoundManager = require(script.SoundManager)

print("🚀 === DÉMARRAGE DU CLIENT ===")
print("🎵 Système de sons chargé")

-- Attendre les RemoteEvents
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
if not remotesFolder then
	warn("❌ Impossible de trouver le dossier Remotes!")
	return
end

local coinCollectedEvent = remotesFolder:WaitForChild("CoinCollected", 5)
if not coinCollectedEvent then
	warn("❌ Impossible de trouver CoinCollected!")
	return
end

print("✅ RemoteEvents trouvés")

-- Créer l'interface utilisateur
local function createUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Frame de score (en haut à droite)
	local scoreFrame = Instance.new("Frame")
	scoreFrame.Name = "ScoreFrame"
	scoreFrame.Size = UDim2.new(0, 200, 0, 90)
	scoreFrame.Position = UDim2.new(1, -220, 0, 20)
	scoreFrame.AnchorPoint = Vector2.new(0, 0)
	scoreFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	scoreFrame.BorderSizePixel = 0
	scoreFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = scoreFrame

	-- Ombre pour un effet professionnel
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 10, 10)
	shadow.ZIndex = -1
	shadow.Parent = scoreFrame

	-- Gradient
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
	})
	gradient.Rotation = 45
	gradient.Parent = scoreFrame

	-- Icône de coin (étoile)
	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "IconFrame"
	iconFrame.Size = UDim2.new(0, 50, 0, 50)
	iconFrame.Position = UDim2.new(0, 10, 0.5, -25)
	iconFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
	iconFrame.BorderSizePixel = 0
	iconFrame.Parent = scoreFrame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(1, 0)
	iconCorner.Parent = iconFrame

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = "⭐"
	iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	iconLabel.TextSize = 28
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = iconFrame

	-- Label de score (ajusté pour l'icône)
	local scoreLabel = Instance.new("TextLabel")
	scoreLabel.Name = "ScoreLabel"
	scoreLabel.Size = UDim2.new(1, -70, 0.7, 0)
	scoreLabel.Position = UDim2.new(0, 70, 0, 0)
	scoreLabel.BackgroundTransparency = 1
	scoreLabel.Text = "0"
	scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	scoreLabel.TextSize = 42
	scoreLabel.Font = Enum.Font.GothamBold
	scoreLabel.TextXAlignment = Enum.TextXAlignment.Left
	scoreLabel.Parent = scoreFrame

	-- Label "COINS" (ajusté pour l'icône)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -70, 0.3, 0)
	titleLabel.Position = UDim2.new(0, 70, 0.7, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "COINS"
	titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = scoreFrame

	-- Effet de collecte (cercle coloré)
	local collectEffect = Instance.new("Frame")
	collectEffect.Name = "CollectEffect"
	collectEffect.Size = UDim2.new(0, 0, 0, 0)
	collectEffect.Position = UDim2.new(0.5, 0, 0.5, 0)
	collectEffect.AnchorPoint = Vector2.new(0.5, 0.5)
	collectEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	collectEffect.BorderSizePixel = 0
	collectEffect.BackgroundTransparency = 1
	collectEffect.ZIndex = 10
	collectEffect.Parent = screenGui

	local effectCorner = Instance.new("UICorner")
	effectCorner.CornerRadius = UDim.new(1, 0)
	effectCorner.Parent = collectEffect

	-- Instructions
	local instructions = Instance.new("TextLabel")
	instructions.Name = "Instructions"
	instructions.Size = UDim2.new(0, 450, 0, 40)
	instructions.Position = UDim2.new(0.5, -225, 1, -60)
	instructions.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	instructions.BackgroundTransparency = 0.3
	instructions.BorderSizePixel = 0
	instructions.Text = "🖱️ Cliquez sur les étoiles colorées pour collecter!"
	instructions.TextColor3 = Color3.fromRGB(255, 255, 255)
	instructions.TextSize = 20
	instructions.Font = Enum.Font.Gotham
	instructions.Parent = screenGui

	local instructionsCorner = Instance.new("UICorner")
	instructionsCorner.CornerRadius = UDim.new(0, 10)
	instructionsCorner.Parent = instructions

	-- Faire disparaître les instructions après 10 secondes
	task.delay(10, function()
		TweenService:Create(instructions, TweenInfo.new(1), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		}):Play()
	end)

	return screenGui
end

-- Mettre à jour le score
local function updateScore(value)
	local ui = playerGui:FindFirstChild("GameUI")
	if not ui then return end

	local scoreFrame = ui:FindFirstChild("ScoreFrame")
	if not scoreFrame then return end

	local scoreLabel = scoreFrame:FindFirstChild("ScoreLabel")
	if not scoreLabel then return end

	scoreLabel.Text = tostring(value)

	-- Changer la couleur du gradient
	local hue = (value % 360) / 360
	local color = Color3.fromHSV(hue, 0.6, 0.8)

	local gradient = scoreFrame:FindFirstChild("UIGradient")
	if gradient then
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(1, Color3.new(
				color.R * 0.7,
				color.G * 0.7,
				color.B * 0.7
			))
		})
	end

	-- Animation de pulsation
	TweenService:Create(scoreLabel, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
		TextSize = 46
	}):Play()

	task.wait(0.2)

	TweenService:Create(scoreLabel, TweenInfo.new(0.2), {
		TextSize = 42
	}):Play()
end

-- Montrer l'effet de collecte
local function showCollectEffect(color)
	local ui = playerGui:FindFirstChild("GameUI")
	if not ui then return end

	local effect = ui:FindFirstChild("CollectEffect")
	if not effect then return end

	effect.BackgroundColor3 = color
	effect.BackgroundTransparency = 0
	effect.Size = UDim2.new(0, 0, 0, 0)

	-- Animation d'expansion
	local expandTween = TweenService:Create(effect, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 400, 0, 400),
		BackgroundTransparency = 0.5
	})

	expandTween:Play()
	expandTween.Completed:Wait()

	-- Animation de disparition
	local fadeTween = TweenService:Create(effect, TweenInfo.new(0.3), {
		Size = UDim2.new(0, 500, 0, 500),
		BackgroundTransparency = 1
	})

	fadeTween:Play()
end

-- Camera shake
local function cameraShake()
	local camera = workspace.CurrentCamera
	local originalCFrame = camera.CFrame

	task.spawn(function()
		for i = 1, 5 do
			camera.CFrame = originalCFrame * CFrame.new(
				math.random(-10, 10) / 100,
				math.random(-10, 10) / 100,
				math.random(-10, 10) / 100
			)
			task.wait(0.03)
		end
		camera.CFrame = originalCFrame
	end)
end

-- Initialiser
print("📱 Création de l'interface...")
createUI()

-- Écouter les changements de score
local leaderstats = player:WaitForChild("leaderstats", 10)
if leaderstats then
	local coins = leaderstats:WaitForChild("Coins", 5)

	if coins then
		coins.Changed:Connect(function()
			updateScore(coins.Value)
		end)

		-- Mise à jour initiale
		updateScore(coins.Value)
	end
end

-- Écouter les collectes
coinCollectedEvent.OnClientEvent:Connect(function(amount, color)
	print("💰 Collecté! +" .. amount .. " coins")

	-- Son de collecte avec variation de pitch
	SoundManager.playVariedSound("CoinCollect")

	-- Effets visuels
	showCollectEffect(color)
	cameraShake()
end)

-- Écouter les téléportations de porte
local doorTeleportEvent = remotesFolder:WaitForChild("DoorTeleport", 5)
if doorTeleportEvent then
	doorTeleportEvent.OnClientEvent:Connect(function()
		print("🚪 Téléportation par porte")
		-- Son de téléportation
		SoundManager.playLocalSound("DoorTeleport")
	end)
end

-- Système de boussole
local compassEvent = remotesFolder:WaitForChild("CompassToggle", 5)
local compassGui = nil
local compassVisible = false

if compassEvent then
	compassEvent.OnClientEvent:Connect(function(dx, dy, distance)
		compassVisible = not compassVisible

		if compassVisible then
			if not compassGui then
				-- Créer la boussole
				compassGui = Instance.new("ScreenGui")
				compassGui.Name = "CompassGui"
				compassGui.ResetOnSpawn = false
				compassGui.Parent = playerGui

				-- Cercle de la boussole
				local compassFrame = Instance.new("Frame")
				compassFrame.Name = "CompassFrame"
				compassFrame.Size = UDim2.new(0, 120, 0, 120)
				compassFrame.Position = UDim2.new(0.5, -60, 0.5, -60)
				compassFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
				compassFrame.BorderSizePixel = 0
				compassFrame.Parent = compassGui

				local compassCorner = Instance.new("UICorner")
				compassCorner.CornerRadius = UDim.new(1, 0)
				compassCorner.Parent = compassFrame

				-- Bordure extérieure
				local border = Instance.new("UIStroke")
				border.Color = Color3.fromRGB(255, 200, 50)
				border.Thickness = 3
				border.Parent = compassFrame

				-- Centre de la boussole
				local center = Instance.new("Frame")
				center.Size = UDim2.new(0, 10, 0, 10)
				center.Position = UDim2.new(0.5, -5, 0.5, -5)
				center.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
				center.BorderSizePixel = 0
				center.Parent = compassFrame

				local centerCorner = Instance.new("UICorner")
				centerCorner.CornerRadius = UDim.new(1, 0)
				centerCorner.Parent = center

				-- Flèche pointant vers Z
				local arrow = Instance.new("ImageLabel")
				arrow.Name = "Arrow"
				arrow.Size = UDim2.new(0, 40, 0, 60)
				arrow.Position = UDim2.new(0.5, -20, 0.5, -50)
				arrow.BackgroundTransparency = 1
				arrow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
				arrow.ImageColor3 = Color3.fromRGB(255, 100, 100)
				arrow.Rotation = 0
				arrow.Parent = compassFrame

				-- Créer une flèche triangle personnalisée
				arrow.Image = ""
				local arrowTriangle = Instance.new("Frame")
				arrowTriangle.Size = UDim2.new(0, 20, 0, 40)
				arrowTriangle.Position = UDim2.new(0.5, -10, 0, 0)
				arrowTriangle.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
				arrowTriangle.BorderSizePixel = 0
				arrowTriangle.Rotation = 0
				arrowTriangle.Parent = arrow

				-- Texte de distance
				local distanceLabel = Instance.new("TextLabel")
				distanceLabel.Name = "DistanceLabel"
				distanceLabel.Size = UDim2.new(1, 0, 0, 25)
				distanceLabel.Position = UDim2.new(0, 0, 1, 5)
				distanceLabel.BackgroundTransparency = 1
				distanceLabel.Text = distance .. " salles"
				distanceLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
				distanceLabel.TextSize = 18
				distanceLabel.Font = Enum.Font.GothamBold
				distanceLabel.Parent = compassFrame

				-- Texte "ARRIVÉE"
				local targetLabel = Instance.new("TextLabel")
				targetLabel.Size = UDim2.new(1, 0, 0, 20)
				targetLabel.Position = UDim2.new(0, 0, 0, -25)
				targetLabel.BackgroundTransparency = 1
				targetLabel.Text = "🏆 ARRIVÉE"
				targetLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
				targetLabel.TextSize = 14
				targetLabel.Font = Enum.Font.GothamBold
				targetLabel.Parent = compassFrame
			end

			-- Calculer l'angle de la flèche
			local angle = math.deg(math.atan2(dy, dx))
			local arrow = compassGui.CompassFrame:FindFirstChild("Arrow")
			if arrow then
				arrow.Rotation = angle + 90 -- +90 car l'image pointe vers le haut par défaut
			end

			-- Mettre à jour la distance
			local distanceLabel = compassGui.CompassFrame:FindFirstChild("DistanceLabel")
			if distanceLabel then
				distanceLabel.Text = distance .. " salles"
			end

			compassGui.Enabled = true
			print("🧭 Boussole affichée - Distance:", distance, "salles")
		else
			if compassGui then
				compassGui.Enabled = false
				print("🧭 Boussole cachée")
			end
		end
	end)
end

-- Système de gestion des rounds
local roundStateEvent = remotesFolder:WaitForChild("RoundStateChanged", 5)
local roundUI = nil
local currentRoundNumber = 0
local gameMusic = nil

if roundStateEvent then
	roundStateEvent.OnClientEvent:Connect(function(state, roundNumber, extraData)
		print("🔄 État du round changé:", state, "Round:", roundNumber or "N/A")

		-- Créer l'UI de round si elle n'existe pas
		if not roundUI then
			roundUI = Instance.new("ScreenGui")
			roundUI.Name = "RoundUI"
			roundUI.ResetOnSpawn = false
			roundUI.Parent = playerGui

			-- Frame du round (en haut au centre)
			local roundFrame = Instance.new("Frame")
			roundFrame.Name = "RoundFrame"
			roundFrame.Size = UDim2.new(0, 250, 0, 60)
			roundFrame.Position = UDim2.new(0.5, -125, 0, 20)
			roundFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			roundFrame.BorderSizePixel = 0
			roundFrame.Parent = roundUI

			local roundCorner = Instance.new("UICorner")
			roundCorner.CornerRadius = UDim.new(0, 15)
			roundCorner.Parent = roundFrame

			local roundGradient = Instance.new("UIGradient")
			roundGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
			})
			roundGradient.Rotation = 45
			roundGradient.Parent = roundFrame

			-- Label du numéro de round
			local roundNumberLabel = Instance.new("TextLabel")
			roundNumberLabel.Name = "RoundNumberLabel"
			roundNumberLabel.Size = UDim2.new(1, -20, 0, 30)
			roundNumberLabel.Position = UDim2.new(0, 10, 0, 5)
			roundNumberLabel.BackgroundTransparency = 1
			roundNumberLabel.Text = "ROUND 1"
			roundNumberLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
			roundNumberLabel.TextSize = 24
			roundNumberLabel.Font = Enum.Font.GothamBold
			roundNumberLabel.Parent = roundFrame

			-- Label d'état
			local stateLabel = Instance.new("TextLabel")
			stateLabel.Name = "StateLabel"
			stateLabel.Size = UDim2.new(1, -20, 0, 20)
			stateLabel.Position = UDim2.new(0, 10, 0, 35)
			stateLabel.BackgroundTransparency = 1
			stateLabel.Text = "En cours..."
			stateLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			stateLabel.TextSize = 16
			stateLabel.Font = Enum.Font.Gotham
			stateLabel.Parent = roundFrame
		end

		-- Mettre à jour l'UI selon l'état
		local roundFrame = roundUI:FindFirstChild("RoundFrame")
		if roundFrame then
			local roundNumberLabel = roundFrame:FindFirstChild("RoundNumberLabel")
			local stateLabel = roundFrame:FindFirstChild("StateLabel")
			local gradient = roundFrame:FindFirstChild("UIGradient")

			if state == "STARTED" then
				currentRoundNumber = roundNumber

				-- Son de démarrage du round
				SoundManager.playLocalSound("RoundStart")

				-- Démarrer la musique d'ambiance
				if not gameMusic then
					gameMusic = SoundManager.createLoopingMusic("GameMusic")
				end
				if gameMusic then
					SoundManager.fadeIn(gameMusic, 2)
				end

				if roundNumberLabel then
					roundNumberLabel.Text = "ROUND " .. roundNumber
				end
				if stateLabel then
					stateLabel.Text = "🎮 En cours..."
					stateLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
				end
				if gradient then
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 100, 60)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 80, 40))
					})
				end

			elseif state == "ENDED" then
				-- Fade out de la musique d'ambiance
				if gameMusic then
					SoundManager.fadeOut(gameMusic, 2)
				end

				if roundNumberLabel then
					roundNumberLabel.Text = "ROUND " .. currentRoundNumber
				end
				if stateLabel then
					stateLabel.Text = "🏆 Terminé! Gagnant: " .. (extraData or "???")
					stateLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
				end
				if gradient then
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 80, 40)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 60, 30))
					})
				end

			elseif state == "WAITING" then
				if roundNumberLabel then
					roundNumberLabel.Text = "PROCHAIN ROUND"
				end
				if stateLabel then
					-- Démarrer le compte à rebours
					local waitTime = extraData or 15
					task.spawn(function()
						for i = waitTime, 1, -1 do
							if stateLabel then
								stateLabel.Text = "⏱️ Démarre dans " .. i .. "s..."
								stateLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
							end
							task.wait(1)
						end
					end)
				end
				if gradient then
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
					})
				end
			end
		end
	end)
end

-- Attendre l'événement de fin de partie
local gameEndedEvent = remotesFolder:WaitForChild("GameEnded", 5)
if gameEndedEvent then
	gameEndedEvent.OnClientEvent:Connect(function(winnerName, leaderboard)
		print("🏆 Fin de round! Gagnant:", winnerName)

		-- Jouer le son de victoire
		SoundManager.playLocalSound("Victory")

		-- Créer l'écran de fin
		local endScreenGui = Instance.new("ScreenGui")
		endScreenGui.Name = "EndScreen"
		endScreenGui.ResetOnSpawn = false
		endScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		endScreenGui.Parent = playerGui

		-- Fond sombre
		local overlay = Instance.new("Frame")
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 0.3
		overlay.BorderSizePixel = 0
		overlay.Parent = endScreenGui

		-- Frame principale
		local mainFrame = Instance.new("Frame")
		mainFrame.Size = UDim2.new(0, 600, 0, 500)
		mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
		mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		mainFrame.BorderSizePixel = 0
		mainFrame.Parent = endScreenGui

		local mainCorner = Instance.new("UICorner")
		mainCorner.CornerRadius = UDim.new(0, 20)
		mainCorner.Parent = mainFrame

		-- Titre
		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -40, 0, 80)
		title.Position = UDim2.new(0, 20, 0, 20)
		title.BackgroundTransparency = 1
		title.Text = "🏆 FIN DE PARTIE 🏆"
		title.TextColor3 = Color3.fromRGB(255, 220, 100)
		title.TextSize = 36
		title.Font = Enum.Font.GothamBold
		title.Parent = mainFrame

		-- Sous-titre avec le gagnant
		local subtitle = Instance.new("TextLabel")
		subtitle.Size = UDim2.new(1, -40, 0, 40)
		subtitle.Position = UDim2.new(0, 20, 0, 100)
		subtitle.BackgroundTransparency = 1
		subtitle.Text = winnerName .. " a atteint la zone de fin!"
		subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
		subtitle.TextSize = 20
		subtitle.Font = Enum.Font.Gotham
		subtitle.Parent = mainFrame

		-- Ligne de séparation
		local separator = Instance.new("Frame")
		separator.Size = UDim2.new(1, -40, 0, 2)
		separator.Position = UDim2.new(0, 20, 0, 150)
		separator.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
		separator.BorderSizePixel = 0
		separator.Parent = mainFrame

		-- Classement
		local leaderboardTitle = Instance.new("TextLabel")
		leaderboardTitle.Size = UDim2.new(1, -40, 0, 30)
		leaderboardTitle.Position = UDim2.new(0, 20, 0, 160)
		leaderboardTitle.BackgroundTransparency = 1
		leaderboardTitle.Text = "CLASSEMENT"
		leaderboardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		leaderboardTitle.TextSize = 24
		leaderboardTitle.Font = Enum.Font.GothamBold
		leaderboardTitle.TextXAlignment = Enum.TextXAlignment.Left
		leaderboardTitle.Parent = mainFrame

		-- Liste des joueurs
		local yOffset = 200
		for i, entry in ipairs(leaderboard) do
			local rankFrame = Instance.new("Frame")
			rankFrame.Size = UDim2.new(1, -40, 0, 50)
			rankFrame.Position = UDim2.new(0, 20, 0, yOffset)
			rankFrame.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(60, 60, 70)
			rankFrame.BorderSizePixel = 0
			rankFrame.Parent = mainFrame

			local rankCorner = Instance.new("UICorner")
			rankCorner.CornerRadius = UDim.new(0, 10)
			rankCorner.Parent = rankFrame

			-- Numéro de rang
			local rankNumber = Instance.new("TextLabel")
			rankNumber.Size = UDim2.new(0, 50, 1, 0)
			rankNumber.BackgroundTransparency = 1
			rankNumber.Text = i .. "."
			rankNumber.TextColor3 = i == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
			rankNumber.TextSize = 24
			rankNumber.Font = Enum.Font.GothamBold
			rankNumber.Parent = rankFrame

			-- Nom du joueur
			local playerName = Instance.new("TextLabel")
			playerName.Size = UDim2.new(0, 250, 1, 0)
			playerName.Position = UDim2.new(0, 60, 0, 0)
			playerName.BackgroundTransparency = 1
			playerName.Text = entry.player.Name
			playerName.TextColor3 = i == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
			playerName.TextSize = 20
			playerName.Font = Enum.Font.GothamBold
			playerName.TextXAlignment = Enum.TextXAlignment.Left
			playerName.Parent = rankFrame

			-- Score
			local score = Instance.new("TextLabel")
			score.Size = UDim2.new(0, 150, 1, 0)
			score.Position = UDim2.new(1, -160, 0, 0)
			score.BackgroundTransparency = 1
			score.Text = entry.coins .. " coins"
			score.TextColor3 = i == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
			score.TextSize = 18
			score.Font = Enum.Font.Gotham
			score.TextXAlignment = Enum.TextXAlignment.Right
			score.Parent = rankFrame

			yOffset = yOffset + 60

			-- Limiter à 5 joueurs affichés
			if i >= 5 then break end
		end

		-- Créer le timer professionnel en bas de l'écran
		local timerFrame = Instance.new("Frame")
		timerFrame.Name = "TimerFrame"
		timerFrame.Size = UDim2.new(0, 400, 0, 80)
		timerFrame.Position = UDim2.new(0.5, -200, 1, -100)
		timerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		timerFrame.BorderSizePixel = 0
		timerFrame.Parent = endScreenGui

		local timerCorner = Instance.new("UICorner")
		timerCorner.CornerRadius = UDim.new(0, 15)
		timerCorner.Parent = timerFrame

		-- Bordure du timer
		local timerStroke = Instance.new("UIStroke")
		timerStroke.Color = Color3.fromRGB(100, 100, 120)
		timerStroke.Thickness = 2
		timerStroke.Parent = timerFrame

		-- Icône horloge
		local clockIcon = Instance.new("TextLabel")
		clockIcon.Size = UDim2.new(0, 40, 0, 40)
		clockIcon.Position = UDim2.new(0, 15, 0.5, -20)
		clockIcon.BackgroundTransparency = 1
		clockIcon.Text = "⏱️"
		clockIcon.TextSize = 32
		clockIcon.Font = Enum.Font.GothamBold
		clockIcon.Parent = timerFrame

		-- Texte du timer
		local timerLabel = Instance.new("TextLabel")
		timerLabel.Name = "TimerLabel"
		timerLabel.Size = UDim2.new(1, -70, 0, 30)
		timerLabel.Position = UDim2.new(0, 60, 0, 5)
		timerLabel.BackgroundTransparency = 1
		timerLabel.Text = "Prochain round dans..."
		timerLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
		timerLabel.TextSize = 16
		timerLabel.Font = Enum.Font.Gotham
		timerLabel.TextXAlignment = Enum.TextXAlignment.Left
		timerLabel.Parent = timerFrame

		-- Compte à rebours
		local countdownLabel = Instance.new("TextLabel")
		countdownLabel.Name = "CountdownLabel"
		countdownLabel.Size = UDim2.new(1, -70, 0, 35)
		countdownLabel.Position = UDim2.new(0, 60, 0, 40)
		countdownLabel.BackgroundTransparency = 1
		countdownLabel.Text = "30"
		countdownLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		countdownLabel.TextSize = 32
		countdownLabel.Font = Enum.Font.GothamBold
		countdownLabel.TextXAlignment = Enum.TextXAlignment.Left
		countdownLabel.Parent = timerFrame

		-- Barre de progression
		local progressBarBg = Instance.new("Frame")
		progressBarBg.Size = UDim2.new(1, -30, 0, 6)
		progressBarBg.Position = UDim2.new(0, 15, 1, -12)
		progressBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		progressBarBg.BorderSizePixel = 0
		progressBarBg.Parent = timerFrame

		local progressBarBgCorner = Instance.new("UICorner")
		progressBarBgCorner.CornerRadius = UDim.new(1, 0)
		progressBarBgCorner.Parent = progressBarBg

		local progressBar = Instance.new("Frame")
		progressBar.Name = "ProgressBar"
		progressBar.Size = UDim2.new(1, 0, 1, 0)
		progressBar.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		progressBar.BorderSizePixel = 0
		progressBar.Parent = progressBarBg

		local progressBarCorner = Instance.new("UICorner")
		progressBarCorner.CornerRadius = UDim.new(1, 0)
		progressBarCorner.Parent = progressBar

		-- Animation du compte à rebours
		task.spawn(function()
			for i = 30, 1, -1 do
				if countdownLabel then
					countdownLabel.Text = tostring(i) .. "s"

					-- Sons du timer
					if i == 10 then
						-- Son d'alerte à 10 secondes
						SoundManager.playLocalSound("TimerWarning")
					elseif i <= 10 then
						-- Tick plus fort dans les dernières secondes
						SoundManager.playLocalSound("TimerTick")
					end

					-- Animation de pulsation
					TweenService:Create(countdownLabel, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
						TextSize = 36
					}):Play()
					task.wait(0.2)
					TweenService:Create(countdownLabel, TweenInfo.new(0.3), {
						TextSize = 32
					}):Play()

					-- Mettre à jour la barre de progression
					local progress = i / 30
					TweenService:Create(progressBar, TweenInfo.new(1, Enum.EasingStyle.Linear), {
						Size = UDim2.new(progress, 0, 1, 0)
					}):Play()

					-- Changer la couleur quand il reste moins de 10 secondes
					if i <= 10 then
						progressBar.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
						countdownLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
					end

					task.wait(0.8)
				end
			end

			-- Fermer l'écran à la fin
			if endScreenGui and endScreenGui.Parent then
				print("🗑️ Fermeture automatique de l'écran de fin")
				-- Animer le fond et la frame principale pour disparaître
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
				if timerFrame then
					TweenService:Create(timerFrame, TweenInfo.new(0.5), {
						BackgroundTransparency = 1
					}):Play()
				end
				task.wait(0.5)
				endScreenGui:Destroy()
			end
		end)
	end)
end

-- Créer l'UI admin si le joueur est admin
task.spawn(function()
	task.wait(3) -- Attendre que l'attribut soit défini

	if player:GetAttribute("IsAdmin") then
		print("👑 Mode admin activé")

		-- Créer l'UI admin
		local adminGui = Instance.new("ScreenGui")
		adminGui.Name = "AdminUI"
		adminGui.ResetOnSpawn = false
		adminGui.Parent = playerGui

		-- Badge admin en haut
		local adminBadge = Instance.new("Frame")
		adminBadge.Size = UDim2.new(0, 150, 0, 40)
		adminBadge.Position = UDim2.new(0, 20, 0, 20)
		adminBadge.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		adminBadge.BorderSizePixel = 0
		adminBadge.Parent = adminGui

		local badgeCorner = Instance.new("UICorner")
		badgeCorner.CornerRadius = UDim.new(0, 10)
		badgeCorner.Parent = adminBadge

		local badgeLabel = Instance.new("TextLabel")
		badgeLabel.Size = UDim2.new(1, 0, 1, 0)
		badgeLabel.BackgroundTransparency = 1
		badgeLabel.Text = "👑 ADMIN"
		badgeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		badgeLabel.TextSize = 20
		badgeLabel.Font = Enum.Font.GothamBold
		badgeLabel.Parent = adminBadge

		-- Panneau de commandes
		local commandPanel = Instance.new("Frame")
		commandPanel.Size = UDim2.new(0, 350, 0, 500)
		commandPanel.Position = UDim2.new(0, 20, 0, 70)
		commandPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		commandPanel.BackgroundTransparency = 0.1
		commandPanel.BorderSizePixel = 0
		commandPanel.Visible = false -- Caché par défaut
		commandPanel.Parent = adminGui

		local panelCorner = Instance.new("UICorner")
		panelCorner.CornerRadius = UDim.new(0, 15)
		panelCorner.Parent = commandPanel

		-- Titre du panneau
		local panelTitle = Instance.new("TextLabel")
		panelTitle.Size = UDim2.new(1, -20, 0, 40)
		panelTitle.Position = UDim2.new(0, 10, 0, 10)
		panelTitle.BackgroundTransparency = 1
		panelTitle.Text = "COMMANDES ADMIN"
		panelTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
		panelTitle.TextSize = 22
		panelTitle.Font = Enum.Font.GothamBold
		panelTitle.TextXAlignment = Enum.TextXAlignment.Left
		panelTitle.Parent = commandPanel

		-- Liste des commandes
		local commandsList = {
			{cmd = "/help", desc = "Afficher toutes les commandes"},
			{cmd = "/compass", desc = "Toggle boussole vers arrivée"},
			{cmd = "/tp [x] [y]", desc = "Téléporter à une salle"},
			{cmd = "/pos", desc = "Afficher ta position"},
			{cmd = "/showgrid", desc = "Afficher la grille"},
			{cmd = "/players", desc = "Lister tous les joueurs"},
			{cmd = "/setcoins [n]", desc = "Définir ton score"},
			{cmd = "/givecoins [nom] [n]", desc = "Donner des coins"},
			{cmd = "/endgame", desc = "Terminer la partie"},
		}

		local yPos = 60
		for i, cmdData in ipairs(commandsList) do
			local cmdFrame = Instance.new("Frame")
			cmdFrame.Size = UDim2.new(1, -20, 0, 45)
			cmdFrame.Position = UDim2.new(0, 10, 0, yPos)
			cmdFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			cmdFrame.BorderSizePixel = 0
			cmdFrame.Parent = commandPanel

			local cmdCorner = Instance.new("UICorner")
			cmdCorner.CornerRadius = UDim.new(0, 8)
			cmdCorner.Parent = cmdFrame

			local cmdLabel = Instance.new("TextLabel")
			cmdLabel.Size = UDim2.new(1, -10, 0, 20)
			cmdLabel.Position = UDim2.new(0, 5, 0, 3)
			cmdLabel.BackgroundTransparency = 1
			cmdLabel.Text = cmdData.cmd
			cmdLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
			cmdLabel.TextSize = 16
			cmdLabel.Font = Enum.Font.GothamBold
			cmdLabel.TextXAlignment = Enum.TextXAlignment.Left
			cmdLabel.Parent = cmdFrame

			local descLabel = Instance.new("TextLabel")
			descLabel.Size = UDim2.new(1, -10, 0, 18)
			descLabel.Position = UDim2.new(0, 5, 0, 23)
			descLabel.BackgroundTransparency = 1
			descLabel.Text = cmdData.desc
			descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			descLabel.TextSize = 13
			descLabel.Font = Enum.Font.Gotham
			descLabel.TextXAlignment = Enum.TextXAlignment.Left
			descLabel.Parent = cmdFrame

			yPos = yPos + 50
		end

		-- Info en bas
		local infoLabel = Instance.new("TextLabel")
		infoLabel.Size = UDim2.new(1, -20, 0, 30)
		infoLabel.Position = UDim2.new(0, 10, 1, -40)
		infoLabel.BackgroundTransparency = 1
		infoLabel.Text = "💡 Tape les commandes dans le chat"
		infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		infoLabel.TextSize = 14
		infoLabel.Font = Enum.Font.Gotham
		infoLabel.Parent = commandPanel

		-- Toggle du panneau avec le badge
		local panelOpen = false
		adminBadge.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				panelOpen = not panelOpen
				commandPanel.Visible = panelOpen
			end
		end)

		print("✅ UI Admin créée")
	end
end)

print("✅ === CLIENT PRÊT ===")
print("🎮 Prêt à jouer!")
