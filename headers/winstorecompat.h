#ifndef WINSTORECOMPAT_H__
# define WINSTORECOMPAT_H__

#pragma warning(push)
#pragma warning(disable:4255)    /* no function prototype given */
#include <Windows.h>
//#include <stdio.h>
#pragma warning(pop)

/* not detected properly by autoconf due to early forced include */
#define HAVE_STRNLEN
#define HAVE_WCSCPY
#define HAVE_WCSLEN
#define HAVE_REWIND

#ifdef __cplusplus
extern "C" {
#endif

#if _MSC_VER < 1900
__forceinline int getpid(void)
{
    return GetCurrentProcessId();
}
#define HAVE_GETPID

__forceinline char *getenv(const char *name)
{
    UNREFERENCED_PARAMETER(name);
    return NULL;
}
#define HAVE_GETENV

__forceinline char *putenv(const char *name)
{
    UNREFERENCED_PARAMETER(name);
    return NULL;
}
#define HAVE_PUTENV
#endif

__forceinline HRESULT SHGetFolderPathW(HWND hwnd,int csidl,HANDLE hToken,DWORD dwFlags,LPWSTR pszPath)
{
    UNREFERENCED_PARAMETER(hwnd);
    UNREFERENCED_PARAMETER(csidl);
    UNREFERENCED_PARAMETER(hToken);
    UNREFERENCED_PARAMETER(dwFlags);
    UNREFERENCED_PARAMETER(pszPath);
    return S_FALSE;
}

__forceinline HANDLE CreateEventW(LPSECURITY_ATTRIBUTES lpEventAttributes, BOOL bManualReset, BOOL bInitialState, LPCWSTR lpName)
{
    int flags = 0;
    if (bManualReset)
        flags |= CREATE_EVENT_MANUAL_RESET;
    if (bInitialState)
        flags |= CREATE_EVENT_INITIAL_SET;
    return CreateEventExW(lpEventAttributes, lpName, flags, EVENT_ALL_ACCESS);
}

#define CreateEvent CreateEventW

__forceinline HANDLE CreateSemaphoreW(LPSECURITY_ATTRIBUTES lpSemaphoreAttributes,
                               LONG lInitialCount,
                               LONG lMaximumCount,
                               LPCWSTR lpName)
{
    return CreateSemaphoreExW(lpSemaphoreAttributes, lInitialCount, lMaximumCount, lpName, 0, EVENT_ALL_ACCESS);
}

/*
 This is not really a proper implementation, but it is needed by gcc/libstdc++
 */
__forceinline HANDLE CreateSemaphoreA(LPSECURITY_ATTRIBUTES lpSemaphoreAttributes,
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

#define CreateSemaphore CreateSemaphoreW

#if 0
__forceinline HMODULE GetModuleHandleA(LPCSTR lpModuleName)
{
    wchar_t msg[512];

    _snwprintf_s(msg, 512, _TRUNCATE, L"GetModuleHandleA (%S) call suppressed\n", lpModuleName);

    OutputDebugStringW(msg);

    return NULL;
}

__forceinline HMODULE GetModuleHandleW(LPCWSTR lpModuleName)
{
    wchar_t msg[512];

    _snwprintf_s(msg, 512, _TRUNCATE, L"GetModuleHandleW (%ws) call suppressed\n", lpModuleName);

    OutputDebugStringW(msg);

    return NULL;
}

__forceinline DWORD GetModuleFileNameA(HMODULE hModule, LPCSTR lpFilename, DWORD nSize)
{
    wchar_t msg[512];
    UNREFERENCED_PARAMETER(hModule);
    UNREFERENCED_PARAMETER(nSize);

    _snwprintf_s(msg, 512, _TRUNCATE, L"GetModuleFileNameW (%S) call suppressed\n", lpFilename);

    OutputDebugStringW(msg);

    return 0;
}

__forceinline DWORD GetModuleFileNameW(HMODULE hModule, LPTSTR lpFilename, DWORD nSize)
{
    wchar_t msg[512];
    UNREFERENCED_PARAMETER(hModule);
    UNREFERENCED_PARAMETER(nSize);

    _snwprintf_s(msg, 512, _TRUNCATE, L"GetModuleFileNameW (%ws) call suppressed\n", lpFilename);

    OutputDebugStringW(msg);

    return 0;
}
#endif

__forceinline HANDLE CreateMutexW(LPSECURITY_ATTRIBUTES lpMutexAttributes, BOOL bInitialOwner, LPCWSTR lpName)
{
    int flags = 0;
    if (bInitialOwner)
        flags |= CREATE_MUTEX_INITIAL_OWNER;
    return CreateMutexExW(lpMutexAttributes, lpName, flags, EVENT_ALL_ACCESS);
}
#define CreateMutex CreateMutexW

__forceinline UINT GetACP(void)
{
    return CP_UTF8; /* utf-8 */
}

__forceinline DWORD GetFileAttributesW(LPCWSTR lpFileName)
{
    WIN32_FILE_ATTRIBUTE_DATA fileInformation;
    if( GetFileAttributesExW(lpFileName, GetFileExInfoStandard, &fileInformation) != 0)
        return fileInformation.dwFileAttributes;
    else
        return INVALID_FILE_ATTRIBUTES;
}

__forceinline HMODULE LoadLibraryW(LPCWSTR lpFileName)
{
    return LoadPackagedLibrary(lpFileName, 0);
}

#define LoadLibrary LoadLibraryW

__forceinline BOOL CreateTimerQueueTimer (PHANDLE phNewTimer, HANDLE TimerQueue, WAITORTIMERCALLBACK Callback, PVOID Parameter, DWORD DueTime, DWORD Period, ULONG Flags)
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

__forceinline BOOL DeleteTimerQueueTimer (HANDLE TimerQueue, HANDLE Timer, HANDLE CompletionEvent)
{
    UNREFERENCED_PARAMETER(TimerQueue);
    UNREFERENCED_PARAMETER(Timer);
    UNREFERENCED_PARAMETER(CompletionEvent);
    SetLastError(ERROR_ACCESS_DENIED);
    return 0;
}

__forceinline void InitializeCriticalSection(LPCRITICAL_SECTION lpCriticalSection)
{
    int flags = 0;
    /* flags = CRITICAL_SECTION_NO_DEBUG_INFO */
    InitializeCriticalSectionEx(lpCriticalSection, 0, flags);
}

#if _MSC_VER < 1900
#define _beginthreadex CreateThread
#define _endthreadex ExitThread

/*
__forceinline BeginThreadEx(
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

__forceinline wchar_t* _wgetcwd(wchar_t *buffer, int maxlen)
{
    (void)buffer;
    (void)maxlen;
    return NULL;
}

#define getcwd _getcwd

__forceinline char* _getcwd(char *buffer, int maxlen)
{
    (void)buffer;
    (void)maxlen;
    return NULL;
}

__forceinline DWORD WaitForSingleObject(HANDLE hHandle, DWORD dwMilliseconds)
{
    return WaitForSingleObjectEx(hHandle, dwMilliseconds, FALSE);
}

#define GetFileAttributes GetFileAttributesW

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
