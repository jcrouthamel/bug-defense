import Foundation
import CoreGraphics

/// Represents different map layouts
enum MapType: String, CaseIterable {
    case map1 = "Winding Road"
    case map2 = "Zigzag"
    case map3 = "S-Curve"
    case map4 = "Double Loop"
    case map5 = "Maze Runner"
    case map6 = "Long Path"
    case map7 = "Figure Eight"
    case map8 = "U-Turns"
    case map9 = "Straight Shot"
    case map10 = "Wave Pattern"
    case map11 = "Box Spiral"
    case map12 = "Switchback"
    case map13 = "Cross Roads"
    case map14 = "Lightning"
    case map15 = "Diagonal"
    case map16 = "Cloverleaf"
    case map17 = "Snake"
    case map18 = "Pyramid"
    case map19 = "Horseshoe"
    case map20 = "Labyrinth"
    case map21 = "Reverse Spiral"
    case map22 = "Diamond Ring"
    case map23 = "Staircase"
    case map24 = "Infinity Loop"
    case map25 = "Dense Zigzag"
    case map26 = "Orbital Path"
    case map27 = "X-Cross"
    case map28 = "Tornado"
    case map29 = "Triple Loop"
    case map30 = "Mountain Peak"

    var displayName: String {
        return rawValue
    }

    var description: String {
        return "Map layout: \(rawValue)"
    }

    /// Get a random map
    static func random() -> MapType {
        return allCases.randomElement() ?? .map1
    }

    /// Get the road path for this map (expanded to include all tiles)
    var roadPath: [GridPosition] {
        let basePath: [GridPosition]
        switch self {
        case .map1: basePath = map1Path
        case .map2: basePath = map2Path
        case .map3: basePath = map3Path
        case .map4: basePath = map4Path
        case .map5: basePath = map5Path
        case .map6: basePath = map6Path
        case .map7: basePath = map7Path
        case .map8: basePath = map8Path
        case .map9: basePath = map9Path
        case .map10: basePath = map10Path
        case .map11: basePath = map11Path
        case .map12: basePath = map12Path
        case .map13: basePath = map13Path
        case .map14: basePath = map14Path
        case .map15: basePath = map15Path
        case .map16: basePath = map16Path
        case .map17: basePath = map17Path
        case .map18: basePath = map18Path
        case .map19: basePath = map19Path
        case .map20: basePath = map20Path
        case .map21: basePath = map21Path
        case .map22: basePath = map22Path
        case .map23: basePath = map23Path
        case .map24: basePath = map24Path
        case .map25: basePath = map25Path
        case .map26: basePath = map26Path
        case .map27: basePath = map27Path
        case .map28: basePath = map28Path
        case .map29: basePath = map29Path
        case .map30: basePath = map30Path
        }

        // Expand path to include all intermediate tiles
        return MapType.expandPath(basePath)
    }

    /// Expand a path to include all intermediate grid positions between waypoints
    private static func expandPath(_ waypoints: [GridPosition]) -> [GridPosition] {
        guard waypoints.count >= 2 else { return waypoints }

        var expandedPath: [GridPosition] = [waypoints[0]]

        for i in 1..<waypoints.count {
            let start = waypoints[i - 1]
            let end = waypoints[i]

            // Calculate deltas
            let dx = end.x - start.x
            let dy = end.y - start.y

            // Calculate number of steps needed (max of abs deltas)
            let steps = max(abs(dx), abs(dy))

            if steps == 0 { continue }

            // Add all intermediate positions
            for step in 1...steps {
                let x = start.x + (dx * step) / steps
                let y = start.y + (dy * step) / steps
                let position = GridPosition(x: x, y: y)

                // Avoid duplicates
                if position != expandedPath.last {
                    expandedPath.append(position)
                }
            }
        }

        return expandedPath
    }

    /// Get the house position for this map (always center, away from edges)
    var housePosition: GridPosition {
        return GridPosition(x: 10, y: 7)  // Center of safe zone
    }

    /// Get spawn points for this map (first point of the path)
    var spawnPoints: [GridPosition] {
        return [roadPath.first ?? GridPosition(x: 2, y: 7)]
    }

    // MARK: - Path Definitions (All paths stay within safe zone x:1-18, y:1-13)

