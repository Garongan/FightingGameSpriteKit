//
//  GameSceneConstant.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 02/08/25.
//

import Foundation

struct PhysicsCategory {
    static let player: UInt32 = 1 << 0  // 0001
    static let land: UInt32 = 1 << 1  // 0010
    static let enemy: UInt32 = 1 << 2
    static let healthPlus: UInt32 = 1 << 3
}

/// Player constant
let playerAnimationKey = "PLAYER_ANIMATION_KEY"

enum CharacterState {
    case idle, run, jump, fall, attack1, attack2, dead
}

/// Enemy constant
let enemySpeed: CGFloat = 200

/// Shared constant
let jumpImpulse: CGFloat = 30
let characterScale = CGFloat(2)
