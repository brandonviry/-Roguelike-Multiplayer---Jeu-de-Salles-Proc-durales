--[[
	RoundUI - Interface des rounds
	Affiche le numéro de round et l'état en haut de l'écran
]]

local Players = game:GetService("Players")

local RoundUI = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local roundUI = nil
local roundFrame = nil

-- Créer l'interface de round
function RoundUI.create()
	roundUI = Instance.new("ScreenGui")
	roundUI.Name = "RoundUI"
	roundUI.ResetOnSpawn = false
	roundUI.Parent = playerGui

	-- Frame du round (en haut au centre)
	roundFrame = Instance.new("Frame")
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
	roundGradient.Name = "UIGradient"
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

	print("✅ RoundUI créée")
	return roundUI
end

-- Mettre à jour l'affichage du round
function RoundUI.updateState(state, roundNumber, extraData)
	if not roundFrame then return end

	local roundNumberLabel = roundFrame:FindFirstChild("RoundNumberLabel")
	local stateLabel = roundFrame:FindFirstChild("StateLabel")
	local gradient = roundFrame:FindFirstChild("UIGradient")

	if state == "STARTED" then
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
		if gradient then
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
			})
		end

		-- Compte à rebours dans le stateLabel
		if stateLabel then
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
	end
end

return RoundUI
