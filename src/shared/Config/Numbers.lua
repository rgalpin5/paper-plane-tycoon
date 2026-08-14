local Numbers = {
	StarterCoins = 0,
	StarterStrength = 10,

	BaseDistance = 48,
	StrengthDistanceScale = 11,
	StrengthDistancePower = 0.44,
	BaseCoinsPerStud = 1.25,
	PlaneLevelDistance = 0.03,

	EarlyThrowBonusThrows = 5,
	EarlyThrowMultiplier = 3,
	TutorialFirstThrowCoins = 280,

	ThrowCooldown = 0.95,
	ThrowStrengthGain = 2.2,
	StrengthGainPerLevel = 0.04,

	BenchTick = 0.5,
	BenchStrengthPerSecond = 10,
	Benches = {
		{ id = "Free", name = "Free Bench", multi = 1, passKey = nil, color = Color3.fromRGB(180, 180, 170) },
		{ id = "Bronze", name = "Bronze Bench", multi = 2, passKey = "BenchBronze", color = Color3.fromRGB(186, 110, 60) },
		{ id = "Silver", name = "Silver Bench", multi = 5, passKey = "BenchSilver", color = Color3.fromRGB(190, 200, 210) },
		{ id = "Gold", name = "Gold Bench", multi = 12, passKey = "BenchGold", color = Color3.fromRGB(232, 186, 64) },
		{ id = "Diamond", name = "Diamond Bench", multi = 30, passKey = "BenchDiamond", color = Color3.fromRGB(120, 220, 255) },
	},

	OfflineHoursFree = 2,
	OfflineHoursVIP = 8,
	IdleBasePerMinute = 10,
	IdlePerLevel = 7,
	IdleOwnedBonus = 0.035,
	HangarBaseStorage = 8,
	HangarStoragePerLevel = 2,
	HangarStoragePlusBonus = 20,
	HangarBaseStands = 1,
	HangarStandsPerFiveLevels = 1,
	HangarMaxStands = 6,

	BasePlanesPerThrow = 1,
	MultiPlanePerLevel = 1,
	MaxMultiPlaneUpgrade = 4,
	ExtraPlaneThrowBonus = 1,
	VolleyStagger = 0.15,
	MaxRenderedFlights = 8,

	BaseCosmeticSlots = 3,
	ExtraCosmeticSlots = 2,

	LuckPerLevel = 0.04,
	LuckPassMultiplier = 2,

	RebirthBaseCost = 1_000_000,
	RebirthCostScale = 1.55,
	RebirthCoinBonus = 0.25,
	RebirthStrengthBonus = 0.25,

	PityLegendary = 50,
	PityMythic = 200,

	VIPCoinMultiplier = 1.15,
	BoostDuration = 30 * 60,
	BoostMultiplier = 2,

	RotationSeconds = 4 * 3600,
	RotationOffers = 3,

	ThrowPadRange = 14,
	HallwayLength = 1100,
	FlightSpeed = 110,
	ArcHeight = 14,

	GuaranteedPrices = {
		Common = 4000,
		Uncommon = 18000,
		Rare = 75000,
		Epic = 320000,
		Legendary = 1_800_000,
		Mythic = 12_000_000,
	},

	DailyRewards = { 500, 1500, 4000, 9000, 18000, 35000, 80000 },
	DailyBoostMinutes = { 0, 0, 15, 0, 0, 30, 0 },
	PlotCount = 12,
}

return Numbers
