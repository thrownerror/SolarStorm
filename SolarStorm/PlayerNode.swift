//
//  PlayerNode.swift
//  SolarStorm
//
//  Created by student on 10/11/17.
//  Copyright © 2017 student. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerNode:SKSpriteNode{
    var pointPos:CGFloat = 0
    //let name:String?
    init(texture: SKTexture!){
        //super.init(imageNamed: "PlayerShip.png")
        //super.SKSpriteNode(imageNamed: "PlayerShip.png")
        let textureImage = SKTexture(imageNamed: "PlayerShip.png")
        super.init(texture: textureImage, color: UIColor.clear, size: texture.size())
        self.xScale = 0.01
        self.yScale = 0.01
        self.zPosition = 0
        self.name = "player"
        
    }
    init(){
        let textureImage = SKTexture(imageNamed: "PlayerShip.png")
        super.init(texture: textureImage, color: UIColor.clear, size: textureImage.size())
    }
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    func printPos(){
        print("At locaiton \(pointPos)")
    }
    func movePlayer(newPoint: CGPoint){
        self.xScale = 0.1
        self.yScale = 0.1
        self.position = newPoint
        let angle = atan2(self.position.y - 0.0, self.position.x - 0.0)
        let rotateAction = SKAction.rotate(toAngle: angle + CGFloat(Double.pi*0.5), duration: 0.0)
        self.run(rotateAction)
        pointPos = self.position.x
    }
}

