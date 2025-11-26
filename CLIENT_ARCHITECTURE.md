# 🎮 Architecture Client - Documentation

## 📋 Vue d'ensemble

Le client a été **refactorisé en architecture modulaire MVC** (Model-View-Controller) pour séparer clairement les responsabilités.

### Avant (OLD_BACKUP)
```
❌ 1 fichier monolithique de 978 lignes
❌ Tout mélangé (UI, logique, effets)
❌ Difficile à maintenir
```

### Après (Architecture actuelle)
```
✅ Architecture MVC modulaire
✅ Séparation claire: UI / Logique / Effets
✅ ~50-200 lignes par module
✅ Injection de dépendances
✅ Code réutilisable
```

---

## 📁 Structure du client

```
src/client/
├── init.client.luau (148 lignes)     ← Point d'entrée, orchestrateur
├── SoundManager.luau                 ← Gestion des sons
│
├── 📂 Controllers/                   ← 🎮 LOGIQUE MÉTIER
│   ├── CoinController.luau           ← Collecte de pièces
│   ├── RoundController.luau          ← Gestion des rounds
│   ├── DoorController.luau           ← Téléportation par portes
│   ├── CompassController.luau        ← Boussole vers Z
│   ├── EffectsController.luau        ← (Optionnel)
│   ├── SoundController.luau          ← (Optionnel)
│   └── UIController.luau             ← (Optionnel)
│
├── 📂 ui/                            ← 🎨 INTERFACES UTILISATEUR
│   ├── ScoreUI.luau                  ← Score en haut à droite
│   ├── RoundUI.luau                  ← Affichage du round en cours
│   ├── EndScreenUI.luau              ← Écran de fin de partie
│   ├── TimerUI.luau                  ← Timer entre rounds
│   ├── CompassUI.luau                ← Boussole vers arrivée
│   └── AdminUI.luau                  ← Interface admin
│
└── 📂 effects/                       ← ✨ EFFETS VISUELS
    ├── CollectEffects.luau           ← Cercles colorés de collecte
    └── CameraEffects.luau            ← Shake de caméra
```

---

## 🏗️ Architecture MVC

### Model
Les données viennent du serveur via RemoteEvents et Leaderstats.

### View (UI)
Les modules dans `ui/` gèrent uniquement l'**affichage**.

### Controller
Les modules dans `Controllers/` gèrent la **logique** et coordonnent View/Model.

---

## 🔄 Flux de données

### Initialisation
```
1. init.client.luau démarre
   ↓
2. Charge tous les modules
   - SoundManager
   - Effects (CollectEffects, CameraEffects)
   - UI (ScoreUI, RoundUI, etc.)
   - Controllers (CoinController, RoundController, etc.)
   ↓
3. Crée les interfaces utilisateur
   - ScoreUI.create()
   - RoundUI.create()
   ↓
4. Initialise les contrôleurs avec injection de dépendances
   - CoinController.initialize({SoundManager, CollectEffects, CameraEffects})
   - RoundController.initialize({SoundManager, RoundUI, EndScreenUI, TimerUI})
   - etc.
   ↓
5. Connecte les contrôleurs aux RemoteEvents
   - CoinController.connect()
   - RoundController.connect()
   - etc.
   ↓
6. Écoute les changements de leaderstats
   - coins.Changed → ScoreUI.update()
   ↓
7. Crée l'UI admin si applicable
   - AdminUI.create()
```

### Quand un événement arrive du serveur

```
Serveur envoie RemoteEvent "CoinCollected"
   ↓
CoinController.onCoinCollected() reçoit l'événement
   ↓
CoinController appelle:
   - SoundManager.playVariedSound()
   - CollectEffects.showCircle()
   - CameraEffects.shake()
   ↓
ScoreUI.update() est appelé via coins.Changed
   ↓
Interface met à jour le score avec animation
```

---

## 📦 Description des modules

### 🎮 Controllers (Logique)

#### CoinController.luau
**Responsabilité:** Gérer la collecte de pièces

