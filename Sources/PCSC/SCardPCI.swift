//
//  Created by Adam Stragner
//

import Essentials
@_implementationOnly import Clibpcsclite

// MARK: - SCardPCI

public struct SCardPCI {
    // MARK: Lifecycle

    private init(protocol: SCardProtocol, length: UInt32) {
        self.protocol = `protocol`
        self.length = length
    }

    // MARK: Public

    public let `protocol`: SCardProtocol
    public let length: UInt32
}

// MARK: Hashable

extension SCardPCI: Hashable {}

// MARK: Sendable

extension SCardPCI: Sendable {}

public extension SCardPCI {
    init(pdwProtocol: SCardProtocol) throws (SCardError) {
        try self.init(pdwActiveProtocol: pdwProtocol.dword)
    }
}

extension SCardPCI {
    init(pdwActiveProtocol: DWORD) throws (SCardError) {
        switch pdwActiveProtocol {
        case SCardProtocol.t0.dword:
            self = try .init(
                protocol: .required(with: DWORD(cg_rgSCardT0Pci.dwProtocol)),
                length: cg_rgSCardT0Pci.cbPciLength
            )
        case SCardProtocol.t1.dword:
            self = try .init(
                protocol: .required(with: DWORD(cg_rgSCardT1Pci.dwProtocol)),
                length: cg_rgSCardT1Pci.cbPciLength
            )
        case SCardProtocol.raw.dword:
            self = try .init(
                protocol: .required(with: DWORD(cg_rgSCardRawPci.dwProtocol)),
                length: cg_rgSCardRawPci.cbPciLength
            )
        default: throw .init(.protoMismatch)
        }
    }

    init(IO_REQUEST: CSCARD_IO_REQUEST) throws (SCardError) {
        self = try .init(
            protocol: .required(with: DWORD(IO_REQUEST.dwProtocol)),
            length: IO_REQUEST.cbPciLength
        )
    }

    var IO_REQUEST: CSCARD_IO_REQUEST {
        get throws (SCardError) {
            switch self.protocol {
            case .undefined, .unset: throw .init(.protoMismatch)
            case .t0: cg_rgSCardT0Pci
            case .t1: cg_rgSCardT1Pci
            case .raw: cg_rgSCardRawPci
            }
        }
    }
}
