import Foundation
import SpriteKit

/// Base class for all defensive structures
@MainActor
class DefenseStructure: SKShapeNode {
    let gridPosition: GridPosition
    var currentHealth: Int
    let maxHealth: Int
    let structureType: StructureType
    var level: Int = 1  // Tower level (1-10)

    private let healthBar: SKShapeNode
    private let healthBarBackground: SKShapeNode
    private let levelLabel: SKLabelNode

    init(type: StructureType, at position: GridPosition) {
        self.structureType = type
        self.gridPosition = position
        self.currentHealth = type.health
        self.maxHealth = type.health

        // Create health bar background
        let barWidth: CGFloat = GameConfiguration.tileSize - 10
        let barHeight: CGFloat = 4
        self.healthBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        self.healthBarBackground.fillColor = .darkGray
        self.healthBarBackground.strokeColor = .clear
        self.healthBarBackground.position = CGPoint(x: 0, y: GameConfiguration.tileSize / 2 + 8)

        // Create health bar
        self.healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        self.healthBar.fillColor = .green
        self.healthBar.strokeColor = .clear
        self.healthBar.position = CGPoint(x: 0, y: GameConfiguration.tileSize / 2 + 8)

        // Create level label
        self.levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.levelLabel.fontSize = 14
        self.levelLabel.fontColor = .yellow
        self.levelLabel.text = "Lv.1"
        self.levelLabel.verticalAlignmentMode = .center
        self.levelLabel.horizontalAlignmentMode = .center
        self.levelLabel.position = CGPoint(x: 0, y: -GameConfiguration.tileSize / 2 - 10)

        super.init()

        self.position = position.toWorldPosition()
        self.name = "structure"

        addChild(healthBarBackground)
        addChild(healthBar)
        addChild(levelLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func takeDamage(_ damage: Int) -> Bool {
        currentHealth -= damage
        updateHealthBar()
        return currentHealth <= 0
    }

    func repair(_ amount: Int) {
        currentHealth = min(maxHealth, currentHealth + amount)
        updateHealthBar()
    }

    func getUpgradeCost() -> Int {
        guard level < 10 else { return 0 }
        // Cost scales: baseCost * level * 0.75
        return Int(Double(structureType.cost) * Double(level) * 0.75)
    }

    func getSellValue() -> Int {
        // Calculate total investment: base cost + all upgrade costs
        let baseCost = structureType.cost
        var totalInvested = baseCost

        // Add all upgrade costs from level 1 to current level
        for lvl in 1..<level {
            let upgradeCost = Int(Double(baseCost) * Double(lvl) * 0.75)
            totalInvested += upgradeCost
        }

        // Return 70% of total investment
        return Int(Double(totalInvested) * 0.7)
    }

    func canUpgrade() -> Bool {
        return level < 10
    }

    func updateLevel(_ newLevel: Int) {
        level = min(10, max(1, newLevel))
        levelLabel.text = "Lv.\(level)"
    }

    private func updateHealthBar() {
        let healthPercent = CGFloat(currentHealth) / CGFloat(maxHealth)
        let barWidth = (GameConfiguration.tileSize - 10) * healthPercent

        healthBar.removeFromParent()
        let newHealthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: 4))
        newHealthBar.fillColor = healthPercent > 0.5 ? .green : (healthPercent > 0.25 ? .yellow : .red)
        newHealthBar.strokeColor = .clear
        newHealthBar.position = CGPoint(
            x: -(GameConfiguration.tileSize - 10 - barWidth) / 2,
            y: GameConfiguration.tileSize / 2 + 8
        )
        addChild(newHealthBar)
    }

    // Override in subclasses
    func update(deltaTime: TimeInterval, bugs: [Bug]) {}
}

