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
    static let clonedPlayer: UInt32 = 1 << 4
}

/// Player constant
let playerAnimationKey = "PLAYER_ANIMATION_KEY"
let moveSpeed: CGFloat = 500.0
enum CharacterState {
    case idle, run, jump, fall, attack1, attack2, dead, takeHit
}

/// Enemy constant
let enemySpeed: CGFloat = 200

/// Shared constant
let jumpImpulse: CGFloat = 120
let characterScale = CGFloat(2)

/// Setup background
#if os(iOS)
let verticalOffsetFraction: CGFloat = 0.19
#elseif os(macOS)
let verticalOffsetFraction: CGFloat = 0.4
#endif