    // Map 1: Winding Road - Classic serpentine
    private var map1Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 3),
            GridPosition(x: 2, y: 3),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 4, y: 3),
            GridPosition(x: 4, y: 4),
            GridPosition(x: 4, y: 5),
            GridPosition(x: 4, y: 6),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 4, y: 8),
            GridPosition(x: 5, y: 8),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 7, y: 8),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 10, y: 8),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 2: Zigzag - Sharp back and forth
    private var map2Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 2),
            GridPosition(x: 2, y: 2),
            GridPosition(x: 3, y: 2),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 3, y: 4),
            GridPosition(x: 4, y: 4),
            GridPosition(x: 5, y: 4),
            GridPosition(x: 5, y: 5),
            GridPosition(x: 5, y: 6),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 7, y: 6),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 7, y: 8),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 9, y: 10),
            GridPosition(x: 10, y: 10),
            GridPosition(x: 11, y: 10),
            GridPosition(x: 11, y: 9),
            GridPosition(x: 11, y: 8),
            GridPosition(x: 10, y: 8),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 3: S-Curve - Smooth S shape
    private var map3Path: [GridPosition] {
        return [
            GridPosition(x: 2, y: 11),
            GridPosition(x: 3, y: 11),
            GridPosition(x: 4, y: 11),
            GridPosition(x: 5, y: 10),
            GridPosition(x: 6, y: 9),
            GridPosition(x: 7, y: 8),
            GridPosition(x: 8, y: 7),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 6),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 4: Double Loop - Two circular paths
    private var map4Path: [GridPosition] {
        return [
            GridPosition(x: 2, y: 7),
            GridPosition(x: 3, y: 7),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 4, y: 9),
            GridPosition(x: 5, y: 10),
            GridPosition(x: 6, y: 10),
            GridPosition(x: 7, y: 9),
            GridPosition(x: 7, y: 8),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 7, y: 6),
            GridPosition(x: 8, y: 5),
            GridPosition(x: 9, y: 5),
            GridPosition(x: 10, y: 6),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 5: Maze Runner - Complex maze-like
    private var map5Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 12),
            GridPosition(x: 2, y: 12),
            GridPosition(x: 3, y: 12),
            GridPosition(x: 3, y: 11),
            GridPosition(x: 3, y: 10),
            GridPosition(x: 4, y: 10),
            GridPosition(x: 5, y: 10),
            GridPosition(x: 5, y: 9),
            GridPosition(x: 5, y: 8),
            GridPosition(x: 4, y: 8),
            GridPosition(x: 3, y: 8),
            GridPosition(x: 3, y: 7),
            GridPosition(x: 3, y: 6),
            GridPosition(x: 4, y: 6),
            GridPosition(x: 5, y: 6),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 6, y: 5),
            GridPosition(x: 6, y: 4),
            GridPosition(x: 7, y: 4),
            GridPosition(x: 8, y: 4),
            GridPosition(x: 9, y: 4),
            GridPosition(x: 9, y: 5),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 6),
            GridPosition(x: 11, y: 6),
            GridPosition(x: 12, y: 6),
            GridPosition(x: 12, y: 7),
            GridPosition(x: 12, y: 8),
            GridPosition(x: 11, y: 8),
            GridPosition(x: 10, y: 8),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 6: Long Path - Extended winding
    private var map6Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 1),
            GridPosition(x: 2, y: 1),
            GridPosition(x: 3, y: 1),
            GridPosition(x: 4, y: 2),
            GridPosition(x: 5, y: 3),
            GridPosition(x: 6, y: 4),
            GridPosition(x: 7, y: 5),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 6),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 7: Figure Eight - Crossing loops
    private var map7Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 9),
            GridPosition(x: 2, y: 9),
            GridPosition(x: 3, y: 9),
            GridPosition(x: 3, y: 10),
            GridPosition(x: 4, y: 10),
            GridPosition(x: 4, y: 11),
            GridPosition(x: 5, y: 11),
            GridPosition(x: 6, y: 11),
            GridPosition(x: 6, y: 10),
            GridPosition(x: 7, y: 10),
            GridPosition(x: 7, y: 9),
            GridPosition(x: 8, y: 9),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 8: U-Turns - Multiple sharp U-turns
    private var map8Path: [GridPosition] {
        return [
            GridPosition(x: 2, y: 2),
            GridPosition(x: 3, y: 2),
            GridPosition(x: 4, y: 2),
            GridPosition(x: 5, y: 2),
            GridPosition(x: 6, y: 2),
            GridPosition(x: 6, y: 3),
            GridPosition(x: 6, y: 4),
            GridPosition(x: 5, y: 4),
            GridPosition(x: 4, y: 4),
            GridPosition(x: 3, y: 4),
            GridPosition(x: 3, y: 5),
            GridPosition(x: 3, y: 6),
            GridPosition(x: 4, y: 6),
            GridPosition(x: 5, y: 6),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 7, y: 6),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 7, y: 8),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 5, y: 8),
            GridPosition(x: 4, y: 8),
            GridPosition(x: 4, y: 9),
            GridPosition(x: 4, y: 10),
            GridPosition(x: 5, y: 10),
            GridPosition(x: 6, y: 10),
            GridPosition(x: 7, y: 10),
            GridPosition(x: 8, y: 10),
            GridPosition(x: 9, y: 10),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 10, y: 9),
            GridPosition(x: 10, y: 8),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 9: Straight Shot - Mostly straight with few turns
    private var map9Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 7),
            GridPosition(x: 2, y: 7),
            GridPosition(x: 3, y: 7),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 5, y: 7),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 8, y: 7),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 10: Wave Pattern - Wavy horizontal path
    private var map10Path: [GridPosition] {
        return [
            GridPosition(x: 2, y: 8),
            GridPosition(x: 3, y: 9),
            GridPosition(x: 4, y: 10),
            GridPosition(x: 5, y: 9),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 11: Box Spiral - Spiral from outside to center
    private var map11Path: [GridPosition] {
        return [
            GridPosition(x: 2, y: 12),
            GridPosition(x: 3, y: 12),
            GridPosition(x: 4, y: 12),
            GridPosition(x: 5, y: 12),
            GridPosition(x: 6, y: 12),
            GridPosition(x: 7, y: 12),
            GridPosition(x: 8, y: 12),
            GridPosition(x: 9, y: 12),
            GridPosition(x: 10, y: 12),
            GridPosition(x: 11, y: 12),
            GridPosition(x: 12, y: 12),
            GridPosition(x: 13, y: 12),
            GridPosition(x: 14, y: 12),
            GridPosition(x: 15, y: 12),
            GridPosition(x: 16, y: 12),
            GridPosition(x: 17, y: 12),
            GridPosition(x: 17, y: 11),
            GridPosition(x: 17, y: 10),
            GridPosition(x: 17, y: 9),
            GridPosition(x: 17, y: 8),
            GridPosition(x: 17, y: 7),
            GridPosition(x: 17, y: 6),
            GridPosition(x: 17, y: 5),
            GridPosition(x: 17, y: 4),
            GridPosition(x: 17, y: 3),
            GridPosition(x: 16, y: 3),
            GridPosition(x: 15, y: 3),
            GridPosition(x: 14, y: 3),
            GridPosition(x: 13, y: 3),
            GridPosition(x: 12, y: 3),
            GridPosition(x: 11, y: 3),
            GridPosition(x: 10, y: 3),
            GridPosition(x: 9, y: 3),
            GridPosition(x: 8, y: 3),
            GridPosition(x: 7, y: 3),
            GridPosition(x: 6, y: 3),
            GridPosition(x: 5, y: 3),
            GridPosition(x: 4, y: 3),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 3, y: 4),
            GridPosition(x: 3, y: 5),
            GridPosition(x: 3, y: 6),
            GridPosition(x: 3, y: 7),
            GridPosition(x: 3, y: 8),
            GridPosition(x: 3, y: 9),
            GridPosition(x: 4, y: 9),
            GridPosition(x: 5, y: 9),
            GridPosition(x: 6, y: 9),
            GridPosition(x: 7, y: 9),
            GridPosition(x: 8, y: 9),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 10, y: 9),
            GridPosition(x: 11, y: 9),
            GridPosition(x: 12, y: 9),
            GridPosition(x: 13, y: 9),
            GridPosition(x: 13, y: 8),
            GridPosition(x: 13, y: 7),
            GridPosition(x: 12, y: 7),
            GridPosition(x: 11, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 12: Switchback - Mountain road style
    private var map12Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 1),
            GridPosition(x: 2, y: 1),
            GridPosition(x: 3, y: 1),
            GridPosition(x: 4, y: 1),
            GridPosition(x: 5, y: 1),
            GridPosition(x: 6, y: 1),
            GridPosition(x: 6, y: 2),
            GridPosition(x: 6, y: 3),
            GridPosition(x: 5, y: 3),
            GridPosition(x: 4, y: 3),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 2, y: 3),
            GridPosition(x: 2, y: 4),
            GridPosition(x: 2, y: 5),
            GridPosition(x: 3, y: 5),
            GridPosition(x: 4, y: 5),
            GridPosition(x: 5, y: 5),
            GridPosition(x: 6, y: 5),
            GridPosition(x: 7, y: 5),
            GridPosition(x: 8, y: 5),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 8, y: 7),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 5, y: 7),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 3, y: 7),
            GridPosition(x: 3, y: 8),
            GridPosition(x: 3, y: 9),
            GridPosition(x: 4, y: 9),
            GridPosition(x: 5, y: 9),
            GridPosition(x: 6, y: 9),
            GridPosition(x: 7, y: 9),
            GridPosition(x: 8, y: 9),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 10, y: 8),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 13: Cross Roads - Intersecting paths
    private var map13Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 3),
            GridPosition(x: 2, y: 3),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 4, y: 3),
            GridPosition(x: 5, y: 3),
            GridPosition(x: 6, y: 3),
            GridPosition(x: 6, y: 4),
            GridPosition(x: 7, y: 4),
            GridPosition(x: 7, y: 5),
            GridPosition(x: 8, y: 5),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 14: Lightning - Jagged lightning bolt
    private var map14Path: [GridPosition] {
        return [
            GridPosition(x: 3, y: 12),
            GridPosition(x: 4, y: 12),
            GridPosition(x: 4, y: 11),
            GridPosition(x: 5, y: 11),
            GridPosition(x: 5, y: 10),
            GridPosition(x: 4, y: 10),
            GridPosition(x: 4, y: 9),
            GridPosition(x: 5, y: 9),
            GridPosition(x: 5, y: 8),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 5, y: 7),
            GridPosition(x: 5, y: 6),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 6, y: 5),
            GridPosition(x: 7, y: 5),
            GridPosition(x: 7, y: 6),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 8, y: 7),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 15: Diagonal - Diagonal emphasis
    private var map15Path: [GridPosition] {
        return [
            GridPosition(x: 2, y: 12),
            GridPosition(x: 3, y: 11),
            GridPosition(x: 4, y: 10),
            GridPosition(x: 5, y: 9),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 16: Cloverleaf - Four-leaf clover pattern
    private var map16Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 7),
            GridPosition(x: 2, y: 7),
            GridPosition(x: 3, y: 7),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 4, y: 8),
            GridPosition(x: 4, y: 9),
            GridPosition(x: 4, y: 10),
            GridPosition(x: 5, y: 10),
            GridPosition(x: 6, y: 10),
            GridPosition(x: 7, y: 10),
            GridPosition(x: 8, y: 10),
            GridPosition(x: 8, y: 9),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 17: Snake - Slithering snake pattern
    private var map17Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 6),
            GridPosition(x: 2, y: 6),
            GridPosition(x: 3, y: 6),
            GridPosition(x: 3, y: 7),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 4, y: 8),
            GridPosition(x: 5, y: 8),
            GridPosition(x: 5, y: 9),
            GridPosition(x: 6, y: 9),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 7, y: 6),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 8, y: 5),
            GridPosition(x: 9, y: 5),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 6),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 18: Pyramid - Building up pattern
    private var map18Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 1),
            GridPosition(x: 2, y: 1),
            GridPosition(x: 2, y: 2),
            GridPosition(x: 3, y: 2),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 4, y: 3),
            GridPosition(x: 4, y: 4),
            GridPosition(x: 5, y: 4),
            GridPosition(x: 5, y: 5),
            GridPosition(x: 6, y: 5),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 7, y: 6),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 19: Horseshoe - U-shaped path
    private var map19Path: [GridPosition] {
        return [
            GridPosition(x: 2, y: 2),
            GridPosition(x: 2, y: 4),
            GridPosition(x: 2, y: 6),
            GridPosition(x: 2, y: 8),
            GridPosition(x: 2, y: 10),
            GridPosition(x: 4, y: 11),
            GridPosition(x: 6, y: 12),
            GridPosition(x: 8, y: 12),
            GridPosition(x: 10, y: 12),
            GridPosition(x: 12, y: 12),
            GridPosition(x: 14, y: 11),
            GridPosition(x: 16, y: 10),
            GridPosition(x: 16, y: 8),
            GridPosition(x: 15, y: 7),
            GridPosition(x: 13, y: 7),
            GridPosition(x: 11, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 20: Labyrinth - Complex maze
    private var map20Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 11),
            GridPosition(x: 2, y: 11),
            GridPosition(x: 2, y: 9),
            GridPosition(x: 4, y: 9),
            GridPosition(x: 4, y: 11),
            GridPosition(x: 6, y: 11),
            GridPosition(x: 6, y: 9),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 4, y: 5),
            GridPosition(x: 6, y: 5),
            GridPosition(x: 8, y: 5),
            GridPosition(x: 8, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 21: Reverse Spiral - Counter-clockwise spiral inward
    private var map21Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 7),
            GridPosition(x: 2, y: 7),
            GridPosition(x: 3, y: 7),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 5, y: 7),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 6, y: 9),
            GridPosition(x: 6, y: 10),
            GridPosition(x: 6, y: 11),
            GridPosition(x: 7, y: 11),
            GridPosition(x: 8, y: 11),
            GridPosition(x: 9, y: 11),
            GridPosition(x: 10, y: 11),
            GridPosition(x: 11, y: 11),
            GridPosition(x: 12, y: 11),
            GridPosition(x: 13, y: 11),
            GridPosition(x: 14, y: 11),
            GridPosition(x: 14, y: 10),
            GridPosition(x: 14, y: 9),
            GridPosition(x: 14, y: 8),
            GridPosition(x: 14, y: 7),
            GridPosition(x: 14, y: 6),
            GridPosition(x: 14, y: 5),
            GridPosition(x: 14, y: 4),
            GridPosition(x: 13, y: 4),
            GridPosition(x: 12, y: 4),
            GridPosition(x: 11, y: 4),
            GridPosition(x: 10, y: 4),
            GridPosition(x: 9, y: 4),
            GridPosition(x: 8, y: 4),
            GridPosition(x: 8, y: 5),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 8, y: 7),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 8, y: 9),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 10, y: 9),
            GridPosition(x: 11, y: 9),
            GridPosition(x: 12, y: 9),
            GridPosition(x: 12, y: 8),
            GridPosition(x: 12, y: 7),
            GridPosition(x: 11, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 22: Diamond Ring - Diamond shape pattern
    private var map22Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 7),
            GridPosition(x: 2, y: 7),
            GridPosition(x: 3, y: 8),
            GridPosition(x: 4, y: 9),
            GridPosition(x: 5, y: 10),
            GridPosition(x: 6, y: 11),
            GridPosition(x: 7, y: 11),
            GridPosition(x: 8, y: 11),
            GridPosition(x: 9, y: 10),
            GridPosition(x: 10, y: 9),
            GridPosition(x: 11, y: 8),
            GridPosition(x: 11, y: 7),
            GridPosition(x: 11, y: 6),
            GridPosition(x: 10, y: 5),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 23: Staircase - Ascending staircase pattern
    private var map23Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 2),
            GridPosition(x: 2, y: 2),
            GridPosition(x: 3, y: 2),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 4, y: 3),
            GridPosition(x: 5, y: 3),
            GridPosition(x: 5, y: 4),
            GridPosition(x: 6, y: 4),
            GridPosition(x: 7, y: 4),
            GridPosition(x: 7, y: 5),
            GridPosition(x: 8, y: 5),
            GridPosition(x: 9, y: 5),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 6),
            GridPosition(x: 11, y: 6),
            GridPosition(x: 11, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 24: Infinity Loop - Figure-8 infinity symbol
    private var map24Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 5),
            GridPosition(x: 2, y: 5),
            GridPosition(x: 3, y: 5),
            GridPosition(x: 4, y: 5),
            GridPosition(x: 4, y: 6),
            GridPosition(x: 5, y: 7),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 7, y: 9),
            GridPosition(x: 8, y: 9),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 8, y: 7),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 5, y: 5),
            GridPosition(x: 6, y: 4),
            GridPosition(x: 7, y: 5),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 25: Dense Zigzag - Compressed zigzag
    private var map25Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 4),
            GridPosition(x: 2, y: 4),
            GridPosition(x: 2, y: 5),
            GridPosition(x: 3, y: 5),
            GridPosition(x: 3, y: 6),
            GridPosition(x: 4, y: 6),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 5, y: 7),
            GridPosition(x: 5, y: 8),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 7, y: 8),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 10, y: 8),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 26: Orbital Path - Circular orbit before entering house
    private var map26Path: [GridPosition] {
        return [
            GridPosition(x: 2, y: 13),
            GridPosition(x: 3, y: 13),
            GridPosition(x: 4, y: 13),
            GridPosition(x: 5, y: 12),
            GridPosition(x: 6, y: 11),
            GridPosition(x: 7, y: 10),
            GridPosition(x: 8, y: 9),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 10, y: 9),
            GridPosition(x: 11, y: 9),
            GridPosition(x: 12, y: 9),
            GridPosition(x: 13, y: 9),
            GridPosition(x: 14, y: 9),
            GridPosition(x: 14, y: 8),
            GridPosition(x: 14, y: 7),
            GridPosition(x: 14, y: 6),
            GridPosition(x: 13, y: 6),
            GridPosition(x: 12, y: 6),
            GridPosition(x: 11, y: 6),
            GridPosition(x: 10, y: 6),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 27: X-Cross - X-shaped diagonal pattern
    private var map27Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 2),
            GridPosition(x: 2, y: 2),
            GridPosition(x: 3, y: 3),
            GridPosition(x: 4, y: 4),
            GridPosition(x: 5, y: 5),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 10, y: 9),
            GridPosition(x: 10, y: 8),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 28: Tornado - Tight spiral expanding outward
    private var map28Path: [GridPosition] {
        return [
            GridPosition(x: 10, y: 1),
            GridPosition(x: 10, y: 2),
            GridPosition(x: 11, y: 2),
            GridPosition(x: 11, y: 3),
            GridPosition(x: 10, y: 3),
            GridPosition(x: 9, y: 3),
            GridPosition(x: 9, y: 2),
            GridPosition(x: 8, y: 2),
            GridPosition(x: 8, y: 3),
            GridPosition(x: 8, y: 4),
            GridPosition(x: 9, y: 4),
            GridPosition(x: 10, y: 4),
            GridPosition(x: 11, y: 4),
            GridPosition(x: 12, y: 4),
            GridPosition(x: 12, y: 5),
            GridPosition(x: 12, y: 6),
            GridPosition(x: 11, y: 6),
            GridPosition(x: 10, y: 6),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 8, y: 6),
            GridPosition(x: 7, y: 6),
            GridPosition(x: 7, y: 5),
            GridPosition(x: 6, y: 5),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 6, y: 8),
            GridPosition(x: 7, y: 8),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 10, y: 8),
            GridPosition(x: 11, y: 8),
            GridPosition(x: 12, y: 8),
            GridPosition(x: 13, y: 8),
            GridPosition(x: 13, y: 9),
            GridPosition(x: 13, y: 10),
            GridPosition(x: 12, y: 10),
            GridPosition(x: 11, y: 10),
            GridPosition(x: 10, y: 10),
            GridPosition(x: 9, y: 10),
            GridPosition(x: 9, y: 9),
            GridPosition(x: 10, y: 9),
            GridPosition(x: 10, y: 8),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 29: Triple Loop - Three small connected loops
    private var map29Path: [GridPosition] {
        return [
            GridPosition(x: 1, y: 7),
            GridPosition(x: 2, y: 7),
            GridPosition(x: 3, y: 7),
            GridPosition(x: 3, y: 8),
            GridPosition(x: 4, y: 8),
            GridPosition(x: 4, y: 7),
            GridPosition(x: 5, y: 7),
            GridPosition(x: 5, y: 6),
            GridPosition(x: 6, y: 6),
            GridPosition(x: 6, y: 7),
            GridPosition(x: 7, y: 7),
            GridPosition(x: 8, y: 7),
            GridPosition(x: 8, y: 8),
            GridPosition(x: 9, y: 8),
            GridPosition(x: 9, y: 7),
            GridPosition(x: 10, y: 7)
        ]
    }

    // Map 30: Mountain Peak - Triangle/peak pattern
    private var map30Path: [GridPosition] {
        return [
            GridPosition(x: 2, y: 13),
            GridPosition(x: 3, y: 12),
            GridPosition(x: 4, y: 11),
            GridPosition(x: 5, y: 10),
            GridPosition(x: 6, y: 9),
            GridPosition(x: 7, y: 8),
            GridPosition(x: 8, y: 7),
            GridPosition(x: 9, y: 6),
            GridPosition(x: 10, y: 6),
            GridPosition(x: 10, y: 7)
        ]
    }
}

/// Manages the current map selection
@MainActor
class MapManager {
    static let shared = MapManager()

    private(set) var currentMap: MapType = .map1

    private init() {}

    func selectMap(_ map: MapType) {
        currentMap = map
        print("🗺️ Selected map: \(map.displayName)")
    }

    func selectRandomMap() {
        currentMap = MapType.random()
        print("🎲 Randomly selected map: \(currentMap.displayName)")
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
