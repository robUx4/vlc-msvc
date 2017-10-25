#ifndef _WINSTORE_WINSOCK2_H
#define _WINSTORE_WINSOCK2_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

# if defined(WINAPI_FAMILY) && (WINAPI_FAMILY == WINAPI_FAMILY_PC_APP || WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
#  undef _LOCAL_FAMILY_OVERRIDE_winsock2
#  if WINAPI_FAMILY == WINAPI_FAMILY_PC_APP
#   define _LOCAL_FAMILY_OVERRIDE_winsock2 1
#  else
#   define _LOCAL_FAMILY_OVERRIDE_winsock2 2
#  endif
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_DESKTOP_APP
#  undef _INC_WINAPIFAMILY /* allow overriding the previous value */
# endif

# pragma warning(push)
# pragma warning(disable:4067)    /* newline for __has_include_next */
# if defined(__clang__) && __has_include_next(<winsock2.h>)
#  ifndef WINAPI_PARTITION_PHONE_RESTRICTED
#   define WINAPI_PARTITION_PHONE_RESTRICTED  WINAPI_PARTITION_APP
#  endif
#  include_next <winsock2.h>
# else /* no clang or no winsock2.h */
#  include <../um/winsock2.h>
# endif
# pragma warning(pop)

# if defined(_LOCAL_FAMILY_OVERRIDE_winsock2)
   /* restore the previous family state */
#  ifndef _INC_WINAPIFAMILY
#   pragma message( "API family wasn't overriden in " __FILE__ )
#  endif
#  undef WINAPI_FAMILY
#  if _LOCAL_FAMILY_OVERRIDE_winsock2 == 1
#   define WINAPI_FAMILY WINAPI_FAMILY_PC_APP
#  else 
#   define WINAPI_FAMILY WINAPI_FAMILY_PHONE_APP
#  endif
# endif

#endif /* _WINSTORE_WINSOCK2_H */
