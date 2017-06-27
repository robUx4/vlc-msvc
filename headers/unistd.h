#ifndef UNISTD_H__
# define UNISTD_H__

#pragma warning(push)
#pragma warning(disable:4067)    /* newline for __has_include_next */

#if defined(__clang__) && __has_include_next(<unistd.h>)
# include_next <unistd.h>
#else
# include <io.h>
#endif

#pragma warning(pop)

#include <direct.h>

#endif /* UNISTD_H__ */