/// Types of defensive structures
enum StructureType {
    case basicTower
    case sniperTower
    case machineGunTower      // NEW: Fast firing tower
    case cannonTower          // NEW: AoE splash damage (unlocks wave 20)
    case lightningTower       // NEW: Chain lightning (unlocks wave 30)
    case freezeTower          // NEW: Area slow (unlocks wave 40)
    case poisonTower          // NEW: Damage over time (unlocks wave 50)
    case laserTower           // NEW: High damage beam (unlocks wave 60)
    case flameTower           // NEW: Streams fire, hits ground and air bugs
    case bladeTower           // NEW: Shoots daggers, hits ground and air bugs
    case earthquakeTower      // NEW: Shakes ground, damages and slows ground bugs
    case slowTrap

    var cost: Int {
        switch self {
        case .basicTower: return 50
        case .sniperTower: return 100
        case .machineGunTower: return 75
        case .cannonTower: return 150
        case .lightningTower: return 200
        case .freezeTower: return 175
        case .poisonTower: return 225
        case .laserTower: return 300
        case .flameTower: return 180
        case .bladeTower: return 190
        case .earthquakeTower: return 210
        case .slowTrap: return 30
        }
    }

    var health: Int {
        switch self {
        case .basicTower: return 100
        case .sniperTower: return 80
        case .machineGunTower: return 90
        case .cannonTower: return 120
        case .lightningTower: return 100
        case .freezeTower: return 110
        case .poisonTower: return 95
        case .laserTower: return 85
        case .flameTower: return 105
        case .bladeTower: return 100
        case .earthquakeTower: return 115
        case .slowTrap: return 50
        }
    }

    var displayName: String {
        switch self {
        case .basicTower: return "Basic Tower"
        case .sniperTower: return "Sniper Tower"
        case .machineGunTower: return "Machine Gun"
        case .cannonTower: return "Cannon Tower"
        case .lightningTower: return "Lightning Tower"
        case .freezeTower: return "Freeze Tower"
        case .poisonTower: return "Poison Tower"
        case .laserTower: return "Laser Tower"
        case .flameTower: return "Flame Tower"
        case .bladeTower: return "Blade Tower"
        case .earthquakeTower: return "Earthquake Tower"
        case .slowTrap: return "Slow Trap"
        }
    }

    var unlockWave: Int {
        switch self {
        case .basicTower, .sniperTower, .machineGunTower, .slowTrap:
            return 0 // Available from start (wave 0)
        case .cannonTower:
            return 5
        case .lightningTower:
            return 10
        case .freezeTower:
            return 15
        case .poisonTower:
            return 20
        case .laserTower:
            return 25
        case .flameTower:
            return 30
        case .bladeTower:
            return 35
        case .earthquakeTower:
            return 40
        }
    }

    var color: SKColor {
        switch self {
        case .basicTower: return .cyan
        case .sniperTower: return .blue
        case .machineGunTower: return .orange
        case .cannonTower: return .brown
        case .lightningTower: return .purple
        case .freezeTower: return SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0) // Light blue
        case .poisonTower: return .green
        case .laserTower: return .red
        case .flameTower: return SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0) // Bright orange
        case .bladeTower: return .gray
        case .earthquakeTower: return SKColor(red: 0.6, green: 0.3, blue: 0.0, alpha: 1.0) // Earth brown
        case .slowTrap: return .purple
        }
    }

    var emoji: String {
        switch self {
        case .basicTower: return "🗼"
        case .sniperTower: return "🎯"
        case .machineGunTower: return "🔫"
        case .cannonTower: return "💥"
        case .lightningTower: return "⚡"
        case .freezeTower: return "❄️"
        case .poisonTower: return "☢️"
        case .laserTower: return "🔴"
        case .flameTower: return "🔥"
        case .bladeTower: return "🗡️"
        case .earthquakeTower: return "🌍"
        case .slowTrap: return "🕸️"
        }
    }
}

/// Tower that shoots at bugs
@MainActor
class Tower: DefenseStructure {
    private let baseRange: CGFloat
    private var range: CGFloat
    private let baseDamage: Int
    private var damage: Int
    private let baseAttackSpeed: TimeInterval
    private var attackSpeed: TimeInterval // Attacks per second
    private var timeSinceLastAttack: TimeInterval = 0
    private var currentTarget: Bug?

