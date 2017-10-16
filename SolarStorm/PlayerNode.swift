//
//  PlayerNode.swift
//  SolarStorm
//
//  Extension of SKSpriteNode to allow custom funcitons for the Player piece
//
//  Created by Robert on 10/11/17.
//  Copyright © 2017. All rights reserved.
//

import SpriteKit

class PlayerNode:SKSpriteNode{
  var pointPos:CGFloat = 0
  
  //MARK: - init -
  //Standard init used in game
  init(){
    let textureImage = SKTexture(imageNamed: "PlayerShip.png")
    super.init(texture: textureImage, color: UIColor.clear, size: textureImage.size())
  }
  
  //MARK: - required init -
  required init?(coder aDecoder: NSCoder){
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - printPos -
  func printPos(){
    //debug usage
    print("At locaiton \(pointPos)")
  }
  
  //MARK: - movePlayer -
  func movePlayer(newPoint: CGPoint){
    self.xScale = 0.1
    self.yScale = 0.1
    self.zPosition = 0
    self.position = newPoint
    let angle = atan2(self.position.y - 0.0, self.position.x - 0.0)
    let rotateAction = SKAction.rotate(toAngle: angle + CGFloat(Double.pi*0.5), duration: 0.0)
    self.run(rotateAction)
    pointPos = self.position.x
  }
}

