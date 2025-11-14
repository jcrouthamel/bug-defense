import Foundation
import SpriteKit

/// Bug types with different characteristics
enum BugType {
    case ant        // Basic bug
    case beetle     // Tanky bug with more health
    case spider     // Fast bug
    case boss       // Large bug with lots of health
    case splitter   // Splits into smaller bugs when killed
    case mosquito   // Flying bug that ignores walls
    case wasp       // Fast flying bug with high damage
    case burrower   // Bug that periodically burrows underground to avoid damage

    var health: Int {
        switch self {
        case .ant: return 20
        case .beetle: return 50
        case .spider: return 15
        case .boss: return 200
        case .splitter: return 30
        case .mosquito: return 12
        case .wasp: return 25
        case .burrower: return 35
        }
    }

    var speed: CGFloat {
        switch self {
        case .ant: return 60.0
        case .beetle: return 30.0
        case .spider: return 100.0
        case .boss: return 40.0
        case .splitter: return 50.0
        case .mosquito: return 80.0
        case .wasp: return 120.0
        case .burrower: return 45.0
        }
    }

    var damage: Int {
        switch self {
        case .ant: return 5
        case .beetle: return 10
        case .spider: return 3
        case .boss: return 25
        case .splitter: return 8
        case .mosquito: return 4
        case .wasp: return 12
        case .burrower: return 7
        }
    }

    var reward: Int {
        switch self {
        case .ant: return 10
        case .beetle: return 25
        case .spider: return 15
        case .boss: return 100
        case .splitter: return 20
        case .mosquito: return 18
        case .wasp: return 30
        case .burrower: return 28
        }
    }

    var color: SKColor {
        switch self {
        case .ant: return .red
        case .beetle: return .brown
        case .spider: return .purple
        case .boss: return .black
        case .splitter: return .orange
        case .mosquito: return .cyan
        case .wasp: return .yellow
        case .burrower: return SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0) // Dirt brown
        }
    }

    var size: CGFloat {
        switch self {
        case .ant: return 20
        case .beetle: return 25
        case .spider: return 18
        case .boss: return 40
        case .splitter: return 22
        case .mosquito: return 16
        case .wasp: return 20
        case .burrower: return 21
        }
    }

    var emoji: String {
        switch self {
        case .ant: return "🐜"
        case .beetle: return "🪲"
        case .spider: return "🕷️"
        case .boss: return "🦂"
        case .splitter: return "🪳"
        case .mosquito: return "🦟"
        case .wasp: return "🐝"
        case .burrower: return "🐛"
        }
    }

    var canFly: Bool {
        switch self {
        case .mosquito, .wasp:
            return true
        default:
            return false
        }
    }

    var canBurrow: Bool {
        switch self {
        case .burrower:
            return true
        default:
            return false
        }
    }
}

/// Enemy entity that moves toward the house
@MainActor
class Bug: SKShapeNode {
    let bugType: BugType
    private(set) var currentHealth: Int
    let maxHealth: Int
    let damage: Int  // Difficulty-adjusted damage
    private(set) var gridPosition: GridPosition
    private var movementPath: [GridPosition] = []
    private var pathIndex: Int = 0
    private var moveSpeed: CGFloat

    private var healthBar: SKShapeNode
    private let healthBarBackground: SKShapeNode

    // Debuffs
    var slowFactor: CGFloat = 1.0 // Multiplier for speed (0.5 = half speed)
    var baseSlowFactor: CGFloat = 1.0 // Base slow from cards (persistent)

    // Burrowing state
    private(set) var isBurrowed: Bool = false
    private var burrowTimer: TimeInterval = 0
    private let burrowInterval: TimeInterval = 4.0 // Burrow every 4 seconds
    private let burrowDuration: TimeInterval = 2.0 // Stay burrowed for 2 seconds
    private var burrowIndicator: SKShapeNode?

