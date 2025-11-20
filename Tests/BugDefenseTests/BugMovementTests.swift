import XCTest
@testable import BugDefense

@MainActor
final class BugMovementTests: XCTestCase {

    // MARK: - Helper Functions

    /// Creates a test bug configured with the specified path and optional speed parameters
    /// - Parameters:
    ///   - path: Array of grid positions defining the bug's movement path
    ///   - bugType: Bug type to use (default .ant)
    ///   - wave: Wave number for speed scaling (default 1)
    ///   - slowFactor: Slow factor to apply (default 1.0 = no slow)
    /// - Returns: Configured Bug instance positioned at first waypoint
    func createTestBug(path: [GridPosition], bugType: BugType = .ant, wave: Int = 1, slowFactor: CGFloat = 1.0) -> Bug {
        let bug = Bug(type: bugType, at: path[0], wave: wave, difficulty: .normal)
        bug.setPath(path)

        // Apply slow effect if slowFactor is not 1.0
        if slowFactor != 1.0 {
            bug.applySlow(factor: slowFactor, duration: 100.0)
        }

        return bug
    }

    /// Runs bug updates until path completion or max iterations reached
    /// - Parameters:
    ///   - bug: The bug to update
    ///   - finalWaypoint: The final grid position to reach
    ///   - maxIterations: Maximum number of update cycles (default 1000)
    func runUpdatesUntilCompletion(bug: Bug, finalWaypoint: GridPosition, maxIterations: Int = 1000) {
        let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
        let fixedDeltaTime: TimeInterval = 0.016  // ~60 FPS

        for _ in 0..<maxIterations {
            bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

            // Check if path is completed (bug reached final waypoint)
            if bug.gridPosition == finalWaypoint {
                break
            }
        }
    }

    /// Asserts that actual position is within tolerance of expected position
    /// - Parameters:
    ///   - actual: The actual CGPoint position
    ///   - expected: The expected CGPoint position
    ///   - tolerance: Maximum allowed distance between positions
    ///   - file: Source file (automatically populated)
    ///   - line: Source line (automatically populated)
    func assertPositionNear(_ actual: CGPoint, _ expected: CGPoint, tolerance: CGFloat, file: StaticString = #file, line: UInt = #line) {
        let dx = actual.x - expected.x
        let dy = actual.y - expected.y
        let distance = sqrt(dx * dx + dy * dy)

        XCTAssertLessThanOrEqual(
            distance,
            tolerance,
            "Position \(actual) not within \(tolerance) of expected \(expected), distance was \(distance)",
            file: file,
            line: line
        )
    }

    // MARK: - Straight Path Tests

    func testBugMovesAlongStraightHorizontalPathWithoutDrift() {
        // Arrange: Create horizontal path (Y constant at 5)
        let path = [
            GridPosition(x: 1, y: 5),
            GridPosition(x: 2, y: 5),
            GridPosition(x: 3, y: 5),
            GridPosition(x: 4, y: 5),
            GridPosition(x: 5, y: 5)
        ]

        let expectedY = path[0].toWorldPosition().y  // Should be 220.0
        let bug = createTestBug(path: path)

        let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
        let fixedDeltaTime: TimeInterval = 0.016

        // Act: Track positions during movement
        var positionsDuringMovement: [CGPoint] = []

        for _ in 0..<200 {
            bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

            // Record position if still moving
            if bug.gridPosition != path.last {
                positionsDuringMovement.append(bug.position)
            }

            // Break if completed
            if bug.gridPosition == path.last {
                break
            }
        }

        // Assert: Check Y coordinate stayed constant (within tolerance)
        for position in positionsDuringMovement {
            XCTAssertEqual(
                position.y,
                expectedY,
                accuracy: 0.5,
                "Bug drifted off horizontal path at position \(position), expected Y=\(expectedY)"
            )
        }

        // Assert: Bug completed the path
        XCTAssertEqual(bug.gridPosition, path.last, "Bug should have completed the entire path")

        // Assert: Final position matches last waypoint
        let expectedFinalPos = path.last!.toWorldPosition()
        assertPositionNear(bug.position, expectedFinalPos, tolerance: 0.1)
    }

