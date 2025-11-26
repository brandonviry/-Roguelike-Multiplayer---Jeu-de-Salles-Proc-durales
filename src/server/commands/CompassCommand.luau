--[[
	Commande: /compass
	Toggle la boussole pointant vers l'arrivée (salle Z)
]]

local CompassCommand = {}

CompassCommand.metadata = {
	name = "compass",
	description = "Afficher/cacher une boussole pointant vers l'arrivée",
	usage = "/compass",
	adminOnly = true,
	aliases = {"boussole"},
}

function CompassCommand.execute(player, args, gameState)
	local pos = gameState.playerPositions[player.UserId]
	if not pos then
		return false, "Position inconnue"
	end

	-- Calculer la direction vers Z
	local dx = gameState.endPos.x - pos.x
	local dy = gameState.endPos.y - pos.y
	local distance = math.abs(dx) + math.abs(dy)

	-- Envoyer au client pour toggle la boussole
	gameState.compassEvent:FireClient(player, dx, dy, distance)

	return true, "Boussole toggle (Distance: " .. distance .. " salles)"
end

return CompassCommand
