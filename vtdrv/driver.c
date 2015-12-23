
#include <ntifs.h>
#include "preprocessor.h"
#include "allocator.h"
#include "snapshot.h"
#include "ioctls.h"
#include "driver.h"


/************************************************************************/
/*                     FORWARD DEFINITIONS                              */
/************************************************************************/

static VOID DriverUnload(PDRIVER_OBJECT DriverObject);


/************************************************************************/
/*                        IRP DISPATCH ROUTINES                         */
/************************************************************************/

/** Dispatches IRPs of IRP_MJ_CREATE and IRP_MJ_CLOSE type. The routine
 *  counts number of handles opened to the communication device. When the
 *  number reaches zero, all existing snapshots are freed.
 */
static NTSTATUS DriverCreateClose(PDEVICE_OBJECT DeviceObject, PIRP Irp)
{
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Irp=0x%p", DeviceObject, Irp);
 
	status = STATUS_SUCCESS;
	Irp->IoStatus.Status = status;
	IoCompleteRequest(Irp, IO_NO_INCREMENT);

	DEBUG_EXIT_FUNCTION("0x%x", status);
	return status;
}


/** Services IRP_MJ_DEVICE_CONTROL requests. User mode application uses these
 *  requests to control activity of the driver.
 */
static NTSTATUS DriverDeviceControl(PDEVICE_OBJECT DeviceObject, PIRP Irp)
{
	PIO_STACK_LOCATION irpStack = NULL;
	PVOID outBuffer = NULL;
	ULONG outBufferLength = 0;
	PVOID inBuffer = NULL;
	ULONG inBufferLength = 0;
	ULONG controlCode = 0;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Irp=0x%p", DeviceObject, Irp);

	irpStack = IoGetCurrentIrpStackLocation(Irp);
	controlCode = irpStack->Parameters.DeviceIoControl.IoControlCode;
	outBufferLength = irpStack->Parameters.DeviceIoControl.OutputBufferLength;
	inBufferLength = irpStack->Parameters.DeviceIoControl.InputBufferLength;
	Irp->IoStatus.Information = 0;
	outBuffer = Irp->AssociatedIrp.SystemBuffer;
	inBuffer = Irp->AssociatedIrp.SystemBuffer;
	switch (controlCode) {
		case IOCTL_VTREE_SNAPSHOT_GET:
			if (inBufferLength == sizeof(VRTULETREE_KERNEL_SNAPSHOT_INPUT) &&
				outBufferLength == sizeof(PVRTULETREE_KERNEL_SNAPSHOT)) {
				PVRTULETREE_KERNEL_SNAPSHOT Snapshot = NULL;
				PVRTULETREE_KERNEL_SNAPSHOT_INPUT inputData = (PVRTULETREE_KERNEL_SNAPSHOT_INPUT)inBuffer;

				status = SnapshotCreate(inputData->SnapshotFlags, &Snapshot);
				if (NT_SUCCESS(status)) {
					status = SnapshotToUser(Snapshot, (PVOID *)outBuffer);
					if (NT_SUCCESS(status))
						Irp->IoStatus.Information = sizeof(PVRTULETREE_KERNEL_SNAPSHOT);
               
					SnapshotFree(Snapshot);
				}
			} else status = STATUS_BUFFER_TOO_SMALL;
			break;

		default:
			DEBUG_ERROR("Invalid device control requiest 0x%x", controlCode);
			status = STATUS_INVALID_DEVICE_REQUEST;
			break;
	}  

	Irp->IoStatus.Status = status;
	IoCompleteRequest(Irp, IO_NO_INCREMENT);

	DEBUG_EXIT_FUNCTION("0x%x", status);
	return status;
}


/************************************************************************/
/*                           DEVICE INITIALIZATION AND FINALIZATION     */
/************************************************************************/

/** Deletes the communication device.
 *
 *  @param DriverObject Address of Driver Object of the driver.
 */
static VOID DriverFinit(PDRIVER_OBJECT DriverObject)
{
	UNICODE_STRING uSymlink;
	DEBUG_ENTER_FUNCTION("DriverObject=0x%p", DriverObject);

	RtlInitUnicodeString(&uSymlink, DRIVER_SYMLINK);
	IoDeleteSymbolicLink(&uSymlink);
	IoDeleteDevice(DriverObject->DeviceObject);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


/** Creates a communication device for the driver. The device is then used
 *  by user mode application in order to collect snapshots of drivers and
 *  devices present in the system. The routine also sets up the DriverUnload
 *  procedure.
 *
 *  @param DriverObject Address of Driver Object structure, passed by the
 *  system into DriverEntry.
 *
 *  @return 
 *  Returns NTSTATUS value indicating success or failure of the operation.
 */
static NTSTATUS DriverInit(PDRIVER_OBJECT DriverObject)
{
	UNICODE_STRING uDeviceName;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DriverObject=0x%p", DriverObject);

	RtlInitUnicodeString(&uDeviceName, DRIVER_DEVICE);
	status = IoCreateDevice(DriverObject, 0, &uDeviceName, FILE_DEVICE_UNKNOWN, 0, FALSE, &DriverObject->DeviceObject);
	if (NT_SUCCESS(status)) {
		UNICODE_STRING uLinkName;

		RtlInitUnicodeString(&uLinkName, DRIVER_SYMLINK);
		status = IoCreateSymbolicLink(&uLinkName, &uDeviceName);
		if (NT_SUCCESS(status)) {
			DriverObject->DriverUnload = DriverUnload;
			DriverObject->MajorFunction[IRP_MJ_CREATE] = DriverCreateClose;
			DriverObject->MajorFunction[IRP_MJ_CLOSE] = DriverCreateClose;
			DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DriverDeviceControl;
		}

		if (!NT_SUCCESS(status))
			IoDeleteDevice(DriverObject->DeviceObject);
	}

	DEBUG_EXIT_FUNCTION("0x%x", status);
	return status;
}


/************************************************************************/
/*                        DRIVERENTRY AND DRIVERUNLOAD                  */
/************************************************************************/


/** Standard DriverUnload routine. Cleans all resources used by the
 *  driver.
 */
static VOID DriverUnload(PDRIVER_OBJECT DriverObject)
{
	DEBUG_ENTER_FUNCTION("DriverObject=0x%p", DriverObject);

	DriverFinit(DriverObject);
#ifdef _DEBUG
	DebugAllocatorModuleFinit();
#endif

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


/** Standard driver entry point. Initializes the driver.
 */
NTSTATUS DriverEntry(PDRIVER_OBJECT DriverObject, PUNICODE_STRING RegistryPath)
{
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DriverObject=0x%p; RegistryPath=%S", DriverObject, RegistryPath->Buffer);

#ifdef _DEBUG
	status = DebugAllocatorModuleInit();
#else 
	status = STATUS_SUCCESS;
#endif
	if (NT_SUCCESS(status)) {
		status = DriverInit(DriverObject);
		if (!NT_SUCCESS(status)) {
#ifdef _DEBUG
			DebugAllocatorModuleFinit();
#endif
		}
	}

	DEBUG_EXIT_FUNCTION("0x%x", status);
	return status;
}
