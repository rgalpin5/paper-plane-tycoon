local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(script.World)
World.build()

require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local Data = require(script.Services.Data)
local Economy = require(script.Services.Economy)
local Monetization = require(script.Services.Monetization)
local Hangar = require(script.Services.Hangar)
local Plots = require(script.Services.Plots)
local Throw = require(script.Services.Throw)
local Crate = require(script.Services.Crate)
local Idle = require(script.Services.Idle)
local Daily = require(script.Services.Daily)
local Rebirth = require(script.Services.Rebirth)
local Codes = require(script.Services.Codes)
local Benches = require(script.Services.Benches)
local RotationShop = require(script.Services.RotationShop)

local function hookCharacter(player: Player)
	local function onCharacter(character)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if humanoid and humanoid:IsA("Humanoid") then
			humanoid.WalkSpeed = 20
			humanoid.JumpPower = 50
		end
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		onCharacter(player.Character)
	end
end

Players.PlayerAdded:Connect(hookCharacter)
for _, player in Players:GetPlayers() do
	hookCharacter(player)
end

Data.start()
Economy.start()
Monetization.start()
Hangar.start()
Plots.start()
Throw.start()
Crate.start()
Idle.start()
Daily.start()
Rebirth.start()
Codes.start()
Benches.start()
RotationShop.start()

print("[Paper Plane Tycoon] Hub + hallway server ready.")
