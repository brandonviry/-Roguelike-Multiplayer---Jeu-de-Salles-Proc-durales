--[[
	CompassUI - Interface de boussole
	Affiche une boussole pointant vers l'arrivée (zone Z)
]]

local Players = game:GetService("Players")

local CompassUI = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local compassGui = nil
local compassVisible = false

-- Créer ou mettre à jour la boussole
function CompassUI.toggle(dx, dy, distance)
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
			arrow.Image = ""
			arrow.Rotation = 0
			arrow.Parent = compassFrame

			-- Créer une flèche triangle personnalisée
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
end

return CompassUI
