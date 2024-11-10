//
//  Created by Adam Stragner
//

#include <Clibpcsclite.h>

#if __has_include(<PCSC/winscard.h>) && __has_include(<PCSC/wintypes.h>)
#include <PCSC/winscard.h>
#include <PCSC/wintypes.h>
#else
#include <winscard.h>
#include <wintypes.h>
#endif

const CSCARD_IO_REQUEST cg_rgSCardT0Pci = { CSCARD_PROTOCOL_T0, sizeof(CSCARD_IO_REQUEST) };
const CSCARD_IO_REQUEST cg_rgSCardT1Pci = { CSCARD_PROTOCOL_T1, sizeof(CSCARD_IO_REQUEST) };
const CSCARD_IO_REQUEST cg_rgSCardRawPci = { CSCARD_PROTOCOL_RAW, sizeof(CSCARD_IO_REQUEST) };

LONG CSCardEstablishContext(DWORD dwScope,
                            const void *pvReserved1,
                            const void *pvReserved2,
                            LPSCARDCONTEXT phContext)
{
    return SCardEstablishContext(dwScope, pvReserved1, pvReserved2, phContext);
}

LONG CSCardReleaseContext(SCARDCONTEXT hContext)
{
    return SCardReleaseContext(hContext);
}

LONG CSCardIsValidContext(SCARDCONTEXT hContext)
{
    return SCardIsValidContext(hContext);
}

LONG CSCardConnect(SCARDCONTEXT hContext,
                   const char *szReader,
                   DWORD dwShareMode,
                   DWORD dwPreferredProtocols,
                   LPSCARDHANDLE phCard,
                   LPDWORD pdwActiveProtocol)
{
    return SCardConnect(hContext, szReader, dwShareMode, dwPreferredProtocols, phCard, pdwActiveProtocol);
}

LONG CSCardReconnect(SCARDHANDLE hCard,
                     DWORD dwShareMode,
                     DWORD dwPreferredProtocols,
                     DWORD dwInitialization,
                     LPDWORD pdwActiveProtocol)
{
    return SCardReconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization, pdwActiveProtocol);
}

LONG CSCardDisconnect(SCARDHANDLE hCard,
                      DWORD dwDisposition)
{
    return SCardDisconnect(hCard, dwDisposition);
}

LONG CSCardBeginTransaction(SCARDHANDLE hCard)
{
    return SCardBeginTransaction(hCard);
}

LONG CSCardEndTransaction(SCARDHANDLE hCard,
                          DWORD dwDisposition)
{
    return SCardEndTransaction(hCard, dwDisposition);
}

LONG CSCardStatus(SCARDHANDLE hCard,
                  char *mszReaderNames,
                  LPDWORD pcchReaderLen,
                  LPDWORD pdwState,
                  LPDWORD pdwProtocol,
                  unsigned char *pbAtr,
                  LPDWORD pcbAtrLen)
{
    return SCardStatus(hCard, mszReaderNames, pcchReaderLen, pdwState, pdwProtocol, pbAtr, pcbAtrLen);
}

LONG CSCardGetStatusChange(SCARDCONTEXT hContext,
                           DWORD dwTimeout,
                           CSCARD_READERSTATE *rgReaderStates,
                           DWORD cReaders)
{
    return SCardGetStatusChange(hContext, dwTimeout, (SCARD_READERSTATE *)rgReaderStates, cReaders);
}

LONG CSCardControl(SCARDHANDLE hCard,
                   DWORD dwControlCode,
                   const void *pbSendBuffer,
                   DWORD cbSendLength,
                   void *pbRecvBuffer,
                   DWORD cbRecvLength,
                   LPDWORD lpBytesReturned)
{
    return SCardControl(hCard, dwControlCode, pbSendBuffer, cbSendLength, pbRecvBuffer, cbRecvLength, lpBytesReturned);
}

LONG CSCardTransmit(SCARDHANDLE hCard,
                    const CSCARD_IO_REQUEST *pioSendPci,
                    const unsigned char *pbSendBuffer,
                    DWORD cbSendLength,
                    CLPSCARD_IO_REQUEST pioRecvPci,
                    unsigned char *pbRecvBuffer,
                    LPDWORD pcbRecvLength)
{
    return SCardTransmit(hCard,
                         (LPCSCARD_IO_REQUEST)pioSendPci,
                         pbSendBuffer, cbSendLength,
                         (LPSCARD_IO_REQUEST)pioRecvPci,
                         pbRecvBuffer, pcbRecvLength);
}

LONG CSCardListReaderGroups(SCARDCONTEXT hContext,
                            char *mszGroups,
                            LPDWORD pcchGroups)
{
    return SCardListReaderGroups(hContext, mszGroups, pcchGroups);
}

LONG CSCardListReaders(SCARDCONTEXT hContext,
                       const char *mszGroups,
                       char *mszReaders,
                       LPDWORD pcchReaders)
{
    return SCardListReaders(hContext, mszGroups, mszReaders, pcchReaders);
}

LONG CSCardCancel(SCARDCONTEXT hContext)
{
    return SCardCancel(hContext);
}

LONG CSCardGetAttrib(SCARDHANDLE hCard,
                     DWORD dwAttrId,
                     uint8_t *pbAttr,
                     LPDWORD pcbAttrLen)
{
    return SCardGetAttrib(hCard, dwAttrId, pbAttr, pcbAttrLen);
}

LONG CSCardSetAttrib(SCARDHANDLE hCard,
                     DWORD dwAttrId,
                     const uint8_t *pbAttr,
                     DWORD cbAttrLen)
{
    return SCardSetAttrib(hCard, dwAttrId, pbAttr, cbAttrLen);
}
