//
//  GameScene.swift
//  SolarStorm
//  Manages the main game logic and presentation for the
//  Tempest-styled endless shooter, SolarStorm
//  Created by Robert and James October 2017
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
  
  //MARK: - Player Management -
  var playerPoints: [CGPoint] = []
  var player = PlayerNode()
  var currentPos = 0 //player location
  
  //MARK: - Level Controls -
  var playBoard:MovementBoard?
  var levelType:String = "circle"
  //Movement markers
  var indicators: Array<SKSpriteNode> = Array()
  
  //MARK: - Controls -
  let swipeWindow:CGFloat = 6 //sensitivity
  var nextLevel = ""
  var movementBarL = SKShapeNode()
  var movementBarR = SKShapeNode()
  var moveTouch:Bool = false
  var loopable:Bool = true
  var loadedLevel:String = "circle"
  var lastTouch: CGPoint?
  //Bar feedback
  var swellingBar = true
  var scaleModifier:CGFloat = 1.0
  var swellingPos = true
  
  //MARK: - Level Transitions -
  var enemiesToChange = 0
  var safeChange = 0
  var transitionStart = false
  
  //MARK: - Enemy controls -
  var enemies: Array<SKSpriteNode> = Array()
  var enemyTimer:Double = 0
  var enemyDifficulty:Double = 0
  let actionDelete = SKAction.removeFromParent()
  
  private var lastUpdateTime : TimeInterval = 0
  private var label : SKLabelNode?
  
  //MARK: - Scoring -
  var enemiesDestroyed = 0
  var enemiesEscaped = 0
  var destroyedLabel = SKLabelNode()
  var escapedLabel = SKLabelNode()
  
  
  //MARK: - Loading Logic -
  var loadedAlready = false
  
  //MARK: - didMove -
  override func didMove(to view: SKView){
    self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    self.scaleMode = .aspectFill
  }
  
  //MARK: - Scene Did Load -
  override func sceneDidLoad() {
    
    self.lastUpdateTime = 0
    
    physicsWorld.gravity = CGVector.zero
    physicsWorld.contactDelegate = self
    
    levelType = "circle"
    if(!loadedAlready){
      playBoard = MovementBoard(type: "circle")
      addChild(player)
      player.movePlayer(newPoint: (playBoard?.playerPoints[0])!)
      //Create UI
      getIndicies()
      createScore()
      createBarL()
      createBarR()
      
      //Clarifiers to avoid double loading
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
  
  //MARK: - getIndicies -
  func getIndicies(){
    //Robert - Clean array and refill with new board
    for index in indicators{
      index.removeFromParent()
    }
    indicators = (playBoard?.pointIndicators)!
    for point in indicators{
      self.addChild(point)
    }
  }
  
  //MARK: - createScore -
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
  
  //MARK: - createBarL -
  func createBarL() ->Void{
    //Robert - these two methods establish the "tappable" UI elements
    movementBarL = SKShapeNode(rectOf: CGSize(width: 20, height: 400), cornerRadius: 12)
    movementBarL.position = CGPoint(x: 330, y: 0)
    movementBarL.fillColor = .red
    movementBarL.strokeColor = .blue
    movementBarL.lineWidth = 2
    movementBarL.name = "moveBarL"
    self.addChild(movementBarL)
  }
  //MARK: - createBearR -
  func createBarR() ->Void{
    movementBarR = SKShapeNode(rectOf: CGSize(width: 20, height: 400), cornerRadius: 12)
    movementBarR.position = CGPoint(x: -330, y: 0)
    movementBarR.fillColor = .red
    movementBarR.strokeColor = .blue
    movementBarR.lineWidth = 2
    movementBarR.name = "moveBarR"
    self.addChild(movementBarR)
  }
  //MARK: - swellBar -
  func swellBar() ->Void{
    //Robert - controls swell to incite clicking by user
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
    movementBarL.setScale(scaleModifier)
    movementBarR.setScale(scaleModifier)
  }
  
  //MARK: - createEnemy -
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
  
  //MARK: - fireProjectile -
  //James - Shoots bullet from current lane to center of screen
  func fireProjectile(){
    let center = CGPoint(x: 0, y: 0)
    
    let projectile = SKSpriteNode(imageNamed: "Projectile.png")
    projectile.position = (playBoard?.playerPoints[currentPos])!
    let angle = atan2(projectile.position.y - 0, projectile.position.x - 0) + CGFloat(Double.pi)
    
    projectile.zRotation = angle
    
    run(SKAction.playSoundFileNamed("FireSound.mp3", waitForCompletion: false))
    
    let bullet = SKEmitterNode(fileNamed: "PlayerBullet")!
    bullet.position = center
    
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
  
  //MARK: - projectileCollision -
  //James - Projectile collision with enemy
  func projectileCollision(projectile: SKSpriteNode, enemy: SKSpriteNode) {
    projectile.removeFromParent()
    enemy.removeFromParent()
    run(SKAction.playSoundFileNamed("EnemyDeathSound.mp3", waitForCompletion: false))
    enemiesDestroyed += 1
    enemiesToChange += 1
    self.destroyedLabel.text = "Enemy Ships Destroyed: \(enemiesDestroyed)"
  }
  
  
  //MARK: - distancePoints -
  //Robert - Distance between two points
  func distancePoints(a: CGPoint, b: CGPoint) -> CGFloat{
    let xDistance = a.x - b.x
    let yDistance = a.y - b.y
    return CGFloat(sqrt((xDistance * yDistance) + (yDistance * yDistance)))
  }
  //MARK: - endScreenTransition -
  //James - transitions to GameOverScene
  func endScreenTransition(phased: Bool){
    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
    let gameOverScene = GameOverScene(size: self.size, phased: phased, destroyed: self.enemiesDestroyed)
    self.view?.presentScene(gameOverScene, transition: reveal)
  }
  
  //MARK: - touchDown -
  //Robert - On touch, fire a projectile and get point
  func touchDown(atPoint pos : CGPoint) {
    
    lastTouch = pos
    fireProjectile()
  }
  
  //MARK: - touchMoved -
  //Robert - When touch pos has moved
  func touchMoved(toPoint pos : CGPoint) {
    
    //Get Distance between points. If greater than swipe window, treat like a swipe
    let distanceBetween = distancePoints(a: pos, b: lastTouch!)
    if(distanceBetween > swipeWindow){
      if(moveTouch){
        //Clockwise movement - loops player position on Circle, stops on others.
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
        }
          //Counterclockwise movement - same checks as above
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
        }
        if(currentPos == playBoard!.playerPoints.count){
          currentPos = 0;
        }
        lastTouch = pos
        //print("Current pos: \(currentPos)")
        player.movePlayer(newPoint: (playBoard?.playerPoints[currentPos])!)
        swellingBar = false;
      }
    }
  }
  
  //MARK: - touchUp -
  func touchUp(atPoint pos : CGPoint) {
    moveTouch = false
  }
  
  //MARK: - touchesBegan -
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch: UITouch = (touches.first)!
    let touchPos = touch.location(in: self)
    let touchedNode = self.atPoint(_:touchPos)
    if let name = touchedNode.name{
      if name == "moveBarL" || name == "moveBarR"{
        moveTouch = true
      }
    }
    for t in touches { self.touchDown(atPoint: t.location(in: self)) }
  }
  
  //MARK: - touchesMoved -
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
  }
  
  //MARK: - touchesEnded
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
  
  //MARK: - update -
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    //var levelChange = false
    if(swellingBar){
      swellBar()
    }
    else{
      movementBarL.xScale = 1.0;
      movementBarR.yScale = 1.0;
    }
    // Initialize _lastUpdateTime if it has not already been
    if (self.lastUpdateTime == 0) {
      self.lastUpdateTime = currentTime
    }
    
    // Calculate time since last update
    
    self.lastUpdateTime = currentTime
    //Increases time between enemy spawns over time
    if enemyTimer >= (180 - enemyDifficulty){
      createEnemy()
      enemyTimer = 0
      enemyDifficulty += 0.1
    } else {
      enemyTimer += 1
    }
    
    //Changes level at set intervals.
    //Signals a change will happen
    if(enemiesToChange > 5 && !transitionStart){
      //print(nextLevel)
      nextLevel = (playBoard?.getRandomLevel())!
      playBoard?.transitionLevel(nextLevel: nextLevel)
      transitionStart = true
      
    }
    //Changes level
    if(enemiesToChange > 8){
      //print("current pos \(currentPos)")
      safeChange = (playBoard?.changeLevel(nextLevel: nextLevel, playerPos: currentPos))!
      playBoard?.fillCGPoints(type: nextLevel)
      //If player has died
      if(safeChange < 0){
        safeChange = (playBoard?.changeLevel(nextLevel: nextLevel, playerPos: currentPos))!
        player.removeFromParent()
        self.endScreenTransition(phased: true)
      }
      //Otherwise, continue on and reset
      currentPos = safeChange
      getIndicies()
      loadedLevel = (playBoard?.levelType)!
      enemiesToChange = 0
      transitionStart = false
    }
  }
  
  //MARK: - didBegin -
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
