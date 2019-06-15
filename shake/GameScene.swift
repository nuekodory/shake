//
//  GameScene.swift
//  shake
//
//  Created by Naoki Nakamura on 2019-06-06.
//  Copyright © 2019 sohzoh. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreLocation
import os.log


typealias Palette = (CGPoint, HexTripletColor)

class GameScene: SKScene {

    private var peripheralHandler: PeripheralHandler!
    private var locationHandler: LocationHandler!
    private var label : SKLabelNode?
    private var paletteNode: SKTouchableShapeNode?
    private var ballNode: SKTouchableShapeNode?
    private var palettes : [Palette]!

    var receivedColor = Set<HexTripletColor>()
    private var colorSelector = ColorSelector()
    private var ballNodes = [SKShapeNode]()
    private var numPaletteTouch = 0

    let maxNumberOfCircles = 5

    var randomPosition: CGPoint {
        let x = CGFloat.random(in: -self.size.width/2...self.size.width/2)
        let y = CGFloat.random(in: -self.size.height/2...self.size.height/2)
        return CGPoint(x: x, y: y)
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()
        peripheralHandler = PeripheralHandler()
        locationHandler = LocationHandler()
        self.backgroundColor = .white
    }

    override func didMove(to view: SKView) {

        NotificationCenter.default.addObserver(forName: .newReceivedColor, object: nil, queue: nil,
                using: { notification in
                    if let color = notification.object as? HexTripletColor {
                        if self.receivedColor.insert(color).inserted {
                            self.drawNewCircle(shapeNode: self.ballNode, at: self.randomPosition, color: color)
                        }
                    }
                })

        NotificationCenter.default.addObserver(forName: .paletteTouchDown, object: nil, queue: nil,
                using: { notification in
                    if let node = notification.object as? SKTouchableShapeNode {
                        if let nodeColor = HexTripletColor(hexTriplet: node.name) {
                            self.peripheralHandler.advertiseSelectedColor(color: nodeColor)
                        }

                        self.numPaletteTouch += 1
                        if self.numPaletteTouch <= 10 {
                            return
                        } else {
                            node.run(.sequence([
                                .fadeOut(withDuration: 0.2),
                                .run{
                                    let nextColor = self.colorSelector.generateColor()
                                    node.fillColor = nextColor.uiColor
                                    node.name = nextColor.stringDescription
                                },
                                .fadeIn(withDuration: 0.4)
                            ]))
                            self.numPaletteTouch = 0
                        }
                    }
                })

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
        self.paletteNode = SKTouchableShapeNode.init(circleOfRadius: r)
        self.ballNode = SKTouchableShapeNode.init(circleOfRadius: r * 0.6)

        paletteNode?.fillColor = UIColor.clear
        ballNode?.fillColor = UIColor.clear

        // place palettes
        let palettePositions: Array<CGPoint> = [
            CGPoint(x:  r*2, y:  r*3),
            CGPoint(x: -r*2, y:  r*3),
            CGPoint(x: -r*2, y: -r*3),
            CGPoint(x:  r*2, y: -r*3)
        ]

        palettes = palettePositions.map { pos in (pos, colorSelector.generateColor()) }
        palettes.forEach{ placePalette(copyingNode: self.paletteNode, palette: $0) }
        locationHandler.manager.requestWhenInUseAuthorization()
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        removeOldNode(nodes: &ballNodes, numNodesToKeep: 5)
        let generatedColor = colorSelector.generateColor()
        drawNewCircle(shapeNode: self.ballNode, at: pos, color: generatedColor, alpha: 0.6)
    }

    func drawNewCircle(shapeNode: SKShapeNode?, at pos: CGPoint, color: HexTripletColor, alpha: CGFloat = 1.0) {
        colorSelector.selectedColors.insert(color)

        if let newNode = shapeNode?.copy() as! SKShapeNode? {
            newNode.position = pos
            newNode.fillColor = color.uiColor.withAlphaComponent(alpha)
            newNode.run(.sequence([
                .fadeIn(withDuration: 0.05),
            ]))
            self.addChild(newNode)
            self.ballNodes.append(newNode)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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

    }


    private func placePalette(copyingNode: SKTouchableShapeNode?, palette: Palette) {
        let node = copyingNode?.copy() as! SKTouchableShapeNode?
        let (pos, hexColor) = palette

        if let node = node {
            node.name = hexColor.stringDescription
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

        (0..<deletionNumber).forEach { _ in
            let oldestNode = nodes.removeFirst()
            oldestNode.run(SKAction.sequence([
                .group([.fadeOut(withDuration: 0.5), .scale(by: 0.0, duration: 0.5)]),
                .removeFromParent()
            ]))
        }
        return deletionNumber
    }
}