**API:**
```lua
CoinController.initialize(deps)  -- Injecter dépendances
CoinController.connect()         -- Connecter aux événements
CoinController.onCoinCollected(amount, color)  -- Handler
```

**Dépendances:** SoundManager, CollectEffects, CameraEffects

---

#### RoundController.luau
**Responsabilité:** Gérer le cycle des rounds

**API:**
```lua
RoundController.initialize(deps)
RoundController.connect()
RoundController.onRoundStateChanged(state, roundNumber, extraData)
```

**Dépendances:** SoundManager, RoundUI, EndScreenUI, TimerUI

**États gérés:**
- `STARTED` - Round commence
- `ENDED` - Round terminé
- `WAITING` - Attente entre rounds

---

#### DoorController.luau
**Responsabilité:** Gérer la téléportation par portes

**API:**
```lua
DoorController.initialize(deps)
DoorController.connect()
DoorController.onDoorTeleport()
```

**Dépendances:** SoundManager

---

#### CompassController.luau
**Responsabilité:** Gérer l'affichage de la boussole

**API:**
```lua
CompassController.initialize(deps)
CompassController.connect()
CompassController.onCompassToggle(dx, dy, distance)
```

**Dépendances:** CompassUI

---

### 🎨 UI (Interfaces)

#### ScoreUI.luau
**Responsabilité:** Afficher le score du joueur

**API:**
```lua
ScoreUI.create()        -- Créer l'interface
ScoreUI.update(value)   -- Mettre à jour le score
```

**Éléments:**
- Frame avec gradient animé
- Icône étoile
- Label du score (avec animation de pulsation)
- Instructions pour les nouveaux joueurs

---

#### RoundUI.luau
**Responsabilité:** Afficher l'état du round en cours

**API:**
```lua
RoundUI.create()                           -- Créer l'interface
RoundUI.update(state, roundNumber, extra)  -- Mettre à jour
```

**États affichés:**
- `STARTED` - "ROUND X - En cours..."
- `ENDED` - "ROUND X - Terminé! Gagnant: ..."
- `WAITING` - "PROCHAIN ROUND - Démarre dans Xs..."

---

#### EndScreenUI.luau
**Responsabilité:** Afficher l'écran de fin de partie

**API:**
```lua
EndScreenUI.show(winnerName, leaderboard)  -- Afficher
```

**Contenu:**
- Titre "FIN DE PARTIE"
- Nom du gagnant
- Classement des joueurs (top 5)
- Timer de 30 secondes
- Barre de progression

---

#### TimerUI.luau
**Responsabilité:** Afficher le compte à rebours entre rounds

**API:**
```lua
TimerUI.create(duration)     -- Créer avec durée
TimerUI.start()              -- Démarrer le compte à rebours
TimerUI.destroy()            -- Détruire
```

**Effets:**
- Animation de pulsation
- Sons de tick
- Changement de couleur < 10s

---

#### CompassUI.luau
**Responsabilité:** Afficher la boussole vers l'arrivée

**API:**
```lua
CompassUI.create()                  -- Créer
CompassUI.show(dx, dy, distance)    -- Afficher avec direction
CompassUI.hide()                    -- Cacher
```

**Éléments:**
- Cercle doré
- Flèche rouge pointant vers Z
- Distance en nombre de salles
- Texte "ARRIVÉE"

---

#### AdminUI.luau
**Responsabilité:** Interface pour les administrateurs

**API:**
```lua
AdminUI.create()  -- Créer l'interface admin
```

**Éléments:**
- Badge "ADMIN" (rouge, cliquable)
- Panneau de commandes (toggle)
- Liste des 9 commandes admin
- Descriptions

---

### ✨ Effects (Effets visuels)

#### CollectEffects.luau
**Responsabilité:** Effets visuels de collecte

**API:**
```lua
CollectEffects.showCircle(color)  -- Afficher cercle coloré
```

**Animation:**
1. Cercle part du centre
2. Expansion avec couleur de la pièce
3. Disparition progressive

---

