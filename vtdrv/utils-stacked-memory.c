
#include <ntifs.h>
#include "preprocessor.h"
#include "utils-mem.h"
#include "utils-stack.h"
#include "utils-stacked-memory.h"

#undef DEBUG_TRACE_ENABLED
#define DEBUG_TRACE_ENABLED 0

/************************************************************************/
/*                              HELPER TOUTINES                         */
/************************************************************************/

/** Allocates and initializes a stacked memory record.
 *
 *  @param StackedMemory Stacked memory to which the new record should belong.
 *  @param AllocType Type of the allocation operation recorded by the record.
 *  @param Address Address of the memory block allocated by the operation.
 *
 *  @return
 *  If the function succeeds, address of the new stacked memory record is returned.
 *  When the routine fails, it returns NULL value.
 */
static PUTILS_STACKED_MEMORY_RECORD _StackedMemoryAllocRecord(PUTILS_STACK StackedMemory, EStackedMemoryAllocType AllocType, PVOID Address)
{
   PUTILS_STACKED_MEMORY_RECORD ret = NULL;
   DEBUG_ENTER_FUNCTION("StackedMemory=0x%p; AllocType=%u; Address=0x%p", StackedMemory, AllocType, Address);

   ret = (PUTILS_STACKED_MEMORY_RECORD)HeapMemoryAlloc(StackedMemory->PoolType, sizeof(UTILS_STACKED_MEMORY_RECORD));
   if (ret != NULL) {
      ret->Address = Address;
      ret->AllocType = AllocType;
   }

   DEBUG_EXIT_FUNCTION("0x%p", ret);
   return ret;
}


/************************************************************************/
/*                        PUBLIC ROUTINES                               */
/************************************************************************/


/** Creates an instance of stacked memory.
 *
 *  @param StackedMemory Address of variable that, in case of success, receives
 *  address of new stacked memory object.
 *
 *  @return
 *  The function returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS StackedMemoryCreate(POOL_TYPE PoolType, PUTILS_STACK *StackedMemory)
{
   PUTILS_STACK tmpStackedMemory = NULL;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("PoolType=%u; StackedMemory=0x%p", PoolType, StackedMemory);

   *StackedMemory = NULL;
   status = StackCreate(PoolType, &tmpStackedMemory);
   if (NT_SUCCESS(status))
      *StackedMemory = tmpStackedMemory;

   DEBUG_EXIT_FUNCTION("0x%x, *StackedMemory=0x%p", status, *StackedMemory);
   return status;
}


/** Allocates memory from kernel memory pool and stores this information into 
 *  stacked memory object.
 *
 *  @param StackedMemory Stacked memory object.
 *  @param PoolType Type of memory pool.
 *  @param NumberOfBytes Size of memory block to allocate, in bytes.
 *  @param Address Address of variable that, in case of success, receives address
 *  of newly allocated memory block.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS StackedMemoryHeapAlloc(PUTILS_STACK StackedMemory, POOL_TYPE PoolType, SIZE_T NumberOfBytes, PVOID *Address)
{
   PVOID tmpAddress = NULL;
   PUTILS_STACKED_MEMORY_RECORD stackRecord = NULL;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("StackedMemory=0x%p; PoolType=%u; NumberOfBytes=%u; Address=0x%p", StackedMemory, PoolType, NumberOfBytes, Address);

   *Address = NULL;
   tmpAddress = HeapMemoryAlloc(PoolType, NumberOfBytes);
   if (tmpAddress != NULL) {
      stackRecord = _StackedMemoryAllocRecord(StackedMemory, smatHeap, tmpAddress);
      if (stackRecord != NULL) {
         StackPushNoAlloc(StackedMemory, &stackRecord->StackItem);
         *Address = tmpAddress;
         status = STATUS_SUCCESS;
      } else status = STATUS_INSUFFICIENT_RESOURCES;

      if (!NT_SUCCESS(status))
         HeapMemoryFree(tmpAddress);
   } else status = STATUS_INSUFFICIENT_RESOURCES;

   DEBUG_EXIT_FUNCTION("0x%x, *Address=0x%p", *Address);
   return status;
}


/** Allocates virtual memory from the user portion of the current address space and
 *  records this operation to given stacked memory object.
 *
 *  @param StackedMemory Stacked memory object.
 *  @param NumberOfBytes Size of the block to allocate, in bytes.
 *  @param Protection Protection of the pages the newly allocated memory block
 *  consists of.
 *  @param Address Address of variable that, in case of success, receives address
 *  of the newly allocated memory block.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS StackedMemoryVirtualAllocUser(PUTILS_STACK StackedMemory, SIZE_T NumberOfBytes, ULONG Protection, PVOID *Address)
{
   PVOID tmpAddress = NULL;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   PUTILS_STACKED_MEMORY_RECORD stackRecord = NULL;
   DEBUG_ENTER_FUNCTION("StackedMemory=0x%p; NumberOfBytes=%u; Protection=0x%x; Address=0x%p", StackedMemory, NumberOfBytes, Protection, Address);

   status = VirtualMemoryAllocUser(NumberOfBytes, Protection, &tmpAddress);
   if (NT_SUCCESS(status)) {
      stackRecord = _StackedMemoryAllocRecord(StackedMemory, smatVirtual, tmpAddress);
      if (stackRecord != NULL) {
         StackPushNoAlloc(StackedMemory, &stackRecord->StackItem);
         status = STATUS_SUCCESS;
         *Address = tmpAddress;
      } else status = STATUS_INSUFFICIENT_RESOURCES;

      if (!NT_SUCCESS(status))
         VirtualMemoryFreeUser(tmpAddress);
   }

   DEBUG_EXIT_FUNCTION("0x%x, *Address=0x%p", status, *Address);
   return status;
}


/** Reverses last operation recorded in the stacked memory object.
 *
 *  Reversing an operation means freeing memory the operation had allocated.
 *
 *  @param StackedMemory Stacked memory object.
 *
 *  @remark
 *  If the stacked memory object contains no operation records, nothing happens.
 */
