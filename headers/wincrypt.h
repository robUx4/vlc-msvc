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

#if !defined(_WIN32_WINNT) || _WIN32_WINNT < 0x0A00
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
#endif /* _WIN32_WINNT */

// By default, when the CurrentUser "Root" store is opened, any SystemRegistry
// roots not also on the protected root list are deleted from the cache before
// CertOpenStore() returns. Set the following flag to return all the roots
// in the SystemRegistry without checking the protected root list.
#define CERT_SYSTEM_STORE_UNPROTECTED_FLAG      0x40000000

#define CERT_SYSTEM_STORE_DEFER_READ_FLAG       0x20000000

// Location of the system store:
#define CERT_SYSTEM_STORE_LOCATION_MASK         0x00FF0000
#define CERT_SYSTEM_STORE_LOCATION_SHIFT        16


//  Registry: HKEY_CURRENT_USER or HKEY_LOCAL_MACHINE
#define CERT_SYSTEM_STORE_CURRENT_USER_ID       1
#define CERT_SYSTEM_STORE_LOCAL_MACHINE_ID      2
//  Registry: HKEY_LOCAL_MACHINE\Software\Microsoft\Cryptography\Services
#define CERT_SYSTEM_STORE_CURRENT_SERVICE_ID    4
#define CERT_SYSTEM_STORE_SERVICES_ID           5
//  Registry: HKEY_USERS
#define CERT_SYSTEM_STORE_USERS_ID              6

//  Registry: HKEY_CURRENT_USER\Software\Policies\Microsoft\SystemCertificates
#define CERT_SYSTEM_STORE_CURRENT_USER_GROUP_POLICY_ID    7
//  Registry: HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\SystemCertificates
#define CERT_SYSTEM_STORE_LOCAL_MACHINE_GROUP_POLICY_ID   8

//  Registry: HKEY_LOCAL_MACHINE\Software\Microsoft\EnterpriseCertificates
#define CERT_SYSTEM_STORE_LOCAL_MACHINE_ENTERPRISE_ID     9

#define CERT_SYSTEM_STORE_CURRENT_USER          \
    (CERT_SYSTEM_STORE_CURRENT_USER_ID << CERT_SYSTEM_STORE_LOCATION_SHIFT)
#define CERT_SYSTEM_STORE_LOCAL_MACHINE         \
    (CERT_SYSTEM_STORE_LOCAL_MACHINE_ID << CERT_SYSTEM_STORE_LOCATION_SHIFT)
#define CERT_SYSTEM_STORE_CURRENT_SERVICE       \
    (CERT_SYSTEM_STORE_CURRENT_SERVICE_ID << CERT_SYSTEM_STORE_LOCATION_SHIFT)
#define CERT_SYSTEM_STORE_SERVICES              \
    (CERT_SYSTEM_STORE_SERVICES_ID << CERT_SYSTEM_STORE_LOCATION_SHIFT)
#define CERT_SYSTEM_STORE_USERS                 \
    (CERT_SYSTEM_STORE_USERS_ID << CERT_SYSTEM_STORE_LOCATION_SHIFT)

#define CERT_SYSTEM_STORE_CURRENT_USER_GROUP_POLICY   \
    (CERT_SYSTEM_STORE_CURRENT_USER_GROUP_POLICY_ID << \
        CERT_SYSTEM_STORE_LOCATION_SHIFT)
#define CERT_SYSTEM_STORE_LOCAL_MACHINE_GROUP_POLICY  \
    (CERT_SYSTEM_STORE_LOCAL_MACHINE_GROUP_POLICY_ID << \
        CERT_SYSTEM_STORE_LOCATION_SHIFT)

#define CERT_SYSTEM_STORE_LOCAL_MACHINE_ENTERPRISE  \
    (CERT_SYSTEM_STORE_LOCAL_MACHINE_ENTERPRISE_ID << \
        CERT_SYSTEM_STORE_LOCATION_SHIFT)

