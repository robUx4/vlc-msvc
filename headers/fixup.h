#ifdef _MSC_VER /* help visual studio compile vlc headers */

#define WIN32_LEAN_AND_MEAN

#ifndef WIN32
#define WIN32
#endif /* WIN32 */

#if _MSC_VER >= 1900
#define __STDC_VERSION__ 199901L
#endif

# if !defined(snprintf) && _MSC_VER < 1900
#  define snprintf _snprintf
# endif
# ifndef snwprintf
#  define snwprintf _snwprintf
# endif
# ifndef __cplusplus
#  define inline __inline
# endif
# if _MSC_VER < 1900
# define strdup _strdup
#endif
typedef signed long int ssize_t;
typedef signed long int off_t;
typedef unsigned int mode_t;
# define N_(x) x
# define _(x) x

# define alloca _alloca
# define bzero(a,b) memset( (a), 0, (b) )
# define bcopy memcpy
# define bcmp memcmp

//# ifndef restrict
//#  define restrict __restrict
//# endif

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

# define strcasecmp _stricmp
# define strncasecmp _strnicmp
# if !defined(vsnprintf) && _MSC_VER < 1900
#  define vsnprintf _vsnprintf
# endif

#if _MSC_VER < 1900
#define HAVE_STRCASECMP
#define HAVE_STRNLEN
#define HAVE_REWIND
#else
#define HAVE_STRNLEN
#define HAVE_REWIND
#endif

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

#ifndef _USE_MATH_DEFINES
#define _USE_MATH_DEFINES
#endif /* _USE_MATH_DEFINES */

#define PATH_MAX MAX_PATH

#include <winapifamily.h>

#if (WINAPI_FAMILY == WINAPI_FAMILY_PC_APP || WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
#include "winstorecompat.h"
#endif /* WINAPI_FAMILY_PC_APP || WINAPI_FAMILY_PHONE_APP */

#endif
