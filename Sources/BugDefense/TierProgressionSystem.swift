import Foundation
import SpriteKit

/// Represents a tier in the game progression
struct Tier {
    let number: Int
    let name: String
    let waveRange: ClosedRange<Int>
    let mapType: MapType
    let icon: String

    var isCompleted: Bool {
        return false // Will be determined by game state
    }
}

/// Manages tier progression through the game
@MainActor
class TierProgressionManager {
    static let shared = TierProgressionManager()

    // Define all tiers - 100 waves per tier
    let tiers: [Tier] = [
        Tier(number: 1, name: "Village", waveRange: 1...100, mapType: .map1, icon: "🏘️"),
        Tier(number: 2, name: "Town", waveRange: 101...200, mapType: .map1, icon: "🏙️"),
        Tier(number: 3, name: "City", waveRange: 201...300, mapType: .map1, icon: "🌆"),
        Tier(number: 4, name: "Metropolis", waveRange: 301...400, mapType: .map1, icon: "🏢")
    ]

    private init() {}

    /// Get the current tier based on wave number
    func getCurrentTier(for wave: Int) -> Tier {
        return tiers.first { $0.waveRange.contains(wave) } ?? tiers[0]
    }

    /// Get tier by number
    func getTier(_ number: Int) -> Tier? {
        return tiers.first { $0.number == number }
    }

    /// Check if a tier is completed
    func isTierCompleted(_ tierNumber: Int, currentWave: Int) -> Bool {
        guard let tier = getTier(tierNumber) else { return false }
        return currentWave > tier.waveRange.upperBound
    }

    /// Check if just completed a tier (reached boss wave)
    func justCompletedTier(wave: Int) -> Bool {
        // Tier completion happens at waves 100, 200, 300, 400
        return wave == 100 || wave == 200 || wave == 300 || wave == 400
    }

    /// Get the next tier after completion
    func getNextTier(after wave: Int) -> Tier? {
        let currentTier = getCurrentTier(for: wave)
        return tiers.first { $0.number == currentTier.number + 1 }
    }

    /// Automatically change map based on current wave - selects random map every 10 waves
    func updateMapForWave(_ wave: Int) {
        let tier = getCurrentTier(for: wave)

        // Select a new random map every 10 waves or at the start
        if wave == 1 || wave % 10 == 1 {
            MapManager.shared.selectRandomMap()
            print("🎲 New random map selected for wave \(wave)")
        }

        print("🏆 Now in Tier \(tier.number): \(tier.name) (Waves \(tier.waveRange.lowerBound)-\(tier.waveRange.upperBound))")
    }
}

/// UI that shows tier progression as a road with houses
@MainActor
class TierProgressionUI: SKNode {
    private let size: CGSize
    private let currentWave: Int
    private let onClose: () -> Void

    init(size: CGSize, currentWave: Int, onClose: @escaping () -> Void) {
        self.size = size
        self.currentWave = currentWave
        self.onClose = onClose

        super.init()

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        // Semi-transparent background
        let background = SKShapeNode(rectOf: size)
        background.fillColor = SKColor.black.withAlphaComponent(0.85)
        background.strokeColor = .clear
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)

        // Title
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "🏆 TIER PROGRESSION 🏆"
        title.fontSize = 32
        title.fontColor = .yellow
        title.position = CGPoint(x: 0, y: halfHeight - 60)
        addChild(title)

        // Current tier info
        let currentTier = TierProgressionManager.shared.getCurrentTier(for: currentWave)
        let tierInfo = SKLabelNode(fontNamed: "Helvetica")
        tierInfo.text = "Currently in: \(currentTier.icon) \(currentTier.name) (Waves \(currentTier.waveRange.lowerBound)-\(currentTier.waveRange.upperBound))"
        tierInfo.fontSize = 18
        tierInfo.fontColor = .white
        tierInfo.position = CGPoint(x: 0, y: halfHeight - 100)
        addChild(tierInfo)

        // Draw tier progression road
        drawTierRoad()

        // Close button
        let closeButton = Button(
            text: "✕ Close",
            size: CGSize(width: 120, height: 50),
            color: .green
        )
        closeButton.position = CGPoint(x: 0, y: -halfHeight + 60)
        closeButton.onTap = { [weak self] in
            self?.onClose()
        }
        addChild(closeButton)

