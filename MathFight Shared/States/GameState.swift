//
//  GameState.swift
//  MathFight
//
//  Created by Alvindo Tri Jatmiko on 10/08/25.
//

import Foundation

class GameState {
    static let shared = GameState()
    private init() {}
    
    var pressedKeys = Set<UInt16>()
    var isGameOver: Bool = false
}