    private var rangeIndicator: SKShapeNode

    var damageMultiplier: CGFloat = 1.0 // From attack upgrades
    var attackSpeedMultiplier: CGFloat = 1.0 // From speed upgrades
    var rangeMultiplier: CGFloat = 1.0 // From research upgrades

    private var effectiveRange: CGFloat {
        return baseRange * rangeMultiplier
    }

    init(type: StructureType, at position: GridPosition, range: CGFloat, damage: Int, attackSpeed: TimeInterval) {
        self.baseRange = range
        self.range = range
        self.baseDamage = damage
        self.damage = damage
        self.baseAttackSpeed = attackSpeed
        self.attackSpeed = attackSpeed

        // Create range indicator (initially hidden)
        self.rangeIndicator = SKShapeNode(circleOfRadius: range)
        self.rangeIndicator.strokeColor = SKColor.white.withAlphaComponent(0.3)
        self.rangeIndicator.lineWidth = 2
        self.rangeIndicator.fillColor = .clear
        self.rangeIndicator.isHidden = true

        super.init(type: type, at: position)

        // Create tower sprite using emoji
        let towerSprite = SKLabelNode(text: type.emoji)
        towerSprite.fontSize = GameConfiguration.tileSize * 1.2
        towerSprite.verticalAlignmentMode = .center
        towerSprite.horizontalAlignmentMode = .center
        addChild(towerSprite)

        // Add subtle background circle for visibility
        let bgCircle = SKShapeNode(circleOfRadius: GameConfiguration.tileSize * 0.45)
        bgCircle.fillColor = type.color.withAlphaComponent(0.2)
        bgCircle.strokeColor = type.color.withAlphaComponent(0.5)
        bgCircle.lineWidth = 2
        bgCircle.zPosition = -1
        addChild(bgCircle)

        // Add turret indicator (small rotating dot for targeting)
        let turret = SKShapeNode(circleOfRadius: 4)
        turret.fillColor = .white
        turret.strokeColor = .black
        turret.lineWidth = 1
        turret.name = "turret"
        turret.position = CGPoint(x: 0, y: GameConfiguration.tileSize * 0.35)
        addChild(turret)

        addChild(rangeIndicator)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime: TimeInterval, bugs: [Bug]) {
        timeSinceLastAttack += deltaTime

        // Get module bonuses
        let moduleBonuses = getModuleBonuses()

        // Find target
        if currentTarget == nil || currentTarget?.parent == nil {
            currentTarget = findNearestBug(in: bugs)
        }

        guard let target = currentTarget else { return }

        // Check if target is still in range (including module range bonus)
        let totalRangeMultiplier = rangeMultiplier * moduleBonuses.rangeMultiplier
        let effectiveRangeWithModules = baseRange * totalRangeMultiplier
        let distance = distanceTo(bug: target)
        if distance > effectiveRangeWithModules {
            currentTarget = nil
            return
        }

        // Rotate turret toward target
        if let turret = childNode(withName: "turret") {
            let angle = atan2(target.position.y - position.y, target.position.x - position.x)
            turret.zRotation = angle
        }

        // Attack if cooldown is ready (including module attack speed bonus)
        let totalAttackSpeedMultiplier = attackSpeedMultiplier * moduleBonuses.attackSpeedMultiplier
        let effectiveAttackSpeed = attackSpeed / Double(totalAttackSpeedMultiplier)
        if timeSinceLastAttack >= effectiveAttackSpeed {
            attack(target, bugs: bugs, moduleBonuses: moduleBonuses)
            timeSinceLastAttack = 0
        }
    }

    private func findNearestBug(in bugs: [Bug]) -> Bug? {
        var nearest: Bug?
        var nearestDistance: CGFloat = .infinity

        for bug in bugs {
            // Skip burrowed bugs - they're underground and can't be targeted
            if bug.isBurrowed {
                continue
            }

            let distance = distanceTo(bug: bug)
            if distance <= effectiveRange && distance < nearestDistance {
                nearest = bug
                nearestDistance = distance
            }
        }

        return nearest
    }

