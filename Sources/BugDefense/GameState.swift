import Foundation

/// Represents the current state of the game
enum GameState {
    case mainMenu
    case building      // Player is placing structures between waves
    case wave          // Wave is active, bugs are spawning
    case upgrade       // Player is viewing upgrade trees
    case gameOver
    case victory
}

/// Manages the overall game state and progression
@MainActor
class GameStateManager {
    private(set) var currentState: GameState = .building
    private(set) var currentWave: Int = 0
    private(set) var currency: Int
    private(set) var houseHealth: Int
    var isAdminMode: Bool = false
    var difficulty: Difficulty = .normal {
        didSet {
            if currentWave == 0 {
                // Only reset if game hasn't started
                currency = Int(CGFloat(GameConfiguration.startingCurrency) * difficulty.startingCurrencyMultiplier)
                onCurrencyChanged?(currency)
            }
        }
    }

    // Callbacks for state changes
    var onStateChanged: ((GameState) -> Void)?
    var onCurrencyChanged: ((Int) -> Void)?
    var onHealthChanged: ((Int) -> Void)?
    var onWaveChanged: ((Int) -> Void)?
    var onWaveCompleted: ((Int) -> Void)? // Passes coins earned

    init() {
        self.currency = Int(CGFloat(GameConfiguration.startingCurrency) * difficulty.startingCurrencyMultiplier)
        self.houseHealth = Int(CGFloat(GameConfiguration.houseMaxHealth) * difficulty.houseHealthMultiplier)
    }

    func changeState(to newState: GameState) {
        currentState = newState
        onStateChanged?(newState)
    }

    func startNextWave() {
        currentWave += 1
        onWaveChanged?(currentWave)
        changeState(to: .wave)
    }

    func addCurrency(_ amount: Int) {
        currency += amount
        onCurrencyChanged?(currency)
    }

    func spendCurrency(_ amount: Int) -> Bool {
        if isAdminMode {
            return true // Don't actually spend in admin mode
        }
        guard currency >= amount else { return false }
        currency -= amount
        onCurrencyChanged?(currency)
        return true
    }

    func damageHouse(_ damage: Int) {
        if isAdminMode {
            return // Don't take damage in admin mode
        }
        houseHealth = max(0, houseHealth - damage)
        onHealthChanged?(houseHealth)

        if houseHealth <= 0 {
            changeState(to: .gameOver)
        }
    }

    func toggleAdminMode() {
        isAdminMode = !isAdminMode
        if isAdminMode {
            // Max out all resources when enabling admin mode
            currency = 999999
            houseHealth = 999999
            onCurrencyChanged?(currency)
            onHealthChanged?(houseHealth)
            print("🔓 Admin Mode ENABLED - Unlimited resources!")
        } else {
            print("🔒 Admin Mode DISABLED")
        }
    }

    func completeWave() {
        // Calculate coins earned
        var coinsEarned = GameConfiguration.baseCoinsPerWave

        // Bonus coins for milestone waves (5, 10, 15, 20)
        if currentWave % 5 == 0 {
            coinsEarned += GameConfiguration.bonusCoinsEvery5Waves
        }

        // Bonus coins for boss waves (every 25)
        if currentWave % GameConfiguration.bossWaveInterval == 0 {
            coinsEarned += GameConfiguration.bonusCoinsPerBossWave
        }

        // Notify listeners (ResearchLab will receive these)
        onWaveCompleted?(coinsEarned)
    }

    func isBossWave() -> Bool {
        return currentWave % GameConfiguration.bossWaveInterval == 0
    }

    func checkVictory() {
        if currentWave >= GameConfiguration.totalWaves && currentState == .building {
            changeState(to: .victory)
        }
    }

    func reset() {
        currentState = .building
        currentWave = 0
        currency = Int(CGFloat(GameConfiguration.startingCurrency) * difficulty.startingCurrencyMultiplier)
        houseHealth = Int(CGFloat(GameConfiguration.houseMaxHealth) * difficulty.houseHealthMultiplier)
    }
}
