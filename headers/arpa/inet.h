#ifndef _WINSTORE_ARPA_INET_H
#define _WINSTORE_ARPA_INET_H

#include <winsock2.h>
#include <ws2tcpip.h>
#define net_errno (WSAGetLastError())

#define inet_pton(f,s,d) inet_ptonW(f,s,d)

__forceinline int inet_ptonW( int i_family, const char *psz_src, void *dst )
{
    int len = MultiByteToWideChar( CP_UTF8, 0, psz_src, -1, NULL, 0 );
    if( len == 0 )
        return 0;

    wchar_t *pswz_src = (wchar_t *) alloca( len * sizeof( wchar_t ) );
    if( pswz_src == NULL )
        return -1;

    MultiByteToWideChar( CP_UTF8, 0, psz_src, -1, pswz_src, len );

    return InetPtonW( i_family, pswz_src, dst );
}

__forceinline const char *inet_ntop( int i_family, void *src, char *psz_dst, size_t i_size )
{
    if( psz_dst == NULL )
        return NULL;
    wchar_t *pszw_dst = alloca( i_size );
    wchar_t *pswz_res = InetNtopW( i_family, src, pszw_dst, i_size );
    if( pswz_res == NULL )
        return NULL;

    WideCharToMultiByte( CP_UTF8, 0, pswz_res, -1, psz_dst, i_size, NULL, NULL );
    return psz_dst;
}

#endif /* _WINSTORE_ARPA_INET_H */