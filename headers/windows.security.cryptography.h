#ifndef _WINSTORE_WIN_SEC_CRYPTO_H
#define _WINSTORE_WIN_SEC_CRYPTO_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

# pragma warning(push)
# pragma warning(disable:4067)    /* newline for __has_include_next */
# if defined(__clang__) && __has_include_next(<windows.security.cryptography.h>)
#  include_next <windows.security.cryptography.h>
# else /* no clang or no windows.security.cryptography.h */
#  define COBJMACROS
#  if (_WIN32_WINNT == 0x603)
#   include <../../../8.1/include/winrt/windows.security.cryptography.h>
#  else
#   include <../winrt/windows.security.cryptography.h>
#  endif
# endif
# pragma warning(pop)

typedef __x_ABI_CWindows_CSecurity_CCryptography_CICryptographicBufferStatics ICryptographicBufferStatics;
typedef __x_ABI_CWindows_CStorage_CStreams_CIBuffer                           IBuffer;
#define ICryptographicBufferStatics_GenerateRandom  __x_ABI_CWindows_CSecurity_CCryptography_CICryptographicBufferStatics_GenerateRandom
#define ICryptographicBufferStatics_CopyToByteArray __x_ABI_CWindows_CSecurity_CCryptography_CICryptographicBufferStatics_CopyToByteArray
#define ICryptographicBufferStatics_Release         __x_ABI_CWindows_CSecurity_CCryptography_CICryptographicBufferStatics_Release
#define IBuffer_Release                             __x_ABI_CWindows_CStorage_CStreams_CIBuffer_Release
#if 1
DEFINE_GUID(IID_ICryptographicBufferStatics, 0x320b7e22, 0x3cb0, 0x4cdf, 0x86,0x63, 0x1d,0x28,0x91,0x00,0x65,0xeb);
#else
#define IID_ICryptographicBufferStatics             IID___x_ABI_CWindows_CSecurity_CCryptography_CICryptographicBufferStatics
#endif
#if (_WIN32_WINNT <= 0x603)
typedef ICryptographicBufferStatics *HCRYPTPROV;
#endif /* _WIN32_WINNT == 0x603 */

#endif /* _WINSTORE_WIN_SEC_CRYPTO_H */
