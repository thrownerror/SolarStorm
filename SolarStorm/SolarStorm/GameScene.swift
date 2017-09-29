//
//  GameScene.swift
//  SolarStorm
//
//  Created by student on 9/21/17.
//  Copyright © 2017 student. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Enemy: UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var change = true
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var playerPoints: [CGPoint] = []
    
    //radius of play area
    var circleRadius:Double = 270
    
    //location of player
    var currentPos = 0
    
    //initial level
    var levelType:String = "circle"
    
    //swipe sensitivity
    let swipeWindow:CGFloat = 6
    
    //movement checks
    var leftOfPlayer = false
    var lastTouch: CGPoint?
    
    //enemy handlers
    var enemies: Array<SKSpriteNode> = Array()
    var enemyTimer:Int = 0
    
    let actionDelete = SKAction.removeFromParent()
    
    //var player = SKSpriteNode(imageNamed:"PlayerShip.png")
    
    //player properties
    var player = SKSpriteNode()
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    
    //private var spinnyNode : SKShapeNode?
    //var centerPoint : CGPoint
      
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
     
        fillCGPoints(type: levelType)
        
        //Debug of locations for representative points - sprites are placeholders
        for point in playerPoints{
            let tempPlayer = SKSpriteNode(imageNamed:"PlayerShip.png")
            tempPlayer.xScale = 0.01
            tempPlayer.yScale = 0.01
            tempPlayer.position = point
            tempPlayer.zPosition = 0
            tempPlayer.name = "tempPlayer"
            
            self.addChild(tempPlayer)
        }
        createPlayer()
        
    }
    func getCenter() ->Void{
        //Header incase of need to get center of screen
        //centerPoint = CGPoint(x: (self.height/2), y: (self.width/2))
      //  centerPoint = CGPoint(x:200,y:200)
    }
    
    //Create player ship and set it appropriatley - Robert
    func createPlayer() -> Void{
        player = SKSpriteNode(imageNamed: "PlayerShip.png")
        //Bug - starts tiny on center of screen - need to ask Jefferson
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
    
    //Handles movement of player from one point to another - Robert
    func movePlayer(newPoint: CGPoint){
        player.xScale = 0.1
        player.yScale = 0.1
        player.position = newPoint
        print("Player move func")
        let angle = atan2(player.position.y - 0.0, player.position.x - 0.0)
        let rotateAction = SKAction.rotate(toAngle: angle + CGFloat(Double.pi*0.5), duration: 0.0)
        player.run(rotateAction)
    }
    
    //Handles CGPoint generation for ship placement each level - Robert
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
    
    //Enemy generation - James
    
    //TODO: Invincibility at start so they can't get eliminated by spamming
    func createEnemy() -> Void{
        let enemy = SKSpriteNode(imageNamed: "EnemyShip.png")
        let targetPoint = playerPoints[Int(arc4random_uniform(UInt32(playerPoints.count)))]
        
        enemy.position = CGPoint(x: targetPoint.x/10, y: targetPoint.y/10)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width/2, height: enemy.size.height/2))
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        addChild(enemy)
        
        let actionMove = SKAction.move(to: CGPoint(x: targetPoint.x, y: targetPoint.y), duration: TimeInterval(10))
        
        enemy.run(SKAction.sequence([actionMove, actionDelete]))
        
    }
    
    //Shoot bullet - James
    //TODO: Make it smalelr so it doesn't hit enemies in other lanes
    func fireProjectile(){
        let center = CGPoint(x: 0, y: 0)
        
        let projectile = SKSpriteNode(imageNamed: "Projectile.png")
        projectile.position = playerPoints[currentPos]
        let angle = atan2(projectile.position.y - 0, projectile.position.x - 0) + CGFloat(Double.pi)

        projectile.zRotation = angle
        
        let bullet = SKEmitterNode(fileNamed: "PlayerBullet")!
        bullet.position = center
        //let angle = atan2(bullet.po!!!!!!!!!!sition.y - (self.scene?.position.y)!, bullet.position.x - (self.scene?.position.x)!) + CGFloat(Double.pi)
        //bullet.zRotation = angle
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(projectile)
        projectile.addChild(bullet)
        
        let actionMove = SKAction.move(to: center, duration: TimeInterval(2))
        
        projectile.run(SKAction.sequence([actionMove, actionDelete]))
    }
    
    //Projectile Collision - James
    func projectileCollision(projectile: SKSpriteNode, enemy: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        enemy.removeFromParent()
    }


    //Distance between two points - Robert
    func distancePoints(a: CGPoint, b: CGPoint) -> CGFloat{
        let xDistance = a.x - b.x
        let yDistance = a.y - b.y
        return CGFloat(sqrt((xDistance * yDistance) + (yDistance * yDistance)))
    }
    
    //Move to new screen
    func loadNextLevel(){
        
    }
    
    //On touch, fire a projectile and get point
    func touchDown(atPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }*/
        lastTouch = pos
        fireProjectile()
    }
    
    /*
   func touchDown(sender: UITapGestureRecognizer){
        print("in touch down")
        if sender.state == .ended{
            print("ended")
        }
    }*/
    
    //When touch pos has moved
    func touchMoved(toPoint pos : CGPoint) {
       /* if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
         }*/

        //Get Distance between points. If greater than swipe window, treat like a swipe
        let distanceBetween = distancePoints(a: pos, b: lastTouch!)
        if(distanceBetween > swipeWindow){
            
            //Use leftOfPlayer to evaluate direction of movement
            if(lastTouch!.x < pos.x){
                leftOfPlayer = false
            }
            else{
                leftOfPlayer = true
            }
            //if left, rotate counter clockwise
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
       // if let label = self.label {
            //label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
      ///  }
        
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
    
    func didBegin(_ contact: SKPhysicsContact) {
    
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let enemy = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? SKSpriteNode {
                projectileCollision(projectile: projectile, enemy: enemy)
            }
        }
        
    }
}
