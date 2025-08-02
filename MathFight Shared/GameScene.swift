//
//  GameScene.swift
//  MathFight Shared
//
//  Created by Alvindo Tri Jatmiko on 31/07/25.
//

import SpriteKit

struct PhysicsCategory {
    static let player: UInt32 = 1 << 0  // 0001
    static let land: UInt32 = 1 << 1  // 0010
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var pressedKeys = Set<UInt16>()

    var player: SKSpriteNode!
    var playerState: CharacterState = .idle
    var playerIsOnGround: Bool = false
    var playerCanAttack: Bool = false
    var playerIdleFrames: [SKTexture] {
        setupAnimationFrames(name: "PlayerIdle")
    }
    var playerAttack1Frames: [SKTexture] {
        setupAnimationFrames(name: "PlayerAttack1")
    }
    var playerAttack2Frames: [SKTexture] {
        setupAnimationFrames(name: "PlayerAttack2")
    }
    var playerJumpFrames: [SKTexture] {
        setupAnimationFrames(name: "PlayerJump")
    }
    var playerFallFrames: [SKTexture] {
        setupAnimationFrames(name: "PlayerFall")
    }
    var playerRunFrames: [SKTexture] {
        setupAnimationFrames(name: "PlayerRun")
    }
    var moveDirection: CGFloat = 0.0
    let moveSpeed: CGFloat = 500.0

    var bot: SKSpriteNode!
    var botIdleFrames: [SKTexture] {
        setupAnimationFrames(name: "BotIdle")
    }

    #if os(iOS)
        let buttonLeft = SKSpriteNode(
            texture: SKTexture(
                image: UIImage(systemName: "arrow.left.circle")!
            )
        )

        let buttonRight = SKSpriteNode(
            texture: SKTexture(
                image: UIImage(systemName: "arrow.right.circle")!
            )
        )

        let buttonJump = SKSpriteNode(
            texture: SKTexture(
                image: UIImage(systemName: "arrow.up.circle")!
            )
        )

        let buttonAttack = SKSpriteNode(
            texture: SKTexture(
                image: UIImage(systemName: "hand.thumbsup.circle")!
            )
        )
    #endif

    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill

