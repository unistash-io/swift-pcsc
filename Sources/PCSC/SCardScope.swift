//
//  Created by Adam Stragner
//

// MARK: - SCardScope

public enum SCardScope {
    case user
    case terminal
    case system
}

// MARK: Hashable

extension SCardScope: Hashable {}

// MARK: Sendable

extension SCardScope: Sendable {}

extension SCardScope {
    var dword: DWORD {
        switch self {
        case .user: 0x0000
        case .terminal: 0x0001
        case .system: 0x0002
        }
    }
}
