//
//  Created by Adam Stragner
//

import Essentials
@_implementationOnly import Clibpcsclite

#if canImport(Darwin)
public typealias LONG = Int32
public typealias DWORD = UInt32
#else
public typealias LONG = CLong
public typealias DWORD = CUnsignedLong
#endif

/// Maximum amount of bytes in an ATR
private let MAX_ATR_SIZE = UInt32(33)

/// Maximum amount of bytes in a short APDU command or response.
private let MAX_BUFFER_SIZE = UInt32(264)

/// Maximum amount of bytes in an extended APDU command or response.
private let MAX_BUFFER_SIZE_EXTENDED = UInt32(65548)

public typealias SCardContext = LONG
public typealias SCardHandle = LONG

/// Instantiates a context for the application within the PC/SC Resource Manager. This must be the first function called in a PC/SC application
///
/// - parameters:
///   - dwScope: Should be set `SCardScope.system` ('pcsc-lite' specific; for original 'Winscard' could be any)
///   - pvReserved1: Must be `nil`; reserved for future use
///   - pvReserved2: Must be `nil`; reserved for future use
/// - returns: Handle to the PC/SC resource manager
/// - warning: Parameter `scope`  must be `SCardScope.system` for 'pcsc-lite. For original 'Winscard' implmenetation could be any
public func SCardEstablishContext(
    _ dwScope: SCardScope = .system,
    _ pvReserved1: UnsafeRawPointer? = nil,
    _ pvReserved2: UnsafeRawPointer? = nil
) throws (SCardError) -> SCardContext {
    var phContext: SCardContext = 0
    try SCardError.checkResult(CSCardEstablishContext(
        dwScope.dword,
        pvReserved1,
        pvReserved2,
        &phContext
    ))
    return phContext
}

/// Destroys the application context within the PC/SC Resource Manager. This must be the last function called in a PC/SC application.
///
/// - parameters:
///   - hContext: Connection context to the be released
public func SCardReleaseContext(_ hContext: SCardContext) throws (SCardError) {
    try SCardError.checkResult(CSCardReleaseContext(hContext))
}

/// Determines whether a smart card context handle is still valid. After a smart card context handle has been set by `SCardEstablishContext`,
/// it may become not valid if the resource manager service has been shut down
///
/// - parameters:
///   - hContext: Connection context to the be tested
public func SCardIsValidContext(_ hContext: SCardContext) -> Bool {
    do {
        try SCardError.checkResult(CSCardIsValidContext(hContext))
        return true
    } catch {
        return false
    }
}

/// - returns: A list of currently available reader groups on the system
public func CSCardListReaderGroups(
    _ hContext: SCardContext
) throws (SCardError) -> [SCardReaderGroup] {
    var pcchGroups: DWORD = 0
    try SCardError.checkResult(CSCardListReaderGroups(hContext, nil, &pcchGroups))

    let mszGroups: UnsafeMutablePointer<CChar> = .allocate(capacity: Int(pcchGroups))
    defer { mszGroups.deallocate() }

    try SCardError.checkResult(CSCardListReaderGroups(hContext, mszGroups, &pcchGroups))
    return .init(mszGroups, capacity: Int(pcchGroups))
}

/// Returns a list of currently available readers on the system
///
/// - parameters:
///   - hContext: Connection context to the PC/SC Resource Manager
///   - mszGroups: List of groups to list readers
/// - returns: a list of currently available readers on the system, optionally filtered by a set of named reader groups
/// - warning: Parameter `mszGroups` is ignored by 'pscs-lite' and used only by 'Windscard'
public func SCardListReaders(
    _ hContext: SCardContext,
    _ mszGroups: [SCardReaderGroup] = []
) throws (SCardError) -> [SCardReaderName] {
    var pcchReaders: DWORD = 0

    var cGroups = [CChar](Array(mszGroups))
    let mszGroups: UnsafePointer<CChar>? = mszGroups.isEmpty ? nil : .init(&cGroups)

    // If the application sends szReaders as NULL then this function returns the size of the buffer needed to allocate in pcchReaders.
    try SCardError.checkResult(CSCardListReaders(hContext, mszGroups, nil, &pcchReaders))

    let mszReaders: UnsafeMutablePointer<CChar> = .allocate(capacity: Int(pcchReaders))
    defer { mszReaders.deallocate() }

    try SCardError.checkResult(CSCardListReaders(hContext, mszGroups, mszReaders, &pcchReaders))
    return .init(mszReaders, capacity: Int(pcchReaders))
}

