 //
//  movementBoard.swift
//  SolarStorm
//
//  Created by student on 10/11/17.
//  Copyright © 2017 student. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class movementBoard{
    
    let circleRadius: Double
    //var activePos: Int
    var levelType:String
    var pointIndicators: Array<SKSpriteNode> = Array()
    let levelOptions = ["circle", "semicircleLeft", "semicircleRight", "semicircleTop", "semicircleBot"]
    //var currentPos: Int
    var playerPoints: [CGPoint] = []
    
    init(){
        circleRadius = 270
        //currentPos = 0
        levelType = "circle"
        //activePos = 0
        fillCGPoints(type: levelType)
    }
    init(type: String){
        circleRadius = 270
        //currentPos = 0
        levelType = type
        //activePos = 0
        fillCGPoints(type: levelType)
    }
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    func getRandomLevel() -> String{
        return levelOptions[Int(arc4random_uniform(4))]
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
            //self.addChild(tempPlayer)
        }
    }
    func transitionLevel(nextLevel: String) -> String{
       // print("in transition level")
        var currentLevel = levelType
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
                //impossible, player dies
                //print("problem - bot to top semicircles")
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
    func changeLevel(nextLevel: String, playerPos: Int) -> Int{
        print("top of change level")
        var currentPos = playerPos
        var currentLevel = levelType
        if(currentLevel == "circle"){
            if(nextLevel == "semicircleBottom"){
                if(currentPos >= 1 && currentPos <= 7){
                    currentPos = -1
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
                    currentPos = -1
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
                    currentPos = -1
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
                    currentPos = -1
                }else{
                    currentPos = currentPos - 4
                }
            }
        }
        if(currentLevel == "semicircleBottom"){
            if(nextLevel == "semicircleTop"){
                if(currentPos != 8 && currentPos != 0){
                    currentPos = -1
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
                    currentPos = -1
                }else{
                    currentPos = currentPos + 4
                }
            }
            if(nextLevel == "semicircleRight"){
                if(currentPos <= 3){
                    currentPos = -1
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
                    currentPos = -1
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
                    currentPos = -1
                }else{
                    currentPos = currentPos - 4
                }
            }
            if(nextLevel == "semicircleRight"){
                if(currentPos >= 5){
                    currentPos = -1
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
                    currentPos = -1
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
                    currentPos = -1
                }else{
                    currentPos = currentPos + 4
                }
            }
            
            if(nextLevel == "semicircleBottom"){
                if(currentPos <= 3){
                    currentPos = -1
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
                    currentPos = -1
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
                    currentPos = -1
                }else{
                    currentPos = currentPos - 4
                }
            }
            if(nextLevel == "semicircleBottom"){
                if(currentPos >= 5){
                    currentPos = -1
                }else{
                    currentPos = currentPos + 4
                }
            }
        }
        fillCGPoints(type: nextLevel)
        print("after fill points")
        return currentPos

        //player.movePlayer(newPoint: playerPoints[currentPos])
        
    }
    func fillCGPoints(type: String){
        playerPoints.removeAll()
        //safePoints.removeAll()
        if(type == "circle"){
            //loopable = true
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
            /*for int in 0...15{
             safePoints.append(false)
             }*/
            
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