        return scene
    }

    func setUpScene() {

    }

    override func didMove(to view: SKView) {
        self.setUpScene()

        #if os(macOS)
            view.window?.makeFirstResponder(self)
        #endif

        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        setupCharacters()
        setupLand()

        #if os(iOS)
            setupButtons()
        #endif
    }

    override func update(_ currentTime: TimeInterval) {
        let distance = player.position.x - bot.position.x
        if abs(distance) < 100 {
            attackPlayer()
        } else {
            moveBotTowardPlayer()
        }

        playerHorizontalMove()

        guard let playerPhysicsBody = player.physicsBody else { return }

        if !playerIsOnGround && playerPhysicsBody.velocity.dy < 0
            && playerState != .fall && !playerCanAttack
        {
            changePlayerState(to: .fall)
        } else if !playerIsOnGround && playerPhysicsBody.velocity.dy > 0
            && playerState != .jump && !playerCanAttack
        {
            changePlayerState(to: .jump)
        } else if playerIsOnGround && playerState != .idle
            && playerPhysicsBody.velocity.dx == 0 && !playerCanAttack
        {
            changePlayerState(to: .idle)
        } else if playerIsOnGround && playerState != .run
            && playerPhysicsBody.velocity.dx != 0 && !playerCanAttack
        {
            changePlayerState(to: .run)
        } else if playerCanAttack && playerState != .attack1 {
            print("player attack")
            changePlayerState(to: .attack1)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let combo =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if combo == PhysicsCategory.player | PhysicsCategory.land {
            playerIsOnGround = true
            print("Player kena lantai!")
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let combo =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if combo == PhysicsCategory.player | PhysicsCategory.land {
            playerIsOnGround = false
            print("Player lompat")
        }
    }

    // MARK: -setup start

    func setupCharacterPhysicsBody(character: SKSpriteNode) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(
            texture: character.texture!,
            size: character.size
        )
        physicsBody.categoryBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask = PhysicsCategory.land
        physicsBody.contactTestBitMask = PhysicsCategory.land
        physicsBody.allowsRotation = false
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = true
        return physicsBody
    }

    func setupCharacters() {
        player = SKSpriteNode(texture: playerIdleFrames.first)
        player.physicsBody = setupCharacterPhysicsBody(character: player)
        player.zPosition = 1
        player.xScale = characterScale
        player.yScale = characterScale
        addChild(player)

        bot = SKSpriteNode(texture: botIdleFrames.first)
        bot.physicsBody = setupCharacterPhysicsBody(character: bot)
        bot.position = CGPoint(x: size.width * 0.4, y: 0)
        bot.zPosition = 1
        bot.xScale = -1.0 * characterScale
        bot.yScale = characterScale
        addChild(bot)
        startAnimationFrames(
            frames: botIdleFrames,
            key: botIdleAnimationKey,
            character: bot,
            loop: true
        )
    }

    func setupAnimationFrames(name: String) -> [SKTexture] {
        let atlas = SKTextureAtlas(named: name)
        let sortedNames = atlas.textureNames.sorted()
        return sortedNames.map { atlas.textureNamed($0) }
    }

    #if os(iOS)
        func setupButtons() {
            buttonLeft.position = CGPoint(
                x: -size.width * 0.4,
                y: -size.height * 0.2
            )
            buttonLeft.name = "left"
            buttonLeft.scale(to: CGSize(width: 100, height: 100))
            buttonLeft.zPosition = 2
            addChild(buttonLeft)

            buttonRight.position = CGPoint(
                x: -size.width * 0.3,
                y: -size.height * 0.2
            )
            buttonRight.name = "right"
            buttonRight.scale(to: CGSize(width: 100, height: 100))
            buttonRight.zPosition = 2
            addChild(buttonRight)

            buttonAttack.position = CGPoint(
                x: size.width * 0.3,
                y: -size.height * 0.2
            )
            buttonAttack.name = "attack"
            buttonAttack.scale(to: CGSize(width: 100, height: 100))
            buttonAttack.zPosition = 2
            addChild(buttonAttack)

            buttonJump.position = CGPoint(
                x: size.width * 0.4,
                y: -size.height * 0.2
            )
            buttonJump.name = "jump"
            buttonJump.scale(to: CGSize(width: 100, height: 100))
            buttonJump.zPosition = 2
            addChild(buttonJump)
        }
    #endif

    func setupLand() {
        let landTexture = SKTexture(imageNamed: "land_0002")
        let landWidth = 100.0
        let landCount = Int(ceil(size.width / landWidth)) + 1

        let earthTexture = SKTexture(imageNamed: "land_0004")
        let earthWidth: CGFloat = 100.0
        
        #if os(iOS)
        let verticalOffsetFraction: CGFloat = 0.23
        #elseif os(macOS)
        let verticalOffsetFraction: CGFloat = 0.42
        #endif
        

        var landContainerWidth: CGFloat = 0

        for i in 0..<landCount {
            let land = SKSpriteNode(texture: landTexture)
            let earth = SKSpriteNode(texture: earthTexture)
            earth.position = CGPoint(
                x: CGFloat(i) * earthWidth - size.width * 0.5,
                y: -size.height * (verticalOffsetFraction + 0.08) + earthWidth * 0.5
            )
            earth.scale(to: CGSize(width: 100, height: 100))
            earth.zPosition = 1
            addChild(earth)

            land.position = CGPoint(
                x: CGFloat(i) * landWidth - size.width * 0.5,
                y: -size.height * verticalOffsetFraction + landWidth * 0.5
            )
            landContainerWidth += landWidth
            land.scale(to: CGSize(width: 100, height: 100))
            land.zPosition = 0
            addChild(land)
        }

        let landPhysicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: landContainerWidth, height: 100)
        )
        landPhysicsBody.isDynamic = false
        landPhysicsBody.categoryBitMask = PhysicsCategory.land
        landPhysicsBody.collisionBitMask = PhysicsCategory.player
        landPhysicsBody.contactTestBitMask = PhysicsCategory.player
        let landContainer = SKNode()
        landContainer.physicsBody = landPhysicsBody
        landContainer.position = CGPoint(
            x: 0,
            y: -size.height * (verticalOffsetFraction + 0.02) + landWidth * 0.5
        )
        addChild(landContainer)
    }

    // MARK: -setup end

    func changePlayerState(to newState: CharacterState) {
        playerState = newState
        player.removeAction(forKey: playerAnimationKey)

        switch playerState {
        case .idle:
            startAnimationFrames(
                frames: playerIdleFrames,
                key: playerAnimationKey,
                character: player,
                loop: true
            )
        case .run:
            startAnimationFrames(
                frames: playerRunFrames,
                key: playerAnimationKey,
                character: player,
                loop: true
            )
        case .jump:
            startAnimationFrames(
                frames: playerJumpFrames,
                key: playerAnimationKey,
                character: player,
                loop: false
            )
        case .fall:
            startAnimationFrames(
                frames: playerFallFrames,
                key: playerAnimationKey,
                character: player,
                loop: false
            )
        case .attack1:
            startAnimationFrames(
                frames: playerAttack1Frames,
                key: playerAnimationKey,
                character: player,
                loop: false
            )
        case .attack2:
            startAnimationFrames(
                frames: playerAttack2Frames,
                key: playerAnimationKey,
                character: player,
                loop: false
            )

        case .dead: break
        }
    }

    func moveBotTowardPlayer() {
        let move = SKAction.moveTo(x: player.position.x + 60, duration: 1.0)
        bot.run(move)
    }

    func attackPlayer() {
        if bot.action(forKey: "attacking") == nil {
            let attack = SKAction.sequence([
                SKAction.run {
                    self.bot.texture = SKTexture(imageNamed: "bot_attack")
                },
                SKAction.wait(forDuration: 0.3),
                SKAction.run {
                    self.bot.texture = SKTexture(imageNamed: "bot_idle")
                },
            ])
            bot.run(attack, withKey: "attacking")

            if bot.frame.intersects(player.frame) {
                print("Player kena pukul bot!")
            }
        }
    }

    func playerHorizontalMove() {
        player.physicsBody?.velocity.dx = moveDirection * moveSpeed
    }

    func startAnimationFrames(
        frames: [SKTexture],
        key: String,
        character: SKSpriteNode,
        loop: Bool
    ) {
        let action = SKAction.animate(with: frames, timePerFrame: 0.1)
        character.run(
            loop ? SKAction.repeatForever(action) : action,
            withKey: key
        )
    }

    func playerJump() {
        if player.physicsBody?.velocity.dy != 0 { return }
        player.physicsBody?.velocity.dy = 0
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
        print("Player jump")
    }

    func playerAttack() {
        playerCanAttack = true
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.6,
            execute: {
                self.playerCanAttack = false
            }
        )
    }

}

