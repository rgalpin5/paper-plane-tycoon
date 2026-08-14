local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

local World = {}

local function part(props): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = props.canCollide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = props.material or Enum.Material.SmoothPlastic
	p.Color = props.color or Color3.fromRGB(200, 200, 200)
	p.Size = props.size
	p.CFrame = props.cf
	p.Name = props.name or "Part"
	p.CastShadow = props.castShadow ~= false
	if props.parent then
		p.Parent = props.parent
	end
	if props.transparency then
		p.Transparency = props.transparency
	end
	return p
end

local function billboard(adornee: BasePart, text: string, color: Color3, size: Vector2)
	local bb = Instance.new("BillboardGui")
	bb.Name = "Label"
	bb.Size = UDim2.fromOffset(size.X, size.Y)
	bb.StudsOffset = Vector3.new(0, adornee.Size.Y / 2 + 2, 0)
	bb.AlwaysOnTop = false
	bb.Adornee = adornee
	bb.Parent = adornee
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.4
	label.Text = text
	label.Parent = bb
end

function World.build()
	local workspace = game:GetService("Workspace")
	local existing = workspace:FindFirstChild("Map")
	if existing and existing:FindFirstChild("ThrowPad") then
		World._enhance(existing)
		World._lighting()
		return existing
	end

	local map = existing or Instance.new("Model")
	map.Name = "Map"
	map.Parent = workspace

	-- Distant city blocks under the roof
	for i = 1, 18 do
		local x = ((i % 6) - 2.5) * 42
		local z = (math.floor((i - 1) / 6) - 1) * 50 - 40
		local h = 20 + (i * 13) % 40
		part({
			name = "Building" .. i,
			size = Vector3.new(28, h, 24),
			cf = CFrame.new(x, h / 2 - 8, z - 80),
			color = Color3.fromRGB(70 + (i * 17) % 40, 80, 100 + (i * 11) % 50),
			material = Enum.Material.Concrete,
			parent = map,
		})
	end

	part({
		name = "Rooftop",
		size = Vector3.new(96, 3, 72),
		cf = CFrame.new(0, 80, 0),
		color = Color3.fromRGB(196, 176, 150),
		material = Enum.Material.Concrete,
		parent = map,
	})

	-- Parapet
	local wallColor = Color3.fromRGB(230, 220, 205)
	part({ name = "WallN", size = Vector3.new(96, 4, 1.2), cf = CFrame.new(0, 83.5, -36), color = wallColor, parent = map })
	part({ name = "WallE", size = Vector3.new(1.2, 4, 72), cf = CFrame.new(48, 83.5, 0), color = wallColor, parent = map })
	part({ name = "WallW", size = Vector3.new(1.2, 4, 72), cf = CFrame.new(-48, 83.5, 0), color = wallColor, parent = map })
	-- South edge is open for throwing
	part({ name = "WallSLeft", size = Vector3.new(30, 4, 1.2), cf = CFrame.new(-33, 83.5, 36), color = wallColor, parent = map })
	part({ name = "WallSRight", size = Vector3.new(30, 4, 1.2), cf = CFrame.new(33, 83.5, 36), color = wallColor, parent = map })

	local pad = part({
		name = "ThrowPad",
		size = Vector3.new(16, 1.2, 16),
		cf = CFrame.new(0, 82.1, 22),
		color = Color3.fromRGB(70, 160, 230),
		material = Enum.Material.Neon,
		parent = map,
	})
	CollectionService:AddTag(pad, "ThrowPad")
	billboard(pad, "THROW", Color3.fromRGB(255, 255, 255), Vector2.new(220, 64))

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = 8
	emitter.Lifetime = NumberRange.new(1, 2)
	emitter.Speed = NumberRange.new(0.4, 1.2)
	emitter.Size = NumberSequence.new(0.2, 0)
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	emitter.Parent = pad

	local vip = part({
		name = "VIPPad",
		size = Vector3.new(10, 1.4, 10),
		cf = CFrame.new(-28, 82.2, 8),
		color = Color3.fromRGB(255, 200, 60),
		material = Enum.Material.Neon,
		parent = map,
	})
	CollectionService:AddTag(vip, "VIPPad")
	billboard(vip, "VIP", Color3.fromRGB(255, 230, 120), Vector2.new(140, 48))

	-- Hangar on the north side
	local hangarColor = Color3.fromRGB(210, 140, 90)
	part({ name = "HangarFloor", size = Vector3.new(40, 1, 28), cf = CFrame.new(0, 81.6, -22), color = Color3.fromRGB(160, 120, 80), parent = map })
	part({ name = "HangarBack", size = Vector3.new(40, 16, 1.4), cf = CFrame.new(0, 89, -36), color = hangarColor, parent = map })
	part({ name = "HangarLeft", size = Vector3.new(1.4, 16, 28), cf = CFrame.new(-20, 89, -22), color = hangarColor, parent = map })
	part({ name = "HangarRight", size = Vector3.new(1.4, 16, 28), cf = CFrame.new(20, 89, -22), color = hangarColor, parent = map })
	part({ name = "HangarRoof", size = Vector3.new(42, 1.2, 30), cf = CFrame.new(0, 97.2, -22), color = Color3.fromRGB(180, 90, 60), parent = map })

	local sign = part({
		name = "HangarSign",
		size = Vector3.new(18, 3, 0.6),
		cf = CFrame.new(0, 95, -7.5),
		color = Color3.fromRGB(245, 230, 200),
		parent = map,
	})
	billboard(sign, "HANGAR", Color3.fromRGB(90, 50, 30), Vector2.new(280, 72))

	local stands = Instance.new("Folder")
	stands.Name = "DisplayStands"
	stands.Parent = map
	for i = 1, 6 do
		local x = ((i - 1) % 3 - 1) * 10
		local z = if i <= 3 then -18 else -28
		local stand = part({
			name = "DisplayStand" .. i,
			size = Vector3.new(3.2, 2.4, 3.2),
			cf = CFrame.new(x, 83.4, z),
			color = Color3.fromRGB(120, 90, 60),
			material = Enum.Material.Wood,
			parent = stands,
		})
		CollectionService:AddTag(stand, "DisplayStand")
		stand:SetAttribute("Slot", i)
	end

	-- Decor
	part({ name = "ACUnit", size = Vector3.new(6, 3, 4), cf = CFrame.new(32, 83.1, -8), color = Color3.fromRGB(150, 155, 160), parent = map })
	part({ name = "Vent", size = Vector3.new(4, 1, 4), cf = CFrame.new(32, 85.2, -8), color = Color3.fromRGB(90, 90, 95), parent = map })
	part({ name = "WaterTower", size = Vector3.new(6, 10, 6), cf = CFrame.new(36, 87, 16), color = Color3.fromRGB(180, 70, 70), material = Enum.Material.Metal, parent = map })

	local banner = part({
		name = "TitleBanner",
		size = Vector3.new(36, 6, 1),
		cf = CFrame.new(0, 92, 34),
		color = Color3.fromRGB(255, 250, 235),
		parent = map,
		canCollide = false,
	})
	billboard(banner, "PAPER PLANE TYCOON", Color3.fromRGB(40, 70, 120), Vector2.new(520, 90))

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(0, 82.2, 8)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Transparency = 0.4
	spawn.BrickColor = BrickColor.new("Bright blue")
	spawn.Parent = map

	-- Invisible landing reference far south
	local landing = part({
		name = "LandingZone",
		size = Vector3.new(80, 1, 20),
		cf = CFrame.new(0, 40, 220),
		color = Color3.fromRGB(80, 160, 90),
		transparency = 1,
		canCollide = false,
		parent = map,
	})
	CollectionService:AddTag(landing, "LandingZone")

	local origin = Instance.new("Attachment")
	origin.Name = "ThrowOrigin"
	origin.Position = Vector3.new(0, 2.2, 0)
	origin.Parent = pad

	World._lighting()
	map:SetAttribute("Built", true)
	return map
