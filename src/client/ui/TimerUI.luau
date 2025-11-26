--[[
	TimerUI - Timer de compte à rebours
	Affiche un timer animé sur l'écran de fin
]]

local TweenService = game:GetService("TweenService")

local TimerUI = {}

-- Créer et afficher le timer sur un ScreenGui
function TimerUI.create(parentGui, duration, onTick, onComplete)
	duration = duration or 30

	-- Créer le timer professionnel en bas de l'écran
	local timerFrame = Instance.new("Frame")
	timerFrame.Name = "TimerFrame"
	timerFrame.Size = UDim2.new(0, 400, 0, 80)
	timerFrame.Position = UDim2.new(0.5, -200, 1, -100)
	timerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	timerFrame.BorderSizePixel = 0
	timerFrame.Parent = parentGui

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
	countdownLabel.Text = duration .. "s"
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
		for i = duration, 1, -1 do
			if countdownLabel then
				countdownLabel.Text = tostring(i) .. "s"

				-- Callback optionnel
				if onTick then
					onTick(i)
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
				local progress = i / duration
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

		-- Callback de fin
		if onComplete then
			onComplete()
		end
	end)

	return timerFrame
end

return TimerUI
