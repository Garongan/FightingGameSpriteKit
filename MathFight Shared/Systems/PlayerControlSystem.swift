//
//  PlayerControlSystem.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 08/08/25.
//

import GameplayKit

class PlayerControlSystem: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        playerHorizontalMove()
    }
    
    func playerHorizontalMove() {
        if PlayerState.shared.moveDirection != 0 && !PlayerState.shared.canAttack {
            PlayerState.shared.node.xScale = CGFloat(PlayerState.shared.moveDirection)
        }
        PlayerState.shared.node.physicsBody?.velocity.dx = CGFloat(PlayerState.shared.moveDirection) * moveSpeed
    }
}
