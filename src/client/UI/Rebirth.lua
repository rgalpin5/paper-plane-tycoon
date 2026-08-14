local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)

local RebirthUI = {}

function RebirthUI.mount(gui: ScreenGui)
	local page = Util.panel({
		parent = gui,
		size = UDim2.new(0.9, 0, 0.64, 0),
		pos = UDim2.new(0.5, 0, 0.47, 0),
		anchor = Vector2.new(0.5, 0.5),
		z = 20,
	})
	Util.label({
		parent = page,
		text = "REBIRTH",
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

	local info = Util.label({
		parent = page,
		text = "",
		size = UDim2.new(1, -24, 0, 200),
		pos = UDim2.fromOffset(12, 50),
		color = Theme.Paper,
	})
	info.TextWrapped = true
	info.TextScaled = false
	info.TextSize = 18
	info.TextYAlignment = Enum.TextYAlignment.Top

	local go = Util.button({
		parent = page,
		text = "REBIRTH",
		size = UDim2.new(0.8, 0, 0, 52),
		pos = UDim2.new(0.5, 0, 1, -16),
		anchor = Vector2.new(0.5, 1),
		bg = Theme.Accent,
	})

	local function rebuild()
		local preview = Remotes.GetRebirthPreview:InvokeServer()
		if not preview then
			info.Text = "Loading..."
			return
		end
		info.Text = string.format(
			"Cost  %s coins\nCoins  ×%.2f → ×%.2f  (+%.0f%% forever)\nStrength  ×%.2f → ×%.2f  (+%.0f%% forever)\nRebirths  %d\n\nKeeps: %s\nResets: %s",
			Format.abbrev(preview.cost),
			preview.currentCoin,
			preview.nextCoin,
			preview.coinGain * 100,
			preview.currentStrength,
			preview.nextStrength,
			preview.strengthGain * 100,
			preview.rebirths,
			table.concat(preview.keeps, ", "),
			table.concat(preview.resets, ", ")
		)
		go.BackgroundColor3 = if preview.canAfford then Theme.Accent else Theme.Muted
	end

	go.MouseButton1Click:Connect(function()
		Remotes.Rebirth:FireServer()
		task.defer(rebuild)
	end)

	page:GetPropertyChangedSignal("Visible"):Connect(function()
		if page.Visible then
			rebuild()
		end
	end)

	HUD.register("Rebirth", page)
end

return RebirthUI
