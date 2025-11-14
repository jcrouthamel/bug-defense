import SpriteKit

/// Main menu for managing modules, shopping, and merging
@MainActor
class ModuleMenu: SKNode {
    private let moduleManager: ModuleManager
    private let researchLab: ResearchLab
    private let onClose: () -> Void

    private var currentTab: ModuleTab = .inventory
    private var inventoryView: ModuleInventoryView!
    private var shopView: ModuleShopView!
    private var mergeView: ModuleMergeView!

    private let tabButtons: [ModuleTab: Button] = [:]
    private var selectedModuleForMerge: Module?
    private var closeButton: Button!

    init(size: CGSize, moduleManager: ModuleManager, researchLab: ResearchLab, onClose: @escaping () -> Void) {
        self.moduleManager = moduleManager
        self.researchLab = researchLab
        self.onClose = onClose

        super.init()

        isUserInteractionEnabled = true
        zPosition = 1000 // Ensure menu renders on top

        setupBackground(size: size)
        setupHeader(size: size)
        setupTabs(size: size)
        setupViews(size: size)

        // Show initial tab
        showTab(.inventory)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBackground(size: CGSize) {
        let background = SKShapeNode(rectOf: size)
        background.fillColor = SKColor.black.withAlphaComponent(0.9)
        background.strokeColor = .clear
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
    }

    private func setupHeader(size: CGSize) {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        // Title
        let title: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "💎 MODULE SYSTEM 💎"
        title.fontSize = CGFloat(28)
        title.fontColor = .magenta
        title.position = CGPoint(x: 0, y: halfHeight - 75)
        addChild(title)

        // Currency display
        let gemsLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        gemsLabel.text = "💎 \(moduleManager.gems) Gems"
        gemsLabel.fontSize = CGFloat(18)
        gemsLabel.fontColor = .magenta
        gemsLabel.position = CGPoint(x: -80, y: halfHeight - 105)
        gemsLabel.name = "gemsLabel"
        addChild(gemsLabel)

        let coinsLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        coinsLabel.text = "🪙 \(researchLab.totalCoins) Coins"
        coinsLabel.fontSize = CGFloat(18)
        coinsLabel.fontColor = .cyan
        coinsLabel.position = CGPoint(x: 80, y: halfHeight - 105)
        coinsLabel.name = "coinsLabel"
        addChild(coinsLabel)

        // Close button
        closeButton = Button(text: "✕ Close", size: CGSize(width: 100, height: 45), color: .red)
        closeButton.position = CGPoint(x: halfWidth - 60, y: halfHeight - 35)
        closeButton.onTap = { [weak self] in
            self?.onClose()
        }
        addChild(closeButton)
    }

    private func setupTabs(size: CGSize) {
        let halfHeight = size.height / 2
        let tabY = halfHeight - 140
        let tabWidth: CGFloat = 150
        let tabSpacing: CGFloat = 160

        let tabs: [(ModuleTab, String, CGFloat)] = [
            (.inventory, "📦 Inventory", -tabSpacing),
            (.shop, "🛒 Shop", 0),
            (.merge, "🔧 Merge", tabSpacing)
        ]

        for (tab, text, x) in tabs {
            let button = Button(text: text, size: CGSize(width: tabWidth, height: 40), color: .darkGray)
            button.position = CGPoint(x: x, y: tabY)
            button.onTap = { [weak self] in
                self?.showTab(tab)
            }
            button.name = "tab_\(tab.rawValue)"
            addChild(button)
        }
    }

    private func setupViews(size: CGSize) {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        let contentFrame = CGRect(x: -halfWidth + 50, y: -halfHeight + 50, width: size.width - 100, height: size.height - 200)

        inventoryView = ModuleInventoryView(
            frame: contentFrame,
            moduleManager: moduleManager,
            onModuleSelected: { [weak self] module in
                self?.handleInventoryModuleSelected(module)
            }
        )
        addChild(inventoryView)

        shopView = ModuleShopView(
            frame: contentFrame,
            moduleManager: moduleManager,
            researchLab: researchLab,
            onPurchase: { [weak self] in
                self?.updateCurrencyDisplay()
            }
        )
        addChild(shopView)

        mergeView = ModuleMergeView(
            frame: contentFrame,
            moduleManager: moduleManager,
            onMerge: { [weak self] in
                self?.inventoryView.refresh()
                self?.updateCurrencyDisplay()
            }
        )
        addChild(mergeView)
    }

    private func showTab(_ tab: ModuleTab) {
        currentTab = tab

        // Update tab button appearances
        for tabCase in ModuleTab.allCases {
            if let button = childNode(withName: "tab_\(tabCase.rawValue)") as? Button {
                // Change appearance based on selection
                button.removeAllChildren()
                let rect = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 5)
                rect.fillColor = tabCase == tab ? .cyan : .darkGray
                rect.strokeColor = .white
                rect.lineWidth = 2
                button.addChild(rect)
            }
        }

        // Show/hide views
        inventoryView.isHidden = (tab != .inventory)
        shopView.isHidden = (tab != .shop)
        mergeView.isHidden = (tab != .merge)

        // Refresh the visible view
        switch tab {
        case .inventory:
            inventoryView.refresh()
        case .shop:
            shopView.refresh()
        case .merge:
            mergeView.refresh()
        }
    }

