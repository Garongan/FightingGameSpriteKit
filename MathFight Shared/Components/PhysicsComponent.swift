//
//  PhysicsComponent.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 08/08/25.
//

import Foundation
import GameplayKit

class PhysicsComponent: GKComponent {
    var body: SKPhysicsBody!

    init(body: SKPhysicsBody, category: UInt32, collision: UInt32, contact: UInt32) {
        super.init()
        self.body = body
        self.body.categoryBitMask = category
        self.body.collisionBitMask = collision
        self.body.contactTestBitMask = contact
        self.body.isDynamic = true
        self.body.affectedByGravity = true
        self.body.allowsRotation = false
    }

    override func didAddToEntity() {
        guard let sprite = entity?.component(ofType: SpriteComponent.self)?.node
        else { return }
        sprite.physicsBody = self.body
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}
