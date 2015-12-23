
#ifndef __UTILS_STACKED_MEMORY_H_
#define __UTILS_STACKED_MEMORY_H_

/**
 * Implementation of stacked memory.
 *
 * Stacked memory is something like Mark/Release approach known from good old
 * Borland Pascal. Stacked memory records individual allocation operations and
 * can be used to "rollback" them (free allocated resources) at onec.
 *
 * Stacked memory is just a stack of records where each record contains information
 * about one allocation operation operation.
 */

#include <ntifs.h>
#include "utils-stack.h"

/** Type of the allocation. */
typedef enum {
   /** Allocation was performed from a kernel memory pool. */
   smatHeap,
   /** Virtual pages from the user portion of the process address space were allocated.*/
   smatVirtual
} EStackedMemoryAllocType;

/** Stores information about one allocation operation. */
typedef struct {
   /** Used by the memory stack to group the operations together. */
   UTILS_STACK_ITEM StackItem;
   /** Tzpe of the allocation operation. */
   EStackedMemoryAllocType AllocType;
   /** Address of the allocated block. */
   PVOID Address;
} UTILS_STACKED_MEMORY_RECORD, *PUTILS_STACKED_MEMORY_RECORD;


/************************************************************************/
/*                              MACROS                                  */
/************************************************************************/


/** Allocates memory from PagedPool and stores this information into 
 *  stacked memory object.
 *
 *  @param StackedMemory Stacked memory object.
 *  @param NumberOfBytes Size of memory block to allocate, in bytes.
 *  @param Address Address of variable that, in case of success, receives address
 *  of newly allocated memory block.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
#define StackedMemoryHeapAllocPaged(StackedMemory, NumberOfBytes, Address)     StackedMemoryHeapAlloc(StackedMemory, PagedPool, NumberOfBytes, Address)


/** Allocates memory from NonPagedPool and stores this information into 
 *  stacked memory object.
 *
 *  @param StackedMemory Stacked memory object.
 *  @param NumberOfBytes Size of memory block to allocate, in bytes.
 *  @param Address Address of variable that, in case of success, receives address
 *  of newly allocated memory block.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
#define StackedMemoryHeapAllocNonPaged(StackedMemory, NumberOfBytes, Address)  StackedMemoryHeapAlloc(StackedMemory, NonPagedPool, NumberOfBytes, Address)


/************************************************************************/
/*                              ROUTINE DEFINITIONS                     */
/************************************************************************/

NTSTATUS StackedMemoryCreate(POOL_TYPE PoolType, PUTILS_STACK *StackedMemory);
NTSTATUS StackedMemoryHeapAlloc(PUTILS_STACK StackedMemory, POOL_TYPE PoolType, SIZE_T NumberOfBytes, PVOID *Address);
NTSTATUS StackedMemoryVirtualAllocUser(PUTILS_STACK StackedMemory, SIZE_T NumberOfBytes, ULONG Protection, PVOID *Address);
VOID StackedMemoryLastFree(PUTILS_STACK StackedMemory);
VOID StackedMemoryAllFree(PUTILS_STACK StackedMemory);
VOID StackedMemoryDestroy(PUTILS_STACK StackedMemory);




#endif
