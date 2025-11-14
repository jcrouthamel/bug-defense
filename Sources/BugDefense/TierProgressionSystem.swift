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

    // Define all tiers
    let tiers: [Tier] = [
        Tier(number: 1, name: "Village", waveRange: 1...25, mapType: .classic, icon: "🏘️"),
        Tier(number: 2, name: "Town", waveRange: 26...50, mapType: .winding, icon: "🏘️"),
        Tier(number: 3, name: "City", waveRange: 51...75, mapType: .spiral, icon: "🏙️"),
        Tier(number: 4, name: "Metropolis", waveRange: 76...100, mapType: .classic, icon: "🌆")  // Reuse classic with harder enemies
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
        // Tier completion happens at waves 25, 50, 75, 100
        return wave == 25 || wave == 50 || wave == 75 || wave == 100
    }

    /// Get the next tier after completion
    func getNextTier(after wave: Int) -> Tier? {
        let currentTier = getCurrentTier(for: wave)
        return tiers.first { $0.number == currentTier.number + 1 }
    }

    /// Automatically change map based on current wave
    func updateMapForWave(_ wave: Int) {
        let tier = getCurrentTier(for: wave)
        MapManager.shared.selectMap(tier.mapType)
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
        // Semi-transparent background
        let background = SKShapeNode(rectOf: size)
        background.fillColor = SKColor.black.withAlphaComponent(0.85)
        background.strokeColor = .clear
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)

        // Title
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "🏆 TIER PROGRESSION 🏆"
        title.fontSize = 32
        title.fontColor = .yellow
        title.position = CGPoint(x: size.width / 2, y: size.height - 60)
        addChild(title)

        // Current tier info
        let currentTier = TierProgressionManager.shared.getCurrentTier(for: currentWave)
        let tierInfo = SKLabelNode(fontNamed: "Helvetica")
        tierInfo.text = "Currently in: \(currentTier.icon) \(currentTier.name) (Waves \(currentTier.waveRange.lowerBound)-\(currentTier.waveRange.upperBound))"
        tierInfo.fontSize = 18
        tierInfo.fontColor = .white
        tierInfo.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(tierInfo)

        // Draw tier progression road
        drawTierRoad()

        // Close button
        let closeButton = Button(
            text: "✕ Close",
            size: CGSize(width: 120, height: 50),
            color: .green
        )
        closeButton.position = CGPoint(x: size.width / 2, y: 60)
        closeButton.onTap = { [weak self] in
            self?.onClose()
        }
        addChild(closeButton)

        isUserInteractionEnabled = true
    }

    private func drawTierRoad() {
        let tiers = TierProgressionManager.shared.tiers
        let roadStartY: CGFloat = size.height - 180
        let houseSpacing: CGFloat = 160
        let startX: CGFloat = 100

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
