local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Products = Config.Products

local Data = require(script.Parent.Data)
local Economy = require(script.Parent.Economy)

local cache: { [Player]: any } = {}
local Monetization = {}

local function emptyFlags()
	return {
		skipAnim = false,
		extraCosmeticSlots = false,
		doubleCoins = false,
		doubleLuck = false,
		extraPlane = false,
		offlinePlus = false,
		storagePlus = false,
		vip = false,
		BenchBronze = false,
		BenchSilver = false,
		BenchGold = false,
		BenchDiamond = false,
	}
end

function Monetization.flags(player: Player)
	return cache[player] or emptyFlags()
end

function Monetization.ownsKey(player: Player, key: string): boolean
	local flags = Monetization.flags(player)
	return flags[key] == true
end

local function setFlag(flags, defKey: string)
	if defKey == "SkipCrateAnim" then
		flags.skipAnim = true
	elseif defKey == "ExtraCosmeticSlots" then
		flags.extraCosmeticSlots = true
	elseif defKey == "DoubleCoins" then
		flags.doubleCoins = true
	elseif defKey == "DoubleLuck" then
		flags.doubleLuck = true
	elseif defKey == "ExtraPlaneThrow" then
		flags.extraPlane = true
	elseif defKey == "OfflinePlus" then
		flags.offlinePlus = true
	elseif defKey == "HangarStoragePlus" then
		flags.storagePlus = true
	elseif defKey == "VIP" then
		flags.vip = true
	elseif defKey == "BenchBronze" or defKey == "BenchSilver" or defKey == "BenchGold" or defKey == "BenchDiamond" then
		flags[defKey] = true
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
	Monetization.applyVipTag(player, flags.vip)
	return flags
end

function Monetization.applyVipTag(player: Player, isVip: boolean)
	pcall(function()
		player:SetAttribute("VIP", isVip)
	end)
end

local Crate
local RotationShop

local function grantProduct(player: Player, key: string): boolean
	local data = Data.get(player)
	if not data then
		return false
	end
	if key == "CoinPackS" or key == "CoinPackM" or key == "CoinPackL" or key == "CoinPackXL" then
		Economy.addCoins(player, Products.CoinPackAmounts[key] or 0, "product")
		return true
	elseif Products.CrateProductToId[key] then
		Crate = Crate or require(script.Parent.Crate)
		Crate.open(player, Products.CrateProductToId[key], { paidRobux = true, free = true })
		return true
	elseif key == "ShopReroll" then
		RotationShop = RotationShop or require(script.Parent.RotationShop)
		return RotationShop.reroll(player)
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
	if profile == nil then
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

	if def.kind == "crate" and Data.isPolicyRestricted(player) then
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
