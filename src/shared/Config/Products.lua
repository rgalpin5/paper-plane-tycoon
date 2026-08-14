--[[
	Paste Creator Hub IDs here after you create Game Passes and Developer Products.
	Leave 0 until then. The in-game shop lists every product; prompts are skipped while the ID is 0.

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
		{ key = "AutoThrow", name = "Auto Throw", blurb = "Planes launch themselves while you hang out.", id = 0, priceHint = 99, tier = "impulse" },
		{ key = "SkipCrateAnim", name = "Skip Crate Anim", blurb = "Instant crate results. No waiting.", id = 0, priceHint = 49, tier = "impulse" },
		{ key = "MagnetCoins", name = "Magnet Coins", blurb = "Landing bursts pull extra coins to you.", id = 0, priceHint = 75, tier = "impulse" },
		{ key = "RainbowTrail", name = "Rainbow Trail", blurb = "Every throw leaves a rainbow paper trail.", id = 0, priceHint = 49, tier = "impulse" },
		{ key = "DoubleCoins", name = "2× Coins", blurb = "Permanent double coins from throws and hangar.", id = 0, priceHint = 199, tier = "mid" },
		{ key = "DoubleLuck", name = "2× Luck", blurb = "Rare+ crate odds are doubled, then re-normalized.", id = 0, priceHint = 199, tier = "mid" },
		{ key = "FastThrow", name = "Fast Throw", blurb = "Shorter cooldown and faster auto-throw.", id = 0, priceHint = 149, tier = "mid" },
		{ key = "ExtraEquipSlot", name = "Extra Equip Slot", blurb = "+1 plane equipped on top of hangar slots.", id = 0, priceHint = 149, tier = "mid" },
		{ key = "DoubleDaily", name = "2× Daily", blurb = "Daily streak coin rewards are doubled.", id = 0, priceHint = 129, tier = "mid" },
		{ key = "TripleCoins", name = "3× Coins", blurb = "Permanent triple coins. Stacks with 2× as 3×.", id = 0, priceHint = 399, tier = "high" },
		{ key = "SuperLuck", name = "Super Luck", blurb = "Rare+ crate odds ×4, then re-normalized.", id = 0, priceHint = 449, tier = "high" },
		{ key = "OfflinePlus", name = "Offline+", blurb = "Offline hangar cap raised to 8 hours.", id = 0, priceHint = 299, tier = "high" },
		{ key = "MultiThrow", name = "Multi-Throw", blurb = "Each throw launches 2 planes.", id = 0, priceHint = 349, tier = "high" },
		{ key = "VIP", name = "VIP", blurb = "Chat tag, extra offline, extra daily crate, VIP pad, +15% coins.", id = 0, priceHint = 499, tier = "high" },
		{ key = "DoubleRebirth", name = "2× Rebirth", blurb = "Rebirth multiplier gains are doubled.", id = 0, priceHint = 799, tier = "whale" },
		{ key = "MythicStarter", name = "Mythic Starter Plane", blurb = "Start with Mythic Paper Phoenix.", id = 0, priceHint = 899, tier = "whale" },
		{ key = "HangarMegaCapacity", name = "Hangar Mega Capacity", blurb = "+50 hangar capacity.", id = 0, priceHint = 649, tier = "whale" },
		{ key = "BundleVIP", name = "VIP Bundle", blurb = "VIP + 2× Coins + Auto Throw in one pass.", id = 0, priceHint = 999, tier = "whale" },
	} :: { GamepassDef },

	DevProducts = {
		{ key = "CoinPackS", name = "Coin Pack S", blurb = "A pocket of coins.", id = 0, priceHint = 49, kind = "coins" },
		{ key = "CoinPackM", name = "Coin Pack M", blurb = "A stack of coins.", id = 0, priceHint = 99, kind = "coins" },
		{ key = "CoinPackL", name = "Coin Pack L", blurb = "A suitcase of coins.", id = 0, priceHint = 249, kind = "coins" },
		{ key = "CoinPackXL", name = "Coin Pack XL", blurb = "A vault of coins.", id = 0, priceHint = 499, kind = "coins" },
		{ key = "CrateKeys1", name = "Paper Keys ×1", blurb = "One Paper Crate key.", id = 0, priceHint = 25, kind = "keys" },
		{ key = "CrateKeys3", name = "Hangar Keys ×3", blurb = "Three Hangar Crate keys.", id = 0, priceHint = 79, kind = "keys" },
		{ key = "CrateKeys10", name = "Golden Keys ×10", blurb = "Ten Golden Crate keys.", id = 0, priceHint = 399, kind = "keys" },
		{ key = "Boost30", name = "30-min 2×", blurb = "Two times coins for 30 minutes.", id = 0, priceHint = 49, kind = "boost" },
		{ key = "StreakShield", name = "Streak Shield", blurb = "Miss a day without resetting your streak.", id = 0, priceHint = 75, kind = "streak" },
		{ key = "LuckyRoll", name = "Lucky Roll", blurb = "Next crate open uses Super Luck odds (disclosed in Details).", id = 0, priceHint = 99, kind = "luck" },
	} :: { ProductDef },

	CoinPackAmounts = {
		CoinPackS = 25000,
		CoinPackM = 120000,
		CoinPackL = 700000,
		CoinPackXL = 3_500_000,
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
