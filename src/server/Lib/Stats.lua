local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Numbers = Config.Numbers
local Planes = Config.Planes
local Upgrades = Config.Upgrades
local Cosmetics = Config.Cosmetics
local Rarities = Config.Rarities

local Stats = {}

local function ownedCount(data): number
	local n = 0
	for _ in data.ownedPlanes do
		n += 1
	end
	return n
end

function Stats.equippedPlaneId(data): string
	return data.equipped[1] or Planes.StarterId
end

function Stats.planeMultiplier(data): number
	local def = Planes.get(Stats.equippedPlaneId(data))
	return if def then def.multiplier else 1
end

function Stats.rebirthCoinMult(data): number
	return 1 + data.rebirths * Numbers.RebirthCoinBonus
end

function Stats.rebirthStrengthMult(data): number
	return 1 + data.rebirths * Numbers.RebirthStrengthBonus
end

function Stats.cosmeticMult(data, stat: string): number
	local total = 1
	for _, id in data.cosmeticsEquipped do
		local def = Cosmetics.get(id)
		if def and def.stat == stat then
			total += def.percent
		end
	end
	return total
end

function Stats.coinMultiplier(data, flags): number
	local mult = 1
	if flags.doubleCoins then
		mult = 2
	end
	if flags.vip then
		mult *= Numbers.VIPCoinMultiplier
	end
	if data.boosts.doubleCoinsUntil > os.time() then
		mult *= Numbers.BoostMultiplier
	end
	mult *= Stats.cosmeticMult(data, "coins")
	mult *= Stats.rebirthCoinMult(data)
	return mult
end

function Stats.luckMultiplier(data, flags): number
	local luck = 1 + (data.playerUpgrades.Luck or 0) * Numbers.LuckPerLevel
	if flags.doubleLuck then
		luck *= Numbers.LuckPassMultiplier
	end
	return luck
end

function Stats.strengthGainMult(data, _flags): number
	local m = 1 + (data.playerUpgrades.StrengthGain or 0) * Numbers.StrengthGainPerLevel
	m *= Stats.rebirthStrengthMult(data)
	m *= Stats.cosmeticMult(data, "strength")
	return m
end

function Stats.planesPerThrow(data, flags): number
	local n = Numbers.BasePlanesPerThrow + (data.playerUpgrades.MultiPlane or 0) * Numbers.MultiPlanePerLevel
	if flags.extraPlane then
		n += Numbers.ExtraPlaneThrowBonus
	end
	return math.clamp(n, 1, 6)
end

function Stats.cosmeticSlots(flags): number
	local slots = Numbers.BaseCosmeticSlots
	if flags.extraCosmeticSlots then
		slots += Numbers.ExtraCosmeticSlots
	end
	return slots
end

function Stats.storage(data, flags): number
	local cap = Numbers.HangarBaseStorage + (data.hangarUpgrades.Storage or 0) * Numbers.HangarStoragePerLevel
	if flags.storagePlus then
		cap += Numbers.HangarStoragePlusBonus
	end
	return cap
end

function Stats.stands(data, _flags): number
	local level = data.hangarUpgrades.Storage or 0
	local extra = math.floor(level / 5) * Numbers.HangarStandsPerFiveLevels
	return math.clamp(Numbers.HangarBaseStands + extra, 1, Numbers.HangarMaxStands)
end

function Stats.offlineHours(_data, flags): number
	if flags.offlinePlus or flags.vip then
		return Numbers.OfflineHoursVIP
	end
	return Numbers.OfflineHoursFree
end

function Stats.idlePerMinute(data, flags): number
	local rate = Numbers.IdleBasePerMinute + (data.hangarUpgrades.OfflineIncome or 0) * Numbers.IdlePerLevel
	local owned = math.min(ownedCount(data), Stats.storage(data, flags))
	rate *= 1 + owned * Numbers.IdleOwnedBonus
	rate *= Stats.coinMultiplier(data, flags)
	return rate
end

-- Distance = f(Strength) × equipped plane × plane level.
-- Strength uses a soft curve so early throws hit the 50 marker and late game fills the 1K hall.
function Stats.distance(data, _flags): number
	local str = math.max(1, data.strength or Numbers.StarterStrength)
	local dist = Numbers.BaseDistance + (str ^ Numbers.StrengthDistancePower) * Numbers.StrengthDistanceScale
	dist *= Stats.planeMultiplier(data)
	dist *= 1 + (data.planeLevel or 0) * Numbers.PlaneLevelDistance
	return dist
end

function Stats.coinsForDistance(data, flags, distance: number): number
	return distance * Numbers.BaseCoinsPerStud * Stats.coinMultiplier(data, flags)
end

function Stats.throwStrengthGain(data, flags): number
	return Numbers.ThrowStrengthGain * Stats.strengthGainMult(data, flags)
end

function Stats.benchStrengthPerSecond(data, flags, benchMulti: number): number
	return Numbers.BenchStrengthPerSecond * benchMulti * Stats.strengthGainMult(data, flags)
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
	if def.category == "player" then
		return data.playerUpgrades[id] or 0
	end
	if id == "PlaneLevel" then
		return data.planeLevel or 0
	end
	return 0
end

function Stats.bestPlaneId(data): string
	local bestId = Planes.StarterId
	local bestRank = -1
	local bestMult = -1
	local rankOf = {}
	for i, name in Rarities.Order do
		rankOf[name] = i
	end
	for id, count in data.ownedPlanes do
		if count > 0 then
			local def = Planes.get(id)
			if def then
				local rank = rankOf[def.rarity] or 0
				if rank > bestRank or (rank == bestRank and def.multiplier > bestMult) then
					bestRank = rank
					bestMult = def.multiplier
					bestId = id
				end
			end
		end
	end
	return bestId
end

function Stats.displayPlaneIds(data, flags): { string }
	local n = Stats.stands(data, flags)
	local best = Stats.bestPlaneId(data)
	local ids = { best }
	local rankOf = {}
	for i, name in Rarities.Order do
		rankOf[name] = i
	end
	local rest = {}
	for id, count in data.ownedPlanes do
		if count > 0 and id ~= best then
			local def = Planes.get(id)
			table.insert(rest, { id = id, rank = def and rankOf[def.rarity] or 0, mult = def and def.multiplier or 0 })
		end
	end
	table.sort(rest, function(a, b)
		if a.rank == b.rank then
			return a.mult > b.mult
		end
		return a.rank > b.rank
	end)
	for i = 1, n - 1 do
		if rest[i] then
			table.insert(ids, rest[i].id)
		end
	end
	return ids
end

function Stats.benchDef(benchId: string)
	for _, def in Numbers.Benches do
		if def.id == benchId then
			return def
		end
	end
	return Numbers.Benches[1]
end

return Stats
