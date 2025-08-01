//
//  GameScene.swift
//  MathFight Shared
//
//  Created by Alvindo Tri Jatmiko on 31/07/25.
//

import SpriteKit

struct PhysicsCategory {
    static let player: UInt32 = 1 << 0  // 0001
    static let land:   UInt32 = 1 << 1  // 0010
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    fileprivate var label: SKLabelNode?
    fileprivate var spinnyNode: SKShapeNode?

    var player: SKSpriteNode!
    var bot: SKSpriteNode!
    var playerIdleFrames: [SKTexture] = []
    var playerAttack1Frames: [SKTexture] = []
    var moveDirection: CGFloat = 0.0
    let moveSpeed: CGFloat = 500.0

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
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        setupPlayerIdleFrames()
        setupPlayerAttackFrames()
        setupCharacters()
        startPlayerIdleAnimation()
        setupButtons()
        setupLand()
    }

    override func update(_ currentTime: TimeInterval) {
        let distance = player.position.x - bot.position.x
        if abs(distance) < 100 {
            attackPlayer()
        } else {
            moveBotTowardPlayer()
        }
        
        playerHorizontalMove()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collisionWithLand = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collisionWithLand == PhysicsCategory.player | PhysicsCategory.land {
            print("Player kena lantai!")
        }
    }

    // MARK: -setup start
    
    func setupCharacters() {
        player = SKSpriteNode(texture: playerIdleFrames.first)
        player.scale(to: CGSize(width: 500, height: 500))
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.land
        player.physicsBody?.contactTestBitMask = PhysicsCategory.land
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.affectedByGravity = true
        player.zPosition = 1
        addChild(player)

        bot = SKSpriteNode(imageNamed: "bot_idle")
        bot.position = CGPoint(x: size.width * 0.4, y: -size.height * 0.075)
        bot.zPosition = 1
        addChild(bot)
    }

    func setupPlayerIdleFrames() {
        let atlas = SKTextureAtlas(named: "PlayerIdle")
        let sortedNames = atlas.textureNames.sorted()
        playerIdleFrames = sortedNames.map { atlas.textureNamed($0) }
    }
    
    func setupPlayerAttackFrames() {
        let atlas = SKTextureAtlas(named: "PlayerAttack1")
        let sortedNames = atlas.textureNames.sorted()
        playerAttack1Frames = sortedNames.map { atlas.textureNamed($0) }
    }
    
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
        
        buttonAttack.position = CGPoint(x: size.width * 0.3, y: -size.height * 0.2)
        buttonAttack.name = "attack"
        buttonAttack.scale(to: CGSize(width: 100, height: 100))
        buttonAttack.zPosition = 2
        addChild(buttonAttack)
        
        buttonJump.position = CGPoint(x: size.width * 0.4, y: -size.height * 0.2)
        buttonJump.name = "jump"
        buttonJump.scale(to: CGSize(width: 100, height: 100))
        buttonJump.zPosition = 2
        addChild(buttonJump)
    }
    
    func setupLand() {
        let landTexture = SKTexture(imageNamed: "land_0002")
        let landWidth = 100.0
        let landCount = Int(ceil(size.width / landWidth)) + 1
        
        let earthTexture = SKTexture(imageNamed: "land_0004")
        let earthWidth: CGFloat = 100.0
        
        var landContainerWidth: CGFloat = 0
        
        for i in 0..<landCount {
            let land = SKSpriteNode(texture: landTexture)
            let earth = SKSpriteNode(texture: earthTexture)
            earth.position = CGPoint(
                x: CGFloat(i) * earthWidth - size.width * 0.5,
                y: -size.height * 0.31 + earthWidth * 0.5
            )
            earth.scale(to: CGSize(width: 100, height: 100))
            earth.zPosition = 1
            addChild(earth)
            
            land.position = CGPoint(
                x: CGFloat(i) * landWidth - size.width * 0.5,
                y: -size.height * 0.23 + landWidth * 0.5
            )
            landContainerWidth += landWidth
            land.scale(to: CGSize(width: 100, height: 100))
            land.zPosition = 0
            addChild(land)
        }
        
        let landPhysicsBody = SKPhysicsBody(rectangleOf: CGSize(width: landContainerWidth, height: 100))
        landPhysicsBody.isDynamic = false
        landPhysicsBody.categoryBitMask = PhysicsCategory.land
        landPhysicsBody.collisionBitMask = PhysicsCategory.player
        landPhysicsBody.contactTestBitMask = PhysicsCategory.player
        let landContainer = SKNode()
        landContainer.physicsBody = landPhysicsBody
        landContainer.position = CGPoint(x: 0, y: -size.height * 0.23 + landWidth * 0.5)
        addChild(landContainer)
    }
    
    // MARK: -setup end
    
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
    
    func checkHit() {
        if player.frame.intersects(bot.frame) {
            print("Bot kena pukul!")
            botHit()
        }
    }
    
    func botHit() {
        // Kurangi health, animasi kena pukul, dll
    }

    func startPlayerIdleAnimation() {
        let action = SKAction.animate(with: playerIdleFrames, timePerFrame: 0.1)
        player.run(
            SKAction.repeatForever(action),
            withKey: "PLAYER_IDLE_ANIMATION"
        )
    }
    
    func playerJump() {
        if player.physicsBody?.velocity.dy != 0 { return }
        player.physicsBody?.velocity.dy = 0
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
    }
    
    func playerAttack() {
        let action = SKAction.animate(with: playerAttack1Frames, timePerFrame: 0.1)
        player.run(action, withKey: "PLAYER_ATTACK1_ANIMATION")
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
                } else if node.name == "right" {
                    moveDirection = 1
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

#if os(OSX)
    // Mouse-based event handling
    extension GameScene {

        override func mouseDown(with event: NSEvent) {
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
            self.makeSpinny(at: event.location(in: self), color: SKColor.green)
        }

        override func mouseDragged(with event: NSEvent) {
            self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
        }

        override func mouseUp(with event: NSEvent) {
            self.makeSpinny(at: event.location(in: self), color: SKColor.red)
        }

    }
#endif
