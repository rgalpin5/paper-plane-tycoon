local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaneFactory = require(ReplicatedStorage.Shared.PlaneFactory)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Data = require(script.Parent.Data)
local Monetization = require(script.Parent.Monetization)
local Stats = require(script.Parent.Parent.Lib.Stats)
local World = require(script.Parent.Parent.World)

local Plots = {}
local ownerOf: { [number]: Player } = {}
local plotOf: { [Player]: number } = {}
local displayed: { [number]: { Model } } = {}

local function setSign(plot: Model, text: string)
	local sign = plot:FindFirstChild("Sign")
	if not sign then
		return
	end
	local bb = sign:FindFirstChild("OwnerLabel")
	local label = bb and bb:FindFirstChildWhichIsA("TextLabel")
	if label then
		label.Text = text
	end
end

local function clearDisplay(index: number)
	if displayed[index] then
		for _, m in displayed[index] do
			m:Destroy()
		end
	end
	displayed[index] = {}
end

function Plots.refresh(player: Player)
	local index = plotOf[player]
	if not index then
		return
	end
	local plot = World.plotModels()[index]
	if not plot then
		return
	end
	local data = Data.get(player)
	if not data then
		return
	end
	clearDisplay(index)
	setSign(plot, player.DisplayName)
	local flags = Monetization.flags(player)
	local ids = Stats.displayPlaneIds(data, flags)
	local standsFolder = plot:FindFirstChild("Stands")
	if not standsFolder then
		return
	end
	local stands = {}
	for _, child in standsFolder:GetChildren() do
		if child:IsA("BasePart") then
			table.insert(stands, child)
		end
	end
	table.sort(stands, function(a, b)
		return (a:GetAttribute("Slot") or 0) < (b:GetAttribute("Slot") or 0)
	end)
	for i, planeId in ids do
		local stand = stands[i]
		if stand then
			local model = PlaneFactory.create(planeId)
			if i == 1 then
				PlaneFactory.applyCosmetics(model, data.cosmeticsEquipped)
			end
			model.Parent = plot
			model:PivotTo(stand.CFrame * CFrame.new(0, 2.2, 0) * CFrame.Angles(0, math.rad(20), math.rad(-8)))
			table.insert(displayed[index], model)
		end
	end
end

function Plots.assign(player: Player)
	if plotOf[player] then
		Plots.refresh(player)
		return
	end
	local models = World.plotModels()
	for i = 1, #models do
		if ownerOf[i] == nil then
			ownerOf[i] = player
			plotOf[player] = i
			Plots.refresh(player)
			Remotes.PlotAssigned:FireClient(player, i)
			return
		end
	end
	Remotes.PlotAssigned:FireClient(player, 0)
end

function Plots.release(player: Player)
	local index = plotOf[player]
	if not index then
		return
	end
	clearDisplay(index)
	local plot = World.plotModels()[index]
	if plot then
		setSign(plot, "EMPTY HANGAR")
	end
	ownerOf[index] = nil
	plotOf[player] = nil
end

function Plots.start()
	Data.ProfileLoaded:Connect(function(player)
		Plots.assign(player)
	end)
	Data.Changed:Connect(function(player)
		if plotOf[player] then
			Plots.refresh(player)
		end
	end)
	Players.PlayerRemoving:Connect(Plots.release)
end

return Plots
