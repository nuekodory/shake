//
// Created by Naoki Nakamura on 2019-06-15.
// Copyright (c) 2019 sohzoh. All rights reserved.
//

import Foundation
import SpriteKit



func floatVector() -> CGVector {
    let d = 100.0
    return CGVector(dx: Double.random(in: -d...d), dy: Double.random(in: -d...d))
}

func floatTime() -> TimeInterval {
    return Double.random(in: 0.02...0.5)
}

func floatAlpha() -> CGFloat {
    let a: CGFloat = 0.10
    return CGFloat.random(in: -a...a)
}

func blinkTime() -> TimeInterval {
    return Double.random(in: 0.0...0.2)
}

