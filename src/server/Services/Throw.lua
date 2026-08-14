local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Numbers = Config.Numbers

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

local function seated(player: Player): boolean
	local char = player.Character
	local hum = char and char:FindFirstChildWhichIsA("Humanoid")
	return hum ~= nil and hum.Sit == true
end

local function pruneFlights()
	local kids = flights:GetChildren()
	while #kids > Numbers.MaxRenderedFlights do
		local oldest = kids[1]
		oldest:Destroy()
		table.remove(kids, 1)
	end
end

local function spawnFlight(player: Player, planeId: string, cosmetics, origin: CFrame, landing: Vector3, duration: number)
	pruneFlights()
	local model = PlaneFactory.create(planeId)
	PlaneFactory.applyCosmetics(model, cosmetics)
	model:SetAttribute("Owner", player.UserId)
	model.Parent = flights
	model:PivotTo(origin)

	local start = origin.Position
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
		task.wait(0.3)
		if model.Parent then
			model:Destroy()
		end
	end)
end

local function doOneThrow(player: Player, data, flags, origin: CFrame, index: number, total: number)
	local expected = Stats.distance(data, flags)
	local distance = expected * (0.92 + math.random() * 0.16)
	local first = data.totalThrows == 0
	data.totalThrows += 1

	local coins = Stats.coinsForDistance(data, flags, distance)
	if data.totalThrows <= Numbers.EarlyThrowBonusThrows then
		coins *= Numbers.EarlyThrowMultiplier
	end
	if first then
		coins = math.max(coins, Numbers.TutorialFirstThrowCoins)
	end
	coins = math.max(1, math.floor(coins + 0.5))

	local strGain = Stats.throwStrengthGain(data, flags)
	data.coins += coins
	data.stats.totalCoinsEarned += coins
	data.strength += strGain
	if distance > data.stats.bestDistance then
		data.stats.bestDistance = distance
	end

	if not data.tutorial.thrown then
		data.tutorial.thrown = true
		Remotes.Tutorial:FireClient(player, "upgrade")
	end

	local duration = math.clamp(distance / Numbers.FlightSpeed, 0.6, 6)
	local dir = World.throwDirection()
	local landing = origin.Position + dir * distance
	local planeId = Stats.equippedPlaneId(data)
	spawnFlight(player, planeId, data.cosmeticsEquipped, origin, landing, duration)

	Remotes.ThrowResult:FireClient(player, {
		distance = distance,
		coins = coins,
		strengthGain = strGain,
		origin = origin.Position,
		landing = landing,
		planeId = planeId,
		duration = duration,
		index = index,
		total = total,
	})
end

function Throw.perform(player: Player)
	local data = Data.get(player)
	if not data then
		return
	end
	if seated(player) then
		Economy.notify(player, "Stand up to throw. Benches are strength only.", "info")
		return
	end
	local origin = World.throwOriginFor(player)
	if not origin then
		Economy.notify(player, "Walk onto a THROW pad in the hallway.", "info")
		return
	end

	local flags = Monetization.flags(player)
	local now = os.clock()
	if lastThrow[player] and now - lastThrow[player] < Numbers.ThrowCooldown * 0.85 then
		return
	end
	lastThrow[player] = now

	local total = Stats.planesPerThrow(data, flags)
	for i = 1, total do
		if i > 1 then
			task.wait(Numbers.VolleyStagger)
		end
		doOneThrow(player, data, flags, origin, i, total)
	end
	Data.replicate(player)
end

function Throw.start()
	Remotes.Throw.OnServerEvent:Connect(function(player)
		Throw.perform(player)
	end)

	for _, pad in World.throwPads() do
		local prompt = pad:FindFirstChildWhichIsA("ProximityPrompt")
		if prompt then
			prompt.Triggered:Connect(function(player)
				Throw.perform(player)
			end)
		end
	end
end

return Throw
