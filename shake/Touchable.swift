//
// Created by Naoki Nakamura on 2019-06-15.
// Copyright (c) 2019 sohzoh. All rights reserved.
//

import Foundation
import SpriteKit
import CoreBluetooth


class SKTouchableShapeNode: SKShapeNode {
    var peripheralHandler: PeripheralHandler?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        peripheralHandler?.advertiseSelectedColor(color: HexTripletColor, duration: )
    }
}