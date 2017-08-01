//
//  GameScene.swift
//  Solo Mission
//
//  Created by Neil Houselander on 25/06/2017.
//  Copyright © 2017 Neil Houselander. All rights reserved.
//
//AT PART 7

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    var livesNumber = 5
    
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    //declared here so can access in fire bullet()
    let player = SKSpriteNode(imageNamed: "newPlayerShip")
    
    //sound effect up here to avoid lag first time
    let bulletSound = SKAction.playSoundFileNamed("laserSound.wav", waitForCompletion: false)
    let explodeSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    
    struct PhysicsCategories{
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1   //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy: UInt32 = 0b100  //4
        
    }
    
    enum gameState {
        case preGame
        case afterGame
        case inGame
    }
    
    var currentGameState = gameState.preGame
    
    
    
    //utilities functions
    func random()->CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        
    }
    
    func random(min: CGFloat, max:CGFloat)-> CGFloat {
        return random() * (max - min) + min
    }
    
    
   
    
    //update the game area so ok for all devices, override size initialiser
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth)/2
        gameArea = CGRect(x: margin, y: 0.00, width: playableWidth, height: size.height)
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
  
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1 {
            
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.name = "Background"
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x:self.size.width/2 ,y:self.size.height*CGFloat(i)) //puts 1 background stacked on top of the other
            background.zPosition = 0
            self.addChild(background)
            
        }

        
        player.setScale(0.40)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height )//start off screen
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 65
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 5"
        livesLabel.fontSize = 65
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        //move lives & score labels onto screen at start
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.95, duration: 0.3)
        livesLabel.run(moveOnToScreenAction)
        scoreLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        let openingSequenceAction = SKAction.sequence([fadeInAction])
        tapToStartLabel.run(openingSequenceAction)
        
        
        
       
        
    }
    
    //scrolling backgrounds...
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime:TimeInterval = 0
    let amountToMovePerSecond:CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background", using: {
            backgroundNode, stop in
            
            if self.currentGameState == gameState.inGame {
                backgroundNode.position.y -= amountToMoveBackground
            }
            
            
            if backgroundNode.position.y < -self.size.height {
                backgroundNode.position.y += self.size.height*2
                
            }
        })
    }
    
    func addScore() {
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 20 || gameScore == 25 {
            startNewLevel()
            
        }
        
    }
    
    func loseALife() {
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let lifeLostSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(lifeLostSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }
        
    }
    
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let movePlayerOnToScreenAction = SKAction.moveTo(y: self.size.height*0.16, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        
        let startGameSequence = SKAction.sequence([movePlayerOnToScreenAction, startLevelAction])
        player.run(startGameSequence)
        
        
    }
    
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        
        //list all bullets & enemies with ref name then loop through & remove them all
        self.enumerateChildNodes(withName: "Bullet", using: {
            bullet, stop in
            bullet.removeAllActions()
        })
        
        self.enumerateChildNodes(withName: "Enemy", using: {
            enemy, stop in
            enemy.removeAllActions()
        })
        
        //move to new scene to show game over stats
       
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)

    }
    
    
    func changeScene() {
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let theTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: theTransition)
        
        
    }
   
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            //player hits enemy
            
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
            
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            //bullet hits enemy
            
            addScore()
            
            if body2.node != nil{
                if body2.node!.position.y > self.size.height {
                    return
                }
                else {
                    spawnExplosion(spawnPosition:body2.node!.position)
                }
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
    
    }
    
    
    func spawnExplosion(spawnPosition:CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0.00)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1.2, duration: 0.1)
        let fadeout = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explodeSound, scaleIn, fadeout, delete])
        
        explosion.run(explosionSequence)
        
        
    }
    
    //adding a level to show current level
    func levelTime() {
        
        levelNumber += 1
        
        let levelLabel = SKLabelNode(fontNamed: "The Bold Font")
        levelLabel.text = "Level: \(levelNumber)"
        levelLabel.color = SKColor.white
        levelLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        levelLabel.zPosition = 1
        levelLabel.fontSize = 80
        levelLabel.alpha = 0
        self.addChild(levelLabel)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let waitTime = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let deleteLabelAction = SKAction.removeFromParent()
        let levelSequence = SKAction.sequence([fadeIn,waitTime, fadeOut, deleteLabelAction])
        levelLabel.run(levelSequence)
    }
    
    
    func startNewLevel() {
        
//        let goLevel = SKAction.run(levelTime)
//        self.run(goLevel)
        
        levelTime()
  
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
  
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.5
        case 2: levelDuration = 1.2
        case 3: levelDuration = 1.0
        case 4: levelDuration = 0.8
        default: levelDuration = 0.5
            print("Cannot find level info")
        }
        
        
        let spawn = SKAction.run(spawnEnemy)//need to do like this as its a function being called as an action
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
    }
    
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(0.80)
        bullet.name = "Bullet"
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1.0)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    
    func spawnEnemy() {
        
    
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(0.70)
        enemy.name = "Enemy"
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Bullet | PhysicsCategories.Player
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let removeEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, removeEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame {
            enemy.run(enemySequence)
        }
        
        
        //rotate enemy
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let amountToRotate = atan2(deltaY, deltaX)
        enemy.zRotation = amountToRotate
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame {
            startGame()
        }
            
        else if currentGameState == gameState.inGame {
            fireBullet()
        }
      
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame {
               player.position.x += amountDragged
            }
            
            //stop half of the player from going off screen
            if player.position.x > gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }

        }
        
    }
    
    
    
    
}
