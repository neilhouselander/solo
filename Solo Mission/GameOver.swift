//
//  GameOver.swift
//  Solo Mission
//
//  Created by Neil Houselander on 22/07/2017.
//  Copyright © 2017 Neil Houselander. All rights reserved.
//
//34:28 IN PART 5 added my own label stuff so far

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
        background.zPosition = 0
        self.addChild(background)
        
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let hiScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        hiScoreLabel.text = "High Score: \(highScoreNumber)"
        hiScoreLabel.fontSize = 125
        hiScoreLabel.fontColor = SKColor.white
        hiScoreLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.45)
        hiScoreLabel.zPosition = 1
        self.addChild(hiScoreLabel)
        
        if gameScore > highScoreNumber {
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
            hiScoreLabel.fontColor = SKColor.red
            let scaleUpAction = SKAction.scale(to: 1.3, duration: 0.5)
            let scaleBackAction = SKAction.scale(to: 1.0, duration: 0.5)
            let scaleSequence = SKAction.sequence([scaleUpAction, scaleBackAction])
            hiScoreLabel.run(scaleSequence)
        }
        
        
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        self.addChild(restartLabel)
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch:AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch) {
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(sceneToMoveTo, transition:myTransition)
                
            }
            
        }
        
        
    }
   
    
    
    
    
}


