#ifndef _WINSTORE_WIN_SEC_CRYPTO_CERT_H
#define _WINSTORE_WIN_SEC_CRYPTO_CERT_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

# pragma warning(push)
# pragma warning(disable:4067)    /* newline for __has_include_next */
# if defined(__clang__) && __has_include_next(<windows.security.cryptography.certificates.h>)
#  include_next <windows.security.cryptography.certificates.h>
# else /* no clang or no windows.security.cryptography.certificates.h */
#  define COBJMACROS
#  if (_WIN32_WINNT == 0x603)
#   include <../../../8.1/include/winrt/windows.security.cryptography.certificates.h>
#  else
#   include <../winrt/windows.security.cryptography.certificates.h>
#  endif
# endif
# pragma warning(pop)

typedef __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStore         ICertificateStore;
typedef __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStoresStatics ICertificateStoresStatics;
#define ICertificateStoresStatics_Release                                  __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStoresStatics_Release
#define ICertificateStoresStatics_get_TrustedRootCertificationAuthorities  __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStoresStatics_get_TrustedRootCertificationAuthorities
#define ICertificateStoresStatics_get_IntermediateCertificationAuthorities __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStoresStatics_get_IntermediateCertificationAuthorities
#if 1
DEFINE_GUID(IID_ICertificateStoresStatics,   0xFBECC739, 0xC6FE, 0x4DE7, 0x99, 0xCF, 0x74, 0xC3, 0xE5, 0x96, 0xE0, 0x32);
#else
#define IID_ICryptographicBufferStatics             IID___x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStoresStatics
#endif

#endif /* _WINSTORE_WIN_SEC_CRYPTO_CERT_H */
