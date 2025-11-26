--[[
	CollectEffects - Effets visuels de collecte
	Gère les animations visuelles quand on collecte une pièce
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local CollectEffects = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Afficher l'effet de cercle coloré
function CollectEffects.showCircle(color)
	local gameUI = playerGui:FindFirstChild("GameUI")
	if not gameUI then return end

	local effect = gameUI:FindFirstChild("CollectEffect")
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

return CollectEffects
