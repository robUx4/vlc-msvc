#ifndef _WINSTORE_IPHLPAPI_H
#define _WINSTORE_IPHLPAPI_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

# if defined(WINAPI_FAMILY) && (WINAPI_FAMILY == WINAPI_FAMILY_PC_APP || WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
#  undef _LOCAL_FAMILY_OVERRIDE_iphlpapi
#  if WINAPI_FAMILY == WINAPI_FAMILY_PC_APP
#   define _LOCAL_FAMILY_OVERRIDE_iphlpapi 1
#  else
#   define _LOCAL_FAMILY_OVERRIDE_iphlpapi 2
#  endif
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_DESKTOP_APP
#  undef _INC_WINAPIFAMILY /* allow overriding the previous value */
# endif

# pragma warning(push)
# pragma warning(disable:4067)    /* newline for __has_include_next */
# if defined(__clang__) && __has_include_next(<iphlpapi.h>)
#  ifndef WINAPI_PARTITION_PHONE_RESTRICTED
#   define WINAPI_PARTITION_PHONE_RESTRICTED  WINAPI_PARTITION_APP
#  endif
#  include_next <iphlpapi.h>
# else /* no clang or no iphlpapi.h */
#  if (_WIN32_WINNT == 0x603)
#    include <../../../8.1/include/um/iphlpapi.h>
#  else
#   include <../um/iphlpapi.h>
#  endif
# endif
# pragma warning(pop)

# if defined(_LOCAL_FAMILY_OVERRIDE_iphlpapi)
   /* restore the previous family state */
#  ifndef _INC_WINAPIFAMILY
#   pragma message( "API family wasn't overriden in " __FILE__ )
#  endif
#  undef WINAPI_FAMILY
#  if _LOCAL_FAMILY_OVERRIDE_iphlpapi == 1
#   define WINAPI_FAMILY WINAPI_FAMILY_PC_APP
#  else 
#   define WINAPI_FAMILY WINAPI_FAMILY_PHONE_APP
#  endif
# endif

#endif /* _WINSTORE_IPHLPAPI_H */
