local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Promise = require(ReplicatedStorage.Packages.Promise)

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Products = Config.Products
local Numbers = Config.Numbers
local Planes = Config.Planes

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)

local cache: { [Player]: { [string]: boolean } } = {}
local Monetization = {}

local function emptyFlags()
	return {
		autoThrow = false,
		skipAnim = false,
		magnet = false,
		rainbowTrail = false,
		doubleCoins = false,
		doubleLuck = false,
		fastThrow = false,
		extraSlot = false,
		doubleDaily = false,
		tripleCoins = false,
		superLuck = false,
		offlinePlus = false,
		multiThrow = false,
		vip = false,
		doubleRebirth = false,
		mythicStarter = false,
		megaCapacity = false,
		bundle = false,
	}
end

function Monetization.owns(player: Player, key: string): boolean
	local flags = cache[player]
	if not flags then
		return false
	end
	if key == "VIP" then
		return flags.vip == true
	end
	if key == "AutoThrow" then
		return flags.autoThrow == true
	end
	if key == "DoubleCoins" then
		return flags.doubleCoins == true
	end
	return flags[key:sub(1, 1):lower() .. key:sub(2)] == true or flags[key] == true
end

function Monetization.flags(player: Player)
	return cache[player] or emptyFlags()
end

local function setFlag(flags, defKey: string)
	if defKey == "AutoThrow" then
		flags.autoThrow = true
	elseif defKey == "SkipCrateAnim" then
		flags.skipAnim = true
	elseif defKey == "MagnetCoins" then
		flags.magnet = true
	elseif defKey == "RainbowTrail" then
		flags.rainbowTrail = true
	elseif defKey == "DoubleCoins" then
		flags.doubleCoins = true
	elseif defKey == "DoubleLuck" then
		flags.doubleLuck = true
	elseif defKey == "FastThrow" then
		flags.fastThrow = true
	elseif defKey == "ExtraEquipSlot" then
		flags.extraSlot = true
	elseif defKey == "DoubleDaily" then
		flags.doubleDaily = true
	elseif defKey == "TripleCoins" then
		flags.tripleCoins = true
	elseif defKey == "SuperLuck" then
		flags.superLuck = true
	elseif defKey == "OfflinePlus" then
		flags.offlinePlus = true
	elseif defKey == "MultiThrow" then
		flags.multiThrow = true
	elseif defKey == "VIP" then
		flags.vip = true
	elseif defKey == "DoubleRebirth" then
		flags.doubleRebirth = true
	elseif defKey == "MythicStarter" then
		flags.mythicStarter = true
	elseif defKey == "HangarMegaCapacity" then
		flags.megaCapacity = true
	elseif defKey == "BundleVIP" then
		flags.bundle = true
		flags.vip = true
		flags.doubleCoins = true
		flags.autoThrow = true
	end
end

function Monetization.refresh(player: Player)
	local flags = emptyFlags()
	for _, def in Products.Gamepasses do
		if def.id ~= 0 then
			local ok, owned = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, def.id)
			end)
			if ok and owned then
				setFlag(flags, def.key)
			end
		end
	end
	cache[player] = flags

	if flags.mythicStarter then
		local data = Data.get(player)
		if data and (data.ownedPlanes[Planes.MythicStarterId] or 0) < 1 then
			data.ownedPlanes[Planes.MythicStarterId] = 1
		end
	end

	Monetization.applyVipTag(player, flags.vip)
	return flags
end

function Monetization.applyVipTag(player: Player, isVip: boolean)
	pcall(function()
		local container = TextChatService:FindFirstChild("TextChannels")
		-- Tags are applied via TextChatService.OnIncomingMessage on the client.
		player:SetAttribute("VIP", isVip)
	end)
end

local function grantProduct(player: Player, key: string): boolean
	local data = Data.get(player)
	if not data then
		return false
	end
	if key == "CoinPackS" or key == "CoinPackM" or key == "CoinPackL" or key == "CoinPackXL" then
		Economy.addCoins(player, Products.CoinPackAmounts[key] or 0, "product")
		return true
	elseif key == "CrateKeys1" then
		Economy.addKeys(player, "Paper", 1)
		return true
	elseif key == "CrateKeys3" then
		Economy.addKeys(player, "Hangar", 3)
		return true
	elseif key == "CrateKeys10" then
		Economy.addKeys(player, "Golden", 10)
		return true
	elseif key == "Boost30" then
		local now = os.time()
		data.boosts.doubleCoinsUntil = math.max(data.boosts.doubleCoinsUntil, now) + Numbers.BoostDuration
		Data.replicate(player)
		Remotes.BoostUpdated:FireClient(player, data.boosts.doubleCoinsUntil)
		return true
	elseif key == "StreakShield" then
		data.streakShields += 1
		Data.replicate(player)
		return true
	elseif key == "LuckyRoll" then
		data.luckyRolls += 1
		Data.replicate(player)
		return true
	end
	return false
end

local function processReceipt(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if player == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local t0 = os.clock()
	while Data.get(player) == nil and player.Parent == Players and os.clock() - t0 < 20 do
		task.wait()
	end

	local profile = Data.getProfile(player)
	if profile == nil or (profile.IsActive and profile:IsActive() == false) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local purchaseId = tostring(info.PurchaseId)
	if Data.wasPurchased(player, purchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local def = Products.ProductById[info.ProductId]
	if def == nil then
		warn("[Monetization] Unknown product id", info.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if not Data.markPurchase(player, purchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local ok, granted = pcall(grantProduct, player, def.key)
	if not ok or granted ~= true then
		warn("[Monetization] Grant failed", def.key, granted)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	Data.saveNow(player)
	Economy.notify(player, "Purchased " .. def.name .. "!", "success")
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function loadPolicy(player: Player)
	Promise.try(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(player)
	end)
		:andThen(function(info)
			local restricted = typeof(info) == "table" and info.ArePaidRandomItemsRestricted == true
			Data.setPolicyRestricted(player, restricted)
			Data.replicate(player)
		end)
		:catch(function()
			Data.setPolicyRestricted(player, false)
		end)
end

function Monetization.start()
	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		if purchased then
			Monetization.refresh(player)
			Data.replicate(player)
			local def = Products.GamepassById[passId]
			Economy.notify(player, "Unlocked " .. ((def and def.name) or "game pass") .. "!", "success")
		end
	end)

	Remotes.GetPolicy.OnServerInvoke = function(player)
		return {
			restrictedPaidRandom = Data.isPolicyRestricted(player),
		}
	end

	Data.ProfileLoaded:Connect(function(player)
		Monetization.refresh(player)
		task.spawn(loadPolicy, player)
		Data.replicate(player)
	end)

	for _, player in Players:GetPlayers() do
		if Data.isLoaded(player) then
			Monetization.refresh(player)
			task.spawn(loadPolicy, player)
		end
	end
end

return Monetization
