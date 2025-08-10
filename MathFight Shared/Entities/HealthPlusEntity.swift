//
//  HealthPlusEntity.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import GameplayKit
import SpriteKit

class HealthPlusEntity: GKEntity {
    override init() {
        super.init()
        let texture = SKTexture(imageNamed: "health_plus")
        let spriteComponent = SpriteComponent(texture: texture)
        spriteComponent.node.name = "healthPlus"
        
        addComponent(spriteComponent)
        
        let body = SKPhysicsBody(circleOfRadius: texture.size().width)
        
        addComponent(
            PhysicsComponent(
                body: body,
                category: PhysicsCategory.healthPlus,
                collision: PhysicsCategory.player | PhysicsCategory.land,
                contact: PhysicsCategory.player | PhysicsCategory.land
            )
        )
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
