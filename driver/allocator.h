
#ifndef __VRTULETREE_DEBUG_ALLOCATOR_H__
#define __VRTULETREE_DEBUG_ALLOCATOR_H__

/**
 * Implementation of a special memory allocator. 
 * 
 * The allocator records information
 * about every memory allocation adn deallocation, attempts to check validity of
 * a heap, which should catch writting too many data to small buffers, and keeps
 * an eye on memory leaks.
 *
 * Structure of every memory block allocated by the allocator looks as follows:
 * - THE HEADER (allocator-specific information are stored here)
 * - THE BLOCK (user gets pointer to beginning of this member)
 * - THE FOOTER (contains signature in order to detect writting to small buffers)
 *
 * The allocator records the following information about every allocated block:
 * - Type of memory pool
 * - size
 * - name of function that allocated it
 * - line of code that allocated it
 */

#include <ntifs.h>


/** Magic signature of block header, used to detect overrides. */
#define BLOCK_HEADER_SIGNATURE         0xfeadefdf
/** Magic signature of block footer, used to detect overrides. */
#define BLOCK_FOOTER_SIGNATURE         0xf00defdf


/** Structure of the header of memory block allocated by the allocator. */
typedef struct {
   /** Used to store the block within list of allocated blocks. */
   LIST_ENTRY Entry;
   /** Name of function that allocated the block. */
   PCHAR Function;
   /** Line of code where the allocation occurred. */
   ULONG Line;
   /** Type of memory pool the block is allocated from. */
   POOL_TYPE PoolType;
   /** Size of the block, in bytes (without the header and the footer). */
   SIZE_T NumberOfBytes;
   /** Header signature */
   ULONG Signature;
} DEBUG_BLOCK_HEADER, *PDEBUG_BLOCK_HEADER;

/** Structure of the footer of memory block allocated by the allocator. */
typedef struct {
   /** Signature of the footer. */
   ULONG Signature;
} DEBUG_BLOCK_FOOTER, *PDEBUG_BLOCK_FOOTER;


/************************************************************************/
/*                     PUBLIC ROUTINE HEADERS                           */
/************************************************************************/


PVOID DebugAllocatorAlloc(POOL_TYPE PoolType, SIZE_T NumberOfBytes, PCHAR Function, ULONG Line);
VOID DebugAllocatorFree(PVOID Address);

NTSTATUS DebugAllocatorModuleInit(VOID);
VOID DebugAllocatorModuleFinit(VOID);


#endif
