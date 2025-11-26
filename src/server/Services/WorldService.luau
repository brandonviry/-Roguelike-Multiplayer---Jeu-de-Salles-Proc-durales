--[[
	WorldService
	Gère la création de l'environnement du jeu
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage.Shared.Config)

local WorldService = {}

-- Initialiser le monde
function WorldService:Init()
	self:CreateEnvironment()
	self:SetupLighting()
	print("✅ WorldService initialisé")
end

-- Créer l'environnement
function WorldService:CreateEnvironment()
	-- Sol
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Config.World.FLOOR_SIZE
	floor.Position = Vector3.new(0, -1, 0)
	floor.Anchored = true
	floor.Material = Enum.Material.SmoothPlastic
	floor.Color = Config.Colors.ENVIRONMENT.FLOOR
	floor.CastShadow = true
	floor.Parent = workspace

	-- Bordures
	for i = 1, 4 do
		local border = Instance.new("Part")
		border.Name = "Border" .. i
		border.Anchored = true
		border.Material = Enum.Material.SmoothPlastic
		border.Color = Config.Colors.ENVIRONMENT.BORDER
		border.CastShadow = true

		if i == 1 or i == 2 then
			border.Size = Vector3.new(104, 3, 2)
			border.Position = Vector3.new(0, 0.5, i == 1 and -51 or 51)
		else
			border.Size = Vector3.new(2, 3, 104)
			border.Position = Vector3.new(i == 3 and -51 or 51, 0.5, 0)
		end

		border.Parent = workspace
	end

	-- Spawn
	local spawn = Instance.new("SpawnLocation")
	spawn.Position = Vector3.new(0, 1.5, 0)
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Anchored = true
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Color = Config.Colors.ENVIRONMENT.SPAWN
	spawn.Transparency = 0
	spawn.CanCollide = false
	spawn.CastShadow = true
	spawn.Parent = workspace

	-- Arbres décoratifs
	for i = 1, Config.World.TREE_COUNT do
		self:CreateTree(i)
	end
end

-- Créer un arbre
function WorldService:CreateTree(index)
	local tree = Instance.new("Model")
	tree.Name = "Tree" .. index

	-- Tronc
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(1.5, 4, 1.5)
	trunk.Material = Enum.Material.SmoothPlastic
	trunk.Color = Config.Colors.ENVIRONMENT.TREE_TRUNK
	trunk.Anchored = true
	trunk.CastShadow = true
	trunk.Parent = tree

	-- Feuillage
	local leaves = Instance.new("Part")
	leaves.Name = "Leaves"
	leaves.Shape = Enum.PartType.Ball
	leaves.Size = Vector3.new(4, 4, 4)
	leaves.Material = Enum.Material.SmoothPlastic
	leaves.Color = Config.Colors.ENVIRONMENT.TREE_LEAVES
	leaves.Anchored = true
	leaves.CastShadow = true
	leaves.Parent = tree

	-- Position
	local angle = math.rad(index * 60)
	local distance = Config.World.TREE_DISTANCE
	local posX = math.cos(angle) * distance
	local posZ = math.sin(angle) * distance

	trunk.Position = Vector3.new(posX, 2, posZ)
	leaves.Position = Vector3.new(posX, 5, posZ)

	tree.Parent = workspace
end

-- Configurer l'éclairage
function WorldService:SetupLighting()
	Lighting.Brightness = 2.5
	Lighting.Ambient = Color3.fromRGB(150, 150, 170)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 170)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 240, 220)
	Lighting.GlobalShadows = true
	Lighting.Technology = Enum.Technology.ShadowMap

	-- Atmosphère
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.3
	atmosphere.Offset = 0.5
	atmosphere.Color = Color3.fromRGB(200, 220, 255)
	atmosphere.Decay = Color3.fromRGB(100, 120, 150)
	atmosphere.Glare = 0.2
	atmosphere.Haze = 1.5
	atmosphere.Parent = Lighting

	-- Bloom
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.3
	bloom.Size = 20
	bloom.Threshold = 0.8
	bloom.Parent = Lighting
end

return WorldService
