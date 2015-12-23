
#include <ntifs.h>
#include "preprocessor.h"
#include "utils-mem.h"
#include "utils-dym-array.h"
#include "utils-devices.h"


/************************************************************************/
/*                       IMPORTS                                        */
/************************************************************************/

/** Definition of ZwQueryDirectoryObject. */
typedef NTSTATUS (NTAPI ZWQUERYDIRECTORYOBJECT)(
   HANDLE DirectoryHandle,
   PVOID Buffer,
   ULONG Length,
   BOOLEAN ReturnSingleEntry,
   BOOLEAN RestartScan,
   PULONG Context,
   PULONG ReturnLength);

/** Definition of ObReferenceObjectByName */
typedef NTSTATUS (NTAPI OBREFERENCEOBJECTBYNAME) (
   PUNICODE_STRING ObjectPath,
   ULONG Attributes,
   PACCESS_STATE PassedAccessState OPTIONAL,
   ACCESS_MASK DesiredAccess OPTIONAL,
   POBJECT_TYPE ObjectType,
   KPROCESSOR_MODE AccessMode,
   PVOID ParseContext OPTIONAL,
   PVOID *ObjectPtr); 


/** Buffer returned by ZwQueryDirectoryObject is full of these
    structures. */
typedef struct _OBJECT_DIRECTORY_INFORMATION {
   /** Name of the object. */
   UNICODE_STRING Name;
   /** type of the object (string form). */
   UNICODE_STRING TypeName;
} OBJECT_DIRECTORY_INFORMATION, *POBJECT_DIRECTORY_INFORMATION;


/** ZwQueryDirectoryObject import. */
__declspec(dllimport) ZWQUERYDIRECTORYOBJECT ZwQueryDirectoryObject;
/** ObReferenceObjectByName import. */
__declspec(dllimport) OBREFERENCEOBJECTBYNAME ObReferenceObjectByName;
/** IoDriverObjectType import. */
__declspec(dllimport) POBJECT_TYPE *IoDriverObjectType;


/** Retrieves a property from the registry keys of given device. The property
 *  data must be a GUID.
 *
 *  @param DeviceObject Address of Device Object which property should be queried.
 *  @param Property Property to query.
 *  @param Value Address of GUID variable that, when the routine succeeds, 
 *  receives data of the property in a form of GUID.
 *
 *  @return 
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS _GetDeviceGUIDProperty(PDEVICE_OBJECT DeviceObject, DEVICE_REGISTRY_PROPERTY Property, PGUID Value)
{
   ULONG ReturnLength = 0;
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Property=%u; Value=0x%p", DeviceObject, Property, Value);

   RtlZeroMemory(Value, sizeof(GUID));
   Status = IoGetDeviceProperty(DeviceObject, Property, sizeof(GUID), Value, &ReturnLength);
   if (Status == STATUS_INVALID_DEVICE_REQUEST ||
      Status == STATUS_OBJECT_NAME_NOT_FOUND)
      Status = STATUS_SUCCESS;

   DEBUG_EXIT_FUNCTION("0x%x", Status);
   return Status;
}


/** Retrieves a property from the registry keys of given device. The property
 *  data must be a wide-character string.
 *
 *  @param DeviceObject Address of Device Object which property should be queried.
 *  @param Property Property to query.
 *  @param Buffer Address of variable that, when the routine succeeds, 
 *  receives data of the property in a form of a wide character string.
 *  The routine allocates storage for the string. When the string is no longer needed,
 *  it must be freed by a call to HeapMemoryFree.
 *  @param BufferLength Address of variable that, in case of success, receives.
 *  the length of buffer allocated to store the property data.
 *
 *  @return 
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS _GetWCharDeviceProperty(PDEVICE_OBJECT DeviceObject, DEVICE_REGISTRY_PROPERTY Property, PWCHAR *Buffer, PULONG BufferLength)
{
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   PVOID Tmp = NULL;
   ULONG TmpSize = 64;
   DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Property=%u; Buffer=0x%p; BufferLength=0x%p", DeviceObject, Property, Buffer, BufferLength);

   do {
      if (Tmp != NULL) {
         HeapMemoryFree(Tmp);
         Tmp = NULL;
      }

      Tmp = HeapMemoryAllocPaged(TmpSize);
      if (Tmp != NULL) {
         Status = IoGetDeviceProperty(DeviceObject, Property, TmpSize, Tmp, &TmpSize);
         if (NT_SUCCESS(Status)) {
            *BufferLength = TmpSize;
            *Buffer = Tmp;
         }
      } else Status = STATUS_INSUFFICIENT_RESOURCES;
   } while (Status == STATUS_BUFFER_TOO_SMALL);

   if (!NT_SUCCESS(Status)) {
      if (Tmp != NULL)
         HeapMemoryFree(Tmp);

      if (Status == STATUS_INVALID_DEVICE_REQUEST || 
         Status == STATUS_OBJECT_NAME_NOT_FOUND) {
            *BufferLength = 0;
            Status = STATUS_SUCCESS;
      } else {
         *Buffer = NULL;
         *BufferLength = 0;
      }
   }

   DEBUG_EXIT_FUNCTION("0x%x, *Buffer=0x%p, *BufferLength=%u", Status, *Buffer, *BufferLength);
   return Status;
}


/** Frees resources occupied by the array of pointers to DRIVER_OBJECT
 *  structures. Every object in the array is dereferenced and the array
 *  is freed.
 *
 *  @param DriverArray Address of the array.
 *  @param DriverCount Number of elements in the array.
 */
