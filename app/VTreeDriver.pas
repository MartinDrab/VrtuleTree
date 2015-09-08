Unit VTreeDriver;

Interface

{$Z4}
{$MINENUMSIZE 4}


Uses
  Windows;

Type
  DEVICE_POWER_STATE = (
    PowerDeviceUnspecified  = 0,
    PowerDeviceD0           = 1,
    PowerDeviceD1           = 2,
    PowerDeviceD2           = 3,
    PowerDeviceD3           = 4,
    PowerDeviceMaximum      = 5
  );

  SYSTEM_POWER_STATE = (
    PowerSystemUnspecified  = 0,
    PowerSystemWorking      = 1,
    PowerSystemSleeping1    = 2,
    PowerSystemSleeping2    = 3,
    PowerSystemSleeping3    = 4,
    PowerSystemHibernate    = 5,
    PowerSystemShutdown     = 6,
    PowerSystemMaximum      = 7
  );

Const
  POWER_SYSTEM_MAXIMUM = 7;

Type
  DEVICE_CAPABILITIES = Record
    SIze : Word;
    Version : Word;
    Flags : Cardinal;
    Address : Cardinal;
    UINumber : Cardinal;
    DeviceState : Array [0..POWER_SYSTEM_MAXIMUM - 1] Of DEVICE_POWER_STATE;
    SystemWake : SYSTEM_POWER_STATE;
    DeviceWake : SYSTEM_POWER_STATE;
    D1Latency : Cardinal;
    D2Latency : Cardinal;
    D3Latency : Cardinal;
    end;
  PDEVICE_CAPABILITIES = ^DEVICE_CAPABILITIES;

  TDriverMajorFunctions = Packed Array [0..27] Of Pointer;

  TSnapshotType = (stDriverList, stDriverInfo, stDeviceInfo);

  TDeviceCapabilities = Record
    Version : Cardinal;
    DeviceD1 : Boolean;
    DeviceD2 : Boolean;
    LockSupported : Boolean;
    EjectSupported : Boolean;
    Removable : Boolean;
    DockDevice : Boolean;
    UniqueId : Boolean;
    SilentInstall : Boolean;
    RawDeviceOK : Boolean;
    SurpriseRemovalOK : Boolean;
    WakeFromD0 : Boolean;
    wakeFromD1 : Boolean;
    WakeFromD2 : Boolean;
    wakeFromD3 : Boolean;
    HardwareDisabled : Boolean;
    NonDynamic : Boolean;
    WarmEjectSupported : Boolean;
    NoDisplayInUI : Boolean;
    Address : Cardinal;
    UINumber : Cardinal;
    State : Array [0..POWER_SYSTEM_MAXIMUM - 1] Of DEVICE_POWER_STATE;
    SystemWake : SYSTEM_POWER_STATE;
    DeviceAke : DEVICE_POWER_STATE;
    D1Latency : Cardinal;
    D2Latency : Cardinal;
    D3Latency : Cardinal;
    end;
  PDeviceCapabilities = ^TDeviceCapabilities;

  TVpbSnapshot = Record
    VpbAddress : Pointer;
    Name : WideString;
    FileSystemDevice : Pointer;
    VolumeDevice : Pointer;
    Flags : Cardinal;
    ReferenceCount : Cardinal;
    end;
  PVpbSnapshot = ^TVpbSnapshot;

  TDeviceSnapshot = Record
    Name : WideString;
    Address : Pointer;
    DriverName : WideString;
    DriverAddress : Pointer;
    NumberOfLowerDevices : Integer;
    LowerDevices : Array Of Pointer;
    NumberOfUpperDevices : Integer;
    UpperDevices : Array Of Pointer;
    DisplayName : WideString;
    Description : WideString;
    Vendor : WideString;
    ClassName : WideString;
    Location : WideString;
    Enumerator : WideString;
    ClassGuid : WideString;
    Flags : Cardinal;
    Characteristics : Cardinal;
    DeviceType : Cardinal;
    DiskDeviceAddress : Pointer;
    Vpb : PVpbSnapshot;
    DeviceId : WideString;
    InstanceId : WideString;
    HardwareIds : Array Of WideString;
    CompatibleIds : Array Of WideString;
    RemovalRelations : Array Of Pointer;
    EjectRelations : Array Of Pointer;
    end;
  PDeviceSnapshot = ^TDeviceSnapshot;

  TDriverSnapshot = Record
    Name : WideString;
    Address : Pointer;
    DriverEntry : Pointer;
    DriverUnload : Pointer;
    StartIo : Pointer;
    Flags : Cardinal;
    ImageBase : Pointer;
    ImageSize : Cardinal;
    ImagePath : WideString;
    MajorFunction : TDriverMajorFunctions;
    NumberOfDevices : Integer;
    Devices : Array Of Pointer;
    end;
  PDriverSnapshot = ^TDriverSnapshot;

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
    end;
  PSNAPSHOT_DEVICEINFO = ^SNAPSHOT_DEVICEINFO;

Function DriverInstall:Boolean;
Procedure DriverUninstall;
Function DriverLoad:Boolean;
Procedure DriverUnload;

Function DriverCreateSnapshot(Var ASnapshot:Pointer):Boolean;
Function DriverFreeSnapshot(ASnapshot:Pointer):Boolean;

Implementation

Uses
  SysUtils, scmDrivers, Utils;

Const
  DriverServiceName = 'VrtuleTree';
  DriverFIleName = 'VrtuleTree.sys';
  DriverDeviceName = '\\.\VrtuleTree';

  IOCTL_VRTULETREE_CREATE_SNAPSHOT          = $228008;


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

Function DriverCreateSnapshot(Var ASnapshot:Pointer):Boolean;
begin
Result := DriverIOCTL(IOCTL_VRTULETREE_CREATE_SNAPSHOT, Nil, 0, @ASnapshot, SizeOf(ASnapshot));
end;

Function DriverFreeSnapshot(ASnapshot:Pointer):Boolean;
begin
Result := VirtualFree(ASnapshot, 0, MEM_RELEASE);
end;


End.

