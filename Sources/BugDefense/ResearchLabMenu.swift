import SpriteKit
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// Menu for purchasing permanent research upgrades with coins
@MainActor
class ResearchLabMenu: SKNode {
    private let researchLab: ResearchLab
    private let onClose: () -> Void

    private let background: SKShapeNode
    private let closeButton: Button
    private var upgradeButtons: [ResearchUpgradeButton] = []

    init(size: CGSize, researchLab: ResearchLab, onClose: @escaping () -> Void) {
        self.researchLab = researchLab
        self.onClose = onClose

        // Create semi-transparent background
        self.background = SKShapeNode(rectOf: size)
        self.background.fillColor = SKColor.black.withAlphaComponent(0.85)
        self.background.strokeColor = .clear
        self.background.position = CGPoint(x: 0, y: 0)

        // Create close button
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        self.closeButton = Button(
            text: "✕ Close",
            size: CGSize(width: 100, height: 45),
            color: .red
        )
        self.closeButton.position = CGPoint(x: halfWidth - 60, y: halfHeight - 35)

        super.init()

        isUserInteractionEnabled = true
        zPosition = 1000 // Ensure menu renders on top

        addChild(background)
        addChild(closeButton)

        closeButton.onTap = { [weak self] in
            self?.onClose()
        }

        setupResearchMenu(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupResearchMenu(size: CGSize) {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        // Title
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "🔬 RESEARCH LAB 🔬"
        title.fontSize = 32
        title.fontColor = .cyan
        title.position = CGPoint(x: 0, y: halfHeight - 80)
        addChild(title)

        // Subtitle
        let subtitle = SKLabelNode(fontNamed: "Helvetica")
        subtitle.text = "Permanent upgrades using Research Coins"
        subtitle.fontSize = 14
        subtitle.fontColor = .lightGray
        subtitle.position = CGPoint(x: 0, y: halfHeight - 105)
        addChild(subtitle)

        // Coins display
        let coinsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        coinsLabel.text = "🪙 \(researchLab.totalCoins) Coins"
        coinsLabel.fontSize = 20
        coinsLabel.fontColor = .yellow
        coinsLabel.position = CGPoint(x: 0, y: halfHeight - 135)
        coinsLabel.name = "coinsLabel"
        addChild(coinsLabel)

        // Listen for coin changes
        researchLab.onCoinsChanged = { [weak self, weak coinsLabel] coins in
            coinsLabel?.text = "Research Coins: \(coins) 🪙"
            self?.refreshUpgradeButtons()
        }

        // Create upgrade buttons in two columns
        let upgrades = ResearchLab.allUpgrades
        let buttonWidth: CGFloat = 350
        let buttonHeight: CGFloat = 90
        let buttonSpacing: CGFloat = 10
        let columnSpacing: CGFloat = 30
        let startY = halfHeight - 180

        let leftColumnX = -columnSpacing / 2 - buttonWidth / 2
        let rightColumnX = columnSpacing / 2 + buttonWidth / 2

        for (index, upgrade) in upgrades.enumerated() {
            let isLeftColumn = index % 2 == 0
            let columnIndex = index / 2
            let xPos = isLeftColumn ? leftColumnX : rightColumnX

            let button = ResearchUpgradeButton(
                upgrade: upgrade,
                size: CGSize(width: buttonWidth, height: buttonHeight),
                researchLab: researchLab
            )
            button.position = CGPoint(
                x: xPos,
                y: startY - CGFloat(columnIndex) * (buttonHeight + buttonSpacing)
            )
            addChild(button)
            upgradeButtons.append(button)
        }
    }

    private func refreshUpgradeButtons() {
        for button in upgradeButtons {
            button.updateDisplay()
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

        // Block clicks from passing through
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

        // Block taps from passing through
    }
    #endif
}

/// Button for purchasing a single research upgrade
@MainActor
class ResearchUpgradeButton: SKNode {
    private let upgrade: ResearchUpgrade
    private let researchLab: ResearchLab
    private let background: SKShapeNode
    private let nameLabel: SKLabelNode
    private let descLabel: SKLabelNode
    private let levelLabel: SKLabelNode
    private let costLabel: SKLabelNode
    private var progressBar: SKShapeNode
    private let progressBarBackground: SKShapeNode

    init(upgrade: ResearchUpgrade, size: CGSize, researchLab: ResearchLab) {
        self.upgrade = upgrade
        self.researchLab = researchLab

        // Background
        self.background = SKShapeNode(rectOf: size, cornerRadius: 10)
        self.background.fillColor = .darkGray
        self.background.strokeColor = .white
        self.background.lineWidth = 2

        // Labels
        self.nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.nameLabel.fontSize = 18
        self.nameLabel.fontColor = .white
        self.nameLabel.horizontalAlignmentMode = .left
        self.nameLabel.position = CGPoint(x: -size.width / 2 + 15, y: size.height / 2 - 25)

        self.descLabel = SKLabelNode(fontNamed: "Helvetica")
        self.descLabel.fontSize = 13
        self.descLabel.fontColor = .lightGray
        self.descLabel.horizontalAlignmentMode = .left
        self.descLabel.position = CGPoint(x: -size.width / 2 + 15, y: size.height / 2 - 45)

        self.levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.levelLabel.fontSize = 16
        self.levelLabel.fontColor = .cyan
        self.levelLabel.horizontalAlignmentMode = .right
        self.levelLabel.position = CGPoint(x: size.width / 2 - 15, y: size.height / 2 - 25)

        self.costLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.costLabel.fontSize = 15
        self.costLabel.fontColor = .yellow
        self.costLabel.horizontalAlignmentMode = .center
        self.costLabel.position = CGPoint(x: 0, y: -size.height / 2 + 20)

        // Progress bar
        let barWidth: CGFloat = size.width - 30
        let barHeight: CGFloat = 8
        self.progressBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        self.progressBarBackground.fillColor = SKColor.darkGray.withAlphaComponent(0.5)
        self.progressBarBackground.strokeColor = .gray
        self.progressBarBackground.lineWidth = 1
        self.progressBarBackground.position = CGPoint(x: 0, y: -size.height / 2 + 40)

        self.progressBar = SKShapeNode(rectOf: CGSize(width: 0, height: barHeight))
        self.progressBar.fillColor = .green
        self.progressBar.strokeColor = .clear
        self.progressBar.position = CGPoint(x: 0, y: -size.height / 2 + 40)

        super.init()

        addChild(background)
        addChild(nameLabel)
        addChild(descLabel)
        addChild(levelLabel)
        addChild(costLabel)
        addChild(progressBarBackground)
        addChild(progressBar)

        updateDisplay()

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateDisplay() {
        let currentLevel = researchLab.getUpgradeLevel(upgrade.id)
        let isMaxed = currentLevel >= upgrade.maxLevel

        nameLabel.text = upgrade.name
        descLabel.text = upgrade.description
        levelLabel.text = "Level \(currentLevel)/\(upgrade.maxLevel)"

        // Update progress bar
        let progress = CGFloat(currentLevel) / CGFloat(upgrade.maxLevel)
        let barWidth: CGFloat = 320
        let barHeight: CGFloat = 8
        let filledWidth = barWidth * progress

        progressBar.removeFromParent()
        progressBar = SKShapeNode(rectOf: CGSize(width: filledWidth, height: barHeight))
        progressBar.fillColor = isMaxed ? .yellow : .green
        progressBar.strokeColor = .clear
        progressBar.position = CGPoint(
            x: -(barWidth - filledWidth) / 2,
            y: -(progressBarBackground.frame.height / 2 + 40)
        )
        addChild(progressBar)

        if isMaxed {
            background.fillColor = SKColor.yellow.withAlphaComponent(0.3)
            costLabel.text = "✓ MAX LEVEL"
            costLabel.fontColor = .yellow
        } else if researchLab.canPurchaseUpgrade(upgrade) {
            background.fillColor = SKColor.green.withAlphaComponent(0.3)
            let cost = upgrade.cost(forLevel: currentLevel + 1)
            costLabel.text = "Upgrade: \(cost) 🪙"
            costLabel.fontColor = .yellow
        } else {
            background.fillColor = .darkGray
            background.strokeColor = .gray
            let cost = upgrade.cost(forLevel: currentLevel + 1)
            costLabel.text = "Upgrade: \(cost) 🪙 (Insufficient Coins)"
            costLabel.fontColor = .red
        }
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        if researchLab.purchaseUpgrade(upgrade) {
            updateDisplay()
        }
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if researchLab.purchaseUpgrade(upgrade) {
            updateDisplay()
        }
    }
    #endif
}
