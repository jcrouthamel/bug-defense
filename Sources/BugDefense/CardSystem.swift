import Foundation

/// Types of cards available
enum CardType: String, CaseIterable {
    case damageBoost = "Damage Boost"
    case rapidFire = "Rapid Fire"
    case sniperNest = "Sniper Nest"
    case fortification = "Fortification"
    case economyBonus = "Economy Bonus"
    case multishot = "Multishot"
    case poisonDarts = "Poison Darts"
    case timeWarp = "Time Warp"
    case coinMagnet = "Coin Magnet"
    case rangeExtender = "Range Extender"
    case criticalMass = "Critical Mass"
    case autoRepair = "Auto Repair"
    case slowField = "Slow Field"
    case explosiveAmmo = "Explosive Ammo"
    case starterPack = "Starter Pack"
}

/// Individual card with effects
struct Card: Equatable, Hashable {
    let type: CardType
    let id: String // Unique identifier
    let rarity: CardRarity

    var name: String { type.rawValue }

    var description: String {
        switch type {
        case .damageBoost:
            return "+30% damage to all towers"
        case .rapidFire:
            return "+40% attack speed"
        case .sniperNest:
            return "Sniper towers cost 50% less, +20% range"
        case .fortification:
            return "+50% structure health"
        case .economyBonus:
            return "+25% currency from bug kills"
        case .multishot:
            return "Towers hit 2 targets simultaneously"
        case .poisonDarts:
            return "Attacks deal 20% damage over 3 seconds"
        case .timeWarp:
            return "+50% attack speed, -30% bug speed"
        case .coinMagnet:
            return "+50% research coins from waves"
        case .rangeExtender:
            return "+40% tower range"
        case .criticalMass:
            return "25% chance to deal triple damage"
        case .autoRepair:
            return "Structures repair 5 HP/second"
        case .slowField:
            return "All bugs move 25% slower"
        case .explosiveAmmo:
            return "Attacks deal splash damage to nearby bugs"
        case .starterPack:
            return "Start with +200 currency each wave"
        }
    }

    var emoji: String {
        switch type {
        case .damageBoost: return "⚔️"
        case .rapidFire: return "⚡"
        case .sniperNest: return "🎯"
        case .fortification: return "🛡️"
        case .economyBonus: return "💰"
        case .multishot: return "🎲"
        case .poisonDarts: return "☠️"
        case .timeWarp: return "⏱️"
        case .coinMagnet: return "🧲"
        case .rangeExtender: return "📡"
        case .criticalMass: return "💥"
        case .autoRepair: return "🔧"
        case .slowField: return "❄️"
        case .explosiveAmmo: return "💣"
        case .starterPack: return "📦"
        }
    }

    // Card effects
    var damageMultiplier: CGFloat {
        switch type {
        case .damageBoost: return 1.3
        case .criticalMass: return 1.0 // Handled separately
        default: return 1.0
        }
    }

    var attackSpeedMultiplier: CGFloat {
        switch type {
        case .rapidFire: return 1.4
        case .timeWarp: return 1.5
        default: return 1.0
        }
    }

    var rangeMultiplier: CGFloat {
        switch type {
        case .sniperNest: return 1.2
        case .rangeExtender: return 1.4
        default: return 1.0
        }
    }

    var healthMultiplier: CGFloat {
        switch type {
        case .fortification: return 1.5
        default: return 1.0
        }
    }

    var currencyMultiplier: CGFloat {
        switch type {
        case .economyBonus: return 1.25
        default: return 1.0
        }
    }

    var coinMultiplier: CGFloat {
        switch type {
        case .coinMagnet: return 1.5
        default: return 1.0
        }
    }

    var bugSlowFactor: CGFloat {
        switch type {
        case .timeWarp: return 0.7
        case .slowField: return 0.75
        default: return 1.0
        }
    }

    var repairRate: Int {
        switch type {
        case .autoRepair: return 5
        default: return 0
        }
    }

    var startingCurrencyBonus: Int {
        switch type {
        case .starterPack: return 200
        default: return 0
        }
    }

    var sniperCostReduction: CGFloat {
        switch type {
        case .sniperNest: return 0.5
        default: return 0.0
        }
    }

    var hasMultishot: Bool {
        type == .multishot
    }

    var hasPoisonDarts: Bool {
        type == .poisonDarts
    }

