import SpriteKit
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// Panel for upgrading towers
@MainActor
class TowerUpgradePanel: SKNode {
    private let tower: Tower
    private let gameState: GameStateManager
    private let onClose: () -> Void
    private let onUpgrade: (Tower) -> Bool  // Returns true if upgrade successful
    private let onSell: (Tower) -> Void  // Called when tower is sold

    private let panelHeight: CGFloat = 430
    private let background: SKShapeNode
    private let titleLabel: SKLabelNode
    private let levelLabel: SKLabelNode
    private let statsLabel: SKLabelNode
    private var upgradeButton: TowerUpgradeButton
    private let sellButton: Button
    private let closeButton: Button

    init(
        tower: Tower,
        gameState: GameStateManager,
        onClose: @escaping () -> Void,
        onUpgrade: @escaping (Tower) -> Bool,
        onSell: @escaping (Tower) -> Void
    ) {
        self.tower = tower
        self.gameState = gameState
        self.onClose = onClose
        self.onUpgrade = onUpgrade
        self.onSell = onSell

        // Background
        let panelWidth: CGFloat = 350
        self.background = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 10)
        self.background.fillColor = SKColor.darkGray.withAlphaComponent(0.95)
        self.background.strokeColor = .white
        self.background.lineWidth = 3

        // Title
        self.titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.titleLabel.text = tower.structureType.displayName
        self.titleLabel.fontSize = 22
        self.titleLabel.fontColor = .white
        self.titleLabel.verticalAlignmentMode = .top
        self.titleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 30)

        // Level
        self.levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.levelLabel.text = "Level \(tower.level) / 10"
        self.levelLabel.fontSize = 18
        self.levelLabel.fontColor = .yellow
        self.levelLabel.verticalAlignmentMode = .top
        self.levelLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 60)

        // Stats
        self.statsLabel = SKLabelNode(fontNamed: "Helvetica")
        self.statsLabel.fontSize = 14
        self.statsLabel.fontColor = .white
        self.statsLabel.numberOfLines = 0
        self.statsLabel.preferredMaxLayoutWidth = panelWidth - 40
        self.statsLabel.verticalAlignmentMode = .top
        self.statsLabel.horizontalAlignmentMode = .center
        self.statsLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 95)

        // Upgrade button
        let upgradeCost = tower.getUpgradeCost()
        let buttonText = tower.canUpgrade() ? "Upgrade ($\(upgradeCost))" : "MAX LEVEL"
        let buttonColor: SKColor = tower.canUpgrade() ? .green : .gray
        self.upgradeButton = TowerUpgradeButton(
            text: buttonText,
            size: CGSize(width: 220, height: 45),
            color: buttonColor,
            isEnabled: tower.canUpgrade() && gameState.currency >= upgradeCost
        )
        self.upgradeButton.position = CGPoint(x: 0, y: -panelHeight / 2 + 105)

        // Sell button
        let sellValue = tower.getSellValue()
        self.sellButton = Button(
            text: "Sell Tower ($\(sellValue))",
            size: CGSize(width: 220, height: 40),
            color: .orange
        )
        self.sellButton.position = CGPoint(x: 0, y: -panelHeight / 2 + 55)

        // Close button
        self.closeButton = Button(
            text: "Close",
            size: CGSize(width: 120, height: 40),
            color: .red
        )
        self.closeButton.position = CGPoint(x: 0, y: -panelHeight / 2 + 15)

        super.init()

        // Enable interaction for the panel itself
        isUserInteractionEnabled = true

        addChild(background)
        addChild(titleLabel)
        addChild(levelLabel)
        addChild(statsLabel)
        addChild(upgradeButton)
        addChild(sellButton)
        addChild(closeButton)

        updateDisplay()
        setupCallbacks()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateDisplay() {
        // Update level
        levelLabel.text = "Level \(tower.level) / 10"

        // Update stats (show current and next level)
        if tower.canUpgrade() {
            let nextDamageIncrease = 20 // 20% per level
            let nextRangeIncrease = 5 // 5% per level
            let nextSpeedIncrease = 10 // 10% per level
            let currentDamageBonus = (tower.level - 1) * nextDamageIncrease
            let currentRangeBonus = (tower.level - 1) * nextRangeIncrease
            let currentSpeedBonus = (tower.level - 1) * nextSpeedIncrease

            statsLabel.text = """
            Current Stats:
            Damage: +\(currentDamageBonus)%
            Range: +\(currentRangeBonus)%
            Speed: +\(currentSpeedBonus)%

            Next Level Gains:
            Damage: +\(nextDamageIncrease)%
            Range: +\(nextRangeIncrease)%
            Speed: +\(nextSpeedIncrease)%
            """
        } else {
            statsLabel.text = """
            MAX LEVEL!

            Total Bonuses:
            Damage: +180%
            Range: +45%
            Speed: +90%
            """
        }

        // Update upgrade button
        let upgradeCost = tower.getUpgradeCost()
        let buttonText = tower.canUpgrade() ? "Upgrade ($\(upgradeCost))" : "MAX LEVEL"
        let buttonColor: SKColor = tower.canUpgrade() ? .green : .gray
        let isEnabled = tower.canUpgrade() && gameState.currency >= upgradeCost

        upgradeButton.removeFromParent()
        upgradeButton = TowerUpgradeButton(
            text: buttonText,
            size: CGSize(width: 220, height: 45),
            color: buttonColor,
            isEnabled: isEnabled
        )
        upgradeButton.position = CGPoint(x: 0, y: -panelHeight / 2 + 105)
        addChild(upgradeButton)
        setupCallbacks()
    }

    private func setupCallbacks() {
        upgradeButton.onTap = { [weak self] in
            guard let self = self else { return }
            if self.onUpgrade(self.tower) {
                self.updateDisplay()
            }
        }

        sellButton.onTap = { [weak self] in
            guard let self = self else { return }
            self.onSell(self.tower)
        }

        closeButton.onTap = { [weak self] in
            self?.onClose()
        }
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        // Check if close button was clicked
        if closeButton.contains(location) {
            closeButton.onTap?()
            return
        }

        // Check if upgrade button was clicked
        if upgradeButton.contains(location) {
            upgradeButton.onTap?()
            return
        }

        // Check if sell button was clicked
        if sellButton.contains(location) {
            sellButton.onTap?()
            return
        }

        // Click on panel background - do nothing (block clicks from passing through)
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check if close button was tapped
        if closeButton.contains(location) {
            closeButton.onTap?()
            return
        }

        // Check if upgrade button was tapped
        if upgradeButton.contains(location) {
            upgradeButton.onTap?()
            return
        }

        // Check if sell button was tapped
        if sellButton.contains(location) {
            sellButton.onTap?()
            return
        }

        // Tap on panel background - do nothing (block taps from passing through)
    }
    #endif
}

