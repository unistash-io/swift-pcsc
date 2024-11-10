//
//  Created by Adam Stragner
//

#ifndef _Clibpcsclite_h
#define _Clibpcsclite_h

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

#ifndef C_PCSC_API
#define C_PCSC_API extern __attribute__((visibility ("default")))
#endif

#define MAX_ATR_SIZE 33

#ifdef __APPLE__
typedef int32_t LONG;
typedef uint32_t DWORD;
#else
typedef long LONG;
typedef unsigned long DWORD;
#endif

typedef DWORD *LPDWORD;


typedef LONG SCARDCONTEXT;
typedef SCARDCONTEXT *PSCARDCONTEXT;
typedef SCARDCONTEXT *LPSCARDCONTEXT;

typedef LONG SCARDHANDLE;
typedef SCARDHANDLE *PSCARDHANDLE;
typedef SCARDHANDLE *LPSCARDHANDLE;

#ifdef __APPLE__
#pragma pack(1)
#else
#pragma pack(push, 1)
#endif

typedef struct
{
    const char *szReader;
    void *pvUserData;
    DWORD dwCurrentState;
    DWORD dwEventState;
    DWORD cbAtr;
    unsigned char rgbAtr[MAX_ATR_SIZE];
} CSCARD_READERSTATE, *CLPSCARD_READERSTATE;

typedef struct
{
    uint32_t dwProtocol;
    uint32_t cbPciLength;
} CSCARD_IO_REQUEST, *CPSCARD_IO_REQUEST, *CLPSCARD_IO_REQUEST;

typedef CSCARD_IO_REQUEST * CLPCSCARD_IO_REQUEST;
C_PCSC_API const CSCARD_IO_REQUEST cg_rgSCardT0Pci, cg_rgSCardT1Pci, cg_rgSCardRawPci;

#ifdef __APPLE__
#pragma pack()
#else
#pragma pack(pop)
#endif

#define CSCARD_PROTOCOL_UNDEFINED    0x0000
#define CSCARD_PROTOCOL_UNSET        SCARD_PROTOCOL_UNDEFINED
#define CSCARD_PROTOCOL_T0           0x0001
#define CSCARD_PROTOCOL_T1           0x0002
#define CSCARD_PROTOCOL_RAW          0x0004
#define CSCARD_PROTOCOL_T15          0x0008

C_PCSC_API LONG CSCardEstablishContext(DWORD dwScope,
                                       const void *pvReserved1,
                                       const void *pvReserved2,
                                       LPSCARDCONTEXT phContext);

C_PCSC_API LONG CSCardReleaseContext(SCARDCONTEXT hContext);
C_PCSC_API LONG CSCardIsValidContext(SCARDCONTEXT hContext);

C_PCSC_API LONG CSCardConnect(SCARDCONTEXT hContext,
                              const char *szReader,
                              DWORD dwShareMode,
                              DWORD dwPreferredProtocols,
                              LPSCARDHANDLE phCard,
                              DWORD *pdwActiveProtocol);

C_PCSC_API LONG CSCardReconnect(SCARDHANDLE hCard,
                                DWORD dwShareMode,
                                DWORD dwPreferredProtocols,
                                DWORD dwInitialization,
                                LPDWORD pdwActiveProtocol);

C_PCSC_API LONG CSCardDisconnect(SCARDHANDLE hCard, DWORD dwDisposition);
C_PCSC_API LONG CSCardBeginTransaction(SCARDHANDLE hCard);
C_PCSC_API LONG CSCardEndTransaction(SCARDHANDLE hCard, DWORD dwDisposition);

C_PCSC_API LONG CSCardStatus(SCARDHANDLE hCard,
                             char *mszReaderNames,
                             LPDWORD pcchReaderLen,
                             LPDWORD pdwState,
                             LPDWORD pdwProtocol,
                             unsigned char *pbAtr,
                             LPDWORD pcbAtrLen);

C_PCSC_API LONG CSCardGetStatusChange(SCARDCONTEXT hContext,
                                      DWORD dwTimeout,
                                      CSCARD_READERSTATE *rgReaderStates,
                                      DWORD cReaders);

C_PCSC_API LONG CSCardControl(SCARDHANDLE hCard,
                              DWORD dwControlCode,
                              const void *pbSendBuffer,
                              DWORD cbSendLength,
                              void *pbRecvBuffer,
                              DWORD cbRecvLength,
                              DWORD *lpBytesReturned);

C_PCSC_API LONG CSCardTransmit(SCARDHANDLE hCard,
                               const CSCARD_IO_REQUEST *pioSendPci,
                               const unsigned char *pbSendBuffer,
                               DWORD cbSendLength,
                               CLPSCARD_IO_REQUEST pioRecvPci,
                               unsigned char *pbRecvBuffer,
                               DWORD *pcbRecvLength);

C_PCSC_API LONG CSCardListReaderGroups(SCARDCONTEXT hContext,
                                       char *mszGroups,
                                       LPDWORD pcchGroups);

C_PCSC_API LONG CSCardListReaders(SCARDCONTEXT hContext,
                                  const char *mszGroups,
                                  char *mszReaders,
                                  LPDWORD pcchReaders);

C_PCSC_API LONG CSCardCancel(SCARDCONTEXT hContext);

C_PCSC_API LONG CSCardGetAttrib(SCARDHANDLE hCard,
                                DWORD dwAttrId,
                                uint8_t *pbAttr,
                                DWORD *pcbAttrLen);

C_PCSC_API LONG CSCardSetAttrib(SCARDHANDLE hCard,
                                DWORD dwAttrId,
                                const uint8_t *pbAttr,
                                DWORD cbAttrLen);


#if defined(__cplusplus)
}
#endif

#endif
