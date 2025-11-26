--[[
	CommandRegistry
	Système d'enregistrement automatique des commandes

	Scanne le dossier commands/ et charge toutes les commandes
	Gère l'exécution, les permissions et les aliases
]]

local CommandRegistry = {}
CommandRegistry.commands = {}
CommandRegistry.aliases = {}

-- Initialiser le registre en scannant tous les fichiers de commandes
function CommandRegistry:Init(commandsFolder)
	print("📋 Initialisation CommandRegistry...")

	local loadedCount = 0

	-- Scanner tous les enfants du dossier commands
	for _, commandModule in ipairs(commandsFolder:GetChildren()) do
		-- Ignorer le README, le template et ce fichier
		if commandModule:IsA("ModuleScript") and
		   not commandModule.Name:match("^_") and
		   commandModule.Name ~= "CommandRegistry" and
		   commandModule.Name ~= "README" then

			local success, command = pcall(function()
				return require(commandModule)
			end)

			if success and command.metadata then
				self:RegisterCommand(command)
				loadedCount = loadedCount + 1
			else
				warn("⚠️ Impossible de charger la commande:", commandModule.Name)
				if not success then
					warn("  Erreur:", command)
				end
			end
		end
	end

	print("✅ CommandRegistry initialisé -", loadedCount, "commande(s) chargée(s)")
	return self
end

-- Enregistrer une commande
function CommandRegistry:RegisterCommand(command)
	if not command.metadata or not command.metadata.name then
		warn("⚠️ Commande invalide: métadonnées manquantes")
		return false
	end

	local name = command.metadata.name:lower()

	-- Enregistrer la commande
	self.commands[name] = command
	print("  ✅ Commande enregistrée:", name)

	-- Enregistrer les aliases
	if command.metadata.aliases then
		for _, alias in ipairs(command.metadata.aliases) do
			self.aliases[alias:lower()] = name
			print("    📎 Alias:", alias, "→", name)
		end
	end

	return true
end

-- Obtenir une commande par nom ou alias
function CommandRegistry:GetCommand(name)
	local commandName = name:lower()

	-- Vérifier les aliases
	if self.aliases[commandName] then
		commandName = self.aliases[commandName]
	end

	return self.commands[commandName]
end

-- Vérifier si une commande existe
function CommandRegistry:HasCommand(name)
	return self:GetCommand(name) ~= nil
end

-- Obtenir toutes les commandes (pour /help)
function CommandRegistry:GetAllCommands()
	return self.commands
end

-- Obtenir les commandes disponibles pour un joueur
function CommandRegistry:GetCommandsForPlayer(player, isAdmin)
	local availableCommands = {}

	for name, command in pairs(self.commands) do
		-- Si la commande nécessite admin et que le joueur n'est pas admin, skip
		if command.metadata.adminOnly and not isAdmin then
			continue
		end

		table.insert(availableCommands, {
			name = name,
			metadata = command.metadata
		})
	end

	-- Trier par nom
	table.sort(availableCommands, function(a, b)
		return a.name < b.name
	end)

	return availableCommands
end

-- Exécuter une commande
function CommandRegistry:ExecuteCommand(player, commandName, args, gameState, isAdmin)
	local command = self:GetCommand(commandName)

	if not command then
		return false, "Commande inconnue: /" .. commandName
	end

	-- Vérifier les permissions
	if command.metadata.adminOnly and not isAdmin then
		return false, "❌ Cette commande est réservée aux administrateurs"
	end

	-- Exécuter la commande avec gestion d'erreurs
	local success, result1, result2 = pcall(function()
		return command.execute(player, args, gameState)
	end)

	if not success then
		warn("❌ Erreur lors de l'exécution de /" .. commandName .. ":")
		warn(result1)
		return false, "Erreur lors de l'exécution: " .. tostring(result1)
	end

	-- result1 = success (boolean), result2 = message (string)
	return result1, result2
end

return CommandRegistry
