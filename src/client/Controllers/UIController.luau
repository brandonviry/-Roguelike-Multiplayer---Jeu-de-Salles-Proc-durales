--[[
	UIController
	Gère toute l'interface utilisateur
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local UIController = {}
UIController.ScreenGui = nil
UIController.Elements = {}

-- Initialiser l'UI
function UIController:Init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	self.ScreenGui = self:CreateScreenGui(playerGui)
	self:SetupScoreTracking(player)

	print("✅ UIController initialisé")
end

-- Créer le ScreenGui principal
function UIController:CreateScreenGui(playerGui)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Frame de score
	self.Elements.ScoreFrame = self:CreateScoreFrame(screenGui)

	-- Frame de streak
	self.Elements.StreakFrame = self:CreateStreakFrame(screenGui)

	-- Effet de collecte
	self.Elements.CollectEffect = self:CreateCollectEffect(screenGui)

	-- Instructions
	self.Elements.Instructions = self:CreateInstructions(screenGui)

	return screenGui
end

-- Créer la frame de score
function UIController:CreateScoreFrame(parent)
	local frame = Instance.new("Frame")
	frame.Name = "ScoreFrame"
	frame.Size = UDim2.new(0, 250, 0, 100)
	frame.Position = UDim2.new(0.5, -125, 0, 20)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = frame

	-- Gradient
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
	})
	gradient.Rotation = 45
	gradient.Parent = frame

	-- Label de score
	local scoreLabel = Instance.new("TextLabel")
	scoreLabel.Name = "ScoreLabel"
	scoreLabel.Size = UDim2.new(1, 0, 0.7, 0)
	scoreLabel.Position = UDim2.new(0, 0, 0, 0)
	scoreLabel.BackgroundTransparency = 1
	scoreLabel.Text = "0"
	scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	scoreLabel.TextSize = 48
	scoreLabel.Font = Enum.Font.GothamBold
	scoreLabel.TextStrokeTransparency = 0.8
	scoreLabel.Parent = frame

	-- Label de titre
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
	titleLabel.Position = UDim2.new(0, 0, 0.7, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "COINS"
	titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.Parent = frame

	return frame
end

-- Créer la frame de streak
function UIController:CreateStreakFrame(parent)
	local frame = Instance.new("Frame")
	frame.Name = "StreakFrame"
	frame.Size = UDim2.new(0, 250, 0, 60)
	frame.Position = UDim2.new(0.5, -125, 0, 130)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	-- Créer 5 indicateurs de streak
	for i = 1, 5 do
		local indicator = Instance.new("Frame")
		indicator.Name = "Indicator" .. i
		indicator.Size = UDim2.new(0, 40, 0, 40)
		indicator.Position = UDim2.new(0, (i - 1) * 50, 0, 10)
		indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		indicator.BorderSizePixel = 0
		indicator.Parent = frame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = indicator

		-- Effet de glow
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Name = "Glow"
		uiStroke.Color = Color3.fromRGB(255, 255, 255)
		uiStroke.Thickness = 0
		uiStroke.Transparency = 1
		uiStroke.Parent = indicator
	end

	return frame
end

-- Créer l'effet de collecte
function UIController:CreateCollectEffect(parent)
	local effect = Instance.new("Frame")
	effect.Name = "CollectEffect"
	effect.Size = UDim2.new(0, 0, 0, 0)
	effect.Position = UDim2.new(0.5, 0, 0.5, 0)
	effect.AnchorPoint = Vector2.new(0.5, 0.5)
	effect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	effect.BorderSizePixel = 0
	effect.BackgroundTransparency = 1
	effect.ZIndex = 10
	effect.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = effect

	return effect
end

-- Créer les instructions
function UIController:CreateInstructions(parent)
	local label = Instance.new("TextLabel")
	label.Name = "Instructions"
	label.Size = UDim2.new(0, 400, 0, 50)
	label.Position = UDim2.new(0.5, -200, 1, -70)
	label.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	label.BackgroundTransparency = 0.3
	label.BorderSizePixel = 0
	label.Text = "Cliquez sur les étoiles colorées pour collecter !"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 20
	label.Font = Enum.Font.Gotham
	label.TextStrokeTransparency = 0.8
	label.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label

	-- Faire disparaître après 10 secondes
	task.delay(10, function()
		TweenService:Create(label, TweenInfo.new(1), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		}):Play()
	end)

	return label
end

-- Configurer le tracking du score
function UIController:SetupScoreTracking(player)
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then return end

	local coins = leaderstats:WaitForChild("Coins", 5)
	local streak = leaderstats:WaitForChild("Streak", 5)

	if coins then
		coins.Changed:Connect(function()
			self:UpdateScore(coins.Value)
		end)
		self:UpdateScore(coins.Value)
	end

	if streak then
		streak.Changed:Connect(function()
			self:UpdateStreak(streak.Value)
		end)
		self:UpdateStreak(streak.Value)
	end
end

-- Mettre à jour le score
function UIController:UpdateScore(value)
	local scoreLabel = self.Elements.ScoreFrame:FindFirstChild("ScoreLabel")
	if not scoreLabel then return end

	scoreLabel.Text = tostring(value)

	-- Changer la couleur du gradient
	local hue = (value % 360) / 360
	local color = Color3.fromHSV(hue, 0.6, 0.8)

	local gradient = self.Elements.ScoreFrame:FindFirstChild("UIGradient")
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
	local tween = TweenService:Create(scoreLabel, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
		TextSize = 52
	})
	tween:Play()
	tween.Completed:Wait()

	TweenService:Create(scoreLabel, TweenInfo.new(0.2), {
		TextSize = 48
	}):Play()
end

-- Mettre à jour le streak
function UIController:UpdateStreak(value)
	local streakValue = math.min(value, 5)

	for i = 1, 5 do
		local indicator = self.Elements.StreakFrame:FindFirstChild("Indicator" .. i)
		if indicator then
			local glow = indicator:FindFirstChild("Glow")

			if i <= streakValue then
				local hue = (i - 1) / 5
				local color = Color3.fromHSV(hue, 1, 1)

				TweenService:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
					BackgroundColor3 = color
				}):Play()

				if glow then
					glow.Color = color
					TweenService:Create(glow, TweenInfo.new(0.3), {
						Thickness = 3,
						Transparency = 0.3
					}):Play()
				end
			else
				TweenService:Create(indicator, TweenInfo.new(0.3), {
					BackgroundColor3 = Color3.fromRGB(60, 60, 70)
				}):Play()

				if glow then
					TweenService:Create(glow, TweenInfo.new(0.3), {
						Thickness = 0,
						Transparency = 1
					}):Play()
				end
			end
		end
	end
end

-- Montrer l'effet de collecte
function UIController:ShowCollectEffect(color)
	local effect = self.Elements.CollectEffect
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

return UIController
