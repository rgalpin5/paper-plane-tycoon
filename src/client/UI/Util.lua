local Theme = require(script.Parent.Theme)

local Util = {}

function Util.corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

function Util.stroke(parent: Instance, thickness: number, transparency: number?)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Color = Theme.Stroke
	s.Transparency = transparency or 0.75
	s.Parent = parent
	return s
end

function Util.pad(parent: Instance, px: number)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, px)
	p.PaddingBottom = UDim.new(0, px)
	p.PaddingLeft = UDim.new(0, px)
	p.PaddingRight = UDim.new(0, px)
	p.Parent = parent
	return p
end

function Util.label(props): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = props.bg and 0 or 1
	l.BackgroundColor3 = props.bg or Theme.Panel
	l.Text = props.text or ""
	l.TextColor3 = props.color or Theme.Paper
	l.Font = props.font or Theme.Fonts.Body
	l.TextScaled = props.scaled ~= false
	l.TextXAlignment = props.align or Enum.TextXAlignment.Left
	l.TextYAlignment = props.valign or Enum.TextYAlignment.Center
	l.Size = props.size or UDim2.fromScale(1, 1)
	l.Position = props.pos or UDim2.fromScale(0, 0)
	l.AnchorPoint = props.anchor or Vector2.new(0, 0)
	l.TextTruncate = props.truncate or Enum.TextTruncate.None
	l.ZIndex = props.z or 1
	l.Parent = props.parent
	if props.auto then
		l.AutomaticSize = props.auto
		l.TextScaled = false
		l.TextSize = props.textSize or 18
	end
	return l
end

function Util.button(props): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true
	b.BackgroundColor3 = props.bg or Theme.Accent
	b.Text = props.text or ""
	b.TextColor3 = props.color or Color3.new(1, 1, 1)
	b.Font = props.font or Theme.Fonts.Title
	b.TextScaled = true
	b.Size = props.size or UDim2.fromOffset(160, 48)
	b.Position = props.pos or UDim2.fromScale(0, 0)
	b.AnchorPoint = props.anchor or Vector2.new(0, 0)
	b.ZIndex = props.z or 2
	b.Parent = props.parent
	Util.corner(b, props.radius or 14)
	Util.stroke(b, 1.5, 0.65)
	return b
end

function Util.panel(props): Frame
	local f = Instance.new("Frame")
	f.BackgroundColor3 = props.bg or Theme.Panel
	f.BackgroundTransparency = props.trans or 0.08
	f.Size = props.size or UDim2.fromScale(1, 1)
	f.Position = props.pos or UDim2.fromScale(0, 0)
	f.AnchorPoint = props.anchor or Vector2.new(0, 0)
	f.ZIndex = props.z or 1
	f.Parent = props.parent
	Util.corner(f, props.radius or 16)
	Util.stroke(f, 1.2, 0.7)
	return f
end

function Util.list(parent: Instance, padding: number)
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, padding or 8)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

function Util.scroll(parent: Instance, size: UDim2): ScrollingFrame
	local s = Instance.new("ScrollingFrame")
	s.BackgroundTransparency = 1
	s.BorderSizePixel = 0
	s.Size = size
	s.CanvasSize = UDim2.fromOffset(0, 0)
	s.AutomaticCanvasSize = Enum.AutomaticSize.Y
	s.ScrollBarThickness = 6
	s.Parent = parent
	return s
end

function Util.clear(parent: Instance)
	for _, child in parent:GetChildren() do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and not child:IsA("UICorner") then
			child:Destroy()
		end
	end
end

return Util
