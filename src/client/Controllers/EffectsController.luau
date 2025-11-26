--[[
	EffectsController
	Gère les effets visuels côté client (camera shake, particles, etc.)
]]

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local EffectsController = {}
EffectsController.Camera = nil

-- Initialiser
function EffectsController:Init()
	self.Camera = Workspace.CurrentCamera
	print("✅ EffectsController initialisé")
end

-- Effet de screen shake
function EffectsController:CameraShake(intensity, duration)
	intensity = intensity or 0.1
	duration = duration or 0.2

	local originalCFrame = self.Camera.CFrame

	task.spawn(function()
		local elapsed = 0
		local steps = math.floor(duration / 0.03)

		for i = 1, steps do
			elapsed = elapsed + 0.03

			local shake = CFrame.new(
				math.random(-intensity * 10, intensity * 10) / 10,
				math.random(-intensity * 10, intensity * 10) / 10,
				math.random(-intensity * 10, intensity * 10) / 10
			)

			self.Camera.CFrame = originalCFrame * shake
			task.wait(0.03)
		end

		self.Camera.CFrame = originalCFrame
	end)
end

-- Effet de flash coloré
function EffectsController:ColorFlash(color, intensity, duration)
	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.TintColor = color
	colorCorrection.Parent = game:GetService("Lighting")

	-- Fade in
	local fadeIn = TweenService:Create(colorCorrection, TweenInfo.new(duration / 2), {
		Saturation = intensity
	})
	fadeIn:Play()
	fadeIn.Completed:Wait()

	-- Fade out
	local fadeOut = TweenService:Create(colorCorrection, TweenInfo.new(duration / 2), {
		Saturation = 0
	})
	fadeOut:Play()
	fadeOut.Completed:Wait()

	colorCorrection:Destroy()
end

-- Créer des particules de collecte autour du joueur
function EffectsController:CreateCollectParticles(player, color)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Créer un attachment temporaire
	local attachment = Instance.new("Attachment")
	attachment.Parent = hrp

	-- Particules
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Color = ColorSequence.new(color)
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particles.Lifetime = NumberRange.new(0.5, 1)
	particles.Rate = 50
	particles.Speed = NumberRange.new(5, 10)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Rotation = NumberRange.new(0, 360)
	particles.RotSpeed = NumberRange.new(-100, 100)
	particles.LightEmission = 1
	particles.Parent = attachment

	-- Émettre et détruire
	particles:Emit(20)

	task.delay(2, function()
		attachment:Destroy()
	end)
end

-- Effet de vague de couleur au sol
function EffectsController:GroundWave(position, color, size)
	local wave = Instance.new("Part")
	wave.Shape = Enum.PartType.Cylinder
	wave.Size = Vector3.new(0.2, 1, 1)
	wave.Material = Enum.Material.Neon
	wave.Color = color
	wave.Anchored = true
	wave.CanCollide = false
	wave.Position = position + Vector3.new(0, 0.1, 0)
	wave.Orientation = Vector3.new(0, 0, 90)
	wave.Transparency = 0.5
	wave.Parent = Workspace

	-- Animation d'expansion
	local tween = TweenService:Create(wave, TweenInfo.new(0.5), {
		Size = Vector3.new(0.2, size, size),
		Transparency = 1
	})

	tween:Play()
	tween.Completed:Wait()

	wave:Destroy()
end

return EffectsController
