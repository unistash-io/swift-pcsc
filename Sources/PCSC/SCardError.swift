//
//  Created by Adam Stragner
//

import Essentials
@_implementationOnly import Clibpcsclite

// MARK: - SCardError

public struct SCardError: Error {
    // MARK: Lifecycle

    public init(_ code: Code) {
        self.code = code
    }

    init?(_ result: LONG) {
        guard result != 0
        else {
            return nil
        }

        let value = UInt(byteCollection: result.byteCollection()) // LONG -> ULONG
        self.init(Code(rawValue: value) ?? .unknownError)
    }

    // MARK: Public

    public let code: Code

    // MARK: Internal

    static func checkResult(_ result: LONG) throws (SCardError) {
        guard let error = SCardError(result)
        else {
            return
        }

        throw error
    }
}

// MARK: LocalizedError

extension SCardError: LocalizedError {
    public var errorDescription: String? {
        "PC/SC Error: 0x\(String(code.rawValue, radix: 16)) - \(code.description))"
    }
}

// MARK: Hashable

extension SCardError: Hashable {}

// MARK: Sendable

extension SCardError: Sendable {}

// MARK: SCardError.Code

public extension SCardError {
    enum Code: UInt {
        /// No error was encountered
        /// `SCARD_S_SUCCESS`
        /// case SUCCESS = 0x0000_0000

        /// An internal consistency check failed
        case internalError = 0x8010_0001

        /// The action was cancelled by an `SCardManager.cancel()` request
        case cancelled = 0x8010_0002

        /// The `SCardReader` are invalid
        case invalidReader = 0x8010_0003

        /// One or more of the supplied parameters could not be properly interpreted
        case invalidParameter = 0x8010_0004

        /// Registry startup information is missing or invalid
        case invalidTarget = 0x8010_0005

        /// Not enough memory available to complete this command
        case noMemory = 0x8010_0006

        /// An internal consistency timer has expired
        case waitedTooLong = 0x8010_0007

        /// The data buffer to receive returned data is too small for the returned data
        case insufficientBuffer = 0x8010_0008

        /// The specified reader name is not recognized
        case unknownReader = 0x8010_0009

        /// The user-specified timeout value has expired
        case timeout = 0x8010_000A

        /// The smart card cannot be accessed because of other connections outstanding
        case sharingViolation = 0x8010_000B

        /// The operation requires a Smart Card, but no Smart Card is currently in the device
        case noSmartcard = 0x8010_000C

        /// The specified smart card name is not recognized
        case unknownCard = 0x8010_000D

        /// The system could not dispose of the media in the requested manner
        case cantDispose = 0x8010_000E

        /// The requested protocols are incompatible with the protocol currently in use with the smart card
        case protoMismatch = 0x8010_000F

        /// The reader or smart card is not ready to accept commands
        case notReady = 0x8010_0010

        /// One or more of the supplied parameters values could not be properly interpreted
        case invalidValue = 0x8010_0011

        /// The action was cancelled by the system, presumably to log off or shut down
        case systemCancelled = 0x8010_0012

        /// An internal communications error has been detected
        case communicationError = 0x8010_0013

        /// An internal error has been detected, but the source is unknown
        case unknownError = 0x8010_0014

        /// An ATR obtained from the registry is not a valid ATR string
        case invalidATR = 0x8010_0015

        /// An attempt was made to end a non-existent transaction
        case notTransacted = 0x8010_0016

        /// The specified reader `SCardReader` is not currently available for use
        case readerUnavailable = 0x8010_0017

        /// The operation has been aborted to allow the server application to exit
        case shutdown = 0x8010_0018

        /// The PCI Receive buffer was too small
        case pciTooSmall = 0x8010_0019

        /// The reader driver does not meet minimal requirements for support
        case readerUnsupported = 0x8010_001A

        /// The reader driver did not produce a unique reader name
        case duplicateReader = 0x8010_001B

        /// The smart card does not meet minimal requirements for support
        case cardUnsupported = 0x8010_001C

        /// The Smart card resource manager is not running
        case noService = 0x8010_001D

