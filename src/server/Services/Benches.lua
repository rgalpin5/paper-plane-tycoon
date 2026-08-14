local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Numbers = Config.Numbers
local Products = Config.Products

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)
local Monetization = require(script.Parent.Monetization)
local Stats = require(script.Parent.Parent.Lib.Stats)
local World = require(script.Parent.Parent.World)

local Benches = {}
local seatedAt: { [Player]: string } = {}

local function ownsBench(player: Player, def): boolean
	if def.passKey == nil then
		return true
	end
	return Monetization.flags(player)[def.passKey] == true or Monetization.ownsKey(player, def.passKey)
end

local function eject(hum: Humanoid)
	hum.Sit = false
	hum.Jump = true
end

function Benches.start()
	for _, seat in World.benchSeats() do
		seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			local hum = seat.Occupant
			if not hum then
				for player, id in seatedAt do
					if id == seat:GetAttribute("BenchId") then
						local char = player.Character
						if not char or char:FindFirstChildWhichIsA("Humanoid") ~= hum then
							seatedAt[player] = nil
						end
					end
				end
				return
			end
			local player = Players:GetPlayerFromCharacter(hum.Parent)
			if not player then
				return
			end
			local benchId = seat:GetAttribute("BenchId") or "Free"
			local def = Stats.benchDef(benchId)
			if not ownsBench(player, def) then
				eject(hum)
				local pass = Products.GamepassByKey[def.passKey]
				if pass and pass.id ~= 0 then
					MarketplaceService:PromptGamePassPurchase(player, pass.id)
				else
					Economy.notify(player, "Need the " .. def.name .. " game pass. Paste its ID in Products.lua.", "info")
				end
				return
			end
			seatedAt[player] = benchId
			if not (Data.get(player) and Data.get(player).tutorial.benched) then
				local data = Data.get(player)
				if data and not data.tutorial.benched then
					data.tutorial.benched = true
					if data.tutorial.thrown and data.tutorial.upgraded then
						data.tutorial.complete = true
						Remotes.Tutorial:FireClient(player, "done")
					end
					Data.replicate(player)
				end
			end
		end)
	end

	task.spawn(function()
		while true do
			local dt = task.wait(Numbers.BenchTick)
			for player, benchId in seatedAt do
				local data = Data.get(player)
				local char = player.Character
				local hum = char and char:FindFirstChildWhichIsA("Humanoid")
				if not data or not hum or not hum.Sit then
					seatedAt[player] = nil
				else
					local def = Stats.benchDef(benchId)
					local gain = Stats.benchStrengthPerSecond(data, Monetization.flags(player), def.multi) * dt
					data.strength += gain
					Data.replicate(player)
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		seatedAt[player] = nil
	end)
end

function Benches.isSeated(player: Player): boolean
	return seatedAt[player] ~= nil
end

return Benches