    private func handleInventoryModuleSelected(_ module: Module) {
        // Could be used for detailed view or equipment
        print("Selected module: \(module.type.rawValue) Level \(module.level)")
    }

    private func updateCurrencyDisplay() {
        if let gemsLabel = childNode(withName: "gemsLabel") as? SKLabelNode {
            gemsLabel.text = "💎 \(moduleManager.gems) Gems"
        }
        if let coinsLabel = childNode(withName: "coinsLabel") as? SKLabelNode {
            coinsLabel.text = "🪙 \(researchLab.totalCoins) Coins"
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

enum ModuleTab: String, CaseIterable {
    case inventory = "inventory"
    case shop = "shop"
    case merge = "merge"
}

/// Inventory view showing all collected modules
@MainActor
class ModuleInventoryView: SKNode {
    private let viewFrame: CGRect
    private let moduleManager: ModuleManager
    private let onModuleSelected: (Module) -> Void

    private var scrollOffset: CGFloat = 0
    private let itemHeight: CGFloat = 70

    init(frame frameRect: CGRect, moduleManager: ModuleManager, onModuleSelected: @escaping (Module) -> Void) {
        self.viewFrame = frameRect
        self.moduleManager = moduleManager
        self.onModuleSelected = onModuleSelected
        super.init()

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Title
        let title: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "Your Modules (\(moduleManager.inventory.count))"
        title.fontSize = CGFloat(24)
        title.fontColor = .white
        title.position = CGPoint(x: CGFloat(viewFrame.midX), y: CGFloat(viewFrame.maxY) - 30)
        addChild(title)

        refresh()
    }

    func refresh() {
        // Remove old items
        enumerateChildNodes(withName: "//moduleItem") { node, _ in
            node.removeFromParent()
        }

        let inventory = moduleManager.inventory.sorted { module1, module2 in
            if module1.type.rawValue != module2.type.rawValue {
                return module1.type.rawValue < module2.type.rawValue
            }
            return module1.level > module2.level
        }

        if inventory.isEmpty {
            let emptyLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
            emptyLabel.text = "No modules yet. Defeat bugs to get module drops!"
            emptyLabel.fontSize = CGFloat(18)
            emptyLabel.fontColor = .gray
            emptyLabel.position = CGPoint(x: CGFloat(viewFrame.midX), y: CGFloat(viewFrame.midY))
            emptyLabel.name = "moduleItem"
            addChild(emptyLabel)
            return
        }

        var y = CGFloat(viewFrame.maxY) - 80

        for module in inventory {
            let itemNode = createModuleItem(module, at: CGPoint(x: CGFloat(viewFrame.minX) + 20, y: y))
            itemNode.name = "moduleItem"
            addChild(itemNode)

            y -= itemHeight
            if y < CGFloat(viewFrame.minY) {
                break // Stop if we're out of view
            }
        }
    }

    private func createModuleItem(_ module: Module, at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position

        // Calculate dimensions once
        let frameWidth: CGFloat = viewFrame.width
        let bgWidth: CGFloat = frameWidth - 40
        let halfWidth: CGFloat = frameWidth / 2

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: bgWidth, height: 60), cornerRadius: 8)
        let tierColor = module.tier.color
        bg.fillColor = SKColor(red: tierColor.r, green: tierColor.g, blue: tierColor.b, alpha: 0.3)
        bg.strokeColor = SKColor(red: tierColor.r, green: tierColor.g, blue: tierColor.b, alpha: 1.0)
        bg.lineWidth = 2
        container.addChild(bg)

        // Emoji
        let emoji: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        emoji.text = module.type.emoji
        emoji.fontSize = CGFloat(32)
        emoji.position = CGPoint(x: -halfWidth + 50, y: -10)
        container.addChild(emoji)

        // Name and level
        let nameLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        nameLabel.text = "\(module.type.rawValue) - Level \(module.level)"
        nameLabel.fontSize = CGFloat(18)
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = CGPoint(x: -halfWidth + 90, y: 5)
        container.addChild(nameLabel)

        // Effect
        let effectLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        effectLabel.text = module.effectString
        effectLabel.fontSize = CGFloat(14)
        effectLabel.fontColor = .lightGray
        effectLabel.horizontalAlignmentMode = .left
        effectLabel.preferredMaxLayoutWidth = bgWidth - 180  // Allow text to wrap within available space
        effectLabel.numberOfLines = 0  // Allow multiple lines
        effectLabel.position = CGPoint(x: -halfWidth + 90, y: -15)
        container.addChild(effectLabel)

        // Tier badge
        let tierLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        tierLabel.text = module.tier.rawValue
        tierLabel.fontSize = CGFloat(12)
        tierLabel.fontColor = SKColor(red: tierColor.r, green: tierColor.g, blue: tierColor.b, alpha: 1.0)
        tierLabel.position = CGPoint(x: halfWidth - 80, y: -5)
        container.addChild(tierLabel)

        return container
    }
}

/// Shop view for purchasing modules with gems
@MainActor
class ModuleShopView: SKNode {
    private let viewFrame: CGRect
    private let moduleManager: ModuleManager
    private let researchLab: ResearchLab
    private let onPurchase: () -> Void

