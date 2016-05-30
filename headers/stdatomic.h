#ifndef __cplusplus

# include <windows.h>

/* Define macros in order to dispatch to the correct function depending on the type.
   Several ranges are need because some operations are not implemented for all types. */
#  define atomic_type_dispatch_32_64(operation, object, ...) \
    (sizeof(*object) == 4 ? operation((LONG *)object, __VA_ARGS__) : \
    sizeof(*object) == 8 ? operation##64((LONGLONG *)object, __VA_ARGS__) : \
    (abort(), 0))

#  define atomic_type_dispatch_16_64(operation, object, ...) \
    (sizeof(*object) == 2 ? operation##16((short *)object, __VA_ARGS__) : \
    atomic_type_dispatch_32_64(operation, object, __VA_ARGS__))

#  define atomic_type_dispatch_8_64(operation, object, ...) \
    (sizeof(*object) == 1 ? operation##8((char *)object, __VA_ARGS__) : \
    atomic_type_dispatch_16_64(operation, object, __VA_ARGS__))

#  define atomic_exchange(object,desired) \
    atomic_type_dispatch_16_64(InterlockedExchange, object, desired)

#  define atomic_load(object) \
    atomic_type_dispatch_16_64(InterlockedCompareExchange, object, 0, 0)

#  define atomic_store(object,desired) \
    atomic_type_dispatch_16_64(InterlockedExchange, object, desired)
#  define atomic_store_explicit(object,desired,order) \
    atomic_store(object, desired)

#  define atomic_compare_exchange_strong(object,expected,desired) \
    atomic_type_dispatch_16_64(InterlockedCompareExchange, object, *expected, desired) == *expected
#  define atomic_compare_exchange_weak(object,expected,desired) \
    atomic_compare_exchange_strong(object, expected, desired)

#  define atomic_fetch_add(object,operand) \
    atomic_type_dispatch_32_64(InterlockedExchangeAdd, object, operand)

#  define atomic_fetch_sub(object,operand) \
    atomic_type_dispatch_32_64(InterlockedExchangeAdd, object, -(LONGLONG)operand)

#  define atomic_fetch_or(object,operand) \
    atomic_type_dispatch_8_64(InterlockedOr, object, operand)
#  define atomic_fetch_or_explicit(object,operand,order) \
    atomic_fetch_or(object, operand)

#  define atomic_fetch_and(object,operand) \
    atomic_type_dispatch_8_64(InterlockedAnd, object, operand)
#  define atomic_fetch_and_explicit(object,operand,order) \
    atomic_fetch_and(object, operand)

/* atomic types */
typedef          int       atomic_int;
typedef unsigned int       atomic_uint;
typedef          bool      atomic_bool;
typedef unsigned char      atomic_uchar;
typedef unsigned short     atomic_ushort;
typedef         uintptr_t atomic_uintptr_t;

typedef     uint_fast32_t atomic_uint_fast32_t;

typedef     uint_least32_t atomic_uint_least32_t;

#  define ATOMIC_VAR_INIT(value) (value)

#  define atomic_init(obj, value) \
    do { *(obj) = (value); } while(0)

#endif /* __cplusplus */
