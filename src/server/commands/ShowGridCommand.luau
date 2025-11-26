--[[
	Commande: /showgrid
	Afficher la grille complète avec toutes les salles générées
]]

local ShowGridCommand = {}

ShowGridCommand.metadata = {
	name = "showgrid",
	description = "Afficher toutes les salles générées",
	usage = "/showgrid",
	adminOnly = true,
	aliases = {"grid", "map"},
}

function ShowGridCommand.execute(player, args, gameState)
	local output = "🗺️ GRILLE DU MONDE (12x12):\n"
	local generated = 0

	for y = 0, gameState.CONFIG.GRID_SIZE - 1 do
		local line = ""
		for x = 0, gameState.CONFIG.GRID_SIZE - 1 do
			if gameState.worldGrid[x][y] then
				generated = generated + 1
				if x == gameState.startPos.x and y == gameState.startPos.y then
					line = line .. "[O]" -- Départ
				elseif x == gameState.endPos.x and y == gameState.endPos.y then
					line = line .. "[Z]" -- Arrivée
				else
					line = line .. "[■]" -- Salle générée
				end
			else
				line = line .. "[ ]" -- Vide
			end
		end
		output = output .. line .. "\n"
	end

	output = output .. "\nSalles générées: " .. generated .. "/" .. (gameState.CONFIG.GRID_SIZE * gameState.CONFIG.GRID_SIZE)
	output = output .. "\nDépart O: (" .. gameState.startPos.x .. ", " .. gameState.startPos.y .. ")"
	output = output .. "\nArrivée Z: (" .. gameState.endPos.x .. ", " .. gameState.endPos.y .. ")"

	print(output)
	return true, "Grille affichée dans la console"
end

return ShowGridCommand
