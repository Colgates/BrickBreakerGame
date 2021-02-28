//
//  GameScene.swift
//  BrickBreakerGame
//
//  Created by Evgenii Kolgin on 27.02.2021.
//

import SpriteKit
import  GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isFingerOnPaddle = false
    
    var paddle: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    
    var brick: SKSpriteNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
//    let breakSound = SKAction.playSoundFileNamed("break", waitForCompletion: false)
    let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
//    let blipSound = SKAction.playSoundFileNamed("pongBlip", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.size = CGSize(width: 30, height: 30)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.restitution = 1
        ball.position = CGPoint(x: 512, y: 384)
        ball.physicsBody?.friction = 0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        ball.name = "ball"
        addChild(ball)
        ball.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: -25.0))
        
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        trail.targetNode = trailNode
        ball.addChild(trail)
        
        let dangerZone = SKSpriteNode(color: .red, size: CGSize(width: frame.width * 2, height: 2))
        dangerZone.physicsBody = SKPhysicsBody(rectangleOf: dangerZone.size)
        dangerZone.physicsBody?.isDynamic = false
        dangerZone.position = CGPoint(x: 0, y: 0)
        dangerZone.name = "zone"
        dangerZone.physicsBody?.contactTestBitMask = dangerZone.physicsBody?.collisionBitMask ?? 0
        addChild(dangerZone)
        
        
        paddle = SKSpriteNode(imageNamed: "paddle-1")
        paddle.size = CGSize(width: 150, height: 30)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.position = CGPoint(x: 512, y: 30)
        paddle.physicsBody?.isDynamic = false
        
        paddle.name = "paddle"
        addChild(paddle)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        let objects = nodes(at: touchLocation)
        if objects.contains(paddle) {
            isFingerOnPaddle.toggle()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isFingerOnPaddle {
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            let paddle = childNode(withName: "paddle") as! SKSpriteNode
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    func removeBlock(between block: SKNode, object: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "BrokenPlatform") {
            fireParticles.position = block.position
            addChild(fireParticles)
        }
        block.removeFromParent()
        score += 1
    }
    
    func removeBall(between ball: SKNode, object: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func gameOver() {
        let gameOver = SKSpriteNode(imageNamed: "GameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        addChild(gameOver)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "Brick" {
            removeBlock(between: nodeA, object: nodeB)
//            run(blipPaddleSound)
        } else if contact.bodyB.node?.name == "Brick" {
            removeBlock(between: nodeB, object: nodeA)
//            run(blipPaddleSound)
        }
        
        if nodeA.name == "ball" && nodeB.name == "zone" {
            removeBall(between: nodeA, object: nodeB)
            gameOver()
        } else if nodeB.name == "ball" && nodeA.name == "zone"{
            removeBall(between: nodeB, object: nodeA)
            gameOver()
        }
        
    }
}
