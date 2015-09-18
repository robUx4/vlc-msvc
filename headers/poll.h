#ifndef _WINSTORE_POLL_H
#define _WINSTORE_POLL_H

#include <winsock2.h>
#include <ws2tcpip.h>
#define net_errno (WSAGetLastError())

typedef ULONG nfds_t;

__forceinline int poll(struct pollfd *fds, nfds_t nfds, int timeout)
{
    DWORD to = (timeout >= 0) ? (DWORD)timeout : INFINITE;

    if (nfds == 0)
    {    /* WSAWaitForMultipleEvents() does not allow zero events */
        if (SleepEx(to, TRUE))
        {
            errno = EINTR;
            return -1;
        }
        return 0;
    }

    WSAEVENT *evts = calloc(nfds, sizeof (WSAEVENT));
    if (evts == NULL)
        return -1; /* ENOMEM */

    DWORD ret = WSA_WAIT_FAILED;
    for (unsigned i = 0; i < nfds; i++)
    {
        SOCKET fd = fds[i].fd;
        long mask = FD_CLOSE;
        fd_set rdset, wrset, exset;

        FD_ZERO(&rdset);
        FD_ZERO(&wrset);
        FD_ZERO(&exset);
        FD_SET(fd, &exset);

        if (fds[i].events & POLLRDNORM)
        {
            mask |= FD_READ | FD_ACCEPT;
            FD_SET(fd, &rdset);
        }
        if (fds[i].events & POLLWRNORM)
        {
            mask |= FD_WRITE | FD_CONNECT;
            FD_SET(fd, &wrset);
        }
        if (fds[i].events & POLLPRI)
            mask |= FD_OOB;

        fds[i].revents = 0;

        evts[i] = WSACreateEvent();
        if (evts[i] == WSA_INVALID_EVENT)
        {
            while (i > 0)
                WSACloseEvent(evts[--i]);
            errno = ENOMEM;
            return -1;
        }

        if (WSAEventSelect(fds[i].fd, evts[i], mask)
         && WSAGetLastError() == WSAENOTSOCK)
            fds[i].revents |= POLLNVAL;

        struct timeval tv = { 0, 0 };
        /* By its horrible design, WSAEnumNetworkEvents() only enumerates
         * events that were not already signaled (i.e. it is edge-triggered).
         * WSAPoll() would be better in this respect, but worse in others.
         * So use WSAEnumNetworkEvents() after manually checking for pending
         * events. */
        if (select(0, &rdset, &wrset, &exset, &tv) > 0)
        {
            if (FD_ISSET(fd, &rdset))
                fds[i].revents |= fds[i].events & POLLRDNORM;
            if (FD_ISSET(fd, &wrset))
                fds[i].revents |= fds[i].events & POLLWRNORM;
            if (FD_ISSET(fd, &exset))
                /* To add pain to injury, POLLERR and POLLPRI cannot be
                 * distinguished here. */
                fds[i].revents |= POLLERR | (fds[i].events & POLLPRI);
        }

        if (fds[i].revents != 0 && ret == WSA_WAIT_FAILED)
            ret = WSA_WAIT_EVENT_0 + i;
    }

    if (ret == WSA_WAIT_FAILED)
        ret = WSAWaitForMultipleEvents(nfds, evts, FALSE, to, TRUE);

    unsigned count = 0;
    for (unsigned i = 0; i < nfds; i++)
    {
        WSANETWORKEVENTS ne;

        if (WSAEnumNetworkEvents(fds[i].fd, evts[i], &ne))
            memset(&ne, 0, sizeof (ne));
        WSAEventSelect(fds[i].fd, evts[i], 0);
        WSACloseEvent(evts[i]);

        if (ne.lNetworkEvents & FD_CONNECT)
        {
            fds[i].revents |= POLLWRNORM;
            if (ne.iErrorCode[FD_CONNECT_BIT] != 0)
                fds[i].revents |= POLLERR;
        }
        if (ne.lNetworkEvents & FD_CLOSE)
        {
            fds[i].revents |= (fds[i].events & POLLRDNORM) | POLLHUP;
            if (ne.iErrorCode[FD_CLOSE_BIT] != 0)
                fds[i].revents |= POLLERR;
        }
        if (ne.lNetworkEvents & FD_ACCEPT)
        {
            fds[i].revents |= POLLRDNORM;
            if (ne.iErrorCode[FD_ACCEPT_BIT] != 0)
                fds[i].revents |= POLLERR;
        }
        if (ne.lNetworkEvents & FD_OOB)
        {
            fds[i].revents |= POLLPRI;
            if (ne.iErrorCode[FD_OOB_BIT] != 0)
                fds[i].revents |= POLLERR;
        }
        if (ne.lNetworkEvents & FD_READ)
        {
            fds[i].revents |= POLLRDNORM;
            if (ne.iErrorCode[FD_READ_BIT] != 0)
                fds[i].revents |= POLLERR;
        }
        if (ne.lNetworkEvents & FD_WRITE)
        {
            fds[i].revents |= POLLWRNORM;
            if (ne.iErrorCode[FD_WRITE_BIT] != 0)
                fds[i].revents |= POLLERR;
        }
        count += fds[i].revents != 0;
    }

    if (count == 0 && ret == WSA_WAIT_IO_COMPLETION)
    {
        errno = EINTR;
        return -1;
    }
    return count;
}

#endif /* _WINSTORE_POLL_H */