    func testBugMovesAlongStraightVerticalPathWithoutDrift() {
        // Arrange: Create vertical path (X constant at 5)
        let path = [
            GridPosition(x: 5, y: 1),
            GridPosition(x: 5, y: 2),
            GridPosition(x: 5, y: 3),
            GridPosition(x: 5, y: 4),
            GridPosition(x: 5, y: 5)
        ]

        let expectedX = path[0].toWorldPosition().x  // Should be 220.0
        let bug = createTestBug(path: path)

        let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
        let fixedDeltaTime: TimeInterval = 0.016

        // Act: Track positions during movement
        var positionsDuringMovement: [CGPoint] = []

        for _ in 0..<200 {
            bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

            // Record position if still moving
            if bug.gridPosition != path.last {
                positionsDuringMovement.append(bug.position)
            }

            // Break if completed
            if bug.gridPosition == path.last {
                break
            }
        }

        // Assert: Check X coordinate stayed constant (within tolerance)
        for position in positionsDuringMovement {
            XCTAssertEqual(
                position.x,
                expectedX,
                accuracy: 0.5,
                "Bug drifted off vertical path at position \(position), expected X=\(expectedX)"
            )
        }

        // Assert: Bug completed the path
        XCTAssertEqual(bug.gridPosition, path.last, "Bug should have completed the entire path")

        // Assert: Final position matches last waypoint
        let expectedFinalPos = path.last!.toWorldPosition()
        assertPositionNear(bug.position, expectedFinalPos, tolerance: 0.1)
    }

    // MARK: - Complex Path Tests

    func testBugMovesAlongDiagonalPath() {
        // Arrange: Create diagonal path
        let path = [
            GridPosition(x: 2, y: 2),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 4, y: 4),
            GridPosition(x: 5, y: 5)
        ]

        let bug = createTestBug(path: path)

        let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
        let fixedDeltaTime: TimeInterval = 0.016

        // Act: Move bug and track waypoint progression
        var waypointsReached: [GridPosition] = [bug.gridPosition]

        for _ in 0..<200 {
            let previousGridPos = bug.gridPosition
            bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

            // Track when bug reaches new waypoint
            if bug.gridPosition != previousGridPos {
                waypointsReached.append(bug.gridPosition)
            }

            // Break if completed
            if bug.gridPosition == path.last {
                break
            }
        }

        // Assert: Bug passed through all waypoints in sequence
        for (index, waypoint) in path.enumerated() {
            XCTAssertTrue(
                waypointsReached.contains(waypoint),
                "Bug should have reached waypoint \(index): \(waypoint)"
            )
        }

        // Assert: Bug completed the path
        XCTAssertEqual(bug.gridPosition, path.last, "Bug should have completed the entire path")

