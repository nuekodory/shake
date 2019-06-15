import Foundation
import CoreBluetooth
import CoreLocation


class PeripheralHandler: NSObject, CBPeripheralManagerDelegate {
    var manager: CBPeripheralManager!

    override init() {
        super.init()
        manager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }


    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print(peripheral.state)
    }

    func advertiseSelectedColor(color: HexTripletColor) {

        let beaconRegion = CLBeaconRegion(
                proximityUUID: ShakeAppIdentifier.selectedInPalette,
                major: UInt16(color.red) * 0x0100 + UInt16(color.green),
                minor: UInt16(color.blue) * 0x0100,
                identifier: ShakeAppIdentifier.beaconIdPrefix + color.stringDescription
        )

        manager.startAdvertising(
                beaconRegion.peripheralData(withMeasuredPower: nil) as NSDictionary as? [String: Any]
        )
    }
}