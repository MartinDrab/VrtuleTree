
#include <ntifs.h>
#include "preprocessor.h"
#include "utils-mem.h"

#undef DEBUG_TRACE_ENABLED
#define DEBUG_TRACE_ENABLED 0

// required to compile in certain debug settings.
volatile ULONG __security_cookie = __LINE__;



/** Allocates block of memory from given memory pool.
 *
 *  @param PoolType Type of the memory pool.
 *  @param NumberOfBytes Size of the block, in bytes.
 *
 *  @return
 *  Returns address of the newly allocated block. If the allocation fails, NULL is
 *  returned.
 */
PVOID StandardHeapMemoryAlloc(POOL_TYPE PoolType, SIZE_T NumberOfBytes)
{
   PVOID ret = NULL;
   DEBUG_ENTER_FUNCTION("PoolType=%u; NumberOfBytes=%u", PoolType, NumberOfBytes);

   ret = ExAllocatePoolWithTag(PoolType, NumberOfBytes, PROJECT_POOL_TAG);

   DEBUG_EXIT_FUNCTION("0x%p", ret);
   return ret;
}


/** Frees given block of memory.
 *
 *  @param Address Address of block to be freed.
 */
VOID StandardHeapMemoryFree(PVOID Address)
{
   DEBUG_ENTER_FUNCTION("Address=0x%p", Address);

   ExFreePoolWithTag(Address, PROJECT_POOL_TAG);

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}


/** Allocates virtual memory in user portion of the current process address sapce.
 *
 *  @param NumberOfBytes Size of the block to allocate, in bytes.
 *  @param Protection Page protection of the block.
 *  @param Address Address of variable that, when the function succeeds, receives
 *  address of the newly allocated block of virtual memory.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS VirtualMemoryAllocUser(SIZE_T NumberOfBytes, ULONG Protection, PVOID *Address)
{
   PVOID tmp = NULL;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("NumberOfBytes=%u; Protection=0x%x; Address=0x%p", NumberOfBytes, Protection, Address);

   *Address = NULL;
   status = ZwAllocateVirtualMemory(NtCurrentProcess(), &tmp, 0, &NumberOfBytes, MEM_RESERVE | MEM_COMMIT, Protection);
   if (NT_SUCCESS(status))
      *Address = tmp;

   DEBUG_EXIT_FUNCTION("0x%x, *Address=0x%p", status, *Address);
   return status;
}


/** Frees block of virtual memory allocated by call to VirtualmemoryAllocUser
 *  function.
 *
 *  @param Address Address of block to free.
 */
VOID VirtualMemoryFreeUser(PVOID Address)
{
   SIZE_T tmp = 0;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Address=0x%p", Address);

   status = ZwFreeVirtualMemory(NtCurrentProcess(), &Address, &tmp, MEM_RELEASE);
   if (!NT_SUCCESS(status)) {
      DEBUG_ERROR("ZwFreeVirtualMemory failed at address 0x%p with status 0x%x", Address, status);
   }

   DEBUG_EXIT_FUNCTION_VOID()
   return;
}


/** Copies a block of memory to the user portion of the address space of the current
 *  process. Necessary checks are performed.
 *
 *  @param Destination Destination address. The address must point into the user portion
 *  of the address space.
 *  @param Source Source address. Must point to kernel memory.
 *  @param NumberOfBytes Number of bytes to copy.
 *
 *  @return
 *  Returns NTSTATUS value indication success or failure of the operation.
 */
NTSTATUS MemoryCopyToUser(PVOID Destionation, PVOID Source, SIZE_T NumberOfBytes)
{
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Destination=0x%p; Source=0x%p; NumberOfBytes=%u", Destionation, Source, NumberOfBytes);

   __try {
      ProbeForWrite(Destionation, NumberOfBytes, 1);
      RtlCopyMemory(Destionation, Source, NumberOfBytes);
      status = STATUS_SUCCESS;
   } __except (EXCEPTION_EXECUTE_HANDLER) {
      status = GetExceptionCode();
   }

   DEBUG_EXIT_FUNCTION("0x%x", status);
   return status;
}


/** Copies a block of memory to the kernel space.
 *  Necessary checks are performed.
 *
 *  @param Destination Destination address. Must lie in kernel memory.
 *  @param Source Source address. Must point to user portion of the address space.
 *  @param NumberOfBytes Number of bytes to copy.
 *
 *  @return
 *  Returns NTSTATUS value indication success or failure of the operation.
 */
NTSTATUS MemoryCopyToKernel(PVOID Destionation, PVOID Source, SIZE_T NumberOfBytes)
{
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Destination=0x%p; Source=0x%p; NumberOfBytes=%u", Destionation, Source, NumberOfBytes);

   __try {
      ProbeForRead(Source, NumberOfBytes, 1);
      RtlCopyMemory(Destionation, Source, NumberOfBytes);
      status = STATUS_SUCCESS;
   } __except (EXCEPTION_EXECUTE_HANDLER) {
      status = GetExceptionCode();
   }

   DEBUG_EXIT_FUNCTION("0x%x", status);
   return status;
}


/** Copies block of memory within the user portion of the address space of the current
 *  process. Necessary checks are performed.
 *
 *  @param Destination Destination address.
 *  @param Source Source address.
 *  @param NumberOfBytes Size of the block, in bytes.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 *
 *  @remark
 *  Source and destination of the copy operation must be in the user portion of the
 *  same address space.
 */
NTSTATUS MemoryCopyInUser(PVOID Destination, PVOID Source, SIZE_T NumberOfBytes)
{
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Destination=0x%p; Source=0x%p; NumberOfBytes=%u", Destination, Source, NumberOfBytes);

   __try {
      ProbeForRead(Source, NumberOfBytes, 1);
      ProbeForWrite(Destination, NumberOfBytes, 1);
      RtlCopyMemory(Destination, Source, NumberOfBytes);
      status = STATUS_SUCCESS;
   } __except (EXCEPTION_EXECUTE_HANDLER) {
      status = GetExceptionCode();
   }

   DEBUG_EXIT_FUNCTION("0x%x", status);
   return status;
}


/** Safely copies block of memory. Necessary checks are performed.
 *
 *  @param Destination Destination address.
 *  @param Source Source address.
 *  @param NumberOfBytes Number of bytes to copy.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS MemoryCopySafe(PVOID Destination, PVOID Source, SIZE_T NumberOfBytes)
{
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Destination=0x%p; Source=0x%p; NumberOfbytes=%u", Destination, Source, NumberOfBytes);

   if (Destination > MmHighestUserAddress && Source > MmHighestUserAddress) {
      RtlCopyMemory(Destination, Source, NumberOfBytes);
      status = STATUS_SUCCESS;
   } else if (Destination > MmHighestUserAddress) {
      status = MemoryCopyToKernel(Destination, Source, NumberOfBytes);
   } else if (Source > MmHighestUserAddress) {
      status = MemoryCopyToUser(Destination, Source, NumberOfBytes);
   } else status = MemoryCopyInUser(Destination, Source, NumberOfBytes);

   DEBUG_EXIT_FUNCTION("0x%x", status);
   return status;
}


