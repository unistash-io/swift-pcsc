//
//  Created by Adam Stragner
//

import Essentials
import EssentialsNFC
import PCSC

// MARK: - ReaderError

public enum ReaderError: Error {
    case apdu(ISO7816.APDU.Error)
    case hardware(SCardError)
    case driver(any Error)
}

// MARK: LocalizedError

extension ReaderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .apdu(error): error.localizedDescription
        case let .hardware(error): error.errorDescription
        case let .driver(error): error.localizedDescription
        }
    }
}

// MARK: Equatable

extension ReaderError: Equatable {
    public static func == (lhs: ReaderError, rhs: ReaderError) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

// MARK: Hashable

extension ReaderError: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(errorDescription ?? "")
    }
}

// MARK: Sendable

extension ReaderError: Sendable {}
