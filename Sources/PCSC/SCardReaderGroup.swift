//
//  Created by Adam Stragner
//

// MARK: - SCardReaderGroup

public enum SCardReaderGroup {
    case all
    case `default`
    case custom(String)

    // MARK: Lifecycle

    public init(rawValue: String) {
        switch rawValue {
        case Self.all.rawValue: self = .all
        case Self.default.rawValue: self = .default
        default: self = .custom(rawValue)
        }
    }

    // MARK: Public

    public var rawValue: String {
        switch self {
        case .all: "SCard$AllReaders"
        case .default: "SCard$DefaultReaders"
        case let .custom(string): string
        }
    }
}

// MARK: Hashable

extension SCardReaderGroup: Hashable {}

// MARK: Sendable

extension SCardReaderGroup: Sendable {}

// MARK: CustomStringConvertible

extension SCardReaderGroup: CustomStringConvertible {
    public var description: String {
        "PS/SC Reader Group: \(rawValue)"
    }
}

extension RangeReplaceableCollection where Element == SCardReaderGroup {
    init(_ pointer: UnsafeMutablePointer<CChar>?, capacity: Int) {
        self.init([String](pointer, capacity: capacity).map({ .init(rawValue: $0) }))
    }
}

extension RangeReplaceableCollection where Element == CChar {
    init(_ readerGroups: [SCardReaderGroup]) {
        var elements = readerGroups.reduce(into: [CChar](), { result, element in
            guard let cString = element.rawValue.cString(using: .utf8)
            else {
                return
            }

            result.append(contentsOf: cString)
            result.append(contentsOf: [0x00])
        })

        if !elements.isEmpty {
            elements.append(0x00)
        }

        self.init(elements)
    }
}
