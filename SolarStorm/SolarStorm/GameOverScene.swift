//
//  GameOverScne.swift
//  SolarStorm
//
//  Created by student on 9/29/17.
//  Copyright © 2017 student. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        backgroundColor = SKColor.black
        
        let label = SKLabelNode()
        label.text = "Too Many Escaped"
        label.fontSize = 50
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        //If uncommented it will return to the game scene after losing. Note Corrdinate system changes on reload
        
        run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.run() {
            let reveal = SKTransition.flipVertical(withDuration: 0.5)
            let scene = GameScene(size: size)
            self.view?.presentScene(scene, transition:reveal)
            }]))
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
