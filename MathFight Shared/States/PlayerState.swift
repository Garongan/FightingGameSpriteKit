//
//  PlayerState.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 08/08/25.
//

import Foundation
import SpriteKit

class PlayerState {
    static let shared = PlayerState()
    private init() {}
    
    var node = SKSpriteNode()
    var state: CharacterState = .idle
    var isOnGround: Bool = false
    var canAttack: Bool = false
    var idleFrames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "PlayerIdle")
    }
    var attack1Frames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "PlayerAttack1")
    }
    var attack2Frames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "PlayerAttack2")
    }
    var jumpFrames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "PlayerJump")
    }
    var fallFrames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "PlayerFall")
    }
    var runFrames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "PlayerRun")
    }
    var takeHitFrames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "PlayerTakeHit")
    }
    var moveDirection: Int = 0
    var randomAttackVersion: Int = 1
    var lastDirection: Int = 1
    var isTakeHit = false
    var hp = 100
}
