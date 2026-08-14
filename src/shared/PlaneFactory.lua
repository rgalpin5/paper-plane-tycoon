local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Planes = Config.Planes
local Rarities = Config.Rarities
local Cosmetics = Config.Cosmetics

local PlaneFactory = {}

local function part(className: string, size: Vector3, color: Color3, parent: Instance): BasePart
	local p = Instance.new(className)
	p.Size = size
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = false
	p.Parent = parent
	return p
end

function PlaneFactory.create(planeId: string): Model
	local def = Planes.get(planeId) or Planes.get(Planes.StarterId) :: any
	local scale = def.size
	local color = def.color
	local model = Instance.new("Model")
	model.Name = def.name
	model:SetAttribute("PlaneId", def.id)
	model:SetAttribute("Rarity", def.rarity)

	local body = part("Part", Vector3.new(0.18 * scale, 0.06 * scale, 1.35 * scale), color, model)
	body.Name = "Body"

	local left = part("WedgePart", Vector3.new(0.9 * scale, 0.05 * scale, 0.7 * scale), color, model)
	left.Name = "LeftWing"
	left.CFrame = body.CFrame * CFrame.new(-0.45 * scale, 0, 0.05 * scale) * CFrame.Angles(0, math.rad(-8), math.rad(12))

	local right = part("WedgePart", Vector3.new(0.9 * scale, 0.05 * scale, 0.7 * scale), color, model)
	right.Name = "RightWing"
	right.CFrame = body.CFrame * CFrame.new(0.45 * scale, 0, 0.05 * scale) * CFrame.Angles(0, math.rad(188), math.rad(-12))

	local nose = part("WedgePart", Vector3.new(0.18 * scale, 0.08 * scale, 0.35 * scale), color:Lerp(Color3.new(1, 1, 1), 0.15), model)
	nose.Name = "Nose"
	nose.CFrame = body.CFrame * CFrame.new(0, 0.01 * scale, -0.75 * scale)

	local tail = part("WedgePart", Vector3.new(0.12 * scale, 0.22 * scale, 0.28 * scale), color, model)
	tail.Name = "Tail"
	tail.CFrame = body.CFrame * CFrame.new(0, 0.1 * scale, 0.55 * scale)

	local attachment = Instance.new("Attachment")
	attachment.Name = "TrailAt"
	attachment.Position = Vector3.new(0, 0, 0.6 * scale)
	attachment.Parent = body

	local trail = Instance.new("Trail")
	trail.Name = "PaperTrail"
	trail.Attachment0 = attachment
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "TrailAt2"
	attachment2.Position = Vector3.new(0, 0.04 * scale, 0.6 * scale)
	attachment2.Parent = body
	trail.Attachment1 = attachment2
	trail.Color = ColorSequence.new(def.trailColor, Color3.new(1, 1, 1))
	trail.Transparency = NumberSequence.new(0.15, 1)
	trail.Lifetime = 0.45
	trail.MinLength = 0.1
	trail.FaceCamera = true
	trail.Parent = body

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Rarities.color(def.rarity)
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0.85
	highlight.OutlineTransparency = 0.35
	highlight.Parent = model

	model.PrimaryPart = body
	model:SetAttribute("Scale", scale)
	return model
end

function PlaneFactory.applyCosmetics(model: Model, equipped: { string }?)
	local body = model.PrimaryPart
	if not body or not equipped then
		return
	end
	local scale = model:GetAttribute("Scale") or 1
	local trail = body:FindFirstChild("PaperTrail")
	for _, id in equipped do
		local def = Cosmetics.get(id)
		if def then
			if def.kind == "trail" and trail and trail:IsA("Trail") then
				trail.Color = ColorSequence.new(def.color, Color3.new(1, 1, 1))
				trail.Lifetime = 0.7
			elseif def.kind == "aura" then
				local att = Instance.new("Attachment")
				att.Name = "Aura"
				att.Parent = body
				local pe = Instance.new("ParticleEmitter")
				pe.Color = ColorSequence.new(def.color)
				pe.Size = NumberSequence.new(0.35 * scale, 0)
				pe.Lifetime = NumberRange.new(0.4, 0.8)
				pe.Rate = 12
				pe.Speed = NumberRange.new(0.2, 0.8)
				pe.LightEmission = 0.4
				pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				pe.Parent = att
			elseif def.kind == "trinket" then
				local gem = Instance.new("Part")
				gem.Name = "Trinket"
				gem.Shape = Enum.PartType.Ball
				gem.Size = Vector3.new(0.22, 0.22, 0.22) * scale
				gem.Color = def.color
				gem.Material = Enum.Material.Neon
				gem.Anchored = true
				gem.CanCollide = false
				gem.Massless = true
				gem.CFrame = body.CFrame * CFrame.new(0, 0.16 * scale, 0)
				gem.Parent = model
			end
		end
	end
end

function PlaneFactory.weldTo(model: Model, cf: CFrame)
	if model.PrimaryPart then
		model:PivotTo(cf)
	end
end

return PlaneFactory
