--[[
	AdminUI - Interface administrateur
	Affiche le panneau de commandes admin
]]

local Players = game:GetService("Players")

local AdminUI = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Créer l'interface admin
function AdminUI.create()
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
	for _, cmdData in ipairs(commandsList) do
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

	print("✅ AdminUI créée")
	return adminGui
end

return AdminUI
