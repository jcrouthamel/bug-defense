import XCTest
@testable import BugDefense

final class BugDefenseTests: XCTestCase {

    func testGridPositionConversion() {
        let gridPos = GridPosition(x: 5, y: 10)
        let worldPos = gridPos.toWorldPosition()

        XCTAssertEqual(worldPos.x, 5 * 40 + 20)
        XCTAssertEqual(worldPos.y, 10 * 40 + 20)

        let convertedBack = GridPosition.fromWorldPosition(worldPos)
        XCTAssertEqual(convertedBack, gridPos)
    }

    func testGridPositionDistance() {
        let pos1 = GridPosition(x: 0, y: 0)
        let pos2 = GridPosition(x: 3, y: 4)

        XCTAssertEqual(pos1.distance(to: pos2), 7) // Manhattan distance
    }

    @MainActor
    func testGameStateManager() {
        let manager = GameStateManager()

        XCTAssertEqual(manager.currentState, .building)
        XCTAssertEqual(manager.currentWave, 0)
        XCTAssertEqual(manager.currency, 500)  // Updated to match GameConfiguration.startingCurrency
        XCTAssertEqual(manager.houseHealth, 100)

        // Test currency operations
        manager.addCurrency(50)
        XCTAssertEqual(manager.currency, 550)  // 500 + 50

        XCTAssertTrue(manager.spendCurrency(50))
        XCTAssertEqual(manager.currency, 500)  // 550 - 50

        XCTAssertFalse(manager.spendCurrency(600))  // Cannot spend more than 500
        XCTAssertEqual(manager.currency, 500)  // Should remain unchanged
    }

    func testPathfinding() {
        let grid = PathfindingGrid(width: 10, height: 10)

        let start = GridPosition(x: 0, y: 0)
        let goal = GridPosition(x: 9, y: 9)

        // Test path finding without obstacles
        let path = grid.findPath(from: start, to: goal)
        XCTAssertNotNil(path)
        XCTAssertEqual(path?.first, start)
        XCTAssertEqual(path?.last, goal)

        // Add obstacle
        grid.setBlocked(at: GridPosition(x: 5, y: 5), blocked: true)
        XCTAssertTrue(grid.isBlocked(at: GridPosition(x: 5, y: 5)))

        // Path should still exist, just avoid the obstacle
        let pathWithObstacle = grid.findPath(from: start, to: goal)
        XCTAssertNotNil(pathWithObstacle)
    }

    @MainActor
    func testBugTypes() {
        // Test ant
        XCTAssertEqual(BugType.ant.health, 20)
        XCTAssertEqual(BugType.ant.damage, 5)
        XCTAssertEqual(BugType.ant.reward, 10)

        // Test boss
        XCTAssertEqual(BugType.boss.health, 200)
        XCTAssertGreaterThan(BugType.boss.damage, BugType.ant.damage)
        XCTAssertGreaterThan(BugType.boss.reward, BugType.ant.reward)
    }

    @MainActor
    func testStructureTypes() {
        // Test basic tower
        XCTAssertEqual(StructureType.basicTower.cost, 50)
        XCTAssertEqual(StructureType.basicTower.health, 100)

        // Test sniper tower
        XCTAssertEqual(StructureType.sniperTower.cost, 100)
        XCTAssertGreaterThan(StructureType.sniperTower.health, 0)
    }

    @MainActor
    func testUpgradeManager() {
        let gameState = GameStateManager()
        let upgradeManager = UpgradeManager(gameState: gameState)

        XCTAssertEqual(upgradeManager.totalDamageMultiplier, 1.0)
        XCTAssertEqual(upgradeManager.totalHealthMultiplier, 1.0)
        XCTAssertEqual(upgradeManager.totalAttackSpeedMultiplier, 1.0)

        // Try to purchase first attack upgrade
        let attackUpgrade = UpgradeManager.allUpgrades.first { $0.tree == .attack && $0.tier == 1 }!

        // Should be able to purchase tier 1 with starting currency
        XCTAssertTrue(upgradeManager.canPurchase(upgrade: attackUpgrade))
        XCTAssertTrue(upgradeManager.purchaseUpgrade(attackUpgrade))

        // Stats should be updated
        XCTAssertGreaterThan(upgradeManager.totalDamageMultiplier, 1.0)

        // Can't purchase same upgrade twice
        XCTAssertFalse(upgradeManager.canPurchase(upgrade: attackUpgrade))
    }

