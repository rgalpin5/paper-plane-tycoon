local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EVENTS = {
	"Throw",
	"BuyUpgrade",
	"BuyHangarUpgrade",
	"BuyPlayerUpgrade",
	"EquipPlane",
	"UnequipPlane",
	"OpenCrate",
	"ClaimDaily",
	"Rebirth",
	"RedeemCode",
	"BuyGuaranteedPlane",
	"BuyCosmetic",
	"EquipCosmetic",
	"UnequipCosmetic",
	"ProfileUpdated",
	"ThrowResult",
	"CrateOpened",
	"OfflineEarnings",
	"DailyClaimed",
	"Announcement",
	"Notify",
	"Tutorial",
	"PlotAssigned",
}

local FUNCTIONS = {
	"GetSnapshot",
	"GetCrateOdds",
	"GetRebirthPreview",
	"GetPolicy",
	"GetRotationShop",
}

local folder: Folder
if RunService:IsServer() then
	folder = ReplicatedStorage:FindFirstChild("Remotes") :: Folder
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
else
	folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
end

local function get(name: string, className: string): Instance
	if RunService:IsServer() then
		local existing = folder:FindFirstChild(name)
		if existing then
			return existing
		end
		local created = Instance.new(className)
		created.Name = name
		created.Parent = folder
		return created
	end
	return folder:WaitForChild(name)
end

local Remotes = {
	Folder = folder,
}

for _, name in EVENTS do
	Remotes[name] = get(name, "RemoteEvent") :: RemoteEvent
end

for _, name in FUNCTIONS do
	Remotes[name] = get(name, "RemoteFunction") :: RemoteFunction
end

return Remotes
