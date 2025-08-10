//
//  EnemyControlSystem.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import GameplayKit

class EnemyControlSystem: GKComponent {
    let scene: SKScene

    init(scene: SKScene) {
        self.scene = scene
        super.init()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func update(deltaTime seconds: TimeInterval) {
        scene.enumerateChildNodes(withName: "enemy") { node, _ in
            let dx = PlayerState.shared.node.position.x - node.position.x
            let dy = PlayerState.shared.node.position.y - node.position.y
            let angle = atan2(dy, dx)

            let vx = cos(angle) * enemySpeed
            let vy = sin(angle) * enemySpeed

            if let body = node.physicsBody {
                body.velocity = CGVector(dx: vx, dy: vy)
            } else {
                node.position.x += vx
                node.position.y += vy
            }
        }
    }
}
