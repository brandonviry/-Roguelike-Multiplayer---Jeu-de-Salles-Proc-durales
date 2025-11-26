--[[
	ScoreUI - Interface de score
	Affiche et anime le score du joueur en haut à droite
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ScoreUI = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = nil

-- Créer l'interface de score
function ScoreUI.create()
	screenGui = Instance.new("ScreenGui")
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

	-- Label de score
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

	-- Label "COINS"
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

	print("✅ ScoreUI créée")
	return screenGui
end

-- Mettre à jour le score avec animation
function ScoreUI.update(value)
	if not screenGui then return end

	local scoreFrame = screenGui:FindFirstChild("ScoreFrame")
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

return ScoreUI
