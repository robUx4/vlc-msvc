#ifndef _MSVC_SDTNORETURN_H
#define _MSVC_SDTNORETURN_H

#if defined(__clang__)
#error Clang has its own stdreturn.h, use it!
#endif

#include <process.h>
#define noreturn __declspec(noreturn)

#endif /* _MSVC_SDTNORETURN_H */
