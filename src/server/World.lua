local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Numbers = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Numbers"))
local Products = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Products"))

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

local function billboard(adornee: BasePart, text: string, color: Color3, size: Vector2, offsetY: number?)
	local bb = Instance.new("BillboardGui")
	bb.Name = "Label"
	bb.Size = UDim2.fromOffset(size.X, size.Y)
	bb.StudsOffset = Vector3.new(0, (offsetY or (adornee.Size.Y / 2 + 2)), 0)
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
	return bb
end

local function clearMap(map: Instance)
	for _, child in map:GetChildren() do
		child:Destroy()
	end
end

function World.build()
	local workspace = game:GetService("Workspace")
	local map = workspace:FindFirstChild("Map")
	if map == nil then
		map = Instance.new("Model")
		map.Name = "Map"
		map.Parent = workspace
	end
	clearMap(map)

	-- Distant city
	for i = 1, 24 do
		local x = ((i % 8) - 3.5) * 48
		local z = 120 + math.floor((i - 1) / 8) * 70
		local h = 16 + (i * 17) % 50
		part({
			name = "Building" .. i,
			size = Vector3.new(26, h, 22),
			cf = CFrame.new(x, h / 2 - 4, z + 200),
			color = Color3.fromRGB(70 + (i * 13) % 40, 82, 105 + (i * 9) % 40),
			material = Enum.Material.Concrete,
			parent = map,
		})
	end

	-- Plaza
	part({
		name = "Plaza",
		size = Vector3.new(110, 2, 90),
		cf = CFrame.new(0, 3, 0),
		color = Color3.fromRGB(210, 198, 178),
		material = Enum.Material.Concrete,
		parent = map,
	})
	part({
		name = "PlazaRing",
		size = Vector3.new(114, 1, 94),
		cf = CFrame.new(0, 2.2, 0),
		color = Color3.fromRGB(160, 140, 120),
		parent = map,
	})

	local banner = part({
		name = "TitleBanner",
		size = Vector3.new(40, 6, 1),
		cf = CFrame.new(0, 16, -42),
		color = Color3.fromRGB(255, 250, 235),
		parent = map,
		canCollide = false,
	})
	billboard(banner, "PAPER PLANE TYCOON", Color3.fromRGB(40, 70, 120), Vector2.new(560, 90), 4)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(0, 4.6, 0)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Transparency = 0.35
	spawn.BrickColor = BrickColor.new("Bright blue")
	spawn.Parent = map

	-- Hallway +Z
	local hallLen = Numbers.HallwayLength
	local hallZ0 = 52
	local hallMid = hallZ0 + hallLen / 2
	part({
		name = "HallFloor",
		size = Vector3.new(36, 1.5, hallLen),
		cf = CFrame.new(0, 3.2, hallMid),
		color = Color3.fromRGB(186, 176, 160),
		material = Enum.Material.Concrete,
		parent = map,
	})
	part({
		name = "HallWallL",
		size = Vector3.new(2, 18, hallLen),
		cf = CFrame.new(-19, 12, hallMid),
		color = Color3.fromRGB(230, 220, 205),
		parent = map,
	})
	part({
		name = "HallWallR",
		size = Vector3.new(2, 18, hallLen),
		cf = CFrame.new(19, 12, hallMid),
		color = Color3.fromRGB(230, 220, 205),
		parent = map,
	})
	-- Open far end. Ceiling strips for "walled" feel without boxing long throws.
	local beamCount = math.max(1, math.floor(hallLen / 80))
	for i = 0, beamCount - 1 do
		part({
			name = "HallBeam" .. i,
			size = Vector3.new(40, 1.2, 8),
			cf = CFrame.new(0, 21, hallZ0 + 40 + i * 80),
			color = Color3.fromRGB(200, 170, 140),
			parent = map,
		})
	end

	local markers = { 50, 100, 250, 500, 1000 }
	for _, studs in markers do
		local z = hallZ0 + studs
		local stripe = part({
			name = "Marker" .. studs,
			size = Vector3.new(34, 0.4, 1.4),
			cf = CFrame.new(0, 4.1, z),
			color = Color3.fromRGB(255, 230, 80),
			material = Enum.Material.Neon,
			parent = map,
			canCollide = false,
		})
		billboard(stripe, tostring(studs), Color3.fromRGB(255, 255, 200), Vector2.new(120, 40), 6)
	end

	local pads = Instance.new("Folder")
	pads.Name = "ThrowPads"
	pads.Parent = map
	for i = 1, 6 do
		local x = (i - 3.5) * 5.2
		local pad = part({
			name = "ThrowPad" .. i,
			size = Vector3.new(4.6, 1.1, 6),
			cf = CFrame.new(x, 4.4, 48),
			color = Color3.fromRGB(70, 160, 230),
			material = Enum.Material.Neon,
			parent = pads,
		})
		pad:SetAttribute("PadIndex", i)
		CollectionService:AddTag(pad, "ThrowPad")
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Throw"
		prompt.ObjectText = "Paper Plane"
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = pad
		if i == 3 or i == 4 then
			billboard(pad, "THROW", Color3.fromRGB(255, 255, 255), Vector2.new(160, 48), 3)
		end
	end

	-- Hangar plots in a ring around the plaza, leaving the +Z hallway open
	local plots = Instance.new("Folder")
	plots.Name = "Plots"
	plots.Parent = map
	local plotCFs = {}
	local radius = 78
	for i = 1, Numbers.PlotCount do
		local deg = 25 + ((i - 1) / math.max(1, Numbers.PlotCount - 1)) * 310
		local rad = math.rad(deg)
		local pos = Vector3.new(math.sin(rad) * radius, 4, math.cos(rad) * radius)
		local lookAway = pos + Vector3.new(pos.X, 0, pos.Z)
		local cf = CFrame.lookAt(pos, Vector3.new(lookAway.X, 4, lookAway.Z))
		table.insert(plotCFs, cf)
	end

	for i, cf in plotCFs do
		local plot = Instance.new("Model")
		plot.Name = "Plot" .. i
		plot:SetAttribute("PlotIndex", i)
		plot.Parent = plots

		local floor = part({
			name = "Floor",
			size = Vector3.new(18, 1, 16),
			cf = cf,
			color = Color3.fromRGB(150, 110, 75),
			material = Enum.Material.Wood,
			parent = plot,
		})
		plot.PrimaryPart = floor
		part({
			name = "Back",
			size = Vector3.new(18, 10, 1),
			cf = cf * CFrame.new(0, 5.5, -8),
			color = Color3.fromRGB(200, 130, 80),
			parent = plot,
		})
		part({
			name = "Left",
			size = Vector3.new(1, 10, 16),
			cf = cf * CFrame.new(-8.5, 5.5, 0),
			color = Color3.fromRGB(190, 120, 75),
			parent = plot,
		})
		part({
			name = "Right",
			size = Vector3.new(1, 10, 16),
			cf = cf * CFrame.new(8.5, 5.5, 0),
			color = Color3.fromRGB(190, 120, 75),
			parent = plot,
		})
		part({
			name = "Roof",
			size = Vector3.new(19, 1, 17),
			cf = cf * CFrame.new(0, 11, 0),
			color = Color3.fromRGB(170, 80, 50),
			parent = plot,
		})

		local stands = Instance.new("Folder")
		stands.Name = "Stands"
		stands.Parent = plot
		local pedestal = part({
			name = "Pedestal",
			size = Vector3.new(3.4, 2.2, 3.4),
			cf = cf * CFrame.new(0, 1.6, 2),
			color = Color3.fromRGB(110, 80, 50),
			material = Enum.Material.Wood,
			parent = stands,
		})
		pedestal:SetAttribute("Slot", 1)
		CollectionService:AddTag(pedestal, "DisplayStand")
		for s = 2, 6 do
			local col = (s - 2) % 3
			local row = math.floor((s - 2) / 3)
			local stand = part({
				name = "Stand" .. s,
				size = Vector3.new(2.4, 1.4, 2.4),
				cf = cf * CFrame.new(-5 + col * 5, 1.2, -3 - row * 4),
				color = Color3.fromRGB(120, 90, 60),
				material = Enum.Material.Wood,
				parent = stands,
			})
			stand:SetAttribute("Slot", s)
			CollectionService:AddTag(stand, "DisplayStand")
		end

		local sign = part({
			name = "Sign",
			size = Vector3.new(10, 2, 0.4),
			cf = cf * CFrame.new(0, 9.2, 8.2),
			color = Color3.fromRGB(245, 230, 200),
			parent = plot,
			canCollide = false,
		})
		local bb = billboard(sign, "EMPTY HANGAR", Color3.fromRGB(90, 50, 30), Vector2.new(240, 56), 1)
		bb.Name = "OwnerLabel"
	end

	-- Benches (east of plaza, before hallway)
	local benches = Instance.new("Folder")
	benches.Name = "Benches"
	benches.Parent = map
	local benchDefs = {
		{ id = "Free", name = "FREE", color = Color3.fromRGB(180, 180, 170) },
		{ id = "Bronze", name = "BRONZE", color = Color3.fromRGB(186, 110, 60) },
		{ id = "Silver", name = "SILVER", color = Color3.fromRGB(190, 200, 210) },
		{ id = "Gold", name = "GOLD", color = Color3.fromRGB(232, 186, 64) },
		{ id = "Diamond", name = "DIAMOND", color = Color3.fromRGB(120, 220, 255) },
	}
	for i, def in benchDefs do
		local z = 8 + (i - 1) * 8
		local base = part({
			name = def.id .. "Base",
			size = Vector3.new(8, 1, 6),
			cf = CFrame.new(40, 4.1, z),
			color = def.color,
			parent = benches,
		})
		local seat = Instance.new("Seat")
		seat.Name = def.id .. "Seat"
		seat.Anchored = true
		seat.Size = Vector3.new(4, 1, 3)
		seat.CFrame = CFrame.new(40, 5.1, z) * CFrame.Angles(0, math.rad(-90), 0)
		seat.Color = def.color:Lerp(Color3.new(0, 0, 0), 0.15)
		seat.Material = Enum.Material.SmoothPlastic
		seat:SetAttribute("BenchId", def.id)
		seat.Parent = benches
		CollectionService:AddTag(seat, "StrengthBench")
		local caption = def.name .. " BENCH"
		if def.id ~= "Free" then
			local pass = Products.GamepassByKey["Bench" .. def.id]
			if pass then
				caption = def.name .. "  ~R$" .. tostring(pass.priceHint)
			end
		end
		billboard(base, caption, Color3.new(1, 1, 1), Vector2.new(220, 48), 5)
	end

	-- Kiosks
	local crateKiosk = part({
		name = "CrateKiosk",
		size = Vector3.new(10, 8, 8),
		cf = CFrame.new(-40, 8, 18),
		color = Color3.fromRGB(255, 200, 70),
		parent = map,
	})
	CollectionService:AddTag(crateKiosk, "CrateKiosk")
	billboard(crateKiosk, "CRATES", Color3.fromRGB(255, 240, 180), Vector2.new(200, 56), 6)
	local cratePrompt = Instance.new("ProximityPrompt")
	cratePrompt.ActionText = "Open"
	cratePrompt.ObjectText = "Crates"
	cratePrompt.HoldDuration = 0
	cratePrompt.Parent = crateKiosk

	local shopKiosk = part({
		name = "ShopKiosk",
		size = Vector3.new(10, 8, 8),
		cf = CFrame.new(-40, 8, 2),
		color = Color3.fromRGB(80, 180, 120),
		parent = map,
	})
	CollectionService:AddTag(shopKiosk, "ShopKiosk")
	billboard(shopKiosk, "ROTATING SHOP", Color3.fromRGB(200, 255, 210), Vector2.new(240, 56), 6)
	local shopPrompt = Instance.new("ProximityPrompt")
	shopPrompt.ActionText = "Browse"
	shopPrompt.ObjectText = "Shop"
	shopPrompt.HoldDuration = 0
	shopPrompt.Parent = shopKiosk

	World._lighting()
	map:SetAttribute("Built", true)
	map:SetAttribute("Layout", "HubHallway")
	return map
