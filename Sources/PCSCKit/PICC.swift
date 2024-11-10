//
//  Created by Adam Stragner
//

import Essentials
import EssentialsNFC
import PCSC

// MARK: - PICC

public protocol PICC: RawRepresentable where RawValue == CardReader.Unit {}

public extension PICC {
    var ATR: ByteCollection { rawValue.ATR }
}

public extension PICC {
    func transmit(
        _ byteCollection: ByteCollection,
        with type: TransceiveType
    ) async throws (ReaderError) -> ByteCollection? {
        try await rawValue.transmit(byteCollection, with: type)
    }
}

public extension PICC {
    func transmit(
        _ comand: ISO7816.APDU.Command
    ) async throws (ReaderError) -> ISO7816.APDU.Response {
        let response = try await transmit(comand.rawValue, with: .raw)
        do {
            return try ISO7816.APDU.Response(response ?? [])
        } catch {
            throw .apdu(error)
        }
    }
}
