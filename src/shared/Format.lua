local Format = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc" }

function Format.abbrev(n: number): string
	if n ~= n or n == math.huge or n == -math.huge then
		return "0"
	end
	local sign = if n < 0 then "-" else ""
	n = math.abs(n)
	if n < 1000 then
		if n % 1 == 0 then
			return sign .. tostring(n)
		end
		return sign .. string.format("%.1f", n)
	end
	local exp = math.min(math.floor(math.log(n) / math.log(1000)), #SUFFIXES - 1)
	local value = n / (1000 ^ exp)
	local text = if value >= 100 then string.format("%.0f", value)
		elseif value >= 10 then string.format("%.1f", value)
		else string.format("%.2f", value)
	text = string.gsub(text, "%.?0+$", "")
	return sign .. text .. SUFFIXES[exp + 1]
end

function Format.coins(n: number): string
	return Format.abbrev(n)
end

function Format.percent(n: number, digits: number?): string
	local d = digits or 2
	return string.format("%." .. d .. "f%%", n)
end

function Format.time(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%d:%02d:%02d", h, m, s)
	end
	return string.format("%d:%02d", m, s)
end

function Format.oddsLine(chance: number): string
	if chance >= 10 then
		return string.format("%.1f%%", chance)
	elseif chance >= 1 then
		return string.format("%.2f%%", chance)
	elseif chance >= 0.01 then
		return string.format("%.3f%%", chance)
	else
		return string.format("%.4f%%", chance)
	end
end

return Format