    init(frame frameRect: CGRect, moduleManager: ModuleManager, researchLab: ResearchLab, onPurchase: @escaping () -> Void) {
        self.viewFrame = frameRect
        self.moduleManager = moduleManager
        self.researchLab = researchLab
        self.onPurchase = onPurchase
        super.init()

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Title
        let title: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "Module Shop"
        title.fontSize = CGFloat(24)
        title.fontColor = .white
        title.position = CGPoint(x: CGFloat(viewFrame.midX), y: CGFloat(viewFrame.maxY) - 30)
        addChild(title)

        // Coin to Gem converter
        setupCoinConverter()

        // Module purchase options
        setupModulePurchases()
    }

    private func setupCoinConverter() {
        let converterY: CGFloat = CGFloat(viewFrame.maxY) - 80

        let converterWidth: CGFloat = CGFloat(viewFrame.width) - 40
        let converterBg = SKShapeNode(rectOf: CGSize(width: converterWidth, height: 80), cornerRadius: 10)
        converterBg.fillColor = SKColor.purple.withAlphaComponent(0.3)
        converterBg.strokeColor = SKColor.purple
        converterBg.lineWidth = 2
        let midX: CGFloat = CGFloat(viewFrame.midX)
        converterBg.position = CGPoint(x: midX, y: converterY)
        addChild(converterBg)

        let converterTitle: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        converterTitle.text = "💎 Convert Coins to Gems"
        converterTitle.fontSize = CGFloat(18)
        converterTitle.fontColor = .white
        converterTitle.position = CGPoint(x: midX, y: converterY + 20)
        addChild(converterTitle)

        let rateLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        rateLabel.text = "Rate: 100 Coins = 1 Gem"
        rateLabel.fontSize = CGFloat(14)
        rateLabel.fontColor = .lightGray
        rateLabel.position = CGPoint(x: midX, y: converterY - 5)
        addChild(rateLabel)

        // Conversion buttons
        let amounts = [100, 500, 1000, 5000]
        let buttonSpacing: CGFloat = 110
        let startX: CGFloat = midX - (CGFloat(amounts.count - 1) * buttonSpacing / 2)

        for (index, amount) in amounts.enumerated() {
            let gems = amount / GameConfiguration.coinToGemConversionRate
            let button = Button(
                text: "\(amount)→\(gems)💎",
                size: CGSize(width: 100, height: 30),
                color: .purple
            )
            button.position = CGPoint(x: startX + CGFloat(index) * buttonSpacing, y: converterY - 30)
            button.onTap = { [weak self] in
                self?.convertCoins(amount: amount)
            }
            addChild(button)
        }
    }

