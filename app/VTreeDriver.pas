Unit VTreeDriver;

Interface

{$Z4}
{$MINENUMSIZE 4}


Uses
  Windows, Kernel;

Const
  VTREE_SNAPSHOT_DEVICE_ID        = $1;
  VTREE_SNAPSHOT_FAST_IO_DISPATCH = $2;
  VTREE_SNAPSHOT_DEVNODE_TREE     = $4;

Type
  _VRTULETREE_KERNEL_SNAPSHOT_INPUT = Record
    SnapshotFlags : Cardinal;
    end;
  VRTULETREE_KERNEL_SNAPSHOT_INPUT = _VRTULETREE_KERNEL_SNAPSHOT_INPUT;
  PVRTULETREE_KERNEL_SNAPSHOT_INPUT = ^VRTULETREE_KERNEL_SNAPSHOT_INPUT;

  TDriverMajorFunctions = Packed Array [0..27] Of Pointer;

  TSnapshotType = (stDriverList, stDriverInfo, stDeviceInfo);

  TSnapshot = Record
    NumberOfDrivers : Integer;
    Drivers : Array Of Pointer;
    end;
  PSnapshot = ^TSnapshot;

  SNAPSHOT_DRIVERLIST = Record
    Size : NativeInt;
    NumberOfDrivers : NativeInt;
    DriversOffset : NativeInt;
    end;
  PSNAPSHOT_DRIVERLIST = ^SNAPSHOT_DRIVERLIST;

  SNAPSHOT_DRIVERINFO = Record
    Size : NativeInt;
    ImageBase : Pointer;
    ImageSize : Cardinal;
    Flags : Cardinal;
    StartIo : Pointer;
    DriverEntry : Pointer;
    DriverUnload : Pointer;
    NameOffset : NativeInt;
    ObjectAddress : Pointer;
    NumberOfDevices : NativeInt;
    DevicesOffset : NativeInt;
    MajorFunction : TDriverMajorFunctions;
    FastIoAddress : Pointer;
    FastIoDispatch : FAST_IO_DISPATCH;
    end;
  PSNAPSHOT_DRIVERINFO = ^SNAPSHOT_DRIVERINFO;

  SNAPSHOT_VPBINFO = Record
    Size : Cardinal;
    Flags : Cardinal;
    SerialNumber : Cardinal;
    ReferenceCount : Cardinal;
    FileSystemDevice : Pointer;
    VolumeDevice : Pointer;
    VolumeLabel : NativeUInt;
    end;
  PSNAPSHOT_VPBINFO = ^SNAPSHOT_VPBINFO;

  SNAPSHOT_DEVICE_RELATIONS_INFO = Record
    Count : Cardinal;
    Size : Cardinal;
    RelationsOffset : NativeUInt;
    end;
  PSNAPSHOT_DEVICE_RELATIONS_INFO = ^SNAPSHOT_DEVICE_RELATIONS_INFO;

  SNAPSHOT_DEVICE_ADVANCED_PNP_INFO = Record
    Size : NativeUInt;
    DeviceId : NativeUInt;
    Instanceid : NativeUInt;
    HardwareId : NativeUInt;
    CompatibleId : NativeUInt;
    RemovalRelations : PSNAPSHOT_DEVICE_RELATIONS_INFO;
    EjectRelations : PSNAPSHOT_DEVICE_RELATIONS_INFO;
    DeviceCapabilities : DEVICE_CAPABILITIES;
    end;
  PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO = ^SNAPSHOT_DEVICE_ADVANCED_PNP_INFO;

  SNAPSHOT_DEVICEINFO = Record
    Size : NativeInt;
    NameOffset : NativeInt;
    ObjectAddress : Pointer;
    Flags : Cardinal;
    Characteristics : Cardinal;
    DeviceType : Cardinal;
    NumberOfLowerDevices : NativeInt;
    LowerDevicesOffset : NativeInt;
    NumberOfUpperDevices : NativeInt;
    UpperDevicesOffset : NativeInt;
    DisplayNameOffset : NativeInt;
    VendorNameOffset : NativeInt;
    DescriptionOffset : NativeInt;
    EnumeratorOffset : NativeInt;
    LocationOffset : NativeInt;
    ClassNameOffset : NativeInt;
    ClassGuidOffset : NativeInt;
    DiskDevice : Pointer;
    Vpb : Pointer;
    VpbSnapshot : Pointer;
    AdvancedPnPInfo : PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO;
    Security : PSECURITY_DESCRIPTOR;
    DeviceNode : Pointer;
    Parent : Pointer;
    Child : Pointer;
    Sibling : Pointer;
    ExtensionFlags : Cardinal;
    PowerFlags : Cardinal;
    end;
  PSNAPSHOT_DEVICEINFO = ^SNAPSHOT_DEVICEINFO;

  _SPECIAL_VALUES = Record
    Case Integer Of
      0 : (
        RoutineAddress : Array [0..8] Of Pointer;
      );
      1 : (
        IopInvalidDeviceRequest : Pointer;
        FsRtlAcquireFileExclusive : Pointer;
        FsRtlCopyRead : Pointer;
        FsRtlCopyWrite : Pointer;
        FsRtlMdlReadDev : Pointer;
        FsRtlMdlReadCompleteDev : Pointer;
        FsRtlPrepareMdlWriteDev : Pointer;
        FsRtlMdlWriteCompleteDev : Pointer;
        FsRtlReleaseFile : Pointer;
      );
    end;
  SPECIAL_VALUES = _SPECIAL_VALUES;
  PSPECIAL_VALUES = ^SPECIAL_VALUES;

