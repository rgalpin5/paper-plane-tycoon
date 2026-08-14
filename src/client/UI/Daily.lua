local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Numbers = Config.Numbers

local State = require(script.Parent.Parent.State)
local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)
local HUD = require(script.Parent.HUD)

local DailyUI = {}

function DailyUI.mount(gui: ScreenGui)
	local page = Util.panel({
		parent = gui,
		size = UDim2.new(0.9, 0, 0.62, 0),
		pos = UDim2.new(0.5, 0, 0.47, 0),
		anchor = Vector2.new(0.5, 0.5),
		z = 20,
	})
	Util.label({
		parent = page,
		text = "DAILY STREAK",
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

	local body = Instance.new("Frame")
	body.BackgroundTransparency = 1
	body.Size = UDim2.new(1, -20, 1, -110)
	body.Position = UDim2.fromOffset(10, 50)
	body.Parent = page
	Util.list(body, 8)

	local claim = Util.button({
		parent = page,
		text = "CLAIM",
		size = UDim2.new(0.8, 0, 0, 52),
		pos = UDim2.new(0.5, 0, 1, -16),
		anchor = Vector2.new(0.5, 1),
		bg = Theme.Green,
	})
	claim.MouseButton1Click:Connect(function()
		Remotes.ClaimDaily:FireServer()
	end)

	local function rebuild()
		Util.clear(body)
		local data = State.data()
		if not data then
			return
		end
		Util.label({
			parent = body,
			text = "Streak  " .. tostring(data.streak) .. " / 7     Shields  " .. tostring(data.streakShields),
			size = UDim2.new(1, 0, 0, 28),
			font = Theme.Fonts.Title,
			auto = Enum.AutomaticSize.Y,
			textSize = 18,
		})
		for i, reward in Numbers.DailyRewards do
			local row = Util.panel({
				parent = body,
				size = UDim2.new(1, 0, 0, 36),
				bg = if data.streak == i then Theme.Sky else Theme.Panel2,
				radius = 8,
			})
			local extra = if i == 7 then "  + Paper Crate" else ""
			Util.label({
				parent = row,
				text = "Day " .. i .. "   " .. Format.abbrev(reward) .. extra,
				size = UDim2.fromScale(1, 1),
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

	Remotes.DailyClaimed.OnClientEvent:Connect(function(payload)
		if typeof(payload) == "table" and payload.prompt and payload.preview and not payload.preview.claimed then
			HUD.open("Daily")
		end
	end)

	HUD.register("Daily", page)
end

return DailyUI
