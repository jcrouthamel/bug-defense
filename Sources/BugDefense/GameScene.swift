import SpriteKit
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// Main game scene that ties everything together
@MainActor
public class GameScene: SKScene {
    // Core managers
    private let gameState = GameStateManager()
    private lazy var waveManager = WaveManager(gameState: gameState)
    private lazy var upgradeManager = UpgradeManager(gameState: gameState)
    private let researchLab = ResearchLab()
    private let cardManager = CardManager()
    private let moduleManager = ModuleManager()
    private let abilityManager = ActiveAbilityManager()
    private let pathfindingGrid = PathfindingGrid(
        width: GameConfiguration.gridWidth,
        height: GameConfiguration.gridHeight
    )

    // Game entities
    private var house: House!
    private var hero: Hero!
    private var bugs: [Bug] = []
    private var structures: [DefenseStructure] = []

    // Grid visualization
    private var gridLayer: SKNode!
    private var structurePlacementLayer: SKNode!

    // Camera
    private var gameCamera: SKCameraNode!

    // UI
    private var hud: GameHUD!
    private var upgradeMenu: UpgradeMenu?
    private var researchLabMenu: ResearchLabMenu?
    private var cardMenu: CardMenu?
    private var moduleMenu: ModuleMenu?
    private var towerUpgradePanel: TowerUpgradePanel?
    private var tierProgressionUI: TierProgressionUI?

    // Placement mode
    private var placementMode: StructureType?
    private var placementPreview: SKShapeNode?

    // Hero control
    private var heroControlMode: Bool = false
    private var heroSelectionIndicator: SKShapeNode?

    // Timing
    private var lastUpdateTime: TimeInterval = 0
    private var buildPhaseTimer: TimeInterval = 0
    private var isRestarting: Bool = false

    public override func didMove(to view: SKView) {
        print("🎮 GameScene loaded! Scene size: \(size)")
        setupScene()
        setupCallbacks()
        print("✅ Game initialization complete")
    }

    private func setupScene() {
        backgroundColor = SKColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 1.0)

        // Wire up gameState references for managers
        researchLab.gameState = gameState
        moduleManager.gameState = gameState

        // Set up camera to center the view on the game grid
        gameCamera = SKCameraNode()
        self.camera = gameCamera
        addChild(gameCamera)

        // Calculate grid dimensions
        let gridWidth = CGFloat(GameConfiguration.gridWidth) * GameConfiguration.tileSize
        let gridHeight = CGFloat(GameConfiguration.gridHeight) * GameConfiguration.tileSize

        // Position camera to center on the grid with some top margin for HUD
        let topMargin: CGFloat = 40  // Space for top HUD elements
        let cameraX = gridWidth / 2
        let cameraY = gridHeight / 2 - topMargin / 2
        gameCamera.position = CGPoint(x: cameraX, y: cameraY)

        print("📷 Camera positioned at (\(cameraX), \(cameraY)) for grid \(gridWidth)x\(gridHeight)")

        // Create grid layer
        gridLayer = SKNode()
        addChild(gridLayer)
        drawGrid()

        // Create structure placement layer
        structurePlacementLayer = SKNode()
        addChild(structurePlacementLayer)

        // Create house
        house = House(
            at: MapManager.shared.getCurrentHousePosition(),
            health: GameConfiguration.houseMaxHealth
        )
        pathfindingGrid.setBlocked(at: MapManager.shared.getCurrentHousePosition(), blocked: true)
        addChild(house)

        // Create hero - spawn near the house
        let heroStartPos = GridPosition(
            x: MapManager.shared.getCurrentHousePosition().x - 2,
            y: MapManager.shared.getCurrentHousePosition().y - 2
        )
        hero = Hero(at: heroStartPos)
        addChild(hero)

        // Create hero selection indicator
        heroSelectionIndicator = SKShapeNode(circleOfRadius: GameConfiguration.tileSize * 0.8)
        heroSelectionIndicator!.strokeColor = .cyan
        heroSelectionIndicator!.lineWidth = 3
        heroSelectionIndicator!.fillColor = .clear
        heroSelectionIndicator!.zPosition = 5
        heroSelectionIndicator!.isHidden = true
        hero.addChild(heroSelectionIndicator!)

        // Create HUD and attach to camera so it stays fixed on screen
        hud = GameHUD(
            size: size,
            gameState: gameState,
            onTowerSelected: { [weak self] type in
                self?.enterPlacementMode(type: type)
            },
            onStartWave: { [weak self] in
                self?.startWave()
            },
            onOpenUpgrades: { [weak self] in
                self?.openUpgradeMenu()
            },
            onOpenResearchLab: { [weak self] in
                self?.openResearchLabMenu()
            },
            onOpenCards: { [weak self] in
                self?.openCardMenu()
            },
            onOpenModules: { [weak self] in
                self?.openModuleMenu()
            },
            onOpenTierProgress: { [weak self] in
                self?.openTierProgressionMenu()
            },
            onToggleHeroControl: { [weak self] in
                self?.toggleHeroControlMode()
            }
        )
        gameCamera.addChild(hud)

