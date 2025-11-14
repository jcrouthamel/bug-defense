import Foundation
import SpriteKit

/// The player-controlled hero character
@MainActor
class Hero: SKNode {
    private let gridPosition: GridPosition
    private var currentGridPosition: GridPosition
    private var currentHealth: Int
    private let maxHealth: Int
    private let damage: Int
    private let attackSpeed: TimeInterval
    private var timeSinceLastAttack: TimeInterval = 0

    private let sprite: SKLabelNode
    private let healthBar: SKShapeNode
    private let healthBarBackground: SKShapeNode

    // Movement
    private var targetPosition: GridPosition?
    private let moveSpeed: CGFloat = 200.0 // pixels per second
    private var isMoving: Bool = false

    // Combat
    private var currentTarget: Bug?
    private let attackRange: CGFloat

    init(at position: GridPosition) {
        self.gridPosition = position
        self.currentGridPosition = position
        self.maxHealth = 200
        self.currentHealth = maxHealth
        self.damage = 25
        self.attackSpeed = 0.5 // Attack every 0.5 seconds
        self.attackRange = GameConfiguration.tileSize * 1.5

        // Create hero sprite
        self.sprite = SKLabelNode(text: "🧙‍♂️")
        self.sprite.fontSize = GameConfiguration.tileSize * 1.5
        self.sprite.verticalAlignmentMode = .center
        self.sprite.horizontalAlignmentMode = .center
        self.sprite.zPosition = 10 // Above most other objects

        // Create health bar background
        let barWidth: CGFloat = GameConfiguration.tileSize
        let barHeight: CGFloat = 5
        self.healthBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        self.healthBarBackground.fillColor = .darkGray
        self.healthBarBackground.strokeColor = .clear
        self.healthBarBackground.position = CGPoint(x: 0, y: GameConfiguration.tileSize * 0.8)
        self.healthBarBackground.zPosition = 11

        // Create health bar
        self.healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        self.healthBar.fillColor = .green
        self.healthBar.strokeColor = .clear
        self.healthBar.position = CGPoint(x: 0, y: GameConfiguration.tileSize * 0.8)
        self.healthBar.zPosition = 12

        super.init()

        self.position = position.toWorldPosition()
        self.name = "hero"

        addChild(sprite)
        addChild(healthBarBackground)
        addChild(healthBar)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: TimeInterval, bugs: [Bug]) {
        timeSinceLastAttack += deltaTime

        // Handle movement
        if let target = targetPosition {
            moveToward(target: target, deltaTime: deltaTime)
        }

        // Handle combat
        if !isMoving {
            findAndAttackNearestBug(bugs: bugs)
        }
    }

    func moveTo(gridPosition: GridPosition) {
        targetPosition = gridPosition
        isMoving = true
    }

    private func moveToward(target: GridPosition, deltaTime: TimeInterval) {
        let targetWorldPos = target.toWorldPosition()
        let dx = targetWorldPos.x - position.x
        let dy = targetWorldPos.y - position.y
        let distance = sqrt(dx * dx + dy * dy)

        if distance < 5.0 {
            // Reached target
            position = targetWorldPos
            currentGridPosition = target
            targetPosition = nil
            isMoving = false
        } else {
            // Move toward target
            let moveDistance = moveSpeed * CGFloat(deltaTime)
            let ratio = min(1.0, moveDistance / distance)
            position.x += dx * ratio
            position.y += dy * ratio
        }
    }

    private func findAndAttackNearestBug(bugs: [Bug]) {
        // Find nearest bug in range
        var nearestBug: Bug?
        var nearestDistance: CGFloat = .infinity

        for bug in bugs {
            // Skip burrowed bugs
            if bug.isBurrowed {
                continue
            }

            let dx = bug.position.x - position.x
            let dy = bug.position.y - position.y
            let distance = sqrt(dx * dx + dy * dy)

            if distance <= attackRange && distance < nearestDistance {
                nearestBug = bug
                nearestDistance = distance
            }
        }

        currentTarget = nearestBug

        // Attack if we have a target and attack is ready
        if let target = currentTarget, timeSinceLastAttack >= attackSpeed {
            attack(target)
            timeSinceLastAttack = 0
        }
    }

    private func attack(_ bug: Bug) {
        // Deal damage to bug
        let _ = bug.takeDamage(damage)
        print("🧙‍♂️ Hero attacked bug for \(damage) damage!")

        // Hero attack animation - pulse effect
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        sprite.run(SKAction.sequence([scaleUp, scaleDown]))

        // Create sword slash animation at bug's position
        let slash = SKLabelNode(text: "⚔️")
        slash.fontSize = GameConfiguration.tileSize * 1.2
        slash.position = bug.position
        slash.zPosition = 15
        parent?.addChild(slash)

        // Animate slash with rotation and scaling
        let rotate = SKAction.rotate(byAngle: .pi, duration: 0.3)
        let scaleUpSlash = SKAction.scale(to: 1.5, duration: 0.15)
        let scaleDownSlash = SKAction.scale(to: 0.5, duration: 0.15)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        slash.run(SKAction.sequence([
            SKAction.group([rotate, scaleUpSlash]),
            SKAction.group([scaleDownSlash, fadeOut]),
            remove
        ]))

        // Flash effect on bug
        if let bugSprite = bug.children.first as? SKLabelNode {
            let originalColor = bugSprite.fontColor
            let flash = SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1),
                SKAction.colorize(with: originalColor ?? .white, colorBlendFactor: 1.0, duration: 0.1)
            ])
            bugSprite.run(flash)
        }

        // Create damage number
        let damageLabel = SKLabelNode(text: "-\(damage)")
        damageLabel.fontSize = 20
        damageLabel.fontColor = .red
        damageLabel.fontName = "Helvetica-Bold"
        damageLabel.position = bug.position
        damageLabel.zPosition = 20
        parent?.addChild(damageLabel)

        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 0.6)
        let fadeOutLabel = SKAction.fadeOut(withDuration: 0.6)
        let scaleLabel = SKAction.scale(to: 1.3, duration: 0.3)
        let removeLabel = SKAction.removeFromParent()
        damageLabel.run(SKAction.sequence([
            SKAction.group([moveUp, fadeOutLabel, scaleLabel]),
            removeLabel
        ]))
    }

    func takeDamage(_ damage: Int) {
        currentHealth = max(0, currentHealth - damage)
        updateHealthBar()
    }

    func heal(_ amount: Int) {
        currentHealth = min(maxHealth, currentHealth + amount)
        updateHealthBar()
    }

    private func updateHealthBar() {
        let healthPercent = CGFloat(currentHealth) / CGFloat(maxHealth)
        let barWidth = GameConfiguration.tileSize * healthPercent

        healthBar.removeFromParent()
        let newHealthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: 5))
        newHealthBar.fillColor = healthPercent > 0.5 ? .green : (healthPercent > 0.25 ? .yellow : .red)
        newHealthBar.strokeColor = .clear
        newHealthBar.position = CGPoint(
            x: -(GameConfiguration.tileSize - barWidth) / 2,
            y: GameConfiguration.tileSize * 0.8
        )
        newHealthBar.zPosition = 12
        addChild(newHealthBar)
    }

    func getCurrentHealth() -> Int {
        return currentHealth
    }

    func getMaxHealth() -> Int {
        return maxHealth
    }

    func getGridPosition() -> GridPosition {
        return currentGridPosition
    }

    func isDead() -> Bool {
        return currentHealth <= 0
    }
}
