--[[
	PathfindingService
	Génération intelligente des configurations de portes
	S'assure qu'il y a toujours un chemin vers l'arrivée
]]

local ServerConfig = require(script.Parent.Parent.Config.ServerConfig)

local PathfindingService = {}

-- Initialiser le service
function PathfindingService:Init(gridService)
	self.gridService = gridService
	print("🧭 PathfindingService initialisé")
	return self
end

-- Générer la configuration des portes pour une salle
function PathfindingService:GenerateDoorConfig(x, y)
	local config = {
		North = {exists = false, active = false, targetX = x, targetY = y - 1},
		South = {exists = false, active = false, targetX = x, targetY = y + 1},
		East = {exists = false, active = false, targetX = x + 1, targetY = y},
		West = {exists = false, active = false, targetX = x - 1, targetY = y},
	}

	-- Salle de fin = pas de portes
	if self.gridService:IsEndRoom(x, y) then
		return config
	end

	-- Vérifier que l'arrivée existe
	if not self.gridService.endPos then
		return config
	end

	local endPos = self.gridService.endPos

	-- Calculer la direction vers Z
	local dx = endPos.x - x
	local dy = endPos.y - y

	-- Garantir au moins une porte vers Z (chemin principal)
	if math.abs(dx) > math.abs(dy) then
		-- Priorité horizontale
		if dx > 0 and self:IsValidTarget(x + 1, y) then
			config.East.exists = true
			config.East.active = true
		elseif dx < 0 and self:IsValidTarget(x - 1, y) then
			config.West.exists = true
			config.West.active = true
		end
	else
		-- Priorité verticale
		if dy > 0 and self:IsValidTarget(x, y + 1) then
			config.South.exists = true
			config.South.active = true
		elseif dy < 0 and self:IsValidTarget(x, y - 1) then
			config.North.exists = true
			config.North.active = true
		end
	end

	-- Ajouter 1-2 portes supplémentaires pour l'exploration
	local numExtraDoors = math.random(1, 2)
	local directions = {"North", "South", "East", "West"}

	for i = 1, numExtraDoors do
		local randomDir = directions[math.random(1, #directions)]
		local doorData = config[randomDir]

		if self:IsValidTarget(doorData.targetX, doorData.targetY) then
			doorData.exists = true
			doorData.active = true
		end
	end

	return config
end

-- Vérifier si une position cible est valide
function PathfindingService:IsValidTarget(x, y)
	return self.gridService:IsValidPosition(x, y)
end

-- Calculer la distance Manhattan entre deux points
function PathfindingService:ManhattanDistance(x1, y1, x2, y2)
	return math.abs(x2 - x1) + math.abs(y2 - y1)
end

-- Obtenir la direction vers une cible
function PathfindingService:GetDirectionTo(fromX, fromY, toX, toY)
	local dx = toX - fromX
	local dy = toY - fromY

	if math.abs(dx) > math.abs(dy) then
		return dx > 0 and "East" or "West"
	else
		return dy > 0 and "South" or "North"
	end
end

return PathfindingService
