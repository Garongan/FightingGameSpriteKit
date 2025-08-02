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

/// Bot constant
let botIdleAnimationKey = "BOT_IDLE_ANIMATION_KEY"
let botRunAnimationKey = "BOT_RUN_ANIMATION_KEY"
let botJumpAnimationKey = "BOT_JUMP_ANIMATION_KEY"
let botFallAnimationKey = "BOT_FALL_ANIMATION_KEY"

/// Shared constant
let jumpImpulse: CGFloat = 30
let characterScale = CGFloat(3)
