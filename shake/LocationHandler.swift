//
// Created by Naoki Nakamura on 2019-06-15.
// Copyright (c) 2019 sohzoh. All rights reserved.
//

import Foundation
import CoreLocation


class LocationHandler: NSObject, CLLocationManagerDelegate {
    var manager: CLLocationManager!

    override init() {
        super.init()
        manager = CLLocationManager()
        manager.delegate = self

        manager.startRangingBeacons(in: CLBeaconRegion(
                proximityUUID: ShakeAppIdentifier.selectedInPalette,
                identifier: "selectedInPalette"
        ))
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let receivedColors = beacons.map{ beacon in extractColor(major: beacon.major, minor: beacon.minor) }
        receivedColors.forEach{ NotificationCenter.default.post(name: .newReceivedColor, object: $0) }
    }

    func extractColor(major: NSNumber, minor: NSNumber) -> HexTripletColor {
        return HexTripletColor(
                red:   UInt8(major.intValue / 0x0100),
                green: UInt8(major.intValue % 0x0100),
                blue:  UInt8(minor.intValue / 0x0100),
                timeStamp: UInt8(minor.intValue % 0x0100)
        )
    }
}