#if os(iOS) || os(tvOS)
    // Touch-based event handling
    extension GameScene {

        override func touchesBegan(
            _ touches: Set<UITouch>,
            with event: UIEvent?
        ) {
            for touch in touches {
                let loc = touch.location(in: self)
                let node = atPoint(loc)

                if node.name == "left" {
                    moveDirection = -1
                    if !playerCanAttack {
                        player.xScale = -1 * characterScale
                    }
                } else if node.name == "right" {
                    moveDirection = 1
                    if !playerCanAttack {
                        player.xScale = 1 * characterScale
                    }
                }

                if node.name == "jump" {
                    playerJump()
                }

                if node.name == "attack" {
                    playerAttack()
                }
            }
        }

        override func touchesMoved(
            _ touches: Set<UITouch>,
            with event: UIEvent?
        ) {

        }

        override func touchesEnded(
            _ touches: Set<UITouch>,
            with event: UIEvent?
        ) {
            for touch in touches {
                let loc = touch.location(in: self)
                let node = atPoint(loc)
                if node.name == "left" || node.name == "right" {
                    moveDirection = 0
                }
            }
        }

        override func touchesCancelled(
            _ touches: Set<UITouch>,
            with event: UIEvent?
        ) {

        }

    }
#endif

#if os(macOS)
    // Mouse-based event handling
    extension GameScene {

        override func mouseDown(with event: NSEvent) {
        }

        override func mouseDragged(with event: NSEvent) {

        }

        override func mouseUp(with event: NSEvent) {

        }

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            self.pressedKeys.insert(event.keyCode)
            updateForKeyboard()
        }

        override func keyUp(with event: NSEvent) {
            self.pressedKeys.remove(event.keyCode)
            updateForKeyboard()
        }

        private func updateForKeyboard() {
            if pressedKeys.contains(KeyInput.a) {
                moveDirection = -1
                if !playerCanAttack {
                    player.xScale = -1 * characterScale
                }
            } else if pressedKeys.contains(KeyInput.d) {
                moveDirection = 1
                if !playerCanAttack {
                    player.xScale = 1 * characterScale
                }
            }

            if !pressedKeys.contains(KeyInput.a)
                && !pressedKeys.contains(KeyInput.d)
            {
                moveDirection = 0
            }

            if pressedKeys.contains(KeyInput.w) {
                playerJump()
            }

            if pressedKeys.contains(KeyInput.k) {
                playerAttack()
            }
        }

    }
#endif
