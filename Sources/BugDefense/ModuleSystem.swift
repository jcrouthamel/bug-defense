import Foundation
import CoreGraphics

/// Types of modules that can be equipped on towers
enum ModuleType: String, CaseIterable, Codable {
    case damage = "Damage"
    case attackSpeed = "Attack Speed"
    case range = "Range"
    case criticalChance = "Critical Chance"
    case piercing = "Piercing"
    case splash = "Splash"
    case lifesteal = "Lifesteal"
    case multishot = "Multishot"

    var emoji: String {
        switch self {
        case .damage: return "⚔️"
        case .attackSpeed: return "⚡"
        case .range: return "🎯"
        case .criticalChance: return "💥"
        case .piercing: return "🗡️"
        case .splash: return "💣"
        case .lifesteal: return "🩸"
        case .multishot: return "🎲"
        }
    }

    var description: String {
        switch self {
        case .damage: return "Increases tower damage"
        case .attackSpeed: return "Increases attack speed"
        case .range: return "Increases attack range"
        case .criticalChance: return "Chance for critical hits"
        case .piercing: return "Attacks pierce through bugs"
        case .splash: return "Damage nearby bugs"
        case .lifesteal: return "Heals tower on hit"
        case .multishot: return "Fire additional projectiles"
        }
    }
}

/// Individual module that can be equipped on towers
struct Module: Equatable, Hashable, Codable {
    let id: String
    let type: ModuleType
    let level: Int // 1-30

    init(type: ModuleType, level: Int) {
        self.id = UUID().uuidString
        self.type = type
        self.level = max(1, min(30, level)) // Clamp between 1 and 30
    }

    // For decoding
    init(id: String, type: ModuleType, level: Int) {
        self.id = id
        self.type = type
        self.level = max(1, min(30, level))
    }

    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case level
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(ModuleType.self, forKey: .type)
        let decodedLevel = try container.decode(Int.self, forKey: .level)
        self.level = max(1, min(30, decodedLevel))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(level, forKey: .level)
    }

    /// Get the tier color based on level
    var tier: ModuleTier {
        switch level {
        case 1...5: return .common
        case 6...10: return .uncommon
        case 11...15: return .rare
        case 16...20: return .epic
        case 21...25: return .legendary
        case 26...30: return .mythic
        default: return .common
        }
    }

    /// Base effect value (scales with level)
    var effectValue: CGFloat {
        let baseValue: CGFloat
        switch type {
        case .damage:
            baseValue = 0.05 // +5% per level
        case .attackSpeed:
            baseValue = 0.03 // +3% per level
        case .range:
            baseValue = 0.04 // +4% per level
        case .criticalChance:
            baseValue = 0.02 // +2% crit chance per level
        case .piercing:
            baseValue = 0.1 // +10% pierce chance per level
        case .splash:
            baseValue = 0.15 // +15% splash damage per level
        case .lifesteal:
            baseValue = 0.01 // +1% lifesteal per level
        case .multishot:
            baseValue = 0.05 // +5% multishot chance per level
        }

        return baseValue * CGFloat(level)
    }

    /// Display string for the effect
    var effectString: String {
        let value = effectValue * 100
        switch type {
        case .damage:
            return "+\(Int(value))% Damage"
        case .attackSpeed:
            return "+\(Int(value))% Attack Speed"
        case .range:
            return "+\(Int(value))% Range"
        case .criticalChance:
            return "\(Int(value))% Crit Chance"
        case .piercing:
            return "\(Int(value))% Pierce"
        case .splash:
            return "\(Int(value))% Splash"
        case .lifesteal:
            return "\(Int(value))% Lifesteal"
        case .multishot:
            return "\(Int(value))% Multishot"
        }
    }

    /// Gem cost to purchase this module
    var gemCost: Int {
        let baseCost = 50
        return baseCost + (level * 20)
    }
}

/// Module tier based on level
enum ModuleTier: String {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    case mythic = "Mythic"

