//
//  Created by Adam Stragner
//

import Essentials
import Logging
import PCSC

// MARK: - CardReader.Unit

public extension CardReader {
    final class Unit {
        // MARK: Lifecycle

        init(
            reader: CardReader,
            driver: PeripheralDeviceDriver,
            hCard: SCardHandle,
            pwProtocol: SCardProtocol
        ) async throws (SCardError) {
            let state = try await _SCardStatus(hCard)

            self.ATR = state.pbAtr

            self.reader = reader
            self.driver = driver

            self.hCard = hCard
            self.pwProtocol = pwProtocol
        }

        deinit {
            let hCard = self.hCard
            SynchronousActor.detached({
                try? SCardDisconnect(hCard, .leave)
            })
        }

        // MARK: Public

        public let ATR: ByteCollection

        // MARK: Internal

        let reader: CardReader
        let driver: PeripheralDeviceDriver

        let hCard: SCardHandle
        let pwProtocol: SCardProtocol

        // MARK: Private

        private let logger = Logger(label: "CardReader.Unit")
    }
}

// MARK: - CardReader.Unit + Equatable

extension CardReader.Unit: Equatable {
    public static func == (lhs: CardReader.Unit, rhs: CardReader.Unit) -> Bool {
        lhs.ATR == rhs.ATR
    }
}

// MARK: - CardReader.Unit + Hashable

extension CardReader.Unit: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ATR)
    }
}

// MARK: - CardReader.Unit + Sendable

extension CardReader.Unit: Sendable {}

public extension CardReader.Unit {
    func transmit(
        _ byteCollection: ByteCollection,
        with type: TransceiveType
    ) async throws (ReaderError) -> ByteCollection? {
        let pioSendPci: SCardPCI
        do {
            pioSendPci = try SCardPCI(pdwProtocol: pwProtocol)
        } catch {
            throw .hardware(error)
        }

        let pbSendBuffer = switch type {
        case .raw: byteCollection
        case .direct: try wrap(directTransceive: byteCollection)
        }

        logger.trace("Transmitting: [\(pbSendBuffer.hexadecimalString(separator: ""))]")

        var result: ByteCollection? = nil
        do {
            result = try await _SCardTransmit(hCard, pioSendPci, pbSendBuffer).pbRecvBuffer
        } catch {
            throw .hardware(error)
        }

        logger.trace("Received: [\(result?.hexadecimalString(separator: "") ?? "")]")
        return switch type {
        case .raw: result
        case .direct: try unwrap(directTransceive: result ?? [])
        }
    }

    private func wrap(
        directTransceive byteCollection: ByteCollection
    ) throws (ReaderError) -> ByteCollection {
        do {
            return try driver.wrap(directTransceive: byteCollection)
        } catch {
            throw .driver(error)
        }
    }

    private func unwrap(
        directTransceive byteCollection: ByteCollection
    ) throws (ReaderError) -> ByteCollection {
        do {
            return try driver.unwrap(directTransceive: byteCollection)
        } catch {
            throw .driver(error)
        }
    }
}

@SynchronousActor
private func _SCardTransmit(
    _ hCard: SCardHandle,
    _ pioSendPci: SCardPCI,
    _ pbSendBuffer: ByteCollection,
    _ pioRecvPci: SCardPCI? = nil
) throws (SCardError) -> (pioRecvPci: SCardPCI?, pbRecvBuffer: ByteCollection?) {
    try SCardTransmit(hCard, pioSendPci, pbSendBuffer)
}

@SynchronousActor
private func _SCardStatus(
    _ hCard: SCardHandle
) throws (SCardError) -> (
    szReaderName: SCardReaderName,
    pdwState: SCardState,
    pdwProtocol: SCardProtocol,
    pbAtr: ByteCollection
) {
    try SCardStatus(hCard)
}
