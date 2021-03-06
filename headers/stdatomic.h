#ifndef MSCVER_STDATOMIC_H__
#define MSCVER_STDATOMIC_H__

#if !defined(__cplusplus) && defined(_MSC_VER)

#pragma warning(push)
#pragma warning(disable:4067)    /* newline for __has_include_next */

#if defined(__clang__) && __has_include_next(<stdatomic.h>)
#  include_next <stdatomic.h>
#else /* no stdatomic.h */

#include <windows.h>

#define  memory_order_relaxed 0

/* Define macros in order to dispatch to the correct function depending on the type.
   Several ranges are need because some operations are not implemented for all types. */
#  define atomic_type_dispatch_32_64(operation, object, ...) \
    (sizeof(*object) == 4 ? operation((LONG *)object, __VA_ARGS__) : \
    sizeof(*object) == 8 ? operation##64((LONGLONG *)object, __VA_ARGS__) : \
    (abort(), 0))

#  define atomic_exchange(object,desired) \
    atomic_type_dispatch_32_64(InterlockedExchange, object, desired)
#  define atomic_exchange_explicit(object,desired,order) \
    atomic_exchange(object,desired)

#  define atomic_load(object) \
    atomic_type_dispatch_32_64(InterlockedCompareExchange, object, 0, 0)
#  define atomic_load_explicit(object,order) \
    atomic_load(object)

#  define atomic_store(object,desired) \
    atomic_type_dispatch_32_64(InterlockedExchange, object, desired)
#  define atomic_store_explicit(object,desired,order) \
    atomic_store(object, desired)

static __forceinline bool msvc_std_exchange_32(LONG *obj, LONG *expected, LONG desired)
{
    LONG was = InterlockedCompareExchange(obj, desired, *expected);
    if (*expected == was)
        return true;
    *expected = was;
    return false;
}

static __forceinline bool msvc_std_exchange_64(LONGLONG *obj, LONGLONG *expected, LONGLONG desired)
{
    LONGLONG was = InterlockedCompareExchange64(obj, desired, *expected);
    if (*expected == was)
        return true;
    *expected = was;
    return false;
}

#  define atomic_compare_exchange_strong(object,expected,desired) \
    (sizeof(*object) == 4 ? msvc_std_exchange_32((LONG*)object,(LONG*)expected,desired) : \
     sizeof(*object) == 8 ? msvc_std_exchange_64((LONGLONG*)object,(LONGLONG*)expected,desired) : \
     (abort(), 0))

#  define atomic_compare_exchange_weak(object,expected,desired) \
    atomic_compare_exchange_strong(object, expected, desired)

#  define atomic_compare_exchange_weak_explicit(object,expected,desired,order1,order2) \
    atomic_compare_exchange_strong(object, expected, desired)

#  define atomic_fetch_add(object,operand) \
    atomic_type_dispatch_32_64(InterlockedExchangeAdd, object, operand)
#  define atomic_fetch_add_explicit(object,operand,order) \
    atomic_fetch_add(object, operand)

#  define atomic_fetch_sub(object,operand) \
    atomic_type_dispatch_32_64(InterlockedExchangeAdd, object, -(LONGLONG)operand)

#  define atomic_fetch_or(object,operand) \
    atomic_type_dispatch_32_64(InterlockedOr, object, operand)
#  define atomic_fetch_or_explicit(object,operand,order) \
    atomic_fetch_or(object, operand)

#  define atomic_fetch_and(object,operand) \
    atomic_type_dispatch_32_64(InterlockedAnd, object, operand)
#  define atomic_fetch_and_explicit(object,operand,order) \
    atomic_fetch_and(object, operand)

/* atomic types */
/* Some atomic operations of the Interlocked API are only
   available for desktop apps. Thus we define the atomic types to
   be at least 32 bits wide. */
#if 1
#define ATOMIC_ALIGN32 __declspec(align(32))
#define ATOMIC_ALIGN64 __declspec(align(64))
#else
#define ATOMIC_ALIGN32
#define ATOMIC_ALIGN64
#endif

typedef ATOMIC_ALIGN32  LONG  atomic_flag;
typedef ATOMIC_ALIGN32  LONG  atomic_bool;
typedef ATOMIC_ALIGN32  LONG  atomic_char;
typedef ATOMIC_ALIGN32  LONG  atomic_schar;
typedef ATOMIC_ALIGN32  ULONG atomic_uchar;
typedef ATOMIC_ALIGN32  LONG  atomic_short;
typedef ATOMIC_ALIGN32  ULONG atomic_ushort;

typedef ATOMIC_ALIGN32  LONG       atomic_int;
typedef ATOMIC_ALIGN32  ULONG      atomic_uint;
#if defined(_M_X64) || defined(__amd64__)
typedef ATOMIC_ALIGN64  LONGLONG  atomic_uintptr_t;
#else
typedef ATOMIC_ALIGN32  LONG      atomic_uintptr_t;
#endif
typedef ATOMIC_ALIGN32  ULONG    atomic_ulong;
typedef ATOMIC_ALIGN64  LONGLONG atomic_llong;

typedef ATOMIC_ALIGN32  ULONG atomic_uint_fast32_t;
typedef ATOMIC_ALIGN32  ULONG atomic_uint_least32_t;

#  define ATOMIC_VAR_INIT(value) (value)

#  define atomic_init(obj, value) \
    do { *(obj) = (value); } while(0)
    
#endif /* no stdatomic.h */

#pragma warning(pop)

#endif /* __cplusplus */

#endif /* MSCVER_STDATOMIC_H__ */
