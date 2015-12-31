
#include <ntifs.h>
#include "preprocessor.h"
#include "driver.h"
#include "utils-devices.h"
#include "utils-mem.h"
#include "snapshot.h"




/************************************************************************/
/* DRIVERLIST SNAPSHOT HELPER ROUTINES                                                                     */
/************************************************************************/

/** Creates Driver List structure that describes a list of drivers in the
 *  snapshot. On input, the routine accepts DRIVER_OBJECT structures of the
 *  drivers it should include within the snapshot.
 *
 *  @param DriverArrays An array of arrays of PDRIVER_OBJECT pointers. For
 *  example, every array of the pointers might contain Driver Objects from
 *  one directory.
 *  @param ArrayLengths Number of elements in the arrays of Driver Object
 *  pointers.
 *  @param ItemCount Number of arrays of Driver Object pointers.
 *  @param DriverList Pointer to variable that, in case the routine succeeds,
 *  receives address of newly created Driver List structure. If the routine
 *  fails, the parameter is filled with NULL.
 *
 *  @return Returns NTSTATUS value indicating either success or failure of
 *  the operation.
 */
static NTSTATUS _DriverListNodeCreate(_In_ PDRIVER_OBJECT **DriverArrays, _In_ PSIZE_T ArrayLengths, _In_ SIZE_T ItemCount, _Out_ PSNAPSHOT_DRIVERLIST *DriverList)
{
	SIZE_T i = 0;
	ULONG_PTR driverCount = 0;
	PSNAPSHOT_DRIVERLIST tmpDriverList = NULL;
	SIZE_T driverListSize = 0;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DriverArrays=0x%p; ArrayLengths=0x%p; ItemCount=%u; DriverList=0x%p", DriverArrays, ArrayLengths, ItemCount, DriverList);

	*DriverList = NULL;
	// Compute the total number of Driver Object pointers stored inside
	// the arrays
	for (i = 0; i < ItemCount; ++i) 
	   driverCount += ArrayLengths[i];
   
	// Compute the total size of the new Driver List structure and allocate
	// storage for it. 
	driverListSize = sizeof(SNAPSHOT_DRIVERLIST) + driverCount * sizeof(PVOID);
	tmpDriverList = (PSNAPSHOT_DRIVERLIST)HeapMemoryAllocPaged(driverListSize);
	if (tmpDriverList != NULL) {
		PDRIVER_OBJECT *oneDriverArray = NULL;
      
		// Initialize the structure
		tmpDriverList->Size = driverListSize;
		tmpDriverList->NumberOfDrivers = driverCount;
		tmpDriverList->DriversOffset = sizeof(SNAPSHOT_DRIVERLIST);
		oneDriverArray = (PDRIVER_OBJECT *)((PUCHAR)tmpDriverList + tmpDriverList->DriversOffset);
		// Copy addresses of Driver Objects from the arrays
		for (i = 0; i < ItemCount; ++i) {
			memcpy(oneDriverArray, DriverArrays[i], ArrayLengths[i] * sizeof(PDRIVER_OBJECT));
			oneDriverArray += ArrayLengths[i];
		}

		// Report success and fill the output argument
		status = STATUS_SUCCESS;
		*DriverList = tmpDriverList;
	} else status = STATUS_INSUFFICIENT_RESOURCES;

	DEBUG_EXIT_FUNCTION("0x%x, *DriverList=0x%p", status, *DriverList);
	return status;
}


/************************************************************************/
/* DEVICEINFO SNAPSHOT HELPER ROUTINES                                                                     */
/************************************************************************/

/** Retrieves PnP information about a device object. The data are
 *  retrieved from the registry.
 *
 *  @param DeviceObject Address of Device Object structure to examine.
 *  @param DisplayName Receives a wide character string containing human-readable
 *  name of the device.
 *  @param Receives a wide character string containing human-readable description
 *  of the device.
 *  @param VendorName Receives a wide character string containing name of the
 *  vendor. 
 *  @param Enumerator Receives a wide character string containing the name
 *  of the component that enumerated the device.
 *  @param ClassName Receives a wide character string containing the name
 *  of the class of the device.
 *  @param ClassGuid Receives a wide character string containing the GUID
 *  of the device class.
 *  @param Location Receives a wide character string containing human-readable
 *  information about the location of the device on its bus.
 *
 *  @return Returns NTSTATUS value indicating success or failure of the operation.
 *
 *  @remark If the registry does not contain certain data in the registry,
 *  the routine fills the corresponding parameter with NULL.
 */
static NTSTATUS _GetDevicePnPInformation(_In_ PDEVICE_OBJECT DeviceObject, _Out_ PWCHAR *DisplayName, _Out_ PWCHAR *Description, _Out_ PWCHAR *VendorName, _Out_ PWCHAR *Enumerator, _Out_ PWCHAR *ClassName, _Out_ PWCHAR *ClassGuid, _Out_ PWCHAR *Location)
{
	ULONG i = 0;
	DEVICE_REGISTRY_PROPERTY devicePropertyTypes[] = {
		DevicePropertyClassName,
		DevicePropertyDeviceDescription,
		DevicePropertyFriendlyName,
		DevicePropertyManufacturer,
		DevicePropertyLocationInformation,
		DevicePropertyEnumeratorName,
		DevicePropertyClassGuid,
	};
	PWCHAR *devicePropertyBuffers[] = {
		ClassName,
		Description,
		DisplayName,
		VendorName,
		Location,
		Enumerator,
		ClassGuid,
	};
	ULONG devicePropertyLengths[sizeof(devicePropertyBuffers) / sizeof(PWCHAR *)];
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p", DeviceObject);

	for (i = 0; i < sizeof(devicePropertyBuffers) / sizeof(PWCHAR *); ++i) {
		status = _GetWCharDeviceProperty(DeviceObject, devicePropertyTypes[i], devicePropertyBuffers[i], &devicePropertyLengths[i]);
		if (!NT_SUCCESS(status)) {
			ULONG j = 0;

			for (j = 0; j < i; ++j) {
				if (*(devicePropertyBuffers[j]) != NULL)
					HeapMemoryFree(*(devicePropertyBuffers[j]));
			}

			break;
		}
	}

	DEBUG_EXIT_FUNCTION("0x%x", status);
	return status;
}


