#ifndef WINSTORECOMPAT_H__
# define WINSTORECOMPAT_H__

#if _MSC_VER < 1900
#pragma warning(push)
#pragma warning(disable:4255)    /* no function prototype given */
#endif /* _MSV_VER */
#include <Windows.h>
#if _MSC_VER < 1900
#pragma warning(pop)
#endif /* _MSV_VER */

#if defined(__clang__)
#define __PRFCHWINTRIN_H /* workaround for an SDK incompatibility when building AMD64 */
#endif /*__clang__ */

/* not detected properly by autoconf due to early forced include */
#define HAVE_WCSCPY 1
#define HAVE_WCSLEN 1
#define HAVE_STRERROR 1

/* defines implied by the C runtime */
#if _MSC_VER >= 1900
#define _TIMESPEC_DEFINED
#endif

#ifdef __cplusplus
extern "C" {
#endif

#if _MSC_VER < 1900 || defined(__clang__)
static __forceinline int getpid(void)
{
    return GetCurrentProcessId();
}
typedef int pid_t;
#endif /* _MSC_VER */

#define getenv(x) NULL
#define putenv(x) NULL

#define CreateEvent CreateEventW

#if _WIN32_WINNT < 0x0A00
static __forceinline HANDLE CreateEventW(LPSECURITY_ATTRIBUTES lpEventAttributes, BOOL bManualReset, BOOL bInitialState, LPCWSTR lpName)
{
    int flags = 0;
    if (bManualReset)
        flags |= CREATE_EVENT_MANUAL_RESET;
    if (bInitialState)
        flags |= CREATE_EVENT_INITIAL_SET;
    return CreateEventExW(lpEventAttributes, lpName, flags, EVENT_ALL_ACCESS);
}

static __forceinline HANDLE CreateSemaphoreW(LPSECURITY_ATTRIBUTES lpSemaphoreAttributes,
                               LONG lInitialCount,
                               LONG lMaximumCount,
                               LPCWSTR lpName)
{
    return CreateSemaphoreExW(lpSemaphoreAttributes, lInitialCount, lMaximumCount, lpName, 0, EVENT_ALL_ACCESS);
}
#endif /* _WIN32_WINNT */

static __forceinline DWORD WINAPI GetFileSize(HANDLE hFile, LPDWORD lpFileSizeHigh)
{
    DWORD dwRet = 0;
    FILE_STANDARD_INFO fStdInfo;

    if (GetFileInformationByHandleEx(hFile, FileStandardInfo, (LPVOID)&fStdInfo, sizeof(FILE_STANDARD_INFO)))
    {
        dwRet = fStdInfo.EndOfFile.LowPart;
        if (lpFileSizeHigh != NULL)
            *lpFileSizeHigh = fStdInfo.EndOfFile.HighPart;
    }
    else
        dwRet = INVALID_FILE_SIZE;

    return dwRet;
}

#if _MSC_VER < 1900
/*
 This is not really a proper implementation, but it is needed by gcc/libstdc++
 */
static __forceinline HANDLE CreateSemaphoreA(LPSECURITY_ATTRIBUTES lpSemaphoreAttributes,
                               LONG lInitialCount,
                               LONG lMaximumCount,
                               LPCSTR lpName)
{
    LPCWSTR lpwName;
    if( lpName == NULL )
        lpwName = NULL;
    else
    {
        SetLastError( ERROR_BAD_ARGUMENTS );
        return NULL; 
    }
    return CreateSemaphoreW(lpSemaphoreAttributes, lInitialCount, lMaximumCount, lpwName );
}
#endif
#define CreateSemaphore    CreateSemaphoreW

#define GetModuleFileName  GetModuleFileNameW
#define GetModuleFileNameA(h,f,s)                          (0)
#define GetModuleFileNameW(h,f,s)                          (0)
#define GetModuleHandleA(x)                             (NULL)
#define GetModuleHandleW(x)                             (NULL)

static __forceinline HANDLE CreateFileW(LPCTSTR lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode,
    LPSECURITY_ATTRIBUTES lpSecurityAttributes, DWORD dwCreationDisposition,
    DWORD dwFlagsAndAttributes, HANDLE hTemplateFile)
{
    CREATEFILE2_EXTENDED_PARAMETERS createExParams;
    createExParams.dwSize               = sizeof(CREATEFILE2_EXTENDED_PARAMETERS);
    createExParams.dwFileAttributes     = dwFlagsAndAttributes & 0xFFFF;
    createExParams.dwFileFlags          = dwFlagsAndAttributes & 0xFFF00000;
    createExParams.dwSecurityQosFlags   = dwFlagsAndAttributes & 0x000F00000;
    createExParams.lpSecurityAttributes = lpSecurityAttributes;
    createExParams.hTemplateFile        = hTemplateFile;
    return CreateFile2(lpFileName, dwDesiredAccess, dwShareMode, dwCreationDisposition, &createExParams);
}
#define CreateFile                      CreateFileW
#define CreateFileA(f,a,sh,sc,cr,fl,h)  (INVALID_HANDLE_VALUE)

#if _WIN32_WINNT < 0x0A00
static __forceinline DWORD GetFileType(HANDLE hFile)
{
    if (hFile != INVALID_HANDLE_VALUE)
        return FILE_TYPE_DISK;
    return FILE_TYPE_UNKNOWN;
}

static __forceinline HANDLE CreateMutexW(LPSECURITY_ATTRIBUTES lpMutexAttributes, BOOL bInitialOwner, LPCWSTR lpName)
{
    int flags = 0;
    if (bInitialOwner)
        flags |= CREATE_MUTEX_INITIAL_OWNER;
    return CreateMutexExW(lpMutexAttributes, lpName, flags, EVENT_ALL_ACCESS);
}
#endif /* _WIN32_WINNT */
#define CreateMutex CreateMutexW

static __forceinline UINT GetACP(void)
{
    DWORD acp;
    if (GetLocaleInfoEx(LOCALE_NAME_USER_DEFAULT, LOCALE_RETURN_NUMBER | LOCALE_IDEFAULTANSICODEPAGE, (LPWSTR) &acp, sizeof(acp) / sizeof(WCHAR)))
        return acp;
    return CP_UTF8; /* utf-8 */
}

static __forceinline DWORD GetFileAttributesW(LPCWSTR lpFileName)
{
    WIN32_FILE_ATTRIBUTE_DATA fileInformation;
    if( GetFileAttributesExW(lpFileName, GetFileExInfoStandard, &fileInformation) != 0)
        return fileInformation.dwFileAttributes;
    else
        return INVALID_FILE_ATTRIBUTES;
}

static __forceinline HMODULE LoadLibraryW(LPCWSTR lpFileName)
{
    return LoadPackagedLibrary(lpFileName, 0);
}

#define LoadLibrary LoadLibraryW

static __forceinline BOOL CreateTimerQueueTimer (PHANDLE phNewTimer, HANDLE TimerQueue, WAITORTIMERCALLBACK Callback, PVOID Parameter, DWORD DueTime, DWORD Period, ULONG Flags)
{
    UNREFERENCED_PARAMETER(phNewTimer);
    UNREFERENCED_PARAMETER(TimerQueue);
    UNREFERENCED_PARAMETER(Callback);
    UNREFERENCED_PARAMETER(Parameter);
    UNREFERENCED_PARAMETER(DueTime);
    UNREFERENCED_PARAMETER(Period);
    UNREFERENCED_PARAMETER(Flags);
    SetLastError(ERROR_ACCESS_DENIED);
    return 0;
}

static __forceinline BOOL DeleteTimerQueueTimer (HANDLE TimerQueue, HANDLE Timer, HANDLE CompletionEvent)
{
    UNREFERENCED_PARAMETER(TimerQueue);
    UNREFERENCED_PARAMETER(Timer);
    UNREFERENCED_PARAMETER(CompletionEvent);
    SetLastError(ERROR_ACCESS_DENIED);
    return 0;
}

#if _WIN32_WINNT < 0x0A00
static __forceinline void InitializeCriticalSection(LPCRITICAL_SECTION lpCriticalSection)
{
    int flags = 0;
#ifdef NDEBUG
    flags = CRITICAL_SECTION_NO_DEBUG_INFO;
#endif
    InitializeCriticalSectionEx(lpCriticalSection, 0, flags);
}
#endif /* _WIN32_WINNT */

#ifndef NTDDI_WIN10_RS1 /* now available in RS1 */
static __forceinline BOOL SetFilePointer(HANDLE hFile, LONG lDistanceToMove, PLONG lpDistanceToMoveHigh, DWORD dwMoveMethod)
{
    LARGE_INTEGER  liDistanceToMove, newFilePointer;
    liDistanceToMove.QuadPart = lDistanceToMove;
    BOOL res = SetFilePointerEx(hFile, liDistanceToMove, &newFilePointer, dwMoveMethod);
    if (lpDistanceToMoveHigh != NULL)
        *lpDistanceToMoveHigh = (LONG) newFilePointer.QuadPart;
    return res;
}
#endif /* NTDDI_WIN10_RS1 */

#if _MSC_VER < 1900
#define _beginthreadex CreateThread
#define _endthreadex ExitThread

/*
static __forceinline BeginThreadEx(
   void *security,
   unsigned stack_size,
   unsigned ( __stdcall *start_address )( void * ),
   void *arglist,
   unsigned initflag,
   unsigned *thrdaddr 
) {
    CreateThread(
  security,
  stack_size,
  start_address,
  _In_opt_   LPVOID lpParameter,
  _In_       DWORD dwCreationFlags,
  _Out_opt_  LPDWORD lpThreadId
);
}*/
#endif

#if _MSC_VER < 1900
static __forceinline wchar_t* _wgetcwd(wchar_t *buffer, int maxlen)
{
    (void)buffer;
    (void)maxlen;
    return NULL;
}

static __forceinline char* _getcwd(char *buffer, int maxlen)
{
    (void)buffer;
    (void)maxlen;
    return NULL;
}
#endif
#define getcwd _getcwd

#if _WIN32_WINNT < 0x0A00
static __forceinline void GetSystemInfo(LPSYSTEM_INFO lpSystemInfo)
{
    GetNativeSystemInfo(lpSystemInfo);
}

static __forceinline DWORD WaitForSingleObject(HANDLE hHandle, DWORD dwMilliseconds)
{
    return WaitForSingleObjectEx(hHandle, dwMilliseconds, FALSE);
}

static __forceinline DWORD WaitForMultipleObjects(WORD nCount, const HANDLE *lpHandles, BOOL bWaitAll, DWORD dwMilliseconds)
{
    return WaitForMultipleObjectsEx(nCount, lpHandles, bWaitAll, dwMilliseconds, FALSE);
}

#define CreateFileMapping(hf, lpa, flp, high, low, name)  CreateFileMappingFromApp(hf, lpa, flp, (((ULONG64) high) << 32) + (ULONG64) low, name)
#define GetTempPath(x)    NULL
#define OpenProcess(dwa, bih, dwp)   NULL

#endif /* _WIN32_WINNT */

#define GetFileAttributes GetFileAttributesW
#define GetTickCount      GetTickCount64

static __forceinline void *LocalAlloc(UINT uFlags, SIZE_T uBytes)
{
    DWORD dFlags = 0;
    if (uFlags & LMEM_ZEROINIT)
        dFlags |= HEAP_ZERO_MEMORY;
    return HeapAlloc(GetProcessHeap(), dFlags, uBytes);
}

static __forceinline void *LocalFree(void *hMem)
{
    if (HeapFree(GetProcessHeap(), 0, hMem))
        return NULL;
    return hMem;
}

// End of function declarations, now let's just hardcode all the values...
#define GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS 0x04;

#define SHGFP_TYPE_CURRENT 0x00
#ifndef TLS_OUT_OF_INDEXES
# define TLS_OUT_OF_INDEXES 0xFFFFFFFF
#endif

// CSIDL
#define CSIDL_APPDATA 0x001A
#define CSIDL_PERSONAL 0x0005
#define CSIDL_MYMUSIC 0x000d
#define CSIDL_MYVIDEO 0x000e
#define CSIDL_MYPICTURES 0x0027
#define CSIDL_FLAG_CREATE 0x8000
#define CSIDL_COMMON_APPDATA 0x0023

#ifdef __cplusplus
} //extern "C"
#endif

#endif //WINSTORECOMPAT_H__
