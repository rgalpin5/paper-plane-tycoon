local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Numbers = Config.Numbers

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)
local Monetization = require(script.Parent.Monetization)
local Crate = require(script.Parent.Crate)

local Daily = {}

local function utcDay(): number
	return math.floor(os.time() / 86400)
end

function Daily.preview(player: Player)
	local data = Data.get(player)
	if not data then
		return nil
	end
	local today = utcDay()
	local claimed = data.lastDailyClaimDay == today
	local nextStreak = data.streak
	if not claimed then
		if data.lastDailyClaimDay == today - 1 then
			nextStreak = math.min(7, data.streak + 1)
			if data.streak == 0 then
				nextStreak = 1
			end
		elseif data.lastDailyClaimDay == 0 then
			nextStreak = 1
		else
			nextStreak = 1
		end
	end
	local dayIndex = math.clamp(if claimed then data.streak else nextStreak, 1, 7)
	local coins = Numbers.DailyRewards[dayIndex] or 500
	if Monetization.flags(player).vip then
		coins = math.floor(coins * 1.25)
	end
	return {
		streak = data.streak,
		claimed = claimed,
		dayIndex = dayIndex,
		coins = coins,
		crateOnSeven = dayIndex == 7,
		shields = data.streakShields,
		rewards = Numbers.DailyRewards,
	}
end

function Daily.start()
	Remotes.ClaimDaily.OnServerEvent:Connect(function(player)
		local data = Data.get(player)
		if not data then
			return
		end
		local today = utcDay()
		if data.lastDailyClaimDay == today then
			Economy.notify(player, "Already claimed today.", "info")
			return
		end

		local missed = data.lastDailyClaimDay ~= 0 and data.lastDailyClaimDay < today - 1
		if missed then
			if data.streakShields > 0 then
				data.streakShields -= 1
				data.streak = math.max(1, data.streak)
			else
				data.streak = 0
			end
		end

		if data.lastDailyClaimDay == today - 1 or data.streak == 0 then
			data.streak = math.min(7, data.streak + 1)
		else
			data.streak = 1
		end

		data.lastDailyClaimDay = today
		local coins = Numbers.DailyRewards[data.streak] or 500
		if Monetization.flags(player).vip then
			coins = math.floor(coins * 1.25)
		end
		data.coins += coins
		data.stats.totalCoinsEarned += coins

		local boostMin = Numbers.DailyBoostMinutes[data.streak] or 0
		if boostMin > 0 then
			local now = os.time()
			data.boosts.doubleCoinsUntil = math.max(data.boosts.doubleCoinsUntil, now) + boostMin * 60
		end

		local gaveCrate = false
		if data.streak == 7 then
			Crate.open(player, "Paper", { free = true })
			gaveCrate = true
			data.streak = 0
		end

		Remotes.DailyClaimed:FireClient(player, {
			streak = data.streak,
			coins = coins,
			crate = gaveCrate,
			boostMinutes = boostMin,
		})
		Data.replicate(player)
		Economy.notify(player, "Daily +" .. tostring(coins) .. " coins", "success")
	end)

	Data.ProfileLoaded:Connect(function(player)
		task.delay(1.2, function()
			if player.Parent then
				Remotes.DailyClaimed:FireClient(player, { prompt = true, preview = Daily.preview(player) })
			end
		end)
	end)
end

return Daily
