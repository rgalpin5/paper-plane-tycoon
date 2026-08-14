local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)

local Tutorial = {}

function Tutorial.mount(gui: ScreenGui)
	local banner = Util.panel({
		parent = gui,
		size = UDim2.new(0.86, 0, 0, 56),
		pos = UDim2.new(0.5, 0, 1, -210),
		anchor = Vector2.new(0.5, 1),
		bg = Theme.Accent,
		z = 12,
	})
	local label = Util.label({
		parent = banner,
		text = "Tap THROW to launch your Folded Note",
		align = Enum.TextXAlignment.Center,
		font = Theme.Fonts.Title,
	})
	banner.Visible = false

	local function show(text: string)
		label.Text = text
		banner.Visible = true
	end

	Remotes.Tutorial.OnClientEvent:Connect(function(step)
		if step == "upgrade" then
			show("Nice! Open UP and buy any upgrade")
			HUD.open("Upgrades")
		elseif step == "throwAgain" then
			HUD.close()
			show("Throw again — watch the coins jump")
		elseif step == "done" then
			show("You're flying. Upgrade, collect planes, rebirth.")
			task.delay(3.5, function()
				banner.Visible = false
			end)
		end
	end)

	task.defer(function()
		local snap = require(script.Parent.Parent.State).snapshot
		if snap and snap.data.tutorial and not snap.data.tutorial.complete then
			if not snap.data.tutorial.thrown then
				show("Tap THROW to launch your Folded Note")
			elseif not snap.data.tutorial.upgraded then
				show("Open UP and buy any upgrade")
			elseif not snap.data.tutorial.thrownAfter then
				show("Throw again — watch the coins jump")
			end
		end
	end)
end

return Tutorial
