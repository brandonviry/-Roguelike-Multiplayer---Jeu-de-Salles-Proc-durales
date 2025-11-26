--[[
	TEMPLATE DE COMMANDE

	Copiez ce fichier et modifiez-le pour créer une nouvelle commande.

	Exemple: MaCommandeCommand.luau

	Étapes:
	1. Copier ce fichier
	2. Renommer en [NomCommande]Command.luau
	3. Modifier les métadonnées
	4. Implémenter la logique dans execute()
	5. C'est tout ! La commande sera automatiquement détectée
]]

local MonTemplate = {}

-- ============================================================================
-- MÉTADONNÉES
-- ============================================================================

MonTemplate.metadata = {
	-- Nom de la commande (sans le /)
	name = "template",

	-- Description courte (pour /help)
	description = "Description de la commande",

	-- Usage avec exemples
	usage = "/template [arg1] [arg2]",

	-- Réservée aux admins ?
	adminOnly = true,

	-- Aliases optionnels (raccourcis)
	aliases = {"tmp", "tpl"},
}

-- ============================================================================
-- EXÉCUTION
-- ============================================================================

--[[
	Fonction principale de la commande

	@param player - Le joueur qui exécute la commande
	@param args - Tableau des arguments passés (args[1], args[2], ...)
	@param gameState - État du jeu (CONFIG, worldGrid, playerPositions, etc.)

	@return success (boolean) - true si succès, false si erreur
	@return message (string) - Message à afficher au joueur
]]
function MonTemplate.execute(player, args, gameState)
	-- Exemple de validation des arguments
	local arg1 = args[1]
	local arg2 = tonumber(args[2])

	if not arg1 then
		return false, "Usage: " .. MonTemplate.metadata.usage
	end

	if not arg2 then
		return false, "Le deuxième argument doit être un nombre"
	end

	-- ========================================================================
	-- VOTRE LOGIQUE ICI
	-- ========================================================================

	-- Exemple: modifier la vitesse du joueur
	local character = player.Character
	if not character then
		return false, "Personnage introuvable"
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return false, "Humanoid introuvable"
	end

	-- Faire quelque chose
	-- humanoid.WalkSpeed = arg2

	-- ========================================================================
	-- FIN DE LA LOGIQUE
	-- ========================================================================

	-- Retourner le résultat
	return true, "Commande exécutée avec succès: " .. arg1 .. ", " .. arg2
end

-- ============================================================================
-- EXPORT
-- ============================================================================

return MonTemplate
