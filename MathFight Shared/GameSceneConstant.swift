//
//  GameSceneConstant.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 02/08/25.
//

import Foundation

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
