import Foundation
import SpriteKit

/// The house that the player must defend
@MainActor
class House: SKShapeNode {
    private let gridPosition: GridPosition
    private var currentHealth: Int
    private let maxHealth: Int

    private let healthLabel: SKLabelNode

    init(at position: GridPosition, health: Int) {
        self.gridPosition = position
        self.currentHealth = health
        self.maxHealth = health

        self.healthLabel = SKLabelNode(fontNamed: "Arial")
        self.healthLabel.fontSize = 16
        self.healthLabel.fontColor = .white
        self.healthLabel.verticalAlignmentMode = .center
        self.healthLabel.horizontalAlignmentMode = .center

        super.init()

        // Create house sprite using emoji
        let houseSprite = SKLabelNode(text: "🏠")
        houseSprite.fontSize = GameConfiguration.tileSize * 2.0
        houseSprite.verticalAlignmentMode = .center
        houseSprite.horizontalAlignmentMode = .center
        houseSprite.zPosition = 1
        self.addChild(houseSprite)

        // Add subtle background circle for emphasis
        let bgCircle = SKShapeNode(circleOfRadius: GameConfiguration.tileSize * 0.8)
        bgCircle.fillColor = SKColor.blue.withAlphaComponent(0.2)
        bgCircle.strokeColor = SKColor.blue.withAlphaComponent(0.5)
        bgCircle.lineWidth = 3
        bgCircle.zPosition = 0
        self.addChild(bgCircle)

        // Add health label below the house
        healthLabel.position = CGPoint(x: 0, y: -GameConfiguration.tileSize * 1.2)
        healthLabel.text = "\(currentHealth)/\(maxHealth)"
        healthLabel.zPosition = 2
        self.addChild(healthLabel)

        // Position house
        self.position = position.toWorldPosition()
        self.name = "house"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func takeDamage(_ damage: Int) -> Int {
        currentHealth = max(0, currentHealth - damage)
        updateHealthLabel()
        return currentHealth
    }

    func heal(_ amount: Int) {
        currentHealth = min(maxHealth, currentHealth + amount)
        updateHealthLabel()
    }

    private func updateHealthLabel() {
        healthLabel.text = "\(currentHealth)/\(maxHealth)"

        let healthPercent = CGFloat(currentHealth) / CGFloat(maxHealth)
        if healthPercent > 0.5 {
            healthLabel.fontColor = .white
        } else if healthPercent > 0.25 {
            healthLabel.fontColor = .yellow
        } else {
            healthLabel.fontColor = .red
        }
    }

    func getGridPosition() -> GridPosition {
        return gridPosition
    }

    func getCurrentHealth() -> Int {
        return currentHealth
    }

    func getMaxHealth() -> Int {
        return maxHealth
    }
}