        // Update HUD initial values
        hud.updateCurrency(gameState.currency)
        hud.updateHealth(gameState.houseHealth)
        hud.updateCoins(researchLab.totalCoins)
        hud.updateGems(moduleManager.gems)
        hud.updateWave(gameState.currentWave)
    }

    private func setupCallbacks() {
        // Game state callbacks
        gameState.onStateChanged = { [weak self] state in
            self?.handleStateChange(state)
        }

        gameState.onCurrencyChanged = { [weak self] currency in
            self?.hud.updateCurrency(currency)
        }

        gameState.onHealthChanged = { [weak self] health in
            self?.hud.updateHealth(health)
        }

        gameState.onWaveChanged = { [weak self] wave in
            self?.hud.updateWave(wave)
        }

        gameState.onWaveCompleted = { [weak self] coins in
            guard let self = self else { return }
            // Apply coin multiplier from cards
            let totalCoins = Int(CGFloat(coins) * self.cardManager.getTotalCoinMultiplier())
            self.researchLab.addCoins(totalCoins)
        }

        // Wave manager callbacks
        waveManager.onBugSpawned = { [weak self] bug in
            self?.spawnBug(bug)
        }

        waveManager.onWaveComplete = { [weak self] in
            self?.handleWaveComplete()
        }

        // Upgrade manager callbacks
        upgradeManager.onUpgradePurchased = { [weak self] upgrade in
            self?.applyUpgradeToStructures(upgrade)
        }

        // Research lab callbacks
        researchLab.onUpgradeChanged = { [weak self] _, _ in
            self?.applyResearchToAllStructures()
        }

        researchLab.onCoinsChanged = { [weak self] coins in
            self?.hud.updateCoins(coins)
        }

        // Module manager callbacks
        moduleManager.onGemsChanged = { [weak self] gems in
            self?.hud.updateGems(gems)
        }
    }

    private func drawGrid() {
        // Create a set of road positions for quick lookup
        let roadPositions = Set(MapManager.shared.getCurrentRoadPath())
        let housePosition = MapManager.shared.getCurrentHousePosition()

        for x in 0..<GameConfiguration.gridWidth {
            for y in 0..<GameConfiguration.gridHeight {
                let position = GridPosition(x: x, y: y)

                // Create base tile
                let rect = SKShapeNode(
                    rectOf: CGSize(
                        width: GameConfiguration.tileSize,
                        height: GameConfiguration.tileSize
                    )
                )
                rect.position = position.toWorldPosition()
                rect.strokeColor = SKColor.white.withAlphaComponent(0.1)
                rect.lineWidth = 1

                // Color tiles based on type
                if roadPositions.contains(position) {
                    // Road path - brown dirt color
                    rect.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 0.8)
                } else if position == housePosition {
                    // House position - darker grass
                    rect.fillColor = SKColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 0.5)
                } else {
                    // Grass background
                    rect.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.4)
                }

                gridLayer.addChild(rect)

                // Add decorative elements (grass, trees, rocks, bushes, water)
                if !roadPositions.contains(position) && position != housePosition {
                    // Randomly add decorations (20% chance)
                    let random = CGFloat.random(in: 0...1)
                    var decoration: String? = nil

                    if random < 0.05 {
                        decoration = "🌳" // Tree
                    } else if random < 0.10 {
                        decoration = "🪨" // Rock
                    } else if random < 0.13 {
                        decoration = "🌲" // Pine tree
                    } else if random < 0.15 {
                        decoration = "🌿" // Bush
                    } else if random < 0.17 {
                        decoration = "💧" // Water droplet
                    } else if random < 0.20 {
                        decoration = "🌾" // Grass tuft
                    }

                    if let emoji = decoration {
                        let decorationLabel = SKLabelNode(text: emoji)
                        decorationLabel.fontSize = GameConfiguration.tileSize * 0.6
                        decorationLabel.verticalAlignmentMode = .center
                        decorationLabel.horizontalAlignmentMode = .center
                        decorationLabel.position = position.toWorldPosition()
                        decorationLabel.zPosition = -0.5 // Behind structures
                        decorationLabel.alpha = 0.7
                        gridLayer.addChild(decorationLabel)
                    }
                }
            }
        }
    }

    private func redrawGrid() {
        // Remove all existing grid tiles
        gridLayer.removeAllChildren()

        // Redraw with new road path
        drawGrid()

        print("🗺️ Grid redrawn for new map layout")
    }

    private func resetAllTowers() {
        // Remove all structures from the scene
        for structure in structures {
            structure.removeFromParent()
        }

        // Clear the structures array
        structures.removeAll()

        // Clear pathfinding grid occupied tiles
        pathfindingGrid.reset()

        print("🔄 All towers have been reset for new tier")
    }

    // MARK: - Game Loop

    public override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Skip updates if game is paused
        if hud.isGamePaused {
            showPauseOverlay()
            return
        } else {
            hidePauseOverlay()
        }

        // Apply game speed multiplier
        let adjustedDeltaTime = deltaTime * TimeInterval(hud.gameSpeed)

        // Update ability manager cooldowns
        abilityManager.update(deltaTime: deltaTime)

        switch gameState.currentState {
        case .building:
            updateBuildingPhase(deltaTime: adjustedDeltaTime)
        case .wave:
            updateWavePhase(deltaTime: adjustedDeltaTime)
        case .gameOver:
            handleGameOver()
        case .victory:
            handleVictory()
        default:
            break
        }
    }

    private func updateBuildingPhase(deltaTime: TimeInterval) {
        buildPhaseTimer += deltaTime

        // Use shorter delay if auto-start is enabled (3 seconds), otherwise use full time (20 seconds)
        let autoStartDelay: TimeInterval = 3.0
        let waveStartTime = hud.isAutoStartEnabled ? autoStartDelay : GameConfiguration.timeBetweenWaves

        let timeRemaining = max(0, waveStartTime - buildPhaseTimer)
        hud.updateBuildTimer(timeRemaining)

        // Auto-start wave if timer expires
        if buildPhaseTimer >= waveStartTime {
            startWave()
        }

        // Apply auto-repair
        applyAutoRepair(deltaTime: deltaTime)
    }

    private func updateWavePhase(deltaTime: TimeInterval) {
        // Update wave manager
        waveManager.update(deltaTime: deltaTime, activeBugs: bugs.count)

        // Update bugs
        var bugsToRemove: [Bug] = []
        for bug in bugs {
            bug.update(deltaTime: deltaTime, pathfindingGrid: pathfindingGrid)

            // Check if bug reached house
            if bug.hasReachedHouse() {
                print("💥 Bug reached house! Dealing \(bug.damage) damage")
                gameState.damageHouse(bug.damage)
                house.takeDamage(bug.damage)
                bugsToRemove.append(bug)
            }
        }

        // Remove bugs that reached house
        for bug in bugsToRemove {
            removeBug(bug)
        }

        // Update structures
        for structure in structures {
            structure.update(deltaTime: deltaTime, bugs: bugs)
        }

        // Update hero
        hero.update(deltaTime: deltaTime, bugs: bugs)

        // Apply auto-repair during wave
        applyAutoRepair(deltaTime: deltaTime)

        // Remove dead bugs
        let deadBugs = bugs.filter { $0.currentHealth <= 0 }
        for bug in deadBugs {
            handleBugDeath(bug)
        }
    }

    private func applyAutoRepair(deltaTime: TimeInterval) {
        let totalRepairRate = upgradeManager.totalRepairRate + cardManager.getTotalRepairRate()
        let repairAmount = Int(CGFloat(totalRepairRate) * CGFloat(deltaTime))
        if repairAmount > 0 {
            for structure in structures {
                structure.repair(repairAmount)
            }
        }
    }

    // MARK: - Wave Management

    public func startWave() {
        guard gameState.currentState == .building else { return }

        // Apply starting currency bonus from cards
        let startingBonus = cardManager.getTotalStartingCurrencyBonus()
        if startingBonus > 0 {
            gameState.addCurrency(startingBonus)
        }

        print("🌊 Starting wave \(gameState.currentWave + 1)")

        // Check if we're entering a new tier
        let previousTier = TierProgressionManager.shared.getCurrentTier(for: gameState.currentWave)

        gameState.startNextWave()

        // Update map for current tier
        TierProgressionManager.shared.updateMapForWave(gameState.currentWave)

        let newTier = TierProgressionManager.shared.getCurrentTier(for: gameState.currentWave)

        // If tier changed, redraw grid and reset towers
        if previousTier.number != newTier.number {
            print("🏆 Tier transition: \(previousTier.name) → \(newTier.name)")
            resetAllTowers()
            redrawGrid()
        }

        waveManager.startWave()
        buildPhaseTimer = 0
        exitPlacementMode()
    }

    private func handleWaveComplete() {
        buildPhaseTimer = 0

        // Award card for boss waves
        if gameState.isBossWave() {
            if let card = cardManager.awardRandomCard() {
                showCardRewardPopup(card)
            }
        }

        // Show tier progression UI when tier is completed
        if TierProgressionManager.shared.justCompletedTier(wave: gameState.currentWave) {
            // Small delay to show after card popup (if any)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.showTierCompletionPopup()
            }
        }

        gameState.checkVictory()

        // Auto-save progress after completing a wave
        saveGame()
    }

    private func spawnBug(_ bug: Bug) {
        // Apply card slow effects as base slow factor
        let cardSlowFactor = cardManager.getTotalBugSlowFactor()
        bug.baseSlowFactor = cardSlowFactor
        bug.slowFactor = cardSlowFactor

        // Find path to house
        let path: [GridPosition]?
        if bug.bugType.canFly {
            // Flying bugs take direct path, ignoring roads
            path = pathfindingGrid.findFlyingPath(
                from: bug.gridPosition,
                to: MapManager.shared.getCurrentHousePosition()
            )
        } else {
            // Ground bugs follow the road, but pathfind around obstacles if needed
            let roadPath = MapManager.shared.getCurrentRoadPath()
            print("📍 Road path has \(roadPath.count) waypoints, starts at \(roadPath.first?.description ?? "nil"), ends at \(roadPath.last?.description ?? "nil")")

            // Check if the road is blocked by walls
            if isRoadPathBlocked(roadPath) {
                // Road is blocked, use A* pathfinding
                print("🚧 Road is blocked! Using A* pathfinding for \(bug.bugType)")
                path = pathfindingGrid.findPath(
                    from: bug.gridPosition,
                    to: MapManager.shared.getCurrentHousePosition()
                )
                print("📍 A* path has \(path?.count ?? 0) waypoints")
            } else {
                // Road is clear, use the predefined road path
                print("🛣️ Road is clear! Using predefined road path for \(bug.bugType) with \(roadPath.count) waypoints")
                path = roadPath
            }
        }

        if let path = path {
            bug.setPath(path)
            bugs.append(bug)
            addChild(bug)
            print("✅ Bug spawned: \(bug.bugType) at position \(bug.gridPosition)")
        } else {
            print("❌ Failed to spawn bug: No path found from \(bug.gridPosition) to house")
        }
    }

    private func handleBugDeath(_ bug: Bug) {
        // Award currency with card multiplier, difficulty multiplier, and gold rush bonus
        var reward = Int(CGFloat(bug.bugType.reward) * cardManager.getTotalCurrencyMultiplier() * gameState.difficulty.rewardMultiplier)

        // Double reward if Gold Rush is active
        if abilityManager.isGoldRushActive() {
            reward *= 2
        }

        gameState.addCurrency(reward)

        // Try to drop a module
        if let droppedModule = moduleManager.tryDropModule(fromWave: gameState.currentWave) {
            showModuleDropNotification(droppedModule, at: bug.position)
        }

        // Handle splitters
        if bug.bugType == .splitter, let splitBugs = bug.split() {
            for splitBug in splitBugs {
                spawnBug(splitBug)
            }
        }

        removeBug(bug)
    }

    private func removeBug(_ bug: Bug) {
        bug.removeFromParent()
        bugs.removeAll { $0 === bug }
    }

    // MARK: - Structure Placement

    private func enterPlacementMode(type: StructureType) {
        // Allow placement during building phase or active wave
        guard gameState.currentState == .building || gameState.currentState == .wave else {
            print("❌ Cannot enter placement mode - not in building or wave phase")
            return
        }
        guard gameState.currency >= type.cost else {
            print("❌ Cannot enter placement mode - insufficient funds (\(gameState.currency) < \(type.cost))")
            return
        }

        print("✅ Entered placement mode for: \(type.displayName)")
        placementMode = type
        createPlacementPreview(for: type)
    }

    private func exitPlacementMode() {
        placementMode = nil
        placementPreview?.removeFromParent()
        placementPreview = nil
    }

    private func toggleHeroControlMode() {
        heroControlMode = !heroControlMode

        // Exit placement mode if entering hero control mode
        if heroControlMode {
            exitPlacementMode()
        }

        // Update selection indicator
        heroSelectionIndicator?.isHidden = !heroControlMode

        print(heroControlMode ? "🧙‍♂️ Hero control mode enabled" : "🧙‍♂️ Hero control mode disabled")
    }

    private func createPlacementPreview(for type: StructureType) {
        placementPreview?.removeFromParent()

        let size = GameConfiguration.tileSize * 0.8
        let preview = SKShapeNode(rectOf: CGSize(width: size, height: size))
        preview.fillColor = SKColor.white.withAlphaComponent(0.5)
        preview.strokeColor = .white
        preview.lineWidth = 2
        placementPreview = preview
        addChild(preview)
    }

    #if os(macOS)
    public override func mouseMoved(with event: NSEvent) {
        guard let preview = placementPreview else { return }

        let location = event.location(in: self)
        let gridPos = GridPosition.fromWorldPosition(location)

        // Snap to grid
        preview.position = gridPos.toWorldPosition()

        // Change color based on validity
        let canPlace = canPlaceStructure(at: gridPos)
        preview.fillColor = canPlace ?
            SKColor.green.withAlphaComponent(0.5) :
            SKColor.red.withAlphaComponent(0.5)
    }

    public override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let gridPos = GridPosition.fromWorldPosition(location)

        print("🖱️ Mouse click at world: \(location), grid: \(gridPos)")

        // First, check if any nodes at this location want to handle the event
        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint {
            if node.isUserInteractionEnabled {
                print("🎯 Delegating to node: \(type(of: node))")
                node.mouseDown(with: event)
                return
            }
        }

        // Handle structure placement
        if let type = placementMode {
            print("📍 Attempting to place \(type.displayName) at \(gridPos)")
            if canPlaceStructure(at: gridPos) {
                placeStructure(type: type, at: gridPos)
            }
            return
        }

        // Check if clicking on a tower to upgrade
        for structure in structures {
            if let tower = structure as? Tower {
                let distance = sqrt(pow(location.x - tower.position.x, 2) + pow(location.y - tower.position.y, 2))
                if distance < GameConfiguration.tileSize / 2 {
                    print("🗼 Clicked tower at \(tower.gridPosition)")
                    openTowerUpgradePanel(tower: tower)
                    return
                }
            }
        }

        // Move hero to clicked position (only if hero control mode is enabled)
        if heroControlMode {
            hero.moveTo(gridPosition: gridPos)
            print("🧙‍♂️ Hero moving to \(gridPos)")
        }
    }

    public override func keyDown(with event: NSEvent) {
        let key = event.charactersIgnoringModifiers ?? ""

        // Spacebar to start wave
        if key == " " {
            print("⌨️ Spacebar pressed - starting wave")
            startWave()
            return
        }

        // R to restart game (when game over or victory)
        if key == "r" || key == "R" {
            if gameState.currentState == .gameOver || gameState.currentState == .victory {
                print("⌨️ R pressed - restarting game")
                restartGame()
                return
            }
        }

        super.keyDown(with: event)
    }
    #elseif os(iOS)
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let gridPos = GridPosition.fromWorldPosition(location)

        print("👆 Touch at world: \(location), grid: \(gridPos)")

        // First, check if any nodes at this location want to handle the event
        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint {
            if node.isUserInteractionEnabled {
                print("🎯 Found interactive node: \(type(of: node))")
                // Forward touch to the node
                node.touchesBegan(touches, with: event)
                return
            }
        }

        // Handle structure placement
        if let type = placementMode {
            print("📍 Attempting to place \(type.displayName) at \(gridPos)")
            if canPlaceStructure(at: gridPos) {
                placeStructure(type: type, at: gridPos)
            }
            return
        }

        // Check if tapping on a tower to upgrade
        for structure in structures {
            if let tower = structure as? Tower {
                let distance = sqrt(pow(location.x - tower.position.x, 2) + pow(location.y - tower.position.y, 2))
                if distance < GameConfiguration.tileSize / 2 {
                    print("🗼 Tapped tower at \(tower.gridPosition)")
                    openTowerUpgradePanel(tower: tower)
                    return
                }
            }
        }

        // Move hero to tapped position (only if hero control mode is enabled)
        if heroControlMode {
            hero.moveTo(gridPosition: gridPos)
            print("🧙‍♂️ Hero moving to \(gridPos)")
        }
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let preview = placementPreview else { return }

        let location = touch.location(in: self)
        let gridPos = GridPosition.fromWorldPosition(location)

        // Snap to grid
        preview.position = gridPos.toWorldPosition()

        // Change color based on validity
        let canPlace = canPlaceStructure(at: gridPos)
        preview.fillColor = canPlace ?
            SKColor.green.withAlphaComponent(0.5) :
            SKColor.red.withAlphaComponent(0.5)
    }
    #endif

    private func canPlaceStructure(at position: GridPosition) -> Bool {
        // Check bounds
        guard position.x >= 0 && position.x < GameConfiguration.gridWidth &&
              position.y >= 0 && position.y < GameConfiguration.gridHeight else {
            print("❌ Out of bounds: \(position)")
            return false
        }

        // Check if house position
        if position == MapManager.shared.getCurrentHousePosition() {
            print("❌ Cannot place on house: \(position)")
            return false
        }

        // Check if on the road path - cannot place structures on road
        if MapManager.shared.getCurrentRoadPath().contains(position) {
            print("❌ Cannot place on road: \(position)")
            return false
        }

        // Check if another structure is already there
        for structure in structures {
            if structure.gridPosition == position {
                print("❌ Structure already exists at: \(position)")
                return false
            }
        }

        print("✅ Can place at: \(position)")
        return true
    }

    private func placeStructure(type: StructureType, at position: GridPosition) {
        let adjustedCost = Int(CGFloat(type.cost) * researchLab.getCostMultiplier())
        guard gameState.spendCurrency(adjustedCost) else { return }

        let structure: DefenseStructure

        switch type {
        case .basicTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 3,
                damage: 10,
                attackSpeed: 1.0
            )
        case .sniperTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 5,
                damage: 30,
                attackSpeed: 2.0
            )
        case .machineGunTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 2.5,
                damage: 5,
                attackSpeed: 0.3 // Very fast
            )
        case .cannonTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 4,
                damage: 40,
                attackSpeed: 3.0 // Slow but powerful
            )
        case .lightningTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 3.5,
                damage: 20,
                attackSpeed: 1.5
            )
        case .freezeTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 3,
                damage: 8,
                attackSpeed: 1.0
            )
        case .poisonTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 3.5,
                damage: 15,
                attackSpeed: 2.0
            )
        case .laserTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 6,
                damage: 50,
                attackSpeed: 2.5
            )
        case .flameTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 3.5,
                damage: 18,
                attackSpeed: 0.8 // Streams fire continuously
            )
        case .bladeTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 4,
                damage: 22,
                attackSpeed: 1.2 // Fast dagger shots
            )
        case .earthquakeTower:
            structure = Tower(
                type: type,
                at: position,
                range: GameConfiguration.tileSize * 2.5,
                damage: 25,
                attackSpeed: 2.5 // Slower but powerful area damage
            )
        case .slowTrap:
            structure = SlowTrap(at: position)
        }

        // Apply upgrades
        applyUpgradesToStructure(structure)

        structures.append(structure)
        structurePlacementLayer.addChild(structure)
        pathfindingGrid.setBlocked(at: position, blocked: true)

        // Recalculate paths for all bugs
        recalculateBugPaths()
    }

    private func applyUpgradesToStructure(_ structure: DefenseStructure) {
        if let tower = structure as? Tower {
            // Apply upgrade tree bonuses + research bonuses + card bonuses
            tower.damageMultiplier = upgradeManager.totalDamageMultiplier *
                                     researchLab.getDamageMultiplier() *
                                     cardManager.getTotalDamageMultiplier()
            tower.attackSpeedMultiplier = upgradeManager.totalAttackSpeedMultiplier *
                                         researchLab.getAttackSpeedMultiplier() *
                                         cardManager.getTotalAttackSpeedMultiplier()
            tower.rangeMultiplier = researchLab.getRangeMultiplier() *
                                   cardManager.getTotalRangeMultiplier()
        }

        // Apply health multiplier from upgrades + research + cards
        let totalHealthMultiplier = upgradeManager.totalHealthMultiplier *
                                   researchLab.getHealthMultiplier() *
                                   cardManager.getTotalHealthMultiplier()
        structure.currentHealth = Int(CGFloat(structure.maxHealth) * totalHealthMultiplier)
    }

    private func applyUpgradeToStructures(_ upgrade: Upgrade) {
        for structure in structures {
            if let tower = structure as? Tower {
                tower.damageMultiplier = upgradeManager.totalDamageMultiplier *
                                        researchLab.getDamageMultiplier() *
                                        cardManager.getTotalDamageMultiplier()
                tower.attackSpeedMultiplier = upgradeManager.totalAttackSpeedMultiplier *
                                             researchLab.getAttackSpeedMultiplier() *
                                             cardManager.getTotalAttackSpeedMultiplier()
                tower.rangeMultiplier = researchLab.getRangeMultiplier() *
                                       cardManager.getTotalRangeMultiplier()
            }
        }
    }

    private func applyResearchToAllStructures() {
        for structure in structures {
            applyUpgradesToStructure(structure)
        }
    }

    private func isRoadPathBlocked(_ roadPath: [GridPosition]) -> Bool {
        // Check if any position in the road path is blocked by a wall or structure
        // Exclude the house/goal position since bugs are supposed to reach it
        let housePosition = MapManager.shared.getCurrentHousePosition()
        for position in roadPath {
            if position != housePosition && pathfindingGrid.isBlocked(at: position) {
                print("⛔ Road is blocked at \(position)!")
                return true
            }
        }
        return false
    }

    private func recalculateBugPaths() {
        print("🔄 Recalculating bug paths for \(bugs.count) bugs")
        for bug in bugs {
            let path: [GridPosition]?
            if bug.bugType.canFly {
                // Flying bugs take direct path
                path = pathfindingGrid.findFlyingPath(
                    from: bug.gridPosition,
                    to: MapManager.shared.getCurrentHousePosition()
                )
            } else {
                // Ground bugs follow the road, but pathfind around obstacles if needed
                let roadPath = MapManager.shared.getCurrentRoadPath()

                // Check if the road is blocked by walls
                if isRoadPathBlocked(roadPath) {
                    // Road is blocked, use A* pathfinding
                    print("🚧 [Recalc] Road is blocked! Using A* pathfinding for \(bug.bugType) at \(bug.gridPosition)")
                    path = pathfindingGrid.findPath(
                        from: bug.gridPosition,
                        to: MapManager.shared.getCurrentHousePosition()
                    )
                } else {
                    // Road is clear, use the predefined road path
                    print("🛣️ [Recalc] Road is clear! Using predefined road path for \(bug.bugType) at \(bug.gridPosition)")
                    path = roadPath
                }
            }

            if let path = path {
                bug.setPath(path)
            }
        }
    }

    // MARK: - Upgrade Menu

    private func openUpgradeMenu() {
        upgradeMenu?.removeFromParent()
        upgradeMenu = UpgradeMenu(
            size: size,
            upgradeManager: upgradeManager,
            onClose: { [weak self] in
                self?.closeUpgradeMenu()
            }
        )
        gameCamera.addChild(upgradeMenu!)
    }

    private func closeUpgradeMenu() {
        upgradeMenu?.removeFromParent()
        upgradeMenu = nil
    }

    // MARK: - Tower Upgrade Panel

    private func openTowerUpgradePanel(tower: Tower) {
        // Close any open menus
        closeUpgradeMenu()
        closeResearchLabMenu()
        closeCardMenu()
        closeModuleMenu()
        closeTowerUpgradePanel()

        towerUpgradePanel = TowerUpgradePanel(
            tower: tower,
            gameState: gameState,
            onClose: { [weak self] in
                self?.closeTowerUpgradePanel()
            },
            onUpgrade: { [weak self] tower in
                guard let self = self else { return false }
                let cost = tower.getUpgradeCost()
                if gameState.currency >= cost && tower.canUpgrade() {
                    gameState.spendCurrency(cost)
                    if let towerToUpgrade = tower as? Tower {
                        towerToUpgrade.upgradeTower()
                    }
                    hud.updateCurrency(gameState.currency)
                    print("✅ Upgraded tower to level \(tower.level)")
                    return true
                } else {
                    print("❌ Cannot upgrade tower - insufficient funds or max level")
                    return false
                }
            },
            onSell: { [weak self] tower in
                guard let self = self else { return }

                // Calculate sell value and refund
                let sellValue = tower.getSellValue()
                gameState.addCurrency(sellValue)
                hud.updateCurrency(gameState.currency)

                // Remove tower from structures array
                if let index = structures.firstIndex(where: { $0 === tower }) {
                    structures.remove(at: index)
                }

                // Remove tower from scene
                tower.removeFromParent()

                // Close the upgrade panel
                closeTowerUpgradePanel()

                print("💰 Sold tower for $\(sellValue)")
            }
        )
        if let panel = towerUpgradePanel {
            panel.position = CGPoint(x: 0, y: 0)  // Camera-relative
            gameCamera.addChild(panel)
        }
    }

    private func closeTowerUpgradePanel() {
        towerUpgradePanel?.removeFromParent()
        towerUpgradePanel = nil
    }

    // MARK: - Research Lab Menu

    private func openResearchLabMenu() {
        researchLabMenu?.removeFromParent()
        researchLabMenu = ResearchLabMenu(
            size: size,
            researchLab: researchLab,
            onClose: { [weak self] in
                self?.closeResearchLabMenu()
            }
        )
        gameCamera.addChild(researchLabMenu!)
    }

    private func closeResearchLabMenu() {
        researchLabMenu?.removeFromParent()
        researchLabMenu = nil
    }

    // MARK: - Card Menu

    private func openCardMenu() {
        cardMenu?.removeFromParent()
        cardMenu = CardMenu(
            size: size,
            cardManager: cardManager,
            researchLab: researchLab,
            onClose: { [weak self] in
                self?.closeCardMenu()
            }
        )
        gameCamera.addChild(cardMenu!)
    }

    private func closeCardMenu() {
        cardMenu?.removeFromParent()
        cardMenu = nil
    }

    private func showCardRewardPopup(_ card: Card) {
        // Create a semi-transparent overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.8)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.name = "cardRewardOverlay"

        // Title
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "🎉 NEW CARD EARNED! 🎉"
        title.fontSize = 36
        title.fontColor = .yellow
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 120)
        title.name = "cardRewardOverlay"

        // Card display box
        let cardBox = SKShapeNode(rectOf: CGSize(width: 300, height: 200), cornerRadius: 15)
        let color = card.rarity.color
        cardBox.fillColor = SKColor(red: color.r, green: color.g, blue: color.b, alpha: 0.4)
        cardBox.strokeColor = SKColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
        cardBox.lineWidth = 4
        cardBox.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cardBox.name = "cardRewardOverlay"

        // Card emoji
        let emoji = SKLabelNode(fontNamed: "Helvetica")
        emoji.text = card.emoji
        emoji.fontSize = 60
        emoji.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        emoji.name = "cardRewardOverlay"

        // Card name
        let name = SKLabelNode(fontNamed: "Helvetica-Bold")
        name.text = card.name
        name.fontSize = 22
        name.fontColor = .white
        name.position = CGPoint(x: size.width / 2, y: size.height / 2 - 30)
        name.name = "cardRewardOverlay"

        // Card rarity
        let rarity = SKLabelNode(fontNamed: "Helvetica")
        rarity.text = card.rarity.rawValue
        rarity.fontSize = 16
        rarity.fontColor = SKColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
        rarity.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        rarity.name = "cardRewardOverlay"

        // Card description
        let description = SKLabelNode(fontNamed: "Helvetica")
        description.text = card.description
        description.fontSize = 14
        description.fontColor = .lightGray
        description.position = CGPoint(x: size.width / 2, y: size.height / 2 - 85)
        description.preferredMaxLayoutWidth = 280
        description.name = "cardRewardOverlay"

        // Close button
        let closeButton = Button(
            text: "Continue",
            size: CGSize(width: 150, height: 50),
            color: .green
        )
        closeButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
        closeButton.name = "cardRewardOverlay"
        closeButton.onTap = { [weak self] in
            self?.dismissCardRewardPopup()
        }

        addChild(overlay)
        addChild(title)
        addChild(cardBox)
        addChild(emoji)
        addChild(name)
        addChild(rarity)
        addChild(description)
        addChild(closeButton)
    }

    private func dismissCardRewardPopup() {
        // Remove all popup elements
        enumerateChildNodes(withName: "cardRewardOverlay") { node, _ in
            node.removeFromParent()
        }
    }

    // MARK: - Module Menu

    private func openModuleMenu() {
        moduleMenu?.removeFromParent()
        moduleMenu = ModuleMenu(
            size: size,
            moduleManager: moduleManager,
            researchLab: researchLab,
            onClose: { [weak self] in
                self?.closeModuleMenu()
            }
        )
        gameCamera.addChild(moduleMenu!)
    }

    private func closeModuleMenu() {
        moduleMenu?.removeFromParent()
        moduleMenu = nil
    }

    // MARK: - Tier Progression Menu

    private func openTierProgressionMenu() {
        tierProgressionUI?.removeFromParent()
        tierProgressionUI = TierProgressionUI(
            size: size,
            currentWave: gameState.currentWave,
            onClose: { [weak self] in
                self?.closeTierProgressionMenu()
            }
        )
        gameCamera.addChild(tierProgressionUI!)
    }

    private func closeTierProgressionMenu() {
        tierProgressionUI?.removeFromParent()
        tierProgressionUI = nil
    }

    private func showTierCompletionPopup() {
        guard let nextTier = TierProgressionManager.shared.getNextTier(after: gameState.currentWave) else {
            // Reached the end, no more tiers
            return
        }

        // Create celebration popup for tier completion
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.8)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.name = "tierCompletionOverlay"

        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "🏆 TIER COMPLETED! 🏆"
        title.fontSize = 40
        title.fontColor = .yellow
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 80)
        title.name = "tierCompletionOverlay"

        let currentTier = TierProgressionManager.shared.getCurrentTier(for: gameState.currentWave)
        let subtitle = SKLabelNode(fontNamed: "Helvetica")
        subtitle.text = "You completed: \(currentTier.icon) \(currentTier.name)"
        subtitle.fontSize = 20
        subtitle.fontColor = .white
        subtitle.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        subtitle.name = "tierCompletionOverlay"

        let nextInfo = SKLabelNode(fontNamed: "Helvetica-Bold")
        nextInfo.text = "Next: \(nextTier.icon) \(nextTier.name)"
        nextInfo.fontSize = 24
        nextInfo.fontColor = .green
        nextInfo.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        nextInfo.name = "tierCompletionOverlay"

        let continueButton = Button(
            text: "Continue",
            size: CGSize(width: 150, height: 50),
            color: .green
        )
        continueButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 80)
        continueButton.name = "tierCompletionOverlay"
        continueButton.onTap = { [weak self] in
            self?.dismissTierCompletionPopup()
        }

        addChild(overlay)
        addChild(title)
        addChild(subtitle)
        addChild(nextInfo)
        addChild(continueButton)
    }

    private func dismissTierCompletionPopup() {
        enumerateChildNodes(withName: "tierCompletionOverlay") { node, _ in
            node.removeFromParent()
        }
    }

    // MARK: - Module Drops

    private func showModuleDropNotification(_ module: Module, at position: CGPoint) {
        // Create floating text notification
        let notification = SKLabelNode(fontNamed: "Helvetica-Bold")
        notification.text = "\(module.type.emoji) Lv.\(module.level)"
        notification.fontSize = 14
        notification.fontColor = .white
        notification.position = position

        // Add glow effect based on tier
        let color = module.tier.color
        let glowColor = SKColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
        notification.fontColor = glowColor

        addChild(notification)

        // Animate floating upward and fading out
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.5)
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([SKAction.group([moveUp, fadeOut]), remove])

        notification.run(sequence)
    }

    // MARK: - Game Over

    private func handleStateChange(_ state: GameState) {
        switch state {
        case .gameOver:
            handleGameOver()
        case .victory:
            handleVictory()
        default:
            break
        }
    }

    private func handleGameOver() {
        // Only show the screen once - don't create it on every frame
        // Also don't show if we're in the middle of restarting
        if !isRestarting && childNode(withName: "gameOverOverlay") == nil {
            showGameOverScreen()
        }
    }

    private func handleVictory() {
        // Only show the screen once - don't create it on every frame
        // Also don't show if we're in the middle of restarting
        if !isRestarting && childNode(withName: "victoryOverlay") == nil {
            showVictoryScreen()
        }
    }

    private func showGameOverScreen() {
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.7)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.name = "gameOverOverlay"

        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "GAME OVER"
        label.fontSize = 48
        label.fontColor = .red
        label.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        label.name = "gameOverLabel"

        let waveLabel = SKLabelNode(fontNamed: "Helvetica")
        waveLabel.text = "You survived \(gameState.currentWave) waves"
        waveLabel.fontSize = 24
        waveLabel.fontColor = .white
        waveLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        waveLabel.name = "gameOverWaveLabel"

        let restartButton = Button(
            text: "Restart Game",
            size: CGSize(width: 200, height: 50),
            color: .green
        )
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        restartButton.name = "gameOverRestartButton"
        restartButton.onTap = { [weak self] in
            self?.restartGame()
        }

        addChild(overlay)
        addChild(label)
        addChild(waveLabel)
        addChild(restartButton)
    }

    private func showVictoryScreen() {
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.7)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.name = "victoryOverlay"

        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "VICTORY!"
        label.fontSize = 48
        label.fontColor = .green
        label.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        label.name = "victoryLabel"

        let waveLabel = SKLabelNode(fontNamed: "Helvetica")
        waveLabel.text = "You defended your house for all \(gameState.currentWave) waves!"
        waveLabel.fontSize = 24
        waveLabel.fontColor = .white
        waveLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        waveLabel.name = "victoryWaveLabel"

        let restartButton = Button(
            text: "Play Again",
            size: CGSize(width: 200, height: 50),
            color: .green
        )
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        restartButton.name = "victoryRestartButton"
        restartButton.onTap = { [weak self] in
            self?.restartGame()
        }

        addChild(overlay)
        addChild(label)
        addChild(waveLabel)
        addChild(restartButton)
    }

    private func showPauseOverlay() {
        // Only create overlay if it doesn't exist
        if childNode(withName: "pauseOverlay") == nil {
            let overlay = SKShapeNode(rectOf: size)
            overlay.fillColor = SKColor.black.withAlphaComponent(0.5)
            overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
            overlay.name = "pauseOverlay"
            overlay.zPosition = 999

            let label = SKLabelNode(fontNamed: "Helvetica-Bold")
            label.text = "PAUSED"
            label.fontSize = 48
            label.fontColor = .white
            label.position = CGPoint(x: size.width / 2, y: size.height / 2)
            label.name = "pauseLabel"
            label.zPosition = 999

            addChild(overlay)
            addChild(label)
        }
    }

    private func hidePauseOverlay() {
        childNode(withName: "pauseOverlay")?.removeFromParent()
        childNode(withName: "pauseLabel")?.removeFromParent()
    }

    public func restartGame() {
        print("🔄 Restarting game...")

        // Set flag to prevent overlays from being recreated during restart
        isRestarting = true

        // Remove ALL game over/victory overlays (use enumerateChildNodes to catch all)
        enumerateChildNodes(withName: "gameOverOverlay") { node, _ in
            node.removeFromParent()
        }
        enumerateChildNodes(withName: "gameOverLabel") { node, _ in
            node.removeFromParent()
        }
        enumerateChildNodes(withName: "gameOverWaveLabel") { node, _ in
            node.removeFromParent()
        }
        enumerateChildNodes(withName: "gameOverRestartButton") { node, _ in
            node.removeFromParent()
        }
        enumerateChildNodes(withName: "victoryOverlay") { node, _ in
            node.removeFromParent()
        }
        enumerateChildNodes(withName: "victoryLabel") { node, _ in
            node.removeFromParent()
        }
        enumerateChildNodes(withName: "victoryWaveLabel") { node, _ in
            node.removeFromParent()
        }
        enumerateChildNodes(withName: "victoryRestartButton") { node, _ in
            node.removeFromParent()
        }
        hidePauseOverlay()

        // Unpause the game
        hud.isGamePaused = false

        // Clear all bugs
        for bug in bugs {
            bug.removeFromParent()
        }
        bugs.removeAll()

        // Clear all structures
        for structure in structures {
            structure.removeFromParent()
        }
        structures.removeAll()

        // Reset pathfinding grid (clear all blocked tiles from removed structures)
        pathfindingGrid.reset()
        // Re-block the house position
        pathfindingGrid.setBlocked(at: MapManager.shared.getCurrentHousePosition(), blocked: true)
        print("🔄 Pathfinding grid reset")

        // Reset game state
        gameState.reset()
        print("🔄 Game state reset to: \(gameState.currentState)")

        // Reset house health
        house.heal(GameConfiguration.houseMaxHealth)
        print("🔄 House health reset to: \(gameState.houseHealth)")

        // Reset research lab
        researchLab.reset()

        // Reset card manager
        cardManager.reset()

        // Reset module manager
        moduleManager.reset()

        // Reset wave manager
        waveManager = WaveManager(gameState: gameState)

        // Reconnect wave manager callbacks
        waveManager.onBugSpawned = { [weak self] bug in
            self?.spawnBug(bug)
        }
        waveManager.onWaveComplete = { [weak self] in
            self?.handleWaveComplete()
        }

        // Reset timers
        buildPhaseTimer = 0
        lastUpdateTime = 0

        // Clear placement mode
        placementMode = nil

        // Update HUD
        hud.updateCurrency(gameState.currency)
        hud.updateHealth(gameState.houseHealth)
        hud.updateWave(gameState.currentWave)
        hud.updateBuildTimer(0)
        hud.updateCoins(researchLab.totalCoins)
        hud.updateGems(moduleManager.gems)

        // Clear restart flag
        isRestarting = false

        print("✅ Game restarted successfully")
    }

    // MARK: - Save/Load

    private func saveGame() {
        SaveManager.shared.saveGame(
            wave: gameState.currentWave,
            currency: gameState.currency,
            houseHealth: gameState.houseHealth,
            difficulty: gameState.difficulty,
            totalCoins: researchLab.totalCoins,
            gems: moduleManager.gems,
            unlockedCardSlots: cardManager.unlockedSlots,
            equippedCardIDs: [], // TODO: Get from cardManager if available
            purchasedUpgradeIDs: [] // TODO: Get from upgradeManager if available
        )
    }

    private func loadGame() -> Bool {
        guard let saveData = SaveManager.shared.loadGame() else {
            return false
        }

        // Restore game state
        gameState.difficulty = saveData.difficulty

        // Note: We need to reset and then apply saved values
        // This is a simplified load - in a full implementation,
        // we'd need to restore structures, upgrades, cards, etc.

        print("📂 Loaded game - Wave: \(saveData.wave), Currency: \(saveData.currency)")
        return true
    }

    // MARK: - Active Abilities

    private func useAbility(_ ability: ActiveAbilityType, at location: CGPoint? = nil) {
        guard abilityManager.canUseAbility(ability, currency: gameState.currency) else {
            print("⚠️ Cannot use ability: not ready or insufficient currency")
            return
        }

        // Spend currency
        guard gameState.spendCurrency(ability.cost) else { return }

        // Use the ability
        abilityManager.useAbility(ability)

        // Execute ability effect
        switch ability {
        case .airstrike:
            if let location = location {
                executeAirstrike(at: location)
            }
        case .timeSlow:
            executeTimeSlow()
        case .instantKill:
            if let location = location {
                executeInstantKill(at: location)
            }
        case .goldRush:
            print("💰 Gold Rush activated! Double currency for 10 seconds")
        }

        print("✨ Used ability: \(ability.name) (Cost: \(ability.cost))")
    }

    private func executeAirstrike(at location: CGPoint) {
        let damage = 100
        let radius: CGFloat = 80.0

        print("💣 Airstrike at \(location)!")

        // Visual effect - explosion circle
        let explosion = SKShapeNode(circleOfRadius: radius)
        explosion.fillColor = SKColor.orange.withAlphaComponent(0.7)
        explosion.strokeColor = .red
        explosion.lineWidth = 3
        explosion.position = location
        addChild(explosion)

        // Animate explosion
        explosion.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))

        // Damage all bugs in radius
        for bug in bugs {
            let distance = hypot(bug.position.x - location.x, bug.position.y - location.y)
            if distance <= radius {
                let _ = bug.takeDamage(damage)
            }
        }
    }

    private func executeTimeSlow() {
        print("⏱️ Time Slow activated! All bugs slowed for 5 seconds")

        // Slow all bugs
        for bug in bugs {
            bug.applySlow(factor: 0.5, duration: 5.0)
        }
    }

    private func executeInstantKill(at location: CGPoint) {
        // Find closest bug to location
        var closestBug: Bug?
        var closestDistance: CGFloat = .infinity

        for bug in bugs {
            let distance = hypot(bug.position.x - location.x, bug.position.y - location.y)
            if distance < closestDistance {
                closestBug = bug
                closestDistance = distance
            }
        }

        if let bug = closestBug {
            print("☠️ Instant Kill on \(bug.bugType)!")

            // Kill the bug instantly
            let _ = bug.takeDamage(bug.currentHealth)

            // Visual effect
            let skull = SKLabelNode(text: "☠️")
            skull.fontSize = 40
            skull.position = bug.position
            addChild(skull)
            skull.run(SKAction.sequence([
                SKAction.moveBy(x: 0, y: 50, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }
    }
}
