
#include <ntifs.h>
#include "preprocessor.h"
#include "utils-mem.h"
#include "utils-dym-array.h"

#undef DEBUG_TRACE_ENABLED
#define DEBUG_TRACE_ENABLED 0

/************************************************************************/
/*                           HELPER ROUTINES                            */
/************************************************************************/


/** Initializes dynamic array synchronization. 
 *
 *  The actual synchronization mechanism depends on the memory pool type used
 *  by the array. Paged dynamic arrays use fast mutexes, nonpaged work
 *  witch spin locks.
 *
 *  @param Array Dynamic array
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
static NTSTATUS _DymArraySynchronizationAlloc(PUTILS_DYM_ARRAY Array)
{
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Array=0x%p", Array);

   switch (Array->PoolType) {
   case PagedPool:
      Array->LockPaged = (PFAST_MUTEX)HeapMemoryAllocNonPaged(sizeof(FAST_MUTEX));
      if (Array->LockPaged != NULL) {
         ExInitializeFastMutex(Array->LockPaged);
         status = STATUS_SUCCESS;
      } else status = STATUS_INSUFFICIENT_RESOURCES;
      break;
   case NonPagedPool:
      Array->LockNonPaged = (PKSPIN_LOCK)HeapMemoryAllocNonPaged(sizeof(KSPIN_LOCK));
      if (Array->LockNonPaged != NULL) {
         KeInitializeSpinLock(Array->LockNonPaged);
         status = STATUS_SUCCESS;
      } else status = STATUS_INSUFFICIENT_RESOURCES;
      break;
   default:
      DEBUG_ERROR("Invalid pool type supplied (%u)", Array->PoolType);
      status = STATUS_NOT_SUPPORTED;
      break;
   }

   DEBUG_EXIT_FUNCTION("0x%x", status);
   return status;
}


/** Destroys dynamic array synchronization.
 *
 *  @param Array Dynamic array.
 */
static VOID _DymArraySynchronizationFree(PUTILS_DYM_ARRAY Array)
{
   DEBUG_ENTER_FUNCTION("Array=0x%p", Array);

   switch (Array->PoolType) {
      case PagedPool:
         HeapMemoryFree(Array->LockPaged);
         break;
      case NonPagedPool:
         HeapMemoryFree(Array->LockNonPaged);
         break;
      default:
         DEBUG_ERROR("Invalid pool type of the array (%u)", Array->PoolType);
         KeBugCheck(0);
         break;
   }

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}


/************************************************************************/
/*                             PUBLIC ROUTINES                          */
/************************************************************************/


/** Creates a new instance of a dynamic array.
 * 
 *  @param PoolType Type of memory pool where the dynamic array should be stored.
 *  @param Array Address of variable that, when the function succeeds, receives
 *  address of newly created dynamic array.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS DymArrayCreate(POOL_TYPE PoolType, PUTILS_DYM_ARRAY *Array)
{
   PUTILS_DYM_ARRAY tmpArray = NULL;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("PoolType=%u; Array=0x%p", PoolType, Array);

   *Array = NULL;
   tmpArray = (PUTILS_DYM_ARRAY)HeapMemoryAllocNonPaged(sizeof(UTILS_DYM_ARRAY));
   if (tmpArray != NULL) {
      tmpArray->PoolType = PoolType;
      tmpArray->AllocatedLength = DYM_ARRAY_INITIAL_ALLOC_LENGTH;
      tmpArray->ValidLength = 0;
      status = _DymArraySynchronizationAlloc(tmpArray);
      if (NT_SUCCESS(status)) {
         tmpArray->Data = (PVOID *)HeapMemoryAlloc(tmpArray->PoolType, DYM_ARRAY_INITIAL_ALLOC_LENGTH * sizeof(PVOID));
         if (tmpArray != NULL) {
            *Array = tmpArray;
         } else status = STATUS_INSUFFICIENT_RESOURCES;

         if (!NT_SUCCESS(status))
            _DymArraySynchronizationFree(tmpArray);
      }

      if (!NT_SUCCESS(status))
         HeapMemoryFree(tmpArray);
   } else status = STATUS_INSUFFICIENT_RESOURCES;

   DEBUG_EXIT_FUNCTION("0x%x, *Array=0x%p", status, *Array);
   return status;
}


/** Destroys a dynamic array.
 *
 *  @param Array Dynamic array to destroy.
 */