    var color: (r: CGFloat, g: CGFloat, b: CGFloat) {
        switch self {
        case .common: return (0.7, 0.7, 0.7) // Gray
        case .uncommon: return (0.3, 0.8, 0.3) // Green
        case .rare: return (0.2, 0.5, 1.0) // Blue
        case .epic: return (0.6, 0.2, 0.8) // Purple
        case .legendary: return (1.0, 0.6, 0.0) // Orange
        case .mythic: return (1.0, 0.2, 0.2) // Red
        }
    }
}

/// Manages module inventory, drops, and merging
@MainActor
class ModuleManager {
    private(set) var inventory: [Module] = []
    private(set) var gems: Int = 0
    weak var gameState: GameStateManager?

    // Callbacks
    var onModuleDropped: ((Module) -> Void)?
    var onModuleMerged: ((Module) -> Void)?
    var onGemsChanged: ((Int) -> Void)?
    var onInventoryChanged: (() -> Void)?

    // MARK: - Gem Management

    func addGems(_ amount: Int) {
        gems += amount
        onGemsChanged?(gems)
    }

    func spendGems(_ amount: Int) -> Bool {
        if gameState?.isAdminMode == true {
            return true // Don't spend in admin mode
        }
        guard gems >= amount else { return false }
        gems -= amount
        onGemsChanged?(gems)
        return true
    }

    /// Convert coins to gems (expensive conversion rate)
    func convertCoinsToGems(coins: Int, researchLab: ResearchLab) -> Int? {
        let conversionRate = 100 // 100 coins = 1 gem
        let gemsToReceive = coins / conversionRate

        guard gemsToReceive > 0 else { return nil }
        guard researchLab.spendCoins(coins) else { return nil }

        addGems(gemsToReceive)
        return gemsToReceive
    }

    // MARK: - Module Drops

    /// Award a random module drop (called when bugs are killed)
    func tryDropModule(fromWave wave: Int) -> Module? {
        // Drop rate increases with wave number
        let baseDropRate = 0.05 // 5% base chance
        let waveBonus = CGFloat(wave) * 0.001 // +0.1% per wave
        let dropChance = min(baseDropRate + waveBonus, 0.3) // Cap at 30%

        guard CGFloat.random(in: 0...1) < dropChance else { return nil }

        // Random module type
        let moduleType = ModuleType.allCases.randomElement()!

        // Level based on wave (early waves drop low level, later waves drop higher)
        let minLevel = max(1, wave / 5) // Wave 5+ drops level 1+, Wave 10+ drops level 2+
        let maxLevel = max(1, min(30, wave / 3)) // Gradually increase max level
        let level = Int.random(in: minLevel...maxLevel)

        let module = Module(type: moduleType, level: level)
        addModule(module)
        onModuleDropped?(module)
        return module
    }

    private func addModule(_ module: Module) {
        inventory.append(module)
        onInventoryChanged?()
    }

    // MARK: - Module Purchase

    func purchaseModule(type: ModuleType, level: Int) -> Module? {
        let module = Module(type: type, level: level)
        guard spendGems(module.gemCost) else { return nil }

        addModule(module)
        return module
    }

    // MARK: - Module Merging

    /// Merge two modules of the same type and level to create a higher level module
    func canMerge(_ module1: Module, _ module2: Module) -> Bool {
        return module1.type == module2.type &&
               module1.level == module2.level &&
               module1.level < 30 &&
               module1.id != module2.id
    }

    func mergeModules(_ module1: Module, _ module2: Module) -> Module? {
        guard canMerge(module1, module2) else { return nil }

        // Remove both modules from inventory
        inventory.removeAll { $0.id == module1.id || $0.id == module2.id }

        // Create new module with level + 1
        let newModule = Module(type: module1.type, level: module1.level + 1)
        addModule(newModule)
        onModuleMerged?(newModule)
        onInventoryChanged?()

        return newModule
    }

    // MARK: - Inventory Management

