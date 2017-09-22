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
        player.xScale = 0.2
        player.yScale = 0.2
        //player.position = playerPoints[0]
        player.zPosition = 0

        
        //let remove = SKAction.removeFromParent()
        //let move = SKAction.move(to: <#T##CGPoint#>, duration: <#T##TimeInterval#>)
        //    = SKAction.move(to: <#T##CGPoint#>, duration: <#T##TimeInterval#>)
       // let moveAndRemove = SKAction.sequence([moveTargets,removeTargets])
        
        self.addChild(player)
    }
    func movePlayer(newPoint: CGPoint){
        print("Player move func")
        player.position = newPoint
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
  /*  func touchDown(atPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }*/
       
        if(currentPos < playerPoints.count){
            currentPos = currentPos + 1;
        }
        if(currentPos == playerPoints.count){
            currentPos = 0;
        }
        print("Current pos: \(currentPos)")
        movePlayer(newPoint: playerPoints[currentPos])
    }
    */
    func touchDown(sender: UITapGestureRecognizer){
        if sender.state == .ended{
            print("ended")
        }
    }
    func touchMoved(toPoint pos : CGPoint) {
       /* if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }*/
    }
    
    func touchUp(atPoint pos : CGPoint) {
       /* if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }*/
    }
    
 /*   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    */
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction{
                case UISwipeGestureRecognizerDirection.right:
                    print("Right")
                case UISwipeGestureRecognizerDirection.down:
                    print("Down")
                case UISwipeGestureRecognizerDirection.left:
                    print("Left")
                case UISwipeGestureRecognizerDirection.up:
                    print("Up:")
                default:
                    print("Oh geeze Rick")
            }
        }
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
    }
}