Function DriverInstall:Boolean;
Procedure DriverUninstall;
Function DriverLoad:Boolean;
Procedure DriverUnload;

Function DriverCreateSnapshot(AFlags:Cardinal; Var ASnapshot:Pointer):Boolean;
Function DriverGetSpecialValues(AValues:PSPECIAL_VALUES):Boolean;
Function DriverFreeSnapshot(ASnapshot:Pointer):Boolean;

Implementation

Uses
  SysUtils, scmDrivers, Utils;

Const
  DriverServiceName = 'VrtuleTree';
  DriverFIleName = 'VrtuleTree.sys';
  DriverDeviceName = '\\.\VrtuleTree';

  IOCTL_VRTULETREE_CREATE_SNAPSHOT          = $228008;
  IOCTL_VRTULETREE_SPECIAL_VALUES_GET       = $22800c;


Var
  hDevice : THandle;

Function DriverInstall:Boolean;
Var
  FullFileName : WideString;
begin
FullFileName := Format('%s%s', [ExtractFilePath(ParamStr(0)), DriverFileName]);
Result := ScmDriverInstall(DriverServiceName, FullFileName);
end;

Procedure DriverUninstall;
begin
ScmDriverUninstall(DriverServiceName);
end;

Function DriverLoad:Boolean;
begin
Result := ScmDriverLoad(DriverServiceName);
If Result Then
  begin
  hDevice := CreateFileW(DriverDeviceName, GENERIC_ALL, 0, Nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  Result := hDevice <> INVALID_HANDLE_VALUE;
  If Not Result Then
    ScmDriverUnload(DriverServiceName);
  end;
end;

Procedure DriverUnload;
begin
CloseHandle(hDevice);
ScmDriverUnload(DriverServiceName);
end;

Function DriverIOCTL(ACode:Cardinal; AInBuffer:Pointer; AInBufferLength:Integer; AOutBUffer:Pointer; AOutBufferLength:Cardinal):Boolean;
Var
  Dummy : DWORD;
begin
Result := DeviceIoControl(hDevice, ACode, AInBuffer, AInBufferLength, AOutBUffer, AOutBufferLength, Dummy, Nil);
end;

Function DriverGetSpecialValues(AValues:PSPECIAL_VALUES):Boolean;
begin
ZeroMemory(AValues, SizeOf(SPECIAL_VALUES));
Result := DriverIOCTL(IOCTL_VRTULETREE_SPECIAL_VALUES_GET, Nil, 0, AValues, SizeOf(SPECIAL_VALUES));
end;

Function DriverCreateSnapshot(AFlags:Cardinal; Var ASnapshot:Pointer):Boolean;
Var
  inData : VRTULETREE_KERNEL_SNAPSHOT_INPUT;
begin
inData.SnapshotFlags := AFlags;
Result := DriverIOCTL(IOCTL_VRTULETREE_CREATE_SNAPSHOT, @inData, SizeOf(inData), @ASnapshot, SizeOf(ASnapshot));
end;

Function DriverFreeSnapshot(ASnapshot:Pointer):Boolean;
begin
Result := VirtualFree(ASnapshot, 0, MEM_RELEASE);
end;


End.

