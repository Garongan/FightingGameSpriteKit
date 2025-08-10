//
//  PlayerAnimationSystem.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 08/08/25.
//

import Foundation
import GameplayKit

class PlayerAnimationSystem: GKComponent {

    override func update(deltaTime seconds: TimeInterval) {
        if !PlayerState.shared.isOnGround
            && PlayerState.shared.node.physicsBody!.velocity.dy < 0
            && PlayerState.shared.state != .fall
            && !PlayerState.shared.canAttack && !PlayerState.shared.isTakeHit
        {
            changePlayerState(to: .fall)
        } else if !PlayerState.shared.isOnGround
            && PlayerState.shared.node.physicsBody!.velocity.dy > 0
            && PlayerState.shared.state != .jump
            && !PlayerState.shared.canAttack && !PlayerState.shared.isTakeHit
        {
            changePlayerState(to: .jump)
        } else if PlayerState.shared.isOnGround
            && PlayerState.shared.state != .idle
            && PlayerState.shared.node.physicsBody!.velocity.dx == 0
            && !PlayerState.shared.canAttack
            && !PlayerState.shared.isTakeHit
        {
            changePlayerState(to: .idle)
        } else if PlayerState.shared.isOnGround
            && PlayerState.shared.state != .run
            && PlayerState.shared.node.physicsBody!.velocity.dx != 0
            && !PlayerState.shared.canAttack
            && !PlayerState.shared.isTakeHit
        {
            changePlayerState(to: .run)
        } else if PlayerState.shared.canAttack
            && PlayerState.shared.state != .attack1
            && !PlayerState.shared.isTakeHit
            && PlayerState.shared.randomAttackVersion == 1
        {
            changePlayerState(to: .attack1)
        } else if PlayerState.shared.canAttack
            && PlayerState.shared.state != .attack2
            && !PlayerState.shared.isTakeHit
            && PlayerState.shared.randomAttackVersion == 2
        {
            changePlayerState(to: .attack2)
        } else if PlayerState.shared.isTakeHit
            && PlayerState.shared.state != .takeHit
        {
            changePlayerState(to: .takeHit)
        }
    }

    func changePlayerState(to newState: CharacterState) {
        PlayerState.shared.state = newState
        PlayerState.shared.node.removeAction(forKey: playerAnimationKey)

        switch PlayerState.shared.state {
        case .idle:
            GameSceneSetup.shared.startAnimationFrames(
                frames: PlayerState.shared.idleFrames,
                key: playerAnimationKey,
                character: PlayerState.shared.node,
                loop: true
            )
        case .run:
            GameSceneSetup.shared.startAnimationFrames(
                frames: PlayerState.shared.runFrames,
                key: playerAnimationKey,
                character: PlayerState.shared.node,
                loop: true
            )
        case .jump:
            GameSceneSetup.shared.startAnimationFrames(
                frames: PlayerState.shared.jumpFrames,
                key: playerAnimationKey,
                character: PlayerState.shared.node,
                loop: false
            )
            PlayerState.shared.isJump = false
        case .fall:
            GameSceneSetup.shared.startAnimationFrames(
                frames: PlayerState.shared.fallFrames,
                key: playerAnimationKey,
                character: PlayerState.shared.node,
                loop: false
            )
        case .attack1:
            GameSceneSetup.shared.startAnimationFrames(
                frames: PlayerState.shared.attack1Frames,
                key: playerAnimationKey,
                character: PlayerState.shared.node,
                loop: false,
                timePerFrame: 0.01
            )
            PlayerState.shared.isAttack = false
        case .attack2:
            GameSceneSetup.shared.startAnimationFrames(
                frames: PlayerState.shared.attack2Frames,
                key: playerAnimationKey,
                character: PlayerState.shared.node,
                loop: false,
                timePerFrame: 0.01
            )
            PlayerState.shared.isAttack = false
        case .takeHit:
            GameSceneSetup.shared.startAnimationFrames(
                frames: PlayerState.shared.takeHitFrames,
                key: playerAnimationKey,
                character: PlayerState.shared.node,
                loop: false,
                timePerFrame: 0.01
            )
        case .dead: break
        }
    }
}
