
#ifndef __UTILS_DYM_ARRAY_H_
#define __UTILS_DYM_ARRAY_H_

/** 
 * Implementation of dynamic arrays. They are like std::vector but can store only
 * pointers. 
 */


#include <ntifs.h>

/** When the array is created it reserves space to store this number of items. */
#define DYM_ARRAY_INITIAL_ALLOC_LENGTH         16
/** When the array is full and a new item is being inserted, it increases its internal
    by this constants. */
#define DYM_ARRAY_INCREASE_PER_CENTS           20

/** Represents a dynamic array. */
typedef struct {
   /** Type of memory pool from which the internal array structures should be allocated. */
   POOL_TYPE PoolType;
   /** Number of items stored in the array. */
   SIZE_T ValidLength;
   /** Number of items the array can contain without any memory operations. */
   SIZE_T AllocatedLength;
   /** Used to synchronize access to paged arrays. */
   PFAST_MUTEX LockPaged;
   /** Used to synchronize access to nonpaged arrays. */
   PKSPIN_LOCK LockNonPaged;
   PVOID *Data;
} UTILS_DYM_ARRAY, *PUTILS_DYM_ARRAY;


NTSTATUS DymArrayCreate(POOL_TYPE PoolType, PUTILS_DYM_ARRAY *Array);
VOID DymArrayDestroy(PUTILS_DYM_ARRAY Array);
NTSTATUS DymArrayReserve(PUTILS_DYM_ARRAY Array, SIZE_T Length);
NTSTATUS DymArrayPushBack(PUTILS_DYM_ARRAY Array, PVOID Value);
PVOID DymArrayPopBack(PUTILS_DYM_ARRAY Array);
NTSTATUS DymArrayPushFront(PUTILS_DYM_ARRAY Array, PVOID Value);
PVOID DymArrayPopFront(PUTILS_DYM_ARRAY Array);
SIZE_T DymArrayLength(PUTILS_DYM_ARRAY Array);
SIZE_T DymArrayAllocatedLength(PUTILS_DYM_ARRAY Array);
PVOID DymArrayItem(PUTILS_DYM_ARRAY Array, SIZE_T Index);
VOID DymArrayLock(PUTILS_DYM_ARRAY Array, PKIRQL Irql);
VOID DymArrayUnlock(PUTILS_DYM_ARRAY Array, KIRQL Irql);
VOID DymArrayToStaticArray(PUTILS_DYM_ARRAY Array, PVOID StaticArray);
NTSTATUS DymArrayToStaticArrayAlloc(PUTILS_DYM_ARRAY Array, POOL_TYPE PoolType, PVOID *StaticArray);


#endif
