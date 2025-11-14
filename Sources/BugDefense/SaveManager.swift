import Foundation

/// Handles saving and loading game progress
@MainActor
class SaveManager {
    static let shared = SaveManager()

    private let userDefaults = UserDefaults.standard
    private let saveKey = "BugDefenseGameSave"

    private init() {}

    /// Save the current game state
    func saveGame(
        wave: Int,
        currency: Int,
        houseHealth: Int,
        difficulty: Difficulty,
        totalCoins: Int,
        gems: Int,
        unlockedCardSlots: Int,
        equippedCardIDs: [String],
        purchasedUpgradeIDs: [String]
    ) {
        let saveData: [String: Any] = [
            "wave": wave,
            "currency": currency,
            "houseHealth": houseHealth,
            "difficulty": difficulty.rawValue,
            "totalCoins": totalCoins,
            "gems": gems,
            "unlockedCardSlots": unlockedCardSlots,
            "equippedCardIDs": equippedCardIDs,
            "purchasedUpgradeIDs": purchasedUpgradeIDs,
            "saveDate": Date().timeIntervalSince1970
        ]

        userDefaults.set(saveData, forKey: saveKey)
        userDefaults.synchronize()

        print("💾 Game saved! Wave: \(wave), Currency: \(currency)")
    }

    /// Load the saved game state
    func loadGame() -> GameSaveData? {
        guard let saveData = userDefaults.dictionary(forKey: saveKey) else {
            print("📂 No save data found")
            return nil
        }

        guard let wave = saveData["wave"] as? Int,
              let currency = saveData["currency"] as? Int,
              let houseHealth = saveData["houseHealth"] as? Int,
              let difficultyString = saveData["difficulty"] as? String,
              let difficulty = Difficulty(rawValue: difficultyString),
              let totalCoins = saveData["totalCoins"] as? Int,
              let gems = saveData["gems"] as? Int,
              let unlockedCardSlots = saveData["unlockedCardSlots"] as? Int,
              let equippedCardIDs = saveData["equippedCardIDs"] as? [String],
              let purchasedUpgradeIDs = saveData["purchasedUpgradeIDs"] as? [String],
              let saveDate = saveData["saveDate"] as? TimeInterval else {
            print("⚠️ Save data corrupted")
            return nil
        }

        print("📂 Game loaded! Wave: \(wave), Currency: \(currency)")

        return GameSaveData(
            wave: wave,
            currency: currency,
            houseHealth: houseHealth,
            difficulty: difficulty,
            totalCoins: totalCoins,
            gems: gems,
            unlockedCardSlots: unlockedCardSlots,
            equippedCardIDs: equippedCardIDs,
            purchasedUpgradeIDs: purchasedUpgradeIDs,
            saveDate: Date(timeIntervalSince1970: saveDate)
        )
    }

    /// Check if a save file exists
    func hasSaveData() -> Bool {
        return userDefaults.dictionary(forKey: saveKey) != nil
    }

    /// Delete the save file
    func deleteSave() {
        userDefaults.removeObject(forKey: saveKey)
        userDefaults.synchronize()
        print("🗑️ Save data deleted")
    }

    /// Get save file info for display
    func getSaveInfo() -> String? {
        guard let saveData = userDefaults.dictionary(forKey: saveKey),
              let wave = saveData["wave"] as? Int,
              let saveDate = saveData["saveDate"] as? TimeInterval else {
            return nil
        }

        let date = Date(timeIntervalSince1970: saveDate)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return "Wave \(wave) - \(formatter.string(from: date))"
    }
}

/// Data structure for saved game
struct GameSaveData {
    let wave: Int
    let currency: Int
    let houseHealth: Int
    let difficulty: Difficulty
    let totalCoins: Int
    let gems: Int
    let unlockedCardSlots: Int
    let equippedCardIDs: [String]
    let purchasedUpgradeIDs: [String]
    let saveDate: Date
}
