local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local PlaneFactory = require(ReplicatedStorage.Shared.PlaneFactory)
local Rarities = Config.Rarities
local Planes = Config.Planes

local Theme = require(script.Parent.Parent.UI.Theme)
local Util = require(script.Parent.Parent.UI.Util)
local FX = require(script.Parent.FX)

local CrateAnim = {}

function CrateAnim.play(gui: ScreenGui, result)
	local def = Planes.get(result.planeId)
	if not def then
		return
	end
	local color = Rarities.color(def.rarity)

	if result.skipped then
		FX.crateSlam(color)
		return
	end

	local overlay = Instance.new("Frame")
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.35
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = 40
	overlay.Parent = gui

	local box = Util.panel({
		parent = overlay,
		size = UDim2.fromOffset(180, 180),
		pos = UDim2.fromScale(0.5, 0.45),
		anchor = Vector2.new(0.5, 0.5),
		bg = color,
		z = 41,
		radius = 24,
	})
	local title = Util.label({
		parent = overlay,
		text = "Unfolding...",
		size = UDim2.new(0.8, 0, 0, 40),
		pos = UDim2.new(0.5, 0, 0.22, 0),
		anchor = Vector2.new(0.5, 0),
		align = Enum.TextXAlignment.Center,
		font = Theme.Fonts.Title,
		z = 41,
	})

	for _ = 1, 8 do
		local shake = TweenService:Create(box, TweenInfo.new(0.07), {
			Rotation = (math.random() - 0.5) * 18,
		})
		shake:Play()
		shake.Completed:Wait()
	end
	box.Rotation = 0

	title.Text = def.rarity
	title.TextColor3 = color
	local name = Util.label({
		parent = overlay,
		text = def.name,
		size = UDim2.new(0.8, 0, 0, 36),
		pos = UDim2.new(0.5, 0, 0.72, 0),
		anchor = Vector2.new(0.5, 0),
		align = Enum.TextXAlignment.Center,
		font = Theme.Fonts.Title,
		z = 41,
	})
	if result.duplicate then
		name.Text = def.name .. "  duplicate  +" .. tostring(result.scrap) .. " scrap"
	end

	local model = PlaneFactory.create(result.planeId)
	model.Parent = Workspace
	local cam = workspace.CurrentCamera
	local cf = cam.CFrame * CFrame.new(0, 0, -8)
	model:PivotTo(cf)
	Debris:AddItem(model, 1.6)

	FX.crateSlam(color)
	if def.rarity == "Mythic" or def.rarity == "Secret" then
		FX.shake(0.7, 0.5)
	end

	task.delay(1.6, function()
		overlay:Destroy()
	end)
end

return CrateAnim