//+-------------------------------------------------------------------------
//  Certificate Store Provider Types
//--------------------------------------------------------------------------
#define CERT_STORE_PROV_MSG                 ((LPCSTR) 1)
#define CERT_STORE_PROV_MEMORY              ((LPCSTR) 2)
#define CERT_STORE_PROV_FILE                ((LPCSTR) 3)
#define CERT_STORE_PROV_REG                 ((LPCSTR) 4)

#define CERT_STORE_PROV_PKCS7               ((LPCSTR) 5)
#define CERT_STORE_PROV_SERIALIZED          ((LPCSTR) 6)
#define CERT_STORE_PROV_FILENAME_A          ((LPCSTR) 7)
#define CERT_STORE_PROV_FILENAME_W          ((LPCSTR) 8)
#define CERT_STORE_PROV_FILENAME            CERT_STORE_PROV_FILENAME_W
#define CERT_STORE_PROV_SYSTEM_A            ((LPCSTR) 9)
#define CERT_STORE_PROV_SYSTEM_W            ((LPCSTR) 10)
#define CERT_STORE_PROV_SYSTEM              CERT_STORE_PROV_SYSTEM_W

#define CERT_STORE_PROV_COLLECTION          ((LPCSTR) 11)
#define CERT_STORE_PROV_SYSTEM_REGISTRY_A   ((LPCSTR) 12)
#define CERT_STORE_PROV_SYSTEM_REGISTRY_W   ((LPCSTR) 13)
#define CERT_STORE_PROV_SYSTEM_REGISTRY     CERT_STORE_PROV_SYSTEM_REGISTRY_W
#define CERT_STORE_PROV_PHYSICAL_W          ((LPCSTR) 14)
#define CERT_STORE_PROV_PHYSICAL            CERT_STORE_PROV_PHYSICAL_W

// SmartCard Store Provider isn't supported
#define CERT_STORE_PROV_SMART_CARD_W        ((LPCSTR) 15)
#define CERT_STORE_PROV_SMART_CARD          CERT_STORE_PROV_SMART_CARD_W

#define CERT_STORE_PROV_LDAP_W              ((LPCSTR) 16)
#define CERT_STORE_PROV_LDAP                CERT_STORE_PROV_LDAP_W
#define CERT_STORE_PROV_PKCS12              ((LPCSTR) 17)

#define sz_CERT_STORE_PROV_MEMORY           "Memory"
#define sz_CERT_STORE_PROV_FILENAME_W       "File"
#define sz_CERT_STORE_PROV_FILENAME         sz_CERT_STORE_PROV_FILENAME_W
#define sz_CERT_STORE_PROV_SYSTEM_W         "System"
#define sz_CERT_STORE_PROV_SYSTEM           sz_CERT_STORE_PROV_SYSTEM_W
#define sz_CERT_STORE_PROV_PKCS7            "PKCS7"
#define sz_CERT_STORE_PROV_PKCS12           "PKCS12"
#define sz_CERT_STORE_PROV_SERIALIZED       "Serialized"

#define sz_CERT_STORE_PROV_COLLECTION       "Collection"
#define sz_CERT_STORE_PROV_SYSTEM_REGISTRY_W "SystemRegistry"
#define sz_CERT_STORE_PROV_SYSTEM_REGISTRY  sz_CERT_STORE_PROV_SYSTEM_REGISTRY_W
#define sz_CERT_STORE_PROV_PHYSICAL_W       "Physical"
#define sz_CERT_STORE_PROV_PHYSICAL         sz_CERT_STORE_PROV_PHYSICAL_W

// SmartCard Store Provider isn't supported
#define sz_CERT_STORE_PROV_SMART_CARD_W     "SmartCard"
#define sz_CERT_STORE_PROV_SMART_CARD       sz_CERT_STORE_PROV_SMART_CARD_W

#define sz_CERT_STORE_PROV_LDAP_W           "Ldap"
#define sz_CERT_STORE_PROV_LDAP             sz_CERT_STORE_PROV_LDAP_W


#endif /* WINAPI_FAMILY */
