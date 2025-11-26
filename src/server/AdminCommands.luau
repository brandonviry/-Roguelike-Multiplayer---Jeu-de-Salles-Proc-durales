--[[
	Système de commandes admin REFACTORISÉ
	Utilise le CommandRegistry pour charger automatiquement toutes les commandes

	Architecture modulaire:
	- Chaque commande = 1 fichier dans commands/
	- Chargement automatique
	- Facile d'ajouter de nouvelles commandes
]]

local CommandRegistry = require(script.Parent.commands.CommandRegistry)

local AdminCommands = {}

-- Liste des admins (par Username ou UserId)
AdminCommands.ADMINS = {
	["HiShikuro"] = true, -- Toi
	-- Ajoute d'autres admins ici:
	-- ["AutreNom"] = true,
	-- [123456789] = true, -- Par UserId
}

-- Initialiser le système de commandes
function AdminCommands.init()
	print("👑 Initialisation AdminCommands...")

	-- Charger toutes les commandes depuis le dossier commands/
	local commandsFolder = script.Parent.commands
	CommandRegistry:Init(commandsFolder)

	print("✅ AdminCommands initialisé")
end

-- Vérifier si un joueur est admin
function AdminCommands.isAdmin(player)
	-- Vérifier par nom d'utilisateur
	if AdminCommands.ADMINS[player.Name] then
		return true
	end

	-- Vérifier par UserId
	if AdminCommands.ADMINS[player.UserId] then
		return true
	end

	return false
end

-- Exécuter une commande
function AdminCommands.executeCommand(player, message, gameState)
	-- Vérifier si c'est une commande (commence par /)
	if message:sub(1, 1) ~= "/" then
		return false
	end

	-- Parser la commande
	local parts = {}
	for part in message:gmatch("%S+") do
		table.insert(parts, part)
	end

	local commandName = parts[1]:sub(2):lower() -- Enlever le /
	local args = {}
	for i = 2, #parts do
		table.insert(args, parts[i])
	end

	-- Vérifier si c'est la commande /help (cas spécial)
	if commandName == "help" or commandName == "?" or commandName == "commands" then
		return AdminCommands.showHelp(player, gameState)
	end

	-- Exécuter la commande via le CommandRegistry
	local isAdmin = AdminCommands.isAdmin(player)
	return CommandRegistry:ExecuteCommand(player, commandName, args, gameState, isAdmin)
end

-- Afficher l'aide (cas spécial car on a besoin du CommandRegistry)
function AdminCommands.showHelp(player, _gameState)
	local isAdmin = AdminCommands.isAdmin(player)
	local output = "📋 COMMANDES DISPONIBLES:\n"

	local commands = CommandRegistry:GetCommandsForPlayer(player, isAdmin)

	for _, cmd in ipairs(commands) do
		output = output .. "/" .. cmd.name .. " - " .. cmd.metadata.description
		if cmd.metadata.adminOnly then
			output = output .. " [ADMIN]"
		end
		if cmd.metadata.aliases and #cmd.metadata.aliases > 0 then
			output = output .. " (alias: " .. table.concat(cmd.metadata.aliases, ", ") .. ")"
		end
		output = output .. "\n"
		output = output .. "  Usage: " .. cmd.metadata.usage .. "\n"
	end

	output = output .. "\n💡 Nombre total de commandes: " .. #commands

	print(output)
	return true, "Liste des commandes affichée dans la console"
end

return AdminCommands
