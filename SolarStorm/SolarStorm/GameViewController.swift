//
//  GameViewController.swift
//  SolarStorm
//
//  Created by student on 9/21/17.
//  Copyright © 2017 student. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //inital loading of main menu
        let scene = MainMenuScene(size: view.bounds.size, score: 0)
        scene.scaleMode = .resizeFill
        
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
        
    }
 
 
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
