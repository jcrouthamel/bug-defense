import Foundation

/// Upgrade tree types
enum UpgradeTree {
    case attack
    case defense
    case speed
}

/// Individual upgrade in a tree
struct Upgrade {
    let id: String
    let name: String
    let description: String
    let cost: Int
    let tree: UpgradeTree
    let tier: Int

    // Effects
    let damageMultiplier: CGFloat
    let healthMultiplier: CGFloat
    let attackSpeedMultiplier: CGFloat
    let repairRate: Int // HP per second
    let critChance: CGFloat
}

/// Manages the upgrade system and progression
@MainActor
class UpgradeManager {
    private let gameState: GameStateManager
    private var purchasedUpgrades: Set<String> = []

    // Current upgrade effects
    private(set) var totalDamageMultiplier: CGFloat = 1.0
    private(set) var totalHealthMultiplier: CGFloat = 1.0
    private(set) var totalAttackSpeedMultiplier: CGFloat = 1.0
    private(set) var totalRepairRate: Int = 0
    private(set) var totalCritChance: CGFloat = 0.0

    var onUpgradePurchased: ((Upgrade) -> Void)?

    init(gameState: GameStateManager) {
        self.gameState = gameState
    }

    // MARK: - Upgrade Definitions

    static let allUpgrades: [Upgrade] = [
        // Attack Tree
        Upgrade(
            id: "attack_tier1",
            name: "Sharpened Ammo",
            description: "+20% damage to all towers",
            cost: 100,
            tree: .attack,
            tier: 1,
            damageMultiplier: 1.2,
            healthMultiplier: 1.0,
            attackSpeedMultiplier: 1.0,
            repairRate: 0,
            critChance: 0.0
        ),
        Upgrade(
            id: "attack_tier2",
            name: "Critical Strike",
            description: "15% chance to deal double damage",
            cost: 200,
            tree: .attack,
            tier: 2,
            damageMultiplier: 1.0,
            healthMultiplier: 1.0,
            attackSpeedMultiplier: 1.0,
            repairRate: 0,
            critChance: 0.15
        ),
        Upgrade(
            id: "attack_tier3",
            name: "Multi-Target",
            description: "+50% damage, towers can hit 2 targets",
            cost: 400,
            tree: .attack,
            tier: 3,
            damageMultiplier: 1.5,
            healthMultiplier: 1.0,
            attackSpeedMultiplier: 1.0,
            repairRate: 0,
            critChance: 0.0
        ),
        Upgrade(
            id: "attack_tier4",
            name: "Elemental Fury",
            description: "+100% damage, attacks burn enemies",
            cost: 800,
            tree: .attack,
            tier: 4,
            damageMultiplier: 2.0,
            healthMultiplier: 1.0,
            attackSpeedMultiplier: 1.0,
            repairRate: 0,
            critChance: 0.0
        ),

        // Defense Tree
        Upgrade(
            id: "defense_tier1",
            name: "Reinforced Walls",
            description: "+30% health to all structures",
            cost: 100,
            tree: .defense,
            tier: 1,
            damageMultiplier: 1.0,
            healthMultiplier: 1.3,
            attackSpeedMultiplier: 1.0,
            repairRate: 0,
            critChance: 0.0
        ),
        Upgrade(
            id: "defense_tier2",
            name: "House Armor",
            description: "+50% house health, reduces damage by 25%",
            cost: 200,
            tree: .defense,
            tier: 2,
            damageMultiplier: 1.0,
            healthMultiplier: 1.5,
            attackSpeedMultiplier: 1.0,
            repairRate: 0,
            critChance: 0.0
        ),
        Upgrade(
            id: "defense_tier3",
            name: "Auto-Repair",
            description: "Structures repair 2 HP/second",
            cost: 400,
            tree: .defense,
            tier: 3,
            damageMultiplier: 1.0,
            healthMultiplier: 1.0,
            attackSpeedMultiplier: 1.0,
            repairRate: 2,
            critChance: 0.0
        ),
        Upgrade(
            id: "defense_tier4",
            name: "Damage Reflection",
            description: "Structures reflect 50% of damage taken",
            cost: 800,
            tree: .defense,
            tier: 4,
            damageMultiplier: 1.0,
            healthMultiplier: 2.0,
            attackSpeedMultiplier: 1.0,
            repairRate: 5,
            critChance: 0.0
        ),

        // Speed Tree
        Upgrade(
            id: "speed_tier1",
            name: "Rapid Fire",
            description: "+25% attack speed",
            cost: 100,
            tree: .speed,
            tier: 1,
            damageMultiplier: 1.0,
            healthMultiplier: 1.0,
            attackSpeedMultiplier: 1.25,
            repairRate: 0,
            critChance: 0.0
        ),
        Upgrade(
            id: "speed_tier2",
            name: "Enhanced Traps",
            description: "+50% attack speed, traps slow by 75%",
            cost: 200,
            tree: .speed,
            tier: 2,
            damageMultiplier: 1.0,
            healthMultiplier: 1.0,
            attackSpeedMultiplier: 1.5,
            repairRate: 0,
            critChance: 0.0
        ),
        Upgrade(
            id: "speed_tier3",
            name: "Cooldown Reduction",
            description: "+75% attack speed",
            cost: 400,
            tree: .speed,
            tier: 3,
            damageMultiplier: 1.0,
            healthMultiplier: 1.0,
            attackSpeedMultiplier: 1.75,
            repairRate: 0,
            critChance: 0.0
        ),
        Upgrade(
            id: "speed_tier4",
            name: "Time Warp",
            description: "Double attack speed, auto-repair doubled",
            cost: 800,
            tree: .speed,
            tier: 4,
            damageMultiplier: 1.0,
            healthMultiplier: 1.0,
            attackSpeedMultiplier: 2.0,
            repairRate: 4,
            critChance: 0.0
        ),
    ]

