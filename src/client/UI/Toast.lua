local Theme = require(script.Parent.Theme)
local Util = require(script.Parent.Util)

local Toast = {}
local host: Frame?

function Toast.mount(gui: ScreenGui)
	host = Instance.new("Frame")
	host.Name = "Toasts"
	host.BackgroundTransparency = 1
	host.Size = UDim2.new(1, 0, 0, 200)
	host.Position = UDim2.new(0.5, 0, 0, 90)
	host.AnchorPoint = Vector2.new(0.5, 0)
	host.ZIndex = 50
	host.Parent = gui
	local list = Util.list(host, 8)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
end

function Toast.show(message: string, kind: string?)
	if not host then
		return
	end
	local color = Theme.Sky
	if kind == "success" then
		color = Theme.Green
	elseif kind == "error" then
		color = Theme.Danger
	end
	local row = Util.panel({
		parent = host,
		size = UDim2.fromOffset(320, 44),
		bg = color,
		trans = 0.1,
		radius = 12,
		z = 50,
	})
	Util.label({
		parent = row,
		text = message,
		align = Enum.TextXAlignment.Center,
		color = Color3.new(1, 1, 1),
		font = Theme.Fonts.Title,
	})
	task.delay(2.4, function()
		row:Destroy()
	end)
end

return Toast
