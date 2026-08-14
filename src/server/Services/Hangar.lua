local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Upgrades = Config.Upgrades
local Planes = Config.Planes

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)
local Monetization = require(script.Parent.Monetization)
local Stats = require(script.Parent.Parent.Lib.Stats)

local Hangar = {}

local function bagFor(data, category: string)
	if category == "hangar" then
		return data.hangarUpgrades
	end
	if category == "player" then
		return data.playerUpgrades
	end
	return nil
end

local function buy(player: Player, upgradeId: string, buyMax: boolean, category: string)
	local def = Upgrades.ById[upgradeId]
	if not def or def.category ~= category then
		return
	end
	local data = Data.get(player)
	if not data then
		return
	end

	local current
	if category == "plane" then
		current = data.planeLevel or 0
	else
		local bag = bagFor(data, category)
		current = bag[upgradeId] or 0
	end
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
	if category == "plane" then
		data.planeLevel = current + bought
	else
		local bag = bagFor(data, category)
		bag[upgradeId] = current + bought
	end
	if not data.tutorial.upgraded then
		data.tutorial.upgraded = true
		Remotes.Tutorial:FireClient(player, "throwAgain")
	end
	Data.replicate(player)
	Economy.notify(player, def.name .. " +" .. bought, "success")
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

	Remotes.BuyPlayerUpgrade.OnServerEvent:Connect(function(player, upgradeId, buyMax)
		if typeof(upgradeId) ~= "string" then
			return
		end
		buy(player, upgradeId, buyMax == true, "player")
	end)

	Remotes.EquipPlane.OnServerEvent:Connect(function(player, planeId)
		if typeof(planeId) ~= "string" then
			return
		end
		local data = Data.get(player)
		if not data or (data.ownedPlanes[planeId] or 0) < 1 then
			return
		end
		data.equipped = { planeId }
		Data.replicate(player)
	end)

	Remotes.UnequipPlane.OnServerEvent:Connect(function(player, planeId)
		if typeof(planeId) ~= "string" then
			return
		end
		local data = Data.get(player)
		if not data then
			return
		end
		if Stats.equippedPlaneId(data) == planeId then
			Economy.notify(player, "Keep one plane equipped.", "error")
			return
		end
	end)

	Data.ProfileLoaded:Connect(function() end)
end

return Hangar