    private func setupModulePurchases() {
        let purchaseY: CGFloat = CGFloat(viewFrame.maxY) - 200
        let midX: CGFloat = CGFloat(viewFrame.midX)
        let minX: CGFloat = CGFloat(viewFrame.minX)

        let purchaseTitle: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        purchaseTitle.text = "Purchase Modules"
        purchaseTitle.fontSize = CGFloat(20)
        purchaseTitle.fontColor = .white
        purchaseTitle.position = CGPoint(x: midX, y: purchaseY)
        addChild(purchaseTitle)

        // Show purchase options for each module type
        let types = ModuleType.allCases
        let itemsPerRow = 4
        let itemWidth: CGFloat = 180
        let itemHeight: CGFloat = 140
        let spacing: CGFloat = 20

        var x: CGFloat = minX + 30
        var y: CGFloat = purchaseY - 50

        for (index, type) in types.enumerated() {
            if index > 0 && index % itemsPerRow == 0 {
                x = minX + 30
                y -= itemHeight + spacing
            }

            let itemNode = createPurchaseItem(type, at: CGPoint(x: x, y: y))
            addChild(itemNode)

            x += itemWidth + spacing
        }
    }

    private func createPurchaseItem(_ type: ModuleType, at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: 170, height: 130), cornerRadius: 8)
        bg.fillColor = SKColor.darkGray.withAlphaComponent(0.7)
        bg.strokeColor = .white
        bg.lineWidth = 2
        container.addChild(bg)

        // Emoji
        let emoji: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        emoji.text = type.emoji
        emoji.fontSize = CGFloat(40)
        emoji.position = CGPoint(x: 0, y: 35)
        container.addChild(emoji)

        // Name
        let nameLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        nameLabel.text = type.rawValue
        nameLabel.fontSize = CGFloat(14)
        nameLabel.fontColor = .white
        nameLabel.preferredMaxLayoutWidth = 160  // Limit width to fit in box
        nameLabel.numberOfLines = 2  // Allow up to 2 lines
        nameLabel.position = CGPoint(x: 0, y: 0)
        container.addChild(nameLabel)

        // Purchase buttons for levels
        let levels = [1, 5, 10]
        for (index, level) in levels.enumerated() {
            let module = Module(type: type, level: level)
            let button = Button(
                text: "Lv.\(level) \(module.gemCost)💎",
                size: CGSize(width: 70, height: 25),
                color: .cyan
            )
            button.position = CGPoint(x: CGFloat(index - 1) * 75, y: -35)
            button.onTap = { [weak self] in
                self?.purchaseModule(type: type, level: level)
            }
            container.addChild(button)
        }

        return container
    }

    private func convertCoins(amount: Int) {
        if let gems = moduleManager.convertCoinsToGems(coins: amount, researchLab: researchLab) {
            showNotification("Converted \(amount) coins to \(gems) gems!", color: .green)
            onPurchase()
        } else {
            showNotification("Not enough coins!", color: .red)
        }
    }

    private func purchaseModule(type: ModuleType, level: Int) {
        if let module = moduleManager.purchaseModule(type: type, level: level) {
            showNotification("Purchased \(module.type.emoji) Level \(module.level)!", color: .green)
            onPurchase()
        } else {
            showNotification("Not enough gems!", color: .red)
        }
    }

    private func showNotification(_ text: String, color: SKColor) {
        let notification: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        notification.text = text
        notification.fontSize = CGFloat(20)
        notification.fontColor = color
        let midX: CGFloat = CGFloat(viewFrame.midX)
        let midY: CGFloat = CGFloat(viewFrame.midY)
        notification.position = CGPoint(x: midX, y: midY)
        addChild(notification)

        let fadeOut = SKAction.fadeOut(withDuration: 2.0)
        let remove = SKAction.removeFromParent()
        notification.run(SKAction.sequence([fadeOut, remove]))
    }

    func refresh() {
        // Refresh is handled by parent updating currency display
    }
}

