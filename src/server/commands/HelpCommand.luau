--[[
	Commande: /help
	Afficher toutes les commandes disponibles pour le joueur
]]

local HelpCommand = {}

HelpCommand.metadata = {
	name = "help",
	description = "Afficher toutes les commandes disponibles",
	usage = "/help",
	adminOnly = false,
	aliases = {"?", "commands"},
}

function HelpCommand.execute(player, args, gameState)
	-- Cette commande est spéciale car elle a besoin d'accéder au CommandRegistry
	-- Elle sera gérée directement dans AdminCommands
	return true, "Liste des commandes affichée dans la console"
end

return HelpCommand
