
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
 *  drivers it should include into the snapshot.
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
static NTSTATUS _DriverListNodeCreate(PDRIVER_OBJECT **DriverArrays, PSIZE_T ArrayLengths, SIZE_T ItemCount, PSNAPSHOT_DRIVERLIST *DriverList)
{
   LONG i = 0;
   ULONG_PTR DriverCount = 0;
   PSNAPSHOT_DRIVERLIST TmpDriverList = NULL;
   SIZE_T DriverListSize = 0;
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("DriverArrays=0x%p; ArrayLengths=0x%p; ItemCount=%u; DriverList=0x%p", DriverArrays, ArrayLengths, ItemCount, DriverList);

   *DriverList = NULL;
   // Compute the total number of Driver Object pointers stored inside
   // the arrays
   for (i = 0; i < ItemCount; ++i) 
      DriverCount += ArrayLengths[i];
   
   // Compute the total size of the new Driver List structure and allocate
   // storage for it. 
   DriverListSize = sizeof(SNAPSHOT_DRIVERLIST) + DriverCount * sizeof(PVOID);
   TmpDriverList = (PSNAPSHOT_DRIVERLIST)HeapMemoryAllocPaged(DriverListSize);
   if (TmpDriverList != NULL) {
      PDRIVER_OBJECT *Data = NULL;
      
      // Initialize the structure
      TmpDriverList->Size = DriverListSize;
      TmpDriverList->NumberOfDrivers = DriverCount;
      TmpDriverList->DriversOffset = sizeof(SNAPSHOT_DRIVERLIST);
      Data = (PDRIVER_OBJECT *)((PUCHAR)TmpDriverList + TmpDriverList->DriversOffset);
      // Copy addresses of Driver Objects from the arrays
      for (i = 0; i < ItemCount; ++i) {
         RtlCopyMemory(Data, DriverArrays[i], ArrayLengths[i] * sizeof(PDRIVER_OBJECT));
         Data += ArrayLengths[i];
      }

      // Report success and fill the output argument
      Status = STATUS_SUCCESS;
      *DriverList = TmpDriverList;
   } else Status = STATUS_INSUFFICIENT_RESOURCES;

   DEBUG_EXIT_FUNCTION("0x%x, *DriverList=0x%p", Status, *DriverList);
   return Status;
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
static NTSTATUS _GetDevicePnPInformation(PDEVICE_OBJECT DeviceObject, PWCHAR *DisplayName,
   PWCHAR *Description, PWCHAR *VendorName, PWCHAR *Enumerator, PWCHAR *ClassName, PWCHAR *ClassGuid, PWCHAR *Location)
{
   ULONG VendorNameLength = 0;
   ULONG DisplayNameLength = 0;
   ULONG DescriptionLength = 0;
   ULONG ClassLength = 0;
   ULONG EnumeratorLength = 0;
   ULONG LocationLength = 0;
   ULONG ClassGuidLength = 0;
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("DeviceObject=0x%p", DeviceObject);

   Status = _GetWCharDeviceProperty(DeviceObject, DevicePropertyClassName, ClassName, &ClassLength);
   if (NT_SUCCESS(Status)) {
      Status = _GetWCharDeviceProperty(DeviceObject, DevicePropertyDeviceDescription, Description, &DescriptionLength);
      if (NT_SUCCESS(Status)) {
         Status = _GetWCharDeviceProperty(DeviceObject, DevicePropertyFriendlyName, DisplayName, &DisplayNameLength);
         if (NT_SUCCESS(Status)) {
            Status = _GetWCharDeviceProperty(DeviceObject, DevicePropertyManufacturer, VendorName, &VendorNameLength);
            if (NT_SUCCESS(Status)) {
               Status = _GetWCharDeviceProperty(DeviceObject, DevicePropertyLocationInformation, Location, &LocationLength);
               if (NT_SUCCESS(Status)) {
                  Status = _GetWCharDeviceProperty(DeviceObject, DevicePropertyEnumeratorName, Enumerator, &EnumeratorLength);
                  if (NT_SUCCESS(Status)) {
                     Status = _GetWCharDeviceProperty(DeviceObject, DevicePropertyClassGuid, ClassGuid, &ClassGuidLength);
				  }
               }
            }
         }
      }
   }

   if (!NT_SUCCESS(Status)) {
      if (*Enumerator != NULL) {
         HeapMemoryFree(*Enumerator);
         *Enumerator = NULL;
      }

      if (*Location != NULL) {
         HeapMemoryFree(*Location);
         *Location = NULL;
      }

      if (*DisplayName != NULL) {
         HeapMemoryFree(*DisplayName);
         *DisplayName = NULL;
      }

      if (*VendorName != NULL) {
         HeapMemoryFree(*VendorName);
         *VendorName = NULL;
      }

      if (*Description != NULL) {
         HeapMemoryFree(*Description);
         *Description = NULL;
      }

      if (*ClassName != NULL) {
         HeapMemoryFree(*ClassName);
         *ClassName = NULL;
      }

      if (*ClassGuid != NULL) {
         HeapMemoryFree(*ClassGuid);
         *ClassGuid = NULL;
      }
   }

   DEBUG_EXIT_FUNCTION("0x%x", Status);
   return Status;
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
static VOID _CopyString(PWCHAR String, PVOID Record, PUCHAR *DataStart, PULONG_PTR OffsetField)
{
   SIZE_T StrLength = 0;
   DEBUG_ENTER_FUNCTION("String=\"%S\"; Record=0x%p; DataStart=0x%p; OffsetField=0x%p", String, Record, DataStart, OffsetField);

   if (String != NULL)
      StrLength = wcslen(String);

   *OffsetField = (ULONG_PTR)*DataStart - (ULONG_PTR)Record;
   RtlCopyMemory(*DataStart, String, StrLength * sizeof(WCHAR));
   ((PWCHAR)(*DataStart))[StrLength] = L'\0';
   *DataStart += (StrLength + 1) * sizeof(WCHAR);

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}

/************************************************************************/
/* VPB SNAPSHOT                                                         */
/************************************************************************/

static NTSTATUS _GetDeviceVpbInfo(PDEVICE_OBJECT DeviceObject, PSNAPSHOT_VPB_INFO *VpbSnapshot)
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
			tmpVpb->Size = allocLength;
			tmpVpb->FileSystemDeviceObject = vpb->DeviceObject;
			tmpVpb->Flags = vpb->Flags;
			tmpVpb->ReferenceCount = vpb->ReferenceCount;
            tmpVpb->SerialNumber = vpb->SerialNumber;
            tmpVpb->VolumeDeviceObject = vpb->RealDevice;
            tmpVpb->VolumeLabel = sizeof(SNAPSHOT_VPB_INFO);
            RtlCopyMemory((PUCHAR)tmpVpb + tmpVpb->VolumeLabel, &vpb->VolumeLabel, vpb->VolumeLabelLength);
            *VpbSnapshot = tmpVpb;
            status = STATUS_SUCCESS;
		} else status = STATUS_INSUFFICIENT_RESOURCES;
   } else status = STATUS_SUCCESS;

   IoReleaseVpbSpinLock(irql);

   DEBUG_EXIT_FUNCTION("0x%x, *VpbSnapshot=0x%p", status, *VpbSnapshot);
   return status;
}

