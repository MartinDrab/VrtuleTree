
#ifndef __VRTULETREE_SNAPSHOT_H_
#define __VRTULETREE_SNAPSHOT_H_

#include <ntifs.h>
#include "ioctls.h"




typedef struct _SNAPSHOT_DEVICE_RELATIONS_INFO {
	ULONG Count;
	ULONG Size;
	ULONG_PTR RelationsOffset;
} SNAPSHOT_DEVICE_RELATIONS_INFO, *PSNAPSHOT_DEVICE_RELATIONS_INFO;

typedef struct _SNAPSHOT_DRIVER_INFO {
	SIZE_T Size;
	PVOID ImageBase;
	ULONG32 ImageSize;
	ULONG32 Flags;
	PDRIVER_STARTIO StartIo;
	PDRIVER_INITIALIZE DriverEntry;
	PDRIVER_UNLOAD DriverUnload;
	ULONG_PTR NameOffset;
	PVOID ObjectAddress;
	ULONG_PTR NumberOfDevices;
	ULONG_PTR DevicesOffset;  
	PDRIVER_DISPATCH MajorFunctions [IRP_MJ_MAXIMUM_FUNCTION + 1];
	PVOID FastIoAddress;
	FAST_IO_DISPATCH FastIo;
} SNAPSHOT_DRIVER_INFO, *PSNAPSHOT_DRIVER_INFO;

typedef struct _SNAPSHOT_VPB_INFO {
	ULONG Size;
	ULONG Flags;
	ULONG SerialNumber;
	ULONG ReferenceCount;
	PDEVICE_OBJECT FileSystemDeviceObject;
	PDEVICE_OBJECT VolumeDeviceObject;
	ULONG_PTR VolumeLabel;
} SNAPSHOT_VPB_INFO, *PSNAPSHOT_VPB_INFO;

typedef struct _SNAPSHOT_DEVICE_ADVANCED_PNP_INFO {
	ULONG_PTR Size;
	ULONG_PTR DeviceId;
	ULONG_PTR InstanceId;
	ULONG_PTR HardwareIds;
	ULONG_PTR CompatibleIds;
	PSNAPSHOT_DEVICE_RELATIONS_INFO RemovalRelationsInfo;
	PSNAPSHOT_DEVICE_RELATIONS_INFO EjectRelationsInfo;
	DEVICE_CAPABILITIES Capabilities;
} SNAPSHOT_DEVICE_ADVANCED_PNP_INFO, *PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO;

typedef struct _SNAPSHOT_DEVICE_INFO {
	SIZE_T Size;
	ULONG_PTR NameOffset;
	PVOID ObjectAddress;
	ULONG Flags;
	ULONG Characteristics;
	ULONG DeviceType;
	ULONG_PTR NumberOfLowerDevices;
	ULONG_PTR LowerDevicesOffset;
	ULONG_PTR NumberOfUpperDevices;
	ULONG_PTR UpperDevicesOffset;
	ULONG_PTR DisplayNameOffset;
	ULONG_PTR VendorNameOffset;
	ULONG_PTR DescriptionOffset;
	ULONG_PTR EnumeratorOffset;
	ULONG_PTR LocationOffset;
	ULONG_PTR ClassNameOffset;
	ULONG_PTR ClassGuidOffset;
	PDEVICE_OBJECT DiskDevice;
	PVOID Vpb;
	PSNAPSHOT_VPB_INFO VpbInfo;
	PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO AdvancedPnPInfo;
	PSECURITY_DESCRIPTOR Security;
	PVOID DeviceNode;
	PVOID Parent;
	PVOID Child;
	PVOID Sibling;
	ULONG ExtensionFlags;
	ULONG PowerFlags;
} SNAPSHOT_DEVICE_INFO, *PSNAPSHOT_DEVICE_INFO;

typedef struct _SNAPSHOT_DRIVERLIST {
   SIZE_T Size;
   SIZE_T NumberOfDrivers;
   ULONG_PTR DriversOffset;
} SNAPSHOT_DRIVERLIST, *PSNAPSHOT_DRIVERLIST;

typedef struct _VRTULETREE_KERNEL_SNAPSHOT {
	SNAPSHOT_DRIVERLIST DriverList;
}  VRTULETREE_KERNEL_SNAPSHOT, *PVRTULETREE_KERNEL_SNAPSHOT;


NTSTATUS SnapshotCreate(_In_ ULONG SnapshotFlags, _Out_ PVRTULETREE_KERNEL_SNAPSHOT *Snapshot);
VOID SnapshotFree(_Inout_ PVRTULETREE_KERNEL_SNAPSHOT Snapshot);
NTSTATUS SnapshotToUser(_In_ PVRTULETREE_KERNEL_SNAPSHOT Snapshot, _Out_ PVOID *Address);



#endif
