//
//  GameSceneSetup.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 08/08/25.
//

import Foundation
import SpriteKit

class GameSceneSetup {
    static let shared = GameSceneSetup()
    private init() {}

    #if os(iOS)
        private let buttonLeft = SKSpriteNode(
            texture: SKTexture(
                image: UIImage(systemName: "arrow.left.circle")!
            )
        )

        private let buttonRight = SKSpriteNode(
            texture: SKTexture(
                image: UIImage(systemName: "arrow.right.circle")!
            )
        )

        private let buttonJump = SKSpriteNode(
            texture: SKTexture(
                image: UIImage(systemName: "arrow.up.circle")!
            )
        )

        private let buttonAttack = SKSpriteNode(
            texture: SKTexture(
                image: UIImage(systemName: "hand.thumbsup.circle")!
            )
        )

        func setupButtons(scene: SKScene) {
            let size = scene.size
            buttonLeft.position = CGPoint(
                x: -size.width * 0.4,
                y: -size.height * 0.2
            )
            buttonLeft.name = "left"
            buttonLeft.scale(to: CGSize(width: 100, height: 100))
            buttonLeft.zPosition = 2
            scene.addChild(buttonLeft)

            buttonRight.position = CGPoint(
                x: -size.width * 0.3,
                y: -size.height * 0.2
            )
            buttonRight.name = "right"
            buttonRight.scale(to: CGSize(width: 100, height: 100))
            buttonRight.zPosition = 2
            scene.addChild(buttonRight)

            buttonAttack.position = CGPoint(
                x: size.width * 0.3,
                y: -size.height * 0.2
            )
            buttonAttack.name = "attack"
            buttonAttack.scale(to: CGSize(width: 100, height: 100))
            buttonAttack.zPosition = 2
            scene.addChild(buttonAttack)

            buttonJump.position = CGPoint(
                x: size.width * 0.4,
                y: -size.height * 0.2
            )
            buttonJump.name = "jump"
            buttonJump.scale(to: CGSize(width: 100, height: 100))
            buttonJump.zPosition = 2
            scene.addChild(buttonJump)
        }
    #endif

    func setupAnimationFrames(name: String) -> [SKTexture] {
        let atlas = SKTextureAtlas(named: name)
        let sortedNames = atlas.textureNames.sorted()
        return sortedNames.map { atlas.textureNamed($0) }
    }

    func startAnimationFrames(
        frames: [SKTexture],
        key: String,
        character: SKSpriteNode,
        loop: Bool,
        timePerFrame: TimeInterval = 0.1
    ) {
        let action = SKAction.animate(with: frames, timePerFrame: timePerFrame)
        character.run(
            loop ? SKAction.repeatForever(action) : action,
            withKey: key
        )
    }

    func setupBackground(scene: SKScene) {
        let size = scene.size
        
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
        scene.addChild(upNode)

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
        scene.addChild(botNode)

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
                scene.addChild(newNode)
            }
        }
    }

    func setupLand(scene: SKScene) {
        let size = scene.size
        
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

            scene.addChild(earth)
            scene.addChild(land)
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
        scene.addChild(landContainer)
    }

    func setupHpLabelNode(scene: SKScene) {
        let size = scene.size
        PlayerState.shared.hpLabelNode = SKLabelNode(
            fontNamed: "PixeloidSans-Bold"
        )
        PlayerState.shared.hpLabelNode.fontSize = 54
        #if os(iOS)
            PlayerState.shared.hpLabelNode.position = CGPoint(
                x: -size.width * 0.44,
                y: size.height * 0.2
            )
        #elseif os(macOS)
            PlayerState.shared.hpLabelNode.position = CGPoint(
                x: -size.width * 0.44,
                y: size.height * 0.35
            )
        #endif
        PlayerState.shared.hpLabelNode.text = "HP: \(PlayerState.shared.hp)"
        PlayerState.shared.hpLabelNode.horizontalAlignmentMode = .left
        scene.addChild(PlayerState.shared.hpLabelNode)
    }

    func showGameOverOverlay(scene: SKScene) {
        scene.isPaused = true
        let size = scene.size

        // 2. Buat overlay node
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.alpha = 0.7
        overlay.zPosition = 10
        overlay.name = "GameOverOverlay"
        scene.addChild(overlay)

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

        GameState.shared.isGameOver = true
    }

    func restartGame(scene: SKScene) {
        PlayerState.shared.hp = 100
        GameState.shared.isGameOver = false
        scene.isPaused = false

        let gameScene = GameScene.newGameScene()
        let transition = SKTransition.fade(withDuration: 0.5)
        scene.view?.presentScene(gameScene, transition: transition)
    }
}
