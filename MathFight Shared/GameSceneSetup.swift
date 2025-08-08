//
//  GameSceneSetup.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 08/08/25.
//

import Foundation
import SpriteKit

class GameSceneSetup {
    static let shared = GameSceneSetup()
    
    func setupAnimationFrames(name: String) -> [SKTexture] {
        let atlas = SKTextureAtlas(named: name)
        let sortedNames = atlas.textureNames.sorted()
        return sortedNames.map { atlas.textureNamed($0) }
    }
    
    func startAnimationFrames(
        frames: [SKTexture],
        key: String,
        character: SKSpriteNode,
        loop: Bool,
        timePerFrame: TimeInterval = 0.1
    ) {
        let action = SKAction.animate(with: frames, timePerFrame: timePerFrame)
        character.run(
            loop ? SKAction.repeatForever(action) : action,
            withKey: key
        )
    }
}