static VOID _FreeDeviceVpbInfo(PSNAPSHOT_VPB_INFO Info)
{
   DEBUG_ENTER_FUNCTION("Info=0x%p", Info);

   HeapMemoryFree(Info);

   DEBUG_EXIT_FUNCTION_VOID();
   return;
}

static NTSTATUS _GetDeviceRelationsInfo(PDEVICE_OBJECT DeviceObject, DEVICE_RELATION_TYPE RelationType, PSNAPSHOT_DEVICE_RELATIONS_INFO *Info)
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

static SIZE_T _GetStringSize(PWCHAR String)
{
	return (String != NULL ? wcslen(String)*sizeof(WCHAR) : 0);
}

static SIZE_T _GetMultiStringSize(PWCHAR MultiString)
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

static NTSTATUS _GetDeviceAdvancedPnPInfo(PDEVICE_OBJECT DeviceObject, PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO *Info)
{
	PWCHAR deviceId = NULL;
	PWCHAR instanceId = NULL;
	PWCHAR hardwareIds = NULL;
	PWCHAR compatibleIds = NULL;
	DEVICE_CAPABILITIES capabilities;
	PSNAPSHOT_DEVICE_RELATIONS_INFO removalRelations = NULL;
	PSNAPSHOT_DEVICE_RELATIONS_INFO ejectRelations = NULL;
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; Info=0x%p", DeviceObject, Info);

	UtilsQueryDeviceId(DeviceObject, BusQueryDeviceID, &deviceId);
	UtilsQueryDeviceId(DeviceObject, BusQueryInstanceID, &instanceId);
	UtilsQueryDeviceId(DeviceObject, BusQueryHardwareIDs, &hardwareIds);
	UtilsQueryDeviceId(DeviceObject, BusQueryCompatibleIDs, &compatibleIds);
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
		ExFreePool(compatibleIds);

	if (hardwareIds != NULL)
		ExFreePool(hardwareIds);

	if (instanceId != NULL)
		ExFreePool(instanceId);

	if (deviceId != NULL)
		ExFreePool(deviceId);
	

	DEBUG_EXIT_FUNCTION("0x%x, *Info=0x%p", status, *Info);
	return status;
}