end

function World._enhance(map: Instance)
	if not map:FindFirstChild("ThrowPad") then
		return
	end
end

function World._lighting()
	Lighting.Brightness = 2.4
	Lighting.ClockTime = 15.2
	Lighting.GeographicLatitude = 22
	Lighting.Ambient = Color3.fromRGB(110, 120, 140)
	Lighting.OutdoorAmbient = Color3.fromRGB(140, 150, 170)
	Lighting.ShadowSoftness = 0.25
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.4
	pcall(function()
		Lighting.Technology = Enum.Technology.ShadowMap
	end)

	local function ensure(className: string, name: string): Instance
		local existing = Lighting:FindFirstChild(name)
		if existing then
			return existing
		end
		local inst = Instance.new(className)
		inst.Name = name
		inst.Parent = Lighting
		return inst
	end

	local atm = ensure("Atmosphere", "Atmosphere") :: Atmosphere
	atm.Density = 0.28
	atm.Offset = 0.2
	atm.Color = Color3.fromRGB(200, 220, 255)
	atm.Decay = Color3.fromRGB(160, 180, 220)
	atm.Glare = 0.15
	atm.Haze = 1.4

	local bloom = ensure("BloomEffect", "Bloom") :: BloomEffect
	bloom.Intensity = 0.35
	bloom.Size = 18
	bloom.Threshold = 0.9

	local rays = ensure("SunRaysEffect", "SunRays") :: SunRaysEffect
	rays.Intensity = 0.08
	rays.Spread = 0.4

	local cc = ensure("ColorCorrectionEffect", "ColorCorrection") :: ColorCorrectionEffect
	cc.Saturation = 0.12
	cc.Contrast = 0.06
	cc.Brightness = 0.02
end

function World.throwOrigin(): CFrame
	local pad = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ThrowPad")
	if pad and pad:IsA("BasePart") then
		return pad.CFrame * CFrame.new(0, 2.4, 0)
	end
	return CFrame.new(0, 84, 22)
end

function World.throwDirection(): Vector3
	return Vector3.new(0, 0.12, 1).Unit
end

function World.displayStands(): { BasePart }
	local map = workspace:FindFirstChild("Map")
	if not map then
		return {}
	end
	local folder = map:FindFirstChild("DisplayStands")
	if not folder then
		return {}
	end
	local stands = {}
	for _, child in folder:GetChildren() do
		if child:IsA("BasePart") then
			table.insert(stands, child)
		end
	end
	table.sort(stands, function(a, b)
		return (a:GetAttribute("Slot") or 0) < (b:GetAttribute("Slot") or 0)
	end)
	return stands
end

return World