/// Blocks execution until the current availability of the cards in a specific set of readers changes
///
/// The caller supplies a list of readers to be monitored by an `SCARD_READERSTATE` array and
/// the maximum amount of time (in milliseconds) that it is willing to wait for an action to occur on one of the listed readers
///
/// The function returns when there is a change in availability (e.g. card inserted or card removed),
/// having filled in the `dwEventState` members of `rgReaderStates` appropriately
///
/// - parameters:
///   - hContext: Connection context to the PC/SC Resource Manager
///   - dwTimeout: Maximum waiting time (in miliseconds) for status change, zero for infinite
///   - rgReaderStates:
public func SCardGetStatusChange(
    _ hContext: SCardContext,
    _ dwTimeout: TimeInterval,
    _ rgReaderStates: inout [SCardReaderState]
) throws (SCardError) {
    var szReaderNames: [UnsafeMutablePointer<CChar>] = []
    defer { szReaderNames.forEach({ $0.deallocate() }) }

    var _rgReaderStates: [CSCARD_READERSTATE] = rgReaderStates.map({
        var rgReaderState = CSCARD_READERSTATE()
        rgReaderState.dwCurrentState = $0.dwCurrentState.rawValue
        rgReaderState.dwEventState = $0.dwEventState.rawValue
        rgReaderState.cbAtr = DWORD(MAX_ATR_SIZE)

        if let cszReader = $0.szReader.rawValue.cString(using: .utf8) {
            let _szReader = UnsafeMutablePointer<CChar>.allocate(capacity: cszReader.count)
            _szReader.initialize(from: cszReader, count: cszReader.count)
            szReaderNames.append(_szReader)

            rgReaderState.szReader = UnsafePointer(_szReader)
        }

        if let rgbAtr = $0.rgbAtr {
            let rgbAtrCount = min(rgbAtr.count, Int(MAX_ATR_SIZE))
            withUnsafeMutableBytes(of: &rgReaderState.rgbAtr, { buffer in
                buffer.copyBytes(from: rgbAtr.prefix(rgbAtrCount))
            })
            rgReaderState.cbAtr = DWORD(rgbAtrCount)
        }

        return rgReaderState
    })

    let dwTimeout = DWORD(dwTimeout * 1000)
    let cReaders = DWORD(_rgReaderStates.count)

    try SCardError.checkResult(CSCardGetStatusChange(
        hContext,
        dwTimeout,
        &_rgReaderStates,
        cReaders
    ))

    rgReaderStates = _rgReaderStates.map({ state in
        SCardReaderState(
            szReader: .init(rawValue: .init(cString: state.szReader)),
            dwCurrentState: .init(rawValue: state.dwCurrentState),
            dwEventState: .init(rawValue: state.dwEventState),
            rgbAtr: { () -> ByteCollection? in
                guard state.cbAtr > 0
                else {
                    return nil
                }

                return withUnsafeBytes(of: state.rgbAtr, { stateRgbAtr in
                    let atrData = Data(stateRgbAtr.prefix(Int(state.cbAtr)))
                    return ByteCollection(atrData)
                })
            }()
        )
    })
}

/// Function cancels all pending blocking requests on the `SCardGetStatusChange` function
///
/// - parameters:
///   - hContext: Connection context to the PC/SC Resource Manager
public func SCardCancel(_ hContext: SCardContext) throws (SCardError) {
    try SCardError.checkResult(CSCardCancel(hContext))
}

/// Establishes a connection between the calling application and a smartcard contained inserted into a specific reader
///
/// - parameters:
///   - hContext: Connection context to the PC/SC Resource Manager
///   - szReader: The name of the reader that contains the target card
///   - dwShareMode: Exclusive or shared connection
///   - dwPreferredProtocols: List of acceptable card protocols
/// - returns: Handle to the smartcard `phCard` and actual protocol selected by the reader `pdwActiveProtocol`
/// - note: The first connection powers up and resets of the card. If there’s no card in the specified reader, an error is returned
public func SCardConnect(
    _ hContext: SCardContext,
    _ szReader: SCardReaderName,
    _ dwShareMode: SCardShareMode = .shared,
    _ dwPreferredProtocols: Set<SCardProtocol> = [.t0, .t1]
) throws (SCardError) -> (phCard: SCardHandle, pdwActiveProtocol: SCardProtocol) {
    let szReader = szReader.unsafeMutablePointer
    defer { szReader.deallocate() }

    var phCard: LONG = 0
    var pdwActiveProtocol: DWORD = 0

    try SCardError.checkResult(CSCardConnect(
        hContext,
        szReader,
        dwShareMode.dword,
        dwPreferredProtocols.dword,
        &phCard,
        &pdwActiveProtocol
    ))

    guard let pdwActiveProtocol = SCardProtocol(value: pdwActiveProtocol)
    else {
        throw .init(.internalError)
    }

    return (phCard, pdwActiveProtocol)
}

