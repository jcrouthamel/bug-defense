import Foundation
import CoreGraphics

/// Represents different map layouts
enum MapType: String, CaseIterable {
    case classic = "Classic"
    case winding = "Winding Path"
    case spiral = "Spiral"

    var displayName: String {
        return rawValue
    }

    var description: String {
        switch self {
        case .classic:
            return "The original winding road"
        case .winding:
            return "Extra twists and turns"
        case .spiral:
            return "A spiral path to the center"
        }
    }

    /// Get the road path for this map
    var roadPath: [GridPosition] {
        switch self {
        case .classic:
            return classicPath
        case .winding:
            return windingPath
        case .spiral:
            return spiralPath
        }
    }

    /// Get the house position for this map
    var housePosition: GridPosition {
        switch self {
        case .classic, .winding:
            return GridPosition(x: 10, y: 7)  // Center
        case .spiral:
            return GridPosition(x: 10, y: 7)  // Center for spiral
        }
    }

    /// Get spawn points for this map
    var spawnPoints: [GridPosition] {
        switch self {
        case .classic, .winding:
            return [GridPosition(x: 0, y: 3)]  // Left edge
        case .spiral:
            return [GridPosition(x: 0, y: 7)]  // Left edge, middle
        }
    }

    // MARK: - Path Definitions

    private var classicPath: [GridPosition] {
        // The original path from GameConfiguration
        return [
            GridPosition(x: 0, y: 3),
            GridPosition(x: 1, y: 3),
            GridPosition(x: 2, y: 3),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 4, y: 3),
            GridPosition(x: 4, y: 4),
            GridPosition(x: 4, y: 5),
            GridPosition(x: 4, y: 6),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 4, y: 8),
            GridPosition(x: 4, y: 9),
            GridPosition(x: 4, y: 10),
            GridPosition(x: 4, y: 11),
            GridPosition(x: 5, y: 11),
            GridPosition(x: 6, y: 11),
            GridPosition(x: 7, y: 11),
            GridPosition(x: 8, y: 11),
            GridPosition(x: 9, y: 11),
            GridPosition(x: 10, y: 11),
            GridPosition(x: 11, y: 11),
            GridPosition(x: 12, y: 11),
            GridPosition(x: 12, y: 10),
            GridPosition(x: 12, y: 9),
            GridPosition(x: 12, y: 8),
            GridPosition(x: 12, y: 7),
            GridPosition(x: 12, y: 6),
            GridPosition(x: 12, y: 5),
            GridPosition(x: 12, y: 4),
            GridPosition(x: 12, y: 3),
            GridPosition(x: 13, y: 3),
            GridPosition(x: 14, y: 3),
            GridPosition(x: 15, y: 3),
            GridPosition(x: 15, y: 4),
            GridPosition(x: 15, y: 5),
            GridPosition(x: 15, y: 6),
            GridPosition(x: 15, y: 7),
            GridPosition(x: 15, y: 8),
            GridPosition(x: 15, y: 9),
            GridPosition(x: 14, y: 9),
            GridPosition(x: 13, y: 9),
            GridPosition(x: 12, y: 9),
            GridPosition(x: 11, y: 9),
            GridPosition(x: 10, y: 9),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    private var windingPath: [GridPosition] {
        // A more complex winding path
        return [
            GridPosition(x: 0, y: 3),
            GridPosition(x: 1, y: 3),
            GridPosition(x: 2, y: 3),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 3, y: 4),
            GridPosition(x: 3, y: 5),
            GridPosition(x: 4, y: 5),
            GridPosition(x: 5, y: 5),
            GridPosition(x: 6, y: 5),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 7, y: 8),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 8, y: 9),
            GridPosition(x: 8, y: 10),
            GridPosition(x: 9, y: 10),
            GridPosition(x: 10, y: 10),
            GridPosition(x: 11, y: 10),
            GridPosition(x: 12, y: 10),
            GridPosition(x: 13, y: 10),
            GridPosition(x: 14, y: 10),
            GridPosition(x: 14, y: 9),
            GridPosition(x: 14, y: 8),
            GridPosition(x: 14, y: 7),
            GridPosition(x: 13, y: 7),
            GridPosition(x: 12, y: 7),
            GridPosition(x: 11, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    private var spiralPath: [GridPosition] {
        // A spiral path going inward
        var path: [GridPosition] = []

        // Outer ring - bottom
        for x in 0...16 {
            path.append(GridPosition(x: x, y: 12))
        }
        // Right side
        for y in (2...11).reversed() {
            path.append(GridPosition(x: 16, y: y))
        }
        // Top
        for x in (3...15).reversed() {
            path.append(GridPosition(x: x, y: 2))
        }
        // Left partial
        for y in 3...10 {
            path.append(GridPosition(x: 3, y: y))
        }

        // Inner ring - bottom
        for x in 4...13 {
            path.append(GridPosition(x: x, y: 10))
        }
        // Right
        for y in (4...9).reversed() {
            path.append(GridPosition(x: 13, y: y))
        }
        // Top
        for x in (6...12).reversed() {
            path.append(GridPosition(x: x, y: 4))
        }
        // Left partial
        for y in 5...8 {
            path.append(GridPosition(x: 6, y: y))
        }

        // Final approach to center
        path.append(GridPosition(x: 7, y: 8))
        path.append(GridPosition(x: 8, y: 8))
        path.append(GridPosition(x: 9, y: 8))
        path.append(GridPosition(x: 10, y: 8))
        path.append(GridPosition(x: 10, y: 7))

        return path
    }
}

/// Manages the current map selection
@MainActor
class MapManager {
    static let shared = MapManager()

    private(set) var currentMap: MapType = .classic

    private init() {}

    func selectMap(_ map: MapType) {
        currentMap = map
        print("🗺️ Selected map: \(map.displayName)")
    }

    func getCurrentRoadPath() -> [GridPosition] {
        return currentMap.roadPath
    }

    func getCurrentHousePosition() -> GridPosition {
        return currentMap.housePosition
    }

    func getCurrentSpawnPoints() -> [GridPosition] {
        return currentMap.spawnPoints
    }
}
