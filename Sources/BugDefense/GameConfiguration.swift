import Foundation
import CoreGraphics

/// Difficulty level setting
enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case insane = "Insane"

    /// Bug health multiplier
    var bugHealthMultiplier: CGFloat {
        switch self {
        case .easy: return 0.7
        case .normal: return 1.0
        case .hard: return 1.5
        case .insane: return 2.5
        }
    }

    /// Bug damage multiplier
    var bugDamageMultiplier: CGFloat {
        switch self {
        case .easy: return 0.7
        case .normal: return 1.0
        case .hard: return 1.3
        case .insane: return 2.0
        }
    }

    /// Currency reward multiplier
    var rewardMultiplier: CGFloat {
        switch self {
        case .easy: return 1.3
        case .normal: return 1.0
        case .hard: return 0.8
        case .insane: return 0.6
        }
    }

    /// Starting currency adjustment
    var startingCurrencyMultiplier: CGFloat {
        switch self {
        case .easy: return 1.5
        case .normal: return 1.0
        case .hard: return 0.7
        case .insane: return 0.5
        }
    }

    /// House health multiplier
    var houseHealthMultiplier: CGFloat {
        switch self {
        case .easy: return 1.5
        case .normal: return 1.0
        case .hard: return 0.8
        case .insane: return 0.5
        }
    }
}

/// Global configuration for game parameters
enum GameConfiguration {
    // Grid settings
    static let gridWidth: Int = 20
    static let gridHeight: Int = 15
    static let tileSize: CGFloat = 40.0

    // House settings
    static let houseMaxHealth: Int = 100
    static let housePosition: GridPosition = GridPosition(x: gridWidth / 2, y: gridHeight / 2)

    // Currency
    static let startingCurrency: Int = 500  // Increased for easier testing
    static let bugKillReward: Int = 10

    // Wave settings
    static let initialWaveSize: Int = 5
    static let waveSizeIncrement: Int = 2
    static let timeBetweenWaves: TimeInterval = 20.0
    static let totalWaves: Int = 100 // Extended for card system with boss waves every 25
    static let bossWaveInterval: Int = 25 // Boss wave every 25 waves

    // Bug spawn points (edges of the map)
    static let spawnPoints: [GridPosition] = [
        GridPosition(x: 0, y: 3)  // Left spawn - connects to winding road
    ]

    // Winding road path that bugs must follow
    static let roadPath: [GridPosition] = [
        // Start from left edge
        GridPosition(x: 0, y: 3),
        GridPosition(x: 1, y: 3),
        GridPosition(x: 2, y: 3),
        GridPosition(x: 3, y: 3),
        GridPosition(x: 4, y: 3),
        // Turn down
        GridPosition(x: 4, y: 4),
        GridPosition(x: 4, y: 5),
        GridPosition(x: 4, y: 6),
        GridPosition(x: 4, y: 7),
        GridPosition(x: 4, y: 8),
        GridPosition(x: 4, y: 9),
        GridPosition(x: 4, y: 10),
        GridPosition(x: 4, y: 11),
        // Turn right
        GridPosition(x: 5, y: 11),
        GridPosition(x: 6, y: 11),
        GridPosition(x: 7, y: 11),
        GridPosition(x: 8, y: 11),
        GridPosition(x: 9, y: 11),
        GridPosition(x: 10, y: 11),
        GridPosition(x: 11, y: 11),
        GridPosition(x: 12, y: 11),
        // Turn up
        GridPosition(x: 12, y: 10),
        GridPosition(x: 12, y: 9),
        GridPosition(x: 12, y: 8),
        GridPosition(x: 12, y: 7),
        GridPosition(x: 12, y: 6),
        GridPosition(x: 12, y: 5),
        GridPosition(x: 12, y: 4),
        GridPosition(x: 12, y: 3),
        // Turn right
        GridPosition(x: 13, y: 3),
        GridPosition(x: 14, y: 3),
        GridPosition(x: 15, y: 3),
        // Turn down
        GridPosition(x: 15, y: 4),
        GridPosition(x: 15, y: 5),
        GridPosition(x: 15, y: 6),
        GridPosition(x: 15, y: 7),
        GridPosition(x: 15, y: 8),
        GridPosition(x: 15, y: 9),
        // Turn left toward house
        GridPosition(x: 14, y: 9),
        GridPosition(x: 13, y: 9),
        GridPosition(x: 12, y: 9),
        GridPosition(x: 11, y: 9),
        GridPosition(x: 10, y: 9),
        GridPosition(x: 9, y: 9),
        // Turn up to house
        GridPosition(x: 9, y: 8),
        GridPosition(x: 9, y: 7),
        GridPosition(x: 10, y: 7)  // House position
    ]

    // Tower costs
    static let basicTowerCost: Int = 50
    static let trapCost: Int = 30

    // Research Lab (coins earned from completing waves)
    static let baseCoinsPerWave: Int = 3
    static let bonusCoinsEvery5Waves: Int = 5 // Extra coins for waves 5, 10, 15, 20
    static let bonusCoinsPerBossWave: Int = 20 // Extra coins for boss waves

    // Card System
    static let cardSlotsCount: Int = 5
    static let initialUnlockedSlots: Int = 1

    // Module System
    static let moduleSlots: Int = 4 // Slots per tower
    static let coinToGemConversionRate: Int = 100 // 100 coins = 1 gem
    static let moduleBaseDropRate: CGFloat = 0.05 // 5% base drop chance
    static let moduleMaxDropRate: CGFloat = 0.3 // 30% max drop chance
}

/// Grid position for tile-based positioning
struct GridPosition: Equatable, Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        return "(\(x),\(y))"
    }

    func toWorldPosition() -> CGPoint {
        return CGPoint(
            x: CGFloat(x) * GameConfiguration.tileSize + GameConfiguration.tileSize / 2,
            y: CGFloat(y) * GameConfiguration.tileSize + GameConfiguration.tileSize / 2
        )
    }

    static func fromWorldPosition(_ point: CGPoint) -> GridPosition {
        return GridPosition(
            x: Int(point.x / GameConfiguration.tileSize),
            y: Int(point.y / GameConfiguration.tileSize)
        )
    }

    func distance(to other: GridPosition) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
}
