local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Crates = Config.Crates
local Planes = Config.Planes
local Rarities = Config.Rarities
local Numbers = Config.Numbers

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)
local Hangar = require(script.Parent.Hangar)
local Monetization = require(script.Parent.Monetization)
local Stats = require(script.Parent.Parent.Lib.Stats)

local Crate = {}

local function weightedPick(entries: { { id: string, weight: number } }): string
	local total = 0
	for _, e in entries do
		total += e.weight
	end
	local roll = math.random() * total
	local acc = 0
	for _, e in entries do
		acc += e.weight
		if roll <= acc then
			return e.id
		end
	end
	return entries[#entries].id
end

function Crate.oddsTable(player: Player, crateId: string)
	local crate = Crates.get(crateId)
	if not crate then
		return nil
	end
	local data = Data.get(player)
	local flags = Monetization.flags(player)
	local luck = if data then Stats.luckMultiplier(data, flags) else 1
	local rarityWeights = {}
	local sum = 0
	for rarity, weight in crate.weights do
		local w = weight
		if luck > 1 and Rarities.isLuckAffected(rarity) then
			w *= luck
		end
		rarityWeights[rarity] = w
		sum += w
	end

	local rarityPercents = {}
	local planeRows = {}
	local check = 0
	for _, rarity in Rarities.Order do
		local w = rarityWeights[rarity] or 0
		local pct = if sum > 0 then (w / sum) * 100 else 0
		rarityPercents[rarity] = pct
		local ids = Planes.idsOfRarity(rarity)
		local each = if #ids > 0 then pct / #ids else 0
		for _, id in ids do
			local def = Planes.get(id)
			table.insert(planeRows, {
				id = id,
				name = def and def.name or id,
				rarity = rarity,
				percent = each,
			})
			check += each
		end
	end
	if #planeRows > 0 then
		planeRows[#planeRows].percent += 100 - check
	end

	return {
		crateId = crateId,
		name = crate.name,
		luck = luck,
		pityLegendary = Crates.PityLegendary,
		pityMythic = Crates.PityMythic,
		pity = if data then data.pity else { legendary = 0, mythic = 0 },
		rarityPercents = rarityPercents,
		planes = planeRows,
		paidRandom = false,
	}
end

local function pickPlane(player: Player, crateId: string, forceRarity: string?): string
	local crate = Crates.get(crateId) :: any
	local data = Data.get(player)
	local flags = Monetization.flags(player)
	local luck = Stats.luckMultiplier(data, flags)
	local entries = {}
	if forceRarity then
		for _, id in Planes.idsOfRarity(forceRarity) do
			table.insert(entries, { id = id, weight = 1 })
		end
		if #entries == 0 then
			return Planes.StarterId
		end
		return weightedPick(entries)
	end
	for _, def in Planes.List do
		local w = crate.weights[def.rarity] or 0
		if luck > 1 and Rarities.isLuckAffected(def.rarity) then
			w *= luck
		end
		if w > 0 then
			table.insert(entries, { id = def.id, weight = w })
		end
	end
	return weightedPick(entries)
end

function Crate.open(player: Player, crateId: string, opts: { free: boolean?, paidRobux: boolean?}?)
	opts = opts or {}
	local crate = Crates.get(crateId)
	local data = Data.get(player)
	if not crate or not data then
		return
	end

	if opts.paidRobux and Data.isPolicyRestricted(player) then
		Economy.notify(player, "Paid crates are unavailable in your region. Buy a guaranteed plane in the Index.", "error")
		return
	end

	if opts.free then
		-- caller paid
	elseif opts.paidRobux then
		-- ProcessReceipt already charged Robux
	else
		if not Economy.spendCoins(player, crate.cost) then
			Economy.notify(player, "Not enough coins.", "error")
			return
		end
	end

	data.pity.legendary += 1
	data.pity.mythic += 1

	local force = nil
	if data.pity.mythic >= Crates.PityMythic then
		force = "Mythic"
	elseif data.pity.legendary >= Crates.PityLegendary then
		force = "Legendary"
	end

	local planeId = pickPlane(player, crateId, force)
	local def = Planes.get(planeId)
	if not def then
		return
	end

	if def.rarity == "Mythic" or def.rarity == "Secret" then
		data.pity.mythic = 0
		data.pity.legendary = 0
	elseif def.rarity == "Legendary" then
		data.pity.legendary = 0
	end

	local duplicate, scrap = Hangar.grantPlane(player, planeId)
	data.stats.cratesOpened += 1

	local skipped = Monetization.flags(player).skipAnim
	Remotes.CrateOpened:FireClient(player, {
		crateId = crateId,
		planeId = planeId,
		duplicate = duplicate,
		scrap = scrap,
		rarity = def.rarity,
		pity = data.pity,
		skipped = skipped,
	})
	Data.replicate(player)

	if def.rarity == "Mythic" or def.rarity == "Secret" then
		local msg = player.DisplayName .. " unfolded " .. def.name .. " (" .. def.rarity .. ")!"
		Remotes.Announcement:FireAllClients(msg, def.rarity)
		pcall(function()
			local channel = TextChatService:FindFirstChild("TextChannels")
				and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
			if channel then
				channel:DisplaySystemMessage(msg)
			end
		end)
	end
end

function Crate.start()
	Remotes.OpenCrate.OnServerEvent:Connect(function(player, crateId)
		if typeof(crateId) ~= "string" then
			return
		end
		Crate.open(player, crateId, {})
	end)

	Remotes.BuyGuaranteedPlane.OnServerEvent:Connect(function(player, planeId)
		if typeof(planeId) ~= "string" then
			return
		end
		if not Data.isPolicyRestricted(player) then
			Economy.notify(player, "Guaranteed shop is for regions where paid crates are restricted.", "info")
			return
		end
		local def = Planes.get(planeId)
		if not def or def.rarity == "Secret" then
			return
		end
		local price = Numbers.GuaranteedPrices[def.rarity]
		if not price then
			return
		end
		local data = Data.get(player)
		if not data then
			return
		end
		if (data.ownedPlanes[planeId] or 0) > 0 then
			Economy.notify(player, "You already own this plane.", "info")
			return
		end
		if not Economy.spendCoins(player, price) then
			Economy.notify(player, "Not enough coins.", "error")
			return
		end
		Hangar.grantPlane(player, planeId)
		Data.replicate(player)
		Economy.notify(player, "Got " .. def.name .. "!", "success")
	end)

	Remotes.GetCrateOdds.OnServerInvoke = function(player, crateId)
		if typeof(crateId) ~= "string" then
			return nil
		end
		return Crate.oddsTable(player, crateId)
	end
end

return Crate
