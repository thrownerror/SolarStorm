//
//  GameOverScne.swift
//  SolarStorm
//
//  Created by James on 9/29/17.
//  Copyright © 2017 student. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
  
  //MARK: - init method -
  //James - Creates the GameOverScene
  init(size: CGSize, phased: Bool, destroyed: Int) {
    
    super.init(size: size)
    
    backgroundColor = SKColor.black
    
    let failLabel = SKLabelNode()
    if phased == false {
      failLabel.text = "Too Many Enemies Passed"
    } else {
      failLabel.text = "You Got Phased Out"
    }
    failLabel.fontSize = 60
    failLabel.fontColor = SKColor.white
    failLabel.fontName = "Maven Pro"
    failLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
    addChild(failLabel)
    
    let scoreLabel = SKLabelNode()
    scoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 40)
    scoreLabel.text = "You were able to"
    scoreLabel.fontColor = SKColor.white
    scoreLabel.fontSize = 60
    scoreLabel.fontName = "Maven Pro"
    addChild(scoreLabel)
    
    let destroyedLabel = SKLabelNode()
    destroyedLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 85)
    destroyedLabel.text = "destroy \(destroyed) enemies"
    destroyedLabel.fontColor = SKColor.white
    destroyedLabel.fontSize = 60
    destroyedLabel.fontName = "Maven Pro"
    addChild(destroyedLabel)
    
    run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.run() {
      let reveal = SKTransition.flipVertical(withDuration: 0.5)
      let scene = MainMenuScene(size: self.view!.bounds.size, score: destroyed)
      self.view?.presentScene(scene, transition:reveal)
      }]))
    
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
