local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Upgrades = Config.Upgrades
local Planes = Config.Planes
local Numbers = Config.Numbers

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)
local Monetization = require(script.Parent.Monetization)
local Stats = require(script.Parent.Parent.Lib.Stats)

local Hangar = {}

local function buy(player: Player, upgradeId: string, buyMax: boolean, category: string)
	local def = Upgrades.ById[upgradeId]
	if not def or def.category ~= category then
		return
	end
	local data = Data.get(player)
	if not data then
		return
	end
	local bag = if category == "hangar" then data.hangarUpgrades else data.upgrades
	local current = bag[upgradeId] or 0
	if current >= def.maxLevel then
		Economy.notify(player, "Already maxed!", "info")
		return
	end
	local bought, spent
	if buyMax then
		bought, spent = Upgrades.buyMax(def, current, data.coins)
	else
		local cost = Upgrades.cost(def, current)
		if data.coins < cost then
			bought, spent = 0, 0
		else
			bought, spent = 1, cost
		end
	end
	if bought <= 0 then
		Economy.notify(player, "Not enough coins.", "error")
		return
	end
	data.coins -= spent
	bag[upgradeId] = current + bought
	if category == "plane" and not data.tutorial.upgraded then
		data.tutorial.upgraded = true
		Remotes.Tutorial:FireClient(player, "throwAgain")
	end
	Data.replicate(player)
	Hangar.refreshDisplay(player)
	Economy.notify(player, def.name .. " +" .. bought, "success")
end

function Hangar.refreshDisplay(player: Player)
	local data = Data.get(player)
	if not data then
		return
	end
	Remotes.HangarDisplay:FireClient(player, data.equipped)
end

function Hangar.grantPlane(player: Player, planeId: string): (boolean, number)
	local data = Data.get(player)
	local def = Planes.get(planeId)
	if not data or not def then
		return false, 0
	end
	local owned = data.ownedPlanes[planeId] or 0
	if owned > 0 then
		local scrap = Config.Rarities.scrap(def.rarity)
		data.scrap += scrap
		data.ownedPlanes[planeId] = owned + 1
		return true, scrap
	end
	data.ownedPlanes[planeId] = 1
	return false, 0
end

function Hangar.start()
	Remotes.BuyUpgrade.OnServerEvent:Connect(function(player, upgradeId, buyMax)
		if typeof(upgradeId) ~= "string" then
			return
		end
		buy(player, upgradeId, buyMax == true, "plane")
	end)

	Remotes.BuyHangarUpgrade.OnServerEvent:Connect(function(player, upgradeId, buyMax)
		if typeof(upgradeId) ~= "string" then
			return
		end
		buy(player, upgradeId, buyMax == true, "hangar")
	end)

	Remotes.BuyAutoThrow.OnServerEvent:Connect(function(player)
		local data = Data.get(player)
		if not data then
			return
		end
		if (data.hangarUpgrades.AutoThrow or 0) >= 1 then
			Economy.notify(player, "Auto Throw already unlocked.", "info")
			return
		end
		if Monetization.flags(player).autoThrow then
			data.hangarUpgrades.AutoThrow = 1
			Data.replicate(player)
			return
		end
		if not Economy.spendCoins(player, Numbers.AutoThrowUpgradeCost) then
			Economy.notify(player, "Need " .. tostring(Numbers.AutoThrowUpgradeCost) .. " coins.", "error")
			return
		end
		data.hangarUpgrades.AutoThrow = 1
		Data.replicate(player)
		Economy.notify(player, "Auto Throw unlocked!", "success")
	end)

	Remotes.EquipPlane.OnServerEvent:Connect(function(player, planeId)
		if typeof(planeId) ~= "string" then
			return
		end
		local data = Data.get(player)
		if not data or (data.ownedPlanes[planeId] or 0) < 1 then
			return
		end
		for _, id in data.equipped do
			if id == planeId then
				return
			end
		end
		local slots = Stats.equipSlots(data, Monetization.flags(player))
		if #data.equipped >= slots then
			data.equipped[1] = planeId
		else
			table.insert(data.equipped, planeId)
		end
		Data.replicate(player)
		Hangar.refreshDisplay(player)
	end)

	Remotes.UnequipPlane.OnServerEvent:Connect(function(player, planeId)
		if typeof(planeId) ~= "string" then
			return
		end
		local data = Data.get(player)
		if not data then
			return
		end
		if #data.equipped <= 1 then
			Economy.notify(player, "Keep at least one plane equipped.", "error")
			return
		end
		local nextEquipped = {}
		for _, id in data.equipped do
			if id ~= planeId then
				table.insert(nextEquipped, id)
			end
		end
		if #nextEquipped == 0 then
			nextEquipped = { Planes.StarterId }
		end
		data.equipped = nextEquipped
		Data.replicate(player)
		Hangar.refreshDisplay(player)
	end)

	Data.ProfileLoaded:Connect(function(player)
		Hangar.refreshDisplay(player)
	end)
end

return Hangar
