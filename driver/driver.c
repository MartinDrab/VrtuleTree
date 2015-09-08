
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
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Irp=0x%p", DeviceObject, Irp);
 
   Status = STATUS_SUCCESS;
   Irp->IoStatus.Status = Status;
   IoCompleteRequest(Irp, IO_NO_INCREMENT);

   DEBUG_EXIT_FUNCTION("0x%x", Status);
   return Status;
}


/** Services IRP_MJ_DEVICE_CONTROL requests. User mode application uses these
 *  requests to control activity of the driver.
 */
static NTSTATUS DriverDeviceControl(PDEVICE_OBJECT DeviceObject, PIRP Irp)
{
   PIO_STACK_LOCATION IrpStack = NULL;
   PVOID OutBuffer = NULL;
   ULONG OutBufferLength = 0;
   PVOID InBuffer = NULL;
   ULONG InBufferLength = 0;
   ULONG ControlCode = 0;
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Irp=0x%p", DeviceObject, Irp);

   IrpStack = IoGetCurrentIrpStackLocation(Irp);
   ControlCode = IrpStack->Parameters.DeviceIoControl.IoControlCode;
   OutBufferLength = IrpStack->Parameters.DeviceIoControl.OutputBufferLength;
   InBufferLength = IrpStack->Parameters.DeviceIoControl.InputBufferLength;
   Irp->IoStatus.Information = 0;
   OutBuffer = Irp->AssociatedIrp.SystemBuffer;
   InBuffer = Irp->AssociatedIrp.SystemBuffer;
   switch (ControlCode) {
      case IOCTL_VTREE_SNAPSHOT_GET:
         if (OutBufferLength == sizeof(PVRTULETREE_KERNEL_SNAPSHOT)) {
            PVRTULETREE_KERNEL_SNAPSHOT Snapshot = NULL;

            Status = SnapshotCreate(&Snapshot);
            if (NT_SUCCESS(Status)) {
               Status = SnapshotToUser(Snapshot, (PVOID *)OutBuffer);
               if (NT_SUCCESS(Status))
                  Irp->IoStatus.Information = sizeof(PVRTULETREE_KERNEL_SNAPSHOT);
               
               SnapshotFree(Snapshot);
            }
         } else Status = STATUS_BUFFER_TOO_SMALL;
         break;

      default:
         DEBUG_ERROR("Invalid device control requiest 0x%x", ControlCode);
         Status = STATUS_INVALID_DEVICE_REQUEST;
         break;
   }  

   Irp->IoStatus.Status = Status;
   IoCompleteRequest(Irp, IO_NO_INCREMENT);

   DEBUG_EXIT_FUNCTION("0x%x", Status);
   return Status;
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
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("DriverObject=0x%p", DriverObject);

   RtlInitUnicodeString(&uDeviceName, DRIVER_DEVICE);
   Status = IoCreateDevice(DriverObject, 0, &uDeviceName, FILE_DEVICE_UNKNOWN, 0, FALSE, &DriverObject->DeviceObject);
   if (NT_SUCCESS(Status)) {
      UNICODE_STRING uLinkName;

      RtlInitUnicodeString(&uLinkName, DRIVER_SYMLINK);
      Status = IoCreateSymbolicLink(&uLinkName, &uDeviceName);
      if (NT_SUCCESS(Status)) {
         DriverObject->DriverUnload = DriverUnload;
         DriverObject->MajorFunction[IRP_MJ_CREATE] = DriverCreateClose;
         DriverObject->MajorFunction[IRP_MJ_CLOSE] = DriverCreateClose;
         DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DriverDeviceControl;
      }

      if (!NT_SUCCESS(Status)) {
         IoDeleteDevice(DriverObject->DeviceObject);
      }
   }

   DEBUG_EXIT_FUNCTION("0x%x", Status);
   return Status;
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
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("DriverObject=0x%p; RegistryPath=%S", DriverObject, RegistryPath->Buffer);

#ifdef _DEBUG
   Status = DebugAllocatorModuleInit();
#else 
   Status = STATUS_SUCCESS;
#endif
   if (NT_SUCCESS(Status)) {
      Status = DriverInit(DriverObject);
      if (!NT_SUCCESS(Status)) {
#ifdef _DEBUG
         DebugAllocatorModuleFinit();
#endif
      }
   }

   DEBUG_EXIT_FUNCTION("0x%x", Status);
   return Status;
}
