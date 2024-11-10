//
//  Created by Adam Stragner
//

import PCSC
import Essentials
import Logging

// MARK: - ReaderSession

public final class ReaderSession {
    // MARK: Lifecycle

    public init() async throws (ReaderError) {
        let logger = Logger(label: "ReaderSession")
        do {
            self.hContext = try await _SCardEstablishContext(.system)
            logger.trace("Context successfully established")
        } catch {
            logger.error("Context establishing error: \(error.localizedDescription)")
            throw .hardware(error)
        }
        self.logger = logger
    }

    deinit {
        let hContext = self.hContext
        let logger = self.logger

        SynchronousActor.detached({
            try? SCardReleaseContext(hContext)
            logger.trace("Context successfully released")
        })
    }

    // MARK: Public

    public func readers(
        for groups: [SCardReaderGroup] = [],
        compatibleWith drivers: [PeripheralDeviceDriver.Type] = []
    ) async throws -> [CardReader] {
        let readers = try await _SCardListReaders(hContext, groups).map({
            CardReader(session: self, name: $0, drivers: drivers)
        })

        guard !drivers.isEmpty
        else {
            return readers
        }

        return readers.filter({ reader in
            drivers.contains(where: { $0 == reader.driver })
        })
    }

    // MARK: Internal

    let hContext: SCardContext

    // MARK: Private

    private let logger: Logger
}

// MARK: Sendable

extension ReaderSession: Sendable {}

@SynchronousActor
private func _SCardEstablishContext(
    _ dwScope: SCardScope = .system,
    _ pvReserved1: UnsafeRawPointer? = nil,
    _ pvReserved2: UnsafeRawPointer? = nil
) throws (SCardError) -> SCardContext {
    try SCardEstablishContext(dwScope, pvReserved1, pvReserved2)
}

@SynchronousActor
public func _SCardListReaders(
    _ hContext: SCardContext,
    _ mszGroups: [SCardReaderGroup] = []
) throws (SCardError) -> [SCardReaderName] {
    try SCardListReaders(hContext, mszGroups)
}
