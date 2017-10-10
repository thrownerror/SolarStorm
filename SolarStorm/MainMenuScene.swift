//
//  MainMenuScene.swift
//  SolarStorm
//
//  Created by student on 10/9/17.
//  Copyright © 2017 student. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    override init(size: CGSize) {
        
        super.init(size: size)
                
        backgroundColor = SKColor.black
        
        let label = SKLabelNode()
        label.fontSize = 100
        label.text = "SOLAR STORM"
        label.fontColor = SKColor.red
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        let label2 = SKLabelNode()
        label2.fontSize = 40
        label2.text = "Tap to Start"
        label2.fontColor = SKColor.red
        label2.position = CGPoint(x: size.width/2, y: size.height/2 - 40)
        addChild(label2)
        
        let backgroundMusic = SKAudioNode(fileNamed: "Background.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        run(SKAction.playSoundFileNamed("EnemyDeathSound.mp3", waitForCompletion: false))
        run(SKAction.sequence([SKAction.run() {
            let reveal = SKTransition.flipVertical(withDuration: 0.5)
            let scene = GameScene(size: CGSize(width: 750, height: 600))
            self.view?.presentScene(scene, transition:reveal)
            }]))
    }
}