VOID DymArrayDestroy(PUTILS_DYM_ARRAY Array)
{
   DEBUG_ENTER_FUNCTION("Array=0x%p", Array);

   HeapMemoryFree(Array->Data);
   _DymArraySynchronizationFree(Array);
   HeapMemoryFree(Array);

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}


/** Locks given dynamic array.
 *
 *  @param Array Dynamic array to lock.
 *  @param Irql The argument is used only by nonpaged dynamic arrays. It is an
 *  address of variable that is filled by a value of IRQL the thread was running
 *  at before the lock operation.
 */
VOID DymArrayLock(PUTILS_DYM_ARRAY Array, PKIRQL Irql)
{
   DEBUG_ENTER_FUNCTION("Array=0x%p; Irql=0x%p", Array, Irql);

   switch (Array->PoolType) {
      case PagedPool:
         ExAcquireFastMutex(Array->LockPaged);
         break;
      case NonPagedPool:
         KeAcquireSpinLock(Array->LockNonPaged, Irql);
         break;
      default:
         DEBUG_ERROR("Invalid array pool type (%u)", Array->PoolType);
         KeBugCheck(0);
         break;
   }

   DEBUG_EXIT_FUNCTION(" *Irql=%u", *Irql);
   return;
}


/** Unlock a dynamic array.
 *
 *  @param Array Dynamic array to unlock.
 *  @param Irql Used by the nonpaged dynamic arrays only. The argument muste contain
 *  value returned by the lock operation.
 */
VOID DymArrayUnlock(PUTILS_DYM_ARRAY Array, KIRQL Irql)
{
   DEBUG_ENTER_FUNCTION("Array=0x%p; Irql=%u", Array, Irql);

   switch (Array->PoolType) {
   case PagedPool:
      ExReleaseFastMutex(Array->LockPaged);
      break;
   case NonPagedPool:
      KeReleaseSpinLock(Array->LockNonPaged, Irql);
      break;
   default:
      DEBUG_ERROR("Invalid array pool type (%u)", Array->PoolType);
      KeBugCheck(0);
      break;
   }

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}


/** Reserves space to store given number of items in the dynamic array.
 *
 *  The routine works the smae as std::vector::reserve().
 *
 *  @param Array Dynamic array.
 *  @param Length Number of items for which the space should be reserved.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 *
 *  @remark
 *  The routine always caused interanl buffer that stores individual items of the
 *  dynamic array to be reallocated. Items stored withuin the array are always
 *  copied to the new internal buffer. The routine can be used also to shrink the
 *  dynamic array which implies that items with indices higher or equal the Length
 *  argument are not copied.
 */
NTSTATUS DymArrayReserve(PUTILS_DYM_ARRAY Array, SIZE_T Length)
{
   PVOID tmpBuffer = NULL;
   SIZE_T minLength = 0;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Array=0x%p; Length=%u", Array, Length);

   tmpBuffer = HeapMemoryAlloc(Array->PoolType, Length*sizeof(PVOID));
   if (tmpBuffer != NULL) {
      minLength = min(Array->ValidLength, Length);
      RtlCopyMemory(tmpBuffer, Array->Data, minLength * sizeof(PVOID));
      tmpBuffer = InterlockedExchangePointer((volatile PVOID *)&Array->Data, tmpBuffer);
      HeapMemoryFree(tmpBuffer);
      Array->AllocatedLength = Length;
      Array->ValidLength = minLength;
      status = STATUS_SUCCESS;
   } else status = STATUS_INSUFFICIENT_RESOURCES;

   DEBUG_EXIT_FUNCTION("0x%x", status);
   return status;
}


