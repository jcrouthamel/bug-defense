import Foundation

/// Research Lab upgrade types
enum ResearchUpgradeType {
    case damage
    case attackSpeed
    case range
    case structureHealth
    case towerCostReduction
    case coinMultiplier
}

/// Individual research upgrade
struct ResearchUpgrade {
    let id: String
    let type: ResearchUpgradeType
    let name: String
    let description: String
    let maxLevel: Int
    let baseCost: Int // Cost of first level
    let costIncrement: Int // Additional cost per level

    // Effects per level
    let damageBonus: CGFloat
    let attackSpeedBonus: CGFloat
    let rangeBonus: CGFloat
    let healthBonus: CGFloat
    let costReduction: CGFloat
    let coinBonus: CGFloat

    func cost(forLevel level: Int) -> Int {
        guard level > 0 && level <= maxLevel else { return 0 }
        return baseCost + (level - 1) * costIncrement
    }
}

/// Manages permanent research upgrades bought with coins
@MainActor
class ResearchLab {
    private var upgradeLevels: [String: Int] = [:] // upgradeId -> current level
    private(set) var totalCoins: Int = 0

    // Cumulative bonuses from all research
    private(set) var totalDamageBonus: CGFloat = 0.0
    private(set) var totalAttackSpeedBonus: CGFloat = 0.0
    private(set) var totalRangeBonus: CGFloat = 0.0
    private(set) var totalHealthBonus: CGFloat = 0.0
    private(set) var totalCostReduction: CGFloat = 0.0
    private(set) var totalCoinMultiplier: CGFloat = 1.0

    var onCoinsChanged: ((Int) -> Void)?
    var onUpgradeChanged: ((ResearchUpgrade, Int) -> Void)?

    // MARK: - Research Upgrade Definitions

    static let allUpgrades: [ResearchUpgrade] = [
        ResearchUpgrade(
            id: "research_damage",
            type: .damage,
            name: "Enhanced Ammunition",
            description: "+5% damage per level",
            maxLevel: 10,
            baseCost: 5,
            costIncrement: 3,
            damageBonus: 0.05,
            attackSpeedBonus: 0.0,
            rangeBonus: 0.0,
            healthBonus: 0.0,
            costReduction: 0.0,
            coinBonus: 0.0
        ),
        ResearchUpgrade(
            id: "research_attack_speed",
            type: .attackSpeed,
            name: "Advanced Targeting",
            description: "+5% attack speed per level",
            maxLevel: 10,
            baseCost: 5,
            costIncrement: 3,
            damageBonus: 0.0,
            attackSpeedBonus: 0.05,
            rangeBonus: 0.0,
            healthBonus: 0.0,
            costReduction: 0.0,
            coinBonus: 0.0
        ),
        ResearchUpgrade(
            id: "research_range",
            type: .range,
            name: "Long-Range Optics",
            description: "+10% range per level",
            maxLevel: 5,
            baseCost: 8,
            costIncrement: 5,
            damageBonus: 0.0,
            attackSpeedBonus: 0.0,
            rangeBonus: 0.1,
            healthBonus: 0.0,
            costReduction: 0.0,
            coinBonus: 0.0
        ),
        ResearchUpgrade(
            id: "research_health",
            type: .structureHealth,
            name: "Reinforced Materials",
            description: "+10% structure health per level",
            maxLevel: 8,
            baseCost: 6,
            costIncrement: 4,
            damageBonus: 0.0,
            attackSpeedBonus: 0.0,
            rangeBonus: 0.0,
            healthBonus: 0.1,
            costReduction: 0.0,
            coinBonus: 0.0
        ),
        ResearchUpgrade(
            id: "research_cost",
            type: .towerCostReduction,
            name: "Efficient Engineering",
            description: "-5% tower costs per level",
            maxLevel: 6,
            baseCost: 10,
            costIncrement: 6,
            damageBonus: 0.0,
            attackSpeedBonus: 0.0,
            rangeBonus: 0.0,
            healthBonus: 0.0,
            costReduction: 0.05,
            coinBonus: 0.0
        ),
        ResearchUpgrade(
            id: "research_coins",
            type: .coinMultiplier,
            name: "Victory Bonus",
            description: "+20% coins from waves per level",
            maxLevel: 5,
            baseCost: 12,
            costIncrement: 8,
            damageBonus: 0.0,
            attackSpeedBonus: 0.0,
            rangeBonus: 0.0,
            healthBonus: 0.0,
            costReduction: 0.0,
            coinBonus: 0.2
        ),
    ]

