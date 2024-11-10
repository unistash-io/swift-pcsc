//
//  Created by Adam Stragner
//

@_implementationOnly import Clibpcsclite

// MARK: - SCardDispositionAction

public enum SCardDispositionAction {
    /// Do not do anything special
    case leave

    /// Reset the card
    case reset

    /// Power down the card
    case unpower

    /// Eject the card
    case eject
}

// MARK: Hashable

extension SCardDispositionAction: Hashable {}

// MARK: Sendable

extension SCardDispositionAction: Sendable {}

extension SCardDispositionAction {
    var dword: DWORD {
        switch self {
        case .leave: 0x0000
        case .reset: 0x0001
        case .unpower: 0x0002
        case .eject: 0x0003
        }
    }
}
