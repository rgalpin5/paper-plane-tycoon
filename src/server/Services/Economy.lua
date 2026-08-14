local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Data = require(script.Parent.Data)

local Economy = {}

function Economy.addCoins(player: Player, amount: number, _source: string?)
	local data = Data.get(player)
	if not data or amount == 0 then
		return data and data.coins or 0
	end
	amount = math.floor(amount + 0.5)
	data.coins = math.max(0, data.coins + amount)
	if amount > 0 then
		data.stats.totalCoinsEarned += amount
	end
	Data.replicate(player)
	return data.coins
end

function Economy.spendCoins(player: Player, amount: number): boolean
	local data = Data.get(player)
	if not data then
		return false
	end
	amount = math.floor(amount + 0.5)
	if data.coins < amount then
		return false
	end
	data.coins -= amount
	Data.replicate(player)
	return true
end

function Economy.addScrap(player: Player, amount: number)
	local data = Data.get(player)
	if not data then
		return 0
	end
	data.scrap = math.max(0, data.scrap + math.floor(amount + 0.5))
	Data.replicate(player)
	return data.scrap
end

function Economy.spendScrap(player: Player, amount: number): boolean
	local data = Data.get(player)
	if not data or data.scrap < amount then
		return false
	end
	data.scrap -= amount
	Data.replicate(player)
	return true
end

function Economy.addKeys(player: Player, crateId: string, amount: number)
	local data = Data.get(player)
	if not data then
		return
	end
	data.crateKeys[crateId] = (data.crateKeys[crateId] or 0) + amount
	Data.replicate(player)
end

function Economy.notify(player: Player, message: string, kind: string?)
	Remotes.Notify:FireClient(player, message, kind or "info")
end

function Economy.start() end

return Economy