    private func distanceTo(bug: Bug) -> CGFloat {
        let dx = bug.position.x - position.x
        let dy = bug.position.y - position.y
        return sqrt(dx * dx + dy * dy)
    }

    func upgradeTower() {
        guard canUpgrade() else { return }
        level += 1
        updateLevel(level)

        // Scale damage: +20% per level
        damage = Int(Double(baseDamage) * (1.0 + 0.2 * Double(level - 1)))

        // Scale range: +5% per level
        range = baseRange * CGFloat(1.0 + 0.05 * Double(level - 1))

        // Scale attack speed: +10% per level (lower cooldown = faster)
        attackSpeed = baseAttackSpeed * (1.0 - 0.1 * Double(level - 1))

        // Update range indicator
        let wasHidden = rangeIndicator.isHidden
        rangeIndicator.removeFromParent()
        rangeIndicator = SKShapeNode(circleOfRadius: range)
        rangeIndicator.strokeColor = SKColor.white.withAlphaComponent(0.3)
        rangeIndicator.lineWidth = 2
        rangeIndicator.fillColor = .clear
        rangeIndicator.isHidden = wasHidden
        addChild(rangeIndicator)
    }

    private func attack(_ bug: Bug, bugs: [Bug], moduleBonuses: ModuleBonuses) {
        // Calculate base damage with all multipliers
        var effectiveDamage = Int(CGFloat(damage) * damageMultiplier * moduleBonuses.damageMultiplier)

        // Check for critical hit
        if CGFloat.random(in: 0...1) < moduleBonuses.criticalChance {
            effectiveDamage = Int(CGFloat(effectiveDamage) * 2.0) // Double damage on crit
        }

        // Apply damage to primary target
        let _ = bug.takeDamage(effectiveDamage)

        // Apply lifesteal (heal tower)
        if moduleBonuses.lifesteal > 0 {
            let healAmount = Int(CGFloat(effectiveDamage) * moduleBonuses.lifesteal)
            repair(healAmount)
        }

        // Splash damage to nearby bugs
        if moduleBonuses.splashDamage > 0 {
            let splashRadius: CGFloat = 60.0
            let splashDamageAmount = Int(CGFloat(effectiveDamage) * moduleBonuses.splashDamage)

            for nearbyBug in bugs where nearbyBug !== bug {
                let dx = nearbyBug.position.x - bug.position.x
                let dy = nearbyBug.position.y - bug.position.y
                let distance = sqrt(dx * dx + dy * dy)

                if distance <= splashRadius {
                    let _ = nearbyBug.takeDamage(splashDamageAmount)
                }
            }
        }

        // Piercing (damage through multiple bugs in a line)
        if CGFloat.random(in: 0...1) < moduleBonuses.piercingChance {
            let pierceDamage = effectiveDamage / 2 // Half damage for piercing
            for pierceBug in bugs where pierceBug !== bug {
                let dx = pierceBug.position.x - bug.position.x
                let dy = pierceBug.position.y - bug.position.y
                let distance = sqrt(dx * dx + dy * dy)

                // Check if bug is roughly in line with the shot
                if distance < 100 {
                    let _ = pierceBug.takeDamage(pierceDamage)
                }
            }
        }

        // Multishot (attack additional random targets)
        if CGFloat.random(in: 0...1) < moduleBonuses.multishotChance {
            let additionalTargets = bugs.filter { $0 !== bug && distanceTo(bug: $0) <= effectiveRange }
            if let randomTarget = additionalTargets.randomElement() {
                let multishotDamage = effectiveDamage / 2
                let _ = randomTarget.takeDamage(multishotDamage)

                // Create additional projectile
                createProjectile(to: randomTarget.position)
            }
        }

        // Tower-specific special mechanics
        applyTowerSpecialEffects(bug: bug, bugs: bugs, damage: effectiveDamage)

        // Create projectile animation
        createProjectile(to: bug.position)
    }

