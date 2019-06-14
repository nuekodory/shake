//
// Created by Naoki Nakamura on 2019-06-06.
// Copyright (c) 2019 sohzoh. All rights reserved.
//

import Foundation
import CoreBluetooth


class CentralManager: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    var receivedColors: Set<HexTripletColor>!

    convenience init(colors: Set<HexTripletColor>){
        self.init()
        receivedColors = colors
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral.debugDescription)
        receivedColors.insert(HexTripletColor())
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state.rawValue)
    }

}