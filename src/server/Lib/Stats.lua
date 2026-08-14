local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Numbers = Config.Numbers
local Planes = Config.Planes
local Upgrades = Config.Upgrades

local Stats = {}

local function ownedCount(data): number
	local n = 0
	for _ in data.ownedPlanes do
		n += 1
	end
	return n
end

function Stats.planeMultiplier(data): number
	local total = 0
	for _, id in data.equipped do
		local def = Planes.get(id)
		if def then
			total += def.multiplier
		end
	end
	if total <= 0 then
		local starter = Planes.get(Planes.StarterId)
		return if starter then starter.multiplier else 1
	end
	return total
end

function Stats.rebirthMultiplier(data, flags): number
	local bonus = Numbers.RebirthBonus
	if flags.doubleRebirth then
		bonus *= 2
	end
	return 1 + data.rebirths * bonus
end

function Stats.coinMultiplier(data, flags): number
	local mult = 1
	if flags.tripleCoins then
		mult = 3
	elseif flags.doubleCoins then
		mult = 2
	end
	if flags.vip then
		mult *= Numbers.VIPCoinMultiplier
	end
	if flags.bundle then
		mult *= Numbers.BundleCoinMultiplier
	end
	if data.boosts.doubleCoinsUntil > os.time() then
		mult *= Numbers.BoostMultiplier
	end
	if flags.magnet then
		mult *= 1 + Numbers.MagnetBonus
	end
	return mult
end

function Stats.luckMultiplier(flags, luckyRoll: boolean): number
	if luckyRoll then
		return 4
	end
	if flags.superLuck then
		return 4
	end
	if flags.doubleLuck then
		return 2
	end
	return 1
end

function Stats.throwCooldown(flags): number
	return if flags.fastThrow then Numbers.FastThrowCooldown else Numbers.ThrowCooldown
end

function Stats.autoInterval(flags): number
	return if flags.fastThrow then Numbers.FastAutoThrowInterval else Numbers.AutoThrowInterval
end

function Stats.equipSlots(data, flags): number
	local slots = Numbers.BaseEquipSlots + (data.hangarUpgrades.DisplaySlots or 0) * Numbers.DisplaySlotsPerLevel
	if flags.extraSlot then
		slots += Numbers.ExtraEquipGamepass
	end
	return math.max(1, slots)
end

function Stats.capacity(data, flags): number
	local cap = Numbers.HangarBaseCapacity + (data.hangarUpgrades.Capacity or 0) * Numbers.HangarCapacityPerLevel
	if flags.megaCapacity then
		cap += Numbers.HangarMegaCapacityBonus
	end
	return cap
end

function Stats.offlineHours(data, flags): number
	if flags.offlinePlus or flags.vip then
		return Numbers.OfflineHoursVIP
	end
	return math.min(Numbers.OfflineHoursFree, 0.5 + (data.hangarUpgrades.OfflineHours or 0) * Numbers.OfflineHoursPerUpgrade)
end

function Stats.idlePerMinute(data, flags): number
	local rate = Numbers.IdleBasePerMinute + (data.hangarUpgrades.IdleRate or 0) * Numbers.IdlePerLevel
	local owned = math.min(ownedCount(data), Stats.capacity(data, flags))
	rate *= 1 + owned * Numbers.IdleOwnedBonus
	rate *= Stats.rebirthMultiplier(data, flags)
	rate *= Stats.coinMultiplier(data, flags)
	return rate
end

function Stats.distance(data, flags): number
	local power = data.upgrades.Power or 0
	local wings = data.upgrades.WingSpan or 0
	local dist = Numbers.BaseDistance
		* (1 + power * 0.02)
		* (1 + wings * 0.025)
		* Stats.planeMultiplier(data)
		* Stats.rebirthMultiplier(data, flags)
	return dist
end

function Stats.coinsPerStud(data, flags): number
	local quality = data.upgrades.PaperQuality or 0
	return Numbers.BaseCoinsPerStud * (1 + quality * 0.03) * Stats.coinMultiplier(data, flags)
end

function Stats.variance(data): number
	local precision = data.upgrades.FoldPrecision or 0
	return math.max(0.12, 0.42 - precision * 0.0035)
end

function Stats.rebirthCost(rebirths: number): number
	return math.floor(Numbers.RebirthBaseCost * (Numbers.RebirthCostScale ^ rebirths))
end

function Stats.upgradeLevel(data, id: string): number
	local def = Upgrades.ById[id]
	if not def then
		return 0
	end
	if def.category == "hangar" then
		return data.hangarUpgrades[id] or 0
	end
	return data.upgrades[id] or 0
end

return Stats
