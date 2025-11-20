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

    @MainActor
    func testBugVectorMovementOnPath() {
        let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
        let fixedDeltaTime: TimeInterval = 0.016  // ~60 FPS

        // Test 1: Straight horizontal movement - Y should remain constant
        let horizontalPath = [
            GridPosition(x: 1, y: 5),
            GridPosition(x: 2, y: 5),
            GridPosition(x: 3, y: 5),
            GridPosition(x: 4, y: 5),
            GridPosition(x: 5, y: 5)
        ]
        let horizontalBug = Bug(type: .ant, at: horizontalPath[0], wave: 1, difficulty: .normal)
        horizontalBug.setPath(horizontalPath)

        let expectedY = horizontalPath[0].toWorldPosition().y

        // Update bug multiple times to move it along the path
        for _ in 0..<200 {
            horizontalBug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)
            // Y should remain constant throughout horizontal movement (until reaching final waypoint)
            if horizontalBug.gridPosition != horizontalPath.last {
                XCTAssertEqual(horizontalBug.position.y, expectedY, accuracy: 1.0,
                    "Bug Y position should remain constant on horizontal path")
            }
        }

        // Verify bug reached final waypoint
        XCTAssertEqual(horizontalBug.gridPosition, horizontalPath.last,
            "Bug should end at final waypoint")

        // Test 2: Straight vertical movement - X should remain constant
        let verticalPath = [
            GridPosition(x: 5, y: 1),
            GridPosition(x: 5, y: 2),
            GridPosition(x: 5, y: 3),
            GridPosition(x: 5, y: 4),
            GridPosition(x: 5, y: 5)
        ]
        let verticalBug = Bug(type: .ant, at: verticalPath[0], wave: 1, difficulty: .normal)
        verticalBug.setPath(verticalPath)

        let expectedX = verticalPath[0].toWorldPosition().x

        for _ in 0..<200 {
            verticalBug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)
            if verticalBug.gridPosition != verticalPath.last {
                XCTAssertEqual(verticalBug.position.x, expectedX, accuracy: 1.0,
                    "Bug X position should remain constant on vertical path")
            }
        }

        XCTAssertEqual(verticalBug.gridPosition, verticalPath.last,
            "Bug should end at final waypoint")

        // Test 3: Diagonal movement - bug should reach all waypoints
        let diagonalPath = [
            GridPosition(x: 2, y: 2),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 4, y: 4),
            GridPosition(x: 5, y: 5)
        ]
        let diagonalBug = Bug(type: .ant, at: diagonalPath[0], wave: 1, difficulty: .normal)
        diagonalBug.setPath(diagonalPath)

        for _ in 0..<300 {
            diagonalBug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)
        }

        XCTAssertEqual(diagonalBug.gridPosition, diagonalPath.last,
            "Bug should end at final diagonal waypoint")
        XCTAssertEqual(diagonalBug.position, diagonalPath.last!.toWorldPosition(),
            "Bug position should exactly match final waypoint world position")

        // Test 4: Waypoint snap - bug close to waypoint should snap exactly
        let snapPath = [
            GridPosition(x: 10, y: 10),
            GridPosition(x: 11, y: 10)
        ]
        let snapBug = Bug(type: .ant, at: snapPath[0], wave: 1, difficulty: .normal)
        snapBug.setPath(snapPath)

        // Position bug 1.5 points from target (within snap threshold of 2.0)
        let targetPos = snapPath[1].toWorldPosition()
        snapBug.position = CGPoint(x: targetPos.x - 1.5, y: targetPos.y)

        snapBug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

        XCTAssertEqual(snapBug.position, targetPos,
            "Bug should snap exactly to waypoint when within threshold")
        XCTAssertEqual(snapBug.gridPosition, snapPath[1],
            "gridPosition should sync with waypoint after snap")

        // Test 5: Very slow bug - should still move correctly
        let slowPath = [
            GridPosition(x: 0, y: 0),
            GridPosition(x: 1, y: 0),
            GridPosition(x: 2, y: 0)
        ]
        let slowBug = Bug(type: .beetle, at: slowPath[0], wave: 1, difficulty: .normal)
        slowBug.setPath(slowPath)
        slowBug.applySlow(factor: 0.1, duration: 10.0)  // Very slow

        let initialPos = slowBug.position

        slowBug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

        // Bug should have moved (even if very little)
        let distanceMoved = sqrt(
            pow(slowBug.position.x - initialPos.x, 2) +
            pow(slowBug.position.y - initialPos.y, 2)
        )
        XCTAssertGreaterThan(distanceMoved, 0,
            "Slow bug should still move toward waypoint")
        XCTAssertFalse(slowBug.position.x.isNaN,
            "Bug position should not be NaN")
        XCTAssertFalse(slowBug.position.x.isInfinite,
            "Bug position should not be infinite")

        // Test 6: Very fast bug - should reach all waypoints without skipping
        let fastPath = [
            GridPosition(x: 0, y: 0),
            GridPosition(x: 1, y: 0),
            GridPosition(x: 2, y: 0),
            GridPosition(x: 3, y: 0)
        ]
        let fastBug = Bug(type: .wasp, at: fastPath[0], wave: 50, difficulty: .hard)
        fastBug.setPath(fastPath)

        // Track visited waypoints by monitoring gridPosition changes
        var visitedWaypoints: Set<GridPosition> = [fastPath[0]]

        for _ in 0..<100 {
            let previousGridPos = fastBug.gridPosition
            fastBug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

            // If gridPosition changed, track it
            if fastBug.gridPosition != previousGridPos {
                visitedWaypoints.insert(fastBug.gridPosition)
            }
        }

        // Verify bug visited all waypoints
        for waypoint in fastPath {
            XCTAssertTrue(visitedWaypoints.contains(waypoint),
                "Fast bug should visit waypoint \(waypoint)")
        }

        XCTAssertEqual(fastBug.gridPosition, fastPath.last,
            "Fast bug should reach final waypoint")

        // Test 7: Path completion - bug at last waypoint should stop
        let completePath = [
            GridPosition(x: 15, y: 7),
            GridPosition(x: 16, y: 7)
        ]
        let completeBug = Bug(type: .ant, at: completePath[0], wave: 1, difficulty: .normal)
        completeBug.setPath(completePath)

        // Move bug to complete path
        for _ in 0..<200 {
            completeBug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)
        }

        let finalPos = completeBug.position
        let finalGridPos = completeBug.gridPosition

        // Update again - bug should not move (guard returns early)
        completeBug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

        XCTAssertEqual(completeBug.position, finalPos,
            "Bug should not move after completing path")
        XCTAssertEqual(completeBug.gridPosition, finalGridPos,
            "gridPosition should not change after completing path")
    }
}
