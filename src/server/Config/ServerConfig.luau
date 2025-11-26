--[[
	Configuration centralisée du serveur
	Toutes les constantes du jeu en un seul endroit
]]

local ServerConfig = {}

-- Configuration du système de grille
ServerConfig.Grid = {
	SIZE = 12,              -- Taille de la grille (12x12)
	ROOM_SIZE = 50,         -- Taille d'une salle (studs)
	ROOM_SPACING = 50,      -- Espacement entre salles (studs)
	MIN_PATH_LENGTH = 10,   -- Distance minimum entre O et Z
}

-- Configuration du gameplay
ServerConfig.Gameplay = {
	COIN_VALUE = 10,                -- Points par pièce collectée
	MIN_COINS_PER_ROOM = 3,         -- Minimum de pièces par salle
	MAX_COINS_PER_ROOM = 8,         -- Maximum de pièces par salle
	MIN_OBSTACLES = 0,              -- Minimum d'obstacles par salle
	MAX_OBSTACLES = 5,              -- Maximum d'obstacles par salle
	DOOR_SIZE = Vector3.new(8, 10, 2),
}

-- Configuration visuelle (couleurs)
ServerConfig.Colors = {
	-- Salles
	FLOOR = Color3.fromRGB(85, 160, 85),
	WALL = Color3.fromRGB(70, 140, 70),
	START_ZONE = Color3.fromRGB(100, 255, 100),
	END_ZONE = Color3.fromRGB(255, 200, 50),

	-- Portes
	DOOR_ACTIVE = Color3.fromRGB(100, 200, 255),
	DOOR_INACTIVE = Color3.fromRGB(60, 60, 60),

	-- Obstacles
	OBSTACLE = Color3.fromRGB(120, 90, 70),

	-- Murs de séparation
	SEPARATION_WALL = Color3.fromRGB(50, 50, 60),
	PILLAR = Color3.fromRGB(40, 40, 50),
	PILLAR_TOP = Color3.fromRGB(60, 60, 70),
}

-- Couleurs des pièces
ServerConfig.CoinColors = {
	Color3.fromRGB(255, 200, 50),   -- Doré
	Color3.fromRGB(80, 200, 255),   -- Bleu ciel
	Color3.fromRGB(255, 100, 200),  -- Rose
	Color3.fromRGB(150, 255, 100),  -- Vert pomme
	Color3.fromRGB(200, 100, 255),  -- Violet
}

-- Configuration des murs de séparation
ServerConfig.Walls = {
	HEIGHT = 40,            -- Hauteur des murs de séparation
	THICKNESS = 15,         -- Épaisseur des murs
	SMALL_WALL_HEIGHT = 3,  -- Hauteur des petits murs décoratifs
	TOP_BARRIER_HEIGHT = 500,-- Hauteur des barrières invisibles (très haute pour empêcher de sauter par-dessus)
}

-- Configuration du système de rounds
ServerConfig.Rounds = {
	WAITING_TIME = 15,      -- Temps d'attente entre rounds (secondes)
	RESULTS_TIME = 15,      -- Temps d'affichage des résultats (secondes)
	START_DELAY = 5,        -- Délai avant le premier round (secondes)
}

return ServerConfig
