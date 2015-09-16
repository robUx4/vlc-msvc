#include <windows.h>
#include <winapifamily.h>

#if (WINAPI_FAMILY == WINAPI_FAMILY_PC_APP || WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)

# define COBJMACROS
# define INITGUID
# include <winstring.h>
# include <windows.security.cryptography.h>
# include <windows.security.cryptography.core.h>
# ifndef _MSC_VER /* roapi.h is a C++ include file that doesn't work with C files */
#  include <roapi.h>
# else /* _MSC_VER */
DECLSPEC_IMPORT HRESULT WINAPI RoGetActivationFactory(HSTRING activatableClassId, REFIID iid, void **factory);
typedef __x_ABI_CWindows_CSecurity_CCryptography_CICryptographicBufferStatics ICryptographicBufferStatics;
typedef __x_ABI_CWindows_CStorage_CStreams_CIBuffer                           IBuffer;
#   define ICryptographicBufferStatics_Release         __x_ABI_CWindows_CSecurity_CCryptography_CICryptographicBufferStatics_Release
#   define ICryptographicBufferStatics_CopyToByteArray __x_ABI_CWindows_CSecurity_CCryptography_CICryptographicBufferStatics_CopyToByteArray
#   define IBuffer_Release                             __x_ABI_CWindows_CStorage_CStreams_CIBuffer_Release
#   define ICryptographicBufferStatics_GenerateRandom  __x_ABI_CWindows_CSecurity_CCryptography_CICryptographicBufferStatics_GenerateRandom
DEFINE_GUID(IID_ICryptographicBufferStatics, 0x320b7e22, 0x3cb0, 0x4cdf, 0x86,0x63, 0x1d,0x28,0x91,0x00,0x65,0xeb);

typedef __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStore         ICertificateStore;
typedef __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStoresStatics ICertificateStoresStatics;
#define      ICertificateStoresStatics_Release                                  __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStoresStatics_Release
#define      ICertificateStoresStatics_get_TrustedRootCertificationAuthorities  __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStoresStatics_get_TrustedRootCertificationAuthorities
#define      ICertificateStoresStatics_get_IntermediateCertificationAuthorities __x_ABI_CWindows_CSecurity_CCryptography_CCertificates_CICertificateStoresStatics_get_IntermediateCertificationAuthorities
DEFINE_GUID(IID_ICertificateStoresStatics,   0xFBECC739, 0xC6FE, 0x4DE7, 0x99, 0xCF, 0x74, 0xC3, 0xE5, 0x96, 0xE0, 0x32);
# endif /* _MSC_VER */

typedef void *HCRYPTPROV_LEGACY;
typedef ICertificateStore *HCERTSTORE;

typedef struct {
    DWORD dwCertEncodingType;
    BYTE *pbCertEncoded;
    DWORD cbCertEncoded;
} CERT_CONTEXT;
typedef const CERT_CONTEXT *PCCERT_CONTEXT;
typedef struct {
    DWORD dwCertEncodingType;
    BYTE *pbCrlEncoded;
    DWORD cbCrlEncoded;
} CRL_CONTEXT;
typedef const CRL_CONTEXT *PCCRL_CONTEXT;

#define X509_ASN_ENCODING  1


#define PROV_RSA_FULL        1
#define MS_DEF_PROV          L"Microsoft Base Cryptographic Provider v1.0"
#define CRYPT_SILENT         0x40
#define CRYPT_VERIFYCONTEXT  0xF0000000

typedef ICryptographicBufferStatics *HCRYPTPROV;