        isUserInteractionEnabled = true
    }

    private func drawTierRoad() {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        let tiers = TierProgressionManager.shared.tiers
        let roadStartY: CGFloat = halfHeight - 180
        let houseSpacing: CGFloat = 160
        let startX: CGFloat = -halfWidth + 100

        // Draw road (horizontal path)
        for i in 0..<(tiers.count - 1) {
            let x1 = startX + CGFloat(i) * houseSpacing + 60
            let x2 = startX + CGFloat(i + 1) * houseSpacing - 60

            let road = SKShapeNode(rectOf: CGSize(width: x2 - x1, height: 8), cornerRadius: 4)
            road.fillColor = .brown
            road.strokeColor = .clear
            road.position = CGPoint(x: (x1 + x2) / 2, y: roadStartY)
            addChild(road)
        }

        // Draw tier houses
        for (index, tier) in tiers.enumerated() {
            let houseX = startX + CGFloat(index) * houseSpacing
            let houseNode = createTierHouse(tier: tier, currentWave: currentWave)
            houseNode.position = CGPoint(x: houseX, y: roadStartY)
            addChild(houseNode)
        }
    }

    private func createTierHouse(tier: Tier, currentWave: Int) -> SKNode {
        let container = SKNode()

        let isCompleted = TierProgressionManager.shared.isTierCompleted(tier.number, currentWave: currentWave)
        let isCurrent = tier.waveRange.contains(currentWave)

        // House background
        let houseSize: CGFloat = 100
        let house = SKShapeNode(rectOf: CGSize(width: houseSize, height: houseSize), cornerRadius: 10)

        if isCompleted {
            house.fillColor = SKColor.green.withAlphaComponent(0.3)
            house.strokeColor = .green
        } else if isCurrent {
            house.fillColor = SKColor.yellow.withAlphaComponent(0.3)
            house.strokeColor = .yellow
        } else {
            house.fillColor = SKColor.gray.withAlphaComponent(0.2)
            house.strokeColor = .darkGray
        }
        house.lineWidth = 3
        container.addChild(house)

        // Icon
        let icon = SKLabelNode(fontNamed: "Helvetica")
        icon.text = tier.icon
        icon.fontSize = 40
        icon.position = CGPoint(x: 0, y: 15)
        container.addChild(icon)

        // Tier name
        let name = SKLabelNode(fontNamed: "Helvetica-Bold")
        name.text = tier.name
        name.fontSize = 14
        name.fontColor = .white
        name.position = CGPoint(x: 0, y: -15)
        container.addChild(name)

        // Wave range
        let waves = SKLabelNode(fontNamed: "Helvetica")
        waves.text = "Waves \(tier.waveRange.lowerBound)-\(tier.waveRange.upperBound)"
        waves.fontSize = 11
        waves.fontColor = .lightGray
        waves.position = CGPoint(x: 0, y: -30)
        container.addChild(waves)

        // Status badge
        if isCompleted {
            let checkmark = SKLabelNode(fontNamed: "Helvetica")
            checkmark.text = "✓"
            checkmark.fontSize = 30
            checkmark.fontColor = .green
            checkmark.position = CGPoint(x: 35, y: 25)
            container.addChild(checkmark)
        } else if isCurrent {
            let current = SKLabelNode(fontNamed: "Helvetica-Bold")
            current.text = "◀"
            current.fontSize = 20
            current.fontColor = .yellow
            current.position = CGPoint(x: -60, y: -5)
            container.addChild(current)
        }

        return container
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        // Block clicks from passing through
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Block taps from passing through
    }
    #endif
}

/// Congratulation popup shown when completing a tier
@MainActor
class TierCompletionPopup: SKNode {
    private let size: CGSize
    private let completedTier: Tier
    private let nextTier: Tier?
    private let onContinue: () -> Void

    init(size: CGSize, completedTier: Tier, nextTier: Tier?, onContinue: @escaping () -> Void) {
        self.size = size
        self.completedTier = completedTier
        self.nextTier = nextTier
        self.onContinue = onContinue

        super.init()

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        // Dark background
        let background = SKShapeNode(rectOf: size)
        background.fillColor = SKColor.black.withAlphaComponent(0.9)
        background.strokeColor = .clear
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)

