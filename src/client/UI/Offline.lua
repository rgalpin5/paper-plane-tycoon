local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)

local Offline = {}

function Offline.mount(gui: ScreenGui)
	local modal = Util.panel({
		parent = gui,
		size = UDim2.new(0.86, 0, 0, 210),
		pos = UDim2.new(0.5, 0, 0.45, 0),
		anchor = Vector2.new(0.5, 0.5),
		bg = Theme.Panel,
		z = 30,
	})
	modal.Visible = false
	Util.label({
		parent = modal,
		text = "HANGAR REPORT",
		size = UDim2.new(1, -16, 0, 36),
		pos = UDim2.fromOffset(10, 10),
		font = Theme.Fonts.Title,
		align = Enum.TextXAlignment.Center,
	})
	local body = Util.label({
		parent = modal,
		text = "",
		size = UDim2.new(1, -24, 0, 90),
		pos = UDim2.fromOffset(12, 50),
		align = Enum.TextXAlignment.Center,
	})
	body.TextWrapped = true
	local ok = Util.button({
		parent = modal,
		text = "NICE",
		size = UDim2.new(0.6, 0, 0, 44),
		pos = UDim2.new(0.5, 0, 1, -16),
		anchor = Vector2.new(0.5, 1),
		bg = Theme.Green,
	})
	ok.MouseButton1Click:Connect(function()
		modal.Visible = false
	end)

	Remotes.OfflineEarnings.OnClientEvent:Connect(function(payload)
		if typeof(payload) ~= "table" then
			return
		end
		body.Text = string.format(
			"Your hangar made %s coins\nwhile you were away (%.0f min, cap %sh).",
			Format.abbrev(payload.coins),
			payload.minutes,
			tostring(payload.capHours)
		)
		modal.Visible = true
	end)
end

return Offline
