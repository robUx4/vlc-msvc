#ifdef _MSC_VER /* help visual studio compile vlc headers */

#include <xkeycheck.h>

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif /* WIN32_LEAN_AND_MEAN */

#ifndef NOUSER
#define NOUSER /* avoid bogus pragma push/pop */
typedef struct tagMSG MSG, *LPMSG;
#endif /* NOUSER */

#ifndef WIN32
#define WIN32
#endif /* WIN32 */

#if _MSC_VER >= 1900 && !defined(__STDC_VERSION__)
#define __STDC_VERSION__ 199901L
#endif

# if !defined(snprintf) && _MSC_VER < 1900
#  define HAVE_SNPRINTF /* bogus autoconf detection using a define */
#  define snprintf _snprintf
# endif
# ifndef snwprintf
#  define HAVE_SNWPRINTF /* bogus autoconf detection using a define */
#  define snwprintf _snwprintf
# endif
# if !defined(strdup) && _MSC_VER < 1900
//#  define HAVE_STRDUP /* bogus autoconf detection using a define */
# define strdup _strdup
#endif
#define ssize_t  SSIZE_T
typedef signed long int off_t;
typedef unsigned int mode_t;
//# define N_(x) x
# define _(x) x

#if _MSC_VER < 1900
# ifndef __cplusplus
#  define inline __inline
# endif
#endif

# define alloca _alloca
# define bzero(a,b) memset( (a), 0, (b) )
# define bcopy memcpy
# define bcmp memcmp

//#ifndef __cplusplus
//# ifndef restrict
//#  define restrict __restrict
//# endif
//#endif

// Stats part

#define	_S_IFBLK	0x3000	/* Block: Is this ever set under w32? */

#define _S_IFMT 0xF000
#define _S_IFDIR 0x4000
#define _S_IFCHR 0x2000
#define _S_IFIFO 0x1000
#define _S_IFREG 0x8000
#define _S_IREAD 0x0100
#define _S_IWRITE 0x0080
#define _S_IEXEC 0x0040

#define S_IFMT _S_IFMT
#define S_IFDIR _S_IFDIR
#define S_IFCHR _S_IFCHR
#define S_IFREG _S_IFREG
#define S_IREAD _S_IREAD
#define S_IWRITE _S_IWRITE
#define S_IEXEC _S_IEXEC
#define	S_IFIFO		_S_IFIFO
#define	S_IFBLK		_S_IFBLK

#define	_S_IRWXU	(_S_IREAD | _S_IWRITE | _S_IEXEC)
#define	_S_IXUSR	_S_IEXEC
#define	_S_IWUSR	_S_IWRITE

#define	S_IRWXU		_S_IRWXU
#define	S_IXUSR		_S_IXUSR
#define	S_IWUSR		_S_IWUSR
#define	S_IRUSR		_S_IRUSR
#define	_S_IRUSR	_S_IREAD

# ifndef S_ISREG
#  define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
# endif

#ifndef S_ISDIR
# define S_ISDIR(mode)  (((mode) & S_IFMT) == S_IFDIR)
#endif

#define	S_ISFIFO(m)	(((m) & S_IFMT) == S_IFIFO)
#define	S_ISCHR(m)	(((m) & S_IFMT) == S_IFCHR)
#define	S_ISBLK(m)	(((m) & S_IFMT) == S_IFBLK)

#define __func__ __FUNCDNAME__

# if !defined(strcasecmp)
# define HAVE_STRCASECMP /* bogus autoconf detection using a define */
# define strcasecmp _stricmp
#endif
# if !defined(strncasecmp)
#  define HAVE_STRNCASECMP /* bogus autoconf detection using a define */
# define strncasecmp _strnicmp
#endif
# if !defined(vsnprintf) && !defined(__cplusplus) && _MSC_VER < 1900
#  define HAVE_VSNPRINTF /* bogus autoconf detection using a define */
#  define vsnprintf _vsnprintf
# endif

#define NOMINMAX

/* Values for the second argument to access.
   These may be OR'd together.  */
#ifndef R_OK
# define R_OK    4       /* Test for read permission.  */
#endif

#ifndef W_OK
# define W_OK    2       /* Test for write permission.  */
#endif

#ifndef F_OK
# define F_OK    0       /* Test for existence.  */
#endif

#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif /* _CRT_SECURE_NO_WARNINGS */

#ifndef _CRT_NONSTDC_NO_WARNINGS
#define _CRT_NONSTDC_NO_WARNINGS
#endif /* _CRT_NONSTDC_NO_WARNINGS */

#ifndef _USE_MATH_DEFINES
#define _USE_MATH_DEFINES
#endif /* _USE_MATH_DEFINES */

#ifndef UNICODE
#define UNICODE
#endif /* UNICODE */

#ifndef _UNICODE
#define _UNICODE
#endif /* _UNICODE */

#ifndef SSIZE_MAX
#ifdef _WIN64
#define SSIZE_MAX _I64_MAX
#else
#define SSIZE_MAX INT_MAX
#endif
#endif

#define PATH_MAX MAX_PATH

#if defined(__clang__)
# define STATIC_ASSERT_CONCAT_(a, b) a##b
# define STATIC_ASSERT_CONCAT(a, b) STATIC_ASSERT_CONCAT_(a, b)
# define _Static_assert(x, s) extern char STATIC_ASSERT_CONCAT(static_assert_, __LINE__)[sizeof(struct { unsigned:-!(x); })]
# define static_assert _Static_assert
#endif /* __clang__ */

#include <winapifamily.h>

#if (WINAPI_FAMILY == WINAPI_FAMILY_PC_APP || WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
#include "winstorecompat.h"
#endif /* WINAPI_FAMILY_PC_APP || WINAPI_FAMILY_PHONE_APP */

#if _MSC_VER < 1900
#pragma warning(disable:4201) /* nameless structs */
#endif /* _MSC_VER */

#endif
