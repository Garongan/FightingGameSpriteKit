//
//  HealthPlusSpawnerEntity.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import GameplayKit

class HealthPlusSpawnerEntity: GKEntity, SpawnerEntity {
    let spawner: SpawnerComponent
    let scene: SKScene

    init(
        scene: SKScene,
        interval: TimeInterval
    ) {
        self.spawner = SpawnerComponent(spawnInterval: interval)
        self.scene = scene
        super.init()
        addComponent(spawner)
    }

    required init?(coder: NSCoder) { fatalError() }

    func spawnEnemy() {
        let healthPlus = HealthPlusEntity()

        // position random
        if let spriteNode = healthPlus.component(ofType: SpriteComponent.self)?.node
        {
            let x = CGFloat.random(in: -scene.size.width...scene.size.width)
            let y = scene.size.height + spriteNode.frame.height
            spriteNode.position = CGPoint(x: x, y: y)
            scene.addChild(spriteNode)
        }
    }
}