/** Inserts a new item to the end of the dynamic array.
 *
 *  The routine works similarly to std::vector::push_back.
 *
 *  @param Array Dynamic array.
 *  @param Value Item to insert.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 *  The routine fail only in case it must reserve more space for array items
 *  and attempt to do so fails.
 */
NTSTATUS DymArrayPushBack(PUTILS_DYM_ARRAY Array, PVOID Value)
{
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Array=0x%p; Value=0x%p", Array, Value);

   if (Array->ValidLength == Array->AllocatedLength) {
      status = DymArrayReserve(Array, Array->AllocatedLength * (100 + DYM_ARRAY_INCREASE_PER_CENTS) / 100);
      if (Array->ValidLength == Array->AllocatedLength) {
         status = DymArrayReserve(Array, Array->AllocatedLength + 1);
      }
   } else status = STATUS_SUCCESS;

   if (NT_SUCCESS(status)) {
      Array->Data[Array->ValidLength] = Value;
      Array->ValidLength++;
   }

   DEBUG_EXIT_FUNCTION("0x%x", status);
   return status;
}


/** Removes an item from the end of the dynamic array.
 *
 *  @param Array Dynamic array.
 *
 *  @return
 *  The routine returns the item removed from the array. Calling the routine to
 *  remove an item from the empty array results in a bug check.
 */
PVOID DymArrayPopBack(PUTILS_DYM_ARRAY Array)
{
   PVOID ret = NULL;
   DEBUG_ENTER_FUNCTION("Array=0x%p", Array);

   if (Array->ValidLength > 0) {
      ret = Array->Data[Array->ValidLength - 1];
      Array->ValidLength--;
   } else {
      DEBUG_ERROR("Attempt to remove an item from an empty array (0x%p)", Array);
      KeBugCheck(0);
   }

   DEBUG_EXIT_FUNCTION("0x%p", ret);
   return ret;
}


/** Inserts an item to the front (index 0) of the dynamic array.
 *
 *  @param Array Dynamic array.
 *  @param Value Item to insert.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 *  The routine fail only in case it must reserve more space for array items
 *  and attempt to do so fails.
 */
NTSTATUS DymArrayPushFront(PUTILS_DYM_ARRAY Array, PVOID Value)
{
   SIZE_T i = 0;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Array=0x%p; Value=0x%p", Array, Value);

   if (Array->ValidLength == Array->AllocatedLength) {
      status = DymArrayReserve(Array, Array->AllocatedLength * (100 + DYM_ARRAY_INCREASE_PER_CENTS) / 100);
      if (Array->ValidLength == Array->AllocatedLength) {
         status = DymArrayReserve(Array, Array->AllocatedLength + 1);
      }
   } else status = STATUS_SUCCESS;

   if (NT_SUCCESS(status)) {
      for (i = Array->ValidLength; i > 0; i--)
         Array->Data[i] = Array->Data[i - 1];

      Array->Data[0] = Value;
      Array->ValidLength++;
   }

   DEBUG_EXIT_FUNCTION("0x%x", status);
   return status;
}


/** Removes an item from the beginning of the dynamic array.
 *
 *  @param Array Dynamic array.
 *
 *  @return
 *  The routine returns the item removed from the array. Calling the routine to
 *  remove an item from an empty array results in a bug check.
 */
PVOID DymArrayPopFront(PUTILS_DYM_ARRAY Array)
{   
   SIZE_T i = 0;
   PVOID ret = NULL;
   DEBUG_ENTER_FUNCTION("Array=0x%p", Array);

   if (Array->ValidLength > 0) {
      ret = Array->Data[0];
      for (i = 0; i < Array->ValidLength - 1; i++)
         Array->Data[i] = Array->Data[i + 1];

      Array->ValidLength--;
   } else {
      DEBUG_ERROR("Attempt to remove an item from an empty array (0x%p)", Array);
      KeBugCheck(0);
   }

   DEBUG_EXIT_FUNCTION("0x%p", ret);
   return ret;
}


