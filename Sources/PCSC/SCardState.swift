//
//  Created by Adam Stragner
//

// MARK: - SCardState

public struct SCardState: OptionSet {
    // MARK: Lifecycle

    public init(rawValue: DWORD) {
        self.rawValue = rawValue
    }

    // MARK: Public

    public static let unknown = Self(rawValue: 0x0001)

    /// There is no card in the reader
    public static let absent = Self(rawValue: 0x0002)

    /// There is a card in the reader, but it has not been moved into position for use
    public static let present = Self(rawValue: 0x0004)

    /// There is a card in the reader in position for use. The card is not powered
    public static let swallowed = Self(rawValue: 0x0008)

    /// Power is being provided to the card, but the reader driver is unaware of the mode of the card
    public static let powered = Self(rawValue: 0x0010)

    /// The card has been reset and is awaiting PTS negotiation
    public static let negotiable = Self(rawValue: 0x0020)

    /// The card has been reset and specific communication protocols have been established
    public static let specific = Self(rawValue: 0x0040)

    public let rawValue: DWORD
}

// MARK: Hashable

extension SCardState: Hashable {}

// MARK: Sendable

extension SCardState: Sendable {}
