//
//  GameScene.swift
//  MathFight Shared
//
//  Created by Alvindo Tri Jatmiko on 31/07/25.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var enemy: SKSpriteNode!
    var enemyRunFrames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "EnemyRun")
    }

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

    lazy var spawnerSystem = GKComponentSystem(
        componentClass: SpawnerComponent.self
    )
    lazy var enemyControlSystem = GKComponentSystem(
        componentClass: EnemyControlSystem.self
    )

    private var lastUpdateTime: TimeInterval?

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

        let enemySpawnerEntity = EnemySpawnerEntity(
            scene: self,
            interval: 1.0,
            controlSystem: enemyControlSystem
        )
        entities.append(enemySpawnerEntity)
        for system in [
            spawnerSystem, enemyControlSystem,
        ] {
            system.addComponent(foundIn: enemySpawnerEntity)
        }

        let healthPlusSpawnerEntity = HealthPlusSpawnerEntity(
            scene: self,
            interval: 5.0
        )
        entities.append(healthPlusSpawnerEntity)
        for system in [
            spawnerSystem
        ] {
            system.addComponent(foundIn: healthPlusSpawnerEntity)
        }

        GameSceneSetup.shared.setupLand(scene: self)
        GameSceneSetup.shared.setupBackground(scene: self)
        GameSceneSetup.shared.setupHpLabelNode(scene: self)

        #if os(iOS)
            GameSceneSetup.shared.setupButtons(scene: self)
        #endif

    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime

        [
            playerSpriteSystem, playerPhysicsSystem, playerControlSystem,
            playerAnimationSystem, spawnerSystem, enemyControlSystem,
        ].forEach {
            $0.update(deltaTime: deltaTime)
        }

        if PlayerState.shared.hp <= 0 {
            GameSceneSetup.shared.showGameOverOverlay(scene: self)
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
                PlayerState.shared.isTakeHit = true
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
            PlayerState.shared.hpLabelNode.text = "HP: \(PlayerState.shared.hp)"
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
                    PlayerState.shared.isJump = true
                }

                if node.name == "attack" {
                    PlayerState.shared.isAttack = true
                }
            }

            if GameState.shared.isGameOver {
                GameSceneSetup.shared.restartGame(scene: self)
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
                    PlayerState.shared.moveDirection = 0
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
            if GameState.shared.isGameOver {
                GameSceneSetup.shared.restartGame(scene: self)
            }
        }

        override func mouseDragged(with event: NSEvent) {

        }

        override func mouseUp(with event: NSEvent) {

        }

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            GameState.shared.pressedKeys.insert(event.keyCode)
            updateForKeyboard()
        }

        override func keyUp(with event: NSEvent) {
            GameState.shared.pressedKeys.remove(event.keyCode)
            updateForKeyboard()
        }

        private func updateForKeyboard() {
            if GameState.shared.pressedKeys.contains(KeyInput.a) {
                PlayerState.shared.moveDirection = -1
                PlayerState.shared.lastDirection = -1
            } else if GameState.shared.pressedKeys.contains(KeyInput.d) {
                PlayerState.shared.moveDirection = 1
                PlayerState.shared.lastDirection = 1
            }

            if !GameState.shared.pressedKeys.contains(KeyInput.a)
                && !GameState.shared.pressedKeys.contains(KeyInput.d)
            {
                PlayerState.shared.moveDirection = 0
            }

            if GameState.shared.pressedKeys.contains(KeyInput.j) {
                PlayerState.shared.isJump = true
            }

            if GameState.shared.pressedKeys.contains(KeyInput.k) {
                PlayerState.shared.isAttack = true
            }
        }

    }
#endif
