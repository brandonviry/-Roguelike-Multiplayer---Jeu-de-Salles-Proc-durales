--[[
	EndScreenUI - Écran de fin de round
	Affiche le classement et le timer avant le prochain round
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local EndScreenUI = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Créer et afficher l'écran de fin
function EndScreenUI.show(winnerName, leaderboard)
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
		local playerNameLabel = Instance.new("TextLabel")
		playerNameLabel.Size = UDim2.new(0, 250, 1, 0)
		playerNameLabel.Position = UDim2.new(0, 60, 0, 0)
		playerNameLabel.BackgroundTransparency = 1
		playerNameLabel.Text = entry.player.Name
		playerNameLabel.TextColor3 = i == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
		playerNameLabel.TextSize = 20
		playerNameLabel.Font = Enum.Font.GothamBold
		playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		playerNameLabel.Parent = rankFrame

		-- Score
		local scoreLabel = Instance.new("TextLabel")
		scoreLabel.Size = UDim2.new(0, 150, 1, 0)
		scoreLabel.Position = UDim2.new(1, -160, 0, 0)
		scoreLabel.BackgroundTransparency = 1
		scoreLabel.Text = entry.coins .. " coins"
		scoreLabel.TextColor3 = i == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
		scoreLabel.TextSize = 18
		scoreLabel.Font = Enum.Font.Gotham
		scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
		scoreLabel.Parent = rankFrame

		yOffset = yOffset + 60

		-- Limiter à 5 joueurs affichés
		if i >= 5 then break end
	end

	-- Créer le timer (voir TimerUI)
	return endScreenGui, overlay, mainFrame
end

return EndScreenUI
