--[[
	Commande: /givecoins
	Donner des coins à un joueur
]]

local Players = game:GetService("Players")

local GiveCoinsCommand = {}

GiveCoinsCommand.metadata = {
	name = "givecoins",
	description = "Donner des coins à un joueur",
	usage = "/givecoins [joueur] [montant]",
	adminOnly = true,
	aliases = {"give"},
}

function GiveCoinsCommand.execute(player, args, gameState)
	local targetName = args[1]
	local amount = tonumber(args[2])

	if not targetName or not amount then
		return false, "Usage: /givecoins [joueur] [montant]"
	end

	local targetPlayer = Players:FindFirstChild(targetName)
	if not targetPlayer then
		return false, "Joueur '" .. targetName .. "' introuvable"
	end

	local leaderstats = targetPlayer:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = coins.Value + amount
			return true, "Donné " .. amount .. " coins à " .. targetName
		end
	end

	return false, "Impossible de donner des coins"
end

return GiveCoinsCommand
