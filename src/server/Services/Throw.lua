local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Numbers = Config.Numbers
local Upgrades = Config.Upgrades

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)
local Monetization = require(script.Parent.Monetization)
local Stats = require(script.Parent.Parent.Lib.Stats)
local World = require(script.Parent.Parent.World)
local PlaneFactory = require(ReplicatedStorage.Shared.PlaneFactory)

local lastThrow: { [Player]: number } = {}
local flights = Instance.new("Folder")
flights.Name = "Flights"
flights.Parent = workspace

local Throw = {}

local function rollDistance(data, flags): number
	local expected = Stats.distance(data, flags)
	local variance = Stats.variance(data)
	local t = math.random()
	return expected * ((1 - variance) + t * variance)
end

local function coinsFor(player, data, flags, distance: number, isFirst: boolean): number
	local cps = Stats.coinsPerStud(data, flags)
	local coins = distance * cps
	if data.totalThrows < Numbers.EarlyThrowBonusThrows then
		coins *= Numbers.EarlyThrowMultiplier
	end
	if isFirst then
		coins = math.max(coins, Numbers.TutorialFirstThrowCoins)
	end
	local combo = data.combo or 0
	coins *= 1 + math.min(combo, Numbers.ComboMax) * Numbers.ComboCoinBonus
	return math.max(1, math.floor(coins + 0.5))
end

local function spawnFlight(player: Player, planeId: string, origin: CFrame, landing: Vector3, duration: number, rainbow: boolean)
	local model = PlaneFactory.create(planeId)
	if rainbow then
		PlaneFactory.setRainbowTrail(model)
	end
	model:SetAttribute("Owner", player.UserId)
	model.Parent = flights
	model:PivotTo(origin)

	local start = origin.Position
	local dir = (landing - start)
	local look = CFrame.lookAt(start, start + dir)
	model:PivotTo(look)

	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < duration and model.Parent do
			local a = math.clamp((os.clock() - t0) / duration, 0, 1)
			local pos = start:Lerp(landing, a)
			local arc = math.sin(a * math.pi) * Numbers.ArcHeight
			pos += Vector3.new(0, arc, 0)
			local nextA = math.clamp(a + 0.02, 0, 1)
			local nextPos = start:Lerp(landing, nextA) + Vector3.new(0, math.sin(nextA * math.pi) * Numbers.ArcHeight, 0)
			model:PivotTo(CFrame.lookAt(pos, nextPos))
			task.wait()
		end
		task.wait(0.35)
		if model.Parent then
			model:Destroy()
		end
	end)

	return model
end

local function doOneThrow(player: Player, data, flags, index: number, total: number)
	local origin = World.throwOrigin()
	local direction = World.throwDirection()
	local distance = rollDistance(data, flags)
	local now = os.clock()
	if data.lastThrowAt > 0 and (now - data.lastThrowAt) <= Numbers.ComboWindow then
		data.combo = math.min(Numbers.ComboMax, (data.combo or 0) + 1)
	else
		data.combo = 1
	end
	data.lastThrowAt = now

	local first = data.totalThrows == 0
	data.totalThrows += 1
	local coins = coinsFor(player, data, flags, distance, first)
	data.coins += coins
	data.stats.totalCoinsEarned += coins
	if distance > data.stats.bestDistance then
		data.stats.bestDistance = distance
	end

	if not data.tutorial.thrown then
		data.tutorial.thrown = true
		Remotes.Tutorial:FireClient(player, "upgrade")
	elseif data.tutorial.upgraded and not data.tutorial.thrownAfter then
		data.tutorial.thrownAfter = true
		data.tutorial.complete = true
		Remotes.Tutorial:FireClient(player, "done")
	end

	local duration = math.clamp(distance / Numbers.FlightSpeed, 0.7, 3.2)
	local landing = origin.Position + direction * distance + Vector3.new(0, -8, 0)
	spawnFlight(player, data.equipped[1] or "FoldedNote", origin, landing, duration, flags.rainbowTrail)

	local result = {
		distance = distance,
		coins = coins,
		combo = data.combo,
		origin = origin.Position,
		landing = landing,
		planeId = data.equipped[1] or "FoldedNote",
		duration = duration,
		rainbow = flags.rainbowTrail,
		index = index,
		total = total,
	}
	Remotes.ThrowResult:FireClient(player, result)
	return result
end

function Throw.perform(player: Player, fromAuto: boolean?)
	local data = Data.get(player)
	if not data then
		return
	end
	local flags = Monetization.flags(player)
	if fromAuto then
		local auto = flags.autoThrow or (data.hangarUpgrades.AutoThrow or 0) >= 1
		if not auto then
			return
		end
	end

	local cooldown = Stats.throwCooldown(flags)
	local now = os.clock()
	if lastThrow[player] and now - lastThrow[player] < cooldown * 0.85 then
		return
	end
	lastThrow[player] = now

	local total = if flags.multiThrow then Numbers.MultiThrowCount else 1
	for i = 1, total do
		doOneThrow(player, data, flags, i, total)
	end
	Data.replicate(player)
end

function Throw.start()
	Remotes.Throw.OnServerEvent:Connect(function(player)
		Throw.perform(player, false)
	end)
end

return Throw
