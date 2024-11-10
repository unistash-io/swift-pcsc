//
//  Created by Adam Stragner
//

@_implementationOnly import Clibpcsclite

// MARK: - SCardInitializationAction

public enum SCardInitializationAction {
    /// Do not do anything special on reconnect.
    case leave

    /// Reset the card (Warm Reset).
    case reset

    /// Power down the card and reset it (Cold Reset)
    case unpower
}

// MARK: Hashable

extension SCardInitializationAction: Hashable {}

// MARK: Sendable

extension SCardInitializationAction: Sendable {}

extension SCardInitializationAction {
    var dword: DWORD {
        switch self {
        case .leave: 0x0000
        case .reset: 0x0001
        case .unpower: 0x0002
        }
    }
}
