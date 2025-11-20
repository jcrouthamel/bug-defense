import SpriteKit
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// Heads-up display showing game stats and controls
@MainActor
class GameHUD: SKNode {
    private let gameState: GameStateManager

    // Labels
    private let currencyLabel: SKLabelNode
    private let healthLabel: SKLabelNode
    private let waveLabel: SKLabelNode
    private let buildTimerLabel: SKLabelNode
    private let coinsLabel: SKLabelNode
    private let gemsLabel: SKLabelNode

    // Buttons
    private let gameControlsDropdown: DropdownMenu
    private let upgradeButton: Button
    private let researchLabButton: Button
    private let cardsButton: Button
    private let modulesButton: Button
    private let tierProgressButton: Button
    private let heroControlButton: Button
    private let nukeButton: Button
    private let powerUpButton: Button

    // Tower buttons (12 total)
    private var towerButtons: [StructureType: TowerButton] = [:]
    private var towerPanelCollapsed: Bool = false
    private var towerPanelToggleButton: Button!

    // Top menu collapsibility
    private var topMenuCollapsed: Bool = false
    private var topMenuToggleButton: Button!

    // Game state
    var isAutoStartEnabled: Bool = false
    var isGamePaused: Bool = false
    var gameSpeed: Int = 1  // 1x to 10x speed

    // Callbacks
    private let onTowerSelected: (StructureType) -> Void
    private let onStartWave: () -> Void
    private let onOpenUpgrades: () -> Void
    private let onOpenResearchLab: () -> Void
    private let onOpenCards: () -> Void
    private let onOpenModules: () -> Void
    private let onOpenTierProgress: () -> Void
    private let onToggleHeroControl: () -> Void
    private let onActivateNuke: () -> Void
    private let hasUsedNuke: () -> Bool
    private let onActivatePowerUp: () -> Void
    private let getAvailablePowerUps: () -> Int

