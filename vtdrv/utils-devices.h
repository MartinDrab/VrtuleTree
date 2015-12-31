
#ifndef __VRTULETREE_UTILS_H_
#define __VRTULETREE_UTILS_H_

/**
 * A bunch of routines useful when enumerating device drivers, their devices and
 * determining additional information about them.
 */


#include <ntifs.h>


typedef struct _DEVICE_NODE_PART {
	struct _DEVICE_NODE_PART *Sibling;
	struct _DEVICE_NODE_PART *Child;
	struct _DEVICE_NODE_PART *Parent;
} DEVICE_NODE_PART, *PDEVICE_NODE_PART;



/************************************************************************/
/*                                  PUBLIC ROUTINE HEADERS              */
/************************************************************************/

NTSTATUS _GetDeviceGUIDProperty(PDEVICE_OBJECT DeviceObject, DEVICE_REGISTRY_PROPERTY Property, PGUID Value);
NTSTATUS _GetWCharDeviceProperty(PDEVICE_OBJECT DeviceObject, DEVICE_REGISTRY_PROPERTY Property, PWCHAR *Buffer, PULONG BufferLength);
VOID _ReleaseDriverArray(PDRIVER_OBJECT *DriverArray, SIZE_T DriverCount);
VOID _ReleaseDeviceArray(PDEVICE_OBJECT *DeviceArray, SIZE_T ArrayLength);
NTSTATUS _GetObjectName(PVOID Object, PUNICODE_STRING Name);
NTSTATUS _GetDriversInDirectory(PUNICODE_STRING Directory, PDRIVER_OBJECT **DriverArray, PSIZE_T DriverCount);
NTSTATUS _GetLowerUpperDevices(PDEVICE_OBJECT DeviceObject, BOOLEAN Upper, PDEVICE_OBJECT **DeviceArray, PSIZE_T ArrayLength);
NTSTATUS _EnumDriverDevices(PDRIVER_OBJECT DriverObject, PDEVICE_OBJECT **DeviceArray, PULONG DeviceArrayLength);

NTSTATUS _QueryDeviceRelations(PDEVICE_OBJECT DeviceObject, DEVICE_RELATION_TYPE RelationType, PDEVICE_OBJECT **Relations, PULONG Count);
NTSTATUS UtilsQueryDeviceId(PDEVICE_OBJECT DeviceObject, BUS_QUERY_ID_TYPE IdType, PWCHAR *Id);
NTSTATUS UtilsQueryDeviceCapabilities(PDEVICE_OBJECT DeviceObject, PDEVICE_CAPABILITIES Capabilities);


#endif