    func removeModule(_ module: Module) {
        inventory.removeAll { $0.id == module.id }
        onInventoryChanged?()
    }

    func getModulesByType(_ type: ModuleType) -> [Module] {
        return inventory.filter { $0.type == type }.sorted { $0.level > $1.level }
    }

    func getMergeableModules() -> [(Module, Module)] {
        var pairs: [(Module, Module)] = []

        for i in 0..<inventory.count {
            for j in (i+1)..<inventory.count {
                if canMerge(inventory[i], inventory[j]) {
                    pairs.append((inventory[i], inventory[j]))
                }
            }
        }

        return pairs
    }

    // MARK: - Persistence

    func save() -> [String: Any] {
        let inventoryData = inventory.map { module -> [String: Any] in
            return [
                "id": module.id,
                "type": module.type.rawValue,
                "level": module.level
            ]
        }

        return [
            "inventory": inventoryData,
            "gems": gems
        ]
    }

    func load(from data: [String: Any]) {
        if let inventoryData = data["inventory"] as? [[String: Any]] {
            inventory = inventoryData.compactMap { dict -> Module? in
                guard let id = dict["id"] as? String,
                      let typeRaw = dict["type"] as? String,
                      let type = ModuleType(rawValue: typeRaw),
                      let level = dict["level"] as? Int else {
                    return nil
                }
                return Module(id: id, type: type, level: level)
            }
        }

        if let savedGems = data["gems"] as? Int {
            gems = savedGems
        }

        onGemsChanged?(gems)
        onInventoryChanged?()
    }

    func reset() {
        // Don't reset inventory and gems - they're permanent like cards
    }
}

/// Extension to DefenseStructure to support modules
extension DefenseStructure {
    private static var moduleAssociationKey: UInt8 = 0

    var equippedModules: [Module?] {
        get {
            return objc_getAssociatedObject(self, &DefenseStructure.moduleAssociationKey) as? [Module?] ?? [nil, nil, nil, nil]
        }
        set {
            objc_setAssociatedObject(self, &DefenseStructure.moduleAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func equipModule(_ module: Module, at slot: Int) -> Bool {
        guard slot >= 0 && slot < 4 else { return false }
        var modules = equippedModules
        modules[slot] = module
        equippedModules = modules
        return true
    }

    func unequipModule(at slot: Int) -> Module? {
        guard slot >= 0 && slot < 4 else { return nil }
        var modules = equippedModules
        let module = modules[slot]
        modules[slot] = nil
        equippedModules = modules
        return module
    }

    func getModuleBonuses() -> ModuleBonuses {
        var bonuses = ModuleBonuses()

        for module in equippedModules.compactMap({ $0 }) {
            switch module.type {
            case .damage:
                bonuses.damageMultiplier *= (1.0 + module.effectValue)
            case .attackSpeed:
                bonuses.attackSpeedMultiplier *= (1.0 + module.effectValue)
            case .range:
                bonuses.rangeMultiplier *= (1.0 + module.effectValue)
            case .criticalChance:
                bonuses.criticalChance += module.effectValue
            case .piercing:
                bonuses.piercingChance += module.effectValue
            case .splash:
                bonuses.splashDamage += module.effectValue
            case .lifesteal:
                bonuses.lifesteal += module.effectValue
            case .multishot:
                bonuses.multishotChance += module.effectValue
            }
        }

        return bonuses
    }
}

/// Accumulated bonuses from equipped modules
struct ModuleBonuses {
    var damageMultiplier: CGFloat = 1.0
    var attackSpeedMultiplier: CGFloat = 1.0
    var rangeMultiplier: CGFloat = 1.0
    var criticalChance: CGFloat = 0.0
    var piercingChance: CGFloat = 0.0
    var splashDamage: CGFloat = 0.0
    var lifesteal: CGFloat = 0.0
    var multishotChance: CGFloat = 0.0
}

// Need to import ObjectiveC for associated objects
import ObjectiveC
