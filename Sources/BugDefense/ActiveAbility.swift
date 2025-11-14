import Foundation
import SpriteKit

/// Types of active abilities the player can use
enum ActiveAbilityType {
    case airstrike    // Drop a bomb that deals area damage
    case timeSlow     // Slow all bugs for a duration
    case instantKill  // Kill a single targeted bug instantly
    case goldRush     // Double currency rewards for a duration

    var name: String {
        switch self {
        case .airstrike: return "Airstrike"
        case .timeSlow: return "Time Slow"
        case .instantKill: return "Instant Kill"
        case .goldRush: return "Gold Rush"
        }
    }

    var cooldown: TimeInterval {
        switch self {
        case .airstrike: return 30.0
        case .timeSlow: return 45.0
        case .instantKill: return 20.0
        case .goldRush: return 60.0
        }
    }

    var cost: Int {
        switch self {
        case .airstrike: return 100
        case .timeSlow: return 150
        case .instantKill: return 75
        case .goldRush: return 200
        }
    }

    var description: String {
        switch self {
        case .airstrike: return "Drop a bomb dealing 100 damage in an area"
        case .timeSlow: return "Slow all bugs by 50% for 5 seconds"
        case .instantKill: return "Instantly kill one bug"
        case .goldRush: return "Double currency rewards for 10 seconds"
        }
    }

    var icon: String {
        switch self {
        case .airstrike: return "💣"
        case .timeSlow: return "⏱️"
        case .instantKill: return "☠️"
        case .goldRush: return "💰"
        }
    }
}

/// Manages active abilities and their cooldowns
@MainActor
class ActiveAbilityManager {
    private var cooldowns: [ActiveAbilityType: TimeInterval] = [:]
    private var activeEffects: [ActiveAbilityType: TimeInterval] = [:] // For duration-based abilities

    // Callbacks
    var onAbilityUsed: ((ActiveAbilityType) -> Void)?
    var onAbilityReady: ((ActiveAbilityType) -> Void)?
    var onGoldRushActive: ((Bool) -> Void)? // Notify when gold rush starts/ends

    init() {
        // Initialize all cooldowns to 0 (ready)
        for ability in [ActiveAbilityType.airstrike, .timeSlow, .instantKill, .goldRush] {
            cooldowns[ability] = 0
        }
    }

    func update(deltaTime: TimeInterval) {
        // Update cooldowns
        for (ability, remaining) in cooldowns {
            if remaining > 0 {
                let newRemaining = max(0, remaining - deltaTime)
                cooldowns[ability] = newRemaining

                // Notify when ability becomes ready
                if newRemaining == 0 && remaining > 0 {
                    onAbilityReady?(ability)
                }
            }
        }

        // Update active effects
        for (ability, remaining) in activeEffects {
            let newRemaining = max(0, remaining - deltaTime)
            activeEffects[ability] = newRemaining

            // Notify when effect ends
            if newRemaining == 0 && remaining > 0 {
                if ability == .goldRush {
                    onGoldRushActive?(false)
                }
            }
        }
    }

    func canUseAbility(_ ability: ActiveAbilityType, currency: Int) -> Bool {
        guard let cooldownRemaining = cooldowns[ability] else { return false }
        return cooldownRemaining == 0 && currency >= ability.cost
    }

    func useAbility(_ ability: ActiveAbilityType) {
        cooldowns[ability] = ability.cooldown

        // Start duration-based effects
        switch ability {
        case .timeSlow:
            activeEffects[ability] = 5.0 // 5 second duration
        case .goldRush:
            activeEffects[ability] = 10.0 // 10 second duration
            onGoldRushActive?(true)
        default:
            break
        }

        onAbilityUsed?(ability)
    }

    func getCooldownRemaining(_ ability: ActiveAbilityType) -> TimeInterval {
        return cooldowns[ability] ?? 0
    }

    func isAbilityReady(_ ability: ActiveAbilityType) -> Bool {
        return (cooldowns[ability] ?? 0) == 0
    }

    func isGoldRushActive() -> Bool {
        return (activeEffects[.goldRush] ?? 0) > 0
    }

    func isTimeSlowActive() -> Bool {
        return (activeEffects[.timeSlow] ?? 0) > 0
    }
}