/// Merge view for combining modules
@MainActor
class ModuleMergeView: SKNode {
    private let viewFrame: CGRect
    private let moduleManager: ModuleManager
    private let onMerge: () -> Void

    private var selectedModule1: Module?
    private var selectedModule2: Module?

    init(frame frameRect: CGRect, moduleManager: ModuleManager, onMerge: @escaping () -> Void) {
        self.viewFrame = frameRect
        self.moduleManager = moduleManager
        self.onMerge = onMerge
        super.init()

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let midX: CGFloat = CGFloat(viewFrame.midX)
        let maxY: CGFloat = CGFloat(viewFrame.maxY)

        // Title
        let title: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "Module Merging"
        title.fontSize = CGFloat(24)
        title.fontColor = .white
        title.position = CGPoint(x: midX, y: maxY - 30)
        addChild(title)

        let subtitle: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        subtitle.text = "Combine 2 modules of the same type and level to upgrade"
        subtitle.fontSize = CGFloat(16)
        subtitle.fontColor = .lightGray
        subtitle.position = CGPoint(x: midX, y: maxY - 55)
        addChild(subtitle)

        refresh()
    }

    func refresh() {
        // Remove old content
        enumerateChildNodes(withName: "//mergeContent") { node, _ in
            node.removeFromParent()
        }

        let mergeablePairs = moduleManager.getMergeableModules()
        let midX: CGFloat = CGFloat(viewFrame.midX)
        let midY: CGFloat = CGFloat(viewFrame.midY)
        let maxY: CGFloat = CGFloat(viewFrame.maxY)
        let minY: CGFloat = CGFloat(viewFrame.minY)

        if mergeablePairs.isEmpty {
            let emptyLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
            emptyLabel.text = "No modules can be merged.\nCollect duplicate modules to merge them!"
            emptyLabel.numberOfLines = 2
            emptyLabel.fontSize = CGFloat(18)
            emptyLabel.fontColor = .gray
            emptyLabel.position = CGPoint(x: midX, y: midY)
            emptyLabel.name = "mergeContent"
            addChild(emptyLabel)
            return
        }

        // Show mergeable pairs
        var y: CGFloat = maxY - 100

        for (module1, module2) in mergeablePairs.prefix(8) {
            let mergeItem = createMergeItem(module1: module1, module2: module2, at: CGPoint(x: midX, y: y))
            mergeItem.name = "mergeContent"
            addChild(mergeItem)

            y -= 90
            if y < minY + 50 {
                break
            }
        }
    }

