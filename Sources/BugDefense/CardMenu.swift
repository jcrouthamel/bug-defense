import SpriteKit
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// Menu for managing cards and slots
@MainActor
class CardMenu: SKNode {
    private let cardManager: CardManager
    private let researchLab: ResearchLab
    private let onClose: () -> Void

    private let background: SKShapeNode
    private let closeButton: Button

    private var slotViews: [CardSlotView] = []
    private var cardListViews: [CardListItemView] = []
    private var selectedSlotIndex: Int? = nil

    init(size: CGSize, cardManager: CardManager, researchLab: ResearchLab, onClose: @escaping () -> Void) {
        self.cardManager = cardManager
        self.researchLab = researchLab
        self.onClose = onClose

        // Create semi-transparent background
        self.background = SKShapeNode(rectOf: size)
        self.background.fillColor = SKColor.black.withAlphaComponent(0.9)
        self.background.strokeColor = .clear
        self.background.position = CGPoint(x: size.width / 2, y: size.height / 2)

        // Create close button
        self.closeButton = Button(
            text: "✕ Close",
            size: CGSize(width: 100, height: 45),
            color: .red
        )
        self.closeButton.position = CGPoint(x: size.width - 60, y: size.height - 35)

        super.init()

        isUserInteractionEnabled = true
        zPosition = 1000 // Ensure menu renders on top

        addChild(background)
        addChild(closeButton)

        closeButton.onTap = { [weak self] in
            self?.onClose()
        }

        setupCardMenu(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        // Check if close button was clicked
        if closeButton.contains(location) {
            closeButton.onTap?()
            return
        }

        // Block clicks from passing through
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check if close button was tapped
        if closeButton.contains(location) {
            closeButton.onTap?()
            return
        }

        // Block taps from passing through
    }
    #endif

    private func setupCardMenu(size: CGSize) {
        // Title
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "🎴 CARD SYSTEM 🎴"
        title.fontSize = 32
        title.fontColor = .orange
        title.position = CGPoint(x: size.width / 2, y: size.height - 80)
        addChild(title)

        // Subtitle
        let subtitle = SKLabelNode(fontNamed: "Helvetica")
        subtitle.text = "Equip cards for bonuses (unlocked from boss waves)"
        subtitle.fontSize = 14
        subtitle.fontColor = .lightGray
        subtitle.position = CGPoint(x: size.width / 2, y: size.height - 105)
        addChild(subtitle)

        // Slot section title
        let slotTitle = SKLabelNode(fontNamed: "Helvetica-Bold")
        slotTitle.text = "EQUIPPED CARDS"
        slotTitle.fontSize = 24
        slotTitle.fontColor = .cyan
        slotTitle.horizontalAlignmentMode = .left
        slotTitle.position = CGPoint(x: 50, y: size.height - 140)
        addChild(slotTitle)

        // Draw card slots
        let slotY = size.height - 200
        let slotSpacing: CGFloat = 140
        let startX: CGFloat = 80

        for i in 0..<GameConfiguration.cardSlotsCount {
            let slotView = CardSlotView(
                slotIndex: i,
                card: cardManager.getEquippedCard(at: i),
                isUnlocked: i < cardManager.unlockedSlots,
                unlockCost: cardManager.getSlotUnlockCost(i),
                onSlotTapped: { [weak self] slotIndex in
                    self?.handleSlotTapped(slotIndex)
                },
                onUnlockTapped: { [weak self] slotIndex in
                    self?.handleUnlockSlot(slotIndex)
                }
            )
            slotView.position = CGPoint(x: startX + CGFloat(i) * slotSpacing, y: slotY)
            addChild(slotView)
            slotViews.append(slotView)
        }

        // Collection section title
        let collectionTitle = SKLabelNode(fontNamed: "Helvetica-Bold")
        collectionTitle.text = "COLLECTED CARDS"
        collectionTitle.fontSize = 24
        collectionTitle.fontColor = .cyan
        collectionTitle.horizontalAlignmentMode = .left
        collectionTitle.position = CGPoint(x: 50, y: size.height - 340)
        addChild(collectionTitle)

        // Draw collected cards list
        drawCardsList(size: size)
    }

    private func drawCardsList(size: CGSize) {
        // Remove existing card list views
        for view in cardListViews {
            view.removeFromParent()
        }
        cardListViews.removeAll()

        let cards = cardManager.getCollectedCardsList()
        let cardWidth: CGFloat = 250
        let cardHeight: CGFloat = 80
        let cardSpacing: CGFloat = 10
        let startY = size.height - 400
        let startX: CGFloat = 80

        let cardsPerRow = 3
        for (index, card) in cards.enumerated() {
            let row = index / cardsPerRow
            let col = index % cardsPerRow

            let cardView = CardListItemView(
                card: card,
                size: CGSize(width: cardWidth, height: cardHeight),
                onTapped: { [weak self] tappedCard in
                    self?.handleCardSelected(tappedCard)
                }
            )
            cardView.position = CGPoint(
                x: startX + CGFloat(col) * (cardWidth + cardSpacing),
                y: startY - CGFloat(row) * (cardHeight + cardSpacing)
            )
            addChild(cardView)
            cardListViews.append(cardView)
        }

        // Show message if no cards collected
        if cards.isEmpty {
            let noCardsLabel = SKLabelNode(fontNamed: "Helvetica")
            noCardsLabel.text = "No cards collected yet. Defeat boss waves to earn cards!"
            noCardsLabel.fontSize = 18
            noCardsLabel.fontColor = .gray
            noCardsLabel.position = CGPoint(x: size.width / 2, y: startY - 40)
            addChild(noCardsLabel)
        }
    }

    private func handleSlotTapped(_ slotIndex: Int) {
        guard slotIndex < cardManager.unlockedSlots else { return }

        if selectedSlotIndex == slotIndex {
            // Deselect
            selectedSlotIndex = nil
            updateSlotHighlights()
        } else {
            // Select this slot
            selectedSlotIndex = slotIndex
            updateSlotHighlights()
        }
    }

    private func handleCardSelected(_ card: Card) {
        guard let slotIndex = selectedSlotIndex else {
            // No slot selected, try to find empty slot
            for i in 0..<cardManager.unlockedSlots {
                if cardManager.getEquippedCard(at: i) == nil {
                    _ = cardManager.equipCard(card, to: i)
                    refreshSlots()
                    return
                }
            }
            return
        }

        // Equip card to selected slot
        _ = cardManager.equipCard(card, to: slotIndex)
        refreshSlots()
        selectedSlotIndex = nil
        updateSlotHighlights()
    }

    private func handleUnlockSlot(_ slotIndex: Int) {
        if cardManager.unlockSlot(slotIndex, with: researchLab) {
            refreshSlots()
        }
    }

    private func updateSlotHighlights() {
        for (index, slotView) in slotViews.enumerated() {
            slotView.setHighlighted(index == selectedSlotIndex)
        }
    }

    private func refreshSlots() {
        for (index, slotView) in slotViews.enumerated() {
            slotView.updateCard(cardManager.getEquippedCard(at: index))
            slotView.setUnlocked(index < cardManager.unlockedSlots)
        }
    }
}

/// Visual representation of a card slot
@MainActor
class CardSlotView: SKNode {
    private let slotIndex: Int
    private var isUnlocked: Bool
    private let unlockCost: Int
    private let onSlotTapped: (Int) -> Void
    private let onUnlockTapped: (Int) -> Void