    init(
        size: CGSize,
        gameState: GameStateManager,
        onTowerSelected: @escaping (StructureType) -> Void,
        onStartWave: @escaping () -> Void,
        onOpenUpgrades: @escaping () -> Void,
        onOpenResearchLab: @escaping () -> Void,
        onOpenCards: @escaping () -> Void,
        onOpenModules: @escaping () -> Void,
        onOpenTierProgress: @escaping () -> Void,
        onToggleHeroControl: @escaping () -> Void,
        onActivateNuke: @escaping () -> Void,
        hasUsedNuke: @escaping () -> Bool,
        onActivatePowerUp: @escaping () -> Void,
        getAvailablePowerUps: @escaping () -> Int
    ) {
        self.gameState = gameState
        self.onTowerSelected = onTowerSelected
        self.onStartWave = onStartWave
        self.onOpenUpgrades = onOpenUpgrades
        self.onOpenResearchLab = onOpenResearchLab
        self.onOpenCards = onOpenCards
        self.onOpenModules = onOpenModules
        self.onOpenTierProgress = onOpenTierProgress
        self.onToggleHeroControl = onToggleHeroControl
        self.onActivateNuke = onActivateNuke
        self.hasUsedNuke = hasUsedNuke
        self.onActivatePowerUp = onActivatePowerUp
        self.getAvailablePowerUps = getAvailablePowerUps

        // Create labels
        self.currencyLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.currencyLabel.fontSize = 20
        self.currencyLabel.fontColor = .yellow
        self.currencyLabel.horizontalAlignmentMode = .left

        self.healthLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.healthLabel.fontSize = 20
        self.healthLabel.fontColor = .red
        self.healthLabel.horizontalAlignmentMode = .left

        self.waveLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.waveLabel.fontSize = 24
        self.waveLabel.fontColor = .white
        self.waveLabel.horizontalAlignmentMode = .center

        self.buildTimerLabel = SKLabelNode(fontNamed: "Helvetica")
        self.buildTimerLabel.fontSize = 18
        self.buildTimerLabel.fontColor = .white
        self.buildTimerLabel.horizontalAlignmentMode = .center

        self.coinsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.coinsLabel.fontSize = 20
        self.coinsLabel.fontColor = .cyan
        self.coinsLabel.horizontalAlignmentMode = .left

        self.gemsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.gemsLabel.fontSize = 20
        self.gemsLabel.fontColor = .magenta
        self.gemsLabel.horizontalAlignmentMode = .left

        // Create buttons with uniform sizing
        let buttonHeight: CGFloat = 40
        let standardButtonWidth: CGFloat = 85

        self.gameControlsDropdown = DropdownMenu(
            title: "Controls",
            size: CGSize(width: standardButtonWidth, height: buttonHeight),
            color: .systemBlue
        )

        self.upgradeButton = Button(
            text: "Upgrades",
            size: CGSize(width: standardButtonWidth, height: buttonHeight),
            color: .purple
        )

        self.researchLabButton = Button(
            text: "Research",
            size: CGSize(width: standardButtonWidth, height: buttonHeight),
            color: .cyan
        )

        self.cardsButton = Button(
            text: "Cards",
            size: CGSize(width: standardButtonWidth, height: buttonHeight),
            color: .orange
        )

        self.modulesButton = Button(
            text: "Modules",
            size: CGSize(width: standardButtonWidth, height: buttonHeight),
            color: .magenta
        )

        self.tierProgressButton = Button(
            text: "Tiers",
            size: CGSize(width: standardButtonWidth, height: buttonHeight),
            color: .yellow
        )

        self.heroControlButton = Button(
            text: "Hero",
            size: CGSize(width: standardButtonWidth, height: buttonHeight),
            color: .systemIndigo
        )

        self.nukeButton = Button(
            text: "Nuke",
            size: CGSize(width: standardButtonWidth, height: buttonHeight),
            color: .systemRed
        )

        self.powerUpButton = Button(
            text: "⚡ 0",
            size: CGSize(width: standardButtonWidth, height: buttonHeight),
            color: .systemYellow
        )

        super.init()

        // Position labels (camera-relative coordinates)
        // Camera children are positioned relative to camera center (0,0)
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        currencyLabel.position = CGPoint(x: -halfWidth + 10, y: halfHeight - 30)
        healthLabel.position = CGPoint(x: -halfWidth + 10, y: halfHeight - 55)
        coinsLabel.position = CGPoint(x: -halfWidth + 10, y: halfHeight - 80)
        gemsLabel.position = CGPoint(x: -halfWidth + 10, y: halfHeight - 105)
        waveLabel.position = CGPoint(x: 0, y: halfHeight - 80)
        buildTimerLabel.position = CGPoint(x: 0, y: halfHeight - 105)

        addChild(currencyLabel)
        addChild(healthLabel)
        addChild(coinsLabel)
        addChild(gemsLabel)
        addChild(waveLabel)
        addChild(buildTimerLabel)

        // Position top menu buttons with uniform spacing (camera-relative, shifted left)
        let buttonSpacing: CGFloat = 80  // Reduced from 95 to fit 9 buttons
        let leftShift: CGFloat = 60  // Reduced from 80 to give more room
        let rightEdge = halfWidth - 42.5 - leftShift  // Half of button width from camera center

        gameControlsDropdown.position = CGPoint(x: rightEdge, y: halfHeight - 30)
        upgradeButton.position = CGPoint(x: rightEdge - buttonSpacing, y: halfHeight - 30)
        researchLabButton.position = CGPoint(x: rightEdge - buttonSpacing * 2, y: halfHeight - 30)
        cardsButton.position = CGPoint(x: rightEdge - buttonSpacing * 3, y: halfHeight - 30)
        modulesButton.position = CGPoint(x: rightEdge - buttonSpacing * 4, y: halfHeight - 30)
        tierProgressButton.position = CGPoint(x: rightEdge - buttonSpacing * 5, y: halfHeight - 30)
        heroControlButton.position = CGPoint(x: rightEdge - buttonSpacing * 6, y: halfHeight - 30)
        nukeButton.position = CGPoint(x: rightEdge - buttonSpacing * 7, y: halfHeight - 30)
        powerUpButton.position = CGPoint(x: rightEdge - buttonSpacing * 8, y: halfHeight - 30)

        addChild(gameControlsDropdown)
        addChild(upgradeButton)
        addChild(researchLabButton)
        addChild(cardsButton)
        addChild(modulesButton)
        addChild(tierProgressButton)
        addChild(heroControlButton)
        addChild(nukeButton)
        addChild(powerUpButton)

        // Create toggle button for top menu (camera-relative, shifted left)
        topMenuToggleButton = Button(
            text: "📋",
            size: CGSize(width: 50, height: 50),
            color: .systemGreen
        )
        topMenuToggleButton.position = CGPoint(
            x: halfWidth - 30 - 60,  // Using updated leftShift value
            y: halfHeight - 30
        )
        topMenuToggleButton.onTap = { [weak self] in
            self?.toggleTopMenu()
        }
        addChild(topMenuToggleButton)

        // Create tower buttons
        setupTowerButtons(screenSize: size)

        // Set up button callbacks
        setupButtonCallbacks()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTowerButtons(screenSize: CGSize) {
        // Camera-relative positioning
        let halfWidth = screenSize.width / 2
        let halfHeight = screenSize.height / 2
        let leftShift: CGFloat = 60  // Updated to match top menu buttons

        // Create toggle button for tower panel (camera-relative, shifted left)
        towerPanelToggleButton = Button(
            text: "🏗️",
            size: CGSize(width: 50, height: 50),
            color: .blue
        )
        towerPanelToggleButton.position = CGPoint(
            x: halfWidth - 30 - leftShift,
            y: -halfHeight + 30
        )
        towerPanelToggleButton.onTap = { [weak self] in
            self?.toggleTowerPanel()
        }
        addChild(towerPanelToggleButton)

        let towerTypes: [StructureType] = [
            .basicTower, .sniperTower, .machineGunTower,
            .cannonTower, .lightningTower, .freezeTower,
            .poisonTower, .laserTower, .flameTower,
            .bladeTower, .earthquakeTower, .slowTrap
        ]

        let buttonWidth: CGFloat = 70
        let buttonHeight: CGFloat = 35
        let buttonSpacing: CGFloat = 5
        let buttonsPerColumn = 4

        // Position from bottom right (camera-relative, shifted left)
        let startX = halfWidth - 85 - leftShift
        let startY: CGFloat = -halfHeight + 90

        for (index, type) in towerTypes.enumerated() {
            let button = TowerButton(
                type: type,
                size: CGSize(width: buttonWidth, height: buttonHeight),
                currentWave: gameState.currentWave
            )

            let col = index / buttonsPerColumn
            let row = index % buttonsPerColumn

            button.position = CGPoint(
                x: startX - CGFloat(col) * (buttonWidth + buttonSpacing),
                y: startY + CGFloat(row) * (buttonHeight + buttonSpacing)
            )
            button.onTap = { [weak self] in
                self?.onTowerSelected(type)
            }
            towerButtons[type] = button
            addChild(button)
        }
    }

    private func toggleTowerPanel() {
        towerPanelCollapsed = !towerPanelCollapsed

        // Update toggle button text
        towerPanelToggleButton.updateText(towerPanelCollapsed ? "🏗️" : "✖️")

        // Show/hide all tower buttons
        for (_, button) in towerButtons {
            button.isHidden = towerPanelCollapsed
        }
    }

    private func toggleTopMenu() {
        topMenuCollapsed = !topMenuCollapsed

        // Update toggle button text
        topMenuToggleButton.updateText(topMenuCollapsed ? "📋" : "✖️")

        // Show/hide all top menu buttons
        gameControlsDropdown.isHidden = topMenuCollapsed
        upgradeButton.isHidden = topMenuCollapsed
        researchLabButton.isHidden = topMenuCollapsed
        cardsButton.isHidden = topMenuCollapsed
        modulesButton.isHidden = topMenuCollapsed
        tierProgressButton.isHidden = topMenuCollapsed
        heroControlButton.isHidden = topMenuCollapsed
        nukeButton.isHidden = topMenuCollapsed
        powerUpButton.isHidden = topMenuCollapsed
    }

    private func setupButtonCallbacks() {
        // Set up dropdown menu items
        updateDropdownMenuItems()

        upgradeButton.onTap = { [weak self] in
            self?.onOpenUpgrades()
        }

        researchLabButton.onTap = { [weak self] in
            self?.onOpenResearchLab()
        }

        cardsButton.onTap = { [weak self] in
            self?.onOpenCards()
        }

        modulesButton.onTap = { [weak self] in
            self?.onOpenModules()
        }

        tierProgressButton.onTap = { [weak self] in
            self?.onOpenTierProgress()
        }

        heroControlButton.onTap = { [weak self] in
            self?.onToggleHeroControl()
        }

        nukeButton.onTap = { [weak self] in
            guard let self = self else { return }
            if self.hasUsedNuke() {
                print("💣 Nuke already used!")
            } else {
                self.onActivateNuke()
                self.updateNukeButtonState()
            }
        }

        powerUpButton.onTap = { [weak self] in
            guard let self = self else { return }
            let availablePowerUps = self.getAvailablePowerUps()
            if availablePowerUps > 0 {
                self.onActivatePowerUp()
                self.updatePowerUpButtonState()
            } else {
                print("⚡ No power-ups available!")
            }
        }
    }

    private func updateNukeButtonState() {
        if hasUsedNuke() {
            nukeButton.updateText("Used")
        } else {
            nukeButton.updateText("Nuke")
        }
    }

    private func updatePowerUpButtonState() {
        let count = getAvailablePowerUps()
        powerUpButton.updateText("⚡ \(count)")
    }

    private func updateDropdownMenuItems() {
        let items: [DropdownMenuItem] = [
            // Start Wave
            DropdownMenuItem(
                id: "start_wave",
                text: "🌊 Start Wave",
                color: .green,
                action: { [weak self] in
                    self?.onStartWave()
                }
            ),
            // Auto-start toggle
            DropdownMenuItem(
                id: "auto_start",
                text: isAutoStartEnabled ? "Auto: ON" : "Auto: OFF",
                color: isAutoStartEnabled ? .green : .gray,
                action: { [weak self] in
                    guard let self = self else { return }
                    self.isAutoStartEnabled.toggle()
                    self.updateDropdownMenuItems()
                }
            ),
            // Pause toggle
            DropdownMenuItem(
                id: "pause",
                text: isGamePaused ? "▶️ Resume" : "⏸ Pause",
                color: isGamePaused ? .orange : .blue,
                action: { [weak self] in
                    guard let self = self else { return }
                    self.isGamePaused.toggle()
                    self.updateDropdownMenuItems()
                }
            ),
            // Speed control
            DropdownMenuItem(
                id: "speed",
                text: "Speed: \(gameSpeed)x",
                color: gameSpeed > 1 ? .systemTeal : .gray,
                action: { [weak self] in
                    guard let self = self else { return }
                    self.gameSpeed = switch self.gameSpeed {
                    case 1: 2
                    case 2: 3
                    case 3: 5
                    case 5: 10
                    default: 1
                    }
                    self.updateDropdownMenuItems()
                }
            ),
            // Difficulty control
            {
                let difficultyColor: SKColor = switch gameState.difficulty {
                case .easy: .green
                case .normal: .orange
                case .hard: .red
                case .insane: .purple
                }

                let isLocked = gameState.currentWave > 0
                let displayText = isLocked ? "🔒 \(gameState.difficulty.rawValue)" : "Difficulty: \(gameState.difficulty.rawValue)"

                return DropdownMenuItem(
                    id: "difficulty",
                    text: displayText,
                    color: isLocked ? .darkGray : difficultyColor,
                    action: { [weak self] in
                        guard let self = self else { return }
                        guard self.gameState.currentWave == 0 else {
                            print("⚠️ Cannot change difficulty after game has started")
                            return
                        }
                        let newDifficulty: Difficulty = switch self.gameState.difficulty {
                        case .easy: .normal
                        case .normal: .hard
                        case .hard: .insane
                        case .insane: .easy
                        }
                        self.gameState.difficulty = newDifficulty
                        self.updateDropdownMenuItems()
                    }
                )
            }(),
            // Admin Mode toggle
            DropdownMenuItem(
                id: "admin_mode",
                text: gameState.isAdminMode ? "🔓 Admin: ON" : "🔒 Admin: OFF",
                color: gameState.isAdminMode ? .systemGreen : .darkGray,
                action: { [weak self] in
                    guard let self = self else { return }
                    self.gameState.toggleAdminMode()
                    self.updateDropdownMenuItems()

                    // Update all tower buttons to reflect admin mode state
                    for (_, button) in self.towerButtons {
                        button.updateForWave(self.gameState.currentWave)
                    }
                }
            )
        ]

        gameControlsDropdown.setItems(items)
    }

    func updateCurrency(_ currency: Int) {
        currencyLabel.text = "💰 \(currency)"
    }

    func updateHealth(_ health: Int) {
        healthLabel.text = "❤️ \(health)"
    }

    func updateCoins(_ coins: Int) {
        coinsLabel.text = "🪙 \(coins)"
    }

    func updateGems(_ gems: Int) {
        gemsLabel.text = "💎 \(gems)"
    }

    func refreshPowerUpButton() {
        updatePowerUpButtonState()
    }

    func isAdminModeActive() -> Bool {
        return gameState.isAdminMode
    }

    func updateWave(_ wave: Int) {
        waveLabel.text = "Wave \(wave)/\(GameConfiguration.totalWaves)"

        // Update tower button states based on new wave
        for (_, button) in towerButtons {
            button.updateForWave(wave)
        }
    }

    func updateBuildTimer(_ time: TimeInterval) {
        if time > 0 {
            buildTimerLabel.text = "Next wave in: \(Int(ceil(time)))s"
            buildTimerLabel.isHidden = false
        } else {
            buildTimerLabel.isHidden = true
        }
    }


    override func contains(_ point: CGPoint) -> Bool {
        // Check top menu buttons
        if gameControlsDropdown.contains(point) || upgradeButton.contains(point) ||
           researchLabButton.contains(point) || cardsButton.contains(point) ||
           modulesButton.contains(point) || tierProgressButton.contains(point) ||
           heroControlButton.contains(point) || nukeButton.contains(point) ||
           powerUpButton.contains(point) {
            return true
        }

        // Check tower panel toggle button
        if towerPanelToggleButton.contains(point) {
            return true
        }

        // Check top menu toggle button
        if topMenuToggleButton.contains(point) {
            return true
        }

        // Check tower buttons
        for (_, button) in towerButtons {
            if button.contains(point) {
                return true
            }
        }

        return false
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        // Check top menu buttons (only if not collapsed)
        if !topMenuCollapsed {
            if gameControlsDropdown.contains(location) {
                gameControlsDropdown.mouseDown(with: event)
                return
            }
            if upgradeButton.contains(location) {
                upgradeButton.onTap?()
                return
            }
            if researchLabButton.contains(location) {
                researchLabButton.onTap?()
                return
            }
            if cardsButton.contains(location) {
                cardsButton.onTap?()
                return
            }
            if modulesButton.contains(location) {
                modulesButton.onTap?()
                return
            }
            if tierProgressButton.contains(location) {
                tierProgressButton.onTap?()
                return
            }
            if heroControlButton.contains(location) {
                heroControlButton.onTap?()
                return
            }
            if nukeButton.contains(location) {
                nukeButton.onTap?()
                return
            }
            if powerUpButton.contains(location) {
                powerUpButton.onTap?()
                return
            }
        }

        // Check top menu toggle button
        if topMenuToggleButton.contains(location) {
            topMenuToggleButton.onTap?()
            return
        }

        // Check tower panel toggle button
        if towerPanelToggleButton.contains(location) {
            towerPanelToggleButton.onTap?()
            return
        }

        // Check tower buttons (only if not collapsed)
        if !towerPanelCollapsed {
            for (_, button) in towerButtons {
                if button.contains(location) {
                    button.mouseDown(with: event)
                    return
                }
            }
        }
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check top menu buttons (only if not collapsed)
        if !topMenuCollapsed {
            if gameControlsDropdown.contains(location) {
                gameControlsDropdown.touchesBegan(touches, with: event)
                return
            }
            if upgradeButton.contains(location) {
                upgradeButton.onTap?()
                return
            }
            if researchLabButton.contains(location) {
                researchLabButton.onTap?()
                return
            }
            if cardsButton.contains(location) {
                cardsButton.onTap?()
                return
            }
            if modulesButton.contains(location) {
                modulesButton.onTap?()
                return
            }
            if tierProgressButton.contains(location) {
                tierProgressButton.onTap?()
                return
            }
            if heroControlButton.contains(location) {
                heroControlButton.onTap?()
                return
            }
            if nukeButton.contains(location) {
                nukeButton.onTap?()
                return
            }
            if powerUpButton.contains(location) {
                powerUpButton.onTap?()
                return
            }
        }

        // Check top menu toggle button
        if topMenuToggleButton.contains(location) {
            topMenuToggleButton.onTap?()
            return
        }

        // Check tower panel toggle button
        if towerPanelToggleButton.contains(location) {
            towerPanelToggleButton.onTap?()
            return
        }

        // Check tower buttons (only if not collapsed)
        if !towerPanelCollapsed {
            for (_, button) in towerButtons {
                if button.contains(location) {
                    button.touchesBegan(touches, with: event)
                    return
                }
            }
        }
    }
    #endif
}

/// Tower button that shows lock state and unlock requirements
@MainActor
class TowerButton: SKNode {
    let type: StructureType
    private let backgroundShape: SKShapeNode
    private let label: SKLabelNode
    private let lockLabel: SKLabelNode
    private let size: CGSize
    private var isUnlocked: Bool = false

