//
//  GameScene.swift
//  shake
//
//  Created by Naoki Nakamura on 2019-06-06.
//  Copyright © 2019 sohzoh. All rights reserved.
//

import SpriteKit
import GameplayKit
import os.log

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var circleNode : SKShapeNode?

    private var colorSelector = ColorSelector()
    lazy var centralManager = CentralManager()
    private var circleNodes = Array<SKShapeNode>()

    let maxNumberOfCircles = 5

    override func sceneDidLoad() {
        super.sceneDidLoad()
        centralManager = CentralManager()

    }

    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }

        let r = (self.size.width + self.size.height) * 0.08
        self.circleNode = SKShapeNode.init(circleOfRadius: r)

        if let circleNode = self.circleNode {
            circleNode.fillColor = UIColor.white
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        removeOldNode(nodes: &circleNodes, numNodesToKeep: 5)

        if let newNode = self.circleNode?.copy() as! SKShapeNode? {
            let color = colorSelector.generateColor()
            colorSelector.advertisedColor.insert(color)
            newNode.position = pos
            newNode.fillColor = color.uiColor
            self.addChild(newNode)
            self.circleNodes.append(newNode)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let currentNode = circleNodes.last {
            currentNode.position = pos
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            let color = HexTripletColor()
            n.position = pos
            n.strokeColor = UIColor(red: color.red, green: color.green, blue: color.blue)
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }


    @discardableResult
    func removeOldNode(nodes: inout [SKShapeNode], numNodesToKeep keep: Int) -> Int {
        let deletionNumber = max(0, circleNodes.count - keep - 1)

        for _ in 0..<deletionNumber {
            let oldestNode = nodes.removeFirst()
            oldestNode.run(SKAction.sequence([
                .group([.fadeOut(withDuration: 0.5), .scale(by: 0.0, duration: 0.5)]),
                .removeFromParent()
            ]))
        }
        return deletionNumber
    }
}
