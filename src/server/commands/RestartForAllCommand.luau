--[[
	Commande: /restartForAll
	Relancer le jeu complètement depuis zéro
	Reset tout: monde, scores, positions
]]

local RestartForAllCommand = {}

-- ============================================================================
-- MÉTADONNÉES
-- ============================================================================

RestartForAllCommand.metadata = {
	name = "restartforall",
	description = "Relancer le jeu depuis zéro pour tous les joueurs",
	usage = "/restartforall",
	adminOnly = true,
	aliases = {"restart", "restartall", "reset"},
}

-- ============================================================================
-- EXÉCUTION
-- ============================================================================

function RestartForAllCommand.execute(player, args, gameState)
	-- Vérifier que la fonction de restart existe
	if not gameState.restartGame then
		return false, "⚠️ Fonction de restart non disponible"
	end

	-- Informer tous les joueurs
	print("🔄 " .. player.Name .. " relance le jeu depuis zéro...")

	-- Appeler la fonction de restart
	gameState.restartGame()

	return true, "✅ Jeu relancé! Nouveau round en cours..."
end

-- ============================================================================
-- EXPORT
-- ============================================================================

return RestartForAllCommand