/** Returns number of items stored in the dynamic array.
 *
 *  @param Array Dynamic array.
 *
 *  @return
 *  Returns number of items stored in the dynamic array.
 */
SIZE_T DymArrayLength(PUTILS_DYM_ARRAY Array)
{
   SIZE_T ret = 0;
   DEBUG_ENTER_FUNCTION("Array=0x%p", Array);

   ret = Array->ValidLength;

   DEBUG_EXIT_FUNCTION("0x%p", ret);
   return ret;
}


/** Retrieves number of items the array can be filled with without any 
 *  memory allocations.
 *
 *  @param Array Dynamic array.
 *
 *  @return
 * Retrieves number of items the array can be filled with without any 
 *  memory allocations.
 */
SIZE_T DymArrayAllocatedLength(PUTILS_DYM_ARRAY Array)
{
   SIZE_T ret = 0;
   DEBUG_ENTER_FUNCTION("Array=0x%p", Array);

   ret = Array->AllocatedLength;

   DEBUG_EXIT_FUNCTION("0x%p", ret);
   return ret;
}


/** Returns item placed at given index in the dynamic array.
 *
 *  @param Array Dynamic array.
 *  @param Index Index of the item to return.
 *
 *  @return
 *  Returns item placed at given index in the dynamic array. Calling the
 *  routine with item index lying out of the array bounds results in a
 *  bug check.
 */
PVOID DymArrayItem(PUTILS_DYM_ARRAY Array, SIZE_T Index)
{
   PVOID ret;
   DEBUG_ENTER_FUNCTION("Array=0x%p; Index=%u", Array, Index);

   if (Index < Array->ValidLength) {
      ret = Array->Data[Index];
   } else {
      DEBUG_ERROR("Index out of bounds (%u)", Index);
      KeBugCheck(0);
   }

   DEBUG_EXIT_FUNCTION("0x%p", ret);
   return ret;
}


/** Copies contents of the dynamic array to given static array.
 *  
 *  @param Array Dynamic array.
 *  @param StaticArray Address of the first item of the static array where the
 *  items of the dynamic array should be copied. The static array must be large
 *  enough to store all the items.
 */
VOID DymArrayToStaticArray(PUTILS_DYM_ARRAY Array, PVOID StaticArray)
{
   DEBUG_ENTER_FUNCTION("Array=0x%p; StaticArray=0x%p", Array, StaticArray);

   RtlCopyMemory(StaticArray, Array->Data, Array->ValidLength * sizeof(PVOID));

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}


/** Allocates static array and copies contents of the dynamic array to it.
 *
 *  @param Array Dynamic array.
 *  @param PoolType Type of memory pool from which the static array should be allocated.
 *  @param StaticArray Address of variable that, when the function succeeds, receives
 *  address of newly allocated static array that contains copies of the items of the dynamic
 *  array.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS DymArrayToStaticArrayAlloc(PUTILS_DYM_ARRAY Array, POOL_TYPE PoolType, PVOID *StaticArray)
{
   SIZE_T numBytes = 0;
   PVOID tmpStaticArray = NULL;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Array=0x%p; PoolType=%u; StaticArray=0x%p", Array, PoolType, StaticArray);

   *StaticArray = NULL;
   numBytes = Array->ValidLength * sizeof(PVOID);
   if (numBytes > 0) {
      tmpStaticArray = HeapMemoryAlloc(PoolType, numBytes);
      if (tmpStaticArray != NULL) {
         DymArrayToStaticArray(Array, tmpStaticArray);
         *StaticArray = tmpStaticArray;
         status = STATUS_SUCCESS;
      } else status = STATUS_INSUFFICIENT_RESOURCES;
   } else status = STATUS_SUCCESS;

   DEBUG_EXIT_FUNCTION("0x%x, *StaticArray=0x%p", status, *StaticArray);
   return status;
}
