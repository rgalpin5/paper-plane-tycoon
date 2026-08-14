local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Format = require(game:GetService("ReplicatedStorage").Shared.Format)
local Theme = require(script.Parent.Parent.UI.Theme)

local FX = {}

local function play(id: string, volume: number)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = volume or 0.5
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 3)
end

function FX.whoosh()
	play("rbxasset://sounds/action_whoosh.ogg", 0.45)
end

function FX.land()
	play("rbxasset://sounds/impact_water.mp3", 0.35)
end

function FX.popup(position: Vector3, text: string, color: Color3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position + Vector3.new(0, 4, 0)
	part.Parent = Workspace

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(160, 50)
	bb.AlwaysOnTop = true
	bb.Parent = part
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.4
	label.Text = text
	label.Parent = bb

	TweenService:Create(part, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = part.Position + Vector3.new(0, 6, 0),
	}):Play()
	Debris:AddItem(part, 1)
end

function FX.burst(position: Vector3, color: Color3)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.Size = Vector3.new(1, 1, 1)
	p.Position = position
	p.Parent = Workspace
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(color)
	e.Lifetime = NumberRange.new(0.3, 0.6)
	e.Speed = NumberRange.new(6, 14)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Rate = 0
	e.Size = NumberSequence.new(0.4, 0)
	e.Parent = p
	e:Emit(18)
	Debris:AddItem(p, 1.2)
end

function FX.shake(intensity: number, duration: number)
	local cam = Workspace.CurrentCamera
	local t0 = os.clock()
	local conn
	conn = game:GetService("RunService").RenderStepped:Connect(function()
		if os.clock() - t0 > duration then
			conn:Disconnect()
			return
		end
		local o = intensity * (1 - (os.clock() - t0) / duration)
		cam.CFrame *= CFrame.new((math.random() - 0.5) * o, (math.random() - 0.5) * o, 0)
	end)
end

function FX.coins(position: Vector3, amount: number)
	FX.popup(position, "+" .. Format.abbrev(amount), Theme.Gold)
end

function FX.crateSlam(rarityColor: Color3)
	local flash = Instance.new("ColorCorrectionEffect")
	flash.TintColor = rarityColor
	flash.Brightness = 0.25
	flash.Parent = Lighting
	Debris:AddItem(flash, 0.25)
	FX.shake(0.35, 0.28)
end

return FX
