local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local PlaneFactory = require(ReplicatedStorage.Shared.PlaneFactory)
local Upgrades = Config.Upgrades
local Planes = Config.Planes
local Numbers = Config.Numbers

local State = require(script.Parent.Parent.State)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)

local HangarUI = {}
local spawned: { Model } = {}

local function clearStands()
	for _, m in spawned do
		m:Destroy()
	end
	table.clear(spawned)
end

function HangarUI.showEquipped(equipped)
	clearStands()
	local map = workspace:FindFirstChild("Map")
	local folder = map and map:FindFirstChild("DisplayStands")
	if not folder then
		return
	end
	local stands = {}
	for _, child in folder:GetChildren() do
		if child:IsA("BasePart") then
			table.insert(stands, child)
		end
	end
	table.sort(stands, function(a, b)
		return (a:GetAttribute("Slot") or 0) < (b:GetAttribute("Slot") or 0)
	end)
	for i, planeId in equipped do
		local stand = stands[i]
		if stand then
			local model = PlaneFactory.create(planeId)
			model.Parent = stand
			model:PivotTo(stand.CFrame * CFrame.new(0, 2.5, 0) * CFrame.Angles(0, math.rad(25), math.rad(-10)))
			table.insert(spawned, model)
		end
	end
end

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

		local auto = Util.panel({ parent = scroll, size = UDim2.new(1, -8, 0, 72), bg = Theme.Panel2 })
		local unlocked = snap.computed.autoThrow
		Util.label({
			parent = auto,
			text = if unlocked then "Auto Throw ON" else "Unlock Auto Throw",
			size = UDim2.new(0.6, 0, 0, 30),
			pos = UDim2.fromOffset(10, 8),
			font = Theme.Fonts.Title,
		})
		Util.label({
			parent = auto,
			text = "Upgrade path or game pass. Throws while you're in-experience.",
			size = UDim2.new(0.6, 0, 0, 28),
			pos = UDim2.fromOffset(10, 36),
			color = Theme.Muted,
		})
		if not unlocked then
			local b = Util.button({
				parent = auto,
				text = Format.abbrev(Numbers.AutoThrowUpgradeCost),
				size = UDim2.fromOffset(110, 40),
				pos = UDim2.new(1, -16, 0.5, 0),
				anchor = Vector2.new(1, 0.5),
				bg = Theme.Sky,
			})
			b.MouseButton1Click:Connect(function()
				Remotes.BuyAutoThrow:FireServer()
			end)
		end

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
			text = "EQUIPPED  (" .. #snap.data.equipped .. "/" .. snap.computed.equipSlots .. ")",
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
				size = UDim2.new(0.7, 0, 1, 0),
				pos = UDim2.fromOffset(10, 0),
			})
			local u = Util.button({
				parent = row,
				text = "OFF",
				size = UDim2.fromOffset(56, 32),
				pos = UDim2.new(1, -12, 0.5, 0),
				anchor = Vector2.new(1, 0.5),
				bg = Theme.Danger,
			})
			u.MouseButton1Click:Connect(function()
				Remotes.UnequipPlane:FireServer(id)
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
		if State.snapshot then
			HangarUI.showEquipped(State.snapshot.data.equipped)
		end
	end)

	Remotes.HangarDisplay.OnClientEvent:Connect(function(equipped)
		HangarUI.showEquipped(equipped)
	end)

	HUD.register("Hangar", page)
end

return HangarUI
