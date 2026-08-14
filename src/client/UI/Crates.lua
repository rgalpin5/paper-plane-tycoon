local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Crates = Config.Crates
local Products = Config.Products
local Rarities = Config.Rarities

local State = require(script.Parent.Parent.State)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)
local Toast = require(script.Parent.Toast)

local CratesUI = {}

local function promptProduct(id: number)
	if id == 0 then
		Toast.show("Paste the Creator Hub ID into Products.lua", "error")
		return
	end
	MarketplaceService:PromptProductPurchase(Players.LocalPlayer, id)
end

function CratesUI.mount(gui: ScreenGui)
	local page = Util.panel({
		parent = gui,
		size = UDim2.new(0.94, 0, 0.78, 0),
		pos = UDim2.new(0.5, 0, 0.47, 0),
		anchor = Vector2.new(0.5, 0.5),
		z = 20,
	})
	Util.label({
		parent = page,
		text = "CRATES",
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

	local scroll = Util.scroll(page, UDim2.new(1, -16, 1, -54))
	scroll.Position = UDim2.fromOffset(8, 46)
	Util.list(scroll, 8)

	local details: Frame? = nil

	local function showDetails(crateId: string)
		if details then
			details:Destroy()
		end
		local odds = Remotes.GetCrateOdds:InvokeServer(crateId)
		if not odds then
			return
		end
		details = Util.panel({
			parent = page,
			size = UDim2.new(0.96, 0, 0.86, 0),
			pos = UDim2.new(0.5, 0, 0.52, 0),
			anchor = Vector2.new(0.5, 0.5),
			bg = Color3.fromRGB(20, 22, 30),
			z = 25,
		})
		Util.label({
			parent = details,
			text = odds.name .. "  Details",
			size = UDim2.new(1, -20, 0, 32),
			pos = UDim2.fromOffset(10, 8),
			font = Theme.Fonts.Title,
		})
		local back = Util.button({
			parent = details,
			text = "Close",
			size = UDim2.fromOffset(80, 32),
			pos = UDim2.new(1, -12, 0, 8),
			anchor = Vector2.new(1, 0),
			bg = Theme.Muted,
		})
		back.MouseButton1Click:Connect(function()
			if details then
				details:Destroy()
				details = nil
			end
		end)
		local body = Util.scroll(details, UDim2.new(1, -16, 1, -88))
		body.Position = UDim2.fromOffset(8, 48)
		Util.list(body, 4)

		Util.label({
			parent = body,
			text = string.format(
				"Luck ×%.0f  •  Legendary pity %d/%d  •  Mythic pity %d/%d",
				odds.luck,
				odds.pity.legendary,
				odds.pityLegendary,
				odds.pity.mythic,
				odds.pityMythic
			),
			size = UDim2.new(1, 0, 0, 36),
			auto = Enum.AutomaticSize.Y,
			textSize = 16,
			color = Theme.Gold,
		})
		Util.label({
			parent = body,
			text = "Legendary is guaranteed by roll "
				.. tostring(odds.pityLegendary)
				.. ". Mythic is guaranteed by roll "
				.. tostring(odds.pityMythic)
				.. ". Luck and pity change the % below. Totals 100%.",
			size = UDim2.new(1, 0, 0, 48),
			auto = Enum.AutomaticSize.Y,
			textSize = 15,
			color = Theme.Muted,
		})

		local sum = 0
		for _, row in odds.planes do
			sum += row.percent
			local line = Util.panel({ parent = body, size = UDim2.new(1, -4, 0, 28), bg = Theme.Panel2, radius = 8 })
			Util.label({
				parent = line,
				text = row.name,
				size = UDim2.new(0.62, 0, 1, 0),
				pos = UDim2.fromOffset(8, 0),
				color = Rarities.color(row.rarity),
			})
			Util.label({
				parent = line,
				text = Format.oddsLine(row.percent),
				size = UDim2.new(0.3, 0, 1, 0),
				pos = UDim2.new(1, -8, 0, 0),
				anchor = Vector2.new(1, 0),
				align = Enum.TextXAlignment.Right,
			})
		end
		Util.label({
			parent = body,
			text = "Total  " .. string.format("%.2f%%", sum),
			size = UDim2.new(1, 0, 0, 28),
			font = Theme.Fonts.Title,
			color = Theme.Green,
			auto = Enum.AutomaticSize.Y,
			textSize = 18,
		})
	end

	local function rebuild()
		Util.clear(scroll)
		local snap = State.snapshot
		if not snap then
			return
		end
		local restricted = snap.computed.restrictedPaidRandom
		if restricted then
			Util.label({
				parent = scroll,
				text = "Paid random Robux rolls are hidden in your region. Coin crates still work. Use the Index to buy a guaranteed plane.",
				size = UDim2.new(1, -8, 0, 64),
				auto = Enum.AutomaticSize.Y,
				textSize = 16,
				color = Theme.Gold,
			})
		end

		for _, crate in Crates.List do
			local robuxKey = crate.robuxKey
			local showRobux = robuxKey ~= nil and not restricted
			local frame = Util.panel({
				parent = scroll,
				size = UDim2.new(1, -8, 0, if showRobux then 124 else 108),
				bg = Theme.Panel2,
			})
			Util.label({
				parent = frame,
				text = crate.name,
				size = UDim2.new(0.62, 0, 0, 28),
				pos = UDim2.fromOffset(10, 6),
				font = Theme.Fonts.Title,
				color = crate.color,
			})
			Util.label({
				parent = frame,
				text = crate.blurb,
				size = UDim2.new(0.62, 0, 0, 36),
				pos = UDim2.fromOffset(10, 34),
				color = Theme.Muted,
			})
			if crate.currency == "coins" then
				Util.label({
					parent = frame,
					text = Format.abbrev(crate.cost) .. " coins",
					size = UDim2.new(0.62, 0, 0, 22),
					pos = UDim2.fromOffset(10, 70),
					color = Theme.Gold,
				})
			end

			local open = Util.button({
				parent = frame,
				text = "OPEN",
				size = UDim2.fromOffset(90, 36),
				pos = UDim2.new(1, -16, 0, 10),
				anchor = Vector2.new(1, 0),
				bg = Theme.Accent,
			})
			open.MouseButton1Click:Connect(function()
				Remotes.OpenCrate:FireServer(crate.id)
			end)

			if showRobux and robuxKey then
				local product = Products.ProductByKey[robuxKey]
				if product then
					local robux = Util.button({
						parent = frame,
						text = "R$" .. tostring(product.priceHint),
						size = UDim2.fromOffset(90, 32),
						pos = UDim2.new(1, -16, 0, 50),
						anchor = Vector2.new(1, 0),
						bg = Theme.Gold,
					})
					robux.MouseButton1Click:Connect(function()
						promptProduct(product.id)
					end)
				end
			end

			local det = Util.button({
				parent = frame,
				text = "Details",
				size = UDim2.fromOffset(90, 32),
				pos = UDim2.new(1, -16, 1, -12),
				anchor = Vector2.new(1, 1),
				bg = Theme.Sky,
			})
			det.MouseButton1Click:Connect(function()
				showDetails(crate.id)
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

	HUD.register("Crates", page)
end

return CratesUI
