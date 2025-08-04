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
    static let enemy: UInt32 = 1 << 2
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

    var enemy: SKSpriteNode!
    var enemyRunFrames: [SKTexture] {
        setupAnimationFrames(name: "EnemyRun")
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
        setupBackground()

        #if os(iOS)
            setupButtons()
        #endif

        let enemyGenerator = SKNode()
        addChild(enemyGenerator)

        let wait = SKAction.wait(forDuration: 1.0, withRange: 0.5)
        let spawn = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        enemyGenerator.run(
            SKAction.repeatForever(SKAction.sequence([wait, spawn]))
        )
    }

    override func update(_ currentTime: TimeInterval) {
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
        }

        if combo == PhysicsCategory.land | PhysicsCategory.enemy {
            enumerateChildNodes(withName: "enemy") { node, _ in
                if node.position.y < -node.frame.height {
                    node.removeFromParent()
                }
            }
        }

        if combo == PhysicsCategory.player | PhysicsCategory.enemy {
            print("player kena enemy")
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let combo =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if combo == PhysicsCategory.player | PhysicsCategory.land {
            playerIsOnGround = false
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

    func setupBackground() {
        var midSpriteNodes: [SKSpriteNode] = []
        let bgCount = Int(ceil(size.width / 400)) + 1

        #if os(iOS)
            let verticalOffsetFraction: CGFloat = 0.3
            let verticalHeightDistance: CGFloat = 50
        #elseif os(macOS)
            let verticalOffsetFraction: CGFloat = 0.46
            let verticalHeightDistance: CGFloat = 100
        #endif

        let up = SKTexture(imageNamed: "bg_v1_up")
        let upNode = SKSpriteNode(texture: up)
        upNode.scale(
            to: CGSize(width: size.width, height: verticalHeightDistance * 6)
        )
        upNode.position = CGPoint(
            x: 0,
            y: size.height * verticalOffsetFraction
                + (verticalHeightDistance * 0.5)
        )
        upNode.zPosition = -1
        upNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        addChild(upNode)

        let bot = SKTexture(imageNamed: "bg_v1_bot")
        let botNode = SKSpriteNode(texture: bot)
        botNode.scale(
            to: CGSize(width: size.width, height: verticalHeightDistance * 3)
        )
        botNode.position = CGPoint(
            x: 0,
            y: size.height * verticalOffsetFraction
                - (verticalHeightDistance * 6)
        )
        botNode.zPosition = -1
        botNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        addChild(botNode)

        for j in 0..<4 {
            let mid = SKTexture(imageNamed: "bg_v1_mid_000\(j)")

            let midNode = SKSpriteNode(texture: mid)
            midNode.position = CGPoint(
                x: CGFloat(j) * 100 - size.width * 0.5,
                y: size.height * verticalOffsetFraction
                    - (verticalHeightDistance * 6)
            )
            midNode.scale(to: CGSize(width: 100, height: 100))
            midNode.zPosition = 0

            midSpriteNodes.append(midNode)
        }

        for i in 0..<bgCount {
            for node in midSpriteNodes {
                let newNode = node.copy() as! SKSpriteNode
                newNode.position.x += CGFloat(i * 400)
                addChild(newNode)
            }
        }
    }

    func setupLand() {
        let landTexture = SKTexture(imageNamed: "land_0002")
        let landCount = Int(ceil(size.width / 100)) + 1

        let earthTexture = SKTexture(imageNamed: "land_0004")

        #if os(iOS)
            let verticalOffsetFraction: CGFloat = 0.19
        #elseif os(macOS)
            let verticalOffsetFraction: CGFloat = 0.4
        #endif

        var landContainerWidth: CGFloat = 0

        for i in 0..<landCount {
            let land = SKSpriteNode(texture: landTexture)
            let earth = SKSpriteNode(texture: earthTexture)

            land.position = CGPoint(
                x: CGFloat(i) * 100 - size.width * 0.5,
                y: -size.height * verticalOffsetFraction
            )
            landContainerWidth += 100
            land.scale(to: CGSize(width: 100, height: 100))
            land.zPosition = 0

            earth.position = CGPoint(
                x: CGFloat(i) * 100 - size.width * 0.5,
                y: -size.height * verticalOffsetFraction - 85
            )
            earth.scale(to: CGSize(width: 100, height: 100))
            earth.zPosition = 1

            addChild(earth)
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
            y: -size.height * verticalOffsetFraction - 20
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

    func spawnEnemy() {
        let enemy = SKSpriteNode(texture: enemyRunFrames.first)
        enemy.name = "enemy"
        enemy.setScale(3)

        let physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false
        physicsBody.affectedByGravity = true
        physicsBody.categoryBitMask = PhysicsCategory.enemy
        physicsBody.collisionBitMask = PhysicsCategory.land
        physicsBody.contactTestBitMask =
            PhysicsCategory.player | PhysicsCategory.land
        enemy.physicsBody = physicsBody

        let x = Int.random(in: 0..<Int(size.width))
        let y = Int(size.height) + Int(enemy.size.height)
        enemy.position = CGPoint(x: x, y: y)
        enemy.zPosition = 1

        addChild(enemy)

        let move = SKAction.moveBy(
            x: 0,
            y: -size.height - enemy.size.height * 2,
            duration: size.height / 10
        )
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([move, remove]))
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