    private func createMergeItem(module1: Module, module2: Module, at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position

        // Background
        let frameWidth: CGFloat = viewFrame.width
        let mergeWidth: CGFloat = frameWidth - 60
        let bg = SKShapeNode(rectOf: CGSize(width: mergeWidth, height: 80), cornerRadius: 10)
        let tierColor = module1.tier.color
        bg.fillColor = SKColor(red: tierColor.r, green: tierColor.g, blue: tierColor.b, alpha: 0.2)
        bg.strokeColor = SKColor(red: tierColor.r, green: tierColor.g, blue: tierColor.b, alpha: 0.8)
        bg.lineWidth = 2
        container.addChild(bg)

        // Module 1
        let emoji1: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        emoji1.text = module1.type.emoji
        emoji1.fontSize = CGFloat(32)
        emoji1.position = CGPoint(x: -200, y: -10)
        container.addChild(emoji1)

        let level1: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        level1.text = "Lv.\(module1.level)"
        level1.fontSize = CGFloat(16)
        level1.fontColor = .white
        level1.position = CGPoint(x: -150, y: 10)
        container.addChild(level1)

        let effect1: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        effect1.text = module1.effectString
        effect1.fontSize = CGFloat(12)
        effect1.fontColor = .lightGray
        effect1.horizontalAlignmentMode = .left
        effect1.preferredMaxLayoutWidth = 120  // Limit width to prevent overflow
        effect1.numberOfLines = 0  // Allow multiple lines
        effect1.position = CGPoint(x: -150, y: -10)
        container.addChild(effect1)

        // Plus sign
        let plus: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        plus.text = "+"
        plus.fontSize = CGFloat(32)
        plus.fontColor = .white
        plus.position = CGPoint(x: -50, y: -10)
        container.addChild(plus)

        // Module 2
        let emoji2: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        emoji2.text = module2.type.emoji
        emoji2.fontSize = CGFloat(32)
        emoji2.position = CGPoint(x: 0, y: -10)
        container.addChild(emoji2)

        let level2: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        level2.text = "Lv.\(module2.level)"
        level2.fontSize = CGFloat(16)
        level2.fontColor = .white
        level2.position = CGPoint(x: 50, y: 10)
        container.addChild(level2)

        let effect2: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        effect2.text = module2.effectString
        effect2.fontSize = CGFloat(12)
        effect2.fontColor = .lightGray
        effect2.horizontalAlignmentMode = .left
        effect2.preferredMaxLayoutWidth = 120  // Limit width to prevent overflow
        effect2.numberOfLines = 0  // Allow multiple lines
        effect2.position = CGPoint(x: 50, y: -10)
        container.addChild(effect2)

        // Arrow
        let arrow: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        arrow.text = "→"
        arrow.fontSize = CGFloat(32)
        arrow.fontColor = .green
        arrow.position = CGPoint(x: 130, y: -10)
        container.addChild(arrow)

        // Result
        let resultLevel = module1.level + 1
        let resultEmoji: SKLabelNode = SKLabelNode(fontNamed: "Helvetica")
        resultEmoji.text = module1.type.emoji
        resultEmoji.fontSize = CGFloat(32)
        resultEmoji.position = CGPoint(x: 180, y: -10)
        container.addChild(resultEmoji)

        let resultLevelLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        resultLevelLabel.text = "Lv.\(resultLevel)"
        resultLevelLabel.fontSize = CGFloat(16)
        let nextTier = Module(type: module1.type, level: resultLevel).tier
        let nextColor = nextTier.color
        resultLevelLabel.fontColor = SKColor(red: nextColor.r, green: nextColor.g, blue: nextColor.b, alpha: 1.0)
        resultLevelLabel.position = CGPoint(x: 230, y: 10)
        container.addChild(resultLevelLabel)

        // Merge button
        let mergeButton = Button(text: "🔧 Merge", size: CGSize(width: 100, height: 35), color: .green)
        mergeButton.position = CGPoint(x: 310, y: 0)
        mergeButton.onTap = { [weak self] in
            self?.performMerge(module1: module1, module2: module2)
        }
        container.addChild(mergeButton)

        return container
    }

    private func performMerge(module1: Module, module2: Module) {
        if let newModule = moduleManager.mergeModules(module1, module2) {
            showNotification("Merged to \(newModule.type.emoji) Level \(newModule.level)!", color: .green)
            refresh()
            onMerge()
        } else {
            showNotification("Cannot merge these modules!", color: .red)
        }
    }

    private func showNotification(_ text: String, color: SKColor) {
        let notification: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold")
        notification.text = text
        notification.fontSize = CGFloat(20)
        notification.fontColor = color
        let midX: CGFloat = CGFloat(viewFrame.midX)
        let midY: CGFloat = CGFloat(viewFrame.midY)
        notification.position = CGPoint(x: midX, y: midY)
        notification.name = "mergeContent"
        addChild(notification)

        let fadeOut = SKAction.fadeOut(withDuration: 2.0)
        let remove = SKAction.removeFromParent()
        notification.run(SKAction.sequence([fadeOut, remove]))
    }
}
