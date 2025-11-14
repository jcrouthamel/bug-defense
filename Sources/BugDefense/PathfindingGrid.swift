import Foundation

/// A* pathfinding implementation for bug navigation
class PathfindingGrid {
    private var grid: [[Bool]] // true = blocked, false = passable
    private let width: Int
    private let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.grid = Array(repeating: Array(repeating: false, count: width), count: height)
    }

    func setBlocked(at position: GridPosition, blocked: Bool) {
        guard isValid(position: position) else { return }
        grid[position.y][position.x] = blocked
    }

    func isBlocked(at position: GridPosition) -> Bool {
        guard isValid(position: position) else { return true }
        return grid[position.y][position.x]
    }

    func reset() {
        // Clear all blocked tiles
        grid = Array(repeating: Array(repeating: false, count: width), count: height)
    }

    private func isValid(position: GridPosition) -> Bool {
        return position.x >= 0 && position.x < width &&
               position.y >= 0 && position.y < height
    }

    /// Find path from start to goal using A* algorithm
    func findPath(from start: GridPosition, to goal: GridPosition) -> [GridPosition]? {
        guard isValid(position: start) && isValid(position: goal) else { return nil }

        var openSet: [Node] = [Node(position: start, g: 0, h: heuristic(start, goal))]
        var closedSet: Set<GridPosition> = []
        var gScores: [GridPosition: Int] = [start: 0]
        var cameFrom: [GridPosition: GridPosition] = [:]

        while !openSet.isEmpty {
            // Get node with lowest f score
            let currentIndex = openSet.indices.min(by: { openSet[$0].f < openSet[$1].f })!
            let current = openSet.remove(at: currentIndex)

            // Check if we reached the goal
            if current.position == goal {
                return reconstructPath(from: start, to: goal, cameFrom: cameFrom)
            }

            closedSet.insert(current.position)

            // Check all neighbors
            for neighbor in getNeighbors(of: current.position) {
                // Allow pathfinding to the goal even if it's blocked
                if closedSet.contains(neighbor) || (isBlocked(at: neighbor) && neighbor != goal) {
                    continue
                }

                let tentativeG = (gScores[current.position] ?? Int.max) + 1

                if tentativeG < (gScores[neighbor] ?? Int.max) {
                    cameFrom[neighbor] = current.position
                    gScores[neighbor] = tentativeG
                    let h = heuristic(neighbor, goal)
                    let neighborNode = Node(position: neighbor, g: tentativeG, h: h)

                    // Remove old version if exists
                    if let existingIndex = openSet.firstIndex(where: { $0.position == neighbor }) {
                        openSet.remove(at: existingIndex)
                    }

                    openSet.append(neighborNode)
                }
            }
        }

        return nil // No path found
    }

    /// Find direct path for flying units that ignore obstacles
    func findFlyingPath(from start: GridPosition, to goal: GridPosition) -> [GridPosition]? {
        guard isValid(position: start) && isValid(position: goal) else { return nil }

        // Create a direct path using Bresenham's line algorithm
        var path: [GridPosition] = []
        var x0 = start.x
        var y0 = start.y
        let x1 = goal.x
        let y1 = goal.y

        let dx = abs(x1 - x0)
        let dy = abs(y1 - y0)
        let sx = x0 < x1 ? 1 : -1
        let sy = y0 < y1 ? 1 : -1
        var err = dx - dy

        while true {
            path.append(GridPosition(x: x0, y: y0))

            if x0 == x1 && y0 == y1 {
                break
            }

            let e2 = 2 * err

            if e2 > -dy {
                err -= dy
                x0 += sx
            }

            if e2 < dx {
                err += dx
                y0 += sy
            }
        }

        return path
    }

    private func getNeighbors(of position: GridPosition) -> [GridPosition] {
        let directions = [
            GridPosition(x: 0, y: 1),   // Up
            GridPosition(x: 0, y: -1),  // Down
            GridPosition(x: 1, y: 0),   // Right
            GridPosition(x: -1, y: 0)   // Left
        ]

        return directions.compactMap { dir in
            let neighbor = GridPosition(x: position.x + dir.x, y: position.y + dir.y)
            return isValid(position: neighbor) ? neighbor : nil
        }
    }

    private func heuristic(_ a: GridPosition, _ b: GridPosition) -> Int {
        return abs(a.x - b.x) + abs(a.y - b.y) // Manhattan distance
    }

    private func reconstructPath(from start: GridPosition, to goal: GridPosition, cameFrom: [GridPosition: GridPosition]) -> [GridPosition] {
        var path: [GridPosition] = []
        var current = goal

        // Build path backwards from goal to start
        while true {
            path.insert(current, at: 0)
            if current == start {
                break
            }
            guard let previous = cameFrom[current] else {
                // This shouldn't happen if the algorithm is correct
                return [start, goal]
            }
            current = previous
        }

        return path
    }

    private class Node {
        let position: GridPosition
        let g: Int // Cost from start
        let h: Int // Heuristic to goal
        var f: Int { g + h }

        init(position: GridPosition, g: Int, h: Int) {
            self.position = position
            self.g = g
            self.h = h
        }
    }
}
