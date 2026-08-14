export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Secret"

export type TutorialFlags = {
	thrown: boolean,
	upgraded: boolean,
	thrownAfter: boolean,
	complete: boolean,
}

export type PityState = {
	legendary: number,
	mythic: number,
}

export type BoostState = {
	doubleCoinsUntil: number,
}

export type CrateKeys = {
	Paper: number,
	Hangar: number,
	Golden: number,
}

export type PlayerStats = {
	totalCoinsEarned: number,
	bestDistance: number,
	cratesOpened: number,
}

export type PlayerData = {
	coins: number,
	scrap: number,
	upgrades: { [string]: number },
	hangarUpgrades: { [string]: number },
	ownedPlanes: { [string]: number },
	equipped: { string },
	streak: number,
	lastDailyClaimDay: number,
	lastDailyCrateDay: number,
	lastVipCrateDay: number,
	rebirths: number,
	pity: PityState,
	processedPurchases: { [string]: boolean },
	purchaseOrder: { string },
	lastLogout: number,
	tutorial: TutorialFlags,
	boosts: BoostState,
	crateKeys: CrateKeys,
	streakShields: number,
	codesRedeemed: { [string]: boolean },
	totalThrows: number,
	lastThrowAt: number,
	combo: number,
	luckyRolls: number,
	stats: PlayerStats,
}

export type Computed = {
	coinMultiplier: number,
	luckMultiplier: number,
	throwCooldown: number,
	autoThrow: boolean,
	skipAnim: boolean,
	equipSlots: number,
	offlineHours: number,
	idlePerMinute: number,
	restrictedPaidRandom: boolean,
	vip: boolean,
	magnet: boolean,
	rainbowTrail: boolean,
	multiThrow: boolean,
	boostRemaining: number,
	capacity: number,
	planeMultiplier: number,
	rebirthMultiplier: number,
}

export type Snapshot = {
	data: PlayerData,
	computed: Computed,
}

export type ThrowResult = {
	distance: number,
	coins: number,
	combo: number,
	origin: Vector3,
	landing: Vector3,
	planeId: string,
	duration: number,
	rainbow: boolean,
	index: number,
	total: number,
}

export type CrateResult = {
	crateId: string,
	planeId: string,
	duplicate: boolean,
	scrap: number,
	rarity: string,
	pity: PityState,
	skipped: boolean,
}

return {}
