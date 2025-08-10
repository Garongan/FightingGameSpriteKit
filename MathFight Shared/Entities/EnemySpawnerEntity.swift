//
//  EnemySpawnerEntity.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import GameplayKit

class EnemySpawnerEntity: GKEntity, SpawnerEntity {
    let spawner: SpawnerComponent
    let scene: SKScene

    init(
        scene: SKScene,
        interval: TimeInterval,
        controlSystem: GKComponentSystem<GKComponent>
    ) {
        self.spawner = SpawnerComponent(spawnInterval: interval)
        self.scene = scene
        super.init()
        addComponent(spawner)
        addComponent(EnemyControlSystem(scene: scene))
    }

    required init?(coder: NSCoder) { fatalError() }

    func spawnEnemy() {
        let enemy = EnemyEntity()

        // position random
        if let spriteNode = enemy.component(ofType: SpriteComponent.self)?.node
        {
            let x = CGFloat.random(in: -scene.size.width...scene.size.width)
            let y = scene.size.height + spriteNode.frame.height
            spriteNode.position = CGPoint(x: x, y: y)
            scene.addChild(spriteNode)
        }
    }
}
