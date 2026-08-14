local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Planes = Config.Planes
local Numbers = Config.Numbers

local TEMPLATE = {
	coins = 0,
	scrap = 0,
	strength = Numbers.StarterStrength,
	planeLevel = 0,
	playerUpgrades = {
		StrengthGain = 0,
		MultiPlane = 0,
		Luck = 0,
	},
	hangarUpgrades = {
		Storage = 0,
		OfflineIncome = 0,
	},
	ownedPlanes = {
		FoldedNote = 1,
	},
	equipped = { Planes.StarterId },
	cosmeticsOwned = {},
	cosmeticsEquipped = {},
	rotationPurchases = {},
	rotationSalt = 0,
	streak = 0,
	lastDailyClaimDay = 0,
	rebirths = 0,
	pity = {
		legendary = 0,
		mythic = 0,
	},
	processedPurchases = {},
	purchaseOrder = {},
	lastLogout = 0,
	tutorial = {
		hangar = false,
		thrown = false,
		upgraded = false,
		benched = false,
		complete = false,
	},
	boosts = {
		doubleCoinsUntil = 0,
	},
	streakShields = 0,
	codesRedeemed = {},
	totalThrows = 0,
	stats = {
		totalCoinsEarned = 0,
		bestDistance = 0,
		cratesOpened = 0,
	},
}

local STORE_NAME = "PaperPlaneTycoon_v2"
local playerStore = ProfileStore.New(STORE_NAME, TEMPLATE)

local profiles: { [Player]: any } = {}
local policyRestricted: { [Player]: boolean } = {}

local Data = {
	ProfileLoaded = Signal.new(),
	Changed = Signal.new(),
	TEMPLATE = TEMPLATE,
}

local Stats
local Monetization

local function snapshotOf(player: Player)
	Stats = Stats or require(script.Parent.Parent.Lib.Stats)
	Monetization = Monetization or require(script.Parent.Monetization)
	local profile = profiles[player]
	if not profile then
		return nil
	end
	local data = profile.Data
	local f = Monetization.flags(player)
	local now = os.time()
	return {
		data = data,
		computed = {
			coinMultiplier = Stats.coinMultiplier(data, f),
			luckMultiplier = Stats.luckMultiplier(data, f),
			throwCooldown = Numbers.ThrowCooldown,
			skipAnim = f.skipAnim,
			extraCosmeticSlots = f.extraCosmeticSlots,
			doubleCoins = f.doubleCoins,
			doubleLuck = f.doubleLuck,
			extraPlane = f.extraPlane,
			offlinePlus = f.offlinePlus,
			storagePlus = f.storagePlus,
			cosmeticSlots = Stats.cosmeticSlots(f),
			offlineHours = Stats.offlineHours(data, f),
			idlePerMinute = Stats.idlePerMinute(data, f),
			restrictedPaidRandom = policyRestricted[player] == true,
			vip = f.vip,
			planesPerThrow = Stats.planesPerThrow(data, f),
			storage = Stats.storage(data, f),
			stands = Stats.stands(data, f),
			planeMultiplier = Stats.planeMultiplier(data),
			rebirthCoinMult = Stats.rebirthCoinMult(data),
			rebirthStrengthMult = Stats.rebirthStrengthMult(data),
			strengthGainMult = Stats.strengthGainMult(data, f),
			cosmeticCoinMult = Stats.cosmeticMult(data, "coins"),
			cosmeticStrengthMult = Stats.cosmeticMult(data, "strength"),
			distancePreview = Stats.distance(data, f),
			coinsPreview = Stats.coinsForDistance(data, f, Stats.distance(data, f)),
			boostRemaining = math.max(0, data.boosts.doubleCoinsUntil - now),
		},
	}
end

function Data.getProfile(player: Player)
	return profiles[player]
end

function Data.get(player: Player)
	local profile = profiles[player]
	return if profile then profile.Data else nil
end

function Data.isLoaded(player: Player): boolean
	return profiles[player] ~= nil
end

function Data.waitFor(player: Player, timeout: number?): any
	local t0 = os.clock()
	local limit = timeout or 15
	while player.Parent == Players and os.clock() - t0 < limit do
		if profiles[player] then
			return profiles[player].Data
		end
		task.wait()
	end
	return Data.get(player)
end

function Data.setPolicyRestricted(player: Player, restricted: boolean)
	policyRestricted[player] = restricted
end

function Data.isPolicyRestricted(player: Player): boolean
	return policyRestricted[player] == true
end

function Data.snapshot(player: Player)
	return snapshotOf(player)
end

function Data.replicate(player: Player)
	if not profiles[player] then
		return
	end
	local snap = snapshotOf(player)
	if snap then
		Remotes.ProfileUpdated:FireClient(player, snap)
		Data.Changed:Fire(player, snap)
	end
end

function Data.markPurchase(player: Player, purchaseId: string): boolean
	local data = Data.get(player)
	if not data then
		return false
	end
	if data.processedPurchases[purchaseId] then
		return false
	end
	data.processedPurchases[purchaseId] = true
	table.insert(data.purchaseOrder, purchaseId)
	while #data.purchaseOrder > 250 do
		local old = table.remove(data.purchaseOrder, 1)
		if old then
			data.processedPurchases[old] = nil
		end
	end
	return true
end

function Data.wasPurchased(player: Player, purchaseId: string): boolean
	local data = Data.get(player)
	return data ~= nil and data.processedPurchases[purchaseId] == true
end

local function playerAdded(player: Player)
	local profile = playerStore:StartSessionAsync(tostring(player.UserId), {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile == nil then
		profile = playerStore.Mock:StartSessionAsync(tostring(player.UserId), {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})
	end

	if profile == nil then
		player:Kick("Could not load data. Please rejoin.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		if player.Parent == Players then
			player:Kick("Profile session ended — please rejoin.")
		end
	end)

	if player.Parent ~= Players then
		profile:EndSession()
		return
	end

	if profile.Data.ownedPlanes[Planes.StarterId] == nil then
		profile.Data.ownedPlanes[Planes.StarterId] = 1
	end
	if #profile.Data.equipped == 0 then
		profile.Data.equipped = { Planes.StarterId }
	end
		if profile.Data.strength == nil or profile.Data.strength < 1 then
			profile.Data.strength = Numbers.StarterStrength
		end
		if profile.Data.tutorial.hangar == nil then
			profile.Data.tutorial.hangar = false
		end
		if profile.Data.rotationPurchases == nil then
			profile.Data.rotationPurchases = {}
		end

	profiles[player] = profile
	task.defer(function()
		if player.Parent == Players and profiles[player] then
			Data.ProfileLoaded:Fire(player, profile.Data)
			Data.replicate(player)
		end
	end)
end

local function playerRemoving(player: Player)
	local profile = profiles[player]
	if profile then
		profile.Data.lastLogout = os.time()
		profile:EndSession()
	end
	profiles[player] = nil
	policyRestricted[player] = nil
end

function Data.start()
	if RunService:IsStudio() then
		if ProfileStore.DataStoreState ~= "Access" then
			playerStore = playerStore.Mock
			print("[Paper Plane Tycoon] Using ProfileStore.Mock (enable Studio API access to persist).")
		end
	end

	Remotes.GetSnapshot.OnServerInvoke = function(player)
		Data.waitFor(player, 10)
		return snapshotOf(player)
	end

	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(playerAdded, player)
	end
end

function Data.saveNow(player: Player)
	local profile = profiles[player]
	if profile and profile.Save then
		profile:Save()
	end
end

return Data
