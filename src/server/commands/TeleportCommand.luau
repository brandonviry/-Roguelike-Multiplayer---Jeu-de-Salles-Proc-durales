--[[
	Commande: /tp
	Téléporter un admin à une salle spécifique de la grille
]]

local TeleportCommand = {}

TeleportCommand.metadata = {
	name = "tp",
	description = "Téléporter à une salle spécifique",
	usage = "/tp [x] [y]",
	adminOnly = true,
	aliases = {"teleport"},
}

function TeleportCommand.execute(player, args, gameState)
	local x = tonumber(args[1])
	local y = tonumber(args[2])

	if not x or not y then
		return false, "Usage: /tp [x] [y]"
	end

	if x < 0 or x >= gameState.CONFIG.GRID_SIZE or y < 0 or y >= gameState.CONFIG.GRID_SIZE then
		return false, "Coordonnées invalides (0-" .. (gameState.CONFIG.GRID_SIZE - 1) .. ")"
	end

	gameState.teleportPlayerToRoom(player, x, y)
	return true, "Téléporté à la salle (" .. x .. ", " .. y .. ")"
end

return TeleportCommand
