export type PlaneDef = {
	id: string,
	name: string,
	rarity: string,
	multiplier: number,
	color: Color3,
	trailColor: Color3,
	size: number,
	secret: boolean?,
}

local function plane(
	id: string,
	name: string,
	rarity: string,
	multiplier: number,
	color: Color3,
	trail: Color3?,
	size: number?
): PlaneDef
	return {
		id = id,
		name = name,
		rarity = rarity,
		multiplier = multiplier,
		color = color,
		trailColor = trail or color,
		size = size or 1,
	}
end

local list: { PlaneDef } = {
	plane("FoldedNote", "Folded Note", "Common", 1.00, Color3.fromRGB(245, 240, 225), Color3.fromRGB(255, 255, 255), 1),
	plane("ClassroomDart", "Classroom Dart", "Common", 1.12, Color3.fromRGB(230, 230, 235), Color3.fromRGB(200, 210, 230), 1),
	plane("RecycledFlyer", "Recycled Flyer", "Common", 1.20, Color3.fromRGB(176, 196, 148), Color3.fromRGB(160, 190, 130), 1),
	plane("OfficeMemo", "Office Memo", "Common", 1.28, Color3.fromRGB(232, 220, 190), Color3.fromRGB(255, 230, 170), 1),
	plane("NapkinGlider", "Napkin Glider", "Common", 1.35, Color3.fromRGB(250, 248, 240), Color3.fromRGB(255, 255, 245), 0.95),
	plane("GraphPaper", "Graph Paper", "Common", 1.42, Color3.fromRGB(210, 225, 240), Color3.fromRGB(120, 160, 220), 1),

	plane("OrigamiCrane", "Origami Crane", "Uncommon", 1.70, Color3.fromRGB(120, 200, 140), Color3.fromRGB(80, 255, 140), 1.05),
	plane("HomeworkAce", "Homework Ace", "Uncommon", 1.85, Color3.fromRGB(255, 214, 90), Color3.fromRGB(255, 230, 120), 1.05),
	plane("ReceiptRocket", "Receipt Rocket", "Uncommon", 1.95, Color3.fromRGB(245, 230, 200), Color3.fromRGB(255, 180, 80), 0.9),
	plane("MagazineWing", "Magazine Wing", "Uncommon", 2.10, Color3.fromRGB(220, 80, 110), Color3.fromRGB(255, 90, 140), 1.1),
	plane("StickyNoteStreak", "Sticky Note Streak", "Uncommon", 2.20, Color3.fromRGB(255, 236, 80), Color3.fromRGB(255, 255, 60), 0.9),

	plane("BlueprintBomber", "Blueprint Bomber", "Rare", 2.70, Color3.fromRGB(50, 110, 210), Color3.fromRGB(80, 180, 255), 1.15),
	plane("TicketStub", "Ticket Stub", "Rare", 2.95, Color3.fromRGB(255, 90, 90), Color3.fromRGB(255, 140, 80), 1.05),
	plane("PostcardExpress", "Postcard Express", "Rare", 3.15, Color3.fromRGB(255, 170, 90), Color3.fromRGB(255, 210, 130), 1.1),
	plane("NewsprintNighthawk", "Newsprint Nighthawk", "Rare", 3.35, Color3.fromRGB(40, 40, 48), Color3.fromRGB(180, 180, 200), 1.2),
	plane("WatercolorWisp", "Watercolor Wisp", "Rare", 3.50, Color3.fromRGB(120, 190, 255), Color3.fromRGB(180, 120, 255), 1.1),

	plane("GoldFoilFalcon", "Gold Foil Falcon", "Epic", 4.40, Color3.fromRGB(232, 186, 64), Color3.fromRGB(255, 220, 80), 1.2),
	plane("NeonOrigami", "Neon Origami", "Epic", 4.90, Color3.fromRGB(40, 255, 200), Color3.fromRGB(255, 40, 220), 1.15),
	plane("CarbonCrease", "Carbon Crease", "Epic", 5.40, Color3.fromRGB(32, 36, 42), Color3.fromRGB(90, 220, 255), 1.25),
	plane("SilkDart", "Silk Dart", "Epic", 5.90, Color3.fromRGB(210, 140, 255), Color3.fromRGB(255, 180, 255), 1.1),

	plane("PaperPhoenix", "Paper Phoenix", "Legendary", 8.50, Color3.fromRGB(255, 110, 50), Color3.fromRGB(255, 200, 40), 1.35),
	plane("StormKite", "Storm Kite", "Legendary", 9.40, Color3.fromRGB(70, 90, 180), Color3.fromRGB(160, 200, 255), 1.4),
	plane("AuroraFold", "Aurora Fold", "Legendary", 10.50, Color3.fromRGB(80, 255, 190), Color3.fromRGB(180, 120, 255), 1.3),
	plane("TitanOrigami", "Titan Origami", "Legendary", 11.80, Color3.fromRGB(200, 210, 220), Color3.fromRGB(255, 255, 255), 1.5),

	plane("MythicPaperPhoenix", "Mythic Paper Phoenix", "Mythic", 18.00, Color3.fromRGB(255, 50, 80), Color3.fromRGB(255, 180, 40), 1.55),
	plane("CelestialDart", "Celestial Dart", "Mythic", 21.00, Color3.fromRGB(60, 80, 180), Color3.fromRGB(255, 240, 160), 1.5),
	plane("VoidOrigami", "Void Origami", "Mythic", 24.50, Color3.fromRGB(20, 10, 40), Color3.fromRGB(160, 60, 255), 1.45),

	plane("DirectorsCut", "Director's Cut", "Secret", 40.00, Color3.fromRGB(20, 20, 20), Color3.fromRGB(255, 255, 255), 1.6),
	plane("MillionthFold", "Millionth Fold", "Secret", 48.00, Color3.fromRGB(255, 248, 220), Color3.fromRGB(255, 215, 80), 1.5),
	plane("PaperDragonEmperor", "Paper Dragon Emperor", "Secret", 60.00, Color3.fromRGB(180, 30, 40), Color3.fromRGB(255, 160, 40), 1.8),
}

local byId: { [string]: PlaneDef } = {}
for _, def in list do
	byId[def.id] = def
end

local Planes = {
	List = list,
	ById = byId,
	StarterId = "FoldedNote",
	MythicStarterId = "MythicPaperPhoenix",
}

function Planes.get(id: string): PlaneDef?
	return byId[id]
end

function Planes.idsOfRarity(rarity: string): { string }
	local ids = {}
	for _, def in list do
		if def.rarity == rarity then
			table.insert(ids, def.id)
		end
	end
	return ids
end

function Planes.count(): number
	return #list
end

return Planes
