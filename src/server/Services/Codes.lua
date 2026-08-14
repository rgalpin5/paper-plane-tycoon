local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Codes = Config.Codes

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)

local CodeService = {}

function CodeService.start()
	Remotes.RedeemCode.OnServerEvent:Connect(function(player, raw)
		if typeof(raw) ~= "string" then
			return
		end
		local code = string.upper((string.gsub(raw, "%s+", "")))
		local reward = Codes[code]
		if not reward then
			Economy.notify(player, "Unknown code.", "error")
			return
		end
		local data = Data.get(player)
		if not data then
			return
		end
		if data.codesRedeemed[code] then
			Economy.notify(player, "Code already redeemed.", "info")
			return
		end
		data.codesRedeemed[code] = true
		if reward.coins then
			data.coins += reward.coins
			data.stats.totalCoinsEarned += reward.coins
		end
		if reward.scrap then
			data.scrap += reward.scrap
		end
		if reward.crateKeys then
			for crateId, amount in reward.crateKeys do
				data.crateKeys[crateId] = (data.crateKeys[crateId] or 0) + amount
			end
		end
		if reward.boostMinutes then
			local now = os.time()
			data.boosts.doubleCoinsUntil = math.max(data.boosts.doubleCoinsUntil, now) + reward.boostMinutes * 60
		end
		Data.replicate(player)
		Economy.notify(player, "Code redeemed: " .. code, "success")
	end)
end

return CodeService