    init(type: BugType, at position: GridPosition, wave: Int = 1, difficulty: Difficulty = .normal) {
        self.bugType = type

        // Scale health and speed based on wave (1-100)
        // Health: +5% per wave, +50% by wave 10, +250% by wave 50, +500% by wave 100
        let waveScaling = 1.0 + (Double(wave - 1) * 0.05)

        // Apply difficulty multiplier
        let difficultyScaling = difficulty.bugHealthMultiplier

        let scaledHealth = Int(Double(type.health) * waveScaling * Double(difficultyScaling))
        self.currentHealth = scaledHealth
        self.maxHealth = scaledHealth
        self.damage = Int(Double(type.damage) * Double(difficulty.bugDamageMultiplier))
        self.gridPosition = position

        // Speed: +2% per wave (gradually faster)
        let speedScaling = 1.0 + (Double(wave - 1) * 0.02)
        self.moveSpeed = type.speed * CGFloat(speedScaling)

        // Create health bar background
        let barWidth: CGFloat = type.size + 10
        let barHeight: CGFloat = 4
        self.healthBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        self.healthBarBackground.fillColor = .darkGray
        self.healthBarBackground.strokeColor = .clear
        self.healthBarBackground.position = CGPoint(x: 0, y: type.size / 2 + 8)

        // Create health bar
        self.healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        self.healthBar.fillColor = .green
        self.healthBar.strokeColor = .clear
        self.healthBar.position = CGPoint(x: 0, y: type.size / 2 + 8)

        super.init()

        // Create bug sprite using emoji
        let bugSprite = SKLabelNode(text: type.emoji)
        bugSprite.fontSize = type.size * 1.5 // Make emoji slightly larger than the hitbox
        bugSprite.verticalAlignmentMode = .center
        bugSprite.horizontalAlignmentMode = .center
        bugSprite.position = CGPoint(x: 0, y: 0)
        self.addChild(bugSprite)

        // Add subtle background circle for visibility (optional)
        let bgCircle = SKShapeNode(circleOfRadius: type.size / 2)
        bgCircle.fillColor = type.color.withAlphaComponent(0.2)
        bgCircle.strokeColor = .clear
        bgCircle.zPosition = -1
        self.addChild(bgCircle)

        self.addChild(healthBarBackground)
        self.addChild(healthBar)

        // Position bug
        self.position = position.toWorldPosition()

        // Add name for identification
        self.name = "bug"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func takeDamage(_ damage: Int) -> Bool {
        // Burrowed bugs are invulnerable
        if isBurrowed {
            print("🌏 Burrower is underground - no damage taken!")
            return false
        }

        currentHealth -= damage
        updateHealthBar()
        return currentHealth <= 0
    }

    private func updateHealthBar() {
        let healthPercent = CGFloat(currentHealth) / CGFloat(maxHealth)
        let barWidth = (bugType.size + 10) * healthPercent

        healthBar.removeFromParent()
        healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: 4))
        healthBar.fillColor = healthPercent > 0.5 ? .green : (healthPercent > 0.25 ? .yellow : .red)
        healthBar.strokeColor = .clear
        healthBar.position = CGPoint(x: -(bugType.size + 10 - barWidth) / 2, y: bugType.size / 2 + 8)
        self.addChild(healthBar)
    }

    func setPath(_ path: [GridPosition]) {
        self.movementPath = path
        self.pathIndex = 0
    }

    func update(deltaTime: TimeInterval, pathfindingGrid: PathfindingGrid) {
        guard pathIndex < movementPath.count else { return }

        // Handle burrowing for burrower bugs
        if bugType.canBurrow {
            burrowTimer += deltaTime

            if !isBurrowed && burrowTimer >= burrowInterval {
                // Time to burrow
                burrow()
                burrowTimer = 0
            } else if isBurrowed && burrowTimer >= burrowDuration {
                // Time to surface
                surface()
                burrowTimer = 0
            }
        }

        let targetGridPos = movementPath[pathIndex]
        let targetWorldPos = targetGridPos.toWorldPosition()

        // Calculate direction and move
        let dx = targetWorldPos.x - position.x
        let dy = targetWorldPos.y - position.y
        let distance = sqrt(dx * dx + dy * dy)

        if distance < 2 {
            // Reached waypoint
            gridPosition = targetGridPos
            pathIndex += 1
            print("🐛 Bug \(bugType) reached waypoint \(pathIndex-1)/\(movementPath.count) at \(gridPosition)")

            // Don't recalculate path for ground bugs - they follow the predefined road
            // Only flying bugs use dynamic pathfinding
            // (This preserves the winding road mechanic)
        } else {
            // Move toward waypoint
            let moveDistance = moveSpeed * slowFactor * CGFloat(deltaTime)
            let ratio = min(moveDistance / distance, 1.0)
            position.x += dx * ratio
            position.y += dy * ratio
        }
    }

    func hasReachedHouse() -> Bool {
        return gridPosition == MapManager.shared.getCurrentHousePosition()
    }

    func applySlow(factor: CGFloat, duration: TimeInterval) {
        // Apply trap slow on top of base slow from cards
        slowFactor = factor * baseSlowFactor
        run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run { [weak self] in
                // Reset to base slow factor from cards
                self?.slowFactor = self?.baseSlowFactor ?? 1.0
            }
        ]))
    }

    func split() -> [Bug]? {
        guard bugType == .splitter else { return nil }

        // Create two smaller ants at this position
        let ant1 = Bug(type: .ant, at: gridPosition)
        let ant2 = Bug(type: .ant, at: gridPosition)

        // Slight position offset to prevent overlap
        ant1.position.x -= 10
        ant2.position.x += 10

        return [ant1, ant2]
    }

    private func burrow() {
        isBurrowed = true
        // Make bug semi-transparent when burrowed
        alpha = 0.3
        print("🌏 Burrower bug burrowed underground!")

        // Add visual indicator (dirt mound)
        let mound = SKShapeNode(circleOfRadius: bugType.size / 3)
        mound.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.1, alpha: 0.8)
        mound.strokeColor = .clear
        mound.position = CGPoint(x: 0, y: -bugType.size / 3)
        burrowIndicator = mound
        addChild(mound)
    }

    private func surface() {
        isBurrowed = false
        // Restore full opacity
        alpha = 1.0
        print("🌏 Burrower bug surfaced!")

        // Remove visual indicator
        burrowIndicator?.removeFromParent()
        burrowIndicator = nil
    }
}
