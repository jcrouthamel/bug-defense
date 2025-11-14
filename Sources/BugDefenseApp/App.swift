import Foundation
import SpriteKit
import BugDefense

#if os(macOS)
import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    nonisolated(unsafe) var gameScene: GameScene!
    var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 App launching...")

        // Create window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Bug Defense"
        window.center()
        print("✅ Window created at: \(window.frame)")

        // Create and configure SKView
        let skView = SKView(frame: window.contentView!.bounds)
        skView.autoresizingMask = [.width, .height]
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        print("✅ SKView created")

        // Create and present scene - use view bounds for full window coverage
        let sceneSize = skView.bounds.size
        gameScene = GameScene(size: sceneSize)
        gameScene.scaleMode = .aspectFill
        skView.presentScene(gameScene)
        print("✅ GameScene created and presented")

        window.contentView = skView
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()  // Force window to front
        window.makeKey()  // Make it the key window
        window.setIsVisible(true)  // Ensure it's visible
        print("✅ Window visible: \(window.isVisible), key: \(window.isKeyWindow)")

        // Ensure window accepts key events
        window.acceptsMouseMovedEvents = true
        window.isMovableByWindowBackground = false

        // Set up application-level event monitoring for keyboard and mouse
        // TODO: Re-enable after fixing Swift 6 concurrency issues
        // setupEventMonitoring()

        // Activate the app
        NSApp.activate(ignoringOtherApps: true)
        print("✅ App activated")
        print("🎮 Bug Defense is ready! Window should be visible now.")
    }

    func setupEventMonitoring() {
        // Temporarily disabled due to Swift 6 concurrency issues
        // TODO: Fix concurrency handling for keyboard/mouse event monitoring
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

#elseif os(iOS)
import UIKit
import SwiftUI

@main
@MainActor
struct BugDefenseApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
        }
    }
}

struct GameView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true

        // Use screen bounds for scene size
        let screenSize = UIScreen.main.bounds.size
        let scene = GameScene(size: screenSize)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)

        // Show FPS and node count for debugging
        skView.showsFPS = true
        skView.showsNodeCount = true

        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        // Update view if needed
    }
}
#endif