    private let background: SKShapeNode
    private var cardDisplay: SKNode?
    private var lockIcon: SKLabelNode?
    private var unlockButton: Button?
    private var highlightBorder: SKShapeNode?

    init(slotIndex: Int, card: Card?, isUnlocked: Bool, unlockCost: Int,
         onSlotTapped: @escaping (Int) -> Void,
         onUnlockTapped: @escaping (Int) -> Void) {
        self.slotIndex = slotIndex
        self.isUnlocked = isUnlocked
        self.unlockCost = unlockCost
        self.onSlotTapped = onSlotTapped
        self.onUnlockTapped = onUnlockTapped

        let size = CGSize(width: 120, height: 160)
        self.background = SKShapeNode(rectOf: size, cornerRadius: 10)
        self.background.fillColor = isUnlocked ? SKColor.darkGray.withAlphaComponent(0.8) : .black
        self.background.strokeColor = .white
        self.background.lineWidth = 2

        super.init()

        addChild(background)

        // Create highlight border (initially hidden)
        let highlightSize = CGSize(width: 124, height: 164)
        self.highlightBorder = SKShapeNode(rectOf: highlightSize, cornerRadius: 10)
        self.highlightBorder?.fillColor = .clear
        self.highlightBorder?.strokeColor = .yellow
        self.highlightBorder?.lineWidth = 4
        self.highlightBorder?.isHidden = true
        addChild(highlightBorder!)

        if isUnlocked {
            if let card = card {
                displayCard(card)
            } else {
                showEmptySlot()
            }
        } else {
            showLockedSlot()
        }

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func displayCard(_ card: Card) {
        cardDisplay?.removeFromParent()

        let container = SKNode()

        // Card emoji
        let emoji = SKLabelNode(fontNamed: "Helvetica")
        emoji.text = card.emoji
        emoji.fontSize = 40
        emoji.position = CGPoint(x: 0, y: 30)
        container.addChild(emoji)

        // Card name
        let name = SKLabelNode(fontNamed: "Helvetica-Bold")
        name.text = card.name
        name.fontSize = 12
        name.fontColor = .white
        name.position = CGPoint(x: 0, y: -10)
        name.preferredMaxLayoutWidth = 100
        name.numberOfLines = 2
        container.addChild(name)

        // Rarity indicator
        let rarityLabel = SKLabelNode(fontNamed: "Helvetica")
        rarityLabel.text = card.rarity.rawValue
        rarityLabel.fontSize = 10
        let color = card.rarity.color
        rarityLabel.fontColor = SKColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
        rarityLabel.position = CGPoint(x: 0, y: -35)
        container.addChild(rarityLabel)

        cardDisplay = container
        addChild(container)
    }

    private func showEmptySlot() {
        cardDisplay?.removeFromParent()

        let emptyLabel = SKLabelNode(fontNamed: "Helvetica")
        emptyLabel.text = "Empty\nSlot"
        emptyLabel.fontSize = 14
        emptyLabel.fontColor = .gray
        emptyLabel.numberOfLines = 2
        emptyLabel.position = CGPoint(x: 0, y: -10)
        cardDisplay = emptyLabel
        addChild(emptyLabel)
    }

    private func showLockedSlot() {
        lockIcon?.removeFromParent()
        unlockButton?.removeFromParent()

        let lock = SKLabelNode(fontNamed: "Helvetica")
        lock.text = "🔒"
        lock.fontSize = 40
        lock.position = CGPoint(x: 0, y: 20)
        lockIcon = lock
        addChild(lock)

        let unlockBtn = Button(
            text: "Unlock\n\(unlockCost) 🪙",
            size: CGSize(width: 100, height: 50),
            color: .cyan
        )
        unlockBtn.position = CGPoint(x: 0, y: -30)
        unlockBtn.onTap = { [weak self] in
            guard let self = self else { return }
            self.onUnlockTapped(self.slotIndex)
        }
        unlockButton = unlockBtn
        addChild(unlockBtn)
    }

    func updateCard(_ card: Card?) {
        if isUnlocked {
            if let card = card {
                displayCard(card)
            } else {
                showEmptySlot()
            }
        }
    }

    func setUnlocked(_ unlocked: Bool) {
        isUnlocked = unlocked
        background.fillColor = unlocked ? SKColor.darkGray.withAlphaComponent(0.8) : .black

        if unlocked {
            lockIcon?.removeFromParent()
            unlockButton?.removeFromParent()
            lockIcon = nil
            unlockButton = nil
            showEmptySlot()
        }
    }

    func setHighlighted(_ highlighted: Bool) {
        highlightBorder?.isHidden = !highlighted
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        if isUnlocked {
            onSlotTapped(slotIndex)
        }
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isUnlocked {
            onSlotTapped(slotIndex)
        }
    }
    #endif
}

/// Card display in the collection list
@MainActor
class CardListItemView: SKNode {
    private let card: Card
    private let onTapped: (Card) -> Void

