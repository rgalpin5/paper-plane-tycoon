--[[
	Paste Creator Hub IDs here after you create Game Passes and Developer Products.
	Leave 0 until then. The in-game shop lists every product; prompts are skipped while the ID is 0.

	Do NOT create the old Auto Throw / Magnet / Rainbow list. This is the launch set.

	Creator Hub: https://create.roblox.com/dashboard
	1. Open your experience → Monetization → Passes / Developer Products
	2. Create each row below
	3. Copy the numeric ID into `id`
]]

export type GamepassDef = {
	key: string,
	name: string,
	blurb: string,
	id: number,
	priceHint: number,
	tier: "impulse" | "mid" | "high" | "whale",
}

export type ProductDef = {
	key: string,
	name: string,
	blurb: string,
	id: number,
	priceHint: number,
	kind: string,
}

local Products = {
	Gamepasses = {
		{ key = "SkipCrateAnim", name = "Skip Crate Anim", blurb = "Instant crate results.", id = 0, priceHint = 49, tier = "impulse" },
		{ key = "BenchBronze", name = "Bronze Bench", blurb = "Sit for 2× strength. No coins while seated.", id = 0, priceHint = 49, tier = "impulse" },
		{ key = "ExtraCosmeticSlots", name = "Extra Cosmetic Slots", blurb = "Equip 5 trails/auras/trinkets instead of 3.", id = 0, priceHint = 199, tier = "mid" },
		{ key = "DoubleCoins", name = "2× Coins", blurb = "Permanent double coins from throws and hangar.", id = 0, priceHint = 199, tier = "mid" },
		{ key = "DoubleLuck", name = "2× Luck", blurb = "Rare+ crate odds doubled, then re-normalized.", id = 0, priceHint = 199, tier = "mid" },
		{ key = "ExtraPlaneThrow", name = "Extra Plane Throw", blurb = "+1 plane per throw on top of the player upgrade.", id = 0, priceHint = 249, tier = "mid" },
		{ key = "BenchSilver", name = "Silver Bench", blurb = "Sit for 5× strength. No coins while seated.", id = 0, priceHint = 149, tier = "mid" },
		{ key = "OfflinePlus", name = "Offline+", blurb = "Offline hangar cap raised to 8 hours.", id = 0, priceHint = 299, tier = "high" },
		{ key = "HangarStoragePlus", name = "Hangar Storage+", blurb = "+20 hangar storage.", id = 0, priceHint = 399, tier = "high" },
		{ key = "VIP", name = "VIP", blurb = "Chat tag, +15% coins, 8h offline, extra daily coins.", id = 0, priceHint = 499, tier = "high" },
		{ key = "BenchGold", name = "Gold Bench", blurb = "Sit for 12× strength. No coins while seated.", id = 0, priceHint = 399, tier = "high" },
		{ key = "BenchDiamond", name = "Diamond Bench", blurb = "Sit for 30× strength. No coins while seated.", id = 0, priceHint = 799, tier = "whale" },
	} :: { GamepassDef },

	DevProducts = {
		{ key = "CoinPackS", name = "Coin Pack S", blurb = "A pocket of coins.", id = 0, priceHint = 49, kind = "coins" },
		{ key = "CoinPackM", name = "Coin Pack M", blurb = "A stack of coins.", id = 0, priceHint = 99, kind = "coins" },
		{ key = "CoinPackL", name = "Coin Pack L", blurb = "A suitcase of coins.", id = 0, priceHint = 249, kind = "coins" },
		{ key = "CoinPackXL", name = "Coin Pack XL", blurb = "A vault of coins.", id = 0, priceHint = 499, kind = "coins" },
		{ key = "CratePaper", name = "Open Paper Crate", blurb = "One Paper Crate roll. Odds in Details.", id = 0, priceHint = 25, kind = "crate" },
		{ key = "CrateTape", name = "Open Tape Crate", blurb = "One Tape Crate roll. Odds in Details.", id = 0, priceHint = 79, kind = "crate" },
		{ key = "CrateBox", name = "Open Box Crate", blurb = "One Box Crate roll. Odds in Details.", id = 0, priceHint = 149, kind = "crate" },
		{ key = "CrateHangar", name = "Open Hangar Crate", blurb = "One Hangar Crate roll. Odds in Details.", id = 0, priceHint = 249, kind = "crate" },
		{ key = "CrateGolden", name = "Open Golden Crate", blurb = "One Golden Crate roll. Odds in Details.", id = 0, priceHint = 399, kind = "crate" },
		{ key = "ShopReroll", name = "Reroll Rotating Shop", blurb = "New 3 cosmetics until this 4-hour window ends.", id = 0, priceHint = 49, kind = "reroll" },
	} :: { ProductDef },

	CoinPackAmounts = {
		CoinPackS = 25000,
		CoinPackM = 120000,
		CoinPackL = 700000,
		CoinPackXL = 3_500_000,
	},

	CrateProductToId = {
		CratePaper = "Paper",
		CrateTape = "Tape",
		CrateBox = "Box",
		CrateHangar = "Hangar",
		CrateGolden = "Golden",
	},
}

local gamepassByKey: { [string]: GamepassDef } = {}
local gamepassById: { [number]: GamepassDef } = {}
for _, def in Products.Gamepasses do
	gamepassByKey[def.key] = def
	if def.id ~= 0 then
		gamepassById[def.id] = def
	end
end

local productByKey: { [string]: ProductDef } = {}
local productById: { [number]: ProductDef } = {}
for _, def in Products.DevProducts do
	productByKey[def.key] = def
	if def.id ~= 0 then
		productById[def.id] = def
	end
end

Products.GamepassByKey = gamepassByKey
Products.GamepassById = gamepassById
Products.ProductByKey = productByKey
Products.ProductById = productById

function Products.refreshIndexes()
	table.clear(gamepassById)
	table.clear(productById)
	for _, def in Products.Gamepasses do
		if def.id ~= 0 then
			gamepassById[def.id] = def
		end
	end
	for _, def in Products.DevProducts do
		if def.id ~= 0 then
			productById[def.id] = def
		end
	end
end

return Products
