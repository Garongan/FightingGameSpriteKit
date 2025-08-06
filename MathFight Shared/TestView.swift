//
//  TestView.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 06/08/25.
//

import SwiftUI
import SpriteKit

struct TestView: View {
    var scene: SKScene {
        let scene = GameScene.newGameScene()
        scene.scaleMode = .aspectFill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    TestView()
}
