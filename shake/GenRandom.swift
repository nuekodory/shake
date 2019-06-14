//
// Created by Naoki Nakamura on 2019-06-11.
// Copyright (c) 2019 sohzoh. All rights reserved.
//

import Foundation
import UIKit
import os.log


extension UIColor {
    convenience init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = UInt8.max) {
        let denominator = CGFloat(UInt8.max)

        self.init(
                red: CGFloat(red) / denominator,
                green: CGFloat(green) / denominator,
                blue: CGFloat(blue) / denominator,
                alpha: CGFloat(alpha) / denominator
        )
    }
}


struct HexTripletColor: Hashable {
    var red: UInt8
    var green: UInt8
    var blue: UInt8

    init() {
        red = UInt8.random(in: 0...255)
        green = UInt8.random(in: 0...255)
        blue = UInt8.random(in: 0...255)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(blue)
    }

    var uiColor: UIColor {
        let denominator = CGFloat(UInt8.max)

        return UIColor(
                red: CGFloat(red) / denominator,
                green: CGFloat(green) / denominator,
                blue: CGFloat(blue) / denominator,
                alpha: CGFloat(1.0)
        )
    }

    func isGray(sumThreshold: Int) -> Bool {
        if abs(Int(self.red) - Int(self.green))
                   + abs(Int(self.green) - Int(self.blue))
                   + abs(Int(self.blue) - Int(self.red)) < sumThreshold {
            return true
        } else {
            return false
        }
    }

    static func == (lhs: HexTripletColor, rhs: HexTripletColor) -> Bool {
        return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }

    static func - (lhs: HexTripletColor, rhs: HexTripletColor) -> Int {
        let diffRed = Int(lhs.red) - Int(rhs.red)
        let diffGreen = Int(lhs.green) - Int(rhs.green)
        let diffBlue = Int(lhs.blue) - Int(rhs.blue)
        return diffRed * diffRed + diffGreen * diffGreen + diffBlue * diffBlue
    }
}


extension Sequence where Element == HexTripletColor {
    func isConflict(with targetColor: HexTripletColor, thresholdDistanceSquare: Int) -> Bool {
        for receivedColor: HexTripletColor in self {
            let distanceSquare = receivedColor - targetColor
            if distanceSquare < thresholdDistanceSquare {
                print("CONFLICT: \(targetColor), \(receivedColor), d^2=\(distanceSquare)")
                return true
            }
        }
        return false
    }
}


struct ColorSelector {
    var advertisedColor = Set<HexTripletColor>()
    private var _hasColorSelected = false
    var maxCountGenerateTrial = 10000
    var thresholdDistanceSquare = 2000
    var grayThresholdSum = 32

    var hasColorSelected: Bool {
        return _hasColorSelected
    }

    mutating func generateColor() -> HexTripletColor {
        var color = HexTripletColor()
        for _ in 0...maxCountGenerateTrial {
            if advertisedColor.isConflict(with: color, thresholdDistanceSquare: thresholdDistanceSquare) {
                color = HexTripletColor()
                continue
            } else {
                if color.isGray(sumThreshold: grayThresholdSum) {
                    print("GRAY: \(color)")
                    color = HexTripletColor()
                    continue
                } else {
                    break
                }
            }
        }
        _hasColorSelected = true
        return color
    }
}
