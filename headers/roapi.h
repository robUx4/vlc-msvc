#ifndef _WINSTORE_ROAPI_H
#define _WINSTORE_ROAPI_H

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

# pragma warning(push)
# pragma warning(disable:4067)    /* newline for __has_include_next */
# if defined(__clang__) && __has_include_next(<roapi.h>)
#  include_next <roapi.h>
# else /* no clang or no roapi.h */
#  if (_WIN32_WINNT == 0x603)
/* not compatible #   include <../../../8.1/include/winrt/roapi.h> */
#  else
#   include <../winrt/roapi.h>
#  endif
# endif
# pragma warning(pop)

DECLSPEC_IMPORT HRESULT WINAPI RoGetActivationFactory(HSTRING activatableClassId, REFIID iid, void **factory);


#endif /* _WINSTORE_ROAPI_H */