        /// The Smart card resource manager has shut down
        case serviceStopped = 0x8010_001E

        /// An unexpected card error has occurred
        case unexpected = 0x8010_001F

        /// No primary provider can be found for the smart card
        case iccInstallation = 0x8010_0020

        /// The requested order of object creation is not supported
        case iccCreateorder = 0x8010_0021

        /// This smart card does not support the requested feature
        case unsupportedFeature = 0x8010_0022

        /// The identified directory does not exist in the smart card
        case directoryNotFound = 0x8010_0023

        /// The identified file does not exist in the smart card
        case fileNotFound = 0x8010_0024

        /// The supplied path does not represent a smart card directory
        case noDirectory = 0x8010_0025

        /// The supplied path does not represent a smart card file
        case noFile = 0x8010_0026

        /// Access is denied to this file
        case noAccess = 0x8010_0027

        /// The smart card does not have enough memory to store the information
        case writeTooMany = 0x8010_0028

        /// There was an error trying to set the smart card file object pointer
        case badSeek = 0x8010_0029

        /// The supplied PIN is incorrect
        case invalidCHV = 0x8010_002A

        /// An unrecognized error code was returned from a layered component (Smart Card Resource Manager)
        case unknownServerError = 0x8010_002B

        /// The requested certificate does not exist
        case noSuchCertificate = 0x8010_002C

        /// The requested certificate could not be obtained
        case certificateUnavailable = 0x8010_002D

        /// Cannot find a smart card reader
        case noReadersAvailable = 0x8010_002E

        /// A communications error with the smart card has been detected. Retry the operation
        case communicationDataLost = 0x8010_002F

        /// The requested key container does not exist on the smart card
        case noKeyContainer = 0x8010_0030

        /// The Smart Card Resource Manager is too busy to complete this operation
        case serverTooBusy = 0x8010_0031

        /// The reader cannot communicate with the card, due to ATR string configuration conflicts
        case unsupportedCard = 0x8010_0065

        /// The smart card is not responding to a reset
        case unresponsiveCard = 0x8010_0066

        /// Power has been removed from the smart card, so that further communication is not possible
        case unpoweredCard = 0x8010_0067

        /// The smart card has been reset, so any shared state information is invalid
        case resetCard = 0x8010_0068

        /// The smart card has been removed, so further communication is not possible
        case removedCard = 0x8010_0069

        /// Access was denied because of a security violation
        case securityViolation = 0x8010_006A

        /// The card cannot be accessed because the wrong PIN was presented
        case wrongCHV = 0x8010_006B

        /// The card cannot be accessed because the maximum number of PIN entry attempts has been reached
        case chvBlocked = 0x8010_006C

        /// The end of the smart card file has been reached
        case EOF = 0x8010_006D

        /// The user pressed 'Cancel' on a Smart Card Selection Dialog
        case cancelledByUser = 0x8010_006E

        /// No PIN was presented to the smart card
        case cardNotAuthenticated = 0x8010_006F

        /// The smart card has been inserted, but the card is not yet authenticated
        /// @note PC/SC Lite specific extension
        ///
        /// `SCARD_W_INSERTED_CARD`
        /// case _INSERTED_CARD = 0x8010_006A

        /// The smart card does not support the requested feature
        /// @note PC/SC Lite specific extension
        ///
        /// `SCARD_E_UNSUPPORTED_FEATURE`
        /// case _UNSUPPORTED_FEATURE = 0x8010_001F
    }
}

// MARK: - SCardError.Code + Hashable

extension SCardError.Code: Hashable {}

// MARK: - SCardError.Code + Sendable

extension SCardError.Code: Sendable {}

// MARK: - SCardError.Code + CustomStringConvertible

