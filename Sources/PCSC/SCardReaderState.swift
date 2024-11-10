//
//  Created by Adam Stragner
//

import Essentials
@_implementationOnly import Clibpcsclite

// MARK: - SCardReaderState

public struct SCardReaderState {
    // MARK: Lifecycle

    public init(
        szReader: SCardReaderName,
        dwCurrentState: StateValue = [.unware],
        dwEventState: StateValue = [.unknown],
        rgbAtr: ByteCollection? = nil
    ) {
        self.szReader = szReader
        self.dwCurrentState = dwCurrentState
        self.dwEventState = dwEventState
        self.rgbAtr = rgbAtr
    }

    // MARK: Public

    /// Reader name
    public let szReader: SCardReaderName

    /// Current state of the reader, as seen by the application
    public let dwCurrentState: StateValue

    /// Current state of the reader, as known by the smart card resource manager
    public let dwEventState: StateValue

    /// ATR of the inserted card, with extra alignment bytes
    /// - warning: Must be equal to `33 bytes`
    public let rgbAtr: ByteCollection?
}

// MARK: Hashable

extension SCardReaderState: Hashable {}

// MARK: Sendable

extension SCardReaderState: Sendable {}

// MARK: SCardReaderState.UserDataValue

public extension SCardReaderState {
    protocol UserDataValue: Sendable, Hashable {}
}

// MARK: SCardReaderState.StateValue

public extension SCardReaderState {
    struct StateValue: OptionSet {
        // MARK: Lifecycle

        public init(rawValue: DWORD) {
            self.rawValue = rawValue
        }

        // MARK: Public

        /// The application is unaware of the current state, and would like to know.
        /// The use of this value results in an immediate return from state transition monitoring services
        public static let unware = Self([])

        /// This reader should be ignored
        public static let ignore = Self(rawValue: 0x0001)

        /// There is a difference between the state believed by the application, and the state known by the resource manager.
        /// When this bit is set, the application may assume a significant state change has occurred on this reader
        public static let changed = Self(rawValue: 0x0002)

        /// The given reader name is not recognized by the resource manager.
        /// If this bit is set, then `.changed` and `.ignore` will also be set
        public static let unknown = Self(rawValue: 0x0004)

        /// The actual state of this reader is not available. If this bit is set, then all the following bits are clear
        public static let unavailable = Self(rawValue: 0x0008)

        /// There is no card in the reader. If this bit is set, all the following bits will be clear
        public static let empty = Self(rawValue: 0x0010)

        /// There is a card in the reader
        public static let present = Self(rawValue: 0x0020)

        /// The application expects that there is a card in the reader with an ATR that matches one of the target cards.
        /// If this bit is set, `.present` is assumed.
        /// This bit has no meaning to `SCardGetStatusChange` beyond `.present`
        public static let atrmacth = Self(rawValue: 0x0040)

        /// The card in the reader is allocated for exclusive use by another application. If this bit is set, `.present` will also be set
        public static let exclusive = Self(rawValue: 0x0080)

        /// The card in the reader is in use by one or more other applications, but may be connected to in shared mode.
        /// If this bit is set, `.present` will also be set
        public static let inuse = Self(rawValue: 0x0100)

        /// There is an unresponsive card in the reader
        public static let mute = Self(rawValue: 0x0200)

        /// This implies that the card in the reader has not been powered up.
        public static let unpowered = Self(rawValue: 0x0400)

        public let rawValue: DWORD
    }
}

// MARK: - SCardReaderState.StateValue + Hashable

extension SCardReaderState.StateValue: Hashable {}

// MARK: - SCardReaderState.StateValue + Sendable

extension SCardReaderState.StateValue: Sendable {}