/// Re-establishes an existing connection between the calling application and smartcard. This function can be useful to move a card
/// handle from direct access to general access, or to acknowledge and clear an error condition that is preventing further access to a smartcard
///
/// - parameters:
///   - hCard: Card handle as returned by `SCardConnect`
///   - dwShareMode: Exclusive or shared connection
///   - dwPreferredProtocols: List of acceptable card protocols
///   - dwInitialization: Type of initialization that should be performed on the card
/// - returns: Actual protocol selected by the reader
public func SCardReconnect(
    _ hCard: SCardHandle,
    _ dwShareMode: SCardShareMode = .shared,
    _ dwPreferredProtocols: Set<SCardProtocol> = [.t0, .t1],
    _ dwInitialization: SCardInitializationAction = .leave
) throws (SCardError) -> SCardProtocol {
    var pdwActiveProtocol: DWORD = 0
    try SCardError.checkResult(CSCardReconnect(
        hCard,
        dwShareMode.dword,
        dwPreferredProtocols.dword,
        dwInitialization.dword,
        &pdwActiveProtocol
    ))

    guard let pdwActiveProtocol = SCardProtocol(value: pdwActiveProtocol)
    else {
        throw .init(.internalError)
    }

    return pdwActiveProtocol
}

/// Terminates a previously opened connection between the calling application and a smartcard
///
/// - parameters:
///   - hCard: Card handle as returned by `SCardConnect`
///   - dwDisposition: Action to perform on the smartcard
public func SCardDisconnect(
    _ hCard: SCardHandle,
    _ dwDisposition: SCardDispositionAction
) throws (SCardError) {
    try SCardError.checkResult(CSCardDisconnect(hCard, dwDisposition.dword))
}

/// Returns the current status of a smartcard previously connected with `SCardConnect`
///
/// - parameters:
///   - hCard: Card handle as returned by `SCardConnect`
/// - returns: The name of the reader the card is in `szReaderName`;
///            Current state of the reader `pdwState`;
///            Current protocol of the smartcard `pdwProtocol`;
///            ATR of the currently inserted card `pbAtr` (if available);
public func SCardStatus(
    _ hCard: SCardHandle
) throws (SCardError) -> (
    szReaderName: SCardReaderName,
    pdwState: SCardState,
    pdwProtocol: SCardProtocol,
    pbAtr: ByteCollection
) {
    let szReaderName: UnsafeMutablePointer<CChar> = .allocate(capacity: 200)
    defer { szReaderName.deallocate() }
    var pcchReaderLen = DWORD(200)

    let pbAtr: UnsafeMutablePointer<UInt8> = .allocate(capacity: 32)
    defer { pbAtr.deallocate() }
    var pcbAtrLen = DWORD(32)

    var pdwState = DWORD(0)
    var pdwProtocol = DWORD(0)

    try SCardError.checkResult(CSCardStatus(
        hCard,
        szReaderName,
        &pcchReaderLen,
        &pdwState,
        &pdwProtocol,
        pbAtr,
        &pcbAtrLen
    ))

    let _szReaderName = [String](szReaderName, capacity: Int(pcchReaderLen)).first
    let _pdwProtocol = SCardProtocol(value: pdwProtocol)
    let _pbAtr = ByteCollection(Data(bytes: pbAtr, count: Int(pcbAtrLen)))

    guard let _szReaderName, let _pdwProtocol
    else {
        throw .init(.internalError)
    }

    return (
        SCardReaderName(rawValue: _szReaderName),
        SCardState(rawValue: pdwState),
        _pdwProtocol,
        _pbAtr
    )
}

/// Sends a command APDU to the smartcard, and retrieve its response
///
/// - parameters:
///   - hCard: Card handle as returned by `SCardConnect`
///   - pioSendPci: Protocol shall be used to send the APDU, and receive card’s response
///   - pbSendBuffer: APDU to send to the card
///   - pioRecvPci:
/// - returns: Protocol is actually in use `pioRecvPci`;
///            APDU response `pbRecvBuffer`;
public func SCardTransmit(
    _ hCard: SCardHandle,
    _ pioSendPci: SCardPCI,
    _ pbSendBuffer: ByteCollection,
    _ pioRecvPci: SCardPCI? = nil
) throws (SCardError) -> (pioRecvPci: SCardPCI?, pbRecvBuffer: ByteCollection?) {
    var pbRecvBuffer = ByteCollection(repeating: 0, count: Int(MAX_BUFFER_SIZE))
    var pcbRecvLength = DWORD(MAX_BUFFER_SIZE)

    var _pioSendPci = try pioSendPci.IO_REQUEST
    var _pioRecvPci = CSCARD_IO_REQUEST()

    if let pioRecvPci {
        let __pioRecvPci = try pioRecvPci.IO_REQUEST
        _pioRecvPci.dwProtocol = __pioRecvPci.dwProtocol
        _pioRecvPci.cbPciLength = __pioRecvPci.cbPciLength
    }

    try SCardError.checkResult(CSCardTransmit(
        hCard,
        &_pioSendPci, pbSendBuffer, DWORD(pbSendBuffer.count),
        &_pioRecvPci, &pbRecvBuffer, &pcbRecvLength
    ))

    return try (
        SCardPCI(IO_REQUEST: _pioRecvPci),
        pcbRecvLength > 0 ? ByteCollection(pbRecvBuffer[0 ..< Int(pcbRecvLength)]) : nil
    )
}

