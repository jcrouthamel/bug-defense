import Foundation
import SpriteKit

/// Dropdown menu item configuration
struct DropdownMenuItem {
    let id: String
    let text: String
    let color: SKColor
    let action: () -> Void
}

/// A dropdown menu that shows/hides a list of options
@MainActor
class DropdownMenu: SKNode {
    private let toggleButton: SKShapeNode
    private let toggleLabel: SKLabelNode
    private let buttonSize: CGSize
    private var menuItems: [DropdownMenuItemNode] = []
    private var isOpen: Bool = false
    private let itemHeight: CGFloat = 40
    private let itemSpacing: CGFloat = 5

    var onToggle: ((Bool) -> Void)?

    init(title: String, size: CGSize, color: SKColor) {
        self.buttonSize = size

        // Create toggle button
        self.toggleButton = SKShapeNode(rectOf: size, cornerRadius: 5)
        self.toggleButton.fillColor = color
        self.toggleButton.strokeColor = .white
        self.toggleButton.lineWidth = 2

        // Create toggle label
        self.toggleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.toggleLabel.text = "\(title) ▼"
        self.toggleLabel.fontSize = 14
        self.toggleLabel.fontColor = .white
        self.toggleLabel.verticalAlignmentMode = .center
        self.toggleLabel.horizontalAlignmentMode = .center

        super.init()

        addChild(toggleButton)
        addChild(toggleLabel)

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setItems(_ items: [DropdownMenuItem]) {
        // Remove old items
        for item in menuItems {
            item.removeFromParent()
        }
        menuItems.removeAll()

        // Create new items
        for (index, menuItem) in items.enumerated() {
            let itemNode = DropdownMenuItemNode(
                id: menuItem.id,
                text: menuItem.text,
                size: CGSize(width: buttonSize.width, height: itemHeight),
                color: menuItem.color,
                action: { [weak self] in
                    menuItem.action()
                    self?.toggle() // Close menu after selection
                }
            )

            // Position below the toggle button
            let yOffset = -buttonSize.height / 2 - CGFloat(index + 1) * (itemHeight + itemSpacing)
            itemNode.position = CGPoint(x: 0, y: yOffset)
            itemNode.isHidden = true // Start hidden

            addChild(itemNode)
            menuItems.append(itemNode)
        }
    }

    func toggle() {
        isOpen.toggle()

        // Update arrow direction
        let currentTitle = toggleLabel.text?.replacingOccurrences(of: " ▼", with: "")
            .replacingOccurrences(of: " ▲", with: "") ?? "Menu"
        toggleLabel.text = isOpen ? "\(currentTitle) ▲" : "\(currentTitle) ▼"

        // Show/hide menu items with animation
        for (index, item) in menuItems.enumerated() {
            if isOpen {
                item.isHidden = false
                item.alpha = 0
                let fadeIn = SKAction.fadeIn(withDuration: 0.2)
                let delay = SKAction.wait(forDuration: Double(index) * 0.05)
                item.run(SKAction.sequence([delay, fadeIn]))
            } else {
                let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                let hide = SKAction.run { item.isHidden = true }
                item.run(SKAction.sequence([fadeOut, hide]))
            }
        }

        onToggle?(isOpen)
    }

    func updateItem(id: String, text: String, color: SKColor) {
        // Find and update the matching item
        guard let index = menuItems.firstIndex(where: { $0.id == id }) else { return }

        let item = menuItems[index]
        item.updateText(text)
        item.updateColor(color)
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        if toggleButton.contains(location) {
            toggle()
        }
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if toggleButton.contains(location) {
            toggle()
        }
    }
    #endif

    override func contains(_ point: CGPoint) -> Bool {
        guard let parent = parent else { return false }
        let localPoint = self.convert(point, from: parent)

        // Check toggle button
        if abs(localPoint.x) < buttonSize.width / 2 && abs(localPoint.y) < buttonSize.height / 2 {
            return true
        }

        // Check menu items if open
        if isOpen {
            for item in menuItems {
                if item.contains(localPoint) {
                    return true
                }
            }
        }

        return false
    }
}

/// Individual menu item in a dropdown
@MainActor
class DropdownMenuItemNode: SKNode {
    let id: String
    private let background: SKShapeNode
    private let label: SKLabelNode
    private let itemSize: CGSize
    private var action: (() -> Void)?

    init(id: String = UUID().uuidString, text: String, size: CGSize, color: SKColor, action: @escaping () -> Void) {
        self.id = id
        self.itemSize = size
        self.action = action

        // Background
        self.background = SKShapeNode(rectOf: size, cornerRadius: 5)
        self.background.fillColor = color
        self.background.strokeColor = .white
        self.background.lineWidth = 2

        // Label
        self.label = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.label.text = text
        self.label.fontSize = 13
        self.label.fontColor = .white
        self.label.verticalAlignmentMode = .center
        self.label.horizontalAlignmentMode = .center

        super.init()

        addChild(background)
        addChild(label)

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateText(_ text: String) {
        label.text = text
    }

    func updateColor(_ color: SKColor) {
        background.fillColor = color
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        action?()
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        action?()
    }
    #endif

    override func contains(_ point: CGPoint) -> Bool {
        guard let parent = parent else { return false }
        let localPoint = self.convert(point, from: parent)
        return abs(localPoint.x) < itemSize.width / 2 && abs(localPoint.y) < itemSize.height / 2
    }
}
