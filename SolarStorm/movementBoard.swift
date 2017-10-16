 //
 //  movementBoard.swift
 //  SolarStorm
 //   Acts as a custom way to control the player's movement within the game, and as the reference
 //   for information about positional logic in game.
 //  Created by Robert on 10/11/17.
 //  Copyright © 2017. All rights reserved.
 //
 
 import SpriteKit
 import GameplayKit
 
 class MovementBoard{
  
  //MARK: - class variables -
  let circleRadius: Double
  var levelType:String
  var pointIndicators: Array<SKSpriteNode> = Array()
  let levelOptions = ["circle", "semicircleLeft", "semicircleRight", "semicircleTop", "semicircleBot"]
  var playerPoints: [CGPoint] = []
  
  //MARK: - init -
  init(){
    circleRadius = 270
    levelType = "circle"
    fillCGPoints(type: levelType)
  }
  //MARK: - parameterized init -
  //Unused here, remaining for possible future extension purposes
  init(type: String){
    circleRadius = 270
    levelType = type
    fillCGPoints(type: levelType)
  }
  //MARK: - error init -
  required init?(coder aDecoder: NSCoder){
    fatalError("init(coder:) has not been implemented")
  }
  //MARK: - getRandomLevel -
  func getRandomLevel() -> String{
    return levelOptions[Int(arc4random_uniform(4))]
  }
  //MARK: - generateIndicators -
  func generateIndicators(){
    for indicator in pointIndicators{
      indicator.removeFromParent()
    }
    pointIndicators.removeAll()
    for point in playerPoints{
      let tempIcon = SKSpriteNode(color: .blue, size: CGSize(width:5, height: 8))
      tempIcon.position = point
      tempIcon.zPosition = 0
      tempIcon.name = "tempIcon"
      pointIndicators.append(tempIcon)
    }
  }
  //MARK: - transitionLevel -
  //Return remains for debug purposes, not used in final version, but remaining for possible future extension
  func transitionLevel(nextLevel: String) -> String{
    let currentLevel = levelType
    let next = nextLevel
    //Based off of the current level, figures out the safe points (shared between two levels)
    //and changes all the icons that are not shared (and will kill the player if they are there at change) red
    if(currentLevel == "circle")
    {
      if(next == "semicircleBottom"){
        //safe: 0/8-15. flash good
        //flash 1-7 bad
        for index in 1...7{
          pointIndicators[index].color = .red
        }
        return "semicircleBottom"
      }
      if(next == "semicircleTop"){
        for index in 9...15{
          pointIndicators[index].color = .red
        }
        return "semicircleTop"
      }
      if(next == "semicircleRight"){
        for index in 5...11{
          pointIndicators[index].color = .red
        }
        return "semicircleRight"
      }
      if(next == "semicircleLeft"){
        for index in 0...15{
          if(index >= 13) || (index <= 3){
            pointIndicators[index].color = .red
          }
        }
        return "semicircleLeft"
      }
    }
    if(currentLevel == "semicircleBottom"){
      if(next == "semicircleTop"){
        for index in 1...7{
          pointIndicators[index].color = .red
        }
        return "semicircleTop"
      }
      if(next == "circle"){
        //all points safe. flash good
        return "circle"
      }
      if(next == "semicircleLeft"){
        for index in 5...8{
          pointIndicators[index].color = .red
        }
        return "semicircleLeft"
      }
      if(next == "semicircleRight"){
        for index in 0...3{
          pointIndicators[index].color = .red
        }
        return "semicircleRight"
      }
      
    }
    if(currentLevel == "semicircleTop"){
      if(next == "semicircleBottom"){
        for index in 1...7{
          pointIndicators[index].color = .red
        }
        return "semicircleBotom"
      }
      if(next == "circle"){
        //all clear
        return "circle"
      }
      if(next == "semicircleLeft"){
        for index in 0...3{
          pointIndicators[index].color = .red
        }
        return "semicircleLeft"
      }
      if(next == "semicircleRight"){
        for index in 5...8{
          pointIndicators[index].color = .red
        }
        return "semicircleRight"
      }
    }
    if(currentLevel == "semicircleLeft"){
      if(next == "semicircleRight"){
        for index in 1...7{
          pointIndicators[index].color = .red
        }
        return "semicircleRight"
      }
      if(next == "semicircleTop"){
        for index in 5...8{
          pointIndicators[index].color = .red
        }
        return "semicircleTop"
      }
      if(next == "semicircleBottom"){
        for index in 0...3{
          pointIndicators[index].color = .red
        }
        return "semicircleBottom"
      }
      if(next == "circle"){
        //all clear
        return "circle"
      }
    }
    if(currentLevel == "semicircleRight"){
      if(next == "semicircleLeft"){
        for index in 1...7{
          pointIndicators[index].color = .red
        }
        return "semicircleLeft"
      }
      if(next == "semicircleTop"){
        for index in 0...3{
          pointIndicators[index].color = .red
        }
        return "semicircleTop"
      }
      if(next == "semicircleBottom"){
        for index in 5...8{
          pointIndicators[index].color = .red
        }
        return "semicircleBottom"
      }
      if(next == "circle"){
        //all clear
        return "circle"
      }
    }
    return "error"
    
  }
  //MARK: - changeLevel -
  func changeLevel(nextLevel: String, playerPos: Int) -> Int{
    //Changes the level between the current and next.
    //Returns -1 if player is on a point lost in transition, saying player is dead
    //Uses currentPos as return value to avoid declaring new variable
    var currentPos = playerPos
    let currentLevel = levelType
    
    if(currentLevel == "circle"){
      if(nextLevel == "semicircleBottom"){
        if(currentPos >= 1 && currentPos <= 7){
          currentPos = -1
          return currentPos
        }
        else{
          if(currentPos != 0){
            currentPos = currentPos - 8
            return currentPos
          }
          else{
            currentPos = 8
            return currentPos
          }
        }
      }
      if(nextLevel == "semicircleTop"){
        if(currentPos >= 9 && currentPos <= 15){
          currentPos = -1
          return currentPos
        }
      }
      if(nextLevel == "semicircleRight"){
        if(currentPos >= 5 && currentPos <= 11){
          currentPos = -1
          return currentPos
        }else{
          if(currentPos >= 12){
            currentPos = currentPos - 12
            return currentPos
          }
          else{
            currentPos = currentPos + 4
            return currentPos
          }
        }
      }
      if(nextLevel == "semicircleLeft"){
        if(currentPos >= 13) || (currentPos <= 3){
          currentPos = -1
          return currentPos
        }else{
          currentPos = currentPos - 4
          return currentPos
        }
      }
    }
    if(currentLevel == "semicircleBottom"){
      if(nextLevel == "semicircleTop"){
        if(currentPos != 8 && currentPos != 0){
          currentPos = -1
          return currentPos
        }
      }
      if(nextLevel == "circle"){
        if(currentPos != 8){
          currentPos = currentPos + 8
          return currentPos
        }
        else{
          currentPos = 0
          return currentPos
        }
      }
      if(nextLevel == "semicircleLeft"){
        if(currentPos >= 5 && currentPos <= 8){
          currentPos = -1
          return currentPos
        }else{
          currentPos = currentPos + 4
          return currentPos
        }
      }
      if(nextLevel == "semicircleRight"){
        if(currentPos <= 3){
          currentPos = -1
          return currentPos
        }
        else{
          currentPos = currentPos - 4
          return currentPos
        }
      }
    }
    if(currentLevel == "semicircleTop"){
      if(nextLevel == "circle"){
        //all okay
        return currentPos
      }
      if(nextLevel == "semicircleBot"){
        if(currentPos != 8 && currentPos != 0){
          currentPos = -1
          return currentPos
        }else{
          if(currentPos == 0){
            currentPos = 8
            return currentPos
          }
          if(currentPos == 8){
            currentPos = 0
            return currentPos
          }
          
        }
      }
      if(nextLevel == "semicircleLeft"){
        if(currentPos <= 3){
          currentPos = -1
          return currentPos
        }else{
          currentPos = currentPos - 4
          return currentPos
        }
      }
      if(nextLevel == "semicircleRight"){
        if(currentPos >= 5){
          currentPos = -1
          return currentPos
        }else{
          currentPos = currentPos + 4
          return currentPos
        }
      }
    }
    if(currentLevel == "semicircleLeft"){
      if(nextLevel == "circle"){
        //good
        return currentPos
      }
      if(nextLevel == "semicircleRight"){
        if(currentPos != 0 && currentPos != 8){
          currentPos = -1
          return currentPos
        }else{
          if(currentPos == 0){
            currentPos = 8
            return currentPos
          }else{
            currentPos = 0
            return currentPos
          }
        }
      }
      if(nextLevel == "semicircleTop"){
        if(currentPos >= 5){
          currentPos = -1
          return currentPos
        }else{
          currentPos = currentPos + 4
          return currentPos
        }
      }
      
      if(nextLevel == "semicircleBottom"){
        if(currentPos <= 3){
          currentPos = -1
          return currentPos
        }else{
          currentPos = currentPos - 4
          return currentPos
        }
      }
    }
    if(currentLevel == "semicircleRight"){
      if(nextLevel == "circle"){
        //good
        return currentPos
      }
      if(nextLevel == "semicircleLeft"){
        if(currentPos != 0 && currentPos != 8){
          currentPos = -1
          return currentPos

        }else{
          if(currentPos == 0){
            currentPos = 8
            return currentPos

          }else{
            currentPos = 0
            return currentPos

          }
        }
      }
      if(nextLevel == "semicircleTop"){
        if(currentPos <= 3){
          currentPos = -1
          return currentPos

        }else{
          currentPos = currentPos - 4
          return currentPos

        }
      }
      if(nextLevel == "semicircleBottom"){
        if(currentPos >= 5){
          currentPos = -1
          return currentPos

        }else{
          currentPos = currentPos + 4
          return currentPos

        }
      }
    }
    fillCGPoints(type: nextLevel)
    //print("after fill points")
    return currentPos

  }
  
  //MARK: - fillCGPoints -
  //Fills the board based off of the level. Uses unit circle as the basis. Generates indicator at the end
  func fillCGPoints(type: String){
    playerPoints.removeAll()
    if(type == "circle"){
      levelType = "circle"
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
   
    }
    if(type == "semicircleBottom"){
      levelType = "semicircleBottom"
      
      
      playerPoints.append(CGPoint(x:-1*circleRadius, y:0 * circleRadius))
      
      playerPoints.append(CGPoint(x:-(sqrt(3)/2)*circleRadius, y:-1/2 * circleRadius))
      playerPoints.append(CGPoint(x:-(sqrt(2)/2) * circleRadius, y: -(sqrt(2)/2 * circleRadius)))
      playerPoints.append(CGPoint(x:-(1/2 * circleRadius), y: -((sqrt(3)/2) * circleRadius)))
      
      playerPoints.append(CGPoint(x: 0, y:-1 * circleRadius))
      
      playerPoints.append(CGPoint(x:(1/2 * circleRadius), y: -((sqrt(3)/2) * circleRadius)))
      playerPoints.append(CGPoint(x:(sqrt(2)/2) * circleRadius, y: -(sqrt(2)/2 * circleRadius)))
      playerPoints.append(CGPoint(x:(sqrt(3)/2)*circleRadius, y:-1/2 * circleRadius))
      
      playerPoints.append(CGPoint(x:1*circleRadius, y:0 * circleRadius))
    }
    
    if(type == "semicircleTop"){
      levelType = "semicircleTop"
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
      levelType = "semicircleRight"
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
      levelType = "semicircleLeft"
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
  
  
  
  
}