    var hasCriticalMass: Bool {
        type == .criticalMass
    }

    var hasExplosiveAmmo: Bool {
        type == .explosiveAmmo
    }
}

/// Card rarity levels
enum CardRarity: String {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"

    var color: (r: CGFloat, g: CGFloat, b: CGFloat) {
        switch self {
        case .common: return (0.7, 0.7, 0.7) // Gray
        case .rare: return (0.2, 0.5, 1.0) // Blue
        case .epic: return (0.6, 0.2, 0.8) // Purple
        case .legendary: return (1.0, 0.6, 0.0) // Orange/Gold
        }
    }
}

/// Manages card collection and equipped slots
@MainActor
class CardManager {
    private(set) var collectedCards: Set<String> = [] // Card IDs
    private(set) var equippedCards: [Card?] = [nil, nil, nil, nil, nil] // 5 slots
    private(set) var unlockedSlots: Int = 1 // Start with 1 slot unlocked

    private let slotUnlockCosts: [Int] = [0, 50, 100, 150, 200] // Cost to unlock each slot

    var onCardCollected: ((Card) -> Void)?
    var onSlotUnlocked: ((Int) -> Void)?
    var onCardEquipped: ((Card?, Int) -> Void)?

    // Available cards (predefined deck)
    static let allCards: [Card] = [
        Card(type: .damageBoost, id: "card_damage_1", rarity: .common),
        Card(type: .rapidFire, id: "card_speed_1", rarity: .common),
        Card(type: .sniperNest, id: "card_sniper_1", rarity: .rare),
        Card(type: .fortification, id: "card_fort_1", rarity: .common),
        Card(type: .economyBonus, id: "card_econ_1", rarity: .rare),
        Card(type: .multishot, id: "card_multi_1", rarity: .epic),
        Card(type: .poisonDarts, id: "card_poison_1", rarity: .rare),
        Card(type: .timeWarp, id: "card_time_1", rarity: .epic),
        Card(type: .coinMagnet, id: "card_coin_1", rarity: .rare),
        Card(type: .rangeExtender, id: "card_range_1", rarity: .common),
        Card(type: .criticalMass, id: "card_crit_1", rarity: .legendary),
        Card(type: .autoRepair, id: "card_repair_1", rarity: .rare),
        Card(type: .slowField, id: "card_slow_1", rarity: .epic),
        Card(type: .explosiveAmmo, id: "card_explode_1", rarity: .legendary),
        Card(type: .starterPack, id: "card_starter_1", rarity: .common),
    ]

    // MARK: - Card Collection

    func awardRandomCard() -> Card? {
        // Filter cards that haven't been collected yet
        let availableCards = Self.allCards.filter { !collectedCards.contains($0.id) }
        guard !availableCards.isEmpty else { return nil }

        // Weighted random selection based on rarity
        let card = weightedRandomCard(from: availableCards)
        collectedCards.insert(card.id)
        onCardCollected?(card)
        return card
    }

    private func weightedRandomCard(from cards: [Card]) -> Card {
        // Rarity weights: Common(50%), Rare(30%), Epic(15%), Legendary(5%)
        let weights: [CardRarity: Int] = [
            .common: 50,
            .rare: 30,
            .epic: 15,
            .legendary: 5
        ]

        let totalWeight = cards.reduce(0) { $0 + (weights[$1.rarity] ?? 1) }
        var random = Int.random(in: 0..<totalWeight)

        for card in cards {
            let weight = weights[card.rarity] ?? 1
            if random < weight {
                return card
            }
            random -= weight
        }

        return cards.last!
    }

    // MARK: - Slot Management

    func canUnlockSlot(_ slotIndex: Int) -> Bool {
        guard slotIndex < 5 && slotIndex >= unlockedSlots else { return false }
        return slotIndex == unlockedSlots // Can only unlock next slot
    }

    func getSlotUnlockCost(_ slotIndex: Int) -> Int {
        guard slotIndex < slotUnlockCosts.count else { return 0 }
        return slotUnlockCosts[slotIndex]
    }

    func unlockSlot(_ slotIndex: Int, with researchLab: ResearchLab) -> Bool {
        guard canUnlockSlot(slotIndex) else { return false }

        let cost = getSlotUnlockCost(slotIndex)
        if researchLab.spendCoins(cost) {
            unlockedSlots = slotIndex + 1
            onSlotUnlocked?(slotIndex)
            return true
        }

        return false
    }

