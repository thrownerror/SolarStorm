//
//  GameScene.swift
//  SolarStorm
//
//  Created by student on 9/21/17.
//  Copyright © 2017 student. All rights reserved.
//



/*
 TODO
 
 Rob:
 Level Change - transitions
 The point indicators are moved to generateIndicators(), called at end of fillCGPoints
 That way we don't have to remember to call it.
 Implemented an array to keep track of indicators for effects - pointIndicators
 TransitionLevel and ChangeLevel stubbed out, no logic. 
 Wanting to do a score transition to trigger them as easiest test.
 
 
 James:
 
 
 DONE:
 Rob: 
 Movement Bar
 Bookends for semicircle
 
 James:
 End Screen
 Score
 */

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
    
    //level handlers
    var levelType:String = "circle"
    var safePoints = [Bool]()
    var pointIndicators: Array<SKSpriteNode> = Array()
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
    
    //score handlers
    var enemiesDestroyed = 0
    var enemiesEscaped = 0
    var destroyedLabel = SKLabelNode()
    var escapedLabel = SKLabelNode()
    
    var enemiesToChange = 0
    
    
    //controls
    var movementBar = SKShapeNode()
    var moveTouch:Bool = false
    var loopable:Bool = true
    var loadedLevel:String = ""
    
    
    
    //var logic bools
    var swellingBar = true
    var scaleModifier:CGFloat = 1.0
    var swellingPos = true
    var loadedAlready = false
    //private var spinnyNode : SKShapeNode?
    //var centerPoint : CGPoint
    
    override func didMove(to view: SKView){
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFill
    }
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        //levelType = "semicircleBottom"
        levelType = "semicircleBottom"
        fillCGPoints(type: levelType)
        
        
        //Debug of locations for representative points - sprites are placeholders
        //Should place in a method
    /*    for point in playerPoints{
            let tempPlayer = SKSpriteNode(imageNamed:"PlayerShip.png")
            tempPlayer.xScale = 0.01
            tempPlayer.yScale = 0.01
            tempPlayer.position = point
            tempPlayer.zPosition = 0
            tempPlayer.name = "tempPlayer"
            self.addChild(tempPlayer)
        }
 */
        if(!loadedAlready){
            createPlayer()
            createScore()
            //generateIndicators()
            createBar()
            loadedAlready = true
        }
        
    }
    
    //James adds the SKLabelNodes for scoring
    func createScore() ->Void{
        destroyedLabel.position = CGPoint(x: 270, y: 250)
        destroyedLabel.text = "Enemy Ships Destroyed: \(enemiesDestroyed)"
        destroyedLabel.fontColor = SKColor.white
        destroyedLabel.fontSize = 15
        destroyedLabel.removeFromParent()
        self.addChild(destroyedLabel)
        
        escapedLabel.position = CGPoint(x: 270, y: 230)
        escapedLabel.text = "Enemy Ships Passed: \(enemiesEscaped)"
        escapedLabel.fontColor = SKColor.white
        escapedLabel.fontSize = 15
        escapedLabel.removeFromParent()
        self.addChild(escapedLabel)
    }
    
    func createBar() ->Void{
        movementBar = SKShapeNode(rectOf: CGSize(width: 20, height: 450), cornerRadius: 12)
        movementBar.position = CGPoint(x: 330, y: 0)
        movementBar.fillColor = UIColor.red
        movementBar.strokeColor = UIColor.blue
        movementBar.lineWidth = 2
        movementBar.name = "moveBar"
        self.addChild(movementBar)
    }
    
    func swellBar() ->Void{
        if(swellingPos){
            if(scaleModifier < 1.2){
                scaleModifier += 0.003
            }
            else{
                swellingPos = false
            }
        }
        else{
            if(scaleModifier > 0.8){
                scaleModifier -= 0.003
            }
            else{
                swellingPos = true
            }
        }
        print(scaleModifier)
        movementBar.setScale(scaleModifier)
    }
    func generateIndicators(){
        for tempPlayer in pointIndicators{
            tempPlayer.removeFromParent()
        }
        pointIndicators.removeAll()
        //pointIndicators = Array<SKSpriteNode>(playerPoints.count)
        for point in playerPoints{
            
            let tempPlayer = SKSpriteNode(color: .blue, size: CGSize(width:5, height: 8))
//let tempPlayer = SKSpriteNode(imageNamed:"PlayerShip.png")
            //tempPlayer.xScale = 0.01
          // tempPlayer.yScale = 0.01
            tempPlayer.position = point
            tempPlayer.zPosition = 0
            tempPlayer.name = "tempPlayer"
            pointIndicators.append(tempPlayer)
            self.addChild(tempPlayer)
        }
    }
    func getCenter() ->Void{
        //Header incase of need to get center of screen
        //centerPoint = CGPoint(x: (self.height/2), y: (self.width/2))
        //centerPoint = CGPoint(x:200,y:200)
    }
    
    func transitionLevel(nextLevel: String){
        print("in transition level")
        var currentLevel = loadedLevel
        var next = nextLevel
        if(currentLevel == "circle")
        {
            if(next == "semicircleBottom"){
               //safe: 0/8-15. flash good
                //flash 1-7 bad
                for index in 1...7{
          //          print(index)
                    //ask about why color isn't working
                    pointIndicators[index].color = .red
                  //  pointIndicators[index].colorBlendFactor = 0.8
                 //   pointIndicators[index].xScale = 0.05
                 //   pointIndicators[index].yScale = 0.05
                }
            }
            //determine shared spaces
            //color change
            //start countdown
        }
        if(currentLevel == "semicircleBottom"){
            if(next == "circle"){
                //all points safe. flash good
            }
        }
    }
    
    func changeLevel(nextLevel: String){
        print("top of change level")
        var currentLevel = loadedLevel
        if(currentLevel == "circle"){
            if(nextLevel == "semicircleBottom"){
                if(currentPos >= 1 && currentPos <= 7){
                    player.removeFromParent()
                    self.endScreenTransition()
                }
                else{
                    if(currentPos != 0){
                        currentPos = currentPos - 8
                    }
                    else{
                        currentPos = 8
                    }
                }
            }
        }
        if(currentLevel == "semicircleBottom"){
            if(nextLevel == "circle"){
                if(currentPos != 8){
                    currentPos = currentPos + 8
                }
                else{
                    currentPos = 0
                }
            }
        }
        fillCGPoints(type: nextLevel)
        print("after fill points")
        movePlayer(newPoint: playerPoints[currentPos])

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
        safePoints.removeAll()
        if(type == "circle"){
            //loopable = true
            loadedLevel = "circle"
            //16 distinct points
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
            /*for int in 0...15{
                safePoints.append(false)
            }*/
            
        }
        if(type == "semicircleBottom"){
            loadedLevel = "semicircleBottom"
        

            playerPoints.append(CGPoint(x:-1*circleRadius, y:0 * circleRadius))
            
            playerPoints.append(CGPoint(x:-(sqrt(3)/2)*circleRadius, y:-1/2 * circleRadius))
            playerPoints.append(CGPoint(x:-(sqrt(2)/2) * circleRadius, y: -(sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:-(1/2 * circleRadius), y: -((sqrt(3)/2) * circleRadius)))
            
            playerPoints.append(CGPoint(x: 0, y:-1 * circleRadius))
            
            playerPoints.append(CGPoint(x:(1/2 * circleRadius), y: -((sqrt(3)/2) * circleRadius)))
            playerPoints.append(CGPoint(x:(sqrt(2)/2) * circleRadius, y: -(sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:(sqrt(3)/2)*circleRadius, y:-1/2 * circleRadius))
           
            playerPoints.append(CGPoint(x:1*circleRadius, y:0 * circleRadius))

            //Ask Jefferson about doing it in one loop
           /* print("Semicircle points:")
            for int in 0...15{
                if(int < 8){
                    safePoints.append(false)
                }
                else{
                    safePoints.append(true)
                }
                print("Point: \(safePoints[int])")
            }*/
            
        }
        generateIndicators()
    }
    
    //Enemy generation - James
    
    func createEnemy() -> Void{
        let enemy = SKSpriteNode(imageNamed: "EnemyShip.png")
        let targetPoint = playerPoints[Int(arc4random_uniform(UInt32(playerPoints.count)))]
        
        enemy.position = CGPoint(x: targetPoint.x/10, y: targetPoint.y/10)
        let angle = atan2(enemy.position.y - targetPoint.y, enemy.position.x - targetPoint.x) + CGFloat(Double.pi)
        
        enemy.zRotation = angle
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width/2, height: enemy.size.height/2))
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        addChild(enemy)
        
        let actionMove = SKAction.move(to: CGPoint(x: targetPoint.x, y: targetPoint.y), duration: TimeInterval(10))
        
        //Can be uncommented along with full line to allow failing
        
        let loseAction = SKAction.run() {
            self.enemiesEscaped += 1
            self.escapedLabel.text = "Enemy Ships Passed: \(self.enemiesEscaped)"
            
            if(self.enemiesEscaped >= 5){
                self.endScreenTransition()
            }
        }
        
        enemy.run(SKAction.sequence([actionMove, loseAction, actionDelete]))
        
    }
    
    //Shoot bullet - James
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
        enemiesDestroyed += 1
        enemiesToChange += 1
        self.destroyedLabel.text = "Enemy Ships Destroyed: \(enemiesDestroyed)"
    }
    


    //Distance between two points - Robert
    func distancePoints(a: CGPoint, b: CGPoint) -> CGFloat{
        let xDistance = a.x - b.x
        let yDistance = a.y - b.y
        return CGFloat(sqrt((xDistance * yDistance) + (yDistance * yDistance)))
    }

    func endScreenTransition(){
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        self.view?.presentScene(gameOverScene, transition: reveal)
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
            if(moveTouch){
                //Use leftOfPlayer to evaluate direction of movement
            /*    if(lastTouch!.x < pos.x){
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
                }*/
                //Clockwise movement
                if(lastTouch!.y < pos.y){//pos.y >= 0){
                    currentPos = currentPos + 1
                    if loadedLevel == "circle"{
                        if(currentPos == playerPoints.count){
                            currentPos = 0
                        }

                    }
                    if loadedLevel == "semicircleBottom"{
                        if(currentPos >= playerPoints.count){
                            currentPos = 8
                        }
                    }

                }
                //counterclockwise movement
                else{
                    currentPos = currentPos - 1
                    if loadedLevel == "circle"{
                        if(currentPos < 0){
                            currentPos = playerPoints.count - 1
                        }
                    }
                    if loadedLevel == "semicircleBottom"{
                        if(currentPos < 0){
                            currentPos = 0
                        }
                    }
                }
                if(currentPos == playerPoints.count){
                    currentPos = 0;
                }
                lastTouch = pos
                print("Current pos: \(currentPos)")
                movePlayer(newPoint: playerPoints[currentPos])
                print("swipe?")
                swellingBar = false;
            }
        }
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }*/
        print("touch released")
        moveTouch = false
        
        ///remove last touch
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = (touches.first as? UITouch)!
        let touchPos = touch.location(in: self)
        let touchedNode = self.atPoint(_:touchPos)
        if let name = touchedNode.name{
            if name == "moveBar"{
                print("touched bar")
                moveTouch = true
            }
        }
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
        var levelChange = false
        if(swellingBar){
            swellBar()
        }
        else{
            movementBar.xScale = 1.0;
            movementBar.yScale = 1.0;
        }
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
        if(enemiesToChange > 1){
            if(loadedLevel == "circle"){
                transitionLevel(nextLevel: "semicircleBottom")
            }
            if(loadedLevel == "semicircleBottom"){
                transitionLevel(nextLevel: "cicle")
            }
        }
        if(enemiesToChange > 3){
            if(loadedLevel == "circle"){
                changeLevel(nextLevel: "semicircleBottom")
                levelChange = true
                
            }
            if(loadedLevel == "semicircleBottom" && !levelChange){
                changeLevel(nextLevel: "circle")
            }
            enemiesToChange = 0
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
