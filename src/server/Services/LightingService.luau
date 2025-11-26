--[[
	LightingService
	Configuration de l'éclairage et des effets visuels
]]

local Lighting = game:GetService("Lighting")

local LightingService = {}

-- Initialiser l'éclairage
function LightingService:Init()
	print("💡 Initialisation LightingService...")

	-- Configuration de base
	Lighting.Brightness = 1.5
	Lighting.Ambient = Color3.fromRGB(70, 80, 100)
	Lighting.OutdoorAmbient = Color3.fromRGB(100, 120, 140)
	Lighting.GlobalShadows = true
	Lighting.ClockTime = 14
	Lighting.GeographicLatitude = 45
	Lighting.ShadowSoftness = 0.2

	-- Effets visuels
	self:CreateBloom()
	self:CreateColorCorrection()

	print("✅ LightingService initialisé")
	return self
end

-- Créer l'effet Bloom
function LightingService:CreateBloom()
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.2
	bloom.Size = 15
	bloom.Threshold = 0.8
	bloom.Parent = Lighting

	print("  ✨ Bloom effect créé")
end

-- Créer la correction de couleurs
function LightingService:CreateColorCorrection()
	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Brightness = 0
	colorCorrection.Contrast = 0.1
	colorCorrection.Saturation = 0.2
	colorCorrection.Parent = Lighting

	print("  🎨 Color correction créée")
end

return LightingService