    var onTap: (() -> Void)?

    init(type: StructureType, size: CGSize, currentWave: Int) {
        self.type = type
        self.size = size
        self.isUnlocked = currentWave >= type.unlockWave

        // Background
        self.backgroundShape = SKShapeNode(rectOf: size, cornerRadius: 5)
        self.backgroundShape.strokeColor = .white
        self.backgroundShape.lineWidth = 2

        // Text label
        self.label = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.label.fontSize = 12
        self.label.fontColor = .white
        self.label.verticalAlignmentMode = .center
        self.label.horizontalAlignmentMode = .center
        self.label.preferredMaxLayoutWidth = size.width - 10

        // Lock label (shows unlock wave when locked)
        self.lockLabel = SKLabelNode(fontNamed: "Helvetica")
        self.lockLabel.fontSize = 10
        self.lockLabel.fontColor = .yellow
        self.lockLabel.verticalAlignmentMode = .center
        self.lockLabel.horizontalAlignmentMode = .center
        self.lockLabel.position = CGPoint(x: 0, y: -12)

        super.init()

        addChild(backgroundShape)
        addChild(label)
        addChild(lockLabel)

        updateAppearance()

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateForWave(_ wave: Int) {
        // Check if admin mode is active by looking for GameHUD in parent hierarchy
        var isAdminMode = false
        if let hud = parent as? GameHUD {
            isAdminMode = hud.isAdminModeActive()
        }

        // Unlock if wave requirement met OR admin mode is active
        isUnlocked = wave >= type.unlockWave || isAdminMode
        updateAppearance()
    }

    private func updateAppearance() {
        if isUnlocked {
            backgroundShape.fillColor = type.color
            label.text = "\(type.displayName.prefix(6))\n$\(type.cost)"
            label.position = CGPoint(x: 0, y: 0)
            label.numberOfLines = 2
            lockLabel.isHidden = true
        } else {
            backgroundShape.fillColor = SKColor.darkGray.withAlphaComponent(0.5)
            label.text = "🔒 \(type.displayName.prefix(6))"
            label.position = CGPoint(x: 0, y: 5)
            label.numberOfLines = 1
            lockLabel.text = "Wave \(type.unlockWave)"
            lockLabel.isHidden = false
        }
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        if isUnlocked {
            onTap?()
        }
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isUnlocked {
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

/// Simple button node
@MainActor
class Button: SKShapeNode {
    private let label: SKLabelNode
    private let buttonSize: CGSize
    var onTap: (() -> Void)?

    init(text: String, size: CGSize, color: SKColor) {
        self.buttonSize = size
        self.label = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.label.text = text
        self.label.fontSize = 14
        self.label.fontColor = .white
        self.label.verticalAlignmentMode = .center
        self.label.horizontalAlignmentMode = .center

        super.init()

        let rect = SKShapeNode(rectOf: size, cornerRadius: 5)
        rect.fillColor = color
        rect.strokeColor = .white
        rect.lineWidth = 2
        addChild(rect)
        addChild(label)

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateText(_ newText: String) {
        label.text = newText
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        onTap?()
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTap?()
    }
    #endif

    override func contains(_ point: CGPoint) -> Bool {
        guard let parent = parent else { return false }
        let localPoint = self.convert(point, from: parent)
        return abs(localPoint.x) < buttonSize.width / 2 && abs(localPoint.y) < buttonSize.height / 2
    }
}
