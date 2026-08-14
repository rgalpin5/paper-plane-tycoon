local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local State = require(script.Parent.Parent.State)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)

local HUD = {}
local pages: { [string]: Frame } = {}
local current: string? = nil
local overlay: Frame
local coinsLabel: TextLabel
local strengthLabel: TextLabel
local scrapLabel: TextLabel
local boostLabel: TextLabel
local lastThrow = 0

local function closePages()
	for _, page in pages do
		page.Visible = false
	end
	overlay.Visible = false
	current = nil
end

function HUD.register(name: string, page: Frame)
	pages[name] = page
	page.Visible = false
end

function HUD.open(name: string)
	if current == name then
		closePages()
		return
	end
	for key, page in pages do
		page.Visible = key == name
	end
	overlay.Visible = true
	current = name
end

function HUD.close()
	closePages()
end

function HUD.current(): string?
	return current
end

local function refresh(snap)
	if not snap then
		return
	end
	coinsLabel.Text = Format.abbrev(snap.data.coins)
	strengthLabel.Text = "STR " .. Format.abbrev(snap.data.strength)
	scrapLabel.Text = Format.abbrev(snap.data.scrap) .. " scrap"
	local remain = snap.computed.boostRemaining or 0
	boostLabel.Visible = remain > 0
	if remain > 0 then
		boostLabel.Text = "2× " .. Format.time(remain)
	end
end

function HUD.mount(gui: ScreenGui)
	local top = Util.panel({
		parent = gui,
		size = UDim2.new(0.92, 0, 0, 64),
		pos = UDim2.new(0.5, 0, 0, 12),
		anchor = Vector2.new(0.5, 0),
		bg = Theme.Panel,
		z = 5,
	})

	coinsLabel = Util.label({
		parent = top,
		text = "0",
		size = UDim2.new(0.34, 0, 1, -8),
		pos = UDim2.new(0, 12, 0.5, 0),
		anchor = Vector2.new(0, 0.5),
		font = Theme.Fonts.Title,
		color = Theme.Gold,
	})
	strengthLabel = Util.label({
		parent = top,
		text = "STR 10",
		size = UDim2.new(0.32, 0, 0.75, 0),
		pos = UDim2.new(0.36, 0, 0.5, 0),
		anchor = Vector2.new(0, 0.5),
		font = Theme.Fonts.Title,
		color = Theme.Accent,
	})
	scrapLabel = Util.label({
		parent = top,
		text = "0 scrap",
		size = UDim2.new(0.28, -8, 0.7, 0),
		pos = UDim2.new(1, -8, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		align = Enum.TextXAlignment.Right,
		color = Theme.Paper,
	})

	boostLabel = Util.label({
		parent = gui,
		text = "",
		size = UDim2.fromOffset(140, 28),
		pos = UDim2.new(0.5, 0, 0, 80),
		anchor = Vector2.new(0.5, 0),
		align = Enum.TextXAlignment.Center,
		color = Theme.Gold,
		font = Theme.Fonts.Title,
		z = 6,
	})
	boostLabel.Visible = false

	local hint = Util.label({
		parent = gui,
		text = "Walk onto a THROW pad  •  Space to launch",
		size = UDim2.new(0.7, 0, 0, 28),
		pos = UDim2.new(0.5, 0, 1, -18),
		anchor = Vector2.new(0.5, 1),
		align = Enum.TextXAlignment.Center,
		color = Theme.Paper,
		z = 6,
	})
	hint.TextTransparency = 0.15

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Space then
			local snap = State.snapshot
			local cd = if snap then snap.computed.throwCooldown else 0.95
			if os.clock() - lastThrow < cd * 0.5 then
				return
			end
			lastThrow = os.clock()
			Remotes.Throw:FireServer()
		end
	end)

	local navLeft = Instance.new("Frame")
	navLeft.BackgroundTransparency = 1
	navLeft.Size = UDim2.fromOffset(92, 280)
	navLeft.Position = UDim2.new(0, 10, 0.55, 0)
	navLeft.AnchorPoint = Vector2.new(0, 0.5)
	navLeft.Parent = gui
	Util.list(navLeft, 8)

	local navRight = Instance.new("Frame")
	navRight.BackgroundTransparency = 1
	navRight.Size = UDim2.fromOffset(92, 360)
	navRight.Position = UDim2.new(1, -10, 0.52, 0)
	navRight.AnchorPoint = Vector2.new(1, 0.5)
	navRight.Parent = gui
	Util.list(navRight, 8)

	local function nav(parent, name, label, color)
		local b = Util.button({
			parent = parent,
			text = label,
			size = UDim2.new(1, 0, 0, 58),
			bg = color,
			radius = 14,
		})
		b.MouseButton1Click:Connect(function()
			HUD.open(name)
		end)
		return b
	end

	nav(navLeft, "Upgrades", "UP", Theme.Accent)
	nav(navLeft, "Hangar", "HAN", Color3.fromRGB(180, 110, 70))
	nav(navLeft, "Index", "IDX", Color3.fromRGB(90, 90, 140))
	nav(navRight, "Crates", "BOX", Theme.Gold)
	nav(navRight, "Shop", "SHOP", Theme.Green)
	nav(navRight, "Daily", "DAY", Color3.fromRGB(80, 180, 160))
	nav(navRight, "Rebirth", "RB", Color3.fromRGB(180, 70, 140))

	overlay = Instance.new("TextButton")
	overlay.Name = "Overlay"
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.45
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = 15
	overlay.Visible = false
	overlay.Parent = gui
	overlay.MouseButton1Click:Connect(closePages)

	State.Changed:Connect(refresh)
	if State.snapshot then
		refresh(State.snapshot)
	end

	task.spawn(function()
		while true do
			task.wait(1)
			if State.snapshot then
				refresh(State.snapshot)
			end
		end
	end)
end

HUD.Close = closePages

return HUD
