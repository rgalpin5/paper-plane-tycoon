local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Upgrades = Config.Upgrades
local Planes = Config.Planes

local State = require(script.Parent.Parent.State)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)

local HangarUI = {}

function HangarUI.mount(gui: ScreenGui)
	local page = Util.panel({
		parent = gui,
		size = UDim2.new(0.94, 0, 0.74, 0),
		pos = UDim2.new(0.5, 0, 0.47, 0),
		anchor = Vector2.new(0.5, 0.5),
		z = 20,
	})
	Util.label({
		parent = page,
		text = "HANGAR",
		size = UDim2.new(1, -20, 0, 36),
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

	local scroll = Util.scroll(page, UDim2.new(1, -16, 1, -56))
	scroll.Position = UDim2.fromOffset(8, 48)
	Util.list(scroll, 8)

	local function rebuild()
		Util.clear(scroll)
		local snap = State.snapshot
		if not snap then
			return
		end

		Util.label({
			parent = scroll,
			text = string.format(
				"Storage %d  •  Stands %d  •  Offline %sh  •  %s/min",
				snap.computed.storage,
				snap.computed.stands,
				tostring(snap.computed.offlineHours),
				Format.abbrev(snap.computed.idlePerMinute)
			),
			size = UDim2.new(1, 0, 0, 36),
			auto = Enum.AutomaticSize.Y,
			textSize = 16,
			color = Theme.Gold,
		})

		for _, def in Upgrades.Hangar do
			local level = snap.data.hangarUpgrades[def.id] or 0
			local cost = if level >= def.maxLevel then 0 else Upgrades.cost(def, level)
			local frame = Util.panel({ parent = scroll, size = UDim2.new(1, -8, 0, 74), bg = Theme.Panel2 })
			Util.label({
				parent = frame,
				text = def.name .. "  " .. level .. "/" .. def.maxLevel,
				size = UDim2.new(0.58, 0, 0, 28),
				pos = UDim2.fromOffset(10, 6),
				font = Theme.Fonts.Title,
			})
			Util.label({
				parent = frame,
				text = def.blurb,
				size = UDim2.new(0.58, 0, 0, 30),
				pos = UDim2.fromOffset(10, 34),
				color = Theme.Muted,
			})
			local buy = Util.button({
				parent = frame,
				text = if level >= def.maxLevel then "MAX" else Format.abbrev(cost),
				size = UDim2.fromOffset(80, 34),
				pos = UDim2.new(1, -96, 0.5, 0),
				anchor = Vector2.new(0, 0.5),
				bg = Theme.Green,
			})
			buy.MouseButton1Click:Connect(function()
				Remotes.BuyHangarUpgrade:FireServer(def.id, false)
			end)
			local maxBtn = Util.button({
				parent = frame,
				text = "MAX",
				size = UDim2.fromOffset(48, 34),
				pos = UDim2.new(1, -44, 0.5, 0),
				anchor = Vector2.new(0, 0.5),
				bg = Theme.Sky,
			})
			maxBtn.MouseButton1Click:Connect(function()
				Remotes.BuyHangarUpgrade:FireServer(def.id, true)
			end)
		end

		Util.label({
			parent = scroll,
			text = "EQUIPPED PLANE  (best plane shows on your plot)",
			size = UDim2.new(1, 0, 0, 28),
			font = Theme.Fonts.Title,
			auto = Enum.AutomaticSize.Y,
			textSize = 18,
		})

		for _, id in snap.data.equipped do
			local def = Planes.get(id)
			local row = Util.panel({ parent = scroll, size = UDim2.new(1, -8, 0, 48), bg = Color3.fromRGB(50, 70, 90) })
			Util.label({
				parent = row,
				text = def and def.name or id,
				size = UDim2.new(0.9, 0, 1, 0),
				pos = UDim2.fromOffset(10, 0),
			})
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

	HUD.register("Hangar", page)
end

return HangarUI