        // Celebration banner
        let banner = SKShapeNode(rectOf: CGSize(width: size.width - 100, height: 180), cornerRadius: 20)
        banner.fillColor = SKColor.systemYellow.withAlphaComponent(0.3)
        banner.strokeColor = .yellow
        banner.lineWidth = 4
        banner.position = CGPoint(x: 0, y: halfHeight - 140)
        addChild(banner)

        // Congratulations title
        let congrats = SKLabelNode(fontNamed: "Helvetica-Bold")
        congrats.text = "🎉 TIER COMPLETED! 🎉"
        congrats.fontSize = 36
        congrats.fontColor = .yellow
        congrats.position = CGPoint(x: 0, y: halfHeight - 100)
        addChild(congrats)

        // Completed tier name
        let tierName = SKLabelNode(fontNamed: "Helvetica-Bold")
        tierName.text = "\(completedTier.icon) \(completedTier.name)"
        tierName.fontSize = 28
        tierName.fontColor = .white
        tierName.position = CGPoint(x: 0, y: halfHeight - 140)
        addChild(tierName)

        // Wave range
        let waveRange = SKLabelNode(fontNamed: "Helvetica")
        waveRange.text = "Waves \(completedTier.waveRange.lowerBound) - \(completedTier.waveRange.upperBound)"
        waveRange.fontSize = 18
        waveRange.fontColor = .lightGray
        waveRange.position = CGPoint(x: 0, y: halfHeight - 170)
        addChild(waveRange)

        // Next tier info (if available)
        if let next = nextTier {
            let separator = SKLabelNode(fontNamed: "Helvetica")
            separator.text = "▼ ▼ ▼"
            separator.fontSize = 24
            separator.fontColor = .yellow
            separator.position = CGPoint(x: 0, y: 30)
            addChild(separator)

            let nextLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            nextLabel.text = "Next Tier:"
            nextLabel.fontSize = 22
            nextLabel.fontColor = .cyan
            nextLabel.position = CGPoint(x: 0, y: -10)
            addChild(nextLabel)

            let nextTierName = SKLabelNode(fontNamed: "Helvetica-Bold")
            nextTierName.text = "\(next.icon) \(next.name)"
            nextTierName.fontSize = 28
            nextTierName.fontColor = .white
            nextTierName.position = CGPoint(x: 0, y: -50)
            addChild(nextTierName)

            let nextWaveRange = SKLabelNode(fontNamed: "Helvetica")
            nextWaveRange.text = "Waves \(next.waveRange.lowerBound) - \(next.waveRange.upperBound)"
            nextWaveRange.fontSize = 16
            nextWaveRange.fontColor = .lightGray
            nextWaveRange.position = CGPoint(x: 0, y: -80)
            addChild(nextWaveRange)
        } else {
            // Final tier completed
            let finalMsg = SKLabelNode(fontNamed: "Helvetica-Bold")
            finalMsg.text = "🏆 FINAL TIER COMPLETE! 🏆"
            finalMsg.fontSize = 24
            finalMsg.fontColor = .orange
            finalMsg.position = CGPoint(x: 0, y: -20)
            addChild(finalMsg)
        }

        // Instructions
        let instructions = SKLabelNode(fontNamed: "Helvetica")
        instructions.text = "🗺️ New map loaded • All towers reset"
        instructions.fontSize = 16
        instructions.fontColor = .orange
        instructions.position = CGPoint(x: 0, y: -halfHeight + 150)
        addChild(instructions)

        let instructions2 = SKLabelNode(fontNamed: "Helvetica")
        instructions2.text = "Place your towers and prepare for the next challenge!"
        instructions2.fontSize = 14
        instructions2.fontColor = .white
        instructions2.position = CGPoint(x: 0, y: -halfHeight + 120)
        addChild(instructions2)

        // Continue button
        let continueButton = Button(
            text: "Continue",
            size: CGSize(width: 200, height: 60),
            color: .systemGreen
        )
        continueButton.position = CGPoint(x: 0, y: -halfHeight + 70)
        continueButton.onTap = { [weak self] in
            self?.onContinue()
        }
        addChild(continueButton)

        isUserInteractionEnabled = true

        // Animate entrance
        self.alpha = 0
        self.setScale(0.8)
        self.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        // Block clicks from passing through
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Block taps from passing through
    }
    #endif
}
