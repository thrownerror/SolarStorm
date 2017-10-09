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
    
    init(size: CGSize, win: Bool, destroyed: Int) {
        
        super.init(size: size)
        
        backgroundColor = SKColor.black
        
        let label = SKLabelNode()
        if(win == false){
            label.text = "Too Many Escaped"
        } else {
            label.text = "You Succeeded"
        }
        label.fontSize = 60
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        addChild(label)
        
        let destroyedLabel1 = SKLabelNode()
        destroyedLabel1.position = CGPoint(x: size.width/2, y: size.height/2 - 40)
        destroyedLabel1.text = "You were able to"
        destroyedLabel1.fontColor = SKColor.white
        destroyedLabel1.fontSize = 60
        addChild(destroyedLabel1)
        
        let destroyedLabel2 = SKLabelNode()
        destroyedLabel2.position = CGPoint(x: size.width/2, y: size.height/2 - 85)
        destroyedLabel2.text = "destroy \(destroyed) enemies"
        destroyedLabel2.fontColor = SKColor.white
        destroyedLabel2.fontSize = 60
        addChild(destroyedLabel2)
                
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
