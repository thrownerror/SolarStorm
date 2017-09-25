//
//  GameScene.swift
//  SolarStorm
//
//  Created by student on 9/21/17.
//  Copyright © 2017 student. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var change = true
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var playerPoints: [CGPoint] = []
    var circleRadius:Double = 270
    var currentPos = 0
    var levelType:String = "circle"
    let swipeWindow:CGFloat = 4.5
    var leftOfPlayer = false
    var lastTouch: CGPoint?
    
    var enemies: Array<SKSpriteNode> = Array()
    var enemyTimer:Int = 0
    
     let actionDelete = SKAction.removeFromParent()
    
    //var player = SKSpriteNode(imageNamed:"PlayerShip.png")
    var player = SKSpriteNode()
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    //var centerPoint : CGPoint
    override func sceneDidLoad() {

        self.lastUpdateTime = 0

        
        // Get label node from scene and store it for use later
      //  self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
      //  if let label = self.label {
      //      label.alpha = 0.0
       //     label.run(SKAction.fadeIn(withDuration: 2.0))
      //  }

      //  var player = SKSpriteNode(imageNamed:"PlayerShip.png")
      //  player.xScale = 0.2
      //  player.yScale = 0.2
      //  player.position = CGPoint(x: 50, y:50)
      //  player.zPosition = 0
      //  player.name = "player"
        
        fillCGPoints(type: levelType)
       // getCenter()
        
        //Debug of locations
        for point in playerPoints{
            let tempPlayer = SKSpriteNode(imageNamed:"PlayerShip.png")
            tempPlayer.xScale = 0.05
            tempPlayer.yScale = 0.05
            tempPlayer.position = point
            tempPlayer.zPosition = 0
            tempPlayer.name = "tempPlayer"
            
            self.addChild(tempPlayer)
        }
        createPlayer()
        
    }
    func getCenter() ->Void{
        //centerPoint = CGPoint(x: (self.height/2), y: (self.width/2))
      //  centerPoint = CGPoint(x:200,y:200)
    }
    
    func createPlayer() -> Void{
        player = SKSpriteNode(imageNamed: "PlayerShip.png")
        player.xScale = 0.01
        player.yScale = 0.01
        //player.position = playerPoints[0]
        player.zPosition = 0

        
        //let remove = SKAction.removeFromParent()
        //let move = SKAction.move(to: <#T##CGPoint#>, duration: <#T##TimeInterval#>)
        //    = SKAction.move(to: <#T##CGPoint#>, duration: <#T##TimeInterval#>)
       // let moveAndRemove = SKAction.sequence([moveTargets,removeTargets])
        
        self.addChild(player)
    }
    func movePlayer(newPoint: CGPoint){
        player.xScale = 0.2
        player.yScale = 0.2
        player.position = newPoint
        print("Player move func")
        let angle = atan2(player.position.y - 0.0, player.position.x - 0.0)
        let rotateAction = SKAction.rotate(toAngle: angle + CGFloat(Double.pi*0.5), duration: 0.0)
        player.run(rotateAction)
    }
    
    func fillCGPoints(type: String){
        playerPoints.removeAll()
        if(type == "circle"){
            playerPoints.append(CGPoint(x:1*circleRadius, y:0 * circleRadius))
            playerPoints.append(CGPoint(x:(sqrt(3)/2)*circleRadius, y:1/2 * circleRadius))
            playerPoints.append(CGPoint(x:(sqrt(2)/2) * circleRadius, y: (sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:(1/2 * circleRadius), y: ((sqrt(3)/2) * circleRadius)))
            
            playerPoints.append(CGPoint(x: 0, y:1 * circleRadius))
            
            playerPoints.append(CGPoint(x:-(1/2 * circleRadius), y: ((sqrt(3)/2) * circleRadius)))
            playerPoints.append(CGPoint(x:-(sqrt(2)/2) * circleRadius, y: (sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:-(sqrt(3)/2)*circleRadius, y:1/2 * circleRadius))

            playerPoints.append(CGPoint(x:-1*circleRadius, y:0 * circleRadius))
            
            playerPoints.append(CGPoint(x:-(sqrt(3)/2)*circleRadius, y:-1/2 * circleRadius))
            playerPoints.append(CGPoint(x:-(sqrt(2)/2) * circleRadius, y: -(sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:-(1/2 * circleRadius), y: -((sqrt(3)/2) * circleRadius)))
            
            playerPoints.append(CGPoint(x: 0, y:-1 * circleRadius))

            playerPoints.append(CGPoint(x:(1/2 * circleRadius), y: -((sqrt(3)/2) * circleRadius)))
            playerPoints.append(CGPoint(x:(sqrt(2)/2) * circleRadius, y: -(sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:(sqrt(3)/2)*circleRadius, y:-1/2 * circleRadius))
            
        }
    }
    
    func createEnemy() -> Void{
        let enemy = SKSpriteNode(imageNamed: "EnemyShip.png")
        enemy.position = CGPoint(x: 0, y: 0)
        
        addChild(enemy)
        
        let targetPoint = playerPoints[Int(arc4random_uniform(UInt32(playerPoints.count)))]
        
        let actionMove = SKAction.move(to: CGPoint(x: targetPoint.x, y: targetPoint.y), duration: TimeInterval(10))
        
        enemy.run(SKAction.sequence([actionMove, actionDelete]))
        
    }
    
    func fireProjectile(){
        let center = CGPoint(x: 0, y: 0)
        
        let bullet = SKEmitterNode(fileNamed: "PlayerBullet")!
        bullet.position = playerPoints[currentPos]
        let angle = atan2(bullet.position.y - 0.0, bullet.position.x - 0.0) + CGFloat(Double.pi)
        bullet.zRotation = angle
        
        addChild(bullet)
        
        let actionMove = SKAction.move(to: center, duration: TimeInterval(2))
        
        bullet.run(SKAction.sequence([actionMove, actionDelete]))
    }

    
    func distancePoints(a: CGPoint, b: CGPoint) -> CGFloat{
        let xDistance = a.x - b.x
        let yDistance = a.y - b.y
        return CGFloat(sqrt((xDistance * yDistance) + (yDistance * yDistance)))
    }
    
    func touchDown(atPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }*/
        
        lastTouch = pos
        fireProjectile()
        
        //Ask how to write this neater

        print("fire")
    }
    /*
   func touchDown(sender: UITapGestureRecognizer){
        print("in touch down")
        if sender.state == .ended{
            print("ended")
        }
    }*/
    
    func touchMoved(toPoint pos : CGPoint) {
       /* if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
         }*/

        let distanceBetween = distancePoints(a: pos, b: lastTouch!)
        if(distanceBetween > swipeWindow){
            if(lastTouch!.x < pos.x){
                leftOfPlayer = false
            }
            else{
                leftOfPlayer = true
            }
            if(leftOfPlayer){
                if(currentPos < playerPoints.count){
                    currentPos = currentPos + 1
                }
                if(currentPos == playerPoints.count){
                    currentPos = 0
                }
            }
            else{
                if(currentPos > 0){
                    currentPos = currentPos - 1
                }
                if(currentPos == 0){
                    currentPos = playerPoints.count - 1
                }
            }
            if(currentPos == playerPoints.count){
                currentPos = 0;
            }
            lastTouch = pos
            print("Current pos: \(currentPos)")
            movePlayer(newPoint: playerPoints[currentPos])
            print("swipe?")
        }
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }*/
        
        
        ///remove last touch
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
 
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        if enemyTimer >= 180{
            createEnemy()
            enemyTimer = 0
        } else {
            enemyTimer += 1
        }

    
    }
}
