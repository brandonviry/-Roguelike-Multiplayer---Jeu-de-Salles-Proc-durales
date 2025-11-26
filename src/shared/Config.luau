--[[
	Configuration globale du jeu
	Partagée entre serveur et client
]]

local Config = {}

-- Configuration du gameplay
Config.Gameplay = {
	COIN_VALUE = 10,
	SPAWN_INTERVAL = 2,
	MAX_COINS = 12,
	COIN_LIFETIME = 30, -- Secondes avant qu'une pièce disparaisse
	CLICK_DISTANCE = 20,
}

-- Couleurs des pièces
Config.Colors = {
	COINS = {
		Color3.fromRGB(255, 200, 50),   -- Doré
		Color3.fromRGB(80, 200, 255),   -- Bleu ciel
		Color3.fromRGB(255, 100, 200),  -- Rose
		Color3.fromRGB(150, 255, 100),  -- Vert pomme
		Color3.fromRGB(200, 100, 255),  -- Violet
	},

	ENVIRONMENT = {
		FLOOR = Color3.fromRGB(100, 180, 100),
		BORDER = Color3.fromRGB(80, 140, 80),
		SPAWN = Color3.fromRGB(100, 150, 255),
		TREE_TRUNK = Color3.fromRGB(120, 80, 60),
		TREE_LEAVES = Color3.fromRGB(80, 160, 80),
	}
}

-- Configuration de l'environnement
Config.World = {
	FLOOR_SIZE = Vector3.new(100, 2, 100),
	SPAWN_AREA = {
		MIN = Vector3.new(-35, 6, -35),
		MAX = Vector3.new(35, 14, 35),
	},
	TREE_COUNT = 6,
	TREE_DISTANCE = 40,
}

-- Configuration des animations
Config.Animation = {
	COIN_ROTATION_SPEED = 2,
	COIN_FLOAT_SPEED = 2,
	COIN_FLOAT_AMPLITUDE = 0.5,
}

return Config
