local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Planes = Config.Planes
local Rarities = Config.Rarities
local Numbers = Config.Numbers

local State = require(script.Parent.Parent.State)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)

local IndexUI = {}

function IndexUI.mount(gui: ScreenGui)
	local page = Util.panel({
		parent = gui,
		size = UDim2.new(0.94, 0, 0.74, 0),
		pos = UDim2.new(0.5, 0, 0.47, 0),
		anchor = Vector2.new(0.5, 0.5),
		z = 20,
	})
	local title = Util.label({
		parent = page,
		text = "PLANE INDEX",
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
	Util.list(scroll, 6)

	local function rebuild()
		Util.clear(scroll)
		local snap = State.snapshot
		if not snap then
			return
		end
		local ownedN = 0
		for _ in snap.data.ownedPlanes do
			ownedN += 1
		end
		title.Text = "PLANE INDEX  " .. ownedN .. "/" .. Planes.count()

		local restricted = snap.computed.restrictedPaidRandom
		for _, def in Planes.List do
			local owned = (snap.data.ownedPlanes[def.id] or 0) > 0
			local equipped = table.find(snap.data.equipped, def.id) ~= nil
			local frame = Util.panel({
				parent = scroll,
				size = UDim2.new(1, -8, 0, 64),
				bg = if owned then Theme.Panel2 else Color3.fromRGB(22, 24, 30),
			})
			local name = if owned then def.name else "?????"
			Util.label({
				parent = frame,
				text = name,
				size = UDim2.new(0.5, 0, 0, 28),
				pos = UDim2.fromOffset(10, 4),
				font = Theme.Fonts.Title,
				color = if owned then Rarities.color(def.rarity) else Theme.Muted,
			})
			Util.label({
				parent = frame,
				text = def.rarity .. "  ×" .. string.format("%.2f", def.multiplier),
				size = UDim2.new(0.5, 0, 0, 24),
				pos = UDim2.fromOffset(10, 32),
				color = Theme.Muted,
			})
			if owned then
				local eq = Util.button({
					parent = frame,
					text = if equipped then "ON" else "EQUIP",
					size = UDim2.fromOffset(78, 36),
					pos = UDim2.new(1, -16, 0.5, 0),
					anchor = Vector2.new(1, 0.5),
					bg = if equipped then Theme.Green else Theme.Sky,
				})
				eq.MouseButton1Click:Connect(function()
					if equipped then
						Remotes.UnequipPlane:FireServer(def.id)
					else
						Remotes.EquipPlane:FireServer(def.id)
					end
				end)
			elseif restricted and def.rarity ~= "Secret" then
				local price = Numbers.GuaranteedPrices[def.rarity]
				if price then
					local buy = Util.button({
						parent = frame,
						text = Format.abbrev(price),
						size = UDim2.fromOffset(90, 36),
						pos = UDim2.new(1, -16, 0.5, 0),
						anchor = Vector2.new(1, 0.5),
						bg = Theme.Gold,
					})
					buy.MouseButton1Click:Connect(function()
						Remotes.BuyGuaranteedPlane:FireServer(def.id)
					end)
				end
			end
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

	HUD.register("Index", page)
end

return IndexUI
