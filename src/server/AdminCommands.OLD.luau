--[[
	Système de commandes admin professionnel
	Accessible uniquement aux administrateurs
]]

local Players = game:GetService("Players")

local AdminCommands = {}

-- Liste des admins (par Username ou UserId)
AdminCommands.ADMINS = {
	["HiShikuro"] = true, -- Toi
	-- Ajoute d'autres admins ici:
	-- ["AutreNom"] = true,
	-- [123456789] = true, -- Par UserId
}

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

-- Liste des commandes disponibles
AdminCommands.commands = {}

-- Commande: /tp [x] [y] - Téléporter à une salle
AdminCommands.commands.tp = {
	description = "Téléporter à une salle spécifique",
	usage = "/tp [x] [y]",
	adminOnly = true,
	execute = function(player, args, gameState)
		local x = tonumber(args[1])
		local y = tonumber(args[2])

		if not x or not y then
			return false, "Usage: /tp [x] [y]"
		end

		if x < 0 or x >= gameState.CONFIG.GRID_SIZE or y < 0 or y >= gameState.CONFIG.GRID_SIZE then
			return false, "Coordonnées invalides (0-" .. (gameState.CONFIG.GRID_SIZE - 1) .. ")"
		end

		gameState.teleportPlayerToRoom(player, x, y)
		return true, "Téléporté à la salle (" .. x .. ", " .. y .. ")"
	end
}

-- Commande: /givecoins [joueur] [montant] - Donner des coins
AdminCommands.commands.givecoins = {
	description = "Donner des coins à un joueur",
	usage = "/givecoins [joueur] [montant]",
	adminOnly = true,
	execute = function(player, args, gameState)
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
}

-- Commande: /endgame - Terminer la partie
AdminCommands.commands.endgame = {
	description = "Terminer la partie immédiatement",
	usage = "/endgame",
	adminOnly = true,
	execute = function(player, args, gameState)
		if gameState.gameEnded then
			return false, "La partie est déjà terminée"
		end

		gameState.gameEnded = true
		gameState.endGameForAll(player)
		return true, "Partie terminée par " .. player.Name
	end
}

-- Commande: /showgrid - Afficher la grille complète
AdminCommands.commands.showgrid = {
	description = "Afficher toutes les salles générées",
	usage = "/showgrid",
	adminOnly = true,
	execute = function(player, args, gameState)
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
}

-- Commande: /setcoins [montant] - Définir ton propre score
AdminCommands.commands.setcoins = {
	description = "Définir ton score de coins",
	usage = "/setcoins [montant]",
	adminOnly = true,
	execute = function(player, args, gameState)
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
}

-- Commande: /pos - Afficher ta position actuelle
AdminCommands.commands.pos = {
	description = "Afficher ta position actuelle",
	usage = "/pos",
	adminOnly = true,
	execute = function(player, args, gameState)
		local pos = gameState.playerPositions[player.UserId]
		if pos then
			return true, "Position: (" .. pos.x .. ", " .. pos.y .. ")"
		end
		return false, "Position inconnue"
	end
}

-- Commande: /players - Lister tous les joueurs et leurs positions
AdminCommands.commands.players = {
	description = "Lister tous les joueurs connectés",
	usage = "/players",
	adminOnly = true,
	execute = function(player, args, gameState)
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
}

-- Commande: /compass - Toggle la boussole vers Z
AdminCommands.commands.compass = {
	description = "Afficher/cacher une boussole pointant vers l'arrivée",
	usage = "/compass",
	adminOnly = true,
	execute = function(player, args, gameState)
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
}

-- Commande: /help - Afficher toutes les commandes
AdminCommands.commands.help = {
	description = "Afficher toutes les commandes disponibles",
	usage = "/help",
	adminOnly = false,
	execute = function(player, args, gameState)
		local isAdmin = AdminCommands.isAdmin(player)
		local output = "📋 COMMANDES DISPONIBLES:\n"

		for name, cmd in pairs(AdminCommands.commands) do
			if not cmd.adminOnly or isAdmin then
				output = output .. "/" .. name .. " - " .. cmd.description
				if cmd.adminOnly then
					output = output .. " [ADMIN]"
				end
				output = output .. "\n"
			end
		end

		print(output)
		return true, "Liste des commandes affichée dans la console"
	end
}

-- Exécuter une commande
function AdminCommands.executeCommand(player, message, gameState)
	-- Vérifier si c'est une commande (commence par /)
	if not message:sub(1, 1) == "/" then
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

	-- Trouver la commande
	local command = AdminCommands.commands[commandName]
	if not command then
		return false, "Commande inconnue: /" .. commandName
	end

	-- Vérifier les permissions
	if command.adminOnly and not AdminCommands.isAdmin(player) then
		return false, "❌ Cette commande est réservée aux administrateurs"
	end

	-- Exécuter la commande
	local success, result = pcall(function()
		return command.execute(player, args, gameState)
	end)

	if not success then
		return false, "Erreur: " .. tostring(result)
	end

	return result
end

return AdminCommands
