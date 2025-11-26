--[[
	CameraEffects - Effets de caméra
	Gère les effets visuels sur la caméra (shake, etc.)
]]

local CameraEffects = {}

-- Faire trembler la caméra
function CameraEffects.shake(intensity, duration)
	local camera = workspace.CurrentCamera
	local originalCFrame = camera.CFrame

	intensity = intensity or 10
	duration = duration or 0.15

	task.spawn(function()
		local shakes = math.floor(duration / 0.03)
		for _ = 1, shakes do
			camera.CFrame = originalCFrame * CFrame.new(
				math.random(-intensity, intensity) / 100,
				math.random(-intensity, intensity) / 100,
				math.random(-intensity, intensity) / 100
			)
			task.wait(0.03)
		end
		camera.CFrame = originalCFrame
	end)
end

return CameraEffects
