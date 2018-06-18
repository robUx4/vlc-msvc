#ifndef _WINSTORE_WS2TCPIP_H
#define _WINSTORE_WS2TCPIP_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

# if defined(WINAPI_FAMILY) && (WINAPI_FAMILY == WINAPI_FAMILY_PC_APP || WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
#  undef _LOCAL_FAMILY_OVERRIDE_ws2tcpip
#  if WINAPI_FAMILY == WINAPI_FAMILY_PC_APP
#   define _LOCAL_FAMILY_OVERRIDE_ws2tcpip 1
#  else
#   define _LOCAL_FAMILY_OVERRIDE_ws2tcpip 2
#  endif
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_DESKTOP_APP
#  undef _INC_WINAPIFAMILY /* allow overriding the previous value */
# endif

# pragma warning(push)
# pragma warning(disable:4067)    /* newline for __has_include_next */
# if defined(__clang__) && __has_include_next(<ws2tcpip.h>)
#  ifndef WINAPI_PARTITION_PHONE_RESTRICTED
#   define WINAPI_PARTITION_PHONE_RESTRICTED  WINAPI_PARTITION_APP
#  endif
#  include_next <ws2tcpip.h>
# else /* no clang or no ws2tcpip.h */
#  if (_WIN32_WINNT == 0x603)
/* we don't want a gai_strerrorA that doesn't pass the WACK */
#   include <../../../8.1/include/um/winsock2.h>
#   define INCL_WINSOCK_API_PROTOTYPES 0
#   include <../../../8.1/include/um/ws2tcpip.h>

#define GAI_STRERROR_BUFFER_SIZE 1024
static __forceinline char *gai_strerrorA(int ecode)
{
    DWORD dwMsgLen;
    static WCHAR buffw[GAI_STRERROR_BUFFER_SIZE + 1];
    static CHAR buff[GAI_STRERROR_BUFFER_SIZE + 1];
    size_t len;

    dwMsgLen = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM
                             |FORMAT_MESSAGE_IGNORE_INSERTS
                             |FORMAT_MESSAGE_MAX_WIDTH_MASK,
                              NULL,
                              ecode,
                              MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                              (LPWSTR)buffw,
                              GAI_STRERROR_BUFFER_SIZE,
                              NULL);
    len = WideCharToMultiByte (CP_UTF8, 0, buffw, -1, NULL, 0, NULL, NULL);

    WideCharToMultiByte (CP_UTF8, 0, buffw, -1, buff, (len<GAI_STRERROR_BUFFER_SIZE) ? len : GAI_STRERROR_BUFFER_SIZE, NULL, NULL);

    return buff;
}

#  else
#   include <../um/ws2tcpip.h>
#  endif
# endif
# pragma warning(pop)

# if defined(_LOCAL_FAMILY_OVERRIDE_ws2tcpip)
   /* restore the previous family state */
#  ifndef _INC_WINAPIFAMILY
#   pragma message( "API family wasn't overriden in " __FILE__ )
#  endif
#  undef WINAPI_FAMILY
#  if _LOCAL_FAMILY_OVERRIDE_ws2tcpip == 1
#   define WINAPI_FAMILY WINAPI_FAMILY_PC_APP
#  else 
#   define WINAPI_FAMILY WINAPI_FAMILY_PHONE_APP
#  endif
# endif

#endif /* _WINSTORE_WS2TCPIP_H */
