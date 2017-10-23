#ifndef _WINSTORE_D3D10SHADER_H
#define _WINSTORE_D3D10SHADER_H

#if defined(_WIN32_WINNT) && _WIN32_WINNT <= 0x603

# if defined(WINAPI_FAMILY) && WINAPI_FAMILY == WINAPI_FAMILY_PC_APP
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_DESKTOP_APP
#  ifdef _INC_WINAPIFAMILY
#   undef _INC_WINAPIFAMILY
#  endif
#  include <../um/d3d10shader.h>
   /* restore the previous family state */
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_PC_APP

# elif defined(WINAPI_FAMILY) && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_DESKTOP_APP
#  ifdef _INC_WINAPIFAMILY
#   undef _INC_WINAPIFAMILY
#  endif
#  include <../um/d3d10shader.h>
   /* restore the previous family state */
#  undef WINAPI_FAMILY
#  define WINAPI_FAMILY WINAPI_FAMILY_PHONE_APP

# else
#  include <../um/d3d10shader.h>

# endif
#else /* use the regular include as it is */

# pragma warning(push)
# pragma warning(disable:4067)    /* newline for __has_include_next */

# if defined(__clang__) && __has_include_next(<d3d10shader.h>)
#  ifndef WINAPI_PARTITION_PHONE_RESTRICTED
#   define WINAPI_PARTITION_PHONE_RESTRICTED  WINAPI_PARTITION_APP
#  endif
#  include_next <d3d10shader.h>
# else /* no clang or no d3d10shader.h */

#  include <../um/d3d10shader.h>

# endif

#endif

#pragma warning(pop)

#endif /* _WINSTORE_D3D10SHADER_H */
