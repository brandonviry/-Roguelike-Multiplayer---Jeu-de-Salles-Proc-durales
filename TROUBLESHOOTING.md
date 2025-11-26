# 🔧 Troubleshooting - Guide de Dépannage

## 🐛 Problèmes connus et solutions

### Problème : Les commandes admin ne fonctionnent pas

#### Symptômes
- Taper `/help` ou `/tp` ne fait rien
- Aucun message dans la console
- Les commandes sont ignorées

#### Solutions

1. **Vérifier que vous êtes admin**
   ```lua
   -- Dans AdminCommands.luau, vérifier que votre nom est dans la liste
   AdminCommands.ADMINS = {
       ["VotreNomRoblox"] = true,  -- ← Vérifier ici
   }
   ```

2. **Vérifier la console Output**
   - Chercher les messages `👑 ADMIN connecté: VotreNom`
   - Si ce message n'apparaît pas, vous n'êtes pas reconnu comme admin

3. **Vérifier que le serveur est bien démarré**
   - Chercher le message `✅ === SERVEUR PRÊT ===`
   - Chercher `✅ Tous les services initialisés`

4. **Tester avec /help**
   ```
   /help
   ```
   Cela devrait afficher la liste des commandes dans la console Output.

---

### Problème : Erreur "Module not found"

#### Symptômes
```
ServerScriptService.Server.init.server:24: attempt to call a nil value
```

#### Cause
Un module n'a pas été trouvé ou le chemin est incorrect.

#### Solution
Vérifier que TOUS les fichiers existent :
```
src/server/
├── Config/ServerConfig.luau
├── Services/RemoteService.luau
├── Services/GridService.luau
├── Services/PlayerManager.luau
├── Services/LightingService.luau
├── Modules/EntityFactory.luau
├── Modules/RoomFactory.luau
├── Modules/PathfindingService.luau
└── Modules/WorldManager.luau
```

---

### Problème : Les salles ne se créent pas

#### Symptômes
- Joueurs tombent dans le vide
- Pas de salle de départ
- Erreurs dans la console

#### Solutions

1. **Vérifier que le RoundManager a démarré**
   - Chercher `🎮 Démarrage du système de rounds...`
   - Chercher `🔄 === NOUVEAU ROUND ===`

2. **Vérifier les logs de création**
   - Chercher `🏗️ Création des salles principales...`
   - Chercher `🔨 Création salle à 6 6` (salle de départ)

3. **Ajouter des logs de debug**
   ```lua
   -- Dans WorldManager:CreateMainRooms()
   print("🔍 DEBUG startPos:", self.gridService.startPos.x, self.gridService.startPos.y)
   print("🔍 DEBUG endPos:", self.gridService.endPos.x, self.gridService.endPos.y)
   ```

---

### Problème : "attempt to index nil value"

#### Symptômes
```
ServerScriptService.Server.Modules.WorldManager:42: attempt to index nil value
```

#### Cause
Un service n'a pas été initialisé correctement ou une dépendance est manquante.

#### Solution

1. **Vérifier l'ordre d'initialisation dans init.server.luau**
   ```lua
   -- L'ordre est IMPORTANT
   local remoteService = RemoteService:Init()
   local gridService = GridService:Init()
   local playerManager = PlayerManager:Init()
   -- ...
   ```

2. **Vérifier que :Init() retourne `self`**
   ```lua
   -- Tous les modules doivent avoir:
   function MonModule:Init(...)
       -- ...
       return self  -- ← IMPORTANT
   end
   ```

---

### Problème : Les joueurs ne sont pas téléportés

#### Symptômes
- Joueurs spawn au point 0,0,0
- Joueurs tombent dans le vide
- Pas de téléportation au démarrage

#### Solutions

1. **Vérifier le log de téléportation**
   - Chercher `🚀 Téléportation des joueurs...`
   - Chercher `📍 [NomJoueur] téléporté à la salle 6 6`

2. **Vérifier que les salles existent**
   ```lua
   -- Utiliser la commande admin
   /showgrid
   ```
   Cela affiche la grille et montre si les salles O et Z existent.

3. **Vérifier CharacterAdded**
   - Le personnage doit être complètement chargé avant la téléportation
   - Il y a un `task.wait(1)` dans le code pour ça

---

### Problème : CONFIG.GRID_SIZE est nil

#### Symptômes
```
attempt to compare number with nil
attempt to index field 'CONFIG' (a nil value)
```

#### Cause
La structure de CONFIG a changé avec la refactorisation.

#### Solution
Vérifier que `WorldManager:GetGameState()` retourne la bonne structure :
```lua
function WorldManager:GetGameState()
    local config = {
        GRID_SIZE = ServerConfig.Grid.SIZE,  -- ← Vérifier ici
        -- ...
    }
    return {
        CONFIG = config,  -- ← Pas ServerConfig directement
        -- ...
    }
end
```

---

### Problème : Les portes ne téléportent pas

#### Symptômes
- Toucher une porte ne fait rien
- Pas de son de téléportation
- Joueur reste dans la même salle

#### Solutions

1. **Vérifier que la porte est active**
   - Portes actives = bleu brillant
   - Portes inactives = gris foncé

2. **Vérifier les logs**
   - Chercher `🚪 [NomJoueur] passe par la porte ...`
   - Si ce message n'apparaît pas, le trigger ne fonctionne pas

