//
//  MainMenuScene.swift
//  SolarStorm
//
//  Created by James on 10/9/17.
//  Copyright © 2017 student. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
  
  //MARK: - init method -
  //James - Creates the Main Menu Scene
  init(size : CGSize, score : Int) {
    
    super.init(size : size)
    
    backgroundColor = SKColor.black
    
    let titleLabel = SKLabelNode()
    titleLabel.fontSize = 100
    titleLabel.text = "SOLAR STORM"
    titleLabel.fontName = "Maven Pro"
    titleLabel.fontColor = SKColor.red
    titleLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 20)
    addChild(titleLabel)
    
    let tapLabel = SKLabelNode()
    tapLabel.fontSize = 40
    tapLabel.text = "Tap to Start"
    tapLabel.fontName = "Maven Pro"
    tapLabel.fontColor = SKColor.red
    tapLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 20)
    addChild(tapLabel)
    
    if score > 0 {
      let scoreLabel = SKLabelNode()
      scoreLabel.fontSize = 40
      scoreLabel.text = "Previous Session Score: \(score)"
      scoreLabel.fontName = "Maven Pro"
      scoreLabel.fontColor = SKColor.red
      scoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 80)
      addChild(scoreLabel)
    }
    
    let controlLabel = SKLabelNode()
    controlLabel.fontSize = 30
    controlLabel.text = "Controls: Tap to Shoot and Swipe Up and Down on Bars to Move"
    controlLabel.fontName = "Maven Pro"
    controlLabel.fontColor = SKColor.red
    controlLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 110)
    addChild(controlLabel)
    
    
    let backgroundMusic = SKAudioNode(fileNamed: "Background.mp3")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
    
    
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - Help Methods -
  //James - Moves scene to GameScene
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    run(SKAction.sequence([SKAction.run() {
      let reveal = SKTransition.flipVertical(withDuration: 0.5)
      let scene = GameScene(size: CGSize(width: 750, height: 700))
      self.view?.presentScene(scene, transition:reveal)
      }]))
  }
}