VOID StackedMemoryLastFree(PUTILS_STACK StackedMemory)
{
   PUTILS_STACK_ITEM stackItem = NULL;
   PUTILS_STACKED_MEMORY_RECORD stackRecord = NULL;
   DEBUG_ENTER_FUNCTION("StackedMemory=0x%p", StackedMemory);

   if (!StackEmpty(StackedMemory)) {
      stackItem = StackPopNoFree(StackedMemory);
      stackRecord = CONTAINING_RECORD(stackItem, UTILS_STACKED_MEMORY_RECORD, StackItem);
      switch (stackRecord->AllocType) {
         case smatHeap:
            HeapMemoryFree(stackRecord->Address);
            break;
         case smatVirtual:
            VirtualMemoryFreeUser(stackRecord->Address);
            break;
         default:
            DEBUG_ERROR("Invalid stacked memory record type (%u)", stackRecord->AllocType);
            KeBugCheck(0);
            break;
      }

      HeapMemoryFree(stackRecord);
   }

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}


/** Reverses all operations recorded in the stacked memory object.
 *
 *  Reversing an operation means freeing memory the operation had allocated.
 *
 *  @param StackedMemory Stacked memory object.
 *
 *  @remark
 *  If the stacked memory object contains no operation records, nothing happens.
 */
VOID StackedMemoryAllFree(PUTILS_STACK StackedMemory)
{
   PUTILS_STACK_ITEM stackItem = NULL;
   PUTILS_STACKED_MEMORY_RECORD stackRecord = NULL;
   DEBUG_ENTER_FUNCTION("StackedMemory=0x%p", StackedMemory);

   while (!StackEmpty(StackedMemory)) {
      stackItem = StackPopNoFree(StackedMemory);
      stackRecord = CONTAINING_RECORD(stackItem, UTILS_STACKED_MEMORY_RECORD, StackItem);
      switch (stackRecord->AllocType) {
      case smatHeap:
         HeapMemoryFree(stackRecord->Address);
         break;
      case smatVirtual:
         VirtualMemoryFreeUser(stackRecord->Address);
         break;
      default:
         DEBUG_ERROR("Invalid stacked memory record type (%u)", stackRecord->AllocType);
         KeBugCheck(0);
         break;
      }

      HeapMemoryFree(stackRecord);
   }

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}


/** Destroys given stacked memory object. 
 *
 *  Operations recorded within the object are not reversed. Their records are just
 *  deallocated.
 *
 *  @param StackedMemory Stacked memory object.
 */
VOID StackedMemoryDestroy(PUTILS_STACK StackedMemory)
{
   PUTILS_STACK_ITEM stackItem = NULL;
   PUTILS_STACKED_MEMORY_RECORD stackRecord = NULL;
   DEBUG_ENTER_FUNCTION("StackedMemory=0x%p", StackedMemory);

   while (!StackEmpty(StackedMemory)) {
      stackItem = StackPopNoFree(StackedMemory);
      stackRecord = CONTAINING_RECORD(stackItem, UTILS_STACKED_MEMORY_RECORD, StackItem);
      HeapMemoryFree(stackRecord);
   }

   StackDestroy(StackedMemory);

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}
