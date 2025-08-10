//
//  SpawnerComponent.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import GameplayKit

protocol SpawnerEntity: AnyObject {
    func spawnEnemy()
}

class SpawnerComponent: GKComponent {
    let spawnInterval: TimeInterval
    private var elapsedTime: TimeInterval = 0
    
    init(spawnInterval: TimeInterval) {
        self.spawnInterval = spawnInterval
        super.init()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        if elapsedTime >= spawnInterval {
            elapsedTime = 0
            (entity as? SpawnerEntity)?.spawnEnemy()
        }
    }
}
