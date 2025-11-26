--[[
	Commande: /players
	Lister tous les joueurs connectés avec leurs positions et scores
]]

local Players = game:GetService("Players")

local PlayersCommand = {}

PlayersCommand.metadata = {
	name = "players",
	description = "Lister tous les joueurs connectés",
	usage = "/players",
	adminOnly = true,
	aliases = {"list", "who"},
}

function PlayersCommand.execute(player, args, gameState)
	local output = "👥 JOUEURS CONNECTÉS:\n"
	local count = 0

	for _, p in ipairs(Players:GetPlayers()) do
		count = count + 1
		local pos = gameState.playerPositions[p.UserId]
		local leaderstats = p:FindFirstChild("leaderstats")
		local coins = leaderstats and leaderstats:FindFirstChild("Coins")

		output = output .. count .. ". " .. p.Name
		if pos then
			output = output .. " - Salle (" .. pos.x .. ", " .. pos.y .. ")"
		end
		if coins then
			output = output .. " - " .. coins.Value .. " coins"
		end
		output = output .. "\n"
	end

	print(output)
	return true, count .. " joueur(s) connecté(s)"
end

return PlayersCommand
