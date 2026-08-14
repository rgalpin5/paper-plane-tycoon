local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Products = Config.Products

local State = require(script.Parent.Parent.State)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)
local Toast = require(script.Parent.Toast)

local ShopUI = {}

local function promptPass(id: number)
	if id == 0 then
		Toast.show("Paste the Creator Hub ID into Products.lua", "error")
		return
	end
	MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, id)
end

local function promptProduct(id: number)
	if id == 0 then
		Toast.show("Paste the Creator Hub ID into Products.lua", "error")
		return
	end
	MarketplaceService:PromptProductPurchase(Players.LocalPlayer, id)
end

function ShopUI.mount(gui: ScreenGui)
	local page = Util.panel({
		parent = gui,
		size = UDim2.new(0.94, 0, 0.78, 0),
		pos = UDim2.new(0.5, 0, 0.47, 0),
		anchor = Vector2.new(0.5, 0.5),
		z = 20,
	})
	Util.label({
		parent = page,
		text = "SHOP",
		size = UDim2.new(1, -20, 0, 34),
		pos = UDim2.fromOffset(12, 8),
		font = Theme.Fonts.Title,
	})
	local close = Util.button({
		parent = page,
		text = "X",
		size = UDim2.fromOffset(40, 40),
		pos = UDim2.new(1, -12, 0, 8),
		anchor = Vector2.new(1, 0),
		bg = Theme.Danger,
		radius = 10,
	})
	close.MouseButton1Click:Connect(HUD.close)

	local scroll = Util.scroll(page, UDim2.new(1, -16, 1, -110))
	scroll.Position = UDim2.fromOffset(8, 46)
	Util.list(scroll, 6)

	local codeBox = Instance.new("TextBox")
	codeBox.Size = UDim2.new(0.62, 0, 0, 40)
	codeBox.Position = UDim2.new(0, 12, 1, -14)
	codeBox.AnchorPoint = Vector2.new(0, 1)
	codeBox.PlaceholderText = "Promo code"
	codeBox.Text = ""
	codeBox.Font = Theme.Fonts.Body
	codeBox.TextSize = 18
	codeBox.TextColor3 = Theme.Paper
	codeBox.BackgroundColor3 = Theme.Panel2
	codeBox.Parent = page
	Util.corner(codeBox, 10)
	local redeem = Util.button({
		parent = page,
		text = "REDEEM",
		size = UDim2.new(0.3, 0, 0, 40),
		pos = UDim2.new(1, -12, 1, -14),
		anchor = Vector2.new(1, 1),
		bg = Theme.Sky,
	})
	redeem.MouseButton1Click:Connect(function()
		Remotes.RedeemCode:FireServer(codeBox.Text)
		codeBox.Text = ""
	end)

	local function owned(key: string): boolean
		local c = State.computed()
		if not c then
			return false
		end
		if key == "AutoThrow" then
			return c.autoThrow
		end
		if key == "SkipCrateAnim" then
			return c.skipAnim
		end
		if key == "MagnetCoins" then
			return c.magnet
		end
		if key == "RainbowTrail" then
			return c.rainbowTrail
		end
		if key == "FastThrow" then
			return c.throwCooldown < 0.8
		end
		if key == "VIP" or key == "BundleVIP" then
			return c.vip
		end
		if key == "MultiThrow" then
			return c.multiThrow
		end
		if key == "OfflinePlus" then
			return c.offlineHours >= 7
		end
		if key == "HangarMegaCapacity" then
			return c.capacity >= 50
		end
		if key == "TripleCoins" then
			return c.coinMultiplier >= 3
		end
		if key == "DoubleCoins" then
			return c.coinMultiplier >= 2
		end
		if key == "SuperLuck" then
			return c.luckMultiplier >= 4
		end
		if key == "DoubleLuck" then
			return c.luckMultiplier >= 2
		end
		return false
	end

	local function rebuild()
		Util.clear(scroll)
		Util.label({
			parent = scroll,
			text = "GAME PASSES  (one-time)",
			size = UDim2.new(1, 0, 0, 24),
			font = Theme.Fonts.Title,
			auto = Enum.AutomaticSize.Y,
			textSize = 18,
		})
		for _, def in Products.Gamepasses do
			local has = owned(def.key)
			local frame = Util.panel({
				parent = scroll,
				size = UDim2.new(1, -8, 0, 70),
				bg = if has then Color3.fromRGB(40, 55, 48) else Theme.Panel2,
			})
			Util.label({
				parent = frame,
				text = def.name .. "  ~R$" .. tostring(def.priceHint),
				size = UDim2.new(0.62, 0, 0, 28),
				pos = UDim2.fromOffset(10, 4),
				font = Theme.Fonts.Title,
			})
			Util.label({
				parent = frame,
				text = def.blurb,
				size = UDim2.new(0.62, 0, 0, 30),
				pos = UDim2.fromOffset(10, 34),
				color = Theme.Muted,
			})
			local b = Util.button({
				parent = frame,
				text = if has then "OWNED" else "BUY",
				size = UDim2.fromOffset(78, 36),
				pos = UDim2.new(1, -16, 0.5, 0),
				anchor = Vector2.new(1, 0.5),
				bg = if has then Theme.Muted else Theme.Green,
			})
			if not has then
				b.MouseButton1Click:Connect(function()
					promptPass(def.id)
				end)
			end
		end

		Util.label({
			parent = scroll,
			text = "COIN PACKS & KEYS  (repeatable)",
			size = UDim2.new(1, 0, 0, 24),
			font = Theme.Fonts.Title,
			auto = Enum.AutomaticSize.Y,
			textSize = 18,
		})
		for _, def in Products.DevProducts do
			local extra = ""
			if Products.CoinPackAmounts[def.key] then
				extra = "  +" .. Format.abbrev(Products.CoinPackAmounts[def.key])
			end
			local frame = Util.panel({ parent = scroll, size = UDim2.new(1, -8, 0, 70), bg = Theme.Panel2 })
			Util.label({
				parent = frame,
				text = def.name .. extra,
				size = UDim2.new(0.62, 0, 0, 28),
				pos = UDim2.fromOffset(10, 4),
				font = Theme.Fonts.Title,
			})
			Util.label({
				parent = frame,
				text = def.blurb,
				size = UDim2.new(0.62, 0, 0, 30),
				pos = UDim2.fromOffset(10, 34),
				color = Theme.Muted,
			})
			local b = Util.button({
				parent = frame,
				text = "R$" .. tostring(def.priceHint),
				size = UDim2.fromOffset(78, 36),
				pos = UDim2.new(1, -16, 0.5, 0),
				anchor = Vector2.new(1, 0.5),
				bg = Theme.Gold,
			})
			b.MouseButton1Click:Connect(function()
				promptProduct(def.id)
			end)
		end
	end

	page:GetPropertyChangedSignal("Visible"):Connect(function()
		if page.Visible then
			rebuild()
		end
	end)
	State.Changed:Connect(function()
		if page.Visible then
			rebuild()
		end
	end)

	HUD.register("Shop", page)
end

return ShopUI
