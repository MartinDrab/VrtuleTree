
#include <ntifs.h>
#include "preprocessor.h"
#include "utils-mem.h"
#include "utils-stack.h"


#undef DEBUG_TRACE_ENABLED
#define DEBUG_TRACE_ENABLED 0

/** Creates a new stack.
 *
 *  @param PoolType Type of memory pool to use for stack structures.
 *  @param Stack Address of variable that, when the function succeeds,
 *  receives address of newly created stack.
 *
 *  @return
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS StackCreate(POOL_TYPE PoolType, PUTILS_STACK *Stack)
{
   PUTILS_STACK tmpStack;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("PoolType=%u; Stack=0x%p", PoolType, Stack);

   tmpStack = (PUTILS_STACK)HeapMemoryAlloc(PoolType, sizeof(UTILS_STACK));
   if (tmpStack != NULL) {
      tmpStack->PoolType = PoolType;
      tmpStack->Top = (PUTILS_STACK_ITEM)&tmpStack->Top;
      *Stack = tmpStack;
      status = STATUS_SUCCESS;
   } else status = STATUS_INSUFFICIENT_RESOURCES;

   DEBUG_EXIT_FUNCTION("0x%x, *Stack=0x%p", status, *Stack);
   return status;
}


/** Pushes a new item into the stack. The routine performs no memory allocations
 *  and cannot fail. The caller must allocate and initializethe stack item herself. 
 *
 *  @param Stack The stack to which the new item should be inserted.
 *  @param Item New item.
 */
VOID StackPushNoAlloc(PUTILS_STACK Stack, PUTILS_STACK_ITEM Item)
{
   DEBUG_ENTER_FUNCTION("Stack=0x%p; Item=0x%p", Stack, Item);

   Item->Next = InterlockedExchangePointer(&Stack->Top, Item);

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}


/** Pushes a value into the stack.
 *
 *  @param Stack The stack.
 *  @param Value The value.
 *
 *  @return
 *  Returns NTSTATUS value indicating either success or failure of the operation.
 */
NTSTATUS StackPush(PUTILS_STACK Stack, PVOID Value)
{
   PUTILS_STACK_ITEM item = NULL;
   NTSTATUS status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Stack=0x%p; Value=0x%p", Stack, Value);

   item = (PUTILS_STACK_ITEM)HeapMemoryAlloc(Stack->PoolType, sizeof(UTILS_STACK_ITEM));
   if (item != NULL) {
      item->Value = Value;
      StackPushNoAlloc(Stack, item);
      status = STATUS_SUCCESS;
   } else status = STATUS_INSUFFICIENT_RESOURCES;

   DEBUG_EXIT_FUNCTION("0x%x", status);
   return status;
}


/** Pops an item from the top the stack. 
 *
 *  The routine does not free memory occupied by the stack item.
 *
 *  @param Stack The stack.
 *
 *  @return
 *  Returns address of the stack item removed from the stack. If the stack
 *  is empty, NULL is returned.
 */
PUTILS_STACK_ITEM StackPopNoFree(PUTILS_STACK Stack)
{
   PUTILS_STACK_ITEM ret = NULL;
   DEBUG_ENTER_FUNCTION("Stack=0x%p", Stack);

   ret = InterlockedExchangePointer(&Stack->Top, Stack->Top->Next);
   if (ret == (PUTILS_STACK_ITEM)&Stack->Top)
      ret = NULL;

   DEBUG_EXIT_FUNCTION("0x%p", ret);
   return ret;
}


/** Removes a value from the top of the stack.
 *
 *  @param Stack The stack.
 *
 *  @return
 *  Returns value removed from the top of the stack. The routine deallocates
 *  memory occupied by the stack item that wrapped the returned value.
 */
PVOID StackPop(PUTILS_STACK Stack)
{
   PVOID ret = NULL;
   PUTILS_STACK_ITEM item = NULL;
   DEBUG_ENTER_FUNCTION("Stack=0x%p", Stack);

   item = StackPopNoFree(Stack);
   if (item != NULL) {
      ret = item->Value;
      HeapMemoryFree(item);
   }

   DEBUG_EXIT_FUNCTION("0x%p", ret);
   return ret;
}


/** Tests whether given stack contains items.
 *
 *  @param Stack The stack.
 *
 *  @return
 *  Returns TRUE when the stack is empty and FALSE otherwise.
 */
BOOLEAN StackEmpty(PUTILS_STACK Stack)
{
   BOOLEAN ret = FALSE;
   DEBUG_ENTER_FUNCTION("Stack=0x%p", Stack);

   ret = (Stack->Top == (PUTILS_STACK_ITEM)&Stack->Top);

   DEBUG_EXIT_FUNCTION("%u", ret);
   return ret;
}


/** Destroys an instance of the stack. The stack must be empty.
 *
 *  @param Stack The stack.
 */
VOID StackDestroy(PUTILS_STACK Stack)
{
   DEBUG_ENTER_FUNCTION("Stack=0x%p", Stack);

   HeapMemoryFree(Stack);

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}
