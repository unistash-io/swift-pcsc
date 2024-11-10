//
//  Created by Adam Stragner
//

import Essentials
import EssentialsNFC
import PCSC

// MARK: - PeripheralDeviceDriver

public protocol PeripheralDeviceDriver: Sendable {
    static var deviceSearchNames: [String] { get }

    init()

    func wrap(directTransceive byteCollection: ByteCollection) throws -> ByteCollection
    func unwrap(directTransceive byteCollection: ByteCollection) throws -> ByteCollection

    func didConnect(to picc: any PICC)
    func didDisconnect()
}

public extension PeripheralDeviceDriver {
    func wrap(directTransceive byteCollection: ByteCollection) throws -> ByteCollection {
        byteCollection
    }

    func unwrap(directTransceive byteCollection: ByteCollection) throws -> ByteCollection {
        let apdu = try ISO7816.APDU.Response(byteCollection)
        try apdu.checkError()
        return apdu.data
    }

    func didConnect(to picc: any PICC) {}
    func didDisconnect() {}
}

// MARK: - _PeripheralDeviceDriver

struct _PeripheralDeviceDriver: PeripheralDeviceDriver {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    static let deviceSearchNames: [String] = []
}

// MARK: - AnyPeripheralDeviceDriver

struct AnyPeripheralDeviceDriver {
    // MARK: Lifecycle

    public init(_ driverType: PeripheralDeviceDriver.Type) {
        self.deviceSearchNames = driverType.deviceSearchNames
        self.driverType = driverType
    }

    // MARK: Internal

    let driverType: PeripheralDeviceDriver.Type

    let deviceSearchNames: [String]
}

extension AnyPeripheralDeviceDriver {
    static func == (lhs: AnyPeripheralDeviceDriver, rhs: AnyPeripheralDeviceDriver) -> Bool {
        String(describing: lhs.driverType) == String(describing: rhs.driverType)
    }
}

// MARK: Hashable

extension AnyPeripheralDeviceDriver: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: driverType))
    }
}

// MARK: Sendable

extension AnyPeripheralDeviceDriver: Sendable {}