    private func applyTowerSpecialEffects(bug: Bug, bugs: [Bug], damage: Int) {
        switch structureType {
        case .cannonTower:
            // Cannon: Built-in splash damage (larger radius than module splash)
            let splashRadius: CGFloat = 80.0
            let splashDamage = damage / 2

            for nearbyBug in bugs where nearbyBug !== bug {
                let dx = nearbyBug.position.x - bug.position.x
                let dy = nearbyBug.position.y - bug.position.y
                let distance = sqrt(dx * dx + dy * dy)

                if distance <= splashRadius {
                    let _ = nearbyBug.takeDamage(splashDamage)
                }
            }

        case .lightningTower:
            // Lightning: Chain to up to 3 nearby bugs
            let chainRadius: CGFloat = 100.0
            let chainDamage = damage / 2
            var chainedBugs: Set<ObjectIdentifier> = [ObjectIdentifier(bug)]
            var currentBug = bug
            var chainsRemaining = 3

            while chainsRemaining > 0 {
                // Find closest unchained bug
                var closestBug: Bug?
                var closestDistance: CGFloat = .infinity

                for nearbyBug in bugs where !chainedBugs.contains(ObjectIdentifier(nearbyBug)) {
                    let dx = nearbyBug.position.x - currentBug.position.x
                    let dy = nearbyBug.position.y - currentBug.position.y
                    let distance = sqrt(dx * dx + dy * dy)

                    if distance <= chainRadius && distance < closestDistance {
                        closestBug = nearbyBug
                        closestDistance = distance
                    }
                }

                if let nextBug = closestBug {
                    let _ = nextBug.takeDamage(chainDamage)
                    chainedBugs.insert(ObjectIdentifier(nextBug))

                    // Visual chain lightning effect
                    createLightningArc(from: currentBug.position, to: nextBug.position)

                    currentBug = nextBug
                    chainsRemaining -= 1
                } else {
                    break // No more bugs in range
                }
            }

        case .freezeTower:
            // Freeze: Slow all bugs in area around the tower (not around target)
            let freezeRadius: CGFloat = 100.0
            let slowFactor: CGFloat = 0.5 // 50% slow
            let slowDuration: TimeInterval = 3.0

            // Create visual freeze effect
            let freezeWave = SKShapeNode(circleOfRadius: freezeRadius)
            freezeWave.strokeColor = SKColor.cyan.withAlphaComponent(0.8)
            freezeWave.lineWidth = 3
            freezeWave.fillColor = SKColor.cyan.withAlphaComponent(0.2)
            freezeWave.position = position
            freezeWave.setScale(0.1)
            if let parent = parent {
                parent.addChild(freezeWave)
                freezeWave.run(SKAction.sequence([
                    SKAction.scale(to: 1.0, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent()
                ]))
            }

            for nearbyBug in bugs {
                // Measure distance from the TOWER, not from the target bug
                let dx = nearbyBug.position.x - position.x
                let dy = nearbyBug.position.y - position.y
                let distance = sqrt(dx * dx + dy * dy)

                if distance <= freezeRadius {
                    nearbyBug.applySlow(factor: slowFactor, duration: slowDuration)
                }
            }

        case .poisonTower:
            // Poison: Apply damage over time
            applyPoison(to: bug, totalDamage: damage, duration: 5.0)

        case .laserTower:
            // Laser: Instant beam damage (visual effect only, damage already applied)
            createLaserBeam(to: bug.position)

        default:
            // Other towers have no special effects beyond modules
            break
        }
    }

    private func applyPoison(to bug: Bug, totalDamage: Int, duration: TimeInterval) {
        let ticks = 5
        let damagePerTick = totalDamage / ticks
        let tickInterval = duration / Double(ticks)

        for tick in 1...ticks {
            let delay = tickInterval * Double(tick)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak bug] in
                if let bug = bug, bug.parent != nil {
                    let _ = bug.takeDamage(damagePerTick)
                }
            }
        }
    }

    private func createLightningArc(from start: CGPoint, to end: CGPoint) {
        let arc = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        arc.path = path
        arc.strokeColor = .purple
        arc.lineWidth = 3
        arc.glowWidth = 5

        parent?.addChild(arc)

        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        arc.run(SKAction.sequence([fadeOut, remove]))
    }

    private func createLaserBeam(to target: CGPoint) {
        let beam = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: position)
        path.addLine(to: target)
        beam.path = path
        beam.strokeColor = .red
        beam.lineWidth = 2
        beam.glowWidth = 10

        parent?.addChild(beam)

        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        beam.run(SKAction.sequence([fadeOut, remove]))
    }

    private func createProjectile(to targetPosition: CGPoint) {
        let projectile = SKShapeNode(circleOfRadius: 3)
        projectile.fillColor = .yellow
        projectile.strokeColor = .clear
        projectile.position = position

        parent?.addChild(projectile)

        let moveAction = SKAction.move(to: targetPosition, duration: 0.2)
        let removeAction = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([moveAction, removeAction]))
    }

    func showRange() {
        rangeIndicator.isHidden = false
        updateRangeIndicator()
    }

    func hideRange() {
        rangeIndicator.isHidden = true
    }

    func updateRangeIndicator() {
        rangeIndicator.removeFromParent()
        let newIndicator = SKShapeNode(circleOfRadius: effectiveRange)
        newIndicator.strokeColor = SKColor.white.withAlphaComponent(0.3)
        newIndicator.lineWidth = 2
        newIndicator.fillColor = .clear
        newIndicator.isHidden = rangeIndicator.isHidden
        parent?.addChild(newIndicator)
    }
}

