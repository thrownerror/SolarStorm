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
 
 //TO DO Rob - add y pos tracker for movement feedback
 
 James:

 
 
 DONE:
 Rob:
 Movement Bar
 Bookends for semicircle
 Classing fadeInOut
 Levels
 
 
 James:
 End Screen
 Score
 Sounds
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
    var enemyTimer:Double = 0
    var enemyDifficulty:Double = 0
    
    let actionDelete = SKAction.removeFromParent()
    
    //var player = SKSpriteNode(imageNamed:"PlayerShip.png")
    
    //player properties
    //var player = SKSpriteNode()
    var player = PlayerNode()
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
    var movementBar2 = SKShapeNode()
    var moveTouch:Bool = false
    var loopable:Bool = true
    var loadedLevel:String = "circle"
    
    
    
    //var logic bools
    var swellingBar = true
    var scaleModifier:CGFloat = 1.0
    var swellingPos = true
    var loadedAlready = false
    
    var nextLevel = ""
    var safeChange = 0
    //private var spinnyNode : SKShapeNode?
    //var centerPoint : CGPoint
    var indicators: Array<SKSpriteNode> = Array()
    var playBoard:movementBoard?
    var transitionStart = false
    //var testPlayer = PlayerNode()
    
    override func didMove(to view: SKView){
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFill
    }
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        //levelType = "semicircleBottom"
        //levelType = "semicircleTop"
        //levelType = "semicircleRight"
        //levelType = "semicircleLeft"
        levelType = "circle"
        //fillCGPoints(type: levelType)
        
        

        
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
            //createPlayer()
            playBoard = movementBoard(type: "circle")
       //     var indicatorCount:Int = (testBoard?.pointIndicators.count)! - 1
       //     for index in 0...indicatorCount{
       //         self.addChild((testBoard?.pointIndicators[index])!)
       //     }
            getIndicies()
            createScore()
            //generateIndicators()
            createBar()
            createBar2()
            addChild(player)
            player.movePlayer(newPoint: (playBoard?.playerPoints[0])!)
            
            //testPlayer.printPos()
            
            loadedAlready = true
            loadedLevel = (playBoard?.levelType)!
        }
        
        //establishes background music and screen along with center particle
        let backgroundMusic = SKAudioNode(fileNamed: "Background.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        let background = SKSpriteNode(imageNamed: "BackgroundImage")
        background.position = CGPoint(x: 0, y:0)
        background.zPosition = -1
        self.addChild(background)
        
        let centerParticle = SKEmitterNode(fileNamed: "CenterParticle")!
        centerParticle.position = CGPoint(x: 0, y: 0)
        addChild(centerParticle)

        
    }
    func getIndicies(){
        for index in indicators{
            index.removeFromParent()
        }
        indicators = (playBoard?.pointIndicators)!
        for point in indicators{
            self.addChild(point)
        }
    }
    
    //James - Adds the SKLabelNodes for scoring
    func createScore() ->Void{
        destroyedLabel.position = CGPoint(x: 270, y: 250)
        destroyedLabel.text = "Enemy Ships Destroyed: \(enemiesDestroyed)"
        destroyedLabel.fontColor = SKColor.white
        destroyedLabel.fontSize = 15
        destroyedLabel.fontName = "Maven Pro"
        destroyedLabel.removeFromParent()
        self.addChild(destroyedLabel)
        
        escapedLabel.position = CGPoint(x: 270, y: 230)
        escapedLabel.text = "Enemy Ships Passed: \(enemiesEscaped)"
        escapedLabel.fontColor = SKColor.white
        escapedLabel.fontSize = 15
        escapedLabel.fontName = "Maven Pro"
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
    func createBar2() ->Void{
        movementBar2 = SKShapeNode(rectOf: CGSize(width: 20, height: 450), cornerRadius: 12)
        movementBar2.position = CGPoint(x: -330, y: 0)
        movementBar2.fillColor = UIColor.red
        movementBar2.strokeColor = UIColor.blue
        movementBar2.lineWidth = 2
        movementBar2.name = "moveBar2"
        self.addChild(movementBar2)
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
        //print(scaleModifier)
        movementBar.setScale(scaleModifier)
        movementBar2.setScale(scaleModifier)
    }

    //James - Enemy Creation Method
    func createEnemy() -> Void{
        
        //sets up sprite node
        let enemy = SKSpriteNode(imageNamed: "EnemyShip.png")
        let targetPoint = playBoard?.playerPoints[Int(arc4random_uniform(UInt32((playBoard?.playerPoints.count)!)))]
        
        enemy.position = CGPoint(x: (targetPoint?.x)!/10, y: (targetPoint?.y)!/10)
        enemy.setScale(0.4)
        let angle = atan2(enemy.position.y - (targetPoint?.y)!, enemy.position.x - (targetPoint?.x)!) + CGFloat(Double.pi)
        enemy.zRotation = angle
        
        //establishes physics body for enemy to be used for collision with bullet
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width/2, height: enemy.size.height/2))
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        addChild(enemy)
        
        //sets up both movement and scaling action
        let actionMove = SKAction.move(to: CGPoint(x: (targetPoint?.x)!, y: (targetPoint?.y)!), duration: TimeInterval(10 - (0.1 * enemyDifficulty)))
        let actionScale = SKAction.scale(by: 3, duration: 7 - (0.1 * enemyDifficulty))
        
        var actions = Array<SKAction>();
        
        actions.append(actionMove);
        actions.append(actionScale);
        
        let group = SKAction.group(actions);

        //Ends game if too many enemies have escaped
        let loseAction = SKAction.run() {
            self.enemiesEscaped += 1
            self.escapedLabel.text = "Enemy Ships Passed: \(self.enemiesEscaped)"
            
            if(self.enemiesEscaped >= 5){
                self.endScreenTransition(phased: false)
            }
        }
        
        enemy.run(SKAction.sequence([group, loseAction, actionDelete]))
        
    }
    
    //Shoot bullet - James
    func fireProjectile(){
        let center = CGPoint(x: 0, y: 0)
        
        let projectile = SKSpriteNode(imageNamed: "Projectile.png")
        projectile.position = (playBoard?.playerPoints[currentPos])!
        let angle = atan2(projectile.position.y - 0, projectile.position.x - 0) + CGFloat(Double.pi)
        
        projectile.zRotation = angle
        
        run(SKAction.playSoundFileNamed("FireSound.mp3", waitForCompletion: false))
        
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
    
    //James - Projectile collision with enemy
    func projectileCollision(projectile: SKSpriteNode, enemy: SKSpriteNode) {
        projectile.removeFromParent()
        enemy.removeFromParent()
        run(SKAction.playSoundFileNamed("EnemyDeathSound.mp3", waitForCompletion: false))
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
    
    func endScreenTransition(phased: Bool){
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, phased: phased, destroyed: self.enemiesDestroyed)
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
                print("movement pos: \(currentPos)")
                //Clockwise movement
                if(lastTouch!.y < pos.y){//pos.y >= 0){
                    currentPos = currentPos + 1
                    if loadedLevel == "circle"{
                        if(currentPos == playBoard!.playerPoints.count){
                            currentPos = 0
                        }
                        
                    }
                    if loadedLevel == "semicircleTop" || loadedLevel == "semicircleBottom" || loadedLevel == "semicircleLeft" || loadedLevel == "semicircleRight"{
                        if(currentPos >= playBoard!.playerPoints.count){
                            currentPos = 8
                        }
                    }
                    //  if loadedLevel == "semicircleBottom"{
                    //      if(currentPos >= playerPoints.count){
                    //          currentPos = 8
                    //      }
                    //  }
                    
                }
                    //counterclockwise movement
                else{
                    currentPos = currentPos - 1
                    if loadedLevel == "circle"{
                        if(currentPos < 0){
                            currentPos = playBoard!.playerPoints.count - 1
                        }
                    }
                    if loadedLevel == "semicircleTop" || loadedLevel == "semicircleBottom" || loadedLevel == "semicircleLeft" || loadedLevel == "semicircleRight"{
                        if(currentPos < 0){
                            currentPos = 0
                        }
                    }
                    // if loadedLevel == "semicircleTop"{
                    //     if(currentPos < 0 ){
                    //         currentPos = 0
                    //     }
                    // }
                }
                if(currentPos == playBoard!.playerPoints.count){
                    currentPos = 0;
                }
                lastTouch = pos
                print("Current pos: \(currentPos)")
                player.movePlayer(newPoint: (playBoard?.playerPoints[currentPos])!)
                //print("swipe?")
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
        //print("touch released")
        moveTouch = false
        
        ///remove last touch
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = (touches.first as? UITouch)!
        let touchPos = touch.location(in: self)
        let touchedNode = self.atPoint(_:touchPos)
        if let name = touchedNode.name{
            if name == "moveBar" || name == "moveBar2"{
                //print("touched bar")
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
        
        if enemyTimer >= (180 - enemyDifficulty){
            createEnemy()
            enemyTimer = 0
            enemyDifficulty += 0.1
        } else {
            enemyTimer += 1
        }
        if(enemiesToChange > 1 && !transitionStart){
            print(nextLevel)
            nextLevel = (playBoard?.getRandomLevel())!
            playBoard?.transitionLevel(nextLevel: nextLevel)
            transitionStart = true
            //if(loadedLevel == "circle"){
            //    playBoard?.transitionLevel(nextLevel: "semicircleLeft")
           // }
           // if(loadedLevel == "semicircleLeft"){
           //     playBoard?.transitionLevel(nextLevel: "semicircleRight")
           // }
            //     if(loadedLevel == "semicircleBottom"){
            //         transitionLevel(nextLevel: "semicircleTop")
            //     }
            
        }
        if(enemiesToChange > 2){
            /*if(loadedLevel == "circle"){
                safeChange = (playBoard?.changeLevel(nextLevel: "semicircleLeft", playerPos: currentPos))!
                playBoard?.fillCGPoints(type: "semicircleLeft")
                levelChange = true
                
            }
            if(loadedLevel == "semicircleBottom" && !levelChange){
                safeChange = (playBoard?.changeLevel(nextLevel: "semicircleTop", playerPos: currentPos))!
                levelChange = true
            }
            if(loadedLevel == "semicircleLeft" && !levelChange){
                safeChange = (playBoard?.changeLevel(nextLevel: "semicircleRight", playerPos: currentPos))!
                levelChange = true
            }*/
            print("current pos \(currentPos)")
            safeChange = (playBoard?.changeLevel(nextLevel: nextLevel, playerPos: currentPos))!
            playBoard?.fillCGPoints(type: nextLevel)
            if(safeChange < 0){
                
                safeChange = (playBoard?.changeLevel(nextLevel: nextLevel, playerPos: currentPos))!
                player.removeFromParent()
                self.endScreenTransition(phased: true)
            }
            currentPos = safeChange
            print("current pos \(currentPos) post change")
            print("After safe change")
            getIndicies()
            print("After get Indicies")
            loadedLevel = (playBoard?.levelType)!
            enemiesToChange = 0
            transitionStart = false
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