extension SCardError.Code: CustomStringConvertible {
    public var description: String {
        switch self {
        case .internalError: "An internal consistency check failed"
        case .cancelled: "The action was cancelled by an SCardCancel request"
        case .invalidReader: "The supplied handle was invalid"
        case .invalidParameter: "One or more of the supplied parameters could not be properly interpreted"
        case .invalidTarget: "Registry startup information is missing or invalid"
        case .noMemory: "Not enough memory available to complete this command"
        case .waitedTooLong: "An internal consistency timer has expired"
        case .insufficientBuffer: "The data buffer to receive returned data is too small for the returned data"
        case .unknownReader: "The specified reader name is not recognized"
        case .timeout: "The user-specified timeout value has expired"
        case .sharingViolation: "The smart card cannot be accessed because of other connections outstanding"
        case .noSmartcard: "The operation requires a Smart Card, but no Smart Card is currently in the device"
        case .unknownCard: "The specified smart card name is not recognized"
        case .cantDispose: "The system could not dispose of the media in the requested manner"
        case .protoMismatch: "The requested protocols are incompatible with the protocol currently in use with the smart card"
        case .notReady: "The reader or smart card is not ready to accept commands"
        case .invalidValue: "One or more of the supplied parameters values could not be properly interpreted"
        case .systemCancelled: "The action was cancelled by the system, presumably to log off or shut down"
        case .communicationError: "An internal communications error has been detected"
        case .unknownError: "An internal error has been detected, but the source is unknown"
        case .invalidATR: "An ATR obtained from the registry is not a valid ATR string"
        case .notTransacted: "An attempt was made to end a non-existent transaction"
        case .readerUnavailable: "The specified reader is not currently available for use"
        case .shutdown: "The operation has been aborted to allow the server application to exit"
        case .pciTooSmall: "The PCI Receive buffer was too small"
        case .readerUnsupported: "The reader driver does not meet minimal requirements for support"
        case .duplicateReader: "The reader driver did not produce a unique reader name"
        case .cardUnsupported: "The smart card does not meet minimal requirements for support"
        case .noService: "The Smart card resource manager is not running"
        case .serviceStopped: "The Smart card resource manager has shut down"
        case .unexpected: "An unexpected card error has occurred"
        case .iccInstallation: "No primary provider can be found for the smart card"
        case .iccCreateorder: "The requested order of object creation is not supported"
        case .unsupportedFeature: "This smart card does not support the requested feature"
        case .directoryNotFound: "The identified directory does not exist in the smart card"
        case .fileNotFound: "The identified file does not exist in the smart card"
        case .noDirectory: "The supplied path does not represent a smart card directory"
        case .noFile: "The supplied path does not represent a smart card file"
        case .noAccess: "Access is denied to this file"
        case .writeTooMany: "The smart card does not have enough memory to store the information"
        case .badSeek: "There was an error trying to set the smart card file object pointer"
        case .invalidCHV: "The supplied PIN is incorrect"
        case .unknownServerError: "An unrecognized error code was returned from a layered component"
        case .noSuchCertificate: "The requested certificate does not exist"
        case .certificateUnavailable: "The requested certificate could not be obtained"
        case .noReadersAvailable: "Cannot find a smart card reader"
        case .communicationDataLost: "A communications error with the smart card has been detected. Retry the operation"
        case .noKeyContainer: "The requested key container does not exist on the smart card"
        case .serverTooBusy: "The Smart Card Resource Manager is too busy to complete this operation"
        case .unsupportedCard: "The reader cannot communicate with the card, due to ATR string configuration conflicts"
        case .unresponsiveCard: "The smart card is not responding to a reset"
        case .unpoweredCard: "Power has been removed from the smart card, so that further communication is not possible"
        case .resetCard: "The smart card has been reset, so any shared state information is invalid"
        case .removedCard: "The smart card has been removed, so further communication is not possible"
        case .securityViolation: "Access was denied because of a security violation"
        case .wrongCHV: "The card cannot be accessed because the wrong PIN was presented"
        case .chvBlocked: "The card cannot be accessed because the maximum number of PIN entry attempts has been reached"
        case .EOF: "The end of the smart card file has been reached"
        case .cancelledByUser: "The user pressed 'Cancel' on a Smart Card Selection Dialog"
        case .cardNotAuthenticated: "No PIN was presented to the smart card"
        }
    }
}
