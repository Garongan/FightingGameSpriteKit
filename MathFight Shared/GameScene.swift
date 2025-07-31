//
//  GameScene.swift
//  MathFight Shared
//
//  Created by Alvindo Tri Jatmiko on 31/07/25.
//

import SpriteKit

class GameScene: SKScene {

    fileprivate var label: SKLabelNode?
    fileprivate var spinnyNode: SKShapeNode?

    var player: SKSpriteNode!
    var bot: SKSpriteNode!
    var playerIdleFrames: [SKTexture] = []

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
        backgroundColor = .white
        setupPlayerIdleFrames()
        setupCharacters()
        startPlayerIdleAnimation()

        setupMoveButtons()
    }

    override func update(_ currentTime: TimeInterval) {
        let distance = player.position.x - bot.position.x
        if abs(distance) < 100 {
            attackPlayer()
        } else {
            moveBotTowardPlayer()
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

    func movePlayer(point: CGPoint) {
        let moveAction = SKAction.moveBy(x: point.x, y: point.y, duration: 0.2)
        player.run(moveAction)
    }

    func attackBot() {
        let attackAction = SKAction.sequence([
            SKAction.run {
                self.player.texture = SKTexture(imageNamed: "player_attack")
            },
            SKAction.wait(forDuration: 0.2),
            SKAction.run {
                self.player.texture = SKTexture(imageNamed: "player_idle")
            },
        ])
        player.run(attackAction)

        checkHit()
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

    func setupCharacters() {
        player = SKSpriteNode(texture: playerIdleFrames.first)
        player.scale(to: CGSize(width: 500, height: 500))
        player.position = CGPoint(x: -size.width * 0.4, y: -size.height * 0.075)
        addChild(player)

        bot = SKSpriteNode(imageNamed: "bot_idle")
        bot.position = CGPoint(x: size.width * 0.4, y: -size.height * 0.075)
        addChild(bot)
    }

    func setupPlayerIdleFrames() {
        let atlas = SKTextureAtlas(named: "PlayerIdle")
        let sortedNames = atlas.textureNames.sorted()
        playerIdleFrames = sortedNames.map { atlas.textureNamed($0) }
    }

    func startPlayerIdleAnimation() {
        let action = SKAction.animate(with: playerIdleFrames, timePerFrame: 0.1)
        player.run(
            SKAction.repeatForever(action),
            withKey: "PLAYER_IDLE_ANIMATION"
        )
    }

    func setupMoveButtons() {
        buttonLeft.position = CGPoint(
            x: -size.width * 0.4,
            y: -size.height * 0.2
        )
        buttonLeft.name = "left"
        buttonLeft.scale(to: CGSize(width: 100, height: 100))
        addChild(buttonLeft)

        buttonRight.position = CGPoint(
            x: -size.width * 0.3,
            y: -size.height * 0.2
        )
        buttonRight.name = "right"
        buttonRight.scale(to: CGSize(width: 100, height: 100))
        addChild(buttonRight)
    }
}

#if os(iOS) || os(tvOS)
    // Touch-based event handling
    extension GameScene {

        override func touchesBegan(
            _ touches: Set<UITouch>,
            with event: UIEvent?
        ) {
            // Misalnya: jika sentuh sisi kiri, bergerak; sisi kanan = serang
            for touch in touches {
                let loc = touch.location(in: self)
                let node = atPoint(loc)
                if node.name == "left" {
                    movePlayer(point: CGPoint(x: -20, y: 0))
                }

                if node.name == "right" {
                    movePlayer(point: CGPoint(x: 20, y: 0))
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