#### CameraEffects.luau
**Responsabilité:** Effets de caméra

**API:**
```lua
CameraEffects.shake(intensity, duration)  -- Faire trembler
```

**Paramètres:**
- `intensity` - Force du tremblement (défaut: 10)
- `duration` - Durée en secondes (défaut: 0.15)

---

## 🔧 Injection de dépendances

### Pourquoi ?
- **Testabilité** - Facile de mocker les dépendances
- **Flexibilité** - Facile de remplacer un module
- **Couplage faible** - Modules indépendants

### Comment ?
```lua
-- Dans init.client.luau
CoinController.initialize({
    SoundManager = SoundManager,
    CollectEffects = CollectEffects,
    CameraEffects = CameraEffects
})

-- Dans CoinController.luau
local SoundManager = nil  -- Variable locale
local CollectEffects = nil
local CameraEffects = nil

function CoinController.initialize(deps)
    SoundManager = deps.SoundManager
    CollectEffects = deps.CollectEffects
    CameraEffects = deps.CameraEffects
end
```

---

## 🎓 Avantages de cette architecture

### ✅ Séparation des responsabilités
- UI s'occupe uniquement de l'affichage
- Controllers gèrent la logique
- Effects gèrent les animations

### ✅ Réutilisabilité
- Modules peuvent être réutilisés dans d'autres projets
- Facile d'ajouter de nouvelles fonctionnalités

### ✅ Maintenabilité
- Bug dans l'UI ? → Regarder `ui/`
- Bug dans la logique ? → Regarder `Controllers/`
- Code organisé et facile à naviguer

### ✅ Testabilité
- Chaque module peut être testé indépendamment
- Dépendances injectées = faciles à mocker

### ✅ Scalabilité
- Facile d'ajouter de nouveaux contrôleurs
- Facile d'ajouter de nouvelles interfaces

---

## 📊 Comparaison Avant/Après

### Avant (OLD_BACKUP)
| Aspect | État |
|--------|------|
| **Lignes de code** | 978 lignes en 1 fichier |
| **Organisation** | Tout mélangé |
| **Maintenabilité** | ❌ Difficile |
| **Réutilisabilité** | ❌ Impossible |
| **Testabilité** | ❌ Impossible |

### Après (Architecture actuelle)
| Aspect | État |
|--------|------|
| **Lignes de code** | 15 modules de 50-200 lignes |
| **Organisation** | MVC clair |
| **Maintenabilité** | ✅ Facile |
| **Réutilisabilité** | ✅ Modules indépendants |
| **Testabilité** | ✅ Injection de dépendances |

---

## 🚀 Ajouter une nouvelle fonctionnalité

### Exemple: Ajouter un système de notifications

**1. Créer l'UI**
```lua
-- ui/NotificationUI.luau
local NotificationUI = {}

function NotificationUI.create()
    -- Créer l'interface
end

function NotificationUI.show(message, type)
    -- Afficher notification
end

return NotificationUI
```

**2. Créer le contrôleur**
```lua
-- Controllers/NotificationController.luau
local NotificationController = {}
local NotificationUI = nil

function NotificationController.initialize(deps)
    NotificationUI = deps.NotificationUI
end

function NotificationController.connect()
    -- Connecter aux RemoteEvents
end

return NotificationController
```

**3. Intégrer dans init.client.luau**
```lua
local NotificationUI = require(uiFolder:WaitForChild("NotificationUI"))
local NotificationController = require(controllersFolder:WaitForChild("NotificationController"))

NotificationUI.create()

NotificationController.initialize({
    NotificationUI = NotificationUI
})

NotificationController.connect()
```

**C'est tout ! ✅**

---

## 📚 Ressources

- **init.client.luau** - Point d'entrée principal
- **init.client.OLD_BACKUP.luau** - Ancien code monolithique (référence)
- **CLIENT_ARCHITECTURE.md** - Ce document

---

**Architecture client MVC professionnelle - Modulaire et maintenable ! 🎉**

*Créé avec l'architecture modulaire v2.0*
