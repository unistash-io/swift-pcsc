//
//  Created by Adam Stragner
//

// MARK: - TransceiveType

public enum TransceiveType {
    case raw

    /// It meas data should be wrapper by device driver to 'direct' APDU
    case direct
}

// MARK: Hashable

extension TransceiveType: Hashable {}

// MARK: Sendable

extension TransceiveType: Sendable {}
