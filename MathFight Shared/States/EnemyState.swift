//
//  EnemyState.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import Foundation
import SpriteKit

class EnemyState {
    static let shared = EnemyState()
    private init() {}
    
    var enemyKilled = 0
    
    var enemyBatFlyFrames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "EnemyBatFly")
    }
    var enemyMonsterRunFrames: [SKTexture] {
        GameSceneSetup.shared.setupAnimationFrames(name: "EnemyMonsterRun")
    }
}
