import UIKit
import SwiftUI
import SpriteKit
import BugDefense

@main
@MainActor
struct BugDefenseApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
                .preferredColorScheme(.dark)
        }
    }
}

struct GameView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true

        // Use screen bounds to fill the entire screen
        let screenSize = UIScreen.main.bounds.size
        let scene = GameScene(size: screenSize)
        scene.scaleMode = .aspectFill  // Fill entire screen
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
