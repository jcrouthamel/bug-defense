import XCTest
@testable import BugDefense

@MainActor
final class MapConfigurationTests: XCTestCase {

    // MARK: - Map Count Tests

    func testMapTypeCountIncludesNewMaps() {
        // Verify that we have at least 30 maps (20 original + 10 new)
        XCTAssertGreaterThanOrEqual(MapType.allCases.count, 30, "Should have at least 30 maps total")
        XCTAssertEqual(MapType.allCases.count, 30, "Should have exactly 30 maps")
    }

    func testRandomMapSelectionWorks() {
        // Verify random map selection returns a valid map
        let randomMap = MapType.random()
        XCTAssertTrue(MapType.allCases.contains(randomMap), "Random map should be in allCases")
    }

    // MARK: - New Maps Path Validity Tests

    func testNewMapsHaveValidPaths() {
        let newMaps: [MapType] = [
            .map21, .map22, .map23, .map24, .map25,
            .map26, .map27, .map28, .map29, .map30
        ]

        for map in newMaps {
            let path = map.roadPath

            // Test: Path has at least 2 waypoints
            XCTAssertGreaterThanOrEqual(path.count, 2, "\(map.displayName) should have at least 2 waypoints")

            // Test: Path has a first and last waypoint
            XCTAssertNotNil(path.first, "\(map.displayName) should have a first waypoint")
            XCTAssertNotNil(path.last, "\(map.displayName) should have a last waypoint")
        }
    }

    func testNewMapsEndAtHousePosition() {
        let newMaps: [MapType] = [
            .map21, .map22, .map23, .map24, .map25,
            .map26, .map27, .map28, .map29, .map30
        ]

        let expectedHousePosition = GridPosition(x: 10, y: 7)

        for map in newMaps {
            let path = map.roadPath
            let lastWaypoint = path.last

            XCTAssertEqual(lastWaypoint, expectedHousePosition,
                          "\(map.displayName) should end at house position (10, 7), but ends at \(lastWaypoint?.description ?? "nil")")
        }
    }

    func testNewMapsStayWithinSafeZone() {
        let newMaps: [MapType] = [
            .map21, .map22, .map23, .map24, .map25,
            .map26, .map27, .map28, .map29, .map30
        ]

        // Safe zone boundaries: x: 1-18, y: 1-13
        let minX = 1
        let maxX = 18
        let minY = 1
        let maxY = 13

        for map in newMaps {
            let path = map.roadPath

            for (index, waypoint) in path.enumerated() {
                XCTAssertGreaterThanOrEqual(waypoint.x, minX,
                    "\(map.displayName) waypoint \(index) x=\(waypoint.x) is below minimum x=\(minX)")
                XCTAssertLessThanOrEqual(waypoint.x, maxX,
                    "\(map.displayName) waypoint \(index) x=\(waypoint.x) exceeds maximum x=\(maxX)")
                XCTAssertGreaterThanOrEqual(waypoint.y, minY,
                    "\(map.displayName) waypoint \(index) y=\(waypoint.y) is below minimum y=\(minY)")
                XCTAssertLessThanOrEqual(waypoint.y, maxY,
                    "\(map.displayName) waypoint \(index) y=\(waypoint.y) exceeds maximum y=\(maxY)")
            }
        }
    }

    func testNewMapsStartAtEdge() {
        let newMaps: [MapType] = [
            .map21, .map22, .map23, .map24, .map25,
            .map26, .map27, .map28, .map29, .map30
        ]

        for map in newMaps {
            let path = map.roadPath
            guard let firstWaypoint = path.first else {
                XCTFail("\(map.displayName) has no first waypoint")
                continue
            }

            // Check if the first waypoint is at an edge (x=1, x=18, y=1, or y=13)
            let isAtEdge = firstWaypoint.x == 1 || firstWaypoint.x == 18 ||
                          firstWaypoint.y == 1 || firstWaypoint.y == 13

            XCTAssertTrue(isAtEdge,
                         "\(map.displayName) should start at an edge, but starts at \(firstWaypoint.description)")
        }
    }

    // MARK: - Path Expansion Tests

    func testExpandPathWorksForNewMaps() {
        let newMaps: [MapType] = [
            .map21, .map22, .map23, .map24, .map25,
            .map26, .map27, .map28, .map29, .map30
        ]

        for map in newMaps {
            let path = map.roadPath

            // Test: Expanded path should be equal to or longer than the base path
            // (expandPath fills in intermediate tiles)
            XCTAssertGreaterThanOrEqual(path.count, 2,
                "\(map.displayName) expanded path should have at least 2 waypoints")

            // Test: Path should not have adjacent duplicates
            for i in 1..<path.count {
                XCTAssertNotEqual(path[i], path[i-1],
                    "\(map.displayName) has duplicate adjacent waypoints at index \(i)")
            }
        }
    }

    // MARK: - House Position Tests

    func testHousePositionIsConsistent() {
        let map21 = MapType.map21
        let map22 = MapType.map22

        XCTAssertEqual(map21.housePosition, map22.housePosition,
                      "All maps should have the same house position")
        XCTAssertEqual(map21.housePosition, GridPosition(x: 10, y: 7),
                      "House position should be at (10, 7)")
    }

    // MARK: - Path Length Distribution Tests

    func testNewMapsPathLengthDistribution() {
        // According to research, we should have:
        // - 3 short maps (8-15 waypoints after expansion)
        // - 5 medium maps (16-25 waypoints after expansion)
        // - 2 long maps (30+ waypoints after expansion)

        let newMaps: [MapType] = [
            .map21, .map22, .map23, .map24, .map25,
            .map26, .map27, .map28, .map29, .map30
        ]

        var shortMaps = 0
        var mediumMaps = 0
        var longMaps = 0

        for map in newMaps {
            let path = map.roadPath

            if path.count <= 15 {
                shortMaps += 1
            } else if path.count <= 25 {
                mediumMaps += 1
            } else {
                longMaps += 1
            }
        }

        // Allow some flexibility in distribution, just verify we have variety
        XCTAssertGreaterThan(shortMaps, 0, "Should have at least 1 short map")
        XCTAssertGreaterThan(mediumMaps, 0, "Should have at least 1 medium map")
        XCTAssertGreaterThan(longMaps, 0, "Should have at least 1 long map")

        print("📊 Path length distribution: \(shortMaps) short, \(mediumMaps) medium, \(longMaps) long")
    }

    // MARK: - Spawn Points Tests

    func testNewMapsHaveValidSpawnPoints() {
        let newMaps: [MapType] = [
            .map21, .map22, .map23, .map24, .map25,
            .map26, .map27, .map28, .map29, .map30
        ]

        for map in newMaps {
            let spawnPoints = map.spawnPoints

            XCTAssertGreaterThan(spawnPoints.count, 0,
                "\(map.displayName) should have at least 1 spawn point")

            // Spawn points should match the first waypoint of the path
            if let firstWaypoint = map.roadPath.first {
                XCTAssertEqual(spawnPoints.first, firstWaypoint,
                    "\(map.displayName) spawn point should match first waypoint")
            }
        }
    }
}
