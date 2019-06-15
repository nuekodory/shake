//
// Created by Naoki Nakamura on 2019-06-15.
// Copyright (c) 2019 sohzoh. All rights reserved.
//

import Foundation


struct ShakeAppIdentifier {
    static let selectedInPalette =
            UUID(uuidVersion: 5, namespace: UUID.namespace.DNS, name: "palette.color.shake.sohzoh.com")!
    static let beaconIdPrefix = "com.sohzoh.shake."
}

extension Notification.Name {
    static let newReceivedColor = Notification.Name("com.sohzoh.shake.newReceivedColor")
    static let paletteTouchDown = Notification.Name("com.sohzoh.shake.paletteTouchDown")
}