/// Direct control on the reader even when there’s no card in it
///
/// - parameters:
///   - hCard: Card handle as returned by `SCardConnect`
///   - dwControlCode: Control code for the operation to be performed
///   - pbSendBuffer: Data required to perform the operation
///   - pcbRecvLength: Maximum length of return buffer
/// - returns: Response from the reader
/// - warning: calling SCardControl may require that the `hCard` connection has been created with either the `.direct` or `.exclusive`
///  value for `SCardConnect` or `SCardReconnect` `dwShareMode` parameter
public func SCardControl(
    _ hCard: SCardHandle,
    _ dwControlCode: DWORD,
    _ pbSendBuffer: ByteCollection?
) throws (SCardError) -> ByteCollection? {
    var pbRecvBuffer = [UInt8](repeating: 0, count: Int(MAX_BUFFER_SIZE_EXTENDED))
    let pcbRecvLength = DWORD(MAX_BUFFER_SIZE_EXTENDED)

    var lpBytesReturned = DWORD(0)

    try SCardError.checkResult(CSCardControl(
        hCard, dwControlCode,
        pbSendBuffer, DWORD(pbSendBuffer?.count ?? 0),
        &pbRecvBuffer, pcbRecvLength, &lpBytesReturned
    ))

    return lpBytesReturned > 0 ? ByteCollection(pbRecvBuffer[0 ..< Int(lpBytesReturned)]) : nil
}

/// Establishes a temporary exclusive access mode, for doing a series of commands or transaction into the card
///
/// You might want to use this when you are selecting a few files and then writing a large file,
/// so you can make sure that another application will not change the current file
///
/// - parameters:
///   - hCard: Card handle as returned by `SCardConnect`
/// - warning: If another application has already started a transaction with the same smartcard, then function will block until the transaction is finished
public func SCardBeginTransaction(_ hCard: SCardHandle) throws (SCardError) {
    try SCardError.checkResult(CSCardBeginTransaction(hCard))
}

/// Exits the exclusive access mode gained after a successful call to `SCardBeginTransaction`
///
/// - parameters:
///   - hCard: Card handle as returned by `SCardConnect`
public func SCardEndTransaction(
    _ hCard: SCardHandle,
    _ dwDisposition: SCardDispositionAction
) throws (SCardError) {
    try SCardError.checkResult(CSCardEndTransaction(hCard, dwDisposition.dword))
}

/// Retrieves the current reader attributes for the given handle. It does not affect the state of the reader, driver, or card
///
/// - parameters:
///   - hCard: Card handle as returned by `SCardConnect`
///   - dwAttrID: Identifier for the attribute to get
public func SCardGetAttrib(
    _ hCard: SCardHandle,
    _ dwAttrID: DWORD
) throws (SCardError) -> ByteCollection {
    let dwAttrID = dwAttrID
    var pcbAttrLen: DWORD = 0

    try SCardError.checkResult(CSCardGetAttrib(hCard, dwAttrID, nil, &pcbAttrLen))

    let pbAttr: UnsafeMutablePointer<UInt8> = .allocate(capacity: Int(pcbAttrLen))
    defer { pbAttr.deallocate() }

    try SCardError.checkResult(CSCardGetAttrib(hCard, dwAttrID, pbAttr, &pcbAttrLen))
    return ByteCollection(pbAttr, capacity: Int(pcbAttrLen))
}

/// The SCardSetAttrib function sets the given reader attribute for the given handle
///
/// It does not affect the state of the reader, reader driver, or smart card.
/// Not all attributes are supported by all readers (nor can they be set at all times) as many of the attributes are under direct control of the transport protocol
///
/// - parameters:
///   - hCard: Card handle as returned by `SCardConnect`
///   - dwAttrID: Identifier for the attribute to set
///   - pbAttr: Attribute value
public func CSCardSetAttrib(
    _ hCard: SCardHandle,
    _ dwAttrID: DWORD,
    _ pbAttr: ByteCollection
) throws (SCardError) {
    let dwAttrID = dwAttrID
    var pbAttr = pbAttr

    try SCardError.checkResult(CSCardSetAttrib(hCard, dwAttrID, &pbAttr, DWORD(pbAttr.count)))
}