    // MARK: - Card Equipment

    func equipCard(_ card: Card, to slotIndex: Int) -> Bool {
        guard slotIndex < unlockedSlots else { return false }
        guard collectedCards.contains(card.id) else { return false }

        // Check if card is already equipped in another slot
        for (index, equipped) in equippedCards.enumerated() {
            if equipped?.id == card.id && index != slotIndex {
                return false // Can't equip same card twice
            }
        }

        equippedCards[slotIndex] = card
        onCardEquipped?(card, slotIndex)
        return true
    }

    func unequipCard(from slotIndex: Int) {
        guard slotIndex < equippedCards.count else { return }
        equippedCards[slotIndex] = nil
        onCardEquipped?(nil, slotIndex)
    }

    func getEquippedCard(at slotIndex: Int) -> Card? {
        guard slotIndex < equippedCards.count else { return nil }
        return equippedCards[slotIndex]
    }

    // MARK: - Aggregated Effects

    func getTotalDamageMultiplier() -> CGFloat {
        return equippedCards.compactMap { $0 }.reduce(1.0) { $0 * $1.damageMultiplier }
    }

    func getTotalAttackSpeedMultiplier() -> CGFloat {
        return equippedCards.compactMap { $0 }.reduce(1.0) { $0 * $1.attackSpeedMultiplier }
    }

    func getTotalRangeMultiplier() -> CGFloat {
        return equippedCards.compactMap { $0 }.reduce(1.0) { $0 * $1.rangeMultiplier }
    }

    func getTotalHealthMultiplier() -> CGFloat {
        return equippedCards.compactMap { $0 }.reduce(1.0) { $0 * $1.healthMultiplier }
    }

    func getTotalCurrencyMultiplier() -> CGFloat {
        return equippedCards.compactMap { $0 }.reduce(1.0) { $0 * $1.currencyMultiplier }
    }

    func getTotalCoinMultiplier() -> CGFloat {
        return equippedCards.compactMap { $0 }.reduce(1.0) { $0 * $1.coinMultiplier }
    }

    func getTotalBugSlowFactor() -> CGFloat {
        return equippedCards.compactMap { $0 }.reduce(1.0) { $0 * $1.bugSlowFactor }
    }

    func getTotalRepairRate() -> Int {
        return equippedCards.compactMap { $0 }.reduce(0) { $0 + $1.repairRate }
    }

    func getTotalStartingCurrencyBonus() -> Int {
        return equippedCards.compactMap { $0 }.reduce(0) { $0 + $1.startingCurrencyBonus }
    }

    func hasMultishot() -> Bool {
        return equippedCards.compactMap { $0 }.contains(where: { $0.hasMultishot })
    }

    func hasPoisonDarts() -> Bool {
        return equippedCards.compactMap { $0 }.contains(where: { $0.hasPoisonDarts })
    }

    func hasCriticalMass() -> Bool {
        return equippedCards.compactMap { $0 }.contains(where: { $0.hasCriticalMass })
    }

    func hasExplosiveAmmo() -> Bool {
        return equippedCards.compactMap { $0 }.contains(where: { $0.hasExplosiveAmmo })
    }

    func getSniperCostReduction() -> CGFloat {
        return equippedCards.compactMap { $0 }.map { $0.sniperCostReduction }.max() ?? 0.0
    }

    // MARK: - Persistence

    func save() -> [String: Any] {
        return [
            "collectedCards": Array(collectedCards),
            "equippedCards": equippedCards.map { $0?.id ?? "" },
            "unlockedSlots": unlockedSlots
        ]
    }

    func load(from data: [String: Any]) {
        if let collected = data["collectedCards"] as? [String] {
            collectedCards = Set(collected)
        }

        if let equipped = data["equippedCards"] as? [String] {
            equippedCards = equipped.map { id in
                guard !id.isEmpty else { return nil }
                return Self.allCards.first { $0.id == id }
            }
        }

        if let slots = data["unlockedSlots"] as? Int {
            unlockedSlots = slots
        }
    }

    func reset() {
        // Don't reset collected cards - they're permanent
        // Only reset equipped cards
        equippedCards = [nil, nil, nil, nil, nil]
    }

    func getCollectedCardsList() -> [Card] {
        return Self.allCards.filter { collectedCards.contains($0.id) }
    }
}