3. **Vérifier le debounce**
   - Il y a un délai de 2 secondes entre chaque utilisation
   - Attendre 2 secondes avant de réessayer

---

### Problème : Fin de partie ne fonctionne pas

#### Symptômes
- Toucher la zone Z ne termine pas la partie
- Pas d'écran de fin
- Le round continue

#### Solutions

1. **Vérifier que la zone Z existe**
   ```
   /tp [endX] [endY]
   ```
   Se téléporter à la salle Z et vérifier qu'elle est dorée.

2. **Vérifier les logs**
   - Chercher `🏆 [NomJoueur] a atteint l'arrivée!`
   - Chercher `🏆 === FIN DE PARTIE ===`

3. **Vérifier le hook dans init.server.luau**
   ```lua
   worldManager.EndGame = function(_self, winner)
       roundManager:EndRound(winner)
   end
   ```

---

### Problème : RemoteEvent not found

#### Symptômes
```
CompassToggle is not a valid member of Folder "ReplicatedStorage.Remotes"
```

#### Cause
Un RemoteEvent n'a pas été créé par RemoteService.

#### Solution

1. **Vérifier RemoteService:Init()**
   ```lua
   local remoteNames = {
       "CoinCollected",
       "GameEnded",
       "CompassToggle",
       "RoundStateChanged",
       "DoorTeleport",
   }
   ```

2. **Vérifier que RemoteService est initialisé en PREMIER**
   ```lua
   -- Dans init.server.luau
   local remoteService = RemoteService:Init()  -- ← PREMIER
   ```

3. **Vérifier les logs**
   - Chercher `✅ RemoteEvent créé: CompassToggle`

---

## 🔍 Debug général

### Activer les logs de debug

Ajouter des prints dans les modules :

```lua
-- Dans n'importe quel module
function MyModule:MyFunction(param)
    print("🔍 DEBUG MyFunction appelée avec:", param)

    -- Votre code

    print("✅ DEBUG MyFunction terminée")
end
```

### Vérifier l'initialisation complète

À la fin de `init.server.luau`, vous devriez voir :

```
🚀 === DÉMARRAGE DU SERVEUR - ARCHITECTURE MODULAIRE ===
🔧 Initialisation des services...
🔌 Initialisation RemoteService...
  ✅ RemoteEvent créé: CoinCollected
  ✅ RemoteEvent créé: GameEnded
  ✅ RemoteEvent créé: CompassToggle
  ✅ RemoteEvent créé: RoundStateChanged
  ✅ RemoteEvent créé: DoorTeleport
✅ RemoteService initialisé - 5 remotes créés
🗺️ Initialisation GridService...
✅ GridService initialisé - Grille 12x12
👥 Initialisation PlayerManager...
✅ PlayerManager initialisé
💡 Initialisation LightingService...
✅ LightingService initialisé
🏭 EntityFactory initialisé
🏗️ RoomFactory initialisé
🧭 PathfindingService initialisé
🌍 Initialisation WorldManager...
✅ WorldManager initialisé
🎮 RoundManager initialisé
✅ Tous les services initialisés
✅ === SERVEUR PRÊT ===
🎮 Système de rounds actif!
🗺️ Monde partagé persistant - Grille 12x12
👑 Admins configurés: 1

🎮 Démarrage du système de rounds...
⏳ Démarrage dans 5 secondes...
🔄 === NOUVEAU ROUND ===
🔄 Reset du monde...
🗑️ Nettoyage de la grille...
✅ 0 salles détruites
📍 Nouvelle arrivée Z générée: [x] [y]
📊 Reset des scores de tous les joueurs...
✅ 0 joueur(s) reset
✅ Monde réinitialisé
🏗️ Création des salles principales...
🔨 Création salle à 6 6
🔨 Création salle à [x] [y]
🏆 Salle de fin créée avec zone de trigger
✅ Salles principales créées
🚀 Téléportation de tous les joueurs au spawn...
✅ Tous les joueurs téléportés
✅ Round 1 commencé!
🏁 Première personne à atteindre Z gagne!
🎯 Le jeu a démarré!
```

Si vous ne voyez pas ces messages, quelque chose n'a pas été initialisé correctement.

---

## 📞 Obtenir de l'aide

Si le problème persiste :

1. **Copier les erreurs de la console** (Output et Server Log)
2. **Noter quand le problème survient** (au démarrage, pendant le jeu, etc.)
3. **Vérifier ARCHITECTURE.md** pour comprendre le fonctionnement
4. **Consulter QUICK_START.md** pour les cas d'usage courants

---

## 🔧 Rollback (retour en arrière)

Si la nouvelle architecture ne fonctionne pas et que vous voulez revenir à l'ancienne :

1. **Restaurer l'ancien fichier**
   ```bash
   # Supprimer le nouveau
   rm src/server/init.server.luau

   # Restaurer l'ancien
   mv src/server/init.server.OLD.luau src/server/init.server.luau
   ```

2. **Supprimer les nouveaux modules**
   ```bash
   rm -rf src/server/Config
   rm -rf src/server/Modules
   # Garder Services si vous voulez
   ```

3. **Tester à nouveau**

---

**Note:** La nouvelle architecture a été testée et devrait fonctionner. Si vous rencontrez des problèmes, c'est probablement un problème de configuration ou d'initialisation, pas un problème d'architecture.
