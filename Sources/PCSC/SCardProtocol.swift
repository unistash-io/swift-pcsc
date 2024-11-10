//
//  Created by Adam Stragner
//

import Essentials
@_implementationOnly import Clibpcsclite

// MARK: - SCardProtocol

/// - warning: `.raw` is no longer available for `pcsc-lite` & `Winscard`
public enum SCardProtocol {
    case undefined

    /// Equals `undefined`; backward compatibility
    case unset

    /// T=0 protocol
    case t0

    /// T=1 protocol
    case t1

    /// For memory cards
    case raw

    // case t15
}

// MARK: Hashable

extension SCardProtocol: Hashable {}

// MARK: Sendable

extension SCardProtocol: Sendable {}

extension SCardProtocol {
    init?(value: DWORD) {
        switch value {
        case Self.undefined.dword: self = .undefined
        case Self.t0.dword: self = .t0
        case Self.t1.dword: self = .t1
        case Self.raw.dword: self = .raw
        // case Self.t15._LONG: self = .t15
        default: return nil
        }
    }

    static func required(with DWORD: DWORD) throws (SCardError) -> Self {
        switch DWORD {
        case undefined.dword, unset.dword: .undefined
        case t0.dword: .t0
        case t1.dword: .t1
        case raw.dword: .raw
        default: throw .init(.protoMismatch)
        }
    }

    var dword: DWORD {
        switch self {
        case .undefined, .unset: DWORD(CSCARD_PROTOCOL_UNDEFINED)
        case .t0: DWORD(CSCARD_PROTOCOL_T0)
        case .t1: DWORD(CSCARD_PROTOCOL_T1)
        case .raw: DWORD(CSCARD_PROTOCOL_RAW)
        }
    }
}

extension Sequence where Element == SCardProtocol {
    var dword: DWORD {
        reduce(into: DWORD(0), { $0 |= $1.dword })
    }
}
