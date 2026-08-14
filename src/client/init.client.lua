local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Format = require(ReplicatedStorage.Shared.Format)
local Rarities = Config.Rarities

local State = require(script.State)
local HUD = require(script.UI.HUD)
local Toast = require(script.UI.Toast)
local UpgradesUI = require(script.UI.Upgrades)
local HangarUI = require(script.UI.Hangar)
local IndexUI = require(script.UI.Index)
local CratesUI = require(script.UI.Crates)
local ShopUI = require(script.UI.Shop)
local DailyUI = require(script.UI.Daily)
local RebirthUI = require(script.UI.Rebirth)
local Tutorial = require(script.UI.Tutorial)
local Offline = require(script.UI.Offline)
local Camera = require(script.Controllers.Camera)
local FX = require(script.Controllers.FX)
local CrateAnim = require(script.Controllers.CrateAnim)

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
end)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "PaperPlaneTycoon"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

Toast.mount(gui)
HUD.mount(gui)
UpgradesUI.mount(gui)
HangarUI.mount(gui)
IndexUI.mount(gui)
CratesUI.mount(gui)
ShopUI.mount(gui)
DailyUI.mount(gui)
RebirthUI.mount(gui)
Tutorial.mount(gui)
Offline.mount(gui)

local snap = Remotes.GetSnapshot:InvokeServer()
if snap then
	State.set(snap)
end

Remotes.ProfileUpdated.OnClientEvent:Connect(function(payload)
	State.set(payload)
end)

Remotes.ThrowResult.OnClientEvent:Connect(function(result)
	if typeof(result) ~= "table" then
		return
	end
	if result.index == 1 then
		FX.whoosh()
		Camera.follow(result.origin, result.landing, result.duration)
	end
	FX.coins(result.origin, result.coins)
	task.delay(result.duration, function()
		FX.land()
		FX.burst(result.landing, Color3.fromRGB(255, 220, 120))
		if typeof(result.distance) == "number" then
			FX.popup(result.landing, Format.abbrev(result.distance) .. " studs", Color3.fromRGB(255, 255, 200))
		end
	end)
end)

Remotes.CrateOpened.OnClientEvent:Connect(function(result)
	if typeof(result) == "table" then
		CrateAnim.play(gui, result)
	end
end)

Remotes.Notify.OnClientEvent:Connect(function(message, kind)
	Toast.show(tostring(message), kind)
end)

Remotes.Announcement.OnClientEvent:Connect(function(message, rarity)
	Toast.show(tostring(message), "success")
	FX.shake(0.55, 0.4)
	FX.crateSlam(Rarities.color(rarity or "Mythic"))
end)

Remotes.PlotAssigned.OnClientEvent:Connect(function(plot)
	if plot == 0 then
		Toast.show("Hangar UI-only — server full", "info")
	else
		Toast.show("Hangar plot claimed", "success")
	end
end)

local function wireKiosk(tag: string, pageName: string)
	local hooked: { [Instance]: boolean } = {}
	local function hook(inst: Instance)
		if hooked[inst] then
			return
		end
		hooked[inst] = true
		local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt")
		if not prompt then
			prompt = inst:WaitForChild("ProximityPrompt", 8)
		end
		if prompt and prompt:IsA("ProximityPrompt") then
			prompt.Triggered:Connect(function()
				HUD.open(pageName)
			end)
		end
	end
	for _, inst in CollectionService:GetTagged(tag) do
		task.spawn(hook, inst)
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
		task.spawn(hook, inst)
	end)
end

wireKiosk("CrateKiosk", "Crates")
wireKiosk("ShopKiosk", "Shop")

pcall(function()
	TextChatService.OnIncomingMessage = function(message)
		local props = Instance.new("TextChatMessageProperties")
		local textSource = message.TextSource
		if textSource then
			local plr = Players:GetPlayerByUserId(textSource.UserId)
			if plr and plr:GetAttribute("VIP") then
				props.PrefixText = "<font color='#e8ba36'>[VIP]</font> " .. (message.PrefixText or "")
			end
		end
		return props
	end
end)

print("[Paper Plane Tycoon] Client ready.")
