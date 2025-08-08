//
//  SpriteComponent.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 08/08/25.
//

import GameplayKit
import SpriteKit

class SpriteComponent: GKComponent {
    let node: SKSpriteNode
    init(texture: SKTexture) {
        self.node = SKSpriteNode(
            texture: texture,
            size: CGSize(
                width: texture.size().width
                    * characterScale,
                height: texture.size().height
                    * characterScale
            )
        )
        self.node.zPosition = 1
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
