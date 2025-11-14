import Foundation
import SpriteKit

/// Manages wave spawning and progression
@MainActor
class WaveManager {
    private let gameState: GameStateManager
    private var spawnTimer: TimeInterval = 0
    private var bugsSpawnedInWave: Int = 0
    private var bugsToSpawnInWave: Int = 0
    private var timeBetweenSpawns: TimeInterval = 1.0

    var onBugSpawned: ((Bug) -> Void)?
    var onWaveComplete: (() -> Void)?

    init(gameState: GameStateManager) {
        self.gameState = gameState
    }

    func startWave() {
        let waveNumber = gameState.currentWave
        bugsSpawnedInWave = 0
        bugsToSpawnInWave = calculateWaveSize(for: waveNumber)
        timeBetweenSpawns = calculateSpawnRate(for: waveNumber)
        spawnTimer = 0
    }

    func update(deltaTime: TimeInterval, activeBugs: Int) {
        guard gameState.currentState == .wave else { return }

        // Spawn bugs
        if bugsSpawnedInWave < bugsToSpawnInWave {
            spawnTimer += deltaTime

            if spawnTimer >= timeBetweenSpawns {
                spawnBug()
                spawnTimer = 0
            }
        } else if activeBugs == 0 {
            // Wave complete
            completeWave()
        }
    }

    private func spawnBug() {
        let waveNumber = gameState.currentWave
        let bugType = selectBugType(for: waveNumber)
        let spawnPoint = selectSpawnPoint()

        let bug = Bug(type: bugType, at: spawnPoint, wave: waveNumber, difficulty: gameState.difficulty)
        onBugSpawned?(bug)

        bugsSpawnedInWave += 1
    }

    private func calculateWaveSize(for wave: Int) -> Int {
        // Progressive difficulty with exponential scaling
        let baseSize = Double(GameConfiguration.initialWaveSize)

        // Exponential growth: baseSize * (1 + wave/20)^1.5
        // This makes later waves much harder
        let growthFactor = pow(1.0 + Double(wave) / 20.0, 1.5)
        var waveSize = Int(baseSize * growthFactor)

        // Boss waves are significantly larger
        if wave % GameConfiguration.bossWaveInterval == 0 {
            waveSize = Int(Double(waveSize) * 2.5) // 2.5x bugs on boss waves
        }

        return max(waveSize, Int(baseSize)) // Never less than base size
    }

    private func calculateSpawnRate(for wave: Int) -> TimeInterval {
        // Faster spawns in later waves with smooth curve
        let baseRate: TimeInterval = 2.0
        let minRate: TimeInterval = 0.2

        // Exponential decrease: baseRate * (0.95^wave)
        // This gradually speeds up spawns over 100 waves
        let rate = baseRate * pow(0.95, Double(wave))

        return max(rate, minRate)
    }

    private func selectBugType(for wave: Int) -> BugType {
        // Boss waves every 25 waves
        if wave % GameConfiguration.bossWaveInterval == 0 {
            return .boss
        }

        // Progressive weighted bug selection - harder bugs more common in later waves
        let difficulty = min(Double(wave) / 100.0, 1.0) // 0.0 to 1.0 scale

        // Calculate weighted probabilities based on wave difficulty
        let weights: [(BugType, Double)] = [
            (.ant, max(0.3 - difficulty * 0.25, 0.05)),          // 30% -> 5%
            (.beetle, max(0.25 - difficulty * 0.15, 0.1)),       // 25% -> 10%
            (.spider, 0.15 + difficulty * 0.05),                  // 15% -> 20%
            (.mosquito, wave >= 10 ? 0.1 + difficulty * 0.15 : 0), // 10% -> 25% (unlocked wave 10)
            (.wasp, wave >= 15 ? 0.05 + difficulty * 0.20 : 0),    // 5% -> 25% (unlocked wave 15)
            (.splitter, wave >= 12 ? 0.10 + difficulty * 0.15 : 0), // 10% -> 25% (unlocked wave 12)
            (.burrower, wave >= 18 ? 0.08 + difficulty * 0.12 : 0) // 8% -> 20% (unlocked wave 18)
        ]

        // Select bug based on weighted probabilities
        let totalWeight = weights.reduce(0.0) { $0 + $1.1 }
        var random = Double.random(in: 0..<totalWeight)

        for (bugType, weight) in weights {
            random -= weight
            if random <= 0 {
                return bugType
            }
        }

        // Fallback (should never reach here)
        return .ant
    }

    private func selectSpawnPoint() -> GridPosition {
        let currentSpawnPoints = MapManager.shared.getCurrentSpawnPoints()
        return currentSpawnPoints.randomElement() ?? currentSpawnPoints[0]
    }

    private func completeWave() {
        gameState.completeWave() // Award coins
        gameState.changeState(to: .building)
        onWaveComplete?()
    }

    func getBugsRemaining() -> Int {
        return bugsToSpawnInWave - bugsSpawnedInWave
    }
}
