local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Data = require(script.Parent.Data)
local Monetization = require(script.Parent.Monetization)
local Stats = require(script.Parent.Parent.Lib.Stats)
local Throw = require(script.Parent.Throw)

local Idle = {}
local autoAccum: { [Player]: number } = {}

local function grantOffline(player: Player, data)
	if data.lastLogout <= 0 then
		return
	end
	local elapsed = os.time() - data.lastLogout
	if elapsed < 30 then
		return
	end
	local flags = Monetization.flags(player)
	local capHours = Stats.offlineHours(data, flags)
	local minutes = math.min(elapsed, capHours * 3600) / 60
	local rate = Stats.idlePerMinute(data, flags)
	local amount = math.floor(rate * minutes)
	if amount <= 0 then
		return
	end
	data.coins += amount
	data.stats.totalCoinsEarned += amount
	Remotes.OfflineEarnings:FireClient(player, {
		coins = amount,
		minutes = minutes,
		capHours = capHours,
		rate = rate,
	})
	Data.replicate(player)
end

function Idle.start()
	Data.ProfileLoaded:Connect(function(player, data)
		task.defer(function()
			grantOffline(player, data)
		end)
	end)

	task.spawn(function()
		while true do
			local dt = task.wait(0.25)
			for _, player in Players:GetPlayers() do
				local data = Data.get(player)
				if data then
					local flags = Monetization.flags(player)
					local auto = flags.autoThrow or (data.hangarUpgrades.AutoThrow or 0) >= 1
					if auto then
						autoAccum[player] = (autoAccum[player] or 0) + dt
						local interval = Stats.autoInterval(flags)
						if autoAccum[player] >= interval then
							autoAccum[player] = 0
							Throw.perform(player, true)
						end
					end
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		autoAccum[player] = nil
	end)
end

return Idle
