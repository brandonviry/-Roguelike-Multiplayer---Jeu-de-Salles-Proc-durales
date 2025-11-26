--[[
	Commande: /endgame
	Terminer la partie immédiatement
]]

local EndGameCommand = {}

EndGameCommand.metadata = {
	name = "endgame",
	description = "Terminer la partie immédiatement",
	usage = "/endgame",
	adminOnly = true,
	aliases = {"end", "stop"},
}

function EndGameCommand.execute(player, args, gameState)
	if gameState.gameEnded then
		return false, "La partie est déjà terminée"
	end

	gameState.gameEnded = true
	gameState.endGameForAll(player)
	return true, "Partie terminée par " .. player.Name
end

return EndGameCommand