static VOID _FreeAdvancedPnPInfo(PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO Info)
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

static NTSTATUS _SecurityInfoCreate(PDEVICE_OBJECT DeviceObject, PSECURITY_DESCRIPTOR *Info)
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

static VOID _SecurityInfoFree(PSECURITY_DESCRIPTOR Info)
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
static NTSTATUS _DeviceInfoSnapshotCreate(PDEVICE_OBJECT DeviceObject, PSNAPSHOT_DEVICE_INFO *DeviceInfo)
{
	UNICODE_STRING DeviceName;
	PSNAPSHOT_DEVICE_INFO TmpDeviceInfo = NULL;
	NTSTATUS Status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DeviceObject=0x%p; DeviceInfo=0x%p", DeviceObject, *DeviceInfo);

	*DeviceInfo = NULL;
	// Retrieve name of the device object
	Status = _GetObjectName(DeviceObject, &DeviceName);
	if (NT_SUCCESS(Status)) {
		PDEVICE_OBJECT *UpperDevices = NULL;
		SIZE_T UpperDeviceCount = 0;
		PDEVICE_OBJECT DiskDevice = NULL;

		// Retrieve Disk Device Object, present in filesystem devices that correspond
		// to volumes.
		Status = IoGetDiskDeviceObject(DeviceObject, &DiskDevice);
		if (!NT_SUCCESS(Status))
			DiskDevice = NULL;

		// Retrieve addresses of Device Objects for lower devices in the
		// device stack.
		Status = _GetLowerUpperDevices(DeviceObject, TRUE, &UpperDevices, &UpperDeviceCount);
		if (NT_SUCCESS(Status)) {
			PDEVICE_OBJECT *LowerDevices = NULL;
			SIZE_T LowerDeviceCount = 0;

			// Retrieve addresses of Device Objects for upper devices in the
			// device stack.
			Status = _GetLowerUpperDevices(DeviceObject, FALSE, &LowerDevices, &LowerDeviceCount);
			if (NT_SUCCESS(Status)) {
				SIZE_T DeviceInfoSize = 0;
				PWCHAR DisplayName = NULL;
				PWCHAR Description = NULL;
				PWCHAR Vendor = NULL;
				PWCHAR Enumerator = NULL;
				PWCHAR Location = NULL;
				PWCHAR Class = NULL;
				PWCHAR ClassGuid = NULL;

				// Start to compute size of the Device Info record
				DeviceInfoSize = sizeof(SNAPSHOT_DEVICE_INFO) + DeviceName.Length + sizeof(WCHAR) + (LowerDeviceCount + UpperDeviceCount) * sizeof(PDEVICE_OBJECT);
				DeviceInfoSize += 7 * sizeof(WCHAR);
				if (DeviceObject->Flags & DO_BUS_ENUMERATED_DEVICE) {
					// The device has been enumerated by PnP. Try to retrieve
					// some information about it.
					Status = _GetDevicePnPInformation(DeviceObject, &DisplayName, &Description, &Vendor, &Enumerator, &Class, &ClassGuid, &Location);
					if (NT_SUCCESS(Status)) {
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
            
				if (NT_SUCCESS(Status)) {
					// Allocate the Device Info record
					TmpDeviceInfo = (PSNAPSHOT_DEVICE_INFO)HeapMemoryAllocPaged(DeviceInfoSize);
					if (TmpDeviceInfo != NULL) {
						PUCHAR Data = NULL;

						// Copy all information collected about the device into the
						// record.
						RtlZeroMemory(TmpDeviceInfo, DeviceInfoSize);
						TmpDeviceInfo->Size = DeviceInfoSize;
						TmpDeviceInfo->Characteristics = DeviceObject->Characteristics;
						TmpDeviceInfo->DeviceType = DeviceObject->DeviceType;
						TmpDeviceInfo->Flags = DeviceObject->Flags;
						TmpDeviceInfo->ObjectAddress = DeviceObject;
						TmpDeviceInfo->NumberOfLowerDevices = LowerDeviceCount;
						TmpDeviceInfo->NumberOfUpperDevices = UpperDeviceCount;
						TmpDeviceInfo->NameOffset = sizeof(SNAPSHOT_DEVICE_INFO);
						Data = (PUCHAR)TmpDeviceInfo + TmpDeviceInfo->NameOffset;
						RtlCopyMemory(Data, DeviceName.Buffer, DeviceName.Length);
						((PWCHAR)Data)[DeviceName.Length / sizeof(WCHAR)] = L'\0';
						Data += DeviceName.Length + sizeof(WCHAR);
						TmpDeviceInfo->LowerDevicesOffset = (ULONG_PTR)Data - (ULONG_PTR)TmpDeviceInfo;
						RtlCopyMemory(Data, LowerDevices, LowerDeviceCount * sizeof(PDEVICE_OBJECT));
						Data += LowerDeviceCount * sizeof(PDEVICE_OBJECT);
						TmpDeviceInfo->UpperDevicesOffset = (ULONG_PTR)Data - (ULONG_PTR)TmpDeviceInfo;
						RtlCopyMemory(Data, UpperDevices, UpperDeviceCount * sizeof(PDEVICE_OBJECT));
						Data += UpperDeviceCount * sizeof(PDEVICE_OBJECT);
						_CopyString(Class, TmpDeviceInfo, &Data, &TmpDeviceInfo->ClassNameOffset);
						_CopyString(DisplayName, TmpDeviceInfo, &Data, &TmpDeviceInfo->DisplayNameOffset);
						_CopyString(Description, TmpDeviceInfo, &Data, &TmpDeviceInfo->DescriptionOffset);
						_CopyString(Vendor, TmpDeviceInfo, &Data, &TmpDeviceInfo->VendorNameOffset);
						_CopyString(Enumerator, TmpDeviceInfo, &Data, &TmpDeviceInfo->EnumeratorOffset);
						_CopyString(Location, TmpDeviceInfo, &Data, &TmpDeviceInfo->LocationOffset);
						_CopyString(ClassGuid, TmpDeviceInfo, &Data, &TmpDeviceInfo->ClassGuidOffset);
						TmpDeviceInfo->DiskDevice = DiskDevice;
						TmpDeviceInfo->Vpb = DeviceObject->Vpb;
						Status = _SecurityInfoCreate(DeviceObject, &TmpDeviceInfo->Security);
						if (NT_SUCCESS(Status)) {
							Status = _GetDeviceVpbInfo(DeviceObject, &TmpDeviceInfo->VpbInfo);
							if (NT_SUCCESS(Status)) {
								if ((DeviceObject->Flags & DO_BUS_ENUMERATED_DEVICE) != 0)
									Status = _GetDeviceAdvancedPnPInfo(DeviceObject, &TmpDeviceInfo->AdvancedPnPInfo);

								if (!NT_SUCCESS(Status) && TmpDeviceInfo->VpbInfo != NULL)
									HeapMemoryFree(TmpDeviceInfo->VpbInfo);
							}

							if (NT_SUCCESS(Status))
								// Return the Device Info record and signal success of
								// the operation.
								*DeviceInfo = TmpDeviceInfo;
					
							if (!NT_SUCCESS(Status))
								_SecurityInfoFree(TmpDeviceInfo->Security);
						}

						if (!NT_SUCCESS(Status))
							HeapMemoryFree(TmpDeviceInfo);
					} else Status = STATUS_INSUFFICIENT_RESOURCES;
            
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

		HeapMemoryFree(DeviceName.Buffer);
	}

	DEBUG_EXIT_FUNCTION("0x%x, *DeviceInfo=0x%p", Status, *DeviceInfo);
	return Status;
}


/** Frees memory and potentially othe rresources allocated for
 *  a Device Info record.
 *
 *  @param Address of Device Info record to free.
 */
static VOID _DeviceInfoSnapshotFree(PSNAPSHOT_DEVICE_INFO DeviceInfo)
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
static NTSTATUS _DriverSnapshotCreate(PDRIVER_OBJECT DriverObject, PSNAPSHOT_DRIVER_INFO *DriverInfo)
{
	UNICODE_STRING DriverName;
	PSNAPSHOT_DRIVER_INFO TmpDriverInfo = NULL;
	NTSTATUS Status = STATUS_UNSUCCESSFUL;
	PDEVICE_OBJECT *DeviceArray = NULL;
	ULONG DeviceArrayLength = 0;
	DEBUG_ENTER_FUNCTION("DriverObject=0x%p; DriverInfo=0x%p", DriverObject, DriverInfo);
   
	*DriverInfo = NULL;
	// Get name of the driver
	Status = _GetObjectName(DriverObject, &DriverName);
	if (NT_SUCCESS(Status)) {
		// Enum its devices
		Status = _EnumDriverDevices(DriverObject, &DeviceArray, &DeviceArrayLength);
		if (NT_SUCCESS(Status)) {
			LONG i = 0;
			SIZE_T DriverInfoSize = 0;

			// Compute size of the new Driver Info record and allocate it.
			DriverInfoSize = sizeof(SNAPSHOT_DRIVER_INFO) + DriverName.Length + sizeof(WCHAR) + DeviceArrayLength * sizeof(PDEVICE_OBJECT);
			TmpDriverInfo = (PSNAPSHOT_DRIVER_INFO)HeapMemoryAllocPaged(DriverInfoSize);
			if (TmpDriverInfo != NULL) {
				LONG i = 0;
				PDEVICE_OBJECT *pDeviceObject = NULL;
				PUCHAR Data = (PUCHAR)((PUCHAR)TmpDriverInfo + sizeof(SNAPSHOT_DRIVER_INFO));
            
				// Initialize members of the Driver Info structure.
				// Do not copy FAST_IO_DISPATCH structure of the driver because
				// it may disappear during the operaion which whould made 
				// VrtuleTree unsafe.
				RtlZeroMemory(TmpDriverInfo, DriverInfoSize);
				TmpDriverInfo->Size = DriverInfoSize;
				TmpDriverInfo->ImageBase = DriverObject->DriverStart;
				TmpDriverInfo->ImageSize = DriverObject->DriverSize;
				TmpDriverInfo->DriverEntry = DriverObject->DriverInit;
				TmpDriverInfo->DriverUnload = DriverObject->DriverUnload;
				TmpDriverInfo->Flags = DriverObject->Flags;
				TmpDriverInfo->StartIo = DriverObject->DriverStartIo;
				TmpDriverInfo->ObjectAddress = DriverObject;
				for (i = 0; i < IRP_MJ_MAXIMUM_FUNCTION + 1; ++i)
					TmpDriverInfo->MajorFunctions[i] = DriverObject->MajorFunction[i];

				TmpDriverInfo->NumberOfDevices = DeviceArrayLength;
				TmpDriverInfo->DevicesOffset = (ULONG_PTR)Data - (ULONG_PTR)TmpDriverInfo;
				// Copy addresses of Device Object structures of the driver's
				// devices into the record. These addresses will be copied to
				// Device Info structures later created for individual devices of
				// the driver. The addresses in the record will be replaced with
				// addresses of the corresponding Device Info structures.
				RtlCopyMemory(Data, DeviceArray, DeviceArrayLength * sizeof(PDEVICE_OBJECT));
				Data += DeviceArrayLength * sizeof(PDEVICE_OBJECT);
				// Copy name of the driver
				TmpDriverInfo->NameOffset = (ULONG_PTR)Data - (ULONG_PTR)TmpDriverInfo;
				RtlCopyMemory(Data, DriverName.Buffer, DriverName.Length);
				((PWCHAR)Data)[DriverName.Length / sizeof(WCHAR)] = '\0';
					// Walk the Device Objects and replace them with DeviceInfo
					// records.
					pDeviceObject = (PDEVICE_OBJECT *)((PUCHAR)TmpDriverInfo + TmpDriverInfo->DevicesOffset);
					for (i = 0; i < TmpDriverInfo->NumberOfDevices; ++i) {
						Status = _DeviceInfoSnapshotCreate(pDeviceObject[i], (PSNAPSHOT_DEVICE_INFO *)&pDeviceObject[i]);
						if (!NT_SUCCESS(Status)) {
							LONG j = 0;

							for (j = i - 1; j >= 0; --j)
								_DeviceInfoSnapshotFree((PSNAPSHOT_DEVICE_INFO)pDeviceObject[j]);
               
							break;
						}
					}
            
					if (NT_SUCCESS(Status))
						*DriverInfo = TmpDriverInfo;

				if (!NT_SUCCESS(Status))
					HeapMemoryFree(TmpDriverInfo);

			} else Status = STATUS_INSUFFICIENT_RESOURCES;

			_ReleaseDeviceArray(DeviceArray, DeviceArrayLength);
		}

		HeapMemoryFree(DriverName.Buffer);
	}

	DEBUG_EXIT_FUNCTION("0x%x, *DriverInfo=0x%p", Status, *DriverInfo);
	return Status;
}


/** Frees memory allocated for Driver Info record. The routine also frees
 *  all Device Info records of devices owned by the driver in time when the
 *  Driver Info structure had been created.
 *
 *  @param DriverInfo Address of Driver Info structure to free.
 */
static VOID _DriverSnapshotFree(PSNAPSHOT_DRIVER_INFO DriverInfo)
{
	LONG i = 0;
	PSNAPSHOT_DEVICE_INFO *DeviceInfo = NULL;
	DEBUG_ENTER_FUNCTION("DriverInfo=0x%p", DriverInfo);

	DeviceInfo = (PSNAPSHOT_DEVICE_INFO *)((PUCHAR)DriverInfo + DriverInfo->DevicesOffset);
	for (i = 0; i < DriverInfo->NumberOfDevices; ++i)
		_DeviceInfoSnapshotFree(DeviceInfo[i]);

	HeapMemoryFree(DriverInfo);

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}

static ULONG _ComputeSnapshotSize(PVRTULETREE_KERNEL_SNAPSHOT Snapshot)
{
	ULONG i = 0;
	ULONG j = 0;
	ULONG snapshotSize = 0;
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

static VOID FORCEINLINE _CopyFlatPart(PUCHAR *AktPos, PVOID KernelBuffer, ULONG Size)
{
	memcpy(*AktPos, KernelBuffer, Size);
	(*AktPos) += Size;

	return;
}

static ULONG _CopySnapshot(PVRTULETREE_KERNEL_SNAPSHOT Snapshot, PVOID UserBuffer)
{
	ULONG i = 0;
	ULONG j = 0;
	PUCHAR aktPos = (PUCHAR)UserBuffer;
	ULONG dataSize = 0;
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
 *  @param Snapshot Address of variable that, in case of success, receives
 *  address of the new snapshot.
 *
 *  @return Returns NTSTATUS value indicating success or failure of the
 *  operation.
 *
 *  @remark The routine inserts the snapshot to the list of snapshot. The
 *  routine is thread-safe.
 */
NTSTATUS SnapshotCreate(PVRTULETREE_KERNEL_SNAPSHOT *Snapshot)
{
   PSNAPSHOT_DRIVERLIST DriverList = NULL;
   UNICODE_STRING DriverDirectory;
   PDRIVER_OBJECT *NormalDrivers = NULL;
   SIZE_T NormalDriverCount = 0;
   PDRIVER_OBJECT *FileSystemDrivers = NULL;
   SIZE_T FileSystemDriverCount = 0;
   NTSTATUS Status = STATUS_UNSUCCESSFUL;
   DEBUG_ENTER_FUNCTION("Snapshot=0x%p", Snapshot);

   // Collect Driver Objects from \Driver directory
   RtlInitUnicodeString(&DriverDirectory, L"\\Driver");
   Status = _GetDriversInDirectory(&DriverDirectory, &NormalDrivers, &NormalDriverCount);
   if (NT_SUCCESS(Status)) {
      // Collect Driver Objects from \FileSystem directory
      RtlInitUnicodeString(&DriverDirectory, L"\\FileSystem");
      Status = _GetDriversInDirectory(&DriverDirectory, &FileSystemDrivers, &FileSystemDriverCount);
      if (NT_SUCCESS(Status)) {
         PDRIVER_OBJECT *DriverArrays [2] = {NormalDrivers, FileSystemDrivers};
         SIZE_T ArrayLengths [2] = {NormalDriverCount, FileSystemDriverCount};

         // Create a node representing the list of drivers in the snapshot.
         // The node will contain all drivers found in \Driver and \FileSystem
         // directories. Creation of the node does not cause creation of
         // Driver Info and Device Info records.
         Status = _DriverListNodeCreate(DriverArrays, ArrayLengths, sizeof(ArrayLengths) / sizeof(SIZE_T), &DriverList);
         if (NT_SUCCESS(Status)) {
            LONG i = 0;
            PDRIVER_OBJECT *DriverObject = NULL;

            // Create Driver Info records for all drivers in the snapshot.
            // This will also cause the Device Info records to be created.
            DriverObject = (PDRIVER_OBJECT *)((PUCHAR)DriverList + DriverList->DriversOffset);
            for (i = 0; i < DriverList->NumberOfDrivers; ++i) {
               Status = _DriverSnapshotCreate(DriverObject[i], (PSNAPSHOT_DRIVER_INFO *)&DriverObject[i]);
               if (!NT_SUCCESS(Status)) {
                  LONG j = 0;

                  for (j = i - 1; j >= 0; --j)
                     _DriverSnapshotFree((PSNAPSHOT_DRIVER_INFO)DriverObject[j]);
               
                  break;
               }
            }

            if (NT_SUCCESS(Status)) {
               PVRTULETREE_KERNEL_SNAPSHOT TmpSnapshot = NULL;
               
               // Allocate snapshot record, initialize it and insert it
               // into the list of snapshots
               TmpSnapshot = (PVRTULETREE_KERNEL_SNAPSHOT)HeapMemoryAllocPaged(DriverList->Size + sizeof(VRTULETREE_KERNEL_SNAPSHOT) - sizeof(SNAPSHOT_DRIVERLIST));
               if (TmpSnapshot != NULL) {
                  RtlCopyMemory(&TmpSnapshot->DriverList, DriverList, DriverList->Size);                  
                  *Snapshot = TmpSnapshot;
                  Status = STATUS_SUCCESS;
               } else Status = STATUS_INSUFFICIENT_RESOURCES;

               if (!NT_SUCCESS(Status)) {
                  PSNAPSHOT_DRIVER_INFO *DriverInfo = NULL;

                  DriverInfo = (PSNAPSHOT_DRIVER_INFO *)((PUCHAR)DriverList + DriverList->DriversOffset);
                  for (i = 0; i < DriverList->NumberOfDrivers; ++i)
                     _DriverSnapshotFree(DriverInfo[i]);
               }
            }

            HeapMemoryFree(DriverList);
         }

         _ReleaseDriverArray(FileSystemDrivers, FileSystemDriverCount);
      }

      _ReleaseDriverArray(NormalDrivers, NormalDriverCount);
   }

   DEBUG_EXIT_FUNCTION("0x%x, *Snapshot=0x%p", Status, *Snapshot);
   return Status;
}


/** Releases memory occupied by given snapshot.
 *
 *  @param Snapshot The snapshot.
 */
VOID SnapshotFree(PVRTULETREE_KERNEL_SNAPSHOT Snapshot)
{
   LONG i = 0;
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

NTSTATUS SnapshotToUser(PVRTULETREE_KERNEL_SNAPSHOT Snapshot, PVOID *Address)
{
	PVOID tmpAddress = NULL;
	ULONG snapshotSize = 0;
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
