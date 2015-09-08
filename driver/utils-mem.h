
#ifndef __UTILS_MEMORY_H_
#define __UTILS_MEMORY_H_

/**
 * General memory management routines, macros and constants.
 */


#include <ntifs.h>
#include "allocator.h"


/************************************************************************/
/*                         MACROS                                       */
/************************************************************************/

/** Used to tag memory allocated by the VrtuleTree.sys driver. */
#define PROJECT_POOL_TAG             (ULONG)'ertV'


/** Copies pointer-sized block of memory from kernel memory to user portion of the 
 *  current address space. 
 *
 *  @param Destination Destination address. Must lie in the user portion of the
 *  address space.
 *  @param Source Source address. Must point to kernel memory.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
#define MemoryPointerCopyToUser(Destination, Source)           MemoryCopyToUser(Destination, Source, sizeof(PVOID))


/** Copies pointer-sized block of memory from user portion of the current 
 *  address space to the kernel memory. 
 *
 *  @param Destination Destination address. Must point to kernel memory.
 *  @param Source Source address. Must lie within the user portion of the address
 *  space.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
#define MemoryPointerCopyToKernel(Destination, Source)         MemoryCopyToKernel(Destination, Source, sizeof(PVOID))


/** Copies pointer-sized block of memory between two places in user portion
 *  of the current address space. 
 *
 *  @param Destination Destination address. Must lie within user portion of the
 *  address space.
 *  @param Source Source address. Must lie within user portion of the address space.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
#define MemoryPointerCopyInUser(Destination, Source)           MemoryCopyInUser(Destination, Source, sizeof(PVOID))


/** safely copies pointer-sized block of memory. 
 *
 *  @param Source Source address.
 *  @param Destination Destination address.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
#define MemoryPointerCopySafe(Destination, Source)             MemoryCopySafe(Destination, Source, sizeof(PVOID))


/** Allocates block of nonpaged memory.
 *
 *  @param NumberOfBytes Size of the block, in bytes.
 *
 *  @return
 *  Returns address of the newly allocated block. If the allocation fails, NULL is
 *  returned.
 */
#define HeapMemoryAllocNonPaged(NumberOfBytes)                 HeapMemoryAlloc(NonPagedPool, NumberOfBytes)


/** Allocates block of paged memory.
 *
 *  @param NumberOfBytes Size of the block, in bytes.
 *
 *  @return
 *  Returns address of the newly allocated block. If the allocation fails, NULL is
 *  returned.
 */
#define HeapMemoryAllocPaged(NumberOfBytes)                    HeapMemoryAlloc(PagedPool, NumberOfBytes)


#ifdef _DEBUG
#define HeapMemoryAlloc(PoolType, NumberOfBytes)       DebugAllocatorAlloc(PoolType, NumberOfBytes, __FUNCTION__, __LINE__)
#define HeapMemoryFree(Address)                        DebugAllocatorFree(Address)
#else
#define HeapMemoryAlloc(PoolType, NumberOfBytes)       StandardHeapMemoryAlloc(PoolType, NumberOfBytes)
#define HeapMemoryFree(Address)                        StandardHeapMemoryFree(Address)
#endif

/************************************************************************/
/*                      ROUTINE HEADERS                                 */
/************************************************************************/

PVOID StandardHeapMemoryAlloc(POOL_TYPE PoolType, SIZE_T NumberOfBytes);
VOID StandardHeapMemoryFree(PVOID Address);
NTSTATUS VirtualMemoryAllocUser(SIZE_T NumberOfBytes, ULONG Protection, PVOID *Address);
VOID VirtualMemoryFreeUser(PVOID Address);
NTSTATUS MemoryCopyToUser(PVOID Destionation, PVOID Source, SIZE_T NumberOfBytes);
NTSTATUS MemoryCopyToKernel(PVOID Destionation, PVOID Source, SIZE_T NumberOfBytes);
NTSTATUS MemoryCopyInUser(PVOID Destination, PVOID Source, SIZE_T NumberOfBytes);
NTSTATUS MemoryCopySafe(PVOID Destination, PVOID Source, SIZE_T NumberOfBytes);


#endif
