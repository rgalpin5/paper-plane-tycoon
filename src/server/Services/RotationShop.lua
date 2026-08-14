local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Cosmetics = Config.Cosmetics

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)
local Monetization = require(script.Parent.Monetization)
local Stats = require(script.Parent.Parent.Lib.Stats)

local RotationShop = {}

local function offersFor(player: Player): { string }
	local data = Data.get(player)
	local salt = if data then data.rotationSalt else 0
	return Cosmetics.rotationIds(os.time(), salt)
end

function RotationShop.snapshot(player: Player)
	local data = Data.get(player)
	if not data then
		return nil
	end
	local ids = offersFor(player)
	local items = {}
	for _, id in ids do
		local def = Cosmetics.get(id)
		if def then
			table.insert(items, {
				id = def.id,
				name = def.name,
				kind = def.kind,
				stat = def.stat,
				percent = def.percent,
				cost = def.cost,
				blurb = def.blurb,
				owned = (data.cosmeticsOwned[id] or 0) > 0,
				equipped = table.find(data.cosmeticsEquipped, id) ~= nil,
			})
		end
	end
	return {
		items = items,
		endsAt = Cosmetics.rotationEndsAt(os.time()),
		slots = Stats.cosmeticSlots(Monetization.flags(player)),
		equipped = data.cosmeticsEquipped,
		owned = data.cosmeticsOwned,
	}
end

function RotationShop.start()
	Remotes.GetRotationShop.OnServerInvoke = function(player)
		return RotationShop.snapshot(player)
	end

	Remotes.BuyCosmetic.OnServerEvent:Connect(function(player, cosmeticId)
		if typeof(cosmeticId) ~= "string" then
			return
		end
		local data = Data.get(player)
		local def = Cosmetics.get(cosmeticId)
		if not data or not def then
			return
		end
		local offered = false
		for _, id in offersFor(player) do
			if id == cosmeticId then
				offered = true
				break
			end
		end
		if not offered then
			Economy.notify(player, "That item is not in this rotation.", "error")
			return
		end
		if (data.cosmeticsOwned[cosmeticId] or 0) > 0 then
			local scrap = 40
			data.scrap += scrap
			data.cosmeticsOwned[cosmeticId] += 1
			Data.replicate(player)
			Economy.notify(player, "Duplicate! +" .. scrap .. " scrap.", "info")
			return
		end
		if not Economy.spendCoins(player, def.cost) then
			Economy.notify(player, "Not enough coins.", "error")
			return
		end
		data.cosmeticsOwned[cosmeticId] = 1
		Data.replicate(player)
		Economy.notify(player, "Unlocked " .. def.name, "success")
	end)

	Remotes.EquipCosmetic.OnServerEvent:Connect(function(player, cosmeticId)
		if typeof(cosmeticId) ~= "string" then
			return
		end
		local data = Data.get(player)
		if not data or (data.cosmeticsOwned[cosmeticId] or 0) < 1 then
			return
		end
		if table.find(data.cosmeticsEquipped, cosmeticId) then
			return
		end
		local slots = Stats.cosmeticSlots(Monetization.flags(player))
		if #data.cosmeticsEquipped >= slots then
			data.cosmeticsEquipped[1] = cosmeticId
		else
			table.insert(data.cosmeticsEquipped, cosmeticId)
		end
		Data.replicate(player)
	end)

	Remotes.UnequipCosmetic.OnServerEvent:Connect(function(player, cosmeticId)
		if typeof(cosmeticId) ~= "string" then
			return
		end
		local data = Data.get(player)
		if not data then
			return
		end
		local nextEq = {}
		for _, id in data.cosmeticsEquipped do
			if id ~= cosmeticId then
				table.insert(nextEq, id)
			end
		end
		data.cosmeticsEquipped = nextEq
		Data.replicate(player)
	end)
end

function RotationShop.reroll(player: Player)
	local data = Data.get(player)
	if not data then
		return false
	end
	data.rotationSalt = (data.rotationSalt or 0) + 17
	Data.replicate(player)
	return true
end

return RotationShop
