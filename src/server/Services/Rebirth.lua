local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Numbers = Config.Numbers

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)
local Stats = require(script.Parent.Parent.Lib.Stats)

local Rebirth = {}

function Rebirth.preview(player: Player)
	local data = Data.get(player)
	if not data then
		return nil
	end
	local cost = Stats.rebirthCost(data.rebirths)
	local coinNow = Stats.rebirthCoinMult(data)
	local strNow = Stats.rebirthStrengthMult(data)
	local coinNext = 1 + (data.rebirths + 1) * Numbers.RebirthCoinBonus
	local strNext = 1 + (data.rebirths + 1) * Numbers.RebirthStrengthBonus
	return {
		cost = cost,
		canAfford = data.coins >= cost,
		currentCoin = coinNow,
		nextCoin = coinNext,
		currentStrength = strNow,
		nextStrength = strNext,
		coinGain = coinNext - coinNow,
		strengthGain = strNext - strNow,
		rebirths = data.rebirths,
		keeps = { "Planes", "Hangar upgrades", "Player upgrades", "Cosmetics", "Scrap" },
		resets = { "Coins", "Strength", "Plane level" },
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
		data.strength = Numbers.StarterStrength
		data.planeLevel = 0
		data.rebirths += 1
		Data.replicate(player)
		Economy.notify(
			player,
			string.format(
				"Rebirth %d! Coins ×%.2f  Strength ×%.2f",
				data.rebirths,
				preview.nextCoin,
				preview.nextStrength
			),
			"success"
		)
	end)
end

return Rebirth
