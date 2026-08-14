export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Secret"

export type TutorialFlags = {
	thrown: boolean,
	upgraded: boolean,
	benched: boolean,
	complete: boolean,
}

export type PityState = {
	legendary: number,
	mythic: number,
}

export type BoostState = {
	doubleCoinsUntil: number,
}

export type PlayerStats = {
	totalCoinsEarned: number,
	bestDistance: number,
	cratesOpened: number,
}

export type PlayerData = {
	coins: number,
	scrap: number,
	strength: number,
	planeLevel: number,
	playerUpgrades: { [string]: number },
	hangarUpgrades: { [string]: number },
	ownedPlanes: { [string]: number },
	equipped: { string },
	cosmeticsOwned: { [string]: number },
	cosmeticsEquipped: { string },
	rotationSalt: number,
	streak: number,
	lastDailyClaimDay: number,
	rebirths: number,
	pity: PityState,
	processedPurchases: { [string]: boolean },
	purchaseOrder: { string },
	lastLogout: number,
	tutorial: TutorialFlags,
	boosts: BoostState,
	streakShields: number,
	codesRedeemed: { [string]: boolean },
	totalThrows: number,
	stats: PlayerStats,
}

export type Computed = {
	coinMultiplier: number,
	luckMultiplier: number,
	throwCooldown: number,
	skipAnim: boolean,
	extraCosmeticSlots: boolean,
	doubleCoins: boolean,
	doubleLuck: boolean,
	extraPlane: boolean,
	offlinePlus: boolean,
	storagePlus: boolean,
	cosmeticSlots: number,
	offlineHours: number,
	idlePerMinute: number,
	restrictedPaidRandom: boolean,
	vip: boolean,
	planesPerThrow: number,
	storage: number,
	stands: number,
	planeMultiplier: number,
	rebirthCoinMult: number,
	rebirthStrengthMult: number,
	strengthGainMult: number,
	cosmeticCoinMult: number,
	cosmeticStrengthMult: number,
	distancePreview: number,
	boostRemaining: number,
}

export type Snapshot = {
	data: PlayerData,
	computed: Computed,
}

export type ThrowResult = {
	distance: number,
	coins: number,
	strengthGain: number,
	origin: Vector3,
	landing: Vector3,
	planeId: string,
	duration: number,
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
