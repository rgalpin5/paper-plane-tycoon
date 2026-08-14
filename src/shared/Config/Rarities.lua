local Rarities = {
	Order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
	Data = {
		Common = { color = Color3.fromRGB(190, 190, 190), scrap = 5, luckAffected = false },
		Uncommon = { color = Color3.fromRGB(90, 200, 120), scrap = 15, luckAffected = false },
		Rare = { color = Color3.fromRGB(80, 150, 255), scrap = 40, luckAffected = true },
		Epic = { color = Color3.fromRGB(180, 90, 255), scrap = 100, luckAffected = true },
		Legendary = { color = Color3.fromRGB(255, 200, 60), scrap = 300, luckAffected = true },
		Mythic = { color = Color3.fromRGB(255, 70, 110), scrap = 900, luckAffected = true },
		Secret = { color = Color3.fromRGB(255, 255, 255), scrap = 2500, luckAffected = true },
	},
}

function Rarities.color(name: string): Color3
	local entry = Rarities.Data[name]
	return if entry then entry.color else Color3.new(1, 1, 1)
end

function Rarities.scrap(name: string): number
	local entry = Rarities.Data[name]
	return if entry then entry.scrap else 5
end

function Rarities.isLuckAffected(name: string): boolean
	local entry = Rarities.Data[name]
	return if entry then entry.luckAffected else false
end

return Rarities
