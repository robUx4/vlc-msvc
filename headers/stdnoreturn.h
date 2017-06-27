#ifndef MSCVER_STDNORETURN_H__
#define MSCVER_STDNORETURN_H__

#ifndef __cplusplus

#pragma warning(push)
#pragma warning(disable:4067)    /* newline for __has_include_next */

#if defined(__clang__) && __has_include_next(<stdnoreturn.h>)
#  include_next <stdnoreturn.h>
#else
# include <process.h>
# define noreturn __declspec(noreturn)
#endif

#pragma warning(pop)

#endif /* __cplusplus */

#endif /* MSCVER_STDNORETURN_H__ */
