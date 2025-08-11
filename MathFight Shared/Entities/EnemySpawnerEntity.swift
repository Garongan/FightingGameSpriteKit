//
//  EnemySpawnerEntity.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import GameplayKit

class EnemySpawnerEntity: GKEntity, SpawnerEntity {
    let spawner: SpawnerComponent
    let scene: SKScene
    let isFlying: Bool
    let textureFrames: [SKTexture]
    let spriteName: String

    init(
        scene: SKScene,
        interval: TimeInterval,
        isFlying: Bool,
        textureFrames: [SKTexture],
        spriteName: String
    ) {
        self.spawner = SpawnerComponent(spawnInterval: interval)
        self.scene = scene
        self.isFlying = isFlying
        self.textureFrames = textureFrames
        self.spriteName = spriteName
        super.init()
        addComponent(spawner)
        addComponent(EnemyControlSystem(scene: scene))
    }

    required init?(coder: NSCoder) { fatalError() }

    func spawnEnemy() {
        let enemy = EnemyEntity(
            textureFrames: textureFrames,
            spriteName: spriteName
        )

        var newXPosition: CGFloat = .zero
        
        if isFlying {
            newXPosition = CGFloat.random(
                in: -scene.size.width...scene.size.width
            )
        } else {
            let randomLeftRightEdge: CGFloat = CGFloat.random(in: 0...1)
            newXPosition =
                randomLeftRightEdge < 0.5
                ? -scene.size.width / 2
                : scene.size.width / 2
        }

        if let spriteNode = enemy.component(ofType: SpriteComponent.self)?.node
        {
            let x = newXPosition
            let y =
                isFlying
                ? scene.size.height + spriteNode.frame.height
                : -scene.size.height * verticalOffsetFraction
            spriteNode.position = CGPoint(x: x, y: y)
            scene.addChild(spriteNode)
        }
    }
}
