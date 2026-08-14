local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Upgrades = Config.Upgrades

local State = require(script.Parent.Parent.State)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)

local UpgradesUI = {}

local function row(parent, def, level, coins, remoteName)
	local cost = if level >= def.maxLevel then 0 else Upgrades.cost(def, level)
	local frame = Util.panel({
		parent = parent,
		size = UDim2.new(1, -8, 0, 78),
		bg = Theme.Panel2,
		radius = 12,
	})
	Util.label({
		parent = frame,
		text = def.name .. "  " .. tostring(level) .. "/" .. tostring(def.maxLevel),
		size = UDim2.new(1, -16, 0, 28),
		pos = UDim2.fromOffset(10, 6),
		font = Theme.Fonts.Title,
	})
	Util.label({
		parent = frame,
		text = def.blurb,
		size = UDim2.new(0.52, 0, 0, 32),
		pos = UDim2.fromOffset(10, 36),
		color = Theme.Muted,
	})
	local buy = Util.button({
		parent = frame,
		text = if level >= def.maxLevel then "MAX" else Format.abbrev(cost),
		size = UDim2.fromOffset(88, 36),
		pos = UDim2.new(1, -100, 0.5, 0),
		anchor = Vector2.new(0, 0.5),
		bg = if coins >= cost then Theme.Green else Theme.Muted,
		radius = 10,
	})
	buy.MouseButton1Click:Connect(function()
		Remotes[remoteName]:FireServer(def.id, false)
	end)
	local maxBtn = Util.button({
		parent = frame,
		text = "MAX",
		size = UDim2.fromOffset(52, 36),
		pos = UDim2.new(1, -44, 0.5, 0),
		anchor = Vector2.new(0, 0.5),
		bg = Theme.Sky,
		radius = 10,
	})
	maxBtn.MouseButton1Click:Connect(function()
		Remotes[remoteName]:FireServer(def.id, true)
	end)
end

function UpgradesUI.mount(gui: ScreenGui)
	local page = Util.panel({
		parent = gui,
		size = UDim2.new(0.94, 0, 0.74, 0),
		pos = UDim2.new(0.5, 0, 0.47, 0),
		anchor = Vector2.new(0.5, 0.5),
		z = 20,
	})
	Util.label({
		parent = page,
		text = "UPGRADES",
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

	local function header(text)
		Util.label({
			parent = scroll,
			text = text,
			size = UDim2.new(1, 0, 0, 24),
			font = Theme.Fonts.Title,
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
		header("PLANE")
		for _, def in Upgrades.Plane do
			row(scroll, def, snap.data.planeLevel or 0, snap.data.coins, "BuyUpgrade")
		end
		header("PLAYER")
		for _, def in Upgrades.Player do
			row(scroll, def, snap.data.playerUpgrades[def.id] or 0, snap.data.coins, "BuyPlayerUpgrade")
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

	HUD.register("Upgrades", page)
end

return UpgradesUI