__forceinline BOOL CryptAcquireContext(HCRYPTPROV *phProv, LPCTSTR pszContainer, LPCTSTR pszProvider, DWORD dwProvType, DWORD dwFlags)
{
    static const WCHAR *className = L"Windows.Security.Cryptography.CryptographicBuffer";
    const UINT32 clen = wcslen(className);

    HSTRING hClassName = NULL;
    HSTRING_HEADER header;
    HRESULT hr = WindowsCreateStringReference(className, clen, &header, &hClassName);
    if (FAILED(hr)) {
        WindowsDeleteString(hClassName);
        return FALSE;
    }

    ICryptographicBufferStatics *cryptoStatics = NULL;
    hr = RoGetActivationFactory(hClassName, &IID_ICryptographicBufferStatics, (void**)&cryptoStatics);
    WindowsDeleteString(hClassName);

    if (FAILED(hr))
        return FALSE;

    *phProv = cryptoStatics;

    return TRUE;
}

__forceinline BOOL CryptReleaseContext(HCRYPTPROV phProv, DWORD dwFlags)
{
    HRESULT hr = ICryptographicBufferStatics_Release(phProv);
    return SUCCEEDED(hr) && dwFlags==0;
}

__forceinline BOOL CryptGenRandom(HCRYPTPROV phProv, DWORD dwLen, BYTE *pbBuffer)
{
    IBuffer *buffer = NULL;
    HRESULT hr = ICryptographicBufferStatics_GenerateRandom(phProv, dwLen, &buffer);
    if (FAILED(hr)) {
        return FALSE;
    }

    UINT32 olength;
    unsigned char *rnd = NULL;
    hr = ICryptographicBufferStatics_CopyToByteArray(phProv, buffer, &olength, (BYTE**)&rnd);
    if (FAILED(hr)) {
        IBuffer_Release(buffer);
        return FALSE;
    }
    memcpy(pbBuffer, rnd, dwLen);

    IBuffer_Release(buffer);
    return TRUE;
}

__forceinline HCERTSTORE CertOpenSystemStore(HCRYPTPROV_LEGACY hprov, LPCSTR szSubsystemProtocol)
{
    static const WCHAR *className = L"Windows.Security.Cryptography.Certificates";
    const UINT32 clen = wcslen(className);

    HSTRING hClassName = NULL;
    HSTRING_HEADER header;
    HRESULT hr = WindowsCreateStringReference(className, clen, &header, &hClassName);
    if (FAILED(hr)) {
        WindowsDeleteString(hClassName);
        return NULL;
    }

    ICertificateStoresStatics *certStoresStatics = NULL;
    hr = RoGetActivationFactory(hClassName, &IID_ICertificateStoresStatics, (void**)&certStoresStatics);
    WindowsDeleteString(hClassName);

    if (FAILED(hr))
        return NULL;
    
    if (!strcmp(szSubsystemProtocol, "ROOT"))
    {
        ICertificateStore *result;
        hr = ICertificateStoresStatics_get_TrustedRootCertificationAuthorities(certStoresStatics, &result);
        ICertificateStoresStatics_Release(certStoresStatics);
        if (SUCCEEDED(hr))
        {
            return result;
        }
    }
    else if (!strcmp(szSubsystemProtocol, "CA"))
    {
        ICertificateStore *result;
        hr = ICertificateStoresStatics_get_IntermediateCertificationAuthorities(certStoresStatics, &result);
        ICertificateStoresStatics_Release(certStoresStatics);
        if (SUCCEEDED(hr))
        {
            return result;
        }
    }
    else
    {
        ICertificateStoresStatics_Release(certStoresStatics);
    }

    return NULL;
}

__forceinline BOOL WINAPI CertCloseStore(HCERTSTORE hCertStore, DWORD dwFlags)
{
    HRESULT hr = ICertificateStoresStatics_Release(hCertStore);
    return SUCCEEDED(hr);
}

__forceinline PCCERT_CONTEXT CertEnumCertificatesInStore(HCERTSTORE hCertStore, PCCERT_CONTEXT pPrevCertContext)
{
    return NULL;
}

__forceinline PCCRL_CONTEXT CertEnumCRLsInStore(HCERTSTORE hCertStore, PCCRL_CONTEXT pPrevCrlContext)
{
    return NULL;
}

#define Loaded_CertEnumCRLsInStore CertEnumCRLsInStore

#endif /* WINAPI_FAMILY */
