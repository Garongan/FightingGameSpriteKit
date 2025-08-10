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
        playerJump()
        playerAttack()
        handlePlayerTakeHit()
    }

    func playerHorizontalMove() {
        if PlayerState.shared.moveDirection != 0
            && !PlayerState.shared.canAttack
        {
            PlayerState.shared.node.xScale = CGFloat(
                PlayerState.shared.moveDirection
            )
        }
        PlayerState.shared.node.physicsBody?.velocity.dx =
            CGFloat(PlayerState.shared.moveDirection) * moveSpeed
    }

    func playerJump() {
        if !PlayerState.shared.isJump { return }

        let physicsBody = PlayerState.shared.node.physicsBody
        if physicsBody?.velocity.dy != 0 { return }
        physicsBody?.velocity.dy = 0
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
    }

    private func setupCharacterPhysicsBody(isAttackBody: Bool = false)
        -> SKPhysicsBody
    {
        var physicsBody: SKPhysicsBody
        if isAttackBody {
            let attackTexture = SKTexture(
                imageNamed:
                    "player_attack_\(PlayerState.shared.randomAttackVersion)_004\(PlayerState.shared.lastDirection == -1 ? "_left" : "")"
            )
            physicsBody = SKPhysicsBody(
                texture: attackTexture,
                size: CGSize(
                    width: attackTexture.size().width * characterScale,
                    height: attackTexture.size().height * characterScale
                )
            )
        } else {
            physicsBody = SKPhysicsBody(
                texture: PlayerState.shared.idleFrames.first!,
                size: CGSize(
                    width: PlayerState.shared.idleFrames.first!.size().width
                        * characterScale,
                    height: PlayerState.shared.idleFrames.first!.size().height
                        * characterScale
                )
            )
        }
        physicsBody.categoryBitMask = PhysicsCategory.player
        physicsBody.collisionBitMask =
            PhysicsCategory.land | PhysicsCategory.enemy
        physicsBody.contactTestBitMask =
            PhysicsCategory.land | PhysicsCategory.enemy
            | PhysicsCategory.healthPlus
        physicsBody.allowsRotation = false
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = true
        return physicsBody
    }

    func playerAttack() {
        if !PlayerState.shared.isAttack { return }

        PlayerState.shared.canAttack = true
        PlayerState.shared.randomAttackVersion =
            PlayerState.shared.randomAttackVersion == 1 ? 2 : 1
        PlayerState.shared.node.physicsBody = self.setupCharacterPhysicsBody(
            isAttackBody: true
        )
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.1,
            execute: {
                PlayerState.shared.canAttack = false
                PlayerState.shared.node.physicsBody =
                    self.setupCharacterPhysicsBody()
            }
        )
    }
    
    func handlePlayerTakeHit() {
        if !PlayerState.shared.isTakeHit { return }
        
        HapticManager.shared.playHaptic()
        PlayerState.shared.hp -= 1
        PlayerState.shared.hpLabelNode.text = "HP: \(PlayerState.shared.hp)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            PlayerState.shared.isTakeHit = false
        }
    }
}
