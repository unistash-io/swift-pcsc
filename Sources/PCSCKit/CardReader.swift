//
//  Created by Adam Stragner
//

import Essentials
import Logging
import PCSC

// MARK: - CardReader

public final class CardReader {
    // MARK: Lifecycle

    init(session: ReaderSession, name: SCardReaderName, drivers: [PeripheralDeviceDriver.Type]) {
        self.name = name
        self.session = session

        self.driver = drivers.filter({
            let anyDriver = AnyPeripheralDeviceDriver($0)
            return !anyDriver.deviceSearchNames
                .filter({ name.rawValue.lowercased().contains($0.lowercased()) })
                .isEmpty
        }).first ?? _PeripheralDeviceDriver.self

        logger.trace("Successfully initialized with driver \(String(describing: driver))")
        logger.trace("==> Driver: \(String(describing: driver))")
        logger.trace("==> Device: \(name.rawValue)")
    }

    deinit {
        logger.trace("Deinitialized")
    }

    // MARK: Public

    public let name: SCardReaderName
    public let driver: PeripheralDeviceDriver.Type

    // MARK: Internal

    let session: ReaderSession

    // MARK: Private

    private let logger = Logger(label: "CardReader")
}

// MARK: Equatable

extension CardReader: Equatable {
    public static func == (lhs: CardReader, rhs: CardReader) -> Bool {
        lhs.name == rhs.name
    }
}

// MARK: Hashable

extension CardReader: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

// MARK: Sendable

extension CardReader: Sendable {}

// MARK: CardReader.TimoutError

public extension CardReader {
    func poll<P>(
        _ type: P.Type,
        with timeout: TimeInterval = 15
    ) async throws (ReaderError) -> P? where P: PICC {
        let hContext = session.hContext

        let dwTimeout = TimeInterval(0.2)
        var dwTimeouts = Int(timeout / dwTimeout)

        logger.debug("Polling a PICC for with timeout: \(timeout)")
        while dwTimeouts > 0 {
            do throws (SCardError) {
                guard !Task.isCancelled
                else {
                    break
                }

                dwTimeouts -= 1

                var states = [SCardReaderState(szReader: name)]
                try await _SCardGetStatusChange(hContext, dwTimeout, &states)

                guard let state = states.first, state.dwEventState.contains(.present)
                else {
                    logger.trace("PICC not found, waiting")
                    try? await Task.sleep(nanoseconds: UInt64(dwTimeout * 1_000_000_000))
                    continue
                }

                let connection = try await _SCardConnect(hContext, name, .shared, [.t0, .t1])
                let unit = try await Unit(
                    reader: self,
                    driver: driver.init(),
                    hCard: connection.phCard,
                    pwProtocol: connection.pdwActiveProtocol
                )

                guard let picc = P(rawValue: unit)
                else {
                    let _type = String(describing: P.self)
                    logger.debug("PICC found, but couldn't instantiate for \(_type)")
                    try? await Task.sleep(nanoseconds: UInt64(dwTimeout * 1_000_000_000))
                    continue
                }

                unit.driver.didConnect(to: picc)
                logger.debug("PICC found; ATR: [\(unit.ATR.hexadecimalString(separator: ""))]")
                return picc
            } catch {
                logger.error("\(error)")
                throw .hardware(error)
            }
        }

        logger.debug("PICC not found")
        return nil
    }
}

public extension CardReader {
    func waitDisconnection(
        with timeout: TimeInterval = 15
    ) async throws (ReaderError) {
        let hContext = session.hContext

        let dwTimeout = TimeInterval(0.2)
        var dwTimeouts = Int(timeout / dwTimeout)

        logger.debug("Waiting for a disconnecting a PICC with timeout: \(timeout)")
        while dwTimeouts > 0 {
            do throws (SCardError) {
                guard !Task.isCancelled
                else {
                    break
                }

                dwTimeouts -= 1

                var states = [SCardReaderState(szReader: name)]
                try await _SCardGetStatusChange(hContext, dwTimeout, &states)

                guard let state = states.first, state.dwEventState.contains(.empty)
                else {
                    logger.trace("PICC still connected, waiting")
                    try? await Task.sleep(nanoseconds: UInt64(dwTimeout * 1_000_000_000))
                    continue
                }

                logger.debug("PICC successfully disconnected!")
                break
            } catch {
                logger.error("\(error)")
                throw .hardware(error)
            }
        }
    }
}

@SynchronousActor
private func _SCardGetStatusChange(
    _ hContext: SCardContext,
    _ dwTimeout: TimeInterval,
    _ rgReaderStates: inout [SCardReaderState]
) throws (SCardError) {
    try SCardGetStatusChange(hContext, dwTimeout, &rgReaderStates)
}

@SynchronousActor
private func _SCardConnect(
    _ hContext: SCardContext,
    _ szReader: SCardReaderName,
    _ dwShareMode: SCardShareMode = .shared,
    _ dwPreferredProtocols: Set<SCardProtocol> = [.t0, .t1]
) throws (SCardError) -> (phCard: SCardHandle, pdwActiveProtocol: SCardProtocol) {
    try SCardConnect(hContext, szReader, dwShareMode, dwPreferredProtocols)
}
