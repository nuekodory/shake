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
    private var circleNode : SKTouchableShapeNode?
    private var palettes : [(CGPoint, HexTripletColor)]!

    private var colorSelector = ColorSelector()
    lazy var centralManager = CentralManager()
    private var touchGeneratedNodes = Array<SKShapeNode>()

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
            label.run(SKAction.sequence([
                .fadeIn(withDuration: 2.0),
                .wait(forDuration: 4.0),
                .fadeOut(withDuration: 1.0),
                .removeFromParent()
            ]))
        }

        // create circle-shaped, palette-like node
        let r = (self.size.width + self.size.height) * 0.05
        self.circleNode = SKTouchableShapeNode.init(circleOfRadius: r)
        if let circleNode = self.circleNode {
            circleNode.fillColor = UIColor.clear
        }

        print("W: \(self.size.width) H: \(self.size.height) R: \(r)")

        // place palettes
        let palettePositions: Array<CGPoint> = [
            CGPoint(x:  r*2, y:  r*3),
            CGPoint(x: -r*2, y:  r*3),
            CGPoint(x: -r*2, y: -r*3),
            CGPoint(x:  r*2, y: -r*3)
        ]

        palettes = palettePositions.map{ pos in
            let color = colorSelector.generateColor()
            placePalette(parentNode: self.circleNode, atPoint: pos, hexColor: color)
            return (pos, color)
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        removeOldNode(nodes: &touchGeneratedNodes, numNodesToKeep: 5)
        print(pos)

        if let newNode = self.circleNode?.copy() as! SKShapeNode? {
            let color = colorSelector.generateColor()
            colorSelector.selectedColor.insert(color)
            newNode.position = pos
            newNode.fillColor = color.uiColor
            self.addChild(newNode)
            self.touchGeneratedNodes.append(newNode)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let currentNode = touchGeneratedNodes.last {
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


    private func placePalette(parentNode: SKTouchableShapeNode?, atPoint pos: CGPoint, hexColor: HexTripletColor) {
        let node = parentNode?.copy() as! SKTouchableShapeNode?

        if let node = node {
            print("pos: \(pos), color: \(hexColor)")
            node.position = pos
            node.fillColor = hexColor.uiColor
            node.run(SKAction.fadeIn(withDuration: 0.2))
            node.isUserInteractionEnabled = true
            self.addChild(node)
        }
    }

    @discardableResult
    func removeOldNode(nodes: inout [SKShapeNode], numNodesToKeep keep: Int) -> Int {
        let deletionNumber = max(0, nodes.count - keep - 1)
        print("deletionNumber: \(deletionNumber)")

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
