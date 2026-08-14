local Planes = require(script.Parent.Planes)
local Numbers = require(script.Parent.Numbers)

export type CrateDef = {
	id: string,
	name: string,
	blurb: string,
	currency: "coins" | "keys" | "free",
	cost: number,
	paidRandom: boolean,
	color: Color3,
	weights: { [string]: number },
}

local Crates = {
	List = {
		{
			id = "Paper",
			name = "Paper Crate",
			blurb = "The everyday fold. Coins or a Paper Key.",
			currency = "coins",
			cost = 2500,
			paidRandom = false,
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
			id = "Hangar",
			name = "Hangar Crate",
			blurb = "Better odds. Built for collectors.",
			currency = "coins",
			cost = 12000,
			paidRandom = false,
			color = Color3.fromRGB(90, 160, 220),
			weights = {
				Common = 28,
				Uncommon = 32,
				Rare = 22,
				Epic = 12,
				Legendary = 5,
				Mythic = 0.9,
				Secret = 0.1,
			},
		},
		{
			id = "Golden",
			name = "Golden Crate",
			blurb = "Premium folds. Uses Golden Keys (Robux).",
			currency = "keys",
			cost = 1,
			paidRandom = true,
			color = Color3.fromRGB(255, 200, 70),
			weights = {
				Common = 8,
				Uncommon = 18,
				Rare = 28,
				Epic = 26,
				Legendary = 15,
				Mythic = 4.5,
				Secret = 0.5,
			},
		},
		{
			id = "Daily",
			name = "Daily Crate",
			blurb = "One free crate per day. Odds still shown.",
			currency = "free",
			cost = 0,
			paidRandom = false,
			color = Color3.fromRGB(120, 210, 150),
			weights = {
				Common = 40,
				Uncommon = 30,
				Rare = 18,
				Epic = 8,
				Legendary = 3.5,
				Mythic = 0.45,
				Secret = 0.05,
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
