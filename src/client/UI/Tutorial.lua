local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)

local HANGAR_TEXT = "Your hangar is ready — look for your name on a stall"
local THROW_TEXT = "Walk to the blue THROW pads in the hallway"
local UPGRADE_TEXT = "Nice! Open UP and buy any upgrade"
local BENCH_TEXT = "Sit on the FREE bench for strength (no coins)"
local DONE_TEXT = "You're flying. Upgrade, collect planes, rebirth."

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
		text = HANGAR_TEXT,
		align = Enum.TextXAlignment.Center,
		font = Theme.Fonts.Title,
	})
	banner.Visible = false

	local function show(text: string)
		banner.BackgroundTransparency = 0.08
		label.TextTransparency = 0
		label.Text = text
		banner.Visible = true
	end

	local function fadeOut()
		TweenService:Create(banner, TweenInfo.new(0.7), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(label, TweenInfo.new(0.7), { TextTransparency = 1 }):Play()
		task.delay(0.75, function()
			banner.Visible = false
			banner.BackgroundTransparency = 0.08
			label.TextTransparency = 0
		end)
	end

	Remotes.Tutorial.OnClientEvent:Connect(function(step)
		if step == "hangar" then
			show(HANGAR_TEXT)
			task.delay(3.5, function()
				local snap = require(script.Parent.Parent.State).snapshot
				if snap and snap.data.tutorial and not snap.data.tutorial.thrown then
					show(THROW_TEXT)
				end
			end)
		elseif step == "upgrade" then
			show(UPGRADE_TEXT)
			HUD.open("Upgrades")
		elseif step == "bench" then
			HUD.close()
			show(BENCH_TEXT)
		elseif step == "done" then
			show(DONE_TEXT)
			task.delay(3.5, fadeOut)
		end
	end)

	task.defer(function()
		local snap = require(script.Parent.Parent.State).snapshot
		if snap and snap.data.tutorial and not snap.data.tutorial.complete then
			local t = snap.data.tutorial
			if not t.hangar then
				show(HANGAR_TEXT)
			elseif not t.thrown then
				show(THROW_TEXT)
			elseif not t.upgraded then
				show(UPGRADE_TEXT)
			elseif not t.benched then
				show(BENCH_TEXT)
			end
		end
	end)
end

return Tutorial