    // MARK: - Coin Management

    func addCoins(_ amount: Int) {
        let bonusAmount = Int(CGFloat(amount) * totalCoinMultiplier)
        totalCoins += bonusAmount
        onCoinsChanged?(totalCoins)
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard totalCoins >= amount else { return false }
        totalCoins -= amount
        onCoinsChanged?(totalCoins)
        return true
    }

    // MARK: - Upgrade Management

    func getUpgradeLevel(_ upgradeId: String) -> Int {
        return upgradeLevels[upgradeId] ?? 0
    }

    func canPurchaseUpgrade(_ upgrade: ResearchUpgrade) -> Bool {
        let currentLevel = getUpgradeLevel(upgrade.id)

        // Check if already maxed
        guard currentLevel < upgrade.maxLevel else { return false }

        // Check if can afford
        let cost = upgrade.cost(forLevel: currentLevel + 1)
        return totalCoins >= cost
    }

    func purchaseUpgrade(_ upgrade: ResearchUpgrade) -> Bool {
        guard canPurchaseUpgrade(upgrade) else { return false }

        let currentLevel = getUpgradeLevel(upgrade.id)
        let cost = upgrade.cost(forLevel: currentLevel + 1)

        if spendCoins(cost) {
            let newLevel = currentLevel + 1
            upgradeLevels[upgrade.id] = newLevel
            applyUpgradeEffects(upgrade, level: newLevel)
            onUpgradeChanged?(upgrade, newLevel)
            return true
        }

        return false
    }

    private func applyUpgradeEffects(_ upgrade: ResearchUpgrade, level: Int) {
        // Apply the bonus for this specific level
        totalDamageBonus += upgrade.damageBonus
        totalAttackSpeedBonus += upgrade.attackSpeedBonus
        totalRangeBonus += upgrade.rangeBonus
        totalHealthBonus += upgrade.healthBonus
        totalCostReduction += upgrade.costReduction
        totalCoinMultiplier += upgrade.coinBonus
    }

    // MARK: - Persistence

    func save() -> [String: Any] {
        return [
            "coins": totalCoins,
            "upgrades": upgradeLevels
        ]
    }

    func load(from data: [String: Any]) {
        if let coins = data["coins"] as? Int {
            totalCoins = coins
        }

        if let upgrades = data["upgrades"] as? [String: Int] {
            upgradeLevels = upgrades

            // Recalculate all bonuses
            totalDamageBonus = 0.0
            totalAttackSpeedBonus = 0.0
            totalRangeBonus = 0.0
            totalHealthBonus = 0.0
            totalCostReduction = 0.0
            totalCoinMultiplier = 1.0

            for upgrade in Self.allUpgrades {
                if let level = upgradeLevels[upgrade.id] {
                    for _ in 1...level {
                        totalDamageBonus += upgrade.damageBonus
                        totalAttackSpeedBonus += upgrade.attackSpeedBonus
                        totalRangeBonus += upgrade.rangeBonus
                        totalHealthBonus += upgrade.healthBonus
                        totalCostReduction += upgrade.costReduction
                        totalCoinMultiplier += upgrade.coinBonus
                    }
                }
            }
        }

        onCoinsChanged?(totalCoins)
    }

    func reset() {
        upgradeLevels.removeAll()
        totalCoins = 0
        totalDamageBonus = 0.0
        totalAttackSpeedBonus = 0.0
        totalRangeBonus = 0.0
        totalHealthBonus = 0.0
        totalCostReduction = 0.0
        totalCoinMultiplier = 1.0
        onCoinsChanged?(totalCoins)
    }

    // MARK: - Helper Methods

    func getDamageMultiplier() -> CGFloat {
        return 1.0 + totalDamageBonus
    }

    func getAttackSpeedMultiplier() -> CGFloat {
        return 1.0 + totalAttackSpeedBonus
    }

    func getRangeMultiplier() -> CGFloat {
        return 1.0 + totalRangeBonus
    }

    func getHealthMultiplier() -> CGFloat {
        return 1.0 + totalHealthBonus
    }

    func getCostMultiplier() -> CGFloat {
        return 1.0 - totalCostReduction
    }
}