    @MainActor
    func testWaveProgression() {
        let gameState = GameStateManager()
        let waveManager = WaveManager(gameState: gameState)

        gameState.startNextWave()
        waveManager.startWave()

        XCTAssertEqual(gameState.currentWave, 1)
        XCTAssertGreaterThan(waveManager.getBugsRemaining(), 0)
    }

    @MainActor
    func testBugSpawningWithRoadPath() {
        // Test 1: Ground bug receives and follows road path
        let startPos = GridPosition(x: 0, y: 0)
        let antBug = Bug(type: .ant, at: startPos, wave: 1, difficulty: .normal)

        // Create a simple test road path
        let roadPath = [
            GridPosition(x: 0, y: 0),
            GridPosition(x: 1, y: 0),
            GridPosition(x: 2, y: 0),
            GridPosition(x: 3, y: 0),
            GridPosition(x: 4, y: 0)
        ]

        // Bug should accept road path and position at first waypoint
        antBug.setPath(roadPath)
        XCTAssertEqual(antBug.gridPosition, roadPath.first)

        // Test 2: Flying bug uses road path (not special flying behavior)
        let mosquitoBug = Bug(type: .mosquito, at: startPos, wave: 1, difficulty: .normal)
        XCTAssertTrue(mosquitoBug.bugType.canFly, "Mosquito should have canFly = true")

        // Flying bug should receive same road path as ground bugs
        mosquitoBug.setPath(roadPath)
        XCTAssertEqual(mosquitoBug.gridPosition, roadPath.first)

        // Test 3: Another flying bug (wasp) also uses road path
        let waspBug = Bug(type: .wasp, at: startPos, wave: 1, difficulty: .normal)
        XCTAssertTrue(waspBug.bugType.canFly, "Wasp should have canFly = true")

        waspBug.setPath(roadPath)
        XCTAssertEqual(waspBug.gridPosition, roadPath.first)

        // Test 4: Multiple waypoints handled correctly
        let extendedRoadPath = [
            GridPosition(x: 0, y: 0),
            GridPosition(x: 1, y: 0),
            GridPosition(x: 2, y: 0),
            GridPosition(x: 3, y: 0),
            GridPosition(x: 4, y: 0),
            GridPosition(x: 5, y: 0),
            GridPosition(x: 6, y: 0),
            GridPosition(x: 7, y: 0),
            GridPosition(x: 8, y: 0),
            GridPosition(x: 9, y: 0)
        ]

        let beetleBug = Bug(type: .beetle, at: startPos, wave: 1, difficulty: .normal)
        beetleBug.setPath(extendedRoadPath)
        XCTAssertEqual(beetleBug.gridPosition, extendedRoadPath.first)

        // Test 5: Verify MapManager provides valid road path
        let roadPathFromManager = MapManager.shared.getCurrentRoadPath()
        XCTAssertFalse(roadPathFromManager.isEmpty, "Road path from MapManager should not be empty")
        XCTAssertGreaterThan(roadPathFromManager.count, 1, "Road path should have multiple waypoints")

        // Test 6: Bug spawned with MapManager road path
        let spiderBug = Bug(type: .spider, at: startPos, wave: 1, difficulty: .normal)
        spiderBug.setPath(roadPathFromManager)
        XCTAssertEqual(spiderBug.gridPosition, roadPathFromManager.first)
    }
}
