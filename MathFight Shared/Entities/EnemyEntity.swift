//
//  EnemyEntity.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import GameplayKit
import SpriteKit

class EnemyEntity: GKEntity {
    override init() {
        super.init()
        let texture = EnemyState.shared.enemyRunFrames.first!
        let spriteComponent = SpriteComponent(texture: texture)
        spriteComponent.node.name = "enemy"
        addComponent(spriteComponent)

        let body = SKPhysicsBody(circleOfRadius: texture.size().width)
        addComponent(
            PhysicsComponent(
                body: body,
                category: PhysicsCategory.enemy,
                collision: PhysicsCategory.player,
                contact: PhysicsCategory.player
            )
        )

        spriteComponent.node.run(
            SKAction.repeatForever(
                SKAction.animate(
                    with: EnemyState.shared.enemyRunFrames,
                    timePerFrame: 0.1
                )
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
