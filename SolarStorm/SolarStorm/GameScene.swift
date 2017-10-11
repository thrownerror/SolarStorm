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
 Level Change - transitional set up
 
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
    var enemyTimer:Int = 0
    
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
    var loadedLevel:String = ""
    
    
    
    //var logic bools
    var swellingBar = true
    var scaleModifier:CGFloat = 1.0
    var swellingPos = true
    var loadedAlready = false
    //private var spinnyNode : SKShapeNode?
    //var centerPoint : CGPoint
    
    var testBoard:movementBoard?
    
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
        levelType = "semicircleLeft"
        //levelType = "circle"
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
            testBoard = movementBoard(type: "circle")
            var indicatorCount:Int = (testBoard?.pointIndicators.count)!
            for index in 0...indicatorCount{
                self.addChild((testBoard?.pointIndicators[index])!)
            }
            createScore()
            //generateIndicators()
            createBar()
            createBar2()
            addChild(player)
            player.movePlayer(newPoint: playerPoints[0])
            
            //testPlayer.printPos()
            
            loadedAlready = true
        }
        let backgroundMusic = SKAudioNode(fileNamed: "Background.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        let background = SKSpriteNode(imageNamed: "BackgroundImage")
        background.position = CGPoint(x: 0, y:0)
        background.zPosition = -1
        self.addChild(background)
        
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
        print(scaleModifier)
        movementBar.setScale(scaleModifier)
        movementBar2.setScale(scaleModifier)
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
                    pointIndicators[index].color = .red
                }
            }
            if(next == "semicircleTop"){
                for index in 9...15{
                    pointIndicators[index].color = .red
                }
            }
            if(next == "semicircleRight"){
                for index in 5...11{
                    pointIndicators[index].color = .red
                }
            }
            if(next == "semicircleLeft"){
                for index in 0...15{
                    if(index >= 13) || (index <= 3){
                        pointIndicators[index].color = .red
                    }
                }
            }
            //determine shared spaces
            //color change
            //start countdown
        }
        if(currentLevel == "semicircleBottom"){
            if(next == "semicircleTop"){
                //impossible, player dies
                //print("problem - bot to top semicircles")
                for index in 1...7{
                    pointIndicators[index].color = .red
                }
            }
            if(next == "circle"){
                //all points safe. flash good
            }
            if(next == "semicircleLeft"){
                for index in 5...8{
                    pointIndicators[index].color = .red
                }
            }
            if(next == "semicircleRight"){
                for index in 0...3{
                    pointIndicators[index].color = .red
                }
            }
            
        }
        if(currentLevel == "semicircleTop"){
            if(next == "semicircleBottom"){
                for index in 1...7{
                    pointIndicators[index].color = .red
                }
            }
            if(next == "circle"){
                //all clear
            }
            if(next == "semicircleLeft"){
                for index in 0...3{
                    pointIndicators[index].color = .red
                }
            }
            if(next == "semicircleRight"){
                for index in 5...8{
                    pointIndicators[index].color = .red
                }
            }
        }
        if(currentLevel == "semicircleLeft"){
            if(next == "semicircleRight"){
                for index in 1...7{
                    pointIndicators[index].color = .red
                }
            }
            if(next == "semicircleTop"){
                for index in 5...8{
                    pointIndicators[index].color = .red
                }
            }
            if(next == "semicircleBottom"){
                for index in 0...3{
                    pointIndicators[index].color = .red
                }
            }
            if(next == "circle"){
                //all clear
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
                    self.endScreenTransition(win: false)
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
            if(nextLevel == "semicircleTop"){
                if(currentPos >= 9 && currentPos <= 15){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }
                //slight bug here - fix later
                //else{
                //if(currentPos != 0){
                //     currentPos = currentPos - 8
                // }
                //else{
                //    currentPos = 8
                //}
                //}
            }
            if(nextLevel == "semicircleRight"){
                if(currentPos >= 5 && currentPos <= 11){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    if(currentPos >= 12){
                        currentPos = currentPos - 12
                    }
                    else{
                        currentPos = currentPos + 4
                    }
                }
            }
            if(nextLevel == "semicircleLeft"){
                if(currentPos >= 13) || (currentPos <= 3){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    currentPos = currentPos - 4
                }
            }
        }
        if(currentLevel == "semicircleBottom"){
            if(nextLevel == "semicircleTop"){
                if(currentPos != 8 && currentPos != 0){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }//else{
                //   if(currentPos == 0){
                //       currentPos = 8
                //   }else{
                //       currentPos = 0
                //   }
                
                //}//nextLevel == "circle"
            }
            if(nextLevel == "circle"){
                if(currentPos != 8){
                    currentPos = currentPos + 8
                }
                else{
                    currentPos = 0
                }
            }
            if(nextLevel == "semicircleLeft"){
                if(currentPos >= 5 && currentPos <= 8){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    currentPos = currentPos + 4
                }
            }
            if(nextLevel == "semicircleRight"){
                if(currentPos <= 3){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }
                else{
                    currentPos = currentPos - 4
                }
            }
        }
        if(currentLevel == "semicircleTop"){
            if(nextLevel == "circle"){
                //all okay
            }
            if(nextLevel == "semicircleBot"){
                if(currentPos != 8 && currentPos != 0){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    if(currentPos == 0){
                        currentPos = 8
                    }
                    if(currentPos == 8){
                        currentPos = 0
                    }
                    
                }
            }
            if(nextLevel == "semicircleLeft"){
                if(currentPos <= 3){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    currentPos = currentPos - 4
                }
            }
            if(nextLevel == "semicircleRight"){
                if(currentPos >= 5){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    currentPos = currentPos + 4
                }
            }
        }
        if(currentLevel == "semicircleLeft"){
            if(nextLevel == "circle"){
                //good
            }
            if(nextLevel == "semicircleRight"){
                if(currentPos != 0 && currentPos != 8){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    if(currentPos == 0){
                        currentPos = 8
                    }else{
                        currentPos = 0
                    }
                }
            }
            if(nextLevel == "semicircleTop"){
                if(currentPos >= 5){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    currentPos = currentPos + 4
                }
            }
            
            if(nextLevel == "semicircleBottom"){
                if(currentPos <= 3){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    currentPos = currentPos - 4
                }
            }
        }
        if(currentLevel == "semicircleRight"){
            if(nextLevel == "circle"){
                //good
            }
            if(nextLevel == "semicircleLeft"){
                if(currentPos != 0 && currentPos != 8){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    if(currentPos == 0){
                        currentPos = 8
                    }else{
                        currentPos = 0
                    }
                }
            }
            if(nextLevel == "semicircleTop"){
                if(currentPos <= 3){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    currentPos = currentPos - 4
                }
            }
            if(nextLevel == "semicircleBottom"){
                if(currentPos >= 5){
                    player.removeFromParent()
                    self.endScreenTransition(win: false)
                }else{
                    currentPos = currentPos + 4
                }
            }
        }
        fillCGPoints(type: nextLevel)
        print("after fill points")
        player.movePlayer(newPoint: playerPoints[currentPos])
        
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
        if(type == "semicircleTop"){
            loadedLevel = "semicircleTop"
            playerPoints.append(CGPoint(x:1*circleRadius, y:0 * circleRadius))
            playerPoints.append(CGPoint(x:(sqrt(3)/2)*circleRadius, y:1/2 * circleRadius))
            playerPoints.append(CGPoint(x:(sqrt(2)/2) * circleRadius, y: (sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:(1/2 * circleRadius), y: ((sqrt(3)/2) * circleRadius)))
            
            playerPoints.append(CGPoint(x: 0, y:1 * circleRadius))
            
            playerPoints.append(CGPoint(x:-(1/2 * circleRadius), y: ((sqrt(3)/2) * circleRadius)))
            playerPoints.append(CGPoint(x:-(sqrt(2)/2) * circleRadius, y: (sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:-(sqrt(3)/2)*circleRadius, y:1/2 * circleRadius))
            
            playerPoints.append(CGPoint(x:-1*circleRadius, y:0 * circleRadius))
        }
        if(type == "semicircleRight"){
            loadedLevel = "semicircleRight"
            playerPoints.append(CGPoint(x: 0, y:-1 * circleRadius))
            
            playerPoints.append(CGPoint(x:(1/2 * circleRadius), y: -((sqrt(3)/2) * circleRadius)))
            playerPoints.append(CGPoint(x:(sqrt(2)/2) * circleRadius, y: -(sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:(sqrt(3)/2)*circleRadius, y:-1/2 * circleRadius))
            
            playerPoints.append(CGPoint(x:1*circleRadius, y:0 * circleRadius))
            
            playerPoints.append(CGPoint(x:(sqrt(3)/2)*circleRadius, y:1/2 * circleRadius))
            playerPoints.append(CGPoint(x:(sqrt(2)/2) * circleRadius, y: (sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:(1/2 * circleRadius), y: ((sqrt(3)/2) * circleRadius)))
            
            playerPoints.append(CGPoint(x: 0, y:1 * circleRadius))
        }
        if(type == "semicircleLeft"){
            loadedLevel = "semicircleLeft"
            playerPoints.append(CGPoint(x: 0, y:1 * circleRadius))
            
            playerPoints.append(CGPoint(x:-(1/2 * circleRadius), y: ((sqrt(3)/2) * circleRadius)))
            playerPoints.append(CGPoint(x:-(sqrt(2)/2) * circleRadius, y: (sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:-(sqrt(3)/2)*circleRadius, y:1/2 * circleRadius))
            
            playerPoints.append(CGPoint(x:-1*circleRadius, y:0 * circleRadius))
            
            playerPoints.append(CGPoint(x:-(sqrt(3)/2)*circleRadius, y:-1/2 * circleRadius))
            playerPoints.append(CGPoint(x:-(sqrt(2)/2) * circleRadius, y: -(sqrt(2)/2 * circleRadius)))
            playerPoints.append(CGPoint(x:-(1/2 * circleRadius), y: -((sqrt(3)/2) * circleRadius)))
            
            playerPoints.append(CGPoint(x: 0, y:-1 * circleRadius))
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
                self.endScreenTransition(win: false)
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
    
    //Projectile Collision - James
    func projectileCollision(projectile: SKSpriteNode, enemy: SKSpriteNode) {
        //print("Hit")
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
    
    func endScreenTransition(win: Bool){
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, win: win, destroyed: self.enemiesDestroyed)
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
                //Clockwise movement
                if(lastTouch!.y < pos.y){//pos.y >= 0){
                    currentPos = currentPos + 1
                    if loadedLevel == "circle"{
                        if(currentPos == playerPoints.count){
                            currentPos = 0
                        }
                        
                    }
                    if loadedLevel == "semicircleTop" || loadedLevel == "semicircleBottom" || loadedLevel == "semicircleLeft" || loadedLevel == "semicircleRight"{
                        if(currentPos >= playerPoints.count){
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
                            currentPos = playerPoints.count - 1
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
                if(currentPos == playerPoints.count){
                    currentPos = 0;
                }
                lastTouch = pos
                print("Current pos: \(currentPos)")
                player.movePlayer(newPoint: playerPoints[currentPos])
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
            if name == "moveBar" || name == "moveBar2"{
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
                transitionLevel(nextLevel: "semicircleLeft")
            }
            if(loadedLevel == "semicircleLeft"){
                transitionLevel(nextLevel: "semicircleRight")
            }
            //     if(loadedLevel == "semicircleBottom"){
            //         transitionLevel(nextLevel: "semicircleTop")
            //     }
            
        }
        if(enemiesToChange > 3){
            if(loadedLevel == "circle"){
                changeLevel(nextLevel: "semicircleLeft")
                levelChange = true
                
            }
            if(loadedLevel == "semicircleBottom" && !levelChange){
                changeLevel(nextLevel: "semicircleTop")
                levelChange = true
            }
            if(loadedLevel == "semicircleLeft" && !levelChange){
                changeLevel(nextLevel: "semicircleRight")
                levelChange = true
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
