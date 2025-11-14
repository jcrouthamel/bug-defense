import SpriteKit
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// Menu for purchasing upgrades
@MainActor
class UpgradeMenu: SKNode {
    private let upgradeManager: UpgradeManager
    private let onClose: () -> Void

    private let background: SKShapeNode
    private let closeButton: Button

    // Upgrade tree displays
    private var attackTreeDisplay: UpgradeTreeDisplay!
    private var defenseTreeDisplay: UpgradeTreeDisplay!
    private var speedTreeDisplay: UpgradeTreeDisplay!

    init(size: CGSize, upgradeManager: UpgradeManager, onClose: @escaping () -> Void) {
        self.upgradeManager = upgradeManager
        self.onClose = onClose

        // Create semi-transparent background (camera-relative, centered at 0,0)
        self.background = SKShapeNode(rectOf: size)
        self.background.fillColor = SKColor.black.withAlphaComponent(0.8)
        self.background.strokeColor = .clear
        self.background.position = CGPoint(x: 0, y: 0)

        // Create close button (camera-relative)
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
        zPosition = 1000 // Ensure menu renders on top of everything

        addChild(background)
        addChild(closeButton)

        closeButton.onTap = { [weak self] in
            self?.onClose()
        }

        setupUpgradeTrees(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    private func setupUpgradeTrees(size: CGSize) {
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "⚔️ UPGRADE TREES ⚔️"
        title.fontSize = 32
        title.fontColor = .yellow
        title.position = CGPoint(x: size.width / 2, y: size.height - 90)
        addChild(title)

        let treeWidth: CGFloat = 250
        let treeHeight: CGFloat = 450
        let spacing: CGFloat = 20
        let startX = (size.width - (treeWidth * 3 + spacing * 2)) / 2

        // Attack Tree
        attackTreeDisplay = UpgradeTreeDisplay(
            tree: .attack,
            title: "⚔️ ATTACK",
            size: CGSize(width: treeWidth, height: treeHeight),
            upgradeManager: upgradeManager
        )
        attackTreeDisplay.position = CGPoint(x: startX + treeWidth / 2, y: size.height / 2)
        addChild(attackTreeDisplay)

        // Defense Tree
        defenseTreeDisplay = UpgradeTreeDisplay(
            tree: .defense,
            title: "🛡️ DEFENSE",
            size: CGSize(width: treeWidth, height: treeHeight),
            upgradeManager: upgradeManager
        )
        defenseTreeDisplay.position = CGPoint(
            x: startX + treeWidth * 1.5 + spacing,
            y: size.height / 2
        )
        addChild(defenseTreeDisplay)

        // Speed Tree
        speedTreeDisplay = UpgradeTreeDisplay(
            tree: .speed,
            title: "⚡ SPEED",
            size: CGSize(width: treeWidth, height: treeHeight),
            upgradeManager: upgradeManager
        )
        speedTreeDisplay.position = CGPoint(
            x: startX + treeWidth * 2.5 + spacing * 2,
            y: size.height / 2
        )
        addChild(speedTreeDisplay)
    }
}

/// Display for a single upgrade tree
@MainActor
class UpgradeTreeDisplay: SKNode {
    private let tree: UpgradeTree
    private let upgradeManager: UpgradeManager
    private var upgradeButtons: [UpgradeButton] = []

    init(tree: UpgradeTree, title: String, size: CGSize, upgradeManager: UpgradeManager) {
        self.tree = tree
        self.upgradeManager = upgradeManager

        super.init()

        // Background
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = SKColor.darkGray.withAlphaComponent(0.5)
        background.strokeColor = .white
        background.lineWidth = 3
        addChild(background)

        // Title
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = title
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: size.height / 2 - 40)
        addChild(titleLabel)

        // Create upgrade buttons
        let upgrades = upgradeManager.getUpgradesForTree(tree)
        let buttonHeight: CGFloat = 80
        let buttonSpacing: CGFloat = 10
        let startY = size.height / 2 - 80

        for (index, upgrade) in upgrades.enumerated() {
            let button = UpgradeButton(
                upgrade: upgrade,
                size: CGSize(width: size.width - 40, height: buttonHeight),
                upgradeManager: upgradeManager
            )
            button.position = CGPoint(
                x: 0,
                y: startY - CGFloat(index) * (buttonHeight + buttonSpacing)
            )
            addChild(button)
            upgradeButtons.append(button)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Button for purchasing a single upgrade
@MainActor
class UpgradeButton: SKNode {
    private let upgrade: Upgrade
    private let upgradeManager: UpgradeManager
    private let background: SKShapeNode
    private let nameLabel: SKLabelNode
    private let descLabel: SKLabelNode
    private let costLabel: SKLabelNode
    private let tierLabel: SKLabelNode

    init(upgrade: Upgrade, size: CGSize, upgradeManager: UpgradeManager) {
        self.upgrade = upgrade
        self.upgradeManager = upgradeManager

        // Background
        self.background = SKShapeNode(rectOf: size, cornerRadius: 8)
        self.background.fillColor = .darkGray
        self.background.strokeColor = .white
        self.background.lineWidth = 2

        // Labels
        self.nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.nameLabel.fontSize = 16
        self.nameLabel.fontColor = .white
        self.nameLabel.horizontalAlignmentMode = .left
        self.nameLabel.position = CGPoint(x: -size.width / 2 + 10, y: size.height / 2 - 25)

        self.descLabel = SKLabelNode(fontNamed: "Helvetica")
        self.descLabel.fontSize = 12
        self.descLabel.fontColor = .lightGray
        self.descLabel.horizontalAlignmentMode = .left
        self.descLabel.position = CGPoint(x: -size.width / 2 + 10, y: size.height / 2 - 45)

        self.costLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.costLabel.fontSize = 14
        self.costLabel.fontColor = .yellow
        self.costLabel.horizontalAlignmentMode = .left
        self.costLabel.position = CGPoint(x: -size.width / 2 + 10, y: -size.height / 2 + 15)

        self.tierLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.tierLabel.fontSize = 14
        self.tierLabel.fontColor = .cyan
        self.tierLabel.horizontalAlignmentMode = .right
        self.tierLabel.position = CGPoint(x: size.width / 2 - 10, y: size.height / 2 - 25)

        super.init()

        addChild(background)
        addChild(nameLabel)
        addChild(descLabel)
        addChild(costLabel)
        addChild(tierLabel)

        updateDisplay()

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateDisplay() {
        nameLabel.text = upgrade.name
        descLabel.text = upgrade.description
        costLabel.text = "💰 \(upgrade.cost)"
        tierLabel.text = "Tier \(upgrade.tier)"

        if upgradeManager.isPurchased(upgrade.id) {
            background.fillColor = .green
            costLabel.text = "✓ PURCHASED"
        } else if upgradeManager.canPurchase(upgrade: upgrade) {
            background.fillColor = .blue
        } else {
            background.fillColor = .darkGray
            background.strokeColor = .gray
        }
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        if upgradeManager.purchaseUpgrade(upgrade) {
            updateDisplay()
        }
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if upgradeManager.purchaseUpgrade(upgrade) {
            updateDisplay()
        }
    }
    #endif
}
