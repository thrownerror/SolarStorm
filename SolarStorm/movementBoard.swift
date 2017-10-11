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
    var activePos: Int
    var levelType:String
    var pointIndicators: Array<SKSpriteNode> = Array()
    var currentPos: Int
    var playerPoints: [CGPoint] = []
    
    init(){
        circleRadius = 270
        currentPos = 0
        levelType = "circle"
        activePos = 0
        fillCGPoints(type: levelType)
    }
    init(type: String){
        circleRadius = 270
        currentPos = 0
        levelType = type
        activePos = 0
        fillCGPoints(type: levelType)
    }
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
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
    func transitionLevel(nextLevel: String){
        print("in transition level")
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
    func changeLevel(nextLevel: String) -> Bool{
        print("top of change level")
        var currentLevel = levelType
        if(currentLevel == "circle"){
            if(nextLevel == "semicircleBottom"){
                if(currentPos >= 1 && currentPos <= 7){
                    return false
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
                    return false
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
                        return false
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
                    return false
                }else{
                    currentPos = currentPos - 4
                }
            }
        }
        if(currentLevel == "semicircleBottom"){
            if(nextLevel == "semicircleTop"){
                if(currentPos != 8 && currentPos != 0){
                    return false
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
                    return false
                }else{
                    currentPos = currentPos + 4
                }
            }
            if(nextLevel == "semicircleRight"){
                if(currentPos <= 3){
                    return false
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
                    return false
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
                    return false
                }else{
                    currentPos = currentPos - 4
                }
            }
            if(nextLevel == "semicircleRight"){
                if(currentPos >= 5){
                    return false
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
                    return false
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
                    return false
                }else{
                    currentPos = currentPos + 4
                }
            }
            
            if(nextLevel == "semicircleBottom"){
                if(currentPos <= 3){
                    return false
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
                    return false
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
                    return false
                }else{
                    currentPos = currentPos - 4
                }
            }
            if(nextLevel == "semicircleBottom"){
                if(currentPos >= 5){
                    return false
                }else{
                    currentPos = currentPos + 4
                }
            }
        }
        return true
        fillCGPoints(type: nextLevel)
        print("after fill points")
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
