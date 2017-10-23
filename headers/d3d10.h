#ifndef _WINSTORE_D3D10_H
#define _WINSTORE_D3D10_H

#if defined(_WIN32_WINNT) && _WIN32_WINNT <= 0x603

# if defined(WINAPI_FAMILY) && WINAPI_FAMILY == WINAPI_FAMILY_PC_APP
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_DESKTOP_APP
#  ifdef _INC_WINAPIFAMILY
#   pragma message( "desktop API hidden in " __FILE__ )
#   undef _INC_WINAPIFAMILY
#  endif

#  include <../um/d3d10.h>
   /* restore the previous family state */
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_PC_APP
#  ifndef _INC_WINAPIFAMILY
#   pragma message( "API family wasn't overriden in " __FILE__ )
#  endif

# elif defined(WINAPI_FAMILY) && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_DESKTOP_APP
#  ifdef _INC_WINAPIFAMILY
#   pragma message( "desktop API hidden in " __FILE__ )
#   undef _INC_WINAPIFAMILY
#  endif

#  include <../um/d3d10.h>
   /* restore the previous family state */
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_PHONE_APP
#  ifndef _INC_WINAPIFAMILY
#   pragma message( "API family wasn't overriden in " __FILE__ )
#  endif

# else
#  include <../um/d3d10.h>

# endif
#else /* use the regular include as it is */

# pragma warning(push)
# pragma warning(disable:4067)    /* newline for __has_include_next */

# if defined(__clang__) && __has_include_next(<d3d10.h>)
#  ifndef WINAPI_PARTITION_PHONE_RESTRICTED
#   define WINAPI_PARTITION_PHONE_RESTRICTED  WINAPI_PARTITION_APP
#  endif
#  include_next <d3d10.h>
# else /* no clang or no d3d10.h */

#  include <../um/d3d10.h>

# endif

#endif

#pragma warning(pop)

#endif /* _WINSTORE_D3D10_H */
