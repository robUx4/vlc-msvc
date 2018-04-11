#ifndef MSCVER_STDALIGN_H__
#define MSCVER_STDALIGN_H__

#ifndef __cplusplus

#pragma warning(push)
#pragma warning(disable:4067)    /* newline for __has_include_next */

#if defined(__clang__) && __has_include_next(<stdalign.h>)
#  include_next <stdalign.h>
#else
# define memory_order_relaxed   0
# define alignof(x) __alignof(x)
#endif

#pragma warning(pop)

#endif /* __cplusplus */

#endif /* MSCVER_STDALIGN_H__ */
