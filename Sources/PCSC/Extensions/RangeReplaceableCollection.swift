//
//  Created by Adam Stragner
//

import Essentials

extension RangeReplaceableCollection where Element == String {
    init(_ pointer: UnsafeMutablePointer<CChar>?, capacity: Int) {
        guard let pointer
        else {
            self.init([])
            return
        }

        var elements: [String] = []
        var current: ByteCollection = []

        for i in 0 ..< capacity {
            let char = pointer.advanced(by: i).pointee
            guard char == 0x00 // null terminator
            else {
                current.append(UInt8(char))
                continue
            }

            let _current = current
            current.removeAll()

            guard !_current.isEmpty,
                  let string = String(bytes: _current, encoding: .utf8)
            else {
                continue
            }

            elements.append(string)
        }

        self.init(elements)
    }
}

extension RangeReplaceableCollection where Element == UInt8 {
    init(_ pointer: UnsafeMutablePointer<UInt8>?, capacity: Int) {
        guard let pointer
        else {
            self.init([])
            return
        }

        var elements: [UInt8] = .init(repeating: 0, count: Int(capacity))
        for i in 0 ..< Int(capacity) {
            elements[i] = pointer.pointee.advanced(by: i)
        }

        self.init(elements)
    }
}