/// Tower upgrade button with enabled/disabled state
@MainActor
class TowerUpgradeButton: SKNode {
    private let background: SKShapeNode
    private let label: SKLabelNode
    private let size: CGSize
    private let isEnabled: Bool
    var onTap: (() -> Void)?

    init(text: String, size: CGSize, color: SKColor, isEnabled: Bool) {
        self.size = size
        self.isEnabled = isEnabled

        // Background
        self.background = SKShapeNode(rectOf: size, cornerRadius: 5)
        self.background.fillColor = isEnabled ? color : SKColor.gray.withAlphaComponent(0.5)
        self.background.strokeColor = .white
        self.background.lineWidth = 2

        // Label
        self.label = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.label.text = text
        self.label.fontSize = 18
        self.label.fontColor = isEnabled ? .white : .darkGray
        self.label.verticalAlignmentMode = .center
        self.label.horizontalAlignmentMode = .center

        super.init()

        addChild(background)
        addChild(label)

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        if isEnabled {
            onTap?()
        }
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            onTap?()
        }
    }
    #endif

    override func contains(_ point: CGPoint) -> Bool {
        guard let parent = parent else { return false }
        let localPoint = self.convert(point, from: parent)
        return abs(localPoint.x) < size.width / 2 && abs(localPoint.y) < size.height / 2
    }
}
