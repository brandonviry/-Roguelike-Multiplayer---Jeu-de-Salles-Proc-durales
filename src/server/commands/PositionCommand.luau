--[[
	Commande: /pos
	Afficher la position actuelle du joueur dans la grille
]]

local PositionCommand = {}

PositionCommand.metadata = {
	name = "pos",
	description = "Afficher ta position actuelle",
	usage = "/pos",
	adminOnly = true,
	aliases = {"position", "where"},
}

function PositionCommand.execute(player, args, gameState)
	local pos = gameState.playerPositions[player.UserId]

	if pos then
		return true, "Position: (" .. pos.x .. ", " .. pos.y .. ")"
	end

	return false, "Position inconnue"
end

return PositionCommand
