
#ifndef __UTILS_STACK_H_
#define __UTILS_STACK_H_

/**
 * Simple and thread-safe stack implementation.
 */



#include <ntifs.h>


/** Represents one item stored in the stack. */
typedef struct _UTILS_STACK_ITEM {
   /** Next item (farer from the top). Initialized and used by the stack. */
   struct _UTILS_STACK_ITEM *Next;
   /** Value stored in the item. Initialized by the user. */
   PVOID Value;
} UTILS_STACK_ITEM, *PUTILS_STACK_ITEM;

/** Represents a stack. */
typedef struct {
   /** Top of the stack. If the stack is empty contains address of itself. */
   PUTILS_STACK_ITEM Top;
   /** Type of memory pool used to allocate stack items. */
   POOL_TYPE PoolType;
} UTILS_STACK, *PUTILS_STACK;


NTSTATUS StackCreate(POOL_TYPE PoolType, PUTILS_STACK *Stack);
VOID StackPushNoAlloc(PUTILS_STACK Stack, PUTILS_STACK_ITEM Item);
NTSTATUS StackPush(PUTILS_STACK Stack, PVOID Value);
PVOID StackPop(PUTILS_STACK Stack);
PUTILS_STACK_ITEM StackPopNoFree(PUTILS_STACK Stack);
BOOLEAN StackEmpty(PUTILS_STACK Stack);
VOID StackDestroy(PUTILS_STACK Stack);

#endif