VOID _ReleaseDriverArray(PDRIVER_OBJECT *DriverArray, SIZE_T DriverCount)
{
	SIZE_T i = 0;
	DEBUG_ENTER_FUNCTION("DriverArray=0x%p; DriverCount=%u", DriverArray, DriverCount);

	if (DriverCount > 0) {
		for (i = 0; i < DriverCount; ++i)
			ObDereferenceObject(DriverArray[i]);
	}

	if (DriverArray != NULL)
		HeapMemoryFree(DriverArray);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


/** Frees resources occupied by the array of pointers to DEVICE_OBJECT
 *  structures. Every object in the array is dereferenced and the array
 *  is freed.
 *
 *  @param DriverArray Address of the array.
 *  @param DriverCount Number of elements in the array.
 */
VOID _ReleaseDeviceArray(PDEVICE_OBJECT *DeviceArray, SIZE_T ArrayLength)
{
	SIZE_T i = 0;
	DEBUG_ENTER_FUNCTION("DeviceArray=0x%p; ArrayLength=%u", DeviceArray, ArrayLength);

	if (ArrayLength > 0) {
		for (i = 0; i < ArrayLength; ++i)
			ObDereferenceObject(DeviceArray[i]);
	}

	if (DeviceArray != NULL)
		HeapMemoryFree(DeviceArray);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


/** Retrieves name of the object via ObQueryNameString.
 *
 *  @param Object Address of object which name should be retrieved.
 *  @param Name Pointer to UNICODE_STRING structure which the routine fills
 *  with the name (of course only if the routine succeeds). The routine
 *  allocates storage for the string and store address of the storage in
 *  the Buffer member of the UNICODE_STRING structure. The caller must
 *  deallocate the storage via HeapMemoryFree when it no longer needs the string.
 *  The storage is allocated from paged pool.
 *
 *  @return 
 *  Returns NTSTATUS value indicating success or failure of the operation. 
 *
 */
NTSTATUS _GetObjectName(PVOID Object, PUNICODE_STRING Name)
{
   ULONG oniLength = 0;
   POBJECT_NAME_INFORMATION oni = NULL;
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Object=0x%p, Name=0x%p", Object, Name);

   RtlZeroMemory(Name, sizeof(UNICODE_STRING));
   Status = ObQueryNameString(Object, oni, oniLength, &oniLength);
   while (Status == STATUS_INFO_LENGTH_MISMATCH) {
      oni = (POBJECT_NAME_INFORMATION)HeapMemoryAllocNonPaged(oniLength);
      if (oni != NULL) {
         Status = ObQueryNameString(Object, oni, oniLength, &oniLength);
         if (NT_SUCCESS(Status))
            *Name = oni->Name;

         if (!NT_SUCCESS(Status)) {
            HeapMemoryFree(oni);
            oni = NULL;
         }
      } else Status = STATUS_INSUFFICIENT_RESOURCES;
   }

   if (NT_SUCCESS(Status)) {
      PWCHAR Tmp = NULL;

      Tmp = (PWCHAR)HeapMemoryAllocPaged(Name->Length + sizeof(WCHAR));
      if (Tmp != NULL) {
         RtlCopyMemory(Tmp, Name->Buffer, Name->Length);
         Tmp[Name->Length / sizeof(WCHAR)] = L'\0';
         Name->Buffer = Tmp;
         HeapMemoryFree(oni);
      } else Status = STATUS_INSUFFICIENT_RESOURCES;
   }

   if (!NT_SUCCESS(Status)) {
      if (oni != NULL)
         HeapMemoryFree(oni);

      RtlZeroMemory(Name, sizeof(UNICODE_STRING));
   }

   DEBUG_EXIT_FUNCTION("0x%x, *Name=%S", Status, Name->Buffer);
   return Status;
}


/** Appends object name to the name of directory, so the resulting name forms
 *  absolute path to the object. The routine adds a backslash between the 
 *  directory name and the object name.
 *
 *  @param Dest The routine fills the UNICODE_STRING structure with the 
 *  resulting name. The storage for the string is allocated from paged pool
 *  and must be deallocated by the caller when no longer needed.
 *  @param Src1 UNICODE_STRING that contains (absolute) name of the directory.
 *  @param Src2 UNICODE_STRING taht contains name of the object.
 *
 *  @return 
 * Returns NTSTATUS value indicating success or failure of the operation.
 */
static NTSTATUS _AppendDriverNameToDirectory(PUNICODE_STRING Dest, PUNICODE_STRING Src1, PUNICODE_STRING Src2)
{
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Dest=0x%p; Src1=\"%S\"; Src2=\"%S\"", Dest, Src1->Buffer, Src2->Buffer);

   Dest->Length = Src1->Length + sizeof(WCHAR) + Src2->Length;
   Dest->MaximumLength = Dest->Length;
   Dest->Buffer = (PWSTR)HeapMemoryAllocPaged(Dest->Length + sizeof(WCHAR));
   if (Dest->Buffer != NULL) {
      RtlZeroMemory(Dest->Buffer, Dest->Length + sizeof(WCHAR));
      RtlCopyMemory(Dest->Buffer, Src1->Buffer, Src1->Length);
      Dest->Buffer[Src1->Length / sizeof(WCHAR)] = L'\\';
      RtlCopyMemory(&Dest->Buffer[(Src1->Length / sizeof(WCHAR)) + 1], Src2->Buffer, Src2->Length);
      Status = STATUS_SUCCESS;
   } else Status = STATUS_INSUFFICIENT_RESOURCES;

   DEBUG_EXIT_FUNCTION("0x%x, *Dest=%S", Status, Dest->Buffer);
   return Status;
}


/** Retrieves all drivers in given object directory in a form of
 *  pointers to their DRIVER_OBJECT structures. The routine increases the
 *  reference count of every Driver Object reported to the caller by one.
 *
 *  @param Name of the directory in absolute form.
 *  @param DriverArray Address of variable that, when the function succeeds,
 *  receives address of array of pointers to DRIVER_OBJECT structures of the
 *  drivers located in object directory given in the first argument. When
 *  the caller no longer uses the array, it should release it by call to
 *  _ReleaseDriverArray routine. If _GetDriversInDirectory routine fails, the variable is
 *  filled with NULL.
 *  @param DriverCount Address of variable that, in case the routine succeeds,
 *  is filled with the number of elements in the array returned in the second
 *  parameter. If the function fails, the variable is filled with zero.
 *
 *  @return 
 * Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS _GetDriversInDirectory(PUNICODE_STRING Directory, PDRIVER_OBJECT **DriverArray, PSIZE_T DriverCount)
{
	PDRIVER_OBJECT *TmpDriverArray = NULL;
	PUTILS_DYM_ARRAY DriverDymArray = NULL;
	HANDLE DirectoryHandle;
	OBJECT_ATTRIBUTES ObjectAttributes;
	NTSTATUS Status = STATUS_UNSUCCESSFUL;
	UNICODE_STRING DriverTypeStr;
	DEBUG_ENTER_FUNCTION("Directory=%S; DriverArray=0x%p; DriverCount=0x%p", Directory->Buffer, DriverArray, DriverCount);

	*DriverCount = 0;
	*DriverArray = NULL;
	Status = DymArrayCreate(PagedPool, &DriverDymArray);
	if (NT_SUCCESS(Status)) {
		// Initialize string with the name of Driver Object Type.
		RtlInitUnicodeString(&DriverTypeStr, L"Driver");
		// Open the object directory specified in the first argument.
		InitializeObjectAttributes(&ObjectAttributes, Directory, OBJ_CASE_INSENSITIVE, NULL, NULL);
		Status = ZwOpenDirectoryObject(&DirectoryHandle, DIRECTORY_QUERY, &ObjectAttributes);
		if (NT_SUCCESS(Status)) {
			ULONG QueryContext = 0;
			// Assume that no directory entry exceeds 1024 bytes in length.
			UCHAR Buffer [1024];
			POBJECT_DIRECTORY_INFORMATION DirInfo = (POBJECT_DIRECTORY_INFORMATION)&Buffer;

			// Attempt to list contents of the directory, filter everything except drivers out,
			// and add the information to the array.
			do {
				memset(&Buffer, 0, sizeof(Buffer));
				Status = ZwQueryDirectoryObject(DirectoryHandle, DirInfo, sizeof(Buffer), TRUE, FALSE, &QueryContext, NULL);
				if (NT_SUCCESS(Status)) {
					// A directory entry has been retrieved. Check whether it represents
					// a Driver Object.
					if (RtlCompareUnicodeString(&DirInfo->TypeName, &DriverTypeStr, TRUE) == 0) {
						UNICODE_STRING FullDriverName;

						// Format the full name of the driver.
						Status = _AppendDriverNameToDirectory(&FullDriverName, Directory, &DirInfo->Name);
						if (NT_SUCCESS(Status)) {
							PDRIVER_OBJECT DriverPtr = NULL;

							// Get the address of corresponding DIRVER_OBJECT structure and
							// increase its reference count by one. ObReferenceObjectByName will
							// do the job.
							Status = ObReferenceObjectByName(&FullDriverName, OBJ_CASE_INSENSITIVE, NULL, GENERIC_READ, *IoDriverObjectType, KernelMode, NULL, (PVOID *)&DriverPtr);
							if (NT_SUCCESS(Status)) {
								Status = DymArrayPushBack(DriverDymArray, DriverPtr);
								if (!NT_SUCCESS(Status))
									ObDereferenceObject(DriverPtr);
							}

							HeapMemoryFree(FullDriverName.Buffer);
						}
					}
				}
			} while (NT_SUCCESS(Status));

			if (Status == STATUS_NO_MORE_ENTRIES) {
				Status = DymArrayToStaticArrayAlloc(DriverDymArray, PagedPool, (PVOID *)&TmpDriverArray);
				if (NT_SUCCESS(Status)) {
					// The object directory has been successfully traversed.
					// Report success and return the array and number of its elements
					// in the second and the third parameters.
					*DriverCount = DymArrayLength(DriverDymArray);            
					*DriverArray = TmpDriverArray;
				}
			}
         
			if (!NT_SUCCESS(Status)) {
				ULONG i = 0;

				for (i = 0; i < DymArrayLength(DriverDymArray); ++i)
					ObDereferenceObject(DymArrayItem(DriverDymArray, i));
			}

			ZwClose(DirectoryHandle);
		}
   
		DymArrayDestroy(DriverDymArray);
	}

	DEBUG_EXIT_FUNCTION("0x%x, *DriverArray=0x%p, *DriverCount=%u", Status, *DriverArray, *DriverCount);
	return Status;
}


/** Retrieves device objects placed lower or upper in the given device's stack.
 *  Reference count of every reported Device object is increased by one.
 *
 *  @param DeviceObject Device which device stack should be examined.
 *  @param Upper Determines the direction of device stack examination. If set to TRUE,
 *  the routine attempts to report upper devices. If set to FALSE, only lower devices
 *  are reported.
 *  @param DeviceArray Address of variable that, when the function succeeds,
 *  is filled address of array of pointers to DEVICE_OBJECT structures. The
 *  array is allocated from paged memory and should be freed by call to
 *  _ReleaseDeviceArray when no longer needed. When _GetLowerUpperDevices fails,
 *  the variable is filled with NULL.
 *  @param ArrayLength Address of variable that, in case of success, receives
 *  number of elements inside array reported through the third parameter. If
 *  the function fails, the variable is filled with zero.
 *
 *  @return 
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS _GetLowerUpperDevices(PDEVICE_OBJECT DeviceObject, BOOLEAN Upper, PDEVICE_OBJECT **DeviceArray, PSIZE_T ArrayLength)
{
   PUTILS_DYM_ARRAY DymDeviceArray = NULL;
   PDEVICE_OBJECT *TmpDeviceArray = NULL;
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   PDEVICE_OBJECT TmpDeviceObject = NULL;
   PDEVICE_OBJECT OldTmpDeviceObject = NULL;
   DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Upper=%u; DeviceArray=0x%p; ArrayLength=0x%p", DeviceObject, Upper, DeviceArray, ArrayLength);

   *DeviceArray = NULL;
   *ArrayLength = 0;
   Status = DymArrayCreate(NonPagedPool, &DymDeviceArray);
   if (NT_SUCCESS(Status)) {
      TmpDeviceObject = Upper ? IoGetAttachedDeviceReference(DeviceObject) : IoGetLowerDeviceObject(DeviceObject);
      while (((Upper && TmpDeviceObject != DeviceObject) || (!Upper && TmpDeviceObject != NULL)) && NT_SUCCESS(Status)) {
         OldTmpDeviceObject = TmpDeviceObject;
         Status = DymArrayPushBack(DymDeviceArray, OldTmpDeviceObject);
         if (!NT_SUCCESS(Status)) {
            ObDereferenceObject(OldTmpDeviceObject);
            break;
         }

         TmpDeviceObject = IoGetLowerDeviceObject(TmpDeviceObject);
         if (TmpDeviceObject == NULL)
            break;
      }

      if (NT_SUCCESS(Status)) {
         if (TmpDeviceObject == DeviceObject)
            ObDereferenceObject(TmpDeviceObject);

         Status = DymArrayToStaticArrayAlloc(DymDeviceArray, NonPagedPool, (PVOID *)&TmpDeviceArray);
         if (NT_SUCCESS(Status)) {
            // The device stack has been successfully traversed. report the
            // success and retrieve the device array and number of its elements.
            *DeviceArray = TmpDeviceArray;
            *ArrayLength = DymArrayLength(DymDeviceArray);
         }
      }

      if (!NT_SUCCESS(Status)) {
         ULONG i = 0;

         for (i = 0; i < DymArrayLength(DymDeviceArray); ++i)
            ObDereferenceObject(DymArrayItem(DymDeviceArray, i));
      }
   
      DymArrayDestroy(DymDeviceArray);
   }

   DEBUG_EXIT_FUNCTION("0x%x, *DeviceArray=0x%p, *ArrayLength=%u", Status, *DeviceArray, *ArrayLength);
   return Status;
}


/** Enumerates devices of given driver. The devices are returned in form of
 *  array of pointers to DEVICE_OBJECT structures. Reference count of every
 *  device object reported by the routine is increased by one.
 *
 *  @param DriverObject Driver which devices should be enumerated.
 *  @param DeviceArray Address of variable that, in case of success, receives
 *  address of array of pointer to DEVICE_OBJECT structures. The array is allocated
 *  from nonpaged memory and must be released by _ReleaseDeviceArray when no longer
 *  needed. When _EnumDriverDevices fails, the variable is filled with NULL.
 *  @param DeviceArrayLength Address of variable that, in case of success, receives
 *  number of elements in the array retrieved in the second parameter. When the
 *  function fails, the variable is filled with zero.
 *
 *  @return 
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
NTSTATUS _EnumDriverDevices(PDRIVER_OBJECT DriverObject, PDEVICE_OBJECT **DeviceArray, PULONG DeviceArrayLength)
{
   ULONG TmpArrayLength = 0;
   PDEVICE_OBJECT *TmpDeviceArray = NULL;
   NTSTATUS Status = STATUS_SUCCESS;
   DEBUG_ENTER_FUNCTION("DriverObject=0x%p; DeviceArray=0x%p; DeviceArrayLength=0x%p", DriverObject, DeviceArray, DeviceArrayLength);

   do {
      Status = IoEnumerateDeviceObjectList(DriverObject, TmpDeviceArray, TmpArrayLength * sizeof(PDEVICE_OBJECT), &TmpArrayLength);
      if (Status == STATUS_BUFFER_TOO_SMALL) {
         if (TmpDeviceArray != NULL)
            HeapMemoryFree(TmpDeviceArray);

         TmpDeviceArray = (PDEVICE_OBJECT *)HeapMemoryAllocNonPaged(TmpArrayLength * sizeof(PDEVICE_OBJECT));
         if (TmpDeviceArray == NULL)
            Status = STATUS_INSUFFICIENT_RESOURCES;
      }
   } while (Status == STATUS_BUFFER_TOO_SMALL);

   if (NT_SUCCESS(Status)) {
      *DeviceArrayLength = TmpArrayLength;
      *DeviceArray = TmpDeviceArray;
   }

   DEBUG_EXIT_FUNCTION("0x%x, *DeviceArray=0x%p, *DeviceArrayLength=%u", *DeviceArray, *DeviceArrayLength);
   return Status;
}


typedef struct {
	KEVENT CompletionEvent;
	NTSTATUS CompletionStatus;
	PDEVICE_OBJECT TargetDevice;
	DEVICE_RELATION_TYPE RelationType;
	PDEVICE_OBJECT *RelationArray;
	ULONG RelationCount;
} QUERY_DEVICE_RELATIONS_CONTEXT, *PQUERY_DEVICE_RELATIONS_CONTEXT;

static VOID _QueryDeviceRelationsWorker(PVOID Context)
{
	PIRP irp = NULL;
	PIO_STACK_LOCATION irpStack = NULL;
	PDEVICE_RELATIONS relations = NULL;
	ULONG tmpCount = 0;
	PDEVICE_OBJECT *tmpArray = NULL;
	KEVENT event;
	IO_STATUS_BLOCK iosb;
	PDEVICE_OBJECT targetDeviceObject = NULL;
	PQUERY_DEVICE_RELATIONS_CONTEXT qdrc = (PQUERY_DEVICE_RELATIONS_CONTEXT)Context;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("Context=0x%p", Context);

	targetDeviceObject = IoGetAttachedDeviceReference(qdrc->TargetDevice);
	iosb.Information = 0;
	iosb.Status = STATUS_NOT_SUPPORTED;
	KeInitializeEvent(&event, NotificationEvent, FALSE);
	irp = IoBuildSynchronousFsdRequest(IRP_MJ_PNP, targetDeviceObject, NULL, 0, NULL, &event, &iosb);
	if (irp != NULL) {
		irpStack = IoGetNextIrpStackLocation(irp);
		irpStack->MinorFunction = IRP_MN_QUERY_DEVICE_RELATIONS;
		irpStack->Parameters.QueryDeviceRelations.Type = qdrc->RelationType;
		status = IoCallDriver(targetDeviceObject, irp);
		if (status == STATUS_PENDING) {
			(VOID) KeWaitForSingleObject(&event, Executive, KernelMode, FALSE, NULL);
			status = iosb.Status;
		}

		if (NT_SUCCESS(status)) {
			relations = (PDEVICE_RELATIONS)iosb.Information;
			tmpCount = (relations != NULL) ? relations->Count : 0;
			if (tmpCount > 0) {
				tmpArray = (PDEVICE_OBJECT *)HeapMemoryAllocNonPaged(sizeof(PDEVICE_OBJECT)*tmpCount);
				if (tmpArray != NULL)
					memcpy(tmpArray, &relations->Objects, tmpCount*sizeof(PDEVICE_OBJECT));
				else status = STATUS_INSUFFICIENT_RESOURCES;
			}

			if (NT_SUCCESS(status)) {
				qdrc->RelationArray = tmpArray;
				qdrc->RelationCount = tmpCount;
			}

			if (relations != NULL) {
				ULONG i = 0;

				if (!NT_SUCCESS(status)) {
					for (i = 0; i < relations->Count; ++i)
						ObDereferenceObject(relations->Objects[i]);
				}

				ExFreePool(relations);
			}
		}
	} else status = STATUS_INSUFFICIENT_RESOURCES;

	ObDereferenceObject(targetDeviceObject);
	qdrc->CompletionStatus = status;
	KeSetEvent(&qdrc->CompletionEvent, IO_NO_INCREMENT, FALSE);

	DEBUG_EXIT_FUNCTION("0x%x, *Relations=0x%p, *Count=%u", status, qdrc->RelationArray, qdrc->RelationCount);
	return;
}


NTSTATUS _QueryDeviceRelations(PDEVICE_OBJECT DeviceObject, DEVICE_RELATION_TYPE RelationType, PDEVICE_OBJECT **Relations, PULONG Count)
{
	WORK_QUEUE_ITEM workItem;
	QUERY_DEVICE_RELATIONS_CONTEXT qdrc = {0};
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; RelationType=0x%p; Relations=0x%p; Count=0x%p", DeviceObject, RelationType, Relations, Count);

	KeInitializeEvent(&qdrc.CompletionEvent, NotificationEvent, FALSE);
	qdrc.CompletionStatus = STATUS_NOT_SUPPORTED;
	qdrc.RelationArray = NULL;
	qdrc.RelationCount = 0;
	qdrc.RelationType = RelationType;
	qdrc.TargetDevice = DeviceObject;
	if (PsGetCurrentProcess() != PsInitialSystemProcess) {
		ExInitializeWorkItem(&workItem, _QueryDeviceRelationsWorker, &qdrc);
		ExQueueWorkItem(&workItem, DelayedWorkQueue);
		(VOID) KeWaitForSingleObject(&qdrc.CompletionEvent, Executive, KernelMode, FALSE, NULL);
	} else _QueryDeviceRelationsWorker(&qdrc);

	status = qdrc.CompletionStatus;
	*Relations = qdrc.RelationArray;
	*Count = qdrc.RelationCount;

	DEBUG_EXIT_FUNCTION("0x%x, *Relations=0x%p, *Count=%u", status, *Relations, *Count);
	return status;
}


NTSTATUS UtilsQueryDeviceId(PDEVICE_OBJECT DeviceObject, BUS_QUERY_ID_TYPE IdType, PWCHAR *Id)
{
	PIRP irp = NULL;
	PIO_STACK_LOCATION irpStack = NULL;
	IO_STATUS_BLOCK iosb;
	KEVENT event;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; IdType=%u; Id=0x%p", DeviceObject, IdType, Id);

	DeviceObject = IoGetAttachedDeviceReference(DeviceObject);
	irp = IoBuildSynchronousFsdRequest(IRP_MJ_PNP, DeviceObject, NULL, 0, NULL, &event, &iosb);
	if (irp != NULL) {
		iosb.Status = STATUS_NOT_SUPPORTED;
		iosb.Information = 0;
		KeInitializeEvent(&event, NotificationEvent, FALSE);
		irpStack = IoGetNextIrpStackLocation(irp);
		irpStack->MinorFunction = IRP_MN_QUERY_ID;
		irpStack->Parameters.QueryId.IdType = IdType;
		status = IoCallDriver(DeviceObject, irp);
		if (status == STATUS_PENDING) {
			(VOID) KeWaitForSingleObject(&event, Executive, KernelMode, FALSE, NULL);
			status = iosb.Status;
		}

		if (NT_SUCCESS(status))
			*Id = (PWCHAR)iosb.Information;
	} else status = STATUS_INSUFFICIENT_RESOURCES;

	ObDereferenceObject(DeviceObject);

	DEBUG_EXIT_FUNCTION("0x%x; *Id=\"%S\"", status, *Id);
	return status;
}


NTSTATUS UtilsQueryDeviceCapabilities(PDEVICE_OBJECT DeviceObject, PDEVICE_CAPABILITIES Capabilities)
{
	PIRP irp = NULL;
	PIO_STACK_LOCATION irpStack = NULL;
	IO_STATUS_BLOCK iosb;
	KEVENT event;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Capabilities=0x%p", DeviceObject, Capabilities);

	DeviceObject = IoGetAttachedDeviceReference(DeviceObject);
	irp = IoBuildSynchronousFsdRequest(IRP_MJ_PNP, DeviceObject, NULL, 0, NULL, &event, &iosb);
	if (irp != NULL) {
		iosb.Status = STATUS_NOT_SUPPORTED;
		iosb.Information = 0;
		KeInitializeEvent(&event, NotificationEvent, FALSE);
		irpStack = IoGetNextIrpStackLocation(irp);
		irpStack->MinorFunction = IRP_MN_QUERY_CAPABILITIES;
		irpStack->Parameters.DeviceCapabilities.Capabilities = Capabilities;
		status = IoCallDriver(DeviceObject, irp);
		if (status == STATUS_PENDING) {
			(VOID) KeWaitForSingleObject(&event, Executive, KernelMode, FALSE, NULL);
			status = iosb.Status;
		}
	} else status = STATUS_INSUFFICIENT_RESOURCES;

	ObDereferenceObject(DeviceObject);

	DEBUG_EXIT_FUNCTION("0x%x", status);
	return status;
}
