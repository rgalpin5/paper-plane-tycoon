export type CosmeticDef = {
	id: string,
	name: string,
	kind: "trail" | "aura" | "trinket",
	stat: "coins" | "strength",
	percent: number,
	cost: number,
	color: Color3,
	blurb: string,
}

local Numbers = require(script.Parent.Numbers)

local function item(
	id: string,
	name: string,
	kind: "trail" | "aura" | "trinket",
	stat: "coins" | "strength",
	percent: number,
	cost: number,
	color: Color3,
	blurb: string
): CosmeticDef
	return {
		id = id,
		name = name,
		kind = kind,
		stat = stat,
		percent = percent,
		cost = cost,
		color = color,
		blurb = blurb,
	}
end

local list: { CosmeticDef } = {
	item("RedRibbon", "Red Ribbon", "trail", "coins", 0.06, 2500, Color3.fromRGB(220, 60, 60), "+6% coins while equipped"),
	item("SkyInk", "Sky Ink", "trail", "strength", 0.07, 2800, Color3.fromRGB(70, 140, 230), "+7% strength gain while equipped"),
	item("GoldDust", "Gold Dust", "trail", "coins", 0.10, 12000, Color3.fromRGB(255, 210, 70), "+10% coins while equipped"),
	item("StormRibbon", "Storm Ribbon", "trail", "strength", 0.11, 14000, Color3.fromRGB(90, 110, 180), "+11% strength gain while equipped"),
	item("NeonStream", "Neon Stream", "trail", "coins", 0.14, 45000, Color3.fromRGB(40, 255, 180), "+14% coins while equipped"),
	item("PaperSmoke", "Paper Smoke", "trail", "strength", 0.15, 48000, Color3.fromRGB(200, 200, 210), "+15% strength gain while equipped"),

	item("WarmGlow", "Warm Glow", "aura", "coins", 0.08, 6000, Color3.fromRGB(255, 170, 80), "+8% coins while equipped"),
	item("ColdFold", "Cold Fold", "aura", "strength", 0.09, 6500, Color3.fromRGB(140, 210, 255), "+9% strength gain while equipped"),
	item("EmberRing", "Ember Ring", "aura", "coins", 0.12, 22000, Color3.fromRGB(255, 90, 40), "+12% coins while equipped"),
	item("OzoneAura", "Ozone Aura", "aura", "strength", 0.13, 24000, Color3.fromRGB(80, 255, 200), "+13% strength gain while equipped"),
	item("GoldenPulse", "Golden Pulse", "aura", "coins", 0.18, 90000, Color3.fromRGB(255, 220, 90), "+18% coins while equipped"),
	item("ShadowFold", "Shadow Fold", "aura", "strength", 0.18, 92000, Color3.fromRGB(40, 20, 70), "+18% strength gain while equipped"),

	item("TinyBell", "Tiny Bell", "trinket", "coins", 0.05, 1800, Color3.fromRGB(255, 220, 120), "+5% coins while equipped"),
	item("LeadWeight", "Lead Weight", "trinket", "strength", 0.06, 2000, Color3.fromRGB(90, 90, 100), "+6% strength gain while equipped"),
	item("CoinClip", "Coin Clip", "trinket", "coins", 0.11, 16000, Color3.fromRGB(232, 186, 64), "+11% coins while equipped"),
	item("IronClip", "Iron Paperclip", "trinket", "strength", 0.12, 17000, Color3.fromRGB(160, 170, 180), "+12% strength gain while equipped"),
	item("CompassRose", "Compass Rose", "trinket", "coins", 0.16, 70000, Color3.fromRGB(80, 160, 120), "+16% coins while equipped"),
	item("SteelRivet", "Steel Rivet", "trinket", "strength", 0.16, 72000, Color3.fromRGB(120, 130, 150), "+16% strength gain while equipped"),
}

local byId: { [string]: CosmeticDef } = {}
for _, def in list do
	byId[def.id] = def
end

local Cosmetics = {
	List = list,
	ById = byId,
}

function Cosmetics.get(id: string): CosmeticDef?
	return byId[id]
end

local function shuffle(ids: { string }, seed: number)
	local rng = Random.new(seed)
	for i = #ids, 2, -1 do
		local j = rng:NextInteger(1, i)
		ids[i], ids[j] = ids[j], ids[i]
	end
end

function Cosmetics.rotationIds(now: number, salt: number?): { string }
	local period = Numbers.RotationSeconds
	local bucket = math.floor(now / period)
	local ids = {}
	for _, def in list do
		table.insert(ids, def.id)
	end
	shuffle(ids, bucket * 7919 + (salt or 0))
	return { ids[1], ids[2], ids[3] }
end

function Cosmetics.rotationEndsAt(now: number): number
	local period = Numbers.RotationSeconds
	return (math.floor(now / period) + 1) * period
end

return Cosmetics
