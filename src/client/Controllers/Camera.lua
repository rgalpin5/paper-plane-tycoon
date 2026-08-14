local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Camera = {}
local camera = Workspace.CurrentCamera
local following = false
local saved: CFrame?
local janitor = Janitor.new()

function Camera.follow(origin: Vector3, landing: Vector3, duration: number)
	if following then
		return
	end
	following = true
	janitor:Cleanup()
	saved = camera.CFrame
	camera.CameraType = Enum.CameraType.Scriptable
	local t0 = os.clock()
	janitor:Add(
		RunService.RenderStepped:Connect(function()
			local a = math.clamp((os.clock() - t0) / duration, 0, 1)
			local pos = origin:Lerp(landing, a)
			local arc = math.sin(a * math.pi) * 28
			pos += Vector3.new(0, arc, 0)
			local behind = pos + Vector3.new(0, 8, -16)
			camera.CFrame = CFrame.lookAt(behind, pos + Vector3.new(0, 2, 0))
			if a >= 1 then
				janitor:Cleanup()
				task.delay(0.35, function()
					if saved then
						camera.CFrame = saved
					end
					camera.CameraType = Enum.CameraType.Custom
					local char = Players.LocalPlayer.Character
					if char then
						camera.CameraSubject = char:FindFirstChildWhichIsA("Humanoid")
					end
					following = false
				end)
			end
		end),
		"Disconnect"
	)
end

return Camera