end

function World._lighting()
	Lighting.Brightness = 2.6
	Lighting.ClockTime = 14.5
	Lighting.GeographicLatitude = 18
	Lighting.Ambient = Color3.fromRGB(110, 120, 140)
	Lighting.OutdoorAmbient = Color3.fromRGB(145, 155, 170)
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
	atm.Density = 0.26
	atm.Offset = 0.18
	atm.Color = Color3.fromRGB(200, 220, 255)
	atm.Decay = Color3.fromRGB(160, 180, 220)
	atm.Glare = 0.12
	atm.Haze = 1.2

	local bloom = ensure("BloomEffect", "Bloom") :: BloomEffect
	bloom.Intensity = 0.32
	bloom.Size = 16
	bloom.Threshold = 0.92
end

function World.map(): Instance?
	return workspace:FindFirstChild("Map")
end

function World.throwPads(): { BasePart }
	local map = World.map()
	local folder = map and map:FindFirstChild("ThrowPads")
	if not folder then
		return {}
	end
	local pads = {}
	for _, child in folder:GetChildren() do
		if child:IsA("BasePart") then
			table.insert(pads, child)
		end
	end
	return pads
end

function World.nearestThrowPad(player: Player): BasePart?
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp or not hrp:IsA("BasePart") then
		return nil
	end
	local best: BasePart? = nil
	local bestD = Numbers.ThrowPadRange
	for _, pad in World.throwPads() do
		local d = (pad.Position - hrp.Position).Magnitude
		if d < bestD then
			bestD = d
			best = pad
		end
	end
	return best
end

function World.throwOriginFor(player: Player): CFrame?
	local pad = World.nearestThrowPad(player)
	if not pad then
		return nil
	end
	return pad.CFrame * CFrame.new(0, 2.2, 1.5)
end

function World.throwDirection(): Vector3
	return Vector3.new(0, 0.04, 1).Unit
end

function World.plotModels(): { Model }
	local map = World.map()
	local folder = map and map:FindFirstChild("Plots")
	if not folder then
		return {}
	end
	local plots = {}
	for _, child in folder:GetChildren() do
		if child:IsA("Model") then
			table.insert(plots, child)
		end
	end
	table.sort(plots, function(a, b)
		return (a:GetAttribute("PlotIndex") or 0) < (b:GetAttribute("PlotIndex") or 0)
	end)
	return plots
end

function World.benchSeats(): { Seat }
	local map = World.map()
	local folder = map and map:FindFirstChild("Benches")
	if not folder then
		return {}
	end
	local seats = {}
	for _, child in folder:GetChildren() do
		if child:IsA("Seat") then
			table.insert(seats, child)
		end
	end
	return seats
end

return World