        // Assert: Final position matches last waypoint
        let expectedFinalPos = path.last!.toWorldPosition()
        assertPositionNear(bug.position, expectedFinalPos, tolerance: 0.1)
    }

    func testBugMovesAlongLShapedCurvedPath() {
        // Arrange: Create L-shaped path (horizontal then vertical)
        let path = [
            GridPosition(x: 1, y: 1),
            GridPosition(x: 2, y: 1),
            GridPosition(x: 3, y: 1),  // Corner waypoint
            GridPosition(x: 3, y: 2),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 3, y: 4)
        ]

        let bug = createTestBug(path: path)

        let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
        let fixedDeltaTime: TimeInterval = 0.016

        // Expected constants for each segment
        let horizontalY = path[0].toWorldPosition().y  // Y for horizontal segment
        let verticalX = path[3].toWorldPosition().x    // X for vertical segment

        // Act: Track positions and check drift during movement
        var horizontalSegmentPositions: [CGPoint] = []
        var verticalSegmentPositions: [CGPoint] = []
        var reachedCorner = false

        for _ in 0..<300 {
            bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

            // Check if we've reached the corner waypoint
            if bug.gridPosition == GridPosition(x: 3, y: 1) {
                reachedCorner = true
            }

            // Categorize positions based on current segment
            // Only record positions BEFORE reaching the corner for horizontal segment
            if bug.gridPosition.y == 1 && bug.gridPosition.x < 3 {
                // Still on horizontal segment (before corner)
                horizontalSegmentPositions.append(bug.position)
            } else if bug.gridPosition.y > 1 && bug.gridPosition.x == 3 {
                // On vertical segment (after corner)
                verticalSegmentPositions.append(bug.position)
            }

            // Break if completed
            if bug.gridPosition == path.last {
                break
            }
        }

        // Assert: Bug reached the corner before turning
        XCTAssertTrue(reachedCorner, "Bug should have reached corner waypoint (3,1) before turning")

        // Assert: No Y drift during horizontal segment
        for position in horizontalSegmentPositions {
            XCTAssertEqual(
                position.y,
                horizontalY,
                accuracy: 0.5,
                "Bug drifted off horizontal segment at position \(position)"
            )
        }

        // Assert: No X drift during vertical segment
        for position in verticalSegmentPositions {
            XCTAssertEqual(
                position.x,
                verticalX,
                accuracy: 0.5,
                "Bug drifted off vertical segment at position \(position)"
            )
        }

        // Assert: Bug completed the path
        XCTAssertEqual(bug.gridPosition, path.last, "Bug should have completed the entire path")

        // Assert: Final position matches last waypoint
        let expectedFinalPos = path.last!.toWorldPosition()
        assertPositionNear(bug.position, expectedFinalPos, tolerance: 0.1)
    }

    // MARK: - Edge Case Tests

    func testVerySlowBugStillReachesWaypoints() {
        // Arrange: Create simple path for slow bug
        let path = [
            GridPosition(x: 1, y: 1),
            GridPosition(x: 2, y: 1),
            GridPosition(x: 3, y: 1)
        ]

        let bug = createTestBug(path: path, slowFactor: 0.1)  // 10% speed

        let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
        let fixedDeltaTime: TimeInterval = 0.016

        // Act: Run with more iterations to accommodate slow speed
        var iterationCount = 0
        for _ in 0..<5000 {
            bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)
            iterationCount += 1

            // Break if completed
            if bug.gridPosition == path.last {
                break
            }
        }

        // Assert: Bug completed the path despite slow speed
        XCTAssertEqual(bug.gridPosition, path.last, "Slow bug should still complete the path")

        // Assert: Bug arrived exactly at final waypoint
        let expectedFinalPos = path.last!.toWorldPosition()
        assertPositionNear(bug.position, expectedFinalPos, tolerance: 0.1)

        // Assert: Took significantly more iterations than normal (rough check)
        XCTAssertGreaterThan(iterationCount, 200, "Slow bug should take more iterations than normal speed")
    }

    func testVeryFastBugDoesNotSkipWaypoints() {
        // Arrange: Create path with close waypoints for fast bug
        let path = [
            GridPosition(x: 1, y: 1),
            GridPosition(x: 2, y: 1),
            GridPosition(x: 3, y: 1),
            GridPosition(x: 4, y: 1),
            GridPosition(x: 5, y: 1)
        ]

        // Use wasp (fast bug type) with high wave number
        let bug = Bug(type: .wasp, at: path[0], wave: 50, difficulty: .hard)
        bug.setPath(path)

        let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
        let fixedDeltaTime: TimeInterval = 0.016

        // Act: Track visited waypoints
        var visitedWaypoints = Set<GridPosition>()
        visitedWaypoints.insert(bug.gridPosition)

        for _ in 0..<200 {
            let previousGridPos = bug.gridPosition
            bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

            // Track waypoint visits
            if bug.gridPosition != previousGridPos {
                visitedWaypoints.insert(bug.gridPosition)
            }

            // Break if completed
            if bug.gridPosition == path.last {
                break
            }
        }

        // Assert: All waypoints were visited
        for waypoint in path {
            XCTAssertTrue(
                visitedWaypoints.contains(waypoint),
                "Fast bug should visit all waypoints including \(waypoint)"
            )
        }

        // Assert: Bug visited exactly the expected number of waypoints (no skips)
        XCTAssertEqual(visitedWaypoints.count, path.count, "Fast bug should visit all \(path.count) waypoints without skipping")

        // Assert: Final position matches last waypoint
        let expectedFinalPos = path.last!.toWorldPosition()
        assertPositionNear(bug.position, expectedFinalPos, tolerance: 0.1)
    }

    func testBugStartingExactlyAtWaypointAdvancesProperly() {
        // Arrange: Create simple path
        let path = [
            GridPosition(x: 1, y: 1),
            GridPosition(x: 2, y: 1),
            GridPosition(x: 3, y: 1)
        ]

        let bug = createTestBug(path: path)

        // Verify bug starts exactly at first waypoint
        let expectedStartPos = path[0].toWorldPosition()
        XCTAssertEqual(bug.position.x, expectedStartPos.x, accuracy: 0.01, "Bug should start exactly at first waypoint X")
        XCTAssertEqual(bug.position.y, expectedStartPos.y, accuracy: 0.01, "Bug should start exactly at first waypoint Y")

        let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
        let fixedDeltaTime: TimeInterval = 0.016

        // Act: Call update once
        let startPosition = bug.position
        bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

        // Assert: Bug moved toward second waypoint (not stuck)
        let secondWaypointPos = path[1].toWorldPosition()
        let distanceToSecond = sqrt(
            pow(bug.position.x - secondWaypointPos.x, 2) +
            pow(bug.position.y - secondWaypointPos.y, 2)
        )
        let initialDistanceToSecond = sqrt(
            pow(startPosition.x - secondWaypointPos.x, 2) +
            pow(startPosition.y - secondWaypointPos.y, 2)
        )

        XCTAssertLessThan(
            distanceToSecond,
            initialDistanceToSecond,
            "Bug should be moving toward second waypoint, not stuck at start"
        )

        // Act: Complete the path
        for _ in 0..<200 {
            bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)

            if bug.gridPosition == path.last {
                break
            }
        }

        // Assert: Bug completed the full path
        XCTAssertEqual(bug.gridPosition, path.last, "Bug should complete the entire path without getting stuck")

        // Assert: Final position matches last waypoint
        let expectedFinalPos = path.last!.toWorldPosition()
        assertPositionNear(bug.position, expectedFinalPos, tolerance: 0.1)
    }
}