    // MARK: - Upgrade Management

    func canPurchase(upgrade: Upgrade) -> Bool {
        // Check if already purchased
        if purchasedUpgrades.contains(upgrade.id) {
            return false
        }

        // Check if can afford
        if gameState.currency < upgrade.cost {
            return false
        }

        // Check if prerequisite tier is met
        if upgrade.tier > 1 {
            let previousTier = upgrade.tier - 1
            let hasPreviousTier = Self.allUpgrades.contains { u in
                u.tree == upgrade.tree &&
                u.tier == previousTier &&
                purchasedUpgrades.contains(u.id)
            }
            return hasPreviousTier
        }

        return true
    }

    func purchaseUpgrade(_ upgrade: Upgrade) -> Bool {
        guard canPurchase(upgrade: upgrade) else { return false }

        if gameState.spendCurrency(upgrade.cost) {
            purchasedUpgrades.insert(upgrade.id)
            applyUpgradeEffects(upgrade)
            onUpgradePurchased?(upgrade)
            return true
        }

        return false
    }

    private func applyUpgradeEffects(_ upgrade: Upgrade) {
        totalDamageMultiplier *= upgrade.damageMultiplier
        totalHealthMultiplier *= upgrade.healthMultiplier
        totalAttackSpeedMultiplier *= upgrade.attackSpeedMultiplier
        totalRepairRate += upgrade.repairRate
        totalCritChance += upgrade.critChance
    }

    func getUpgradesForTree(_ tree: UpgradeTree) -> [Upgrade] {
        return Self.allUpgrades.filter { $0.tree == tree }.sorted { $0.tier < $1.tier }
    }

    func isPurchased(_ upgradeId: String) -> Bool {
        return purchasedUpgrades.contains(upgradeId)
    }

    func reset() {
        purchasedUpgrades.removeAll()
        totalDamageMultiplier = 1.0
        totalHealthMultiplier = 1.0
        totalAttackSpeedMultiplier = 1.0
        totalRepairRate = 0
        totalCritChance = 0.0
    }
}
