local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Numbers = Config.Numbers

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)
local Monetization = require(script.Parent.Monetization)
local Stats = require(script.Parent.Parent.Lib.Stats)

local Rebirth = {}

function Rebirth.preview(player: Player)
	local data = Data.get(player)
	if not data then
		return nil
	end
	local flags = Monetization.flags(player)
	local cost = Stats.rebirthCost(data.rebirths)
	local bonus = Numbers.RebirthBonus
	if flags.doubleRebirth then
		bonus *= 2
	end
	local current = Stats.rebirthMultiplier(data, flags)
	local nextMult = 1 + (data.rebirths + 1) * bonus
	return {
		cost = cost,
		canAfford = data.coins >= cost,
		currentMultiplier = current,
		nextMultiplier = nextMult,
		gain = nextMult - current,
		rebirths = data.rebirths,
		keeps = { "Planes", "Hangar upgrades", "Scrap", "Crate keys" },
		resets = { "Coins", "Plane upgrades" },
	}
end

function Rebirth.start()
	Remotes.GetRebirthPreview.OnServerInvoke = function(player)
		return Rebirth.preview(player)
	end

	Remotes.Rebirth.OnServerEvent:Connect(function(player)
		local data = Data.get(player)
		if not data then
			return
		end
		local preview = Rebirth.preview(player)
		if not preview or not preview.canAfford then
			Economy.notify(player, "Need " .. tostring(preview and preview.cost or 0) .. " coins to rebirth.", "error")
			return
		end
		data.coins = 0
		data.upgrades.Power = 0
		data.upgrades.PaperQuality = 0
		data.upgrades.FoldPrecision = 0
		data.upgrades.WingSpan = 0
		data.rebirths += 1
		Data.replicate(player)
		Economy.notify(player, "Rebirth " .. tostring(data.rebirths) .. "! +" .. string.format("%.0f%%", preview.gain * 100) .. " forever.", "success")
	end)
end

return Rebirth
