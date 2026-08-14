local Planes = require(script.Parent.Planes)
local Numbers = require(script.Parent.Numbers)

export type CrateDef = {
	id: string,
	name: string,
	blurb: string,
	currency: "coins" | "free",
	cost: number,
	paidRandom: boolean,
	color: Color3,
	weights: { [string]: number },
	robuxKey: string?,
}

local Crates = {
	List = {
		{
			id = "Paper",
			name = "Paper Crate",
			blurb = "Everyday folds. Coins, or buy one roll with Robux.",
			currency = "coins",
			cost = 1500,
			paidRandom = false,
			robuxKey = "CratePaper",
			color = Color3.fromRGB(230, 220, 200),
			weights = {
				Common = 52,
				Uncommon = 28,
				Rare = 12,
				Epic = 5.5,
				Legendary = 2.2,
				Mythic = 0.28,
				Secret = 0.02,
			},
		},
		{
			id = "Tape",
			name = "Tape Crate",
			blurb = "Stuck together better. Mid odds.",
			currency = "coins",
			cost = 8000,
			paidRandom = false,
			robuxKey = "CrateTape",
			color = Color3.fromRGB(120, 190, 220),
			weights = {
				Common = 36,
				Uncommon = 32,
				Rare = 18,
				Epic = 9,
				Legendary = 4,
				Mythic = 0.9,
				Secret = 0.1,
			},
		},
		{
			id = "Box",
			name = "Box Crate",
			blurb = "A packed box of better paper.",
			currency = "coins",
			cost = 35000,
			paidRandom = false,
			robuxKey = "CrateBox",
			color = Color3.fromRGB(90, 160, 255),
			weights = {
				Common = 22,
				Uncommon = 30,
				Rare = 24,
				Epic = 15,
				Legendary = 7,
				Mythic = 1.8,
				Secret = 0.2,
			},
		},
		{
			id = "Hangar",
			name = "Hangar Crate",
			blurb = "Collector odds. Built for the index.",
			currency = "coins",
			cost = 120000,
			paidRandom = false,
			robuxKey = "CrateHangar",
			color = Color3.fromRGB(180, 110, 70),
			weights = {
				Common = 12,
				Uncommon = 24,
				Rare = 28,
				Epic = 22,
				Legendary = 11,
				Mythic = 2.7,
				Secret = 0.3,
			},
		},
		{
			id = "Golden",
			name = "Golden Crate",
			blurb = "Premium folds. Coin grind or a Robux roll.",
			currency = "coins",
			cost = 500000,
			paidRandom = false,
			robuxKey = "CrateGolden",
			color = Color3.fromRGB(255, 200, 70),
			weights = {
				Common = 6,
				Uncommon = 14,
				Rare = 26,
				Epic = 28,
				Legendary = 18,
				Mythic = 7,
				Secret = 1,
			},
		},
	} :: { CrateDef },
	PityLegendary = Numbers.PityLegendary,
	PityMythic = Numbers.PityMythic,
}

local byId: { [string]: CrateDef } = {}
for _, def in Crates.List do
	byId[def.id] = def
end
Crates.ById = byId

function Crates.get(id: string): CrateDef?
	return byId[id]
end

function Crates.planesForRarity(rarity: string): { string }
	return Planes.idsOfRarity(rarity)
end

return Crates