/// Trap that slows bugs
@MainActor
class SlowTrap: DefenseStructure {
    private let range: CGFloat
    private let slowFactor: CGFloat
    private let slowDuration: TimeInterval
    private var affectedBugs: Set<ObjectIdentifier> = []

    init(at position: GridPosition) {
        self.range = GameConfiguration.tileSize * 1.5
        self.slowFactor = 0.5
        self.slowDuration = 2.0

        super.init(type: .slowTrap, at: position)

        // Create trap sprite using emoji
        let trapSprite = SKLabelNode(text: StructureType.slowTrap.emoji)
        trapSprite.fontSize = GameConfiguration.tileSize * 1.0
        trapSprite.verticalAlignmentMode = .center
        trapSprite.horizontalAlignmentMode = .center
        addChild(trapSprite)

        // Add subtle background circle
        let bgCircle = SKShapeNode(circleOfRadius: GameConfiguration.tileSize * 0.35)
        bgCircle.fillColor = SKColor.purple.withAlphaComponent(0.2)
        bgCircle.strokeColor = SKColor.purple.withAlphaComponent(0.5)
        bgCircle.lineWidth = 2
        bgCircle.zPosition = -1
        addChild(bgCircle)

        // Add effect indicator
        let effectCircle = SKShapeNode(circleOfRadius: range)
        effectCircle.strokeColor = SKColor.purple.withAlphaComponent(0.3)
        effectCircle.fillColor = .clear
        effectCircle.lineWidth = 2
        effectCircle.zPosition = -2
        addChild(effectCircle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime: TimeInterval, bugs: [Bug]) {
        for bug in bugs {
            let distance = distanceTo(bug: bug)
            let bugId = ObjectIdentifier(bug)

            if distance <= range && !affectedBugs.contains(bugId) {
                bug.applySlow(factor: slowFactor, duration: slowDuration)
                affectedBugs.insert(bugId)

                // Reset after duration
                DispatchQueue.main.asyncAfter(deadline: .now() + slowDuration) { [weak self] in
                    self?.affectedBugs.remove(bugId)
                }
            }
        }
    }

    private func distanceTo(bug: Bug) -> CGFloat {
        let dx = bug.position.x - position.x
        let dy = bug.position.y - position.y
        return sqrt(dx * dx + dy * dy)
    }
}
