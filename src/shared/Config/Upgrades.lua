export type UpgradeDef = {
	id: string,
	name: string,
	blurb: string,
	maxLevel: number,
	baseCost: number,
	costScale: number,
	category: "plane" | "hangar" | "player",
	stat: string,
}

local plane: { UpgradeDef } = {
	{
		id = "PlaneLevel",
		name = "Plane Level",
		blurb = "Global fold rank. Your equipped plane flies farther.",
		maxLevel = 100,
		baseCost = 18,
		costScale = 1.13,
		category = "plane",
		stat = "distance",
	},
}

local hangar: { UpgradeDef } = {
	{
		id = "Storage",
		name = "Storage",
		blurb = "More unique planes count toward offline income. Extra display stands.",
		maxLevel = 30,
		baseCost = 120,
		costScale = 1.2,
		category = "hangar",
		stat = "capacity",
	},
	{
		id = "OfflineIncome",
		name = "Offline Income",
		blurb = "Hangar earns more coins every minute you are away.",
		maxLevel = 50,
		baseCost = 80,
		costScale = 1.18,
		category = "hangar",
		stat = "idle",
	},
}

local player: { UpgradeDef } = {
	{
		id = "StrengthGain",
		name = "Strength Gain",
		blurb = "Throws and benches grant more strength.",
		maxLevel = 80,
		baseCost = 25,
		costScale = 1.14,
		category = "player",
		stat = "strength",
	},
	{
		id = "MultiPlane",
		name = "Planes at Once",
		blurb = "Launch extra planes each throw (up to 5, plus a Robux extra).",
		maxLevel = 4,
		baseCost = 400,
		costScale = 2.1,
		category = "player",
		stat = "volley",
	},
	{
		id = "Luck",
		name = "Luck",
		blurb = "Better Rare+ crate odds. Does not change throw distance or coins.",
		maxLevel = 50,
		baseCost = 90,
		costScale = 1.22,
		category = "player",
		stat = "luck",
	},
}

local byId: { [string]: UpgradeDef } = {}
for _, def in plane do
	byId[def.id] = def
end
for _, def in hangar do
	byId[def.id] = def
end
for _, def in player do
	byId[def.id] = def
end

local Upgrades = {
	Plane = plane,
	Hangar = hangar,
	Player = player,
	ById = byId,
}

function Upgrades.cost(def: UpgradeDef, currentLevel: number): number
	return math.floor(def.baseCost * (def.costScale ^ currentLevel))
end

function Upgrades.buyMax(def: UpgradeDef, currentLevel: number, coins: number): (number, number)
	local bought = 0
	local spent = 0
	while currentLevel + bought < def.maxLevel do
		local nextCost = Upgrades.cost(def, currentLevel + bought)
		if spent + nextCost > coins then
			break
		end
		spent += nextCost
		bought += 1
	end
	return bought, spent
end

return Upgrades
