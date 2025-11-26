--[[
	Commande: /setcoins
	Définir son propre score de coins
]]

local SetCoinsCommand = {}

SetCoinsCommand.metadata = {
	name = "setcoins",
	description = "Définir ton score de coins",
	usage = "/setcoins [montant]",
	adminOnly = true,
	aliases = {"setmoney"},
}

function SetCoinsCommand.execute(player, args, gameState)
	local amount = tonumber(args[1])

	if not amount then
		return false, "Usage: /setcoins [montant]"
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = amount
			return true, "Score défini à " .. amount .. " coins"
		end
	end

	return false, "Impossible de modifier le score"
end

return SetCoinsCommand
