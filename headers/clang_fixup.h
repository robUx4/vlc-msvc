#ifdef _MSC_VER /* help visual studio compile vlc headers */

#ifndef __clang__
#error Clang compatibility header
#endif

#include "mscver_fixup.h"

#define _CRT_DECLARE_NONSTDC_NAMES 1
#include <corecrt.h>

#ifdef __cplusplus
//#undef _NO_CRT_STDIO_INLINE
//#define _CRT_STDIO_INLINE
#define _NO_CRT_STDIO_INLINE
#define restrict
#define NOMINMAX
#else /* __cplusplus */
#if !__has_feature(c_static_assert)
#define STATIC_ASSERT_CONCAT_(a, b) a##b
#define STATIC_ASSERT_CONCAT(a, b) STATIC_ASSERT_CONCAT_(a, b)
#define _Static_assert(x, s) extern char STATIC_ASSERT_CONCAT(static_assert_, __LINE__)[sizeof(struct { unsigned:-!(x); })]
#endif
#define static_assert _Static_assert
#endif /* __cplusplus */

#define __declspec(noreturn)  __attribute__ ((noreturn))
#define DECLSPEC_NORETURN     __attribute__ ((noreturn))
#define DECLSPEC_SELECTANY    __attribute__((weak))
//#define DECLSPEC_ALIGN(x)     __attribute__((weak))

#if 0 /* TODO */

//#define stat _stat64
//#define fstat(fd,out) _fstat64(fd,out)
/* NO extern int stricmp(char const * s1, char const * s2); */
//extern void* fdopen(int fd, char const* fmt);
extern int read(int fd, void * buf, unsigned int bufcount);
extern int write(int fd, void const * buf, unsigned int bufcount);
extern int close(int fd);
extern int setmode(int fd, int mode);
extern int dup(int fd);
/* NO extern void swab(char * b1, char * b2, int size); */
extern long lseek(int fd, long offset, int origin);
//extern int fileno(void* FILE);
#endif /* TODO */

#endif /* _MSC_VER */
