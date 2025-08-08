//
//  GameScene.swift
//  MathFight Shared
//
//  Created by Alvindo Tri Jatmiko on 31/07/25.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var pressedKeys = Set<UInt16>()

    var enemy: SKSpriteNode!
    var enemyRunFrames: [SKTexture] {
        setupAnimationFrames(name: "EnemyRun")
    }

    var hpLabelNode: SKLabelNode!
    var isGameOver: Bool = false

    var entities = [GKEntity]()
    lazy var playerSpriteSystem = GKComponentSystem(
        componentClass: SpriteComponent.self
    )
    lazy var playerPhysicsSystem = GKComponentSystem(
        componentClass: PhysicsComponent.self
    )
    lazy var playerControlSystem = GKComponentSystem(
        componentClass: PlayerControlSystem.self
    )
    lazy var playerAnimationSystem = GKComponentSystem(
        componentClass: PlayerAnimationSystem.self
    )

    private var lastUpdateTime: TimeInterval?

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

    override func didMove(to view: SKView) {
        #if os(macOS)
            view.window?.makeFirstResponder(self)
        #endif

        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        //        setupCharacters()

        let player = PlayerEntity()
        entities.append(player)
        for system in [
            playerSpriteSystem, playerPhysicsSystem, playerControlSystem,
            playerAnimationSystem,
        ] {
            system.addComponent(foundIn: player)
        }
        PlayerState.shared.node =
            player.component(ofType: SpriteComponent.self)!.node
        addChild(PlayerState.shared.node)

        setupLand()
        setupBackground()

        #if os(iOS)
            setupButtons()
        #endif

        setupEnemy()
        setupHealthPlus()

        hpLabelNode = SKLabelNode(fontNamed: "PixeloidSans-Bold")
        hpLabelNode.fontSize = 54
        #if os(iOS)
            hpLabelNode.position = CGPoint(
                x: -size.width * 0.44,
                y: size.height * 0.2
            )
        #elseif os(macOS)
            hpLabelNode.position = CGPoint(
                x: -size.width * 0.4,
                y: size.height * 0.4
            )
        #endif
        hpLabelNode.text = "HP: \(PlayerState.shared.hp)"
        hpLabelNode.horizontalAlignmentMode = .left
        addChild(hpLabelNode)
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime

        [
            playerSpriteSystem, playerPhysicsSystem, playerControlSystem,
            playerAnimationSystem,
        ].forEach {
            $0.update(deltaTime: deltaTime)
        }
        
        enumerateChildNodes(withName: "enemy") { node, _ in
            let dx = PlayerState.shared.node.position.x - node.position.x
            let dy = PlayerState.shared.node.position.y - node.position.y
            let angle = atan2(dy, dx)

            let vx = cos(angle) * enemySpeed
            let vy = sin(angle) * enemySpeed

            if let body = node.physicsBody {
                body.velocity = CGVector(dx: vx, dy: vy)
            } else {
                node.position.x += vx
                node.position.y += vy
            }
        }

        if PlayerState.shared.hp <= 0 {
            showGameOverOverlay()
        }

    }

    func didBegin(_ contact: SKPhysicsContact) {
        let combo =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if combo == PhysicsCategory.player | PhysicsCategory.land {
            PlayerState.shared.isOnGround = true
        }

        if combo == PhysicsCategory.land | PhysicsCategory.enemy {
            print("player kena land")
        }

        if combo == PhysicsCategory.player | PhysicsCategory.enemy {
            var enemyNode: SKNode?
            if contact.bodyA.node?.name == "enemy" {
                enemyNode = contact.bodyA.node
            } else if contact.bodyB.node?.name == "enemy" {
                enemyNode = contact.bodyB.node
            }

            guard let enemyPosition = enemyNode?.position else { return }

            if PlayerState.shared.canAttack
                && ((PlayerState.shared.node.xScale > 0
                    && enemyPosition.x > PlayerState.shared.node.position.x)
                    || (PlayerState.shared.node.xScale < 0
                        && enemyPosition.x < PlayerState.shared.node.position.x))
            {
                enemyNode?.run(
                    SKAction.sequence(
                        [
                            .colorize(
                                with: .red,
                                colorBlendFactor: 1.0,
                                duration: 0.15
                            ), .wait(forDuration: 0.15), .removeFromParent(),
                        ]
                    )
                )
            } else {
                handlePlayerTakeHit()
            }
        }

        if combo == PhysicsCategory.land | PhysicsCategory.healthPlus {
            enumerateChildNodes(withName: "healthPlus") { node, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    node.removeFromParent()
                }
            }
        }

        if combo == PhysicsCategory.player | PhysicsCategory.healthPlus {
            var healthPlusNode: SKNode?
            if contact.bodyA.node?.name == "healthPlus" {
                healthPlusNode = contact.bodyA.node
            } else if contact.bodyB.node?.name == "healthPlus" {
                healthPlusNode = contact.bodyB.node
            }
            healthPlusNode?.removeFromParent()
            PlayerState.shared.hp += 10
            hpLabelNode.text = "HP: \(PlayerState.shared.hp)"
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let combo =
            contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if combo == PhysicsCategory.player | PhysicsCategory.land {
            PlayerState.shared.isOnGround = false
        }
    }

    override func willMove(from view: SKView) {
        self.removeAllActions()
        self.removeAllChildren()
        physicsWorld.contactDelegate = nil
    }

    // MARK: -setup start

    func setupCharacterPhysicsBody(isAttackBody: Bool = false)
        -> SKPhysicsBody
    {
        var physicsBody: SKPhysicsBody
        if isAttackBody {
            let attackTexture = SKTexture(
                imageNamed:
                    "player_attack_\(PlayerState.shared.randomAttackVersion)_004\(PlayerState.shared.lastDirection == -1 ? "_left" : "")"
            )
            physicsBody = SKPhysicsBody(
                texture: attackTexture,
                size: CGSize(
                    width: attackTexture.size().width * characterScale,
                    height: attackTexture.size().height * characterScale
                )
            )
        } else {
            physicsBody = SKPhysicsBody(
                texture: PlayerState.shared.idleFrames.first!,
                size: CGSize(
                    width: PlayerState.shared.idleFrames.first!.size().width
                        * characterScale,
                    height: PlayerState.shared.idleFrames.first!.size().height
                        * characterScale
                )
            )
        }
        physicsBody.categoryBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask =
            PhysicsCategory.land | PhysicsCategory.enemy
        physicsBody.contactTestBitMask =
            PhysicsCategory.land | PhysicsCategory.enemy
            | PhysicsCategory.healthPlus
        physicsBody.allowsRotation = false
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = true
        return physicsBody
    }

    func setupAnimationFrames(name: String) -> [SKTexture] {
        let atlas = SKTextureAtlas(named: name)
        let sortedNames = atlas.textureNames.sorted()
        return sortedNames.map { atlas.textureNamed($0) }
    }

    func setupEnemy() {
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

    func setupHealthPlus() {
        let healthPlusGenerator = SKNode()
        addChild(healthPlusGenerator)

        let wait = SKAction.wait(forDuration: 2.0, withRange: 1.5)
        let spawn = SKAction.run { [weak self] in
            self?.spawnHealthPlus()
        }
        healthPlusGenerator.run(
            SKAction.repeatForever(SKAction.sequence([wait, spawn]))
        )
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
        let bgCount = Int(ceil(size.width / 200)) + 1

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

        for j in 0..<2 {
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
                newNode.position.x += CGFloat(i * 200)
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
        let landContainer = SKNode()
        landContainer.physicsBody = landPhysicsBody
        landContainer.position = CGPoint(
            x: 0,
            y: -size.height * verticalOffsetFraction - 20
        )
        addChild(landContainer)
    }

    // MARK: -setup end

    func playerJump() {
        let physicsBody = PlayerState.shared.node.physicsBody
        if physicsBody?.velocity.dy != 0 { return }
        physicsBody?.velocity.dy = 0
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
    }

    func playerAttack() {
        PlayerState.shared.canAttack = true
        PlayerState.shared.randomAttackVersion =
            PlayerState.shared.randomAttackVersion == 1 ? 2 : 1
        PlayerState.shared.node.physicsBody = setupCharacterPhysicsBody(
            isAttackBody: true
        )
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.1,
            execute: {
                PlayerState.shared.canAttack = false
                PlayerState.shared.node.physicsBody =
                    self.setupCharacterPhysicsBody()
            }
        )
    }

    func handlePlayerTakeHit() {
        PlayerState.shared.isTakeHit = true
        PlayerState.shared.hp -= 1
        hpLabelNode.text = "HP: \(PlayerState.shared.hp)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            PlayerState.shared.isTakeHit = false
        }
    }

    func spawnEnemy() {
        let enemy = SKSpriteNode(texture: enemyRunFrames.first)
        enemy.name = "enemy"
        enemy.setScale(characterScale)

        let physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false
        physicsBody.affectedByGravity = true
        physicsBody.categoryBitMask = PhysicsCategory.enemy
        physicsBody.collisionBitMask = PhysicsCategory.player
        physicsBody.contactTestBitMask = PhysicsCategory.player
        enemy.physicsBody = physicsBody

        let x = Int.random(in: -Int(size.width)..<Int(size.width))
        let y = Int(size.height) + Int(enemy.size.height)
        enemy.position = CGPoint(x: x, y: y)
        enemy.zPosition = 1

        enemy.run(
            SKAction.repeatForever(
                SKAction.animate(with: enemyRunFrames, timePerFrame: 0.1)
            )
        )
        addChild(enemy)
    }

    func spawnHealthPlus() {
        let healthPlus = SKSpriteNode(imageNamed: "health_plus")
        healthPlus.name = "healthPlus"
        healthPlus.setScale(characterScale)

        let physicsBody = SKPhysicsBody(
            circleOfRadius: healthPlus.size.width / 2
        )
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false
        physicsBody.affectedByGravity = true
        physicsBody.categoryBitMask = PhysicsCategory.healthPlus
        physicsBody.collisionBitMask =
            PhysicsCategory.player | PhysicsCategory.land
        physicsBody.contactTestBitMask =
            PhysicsCategory.player | PhysicsCategory.land
        healthPlus.physicsBody = physicsBody

        let x = Int.random(in: -Int(size.width)..<Int(size.width))
        let y = Int(size.height) + Int(healthPlus.size.height)
        healthPlus.position = CGPoint(x: x, y: y)
        healthPlus.zPosition = 1

        addChild(healthPlus)
    }

    func showGameOverOverlay() {
        // 1. Block input & physics
        isPaused = true

        // 2. Buat overlay node
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.alpha = 0.7
        overlay.zPosition = 10
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.name = "GameOverOverlay"
        addChild(overlay)

        // 3. Tambahkan label Game Over
        let label = SKLabelNode(fontNamed: "PixeloidSans-Bold")
        label.text = "Game Over"
        label.fontSize = 64
        label.position = .zero
        label.zPosition = 11
        overlay.addChild(label)

        // 4. Tambahkan tombol Restart jika mau
        let restart = SKLabelNode(fontNamed: "PixeloidSans-Bold")
        restart.text = "Tap to Restart"
        restart.fontSize = 32
        restart.position = CGPoint(x: 0, y: -100)
        restart.name = "Restart"
        restart.zPosition = 11
        overlay.addChild(restart)

        isGameOver = true
    }

    func restartGame() {
        isGameOver = false
        isPaused = false

        let gameScene = GameScene.newGameScene()
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
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
                    PlayerState.shared.moveDirection = -1
                    PlayerState.shared.lastDirection = -1
                } else if node.name == "right" {
                    PlayerState.shared.moveDirection = 1
                    PlayerState.shared.lastDirection = 1
                }

                if node.name == "jump" {
                    playerJump()
                }

                if node.name == "attack" {
                    playerAttack()
                }
            }

            if isGameOver {
                restartGame()
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
            if isGameOver {
                restartGame()
            }
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
                PlayerState.shared.moveDirection = -1
                PlayerState.shared.lastDirection = -1
            } else if pressedKeys.contains(KeyInput.d) {
                PlayerState.shared.moveDirection = 1
                PlayerState.shared.lastDirection = 1
            }

            if !pressedKeys.contains(KeyInput.a)
                && !pressedKeys.contains(KeyInput.d)
            {
                PlayerState.shared.moveDirection = 0
            }

            if pressedKeys.contains(KeyInput.j) {
                playerJump()
            }

            if pressedKeys.contains(KeyInput.k) {
                playerAttack()
            }
        }

    }
#endif
