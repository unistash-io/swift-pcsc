//
//  Created by Adam Stragner
//

// MARK: - SCardShareMode

public enum SCardShareMode: UInt32 {
    /// Еhe application requests exclusive access to the smartcard
    case exclusive

    /// The application allows others to share the smartcard
    case shared

    /// Еhe application requests direct (and exclusive) control of the reader, even without a smartcard in it
    case direct
}

// MARK: Hashable

extension SCardShareMode: Hashable {}

// MARK: Sendable

extension SCardShareMode: Sendable {}

extension SCardShareMode {
    var dword: DWORD {
        switch self {
        case .exclusive: 0x0001
        case .shared: 0x0002
        case .direct: 0x0003
        }
    }
}
