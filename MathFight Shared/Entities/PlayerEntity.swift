//
//  PlayerEntity.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 08/08/25.
//

import GameplayKit
import SpriteKit

class PlayerEntity: GKEntity {
    override init() {
        super.init()
        let texture = PlayerState.shared.idleFrames.first!
        addComponent(SpriteComponent(texture: texture))
        let body = SKPhysicsBody(
            texture: texture,
            size: CGSize(
                width: texture.size().width
                * characterScale,
                height: texture.size().height
                * characterScale
            )
        )
        addComponent(PhysicsComponent(body: body, category: PhysicsCategory.player,
                                      collision: PhysicsCategory.land,
                                      contact: PhysicsCategory.enemy | PhysicsCategory.land))
        
        addComponent(PlayerControlSystem())
        
        addComponent(PlayerAnimationSystem())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
