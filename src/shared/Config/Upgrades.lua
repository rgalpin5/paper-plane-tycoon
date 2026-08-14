local Numbers = require(script.Parent.Numbers)

export type UpgradeDef = {
	id: string,
	name: string,
	blurb: string,
	maxLevel: number,
	baseCost: number,
	costScale: number,
	category: "plane" | "hangar",
	stat: string,
}

local plane: { UpgradeDef } = {
	{
		id = "Power",
		name = "Power",
		blurb = "Throw farther. More studs, more coins.",
		maxLevel = 100,
		baseCost = 15,
		costScale = 1.12,
		category = "plane",
		stat = "distance",
	},
	{
		id = "PaperQuality",
		name = "Paper Quality",
		blurb = "Richer paper pays more coins per stud.",
		maxLevel = 80,
		baseCost = 22,
		costScale = 1.13,
		category = "plane",
		stat = "coins",
	},
	{
		id = "FoldPrecision",
		name = "Fold Precision",
		blurb = "Tighter folds, more consistent distance.",
		maxLevel = 80,
		baseCost = 18,
		costScale = 1.12,
		category = "plane",
		stat = "consistency",
	},
	{
		id = "WingSpan",
		name = "Wing Span",
		blurb = "Wider wings glide farther.",
		maxLevel = 50,
		baseCost = 40,
		costScale = 1.15,
		category = "plane",
		stat = "distance",
	},
}

local hangar: { UpgradeDef } = {
	{
		id = "Capacity",
		name = "Capacity",
		blurb = "Store more planes for a bigger idle bonus.",
		maxLevel = 30,
		baseCost = 120,
		costScale = 1.2,
		category = "hangar",
		stat = "capacity",
	},
	{
		id = "IdleRate",
		name = "Idle Rate",
		blurb = "Hangar earns more coins every minute.",
		maxLevel = 50,
		baseCost = 80,
		costScale = 1.18,
		category = "hangar",
		stat = "idle",
	},
	{
		id = "OfflineHours",
		name = "Offline Hours",
		blurb = "Raise the free offline cap (VIP still goes to 8h).",
		maxLevel = 10,
		baseCost = 400,
		costScale = 1.45,
		category = "hangar",
		stat = "offline",
	},
	{
		id = "DisplaySlots",
		name = "Display Slots",
		blurb = "Equip more planes at once for stacked throw power.",
		maxLevel = 5,
		baseCost = 750,
		costScale = 1.85,
		category = "hangar",
		stat = "slots",
	},
}

local byId: { [string]: UpgradeDef } = {}
for _, def in plane do
	byId[def.id] = def
end
for _, def in hangar do
	byId[def.id] = def
end

local Upgrades = {
	Plane = plane,
	Hangar = hangar,
	ById = byId,
	AutoThrowCost = Numbers.AutoThrowUpgradeCost,
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
