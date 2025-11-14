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
        XCTAssertEqual(manager.currency, 100)
        XCTAssertEqual(manager.houseHealth, 100)

        // Test currency operations
        manager.addCurrency(50)
        XCTAssertEqual(manager.currency, 150)

        XCTAssertTrue(manager.spendCurrency(50))
        XCTAssertEqual(manager.currency, 100)

        XCTAssertFalse(manager.spendCurrency(200))
        XCTAssertEqual(manager.currency, 100)
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

        // Test wall
        XCTAssertEqual(StructureType.wall.cost, 20)
        XCTAssertEqual(StructureType.wall.health, 200)
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
}