/** Copies wide character string to the one of snapshot records and updates
 *  position information.
 *
 *  @param String String to copy.
 *  @param Record Address of the beginning of the record to which the string
 *  should be copied.
 *  @param DataStart Pointer to variable that points to place inside the record
 *  where the string should be stored. The routine updates this variable to point
 *  just after the terminating null character of the string.
 *  @param OffsetField Address of field of the record that contains information
 *  about the beginning of the string inside the record. The information have form
 *  of offset to the string relative to beginning of the record. The variable is
 *  updated to contain correct data.
 */
static VOID _CopyString(_In_opt_ PWCHAR String, _In_ PVOID Record, _Inout_ PUCHAR *DataStart, _Inout_ PULONG_PTR OffsetField)
{
	SIZE_T strLength = 0;
	DEBUG_ENTER_FUNCTION("String=\"%S\"; Record=0x%p; DataStart=0x%p; OffsetField=0x%p", String, Record, DataStart, OffsetField);

	if (String != NULL)
		strLength = wcslen(String);

	*OffsetField = (ULONG_PTR)*DataStart - (ULONG_PTR)Record;
	memcpy(*DataStart, String, strLength * sizeof(WCHAR));
	((PWCHAR)(*DataStart))[strLength] = L'\0';
	*DataStart += (strLength + 1) * sizeof(WCHAR);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


/************************************************************************/
/* VPB SNAPSHOT                                                         */
/************************************************************************/


/** Extracts information from Volume Parameter Block of a given device object.
 *
 *  @param DeviceObject The device object VPB of which will be examined.
 *  @param VpbSnapshot Address of variable that receives address of a newly allocated
 *  @link(SNAPSHOT_VPB_INFO) structure filled with VPB-related information.
 *
 *  @return
 *  NTSTATUS value.
 *
 *  @remark
 *  The routine uses the VPB spin lock to access the Volume Parameter Block in a correct way.
 *
 *  The @link(_FreeDeviceVpbInfo) routine must be used to free the structure returned in the second argument.
 */
static NTSTATUS _GetDeviceVpbInfo(_In_ PDEVICE_OBJECT DeviceObject, _Out_ PSNAPSHOT_VPB_INFO *VpbSnapshot)
{
	KIRQL irql;
	PVPB vpb = NULL;
	PSNAPSHOT_VPB_INFO tmpVpb = NULL;
	SIZE_T allocLength = 0;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; VpbSnapshot=0x%p", DeviceObject, VpbSnapshot);

	*VpbSnapshot = NULL;
	IoAcquireVpbSpinLock(&irql);
	vpb = DeviceObject->Vpb;
	if (vpb != NULL) {
		allocLength = sizeof(SNAPSHOT_VPB_INFO) + vpb->VolumeLabelLength + sizeof(WCHAR);
		tmpVpb = (PSNAPSHOT_VPB_INFO)HeapMemoryAllocNonPaged(allocLength);
		if (tmpVpb != NULL) {
			RtlZeroMemory(tmpVpb, allocLength);
			tmpVpb->Size = (ULONG)allocLength;
			tmpVpb->FileSystemDeviceObject = vpb->DeviceObject;
			tmpVpb->Flags = vpb->Flags;
			tmpVpb->ReferenceCount = vpb->ReferenceCount;
            tmpVpb->SerialNumber = vpb->SerialNumber;
            tmpVpb->VolumeDeviceObject = vpb->RealDevice;
            tmpVpb->VolumeLabel = sizeof(SNAPSHOT_VPB_INFO);
            memcpy((PUCHAR)tmpVpb + tmpVpb->VolumeLabel, &vpb->VolumeLabel, vpb->VolumeLabelLength);
            *VpbSnapshot = tmpVpb;
            status = STATUS_SUCCESS;
		} else status = STATUS_INSUFFICIENT_RESOURCES;
	} else status = STATUS_SUCCESS;

	IoReleaseVpbSpinLock(irql);

	DEBUG_EXIT_FUNCTION("0x%x, *VpbSnapshot=0x%p", status, *VpbSnapshot);
	return status;
}


/** Frees a given @link(SNAPSHOT_VPB_INFO) structure allocatd by a call to @link(_GetDeviceVpbInfo) routine.
 *
 *  @param Info The structure to free.
 */
static VOID _FreeDeviceVpbInfo(_Inout_ PSNAPSHOT_VPB_INFO Info)
{
	DEBUG_ENTER_FUNCTION("Info=0x%p", Info);

	HeapMemoryFree(Info);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


static NTSTATUS _GetDeviceRelationsInfo(_In_ PDEVICE_OBJECT DeviceObject, _In_ DEVICE_RELATION_TYPE RelationType, _Out_ PSNAPSHOT_DEVICE_RELATIONS_INFO *Info)
{
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	PSNAPSHOT_DEVICE_RELATIONS_INFO tmpInfo = NULL;
	ULONG tmpInfoSize = sizeof(SNAPSHOT_DEVICE_RELATIONS_INFO);
	PDEVICE_OBJECT *deviceArray = NULL;
	ULONG deviceCount = 0;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; RelationType=%u; Info=0x%p", DeviceObject, RelationType, Info);

	status = _QueryDeviceRelations(DeviceObject, RelationType, &deviceArray, &deviceCount);
	if (NT_SUCCESS(status))
		tmpInfoSize += deviceCount*sizeof(PDEVICE_OBJECT);

	status = STATUS_SUCCESS;
	tmpInfo = (PSNAPSHOT_DEVICE_RELATIONS_INFO)HeapMemoryAllocNonPaged(tmpInfoSize);
	if (tmpInfo != NULL) {
		tmpInfo->Count = deviceCount;
		tmpInfo->Size = tmpInfoSize;
		tmpInfo->RelationsOffset = sizeof(SNAPSHOT_DEVICE_RELATIONS_INFO);
		if (tmpInfo->Count > 0)
			memcpy((PUCHAR)tmpInfo + tmpInfo->RelationsOffset, deviceArray, tmpInfo->Count*sizeof(PDEVICE_OBJECT));

		*Info = tmpInfo;
		status = STATUS_SUCCESS;
	} else status = STATUS_INSUFFICIENT_RESOURCES;

	if (deviceCount > 0)
		_ReleaseDeviceArray(deviceArray, deviceCount);

	DEBUG_EXIT_FUNCTION("0x%x, *Info=0x%p", status, *Info);
	return status;
}


static SIZE_T _GetStringSize(_In_opt_ PWCHAR String)
{
	return (String != NULL ? wcslen(String)*sizeof(WCHAR) : 0);
}


static SIZE_T _GetMultiStringSize(_In_opt_ PWCHAR MultiString)
{
	SIZE_T ret = 0;
	SIZE_T partlen = 0;

	if (MultiString != NULL) {
		while (*MultiString != L'\0') {
			partlen = wcslen(MultiString) + 1;
			ret += partlen*sizeof(WCHAR);
			MultiString += partlen;
		}
	}
	
	return ret;
}


static NTSTATUS _GetDeviceAdvancedPnPInfo(_In_ ULONG SnapshotFlags, _In_ PDEVICE_OBJECT DeviceObject, _Out_ PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO *Info)
{
	PWCHAR deviceId = NULL;
	PWCHAR instanceId = NULL;
	PWCHAR hardwareIds = NULL;
	ULONG hardwareIdsLen = 0;
	PWCHAR compatibleIds = NULL;
	ULONG compatibleIdsLen = 0;
	DEVICE_CAPABILITIES capabilities;
	PSNAPSHOT_DEVICE_RELATIONS_INFO removalRelations = NULL;
	PSNAPSHOT_DEVICE_RELATIONS_INFO ejectRelations = NULL;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("SnapshotFlags=0x%x; DeviceObject=0x%p; Info=0x%p", SnapshotFlags, DeviceObject, Info);

	if (SnapshotFlags & VTREE_SNAPSHOT_DEVICE_ID)
		UtilsQueryDeviceId(DeviceObject, BusQueryDeviceID, &deviceId);
	
	UtilsQueryDeviceId(DeviceObject, BusQueryInstanceID, &instanceId);
//	UtilsQueryDeviceId(DeviceObject, BusQueryHardwareIDs, &hardwareIds);
//	UtilsQueryDeviceId(DeviceObject, BusQueryCompatibleIDs, &compatibleIds);
	_GetWCharDeviceProperty(DeviceObject, DevicePropertyHardwareID, &hardwareIds, &hardwareIdsLen);
	_GetWCharDeviceProperty(DeviceObject, DevicePropertyCompatibleIDs, &compatibleIds, &compatibleIdsLen);
	status = _GetDeviceRelationsInfo(DeviceObject, RemovalRelations, &removalRelations);
	if (NT_SUCCESS(status)) {
		status = _GetDeviceRelationsInfo(DeviceObject, EjectionRelations, &ejectRelations);
		if (NT_SUCCESS(status)) {
			SIZE_T totalSize = sizeof(SNAPSHOT_DEVICE_ADVANCED_PNP_INFO);
			SIZE_T deviceIdSize = _GetStringSize(deviceId);
			SIZE_T instanceIdSize = _GetStringSize(instanceId);
			SIZE_T hardwareSize = _GetMultiStringSize(hardwareIds);
			SIZE_T compatibleSize = _GetMultiStringSize(compatibleIds);
			PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO tmpInfo = NULL;

			memset(&capabilities, 0, sizeof(capabilities));
			UtilsQueryDeviceCapabilities(DeviceObject, &capabilities);

			totalSize += deviceIdSize + sizeof(WCHAR) + instanceIdSize + sizeof(WCHAR) + hardwareSize + sizeof(WCHAR) + compatibleSize + sizeof(WCHAR);
			tmpInfo = (PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO)HeapMemoryAllocNonPaged(totalSize);
			if (tmpInfo != NULL) {
				PUCHAR tmp = (PUCHAR)(tmpInfo + 1);

				memset(tmpInfo, 0, totalSize);
				tmpInfo->Size = totalSize;
				memcpy(&tmpInfo->Capabilities, &capabilities, sizeof(capabilities));
				tmpInfo->RemovalRelationsInfo = removalRelations;
				tmpInfo->EjectRelationsInfo = ejectRelations;
					
				tmpInfo->DeviceId = (ULONG_PTR)tmp - (ULONG_PTR)tmpInfo;
				memcpy(tmp, deviceId, deviceIdSize);
				tmp += deviceIdSize + sizeof(WCHAR);

				tmpInfo->InstanceId = (ULONG_PTR)tmp - (ULONG_PTR)tmpInfo;
				memcpy(tmp, instanceId, instanceIdSize);
				tmp += instanceIdSize + sizeof(WCHAR);

				tmpInfo->HardwareIds = (ULONG_PTR)tmp - (ULONG_PTR)tmpInfo;
				memcpy(tmp, hardwareIds, hardwareSize);
				tmp += hardwareSize + sizeof(WCHAR);

				tmpInfo->CompatibleIds = (ULONG_PTR)tmp - (ULONG_PTR)tmpInfo;
				memcpy(tmp, compatibleIds, compatibleSize);
				tmp += compatibleSize + sizeof(WCHAR);

				*Info = tmpInfo;
				status = STATUS_SUCCESS;
			} else status = STATUS_INSUFFICIENT_RESOURCES;

			if (!NT_SUCCESS(status)) 
				HeapMemoryFree(ejectRelations);
		}

		if (!NT_SUCCESS(status))
			HeapMemoryFree(removalRelations);
	}

	if (compatibleIds != NULL)
		HeapMemoryFree(compatibleIds);

	if (hardwareIds != NULL)
		HeapMemoryFree(hardwareIds);

	if (instanceId != NULL)
		ExFreePool(instanceId);

	if (deviceId != NULL)
		ExFreePool(deviceId);
	

	DEBUG_EXIT_FUNCTION("0x%x, *Info=0x%p", status, *Info);
	return status;
}


static VOID _FreeAdvancedPnPInfo(_Inout_ PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO Info)
{
	DEBUG_ENTER_FUNCTION("Info=0x%p", Info);

	if (Info->EjectRelationsInfo != NULL)
		HeapMemoryFree(Info->EjectRelationsInfo);

	if (Info->RemovalRelationsInfo != NULL)
		HeapMemoryFree(Info->RemovalRelationsInfo);

	HeapMemoryFree(Info);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


static NTSTATUS _SecurityInfoCreate(_In_ PDEVICE_OBJECT DeviceObject, _Out_ PSECURITY_DESCRIPTOR *Info)
{
	BOOLEAN allocated = FALSE;
	ULONG sdLen = 0;
	PSECURITY_DESCRIPTOR sd = NULL;
	PSECURITY_DESCRIPTOR tmpInfo = NULL;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Info=0x%p", DeviceObject, Info);

	status = ObGetObjectSecurity(DeviceObject, &sd, &allocated);
	if (NT_SUCCESS(status)) {
		sdLen = RtlLengthSecurityDescriptor(sd);
		tmpInfo = (PSECURITY_DESCRIPTOR)HeapMemoryAllocPaged(sdLen);
		if (tmpInfo != NULL) {
			memcpy(tmpInfo, sd, sdLen);
			*Info = tmpInfo;
			status = STATUS_SUCCESS;
		} else status = STATUS_INSUFFICIENT_RESOURCES;
		
		if (allocated)
			ExFreePool(sd);
	}

	DEBUG_EXIT_FUNCTION("0x%x, *Info=0x%p", status, *Info);
	return status;
}


static VOID _SecurityInfoFree(_In_ PSECURITY_DESCRIPTOR Info)
{
	DEBUG_ENTER_FUNCTION("Info=0x%p", Info);

	HeapMemoryFree(Info);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


/** Creates Device Info record that contains information about a device object
 *  within the snapshot.
 *
 *  @param DeviceObject Address of Device Object information about which should
 *  be collected and stored inside new Device Info record.
 *  @param DeviceInfo Address of variable that, when the routine succeeds,
 *  receives address of the newly allocated and initialized Device Info 
 *  structure. When the routine fails, the variable is filled with NULL.
 */
static NTSTATUS _DeviceInfoSnapshotCreate(_In_ ULONG SnapshotFlags, _In_ PDEVICE_OBJECT DeviceObject, _Out_ PSNAPSHOT_DEVICE_INFO *DeviceInfo)
{
	UNICODE_STRING uDeviceName;
	PSNAPSHOT_DEVICE_INFO tmpDeviceInfo = NULL;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("SnapshotFlags=0x%x; DeviceObject=0x%p; DeviceInfo=0x%p", SnapshotFlags, DeviceObject, *DeviceInfo);

	*DeviceInfo = NULL;
	// Retrieve name of the device object
	status = _GetObjectName(DeviceObject, &uDeviceName);
	if (NT_SUCCESS(status)) {
		PDEVICE_OBJECT *UpperDevices = NULL;
		SIZE_T UpperDeviceCount = 0;
		PDEVICE_OBJECT DiskDevice = NULL;

		// Retrieve Disk Device Object, present in filesystem devices that correspond
		// to volumes.
		status = IoGetDiskDeviceObject(DeviceObject, &DiskDevice);
		if (!NT_SUCCESS(status))
			DiskDevice = NULL;

		// Retrieve addresses of Device Objects for lower devices in the
		// device stack.
		status = _GetLowerUpperDevices(DeviceObject, TRUE, &UpperDevices, &UpperDeviceCount);
		if (NT_SUCCESS(status)) {
			PDEVICE_OBJECT *LowerDevices = NULL;
			SIZE_T LowerDeviceCount = 0;

			// Retrieve addresses of Device Objects for upper devices in the
			// device stack.
			status = _GetLowerUpperDevices(DeviceObject, FALSE, &LowerDevices, &LowerDeviceCount);
			if (NT_SUCCESS(status)) {
				SIZE_T DeviceInfoSize = 0;
				PWCHAR DisplayName = NULL;
				PWCHAR Description = NULL;
				PWCHAR Vendor = NULL;
				PWCHAR Enumerator = NULL;
				PWCHAR Location = NULL;
				PWCHAR Class = NULL;
				PWCHAR ClassGuid = NULL;

				// Start to compute size of the Device Info record
				DeviceInfoSize = sizeof(SNAPSHOT_DEVICE_INFO) + uDeviceName.Length + sizeof(WCHAR) + (LowerDeviceCount + UpperDeviceCount) * sizeof(PDEVICE_OBJECT);
				DeviceInfoSize += 7 * sizeof(WCHAR);
				if (DeviceObject->Flags & DO_BUS_ENUMERATED_DEVICE) {
					// The device has been enumerated by PnP. Try to retrieve
					// some information about it.
					status = _GetDevicePnPInformation(DeviceObject, &DisplayName, &Description, &Vendor, &Enumerator, &Class, &ClassGuid, &Location);
					if (NT_SUCCESS(status)) {
						if (DisplayName != NULL)
							DeviceInfoSize += wcslen(DisplayName) * sizeof(WCHAR);
                  
						if (Vendor != NULL)
							DeviceInfoSize += wcslen(Vendor) * sizeof(WCHAR);
                  
						if (Description != NULL)
							DeviceInfoSize += wcslen(Description) * sizeof(WCHAR);
                  
						if (Class != NULL)
							DeviceInfoSize += wcslen(Class) * sizeof(WCHAR);
                  
						if (Location != NULL)
							DeviceInfoSize += wcslen(Location) * sizeof(WCHAR);
                  
						if (Enumerator != NULL)
							DeviceInfoSize += wcslen(Enumerator) * sizeof(WCHAR);

						if (ClassGuid != NULL)
							DeviceInfoSize += wcslen(ClassGuid) * sizeof(WCHAR);
					}
				}
            
				if (NT_SUCCESS(status)) {
					// Allocate the Device Info record
					tmpDeviceInfo = (PSNAPSHOT_DEVICE_INFO)HeapMemoryAllocPaged(DeviceInfoSize);
					if (tmpDeviceInfo != NULL) {
						PUCHAR Data = NULL;
						PDEVOBJ_EXTENSION devObjExtension = NULL;

						// Copy all information collected about the device into the
						// record.
						RtlZeroMemory(tmpDeviceInfo, DeviceInfoSize);
						tmpDeviceInfo->Size = DeviceInfoSize;
						tmpDeviceInfo->Characteristics = DeviceObject->Characteristics;
						tmpDeviceInfo->DeviceType = DeviceObject->DeviceType;
						tmpDeviceInfo->Flags = DeviceObject->Flags;
						tmpDeviceInfo->ObjectAddress = DeviceObject;
						tmpDeviceInfo->NumberOfLowerDevices = LowerDeviceCount;
						tmpDeviceInfo->NumberOfUpperDevices = UpperDeviceCount;
						tmpDeviceInfo->NameOffset = sizeof(SNAPSHOT_DEVICE_INFO);
						Data = (PUCHAR)tmpDeviceInfo + tmpDeviceInfo->NameOffset;
						memcpy(Data, uDeviceName.Buffer, uDeviceName.Length);
						((PWCHAR)Data)[uDeviceName.Length / sizeof(WCHAR)] = L'\0';
						Data += uDeviceName.Length + sizeof(WCHAR);
						tmpDeviceInfo->LowerDevicesOffset = (ULONG_PTR)Data - (ULONG_PTR)tmpDeviceInfo;
						memcpy(Data, LowerDevices, LowerDeviceCount * sizeof(PDEVICE_OBJECT));
						Data += LowerDeviceCount * sizeof(PDEVICE_OBJECT);
						tmpDeviceInfo->UpperDevicesOffset = (ULONG_PTR)Data - (ULONG_PTR)tmpDeviceInfo;
						RtlCopyMemory(Data, UpperDevices, UpperDeviceCount * sizeof(PDEVICE_OBJECT));
						Data += UpperDeviceCount * sizeof(PDEVICE_OBJECT);
						_CopyString(Class, tmpDeviceInfo, &Data, &tmpDeviceInfo->ClassNameOffset);
						_CopyString(DisplayName, tmpDeviceInfo, &Data, &tmpDeviceInfo->DisplayNameOffset);
						_CopyString(Description, tmpDeviceInfo, &Data, &tmpDeviceInfo->DescriptionOffset);
						_CopyString(Vendor, tmpDeviceInfo, &Data, &tmpDeviceInfo->VendorNameOffset);
						_CopyString(Enumerator, tmpDeviceInfo, &Data, &tmpDeviceInfo->EnumeratorOffset);
						_CopyString(Location, tmpDeviceInfo, &Data, &tmpDeviceInfo->LocationOffset);
						_CopyString(ClassGuid, tmpDeviceInfo, &Data, &tmpDeviceInfo->ClassGuidOffset);
						tmpDeviceInfo->DiskDevice = DiskDevice;
						tmpDeviceInfo->Vpb = DeviceObject->Vpb;
						devObjExtension = DeviceObject->DeviceObjectExtension;
						tmpDeviceInfo->DeviceNode = devObjExtension->DeviceNode;
						if ((SnapshotFlags & VTREE_SNAPSHOT_DEVNODE_TREE) &&
							DeviceObject->Flags & DO_BUS_ENUMERATED_DEVICE &&
							devObjExtension->DeviceNode != NULL) {
							PDEVICE_NODE_PART devNodePart = (PDEVICE_NODE_PART)devObjExtension->DeviceNode;
						
							tmpDeviceInfo->Parent = devNodePart->Parent;
							tmpDeviceInfo->Sibling = devNodePart->Sibling;
							tmpDeviceInfo->Child = devNodePart->Child;
						}

						tmpDeviceInfo->ExtensionFlags = devObjExtension->ExtensionFlags;
						tmpDeviceInfo->PowerFlags = devObjExtension->PowerFlags;
						status = _SecurityInfoCreate(DeviceObject, &tmpDeviceInfo->Security);
						if (NT_SUCCESS(status)) {
							status = _GetDeviceVpbInfo(DeviceObject, &tmpDeviceInfo->VpbInfo);
							if (NT_SUCCESS(status)) {
								if ((DeviceObject->Flags & DO_BUS_ENUMERATED_DEVICE) != 0)
									status = _GetDeviceAdvancedPnPInfo(SnapshotFlags, DeviceObject, &tmpDeviceInfo->AdvancedPnPInfo);

								if (!NT_SUCCESS(status) && tmpDeviceInfo->VpbInfo != NULL)
									HeapMemoryFree(tmpDeviceInfo->VpbInfo);
							}

							if (NT_SUCCESS(status))
								// Return the Device Info record and signal success of
								// the operation.
								*DeviceInfo = tmpDeviceInfo;
					
							if (!NT_SUCCESS(status))
								_SecurityInfoFree(tmpDeviceInfo->Security);
						}

						if (!NT_SUCCESS(status))
							HeapMemoryFree(tmpDeviceInfo);
					} else status = STATUS_INSUFFICIENT_RESOURCES;
            
					if (Enumerator != NULL)
						HeapMemoryFree(Enumerator);

					if (Location != NULL)
						HeapMemoryFree(Location);

					if (DisplayName != NULL)
						HeapMemoryFree(DisplayName);

					if (Vendor != NULL)
						HeapMemoryFree(Vendor);

					if (Description != NULL)
						HeapMemoryFree(Description);

					if (Class != NULL)
						HeapMemoryFree(Class);

					if (ClassGuid != NULL)
						HeapMemoryFree(ClassGuid);
				}

				_ReleaseDeviceArray(LowerDevices, LowerDeviceCount);
			}

			_ReleaseDeviceArray(UpperDevices, UpperDeviceCount);
		}

		HeapMemoryFree(uDeviceName.Buffer);
	}

	DEBUG_EXIT_FUNCTION("0x%x, *DeviceInfo=0x%p", status, *DeviceInfo);
	return status;
}


/** Frees memory and potentially othe rresources allocated for
 *  a Device Info record.
 *
 *  @param Address of Device Info record to free.
 */
static VOID _DeviceInfoSnapshotFree(_Inout_ PSNAPSHOT_DEVICE_INFO DeviceInfo)
{
	DEBUG_ENTER_FUNCTION("DeviceInfo=0x%p", DeviceInfo);

	if (DeviceInfo->AdvancedPnPInfo != NULL)
		_FreeAdvancedPnPInfo(DeviceInfo->AdvancedPnPInfo);

	if (DeviceInfo->VpbInfo != NULL)
		_FreeDeviceVpbInfo(DeviceInfo->VpbInfo);

	_SecurityInfoFree(DeviceInfo->Security);
	HeapMemoryFree(DeviceInfo);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


/************************************************************************/
/* DRIVERINFO SNAPSHOT HELPER ROUTINES                                                                     */
/************************************************************************/


/** Creates a Driver Info record that represents given device driver within
 *  the snapshot.
 *
 *  @param DriverObject Address of Driver Object for which the Driver Info
 *  structure should be created.
 *  @param DeviceInfo Address of variable that, if the function succeeds, 
 *  receives address of the new Driver Info structure. If the routine fails,
 *  the variable is filled with NULL.
 *
 *  @return Returns NTSTATUS value indicating success or failure of the opeation.
 *
 *  @remark The routine also determines device objects of given driver, and
 *  creates and fills Device Info structures of them. Addresses of the structures
 *  are stored inside the Driver Info structure.
 */
static NTSTATUS _DriverSnapshotCreate(_In_ ULONG SnapshotFlags, _In_ PDRIVER_OBJECT DriverObject, _Out_ PSNAPSHOT_DRIVER_INFO *DriverInfo)
{
	UNICODE_STRING uDrivername;
	PSNAPSHOT_DRIVER_INFO tmpDriverInfo = NULL;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	PDEVICE_OBJECT *deviceArray = NULL;
	ULONG deviceArrayLength = 0;
	DEBUG_ENTER_FUNCTION("SnapshotFlags=0x%x; DriverObject=0x%p; DriverInfo=0x%p", SnapshotFlags, DriverObject, DriverInfo);
   
	*DriverInfo = NULL;
	// Get name of the driver
	status = _GetObjectName(DriverObject, &uDrivername);
	if (NT_SUCCESS(status)) {
		// Enum its devices
		status = _EnumDriverDevices(DriverObject, &deviceArray, &deviceArrayLength);
		if (NT_SUCCESS(status)) {
			SIZE_T DriverInfoSize = 0;

			// Compute size of the new Driver Info record and allocate it.
			DriverInfoSize = sizeof(SNAPSHOT_DRIVER_INFO) + uDrivername.Length + sizeof(WCHAR) + deviceArrayLength * sizeof(PDEVICE_OBJECT);
			tmpDriverInfo = (PSNAPSHOT_DRIVER_INFO)HeapMemoryAllocPaged(DriverInfoSize);
			if (tmpDriverInfo != NULL) {
				SIZE_T i = 0;
				PDEVICE_OBJECT *pDeviceObject = NULL;
				PUCHAR Data = (PUCHAR)((PUCHAR)tmpDriverInfo + sizeof(SNAPSHOT_DRIVER_INFO));
            
				// Initialize members of the Driver Info structure.
				// Do not copy FAST_IO_DISPATCH structure of the driver because
				// it may disappear during the operaion which whould made 
				// VrtuleTree unsafe.
				memset(tmpDriverInfo, 0, DriverInfoSize);
				tmpDriverInfo->Size = DriverInfoSize;
				tmpDriverInfo->ImageBase = DriverObject->DriverStart;
				tmpDriverInfo->ImageSize = DriverObject->DriverSize;
				tmpDriverInfo->DriverEntry = DriverObject->DriverInit;
				tmpDriverInfo->DriverUnload = DriverObject->DriverUnload;
				tmpDriverInfo->Flags = DriverObject->Flags;
				tmpDriverInfo->StartIo = DriverObject->DriverStartIo;
				tmpDriverInfo->ObjectAddress = DriverObject;
				memcpy(tmpDriverInfo->MajorFunctions, DriverObject->MajorFunction, (IRP_MJ_MAXIMUM_FUNCTION + 1)*sizeof(DRIVER_DISPATCH*));
				if (SnapshotFlags & VTREE_SNAPSHOT_FAST_IO_DISPATCH) {
					PFAST_IO_DISPATCH f = DriverObject->FastIoDispatch;

					tmpDriverInfo->FastIoAddress = f;
					if (f != NULL)
						memcpy(&tmpDriverInfo->FastIo, f, min(f->SizeOfFastIoDispatch, sizeof(FAST_IO_DISPATCH)));
				}

				tmpDriverInfo->NumberOfDevices = deviceArrayLength;
				tmpDriverInfo->DevicesOffset = (ULONG_PTR)Data - (ULONG_PTR)tmpDriverInfo;
				// Copy addresses of Device Object structures of the driver's
				// devices into the record. These addresses will be copied to
				// Device Info structures later created for individual devices of
				// the driver. The addresses in the record will be replaced with
				// addresses of the corresponding Device Info structures.
				memcpy(Data, deviceArray, deviceArrayLength * sizeof(PDEVICE_OBJECT));
				Data += deviceArrayLength * sizeof(PDEVICE_OBJECT);
				// Copy name of the driver
				tmpDriverInfo->NameOffset = (ULONG_PTR)Data - (ULONG_PTR)tmpDriverInfo;
				memcpy(Data, uDrivername.Buffer, uDrivername.Length);
				((PWCHAR)Data)[uDrivername.Length / sizeof(WCHAR)] = '\0';
					// Walk the Device Objects and replace them with DeviceInfo
					// records.
					pDeviceObject = (PDEVICE_OBJECT *)((PUCHAR)tmpDriverInfo + tmpDriverInfo->DevicesOffset);
					for (i = 0; i < tmpDriverInfo->NumberOfDevices; ++i) {
						status = _DeviceInfoSnapshotCreate(SnapshotFlags, pDeviceObject[i], (PSNAPSHOT_DEVICE_INFO *)&pDeviceObject[i]);
						if (!NT_SUCCESS(status)) {
							SIZE_T j = 0;

							for (j = 0; j < i; ++j)
								_DeviceInfoSnapshotFree((PSNAPSHOT_DEVICE_INFO)pDeviceObject[j]);
               
							break;
						}
					}
            
					if (NT_SUCCESS(status))
						*DriverInfo = tmpDriverInfo;

				if (!NT_SUCCESS(status))
					HeapMemoryFree(tmpDriverInfo);

			} else status = STATUS_INSUFFICIENT_RESOURCES;

			_ReleaseDeviceArray(deviceArray, deviceArrayLength);
		}

		HeapMemoryFree(uDrivername.Buffer);
	}

	DEBUG_EXIT_FUNCTION("0x%x, *DriverInfo=0x%p", status, *DriverInfo);
	return status;
}


/** Frees memory allocated for Driver Info record. The routine also frees
 *  all Device Info records of devices owned by the driver in time when the
 *  Driver Info structure had been created.
 *
 *  @param DriverInfo Address of Driver Info structure to free.
 */
static VOID _DriverSnapshotFree(_Inout_ PSNAPSHOT_DRIVER_INFO DriverInfo)
{
	ULONG_PTR i = 0;
	PSNAPSHOT_DEVICE_INFO *DeviceInfo = NULL;
	DEBUG_ENTER_FUNCTION("DriverInfo=0x%p", DriverInfo);

	DeviceInfo = (PSNAPSHOT_DEVICE_INFO *)((PUCHAR)DriverInfo + DriverInfo->DevicesOffset);
	for (i = 0; i < DriverInfo->NumberOfDevices; ++i)
		_DeviceInfoSnapshotFree(DeviceInfo[i]);

	HeapMemoryFree(DriverInfo);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


static SIZE_T _ComputeSnapshotSize(_In_ PVRTULETREE_KERNEL_SNAPSHOT Snapshot)
{
	ULONG i = 0;
	ULONG j = 0;
	SIZE_T snapshotSize = 0;
	PSNAPSHOT_DRIVERLIST driverList = NULL;
	DEBUG_ENTER_FUNCTION("Snapshot=0x%p", Snapshot);

	driverList = &Snapshot->DriverList;
	snapshotSize = sizeof(SNAPSHOT_DRIVERLIST) + driverList->NumberOfDrivers*sizeof(PSNAPSHOT_DRIVER_INFO);
	for (i = 0; i < driverList->NumberOfDrivers; ++i) {
		PSNAPSHOT_DRIVER_INFO driverInfo = *(PSNAPSHOT_DRIVER_INFO *)((PUCHAR)driverList + driverList->DriversOffset + i*sizeof(PSNAPSHOT_DRIVER_INFO));

		snapshotSize += driverInfo->Size;
		for (j = 0; j < driverInfo->NumberOfDevices; ++j) {
			PSNAPSHOT_DEVICE_INFO deviceInfo = *(PSNAPSHOT_DEVICE_INFO *)((PUCHAR)driverInfo + driverInfo->DevicesOffset + j*sizeof(PSNAPSHOT_DEVICE_INFO));
			PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO advPnP = deviceInfo->AdvancedPnPInfo;

			snapshotSize += deviceInfo->Size;
			if (deviceInfo->VpbInfo != NULL)
				snapshotSize += deviceInfo->VpbInfo->Size;

			if (deviceInfo->Security != NULL)
				snapshotSize += RtlLengthSecurityDescriptor(deviceInfo->Security);

			if (advPnP != NULL) {
				snapshotSize += advPnP->Size;
				if (advPnP->RemovalRelationsInfo != NULL)
					snapshotSize += advPnP->RemovalRelationsInfo->Size;

				if (advPnP->EjectRelationsInfo != NULL)
					snapshotSize += advPnP->EjectRelationsInfo->Size;
			}
		}
	}

	DEBUG_EXIT_FUNCTION("%u", snapshotSize);
	return snapshotSize;
}


static VOID FORCEINLINE _CopyFlatPart(_Inout_ PUCHAR *AktPos, _In_ PVOID KernelBuffer, _In_ SIZE_T Size)
{
	memcpy(*AktPos, KernelBuffer, Size);
	(*AktPos) += Size;

	return;
}


static ULONG _CopySnapshot(_In_ PVRTULETREE_KERNEL_SNAPSHOT Snapshot, _Out_ PVOID UserBuffer)
{
	ULONG i = 0;
	ULONG j = 0;
	PUCHAR aktPos = (PUCHAR)UserBuffer;
	PSNAPSHOT_DRIVER_INFO *userDriverInfoPtr = NULL;
	PSNAPSHOT_DEVICE_INFO *userDeviceInfoPtr = NULL;
	PSNAPSHOT_DRIVERLIST driverList = NULL;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("Snapshot=0x%p; UserBuffer=0x%p", Snapshot, UserBuffer);

	status = STATUS_SUCCESS;
	driverList = &Snapshot->DriverList;
	__try {
		userDriverInfoPtr = (PSNAPSHOT_DRIVER_INFO *)((PUCHAR)aktPos + sizeof(SNAPSHOT_DRIVERLIST));
		_CopyFlatPart(&aktPos, driverList, sizeof(SNAPSHOT_DRIVERLIST) + driverList->NumberOfDrivers*sizeof(PSNAPSHOT_DRIVER_INFO));
		for (i = 0; i < driverList->NumberOfDrivers; ++i) {
			PSNAPSHOT_DRIVER_INFO driverInfo = *(PSNAPSHOT_DRIVER_INFO *)((PUCHAR)driverList + driverList->DriversOffset + i*sizeof(PSNAPSHOT_DRIVER_INFO));

			*userDriverInfoPtr = (PSNAPSHOT_DRIVER_INFO)aktPos;
			userDeviceInfoPtr = (PSNAPSHOT_DEVICE_INFO *)(aktPos + driverInfo->DevicesOffset); 

			_CopyFlatPart(&aktPos, driverInfo, driverInfo->Size);
			for (j = 0; j < driverInfo->NumberOfDevices; ++j) {
				PSNAPSHOT_DEVICE_INFO deviceInfo = *(PSNAPSHOT_DEVICE_INFO *)((PUCHAR)driverInfo + driverInfo->DevicesOffset + j*sizeof(PSNAPSHOT_DEVICE_INFO));
				PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO advPnP = deviceInfo->AdvancedPnPInfo;

				*userDeviceInfoPtr = (PSNAPSHOT_DEVICE_INFO)aktPos;

				_CopyFlatPart(&aktPos, deviceInfo, deviceInfo->Size);
				if (deviceInfo->VpbInfo != NULL) {
					(*userDeviceInfoPtr)->VpbInfo = (PSNAPSHOT_VPB_INFO)aktPos;
					_CopyFlatPart(&aktPos, deviceInfo->VpbInfo, deviceInfo->VpbInfo->Size);
				}

				if (deviceInfo->Security != NULL) {
					(*userDeviceInfoPtr)->Security = (PSECURITY_DESCRIPTOR)aktPos;
					_CopyFlatPart(&aktPos, deviceInfo->Security, RtlLengthSecurityDescriptor(deviceInfo->Security));
				}

				if (advPnP != NULL) {
					PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO userPnPInfo = (PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO)aktPos;
					(*userDeviceInfoPtr)->AdvancedPnPInfo = (PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO)aktPos;
					_CopyFlatPart(&aktPos, advPnP, advPnP->Size);
					if (advPnP->RemovalRelationsInfo != NULL) {
						userPnPInfo->RemovalRelationsInfo = (PSNAPSHOT_DEVICE_RELATIONS_INFO)aktPos;
						_CopyFlatPart(&aktPos, advPnP->RemovalRelationsInfo, advPnP->RemovalRelationsInfo->Size);
					}

					if (advPnP->EjectRelationsInfo != NULL) {
						userPnPInfo->EjectRelationsInfo = (PSNAPSHOT_DEVICE_RELATIONS_INFO)aktPos;
						_CopyFlatPart(&aktPos, advPnP->EjectRelationsInfo, advPnP->EjectRelationsInfo->Size);
					}
				}

				++userDeviceInfoPtr;
			}

			++userDriverInfoPtr;
		}
	} __except (EXCEPTION_EXECUTE_HANDLER) {
		status = GetExceptionCode();
	}

	DEBUG_EXIT_FUNCTION("0x%x", status);
	return status;
}


/************************************************************************/
/*                            PUBLIC ROUTINES                           */
/************************************************************************/

/** Collects information about all drivers and devices present in the
 *  system and stores it inside a new snapshot.
 *
 *  @param SnapshotFlags Determines whether some special information should also be
 *  collected (collecting of them might be dangerous for the system stability).
 *  The following flags are valid:
 *    @value VTREE_SNAPSHOT_DEVICE_ID Collect device ID (via the IRP_MN_QUERY_ID request).
 *	  @value VTREE_SNAPSHOT_FAST_IO_DISPATCH Collect fast I/O dispatch structure of driver objects,
 *     if available.
 *   @value VTREE_SNAPSHOT_DEVNODE_TREE Collect some information from devnodes (parent, and children).
 *  @param Snapshot Address of variable that, in case of success, receives
 *  address of the new snapshot.
 *
 *  @return Returns NTSTATUS value indicating success or failure of the
 *  operation.
 *
 *  @remark The routine inserts the snapshot to the list of snapshot. The
 *  routine is thread-safe.
 */
NTSTATUS SnapshotCreate(_In_ ULONG SnapshotFlags, _Out_ PVRTULETREE_KERNEL_SNAPSHOT *Snapshot)
{
	PSNAPSHOT_DRIVERLIST driverList = NULL;
	UNICODE_STRING uDriverDirectory;
	PDRIVER_OBJECT *normalDrivers = NULL;
	SIZE_T normalDriverCount = 0;
	PDRIVER_OBJECT *fileSystemDrivers = NULL;
	SIZE_T fileSystemDriverCount = 0;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("SnapshotFlags=0x%x; Snapshot=0x%p", SnapshotFlags, Snapshot);

	// Collect Driver Objects from \Driver directory
	RtlInitUnicodeString(&uDriverDirectory, L"\\Driver");
	status = _GetDriversInDirectory(&uDriverDirectory, &normalDrivers, &normalDriverCount);
	if (NT_SUCCESS(status)) {
		// Collect Driver Objects from \FileSystem directory
		RtlInitUnicodeString(&uDriverDirectory, L"\\FileSystem");
		status = _GetDriversInDirectory(&uDriverDirectory, &fileSystemDrivers, &fileSystemDriverCount);
		if (NT_SUCCESS(status)) {
			PDRIVER_OBJECT *DriverArrays [2] = {normalDrivers, fileSystemDrivers};
			SIZE_T ArrayLengths [2] = {normalDriverCount, fileSystemDriverCount};

			// Create a node representing the list of drivers in the snapshot.
			// The node will contain all drivers found in \Driver and \FileSystem
			// directories. Creation of the node does not cause creation of
			// Driver Info and Device Info records.
			status = _DriverListNodeCreate(DriverArrays, ArrayLengths, sizeof(ArrayLengths) / sizeof(SIZE_T), &driverList);
			if (NT_SUCCESS(status)) {
				SIZE_T i = 0;
				PDRIVER_OBJECT *DriverObject = NULL;

				// Create Driver Info records for all drivers in the snapshot.
				// This will also cause the Device Info records to be created.
				DriverObject = (PDRIVER_OBJECT *)((PUCHAR)driverList + driverList->DriversOffset);
				for (i = 0; i < driverList->NumberOfDrivers; ++i) {
					status = _DriverSnapshotCreate(SnapshotFlags, DriverObject[i], (PSNAPSHOT_DRIVER_INFO *)&DriverObject[i]);
					if (!NT_SUCCESS(status)) {
						SIZE_T j = 0;

						for (j = 0; j < i; ++j)
							_DriverSnapshotFree((PSNAPSHOT_DRIVER_INFO)DriverObject[j]);
               
						break;
					}
				}

				if (NT_SUCCESS(status)) {
					PVRTULETREE_KERNEL_SNAPSHOT TmpSnapshot = NULL;
               
					// Allocate snapshot record, initialize it and insert it
					// into the list of snapshots
					TmpSnapshot = (PVRTULETREE_KERNEL_SNAPSHOT)HeapMemoryAllocPaged(driverList->Size + sizeof(VRTULETREE_KERNEL_SNAPSHOT) - sizeof(SNAPSHOT_DRIVERLIST));
					if (TmpSnapshot != NULL) {
						RtlCopyMemory(&TmpSnapshot->DriverList, driverList, driverList->Size);                  
						*Snapshot = TmpSnapshot;
						status = STATUS_SUCCESS;
					} else status = STATUS_INSUFFICIENT_RESOURCES;

					if (!NT_SUCCESS(status)) {
						PSNAPSHOT_DRIVER_INFO *DriverInfo = NULL;

						DriverInfo = (PSNAPSHOT_DRIVER_INFO *)((PUCHAR)driverList + driverList->DriversOffset);
						for (i = 0; i < driverList->NumberOfDrivers; ++i)
							_DriverSnapshotFree(DriverInfo[i]);
					}
				}

				HeapMemoryFree(driverList);
			}

			_ReleaseDriverArray(fileSystemDrivers, fileSystemDriverCount);
		}

		_ReleaseDriverArray(normalDrivers, normalDriverCount);
	}

	DEBUG_EXIT_FUNCTION("0x%x, *Snapshot=0x%p", status, *Snapshot);
	return status;
}


/** Releases memory occupied by given snapshot.
 *
 *  @param Snapshot The snapshot.
 */
VOID SnapshotFree(_Inout_ PVRTULETREE_KERNEL_SNAPSHOT Snapshot)
{
	SIZE_T i = 0;
	PSNAPSHOT_DRIVER_INFO *DriverInfo;
	PSNAPSHOT_DRIVERLIST DriverList = NULL;
	DEBUG_ENTER_FUNCTION("Snapshot=0x%p", Snapshot);

	DriverList = &Snapshot->DriverList;
	DriverInfo = (PSNAPSHOT_DRIVER_INFO *)((PUCHAR)DriverList + DriverList->DriversOffset);
	for (i = 0; i < DriverList->NumberOfDrivers; ++i)
		// Freeing Driver Info record also frees all related Device Info records
		_DriverSnapshotFree(DriverInfo[i]);

	HeapMemoryFree(Snapshot);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}


NTSTATUS SnapshotToUser(_In_ PVRTULETREE_KERNEL_SNAPSHOT Snapshot, _Out_ PVOID *Address)
{
	PVOID tmpAddress = NULL;
	SIZE_T snapshotSize = 0;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("Snapshot=0x%p; Address=0x%p", Snapshot, Address);

	snapshotSize = _ComputeSnapshotSize(Snapshot);
	if (snapshotSize > 0) {
		status = VirtualMemoryAllocUser(snapshotSize, PAGE_READWRITE, &tmpAddress);
		if (NT_SUCCESS(status)) {
			status = _CopySnapshot(Snapshot, tmpAddress);
			if (NT_SUCCESS(status))
				*Address = tmpAddress;

			if (!NT_SUCCESS(status))
				VirtualMemoryFreeUser(tmpAddress);
		}
	} else status = STATUS_UNSUCCESSFUL;

	DEBUG_EXIT_FUNCTION("0x%x, *Address=0x%p", status, *Address);
	return status;
}
