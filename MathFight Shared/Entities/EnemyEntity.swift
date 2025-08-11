//
//  EnemyEntity.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import GameplayKit
import SpriteKit

class EnemyEntity: GKEntity {
    init(textureFrames: [SKTexture], spriteName: String) {
        super.init()
        let texture = textureFrames.first!
        let spriteComponent = SpriteComponent(texture: texture)
        spriteComponent.node.name = spriteName
        addComponent(spriteComponent)

        let body = SKPhysicsBody(circleOfRadius: texture.size().width)
        addComponent(
            PhysicsComponent(
                body: body,
                category: PhysicsCategory.enemy,
                collision: PhysicsCategory.player | PhysicsCategory.land,
                contact: PhysicsCategory.player
            )
        )

        spriteComponent.node.run(
            SKAction.repeatForever(
                SKAction.animate(
                    with: textureFrames,
                    timePerFrame: 0.1
                )
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