    init(card: Card, size: CGSize, onTapped: @escaping (Card) -> Void) {
        self.card = card
        self.onTapped = onTapped

        super.init()

        // Background
        let background = SKShapeNode(rectOf: size, cornerRadius: 8)
        let color = card.rarity.color
        background.fillColor = SKColor(red: color.r, green: color.g, blue: color.b, alpha: 0.3)
        background.strokeColor = SKColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
        background.lineWidth = 2
        addChild(background)

        // Emoji
        let emoji = SKLabelNode(fontNamed: "Helvetica")
        emoji.text = card.emoji
        emoji.fontSize = 30
        emoji.position = CGPoint(x: -size.width / 2 + 30, y: 0)
        addChild(emoji)

        // Name
        let name = SKLabelNode(fontNamed: "Helvetica-Bold")
        name.text = card.name
        name.fontSize = 14
        name.fontColor = .white
        name.horizontalAlignmentMode = .left
        name.position = CGPoint(x: -size.width / 2 + 60, y: 15)
        addChild(name)

        // Description
        let desc = SKLabelNode(fontNamed: "Helvetica")
        desc.text = card.description
        desc.fontSize = 11
        desc.fontColor = .lightGray
        desc.horizontalAlignmentMode = .left
        desc.position = CGPoint(x: -size.width / 2 + 60, y: -5)
        desc.preferredMaxLayoutWidth = size.width - 70
        desc.numberOfLines = 0  // Allow text wrapping
        addChild(desc)

        // Rarity
        let rarity = SKLabelNode(fontNamed: "Helvetica")
        rarity.text = card.rarity.rawValue
        rarity.fontSize = 10
        rarity.fontColor = SKColor(red: color.r, green: color.g, blue: color.b, alpha: 1.0)
        rarity.horizontalAlignmentMode = .left
        rarity.position = CGPoint(x: -size.width / 2 + 60, y: -25)
        addChild(rarity)

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        onTapped(card)
    }
    #elseif os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTapped(card)
    }
    #endif
}
