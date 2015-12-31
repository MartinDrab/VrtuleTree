unit DeviceSnapshot;

interface

Uses
  VTreeDriver, Kernel, AbstractSnapshotRecord, DriverSnapshot;

Type
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

  TDeviceSnapshot = Class (TAbstractSnapshotRecord)
    Private
      FName : WideString;
      FAddress : Pointer;
      FDriverName : WideString;
      FDriverAddress : Pointer;
      FNumberOfLowerDevices : Integer;
      FLowerDevices : TPointerArray;
      FNumberOfUpperDevices : Integer;
      FUpperDevices : TPointerArray;
      FDisplayName : WideString;
      FDescription : WideString;
      FVendor : WideString;
      FClassName : WideString;
      FLocation : WideString;
      FEnumerator : WideString;
      FClassGuid : WideString;
      FFlags : Cardinal;
      FCharacteristics : Cardinal;
      FDeviceType : Cardinal;
      FDiskDeviceAddress : Pointer;
      FVpb : TVpbSnapshot;
      FDeviceId : WideString;
      FInstanceId : WideString;
      FNumberOfHardwareIds : Cardinal;
      FHardwareIds : TWideStringArray;
      FNumberOfCompatibleIds : Cardinal;
      FCompatibleIds : TWideStringArray;
      FNumberOfRemovalRelations : Cardinal;
      FRemovalRelations : TPointerArray;
      FNumberOfEjectRelations : Cardinal;
      FEjectRelations : TPointerArray;
      FDeviceNode : Pointer;
      FChild : Pointer;
      FParent : Pointer;
      FSibling : Pointer;
      FExtensionFlags : Cardinal;
      FPowerFlags : Cardinal;
      FCapabilities : TDeviceCapabilities;
      Procedure CreateVpbRecord(AVpbInfo:PSNAPSHOT_VPBINFO; Var AVpbRecord:TVpbSnapshot);
      Procedure FillDeviceCapabilities(Var ADC:DEVICE_CAPABILITIES);
    Protected
      Function GetLowerDevice(AIndex:Integer):Pointer;
      Function GetUpperDevice(AIndex:Integer):Pointer;
      Function GetEjectRelation(AIndex:Integer):Pointer;
      Function GetRemovalRelation(AIndex:Integer):Pointer;
      Function GetHardwareId(AIndex:Integer):WideString;
      Function GetCompatibleId(AIndex:Integer):WideString;
    Public
      Constructor Create(ADeviceInfo:PSNAPSHOT_DEVICEINFO; ADriverSnapshot:TDriverSnapshot); Reintroduce;
      Destructor Destroy; Override;

      Property Name : WideString Read FName;
      Property Address : Pointer Read FAddress;
      Property DriverName : WideString Read FDriverName;
      Property DriverAddress : Pointer Read FDriverAddress;
      Property NumberOfLowerDevices : Integer Read FNumberOfLowerDevices;
      Property LowerDevice [Index:Integer] : Pointer Read GetLowerDevice;
      Property LowerDevices : TPointerArray Read FLowerDevices;
      Property NumberOfUpperDevices : Integer Read FNumberOfUpperDevices;
      Property UpperDevice [Index:Integer] : Pointer Read GetUpperDevice;
      Property UpperDevices : TPointerArray Read FUpperDevices;
      Property DisplayName : WideString Read FDisplayName;
      Property Description : WideString Read FDescription;
      Property Vendor : WideString Read FVendor;
      Property ClassName : WideString Read FClassName;
      Property Location : WideString Read FLocation;
      Property Enumerator : WideString Read FEnumerator;
      Property ClassGuid : WideString Read FClassGuid;
      Property Flags : Cardinal Read FFlags;
      Property Characteristics : Cardinal Read FCharacteristics;
      Property DeviceType : Cardinal Read FDeviceType;
      Property DiskDeviceAddress : Pointer Read FDiskDeviceAddress;
      Property DeviceId : WideString Read FDeviceId;
      Property InstanceId : WideString Read FInstanceId;
      Property NumberOfHardwareIds : Cardinal Read FNumberOfHardwareIds;
      Property HardwareId [Index:Integer] : WideString Read GetHardwareId;
      Property HardwareIds : TWideStringArray Read FHardwareIds;
      Property NumberOfCompatibleIds : Cardinal Read FNumberOfCompatibleIds;
      Property CompatibleId [Index:Integer] : WideString Read GetCompatibleId;
      Property CompatibleIds : TWideStringArray Read FCompatibleIds;
      Property NumberOfRemovalRelations : Cardinal Read FNumberOfRemovalRelations;
      Property RemovalRelation [Index:Integer] : Pointer Read GetRemovalRelation;
      Property RemovalRelations : TPointerArray Read FRemovalRelations;
      Property NumberOfEjectRelations : Cardinal Read FNumberOfEjectRelations;
      Property EjectRelation [Index:Integer] : Pointer Read GetEjectRelation;
      Property EjectRelations:TPointerArray Read FEjectRelations;
      Property DeviceNode : Pointer Read FDeviceNode;
      Property Child : Pointer Read FChild;
      Property Parent : Pointer Read FParent;
      Property Sibling : Pointer Read FSibling;
      Property ExtensionFlags : Cardinal Read FExtensionFlags;
      Property PowerFlags : Cardinal Read FPowerFlags;
      Property Capabilities : TDeviceCapabilities Read FCapabilities;
      Property Vpb : TVpbSnapshot Read FVpb;
    end;


implementation

Uses
  SysUtils, Utils;

Constructor TDeviceSnapshot.Create(ADeviceInfo:PSNAPSHOT_DEVICEINFO; ADriverSnapshot:TDriverSnapshot);
Var
  tmp : PWideChar;
  pDevice : PPointer;
  K : Integer;
  AdvPnP : PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO;
begin
Inherited Create(srtDevice);
FAddress := ADeviceInfo.ObjectAddress;
FName := CopyString(ADeviceInfo, ADeviceInfo.NameOffset);
FDriverName := ADriverSnapshot.Name;
FDriverAddress := ADriverSnapshot.Address;
FDisplayName := CopyString(ADeviceInfo, ADeviceInfo.DisplayNameOffset);
If (Length(FDisplayName) > 1) And (FDisplayName[1] = '@') Then
  begin
  If Not LoadStringFromPath(FDisplayName, FDisplayName) Then
    FDisplayName := CopyString(ADeviceInfo, ADeviceInfo.DisplayNameOffset);
  end;

FDescription := CopyString(ADeviceInfo, ADeviceInfo.DescriptionOffset);
If (Length(FDescription) > 1) And (FDescription[1] = '@') Then
  begin
  If Not LoadStringFromPath(FDescription, FDescription) Then
    FDescription := CopyString(ADeviceInfo, ADeviceInfo.DescriptionOffset);
  end;

FVendor := CopyString(ADeviceInfo, ADeviceInfo.VendorNameOffset);
FLocation := CopyString(ADeviceInfo, ADeviceInfo.LocationOffset);
FClassName := CopyString(ADeviceInfo, ADeviceInfo.ClassNameOffset);
FEnumerator := CopyString(ADeviceInfo, ADeviceInfo.EnumeratorOffset);
FClassGuid := CopyString(ADeviceInfo, ADeviceInfo.ClassGuidOffset);
FFlags := ADeviceInfo.Flags;
FCharacteristics := ADeviceInfo.Characteristics;
FDeviceType := ADeviceInfo.DeviceType;
FDiskDeviceAddress := ADeviceInfo.DiskDevice;
FNumberOfLowerDevices := ADeviceInfo.NumberOfLowerDevices;
FNumberOfUpperDevices := ADeviceInfo.NumberOfUpperDevices;
SetLength(FLowerDevices, FNumberOfLowerDevices);
SetLength(FUpperDevices, FNumberOfUpperDevices);
pDevice := PPointer(NativeInt(ADeviceInfo) + ADeviceInfo.LowerDevicesOffset);
For K := 0 To FNumberOfLowerDevices - 1 Do
  begin
  FLowerDevices[K] := pDevice^;
  Inc(pDevice);
  end;

pDevice := PPointer(NativeInt(ADeviceInfo) + ADeviceInfo.UpperDevicesOffset);
For K := 0 To FNumberOfUpperDevices - 1 Do
  begin
  FUpperDevices[K] := pDevice^;
  Inc(pDevice);
  end;

If Assigned(ADeviceInfo.VpbSnapshot) Then
  begin
  CreateVpbRecord(ADeviceInfo.VpbSnapshot, FVpb);
  FVpb.VpbAddress := ADeviceInfo.Vpb;
  end;

SetLength(FRemovalRelations, 0);
SetLength(FEjectRelations, 0);
FDeviceId := '';
FInstanceId := '';
SetLength(FHardwareIds, 0);
SetLength(FCompatibleIds, 0);
FDeviceNode := ADeviceInfo.DeviceNode;
FChild := ADeviceInfo.Child;
FParent := ADeviceInfo.Parent;
FSibling := ADeviceInfo.Sibling;
FExtensionFlags := ADeviceInfo.ExtensionFlags;
FPowerFlags := ADeviceInfo.PowerFlags;
AdvPnP := ADeviceInfo.AdvancedPnPInfo;
FNumberOfHardwareIds := 0;
FNumberOfCompatibleIds := 0;
FNumberOfRemovalRelations := 0;
FNumberOfEjectRelations := 0;
If Assigned(AdvPnP) Then
  begin
  FDeviceId := CopyString(AdvPnP, AdvPnP.DeviceId);
  FInstanceId := CopyString(AdvPnP, AdvPnP.Instanceid);
  If Assigned(AdvPnP.RemovalRelations) Then
    begin
    pDevice := PPointer(NativeUInt(AdvPnP.RemovalRelations) + AdvPnP.RemovalRelations.RelationsOffset);
    FNumberOfRemovalRelations := AdvPnP.RemovalRelations.Count;
    SetLength(FRemovalRelations, FNumberOfRemovalRelations);
    For K := 0 To FNumberOfRemovalRelations - 1 Do
      begin
      FRemovalRelations[K] := pDevice^;
      Inc(pDevice);
      end;
    end;

  If Assigned(AdvPnP.EjectRelations) Then
    begin
    pDevice := PPointer(NativeUInt(AdvPnP.EjectRelations) + AdvPnP.EjectRelations.RelationsOffset);
    FNumberOfEjectRelations := AdvPnP.EjectRelations.Count;
    SetLength(FEjectRelations, FNumberOfEjectRelations);
    For K := 0 To FNumberOfEjectRelations - 1 Do
      begin
      FEjectRelations[K] := pDevice^;
      Inc(pDevice);
      end;
    end;

  tmp := PWideChar(NativeUInt(AdvPnP) + AdvPnP.HardwareId);
  If tmp^ <> #0 Then
    begin
    Repeat
    Inc(FNumberOfHardwareIds);
    SetLength(FHardwareIds, Length(FHardwareIds) + 1);
    FHardwareIds[FNumberOfHardwareIds - 1] := Copy(WideString(tmp), 1, StrLen(tmp));
    Inc(tmp, StrLen(tmp) + 1);
    Until tmp^ = #0;
    end;

  tmp := PWideChar(NativeUInt(AdvPnP) + AdvPnP.CompatibleId);
  If tmp^ <> #0 Then
    begin
    Repeat
    Inc(FNumberOfCompatibleIds);
    SetLength(FCompatibleIds, FNumberOfCompatibleIds);
    FCompatibleIds[FNumberofCompatibleIds - 1] := Copy(WideString(tmp), 1, StrLen(tmp));
    Inc(tmp, StrLen(tmp) + 1);
    Until tmp^ = #0;
    end;

  FillDeviceCapabilities(AdvPnp.DeviceCapabilities);
  end;
end;

Destructor TDeviceSnapshot.Destroy;
begin
SetLength(FLowerDevices, 0);
SetLength(FUpperDevices, 0);
Setlength(FRemovalRelations, 0);
SetLength(FEjectRelations, 0);
Inherited Destroy;
end;

Function TDeviceSnapshot.GetLowerDevice(AIndex:Integer):Pointer;
begin
Result := FLowerDevices[AIndex];
end;

Function TDeviceSnapshot.GetUpperDevice(AIndex:Integer):Pointer;
begin
Result := FUpperDevices[AIndex];
end;

Function TDeviceSnapshot.GetEjectRelation(AIndex:Integer):Pointer;
begin
Result := FEjectRelations[AIndex];
end;

Function TDeviceSnapshot.GetRemovalRelation(AIndex:Integer):Pointer;
begin
Result := FRemovalRelations[AIndex];
end;

Function TDeviceSnapshot.GetHardwareId(AIndex:Integer):WideString;
begin
Result := FHardwareIds[AIndex];
end;

Function TDeviceSnapshot.GetCompatibleId(AIndex:Integer):WideString;
begin
Result := FCompatibleIds[AIndex];
end;

Procedure TDeviceSnapshot.CreateVpbRecord(AVpbInfo:PSNAPSHOT_VPBINFO; Var AVpbRecord:TVpbSnapshot);
begin
AVpbRecord.VpbAddress := Nil;
AVpbRecord.Name := CopyString(AVpbInfo, AVpbInfo.VolumeLabel);
AVpbRecord.FileSystemDevice := AVpbInfo.FileSystemDevice;
AVpbRecord.VolumeDevice := AVpbInfo.VolumeDevice;
AVpbRecord.Flags := AVpbInfo.Flags;
AVpbRecord.ReferenceCount := AVpbInfo.ReferenceCount;
end;

Procedure TDeviceSnapshot.FillDeviceCapabilities(Var ADC:DEVICE_CAPABILITIES);
begin
FCapabilities.Version := ADC.Version;
FCapabilities.UINumber := ADC.UINumber;
FCapabilities.Address := ADC.Address;
FCapabilities.D1Latency := ADC.D1Latency;
FCapabilities.D2Latency := ADC.D2Latency;
FCapabilities.D3Latency := ADC.D3Latency;
FCapabilities.DeviceD1 := (ADC.Flags And DEVCAP_DEVICE_D1) <> 0;
FCapabilities.DeviceD2 := (ADC.Flags And DEVCAP_DEVICE_D2) <> 0;
FCapabilities.LockSupported := (ADC.Flags And DEVCAP_LOCK_SUPPORTED) <> 0;
FCapabilities.EjectSupported := (ADC.Flags And DEVCAP_EJECT_SUPPORTED) <> 0;
FCapabilities.Removable := (ADC.Flags And DEVCAP_REMOVABLE) <> 0;
FCapabilities.DockDevice := (ADC.Flags And DEVCAP_DOCK_DEVICE) <> 0;
FCapabilities.UniqueId := (ADC.Flags And DEVCAP_UNIQUE_ID) <> 0;
FCapabilities.SilentInstall := (ADC.Flags And DEVCAP_SILENT_INSTALL) <> 0;
FCapabilities.RawDeviceOK := (ADC.Flags And DEVCAP_RAW_DEVICE_OK) <> 0;
FCapabilities.SurpriseRemovalOK := (ADC.Flags And DEVCAP_SURPRISE_REMOVAL_OK) <> 0;
FCapabilities.WakeFromD0 := (ADC.Flags And DEVCAP_WAKE_FROM_D0) <> 0;
FCapabilities.WakeFromD1 := (ADC.Flags And DEVCAP_WAKE_FROM_D1) <> 0;
FCapabilities.WakeFromD2 := (ADC.Flags And DEVCAP_WAKE_FROM_D2) <> 0;
FCapabilities.wakeFromD3 := (ADC.Flags And DEVCAP_WAKE_FROM_D3) <> 0;
FCapabilities.HardwareDisabled := (ADC.Flags And DEVCAP_HARDWARE_DISABLED) <> 0;
FCapabilities.NonDynamic := (ADC.Flags And DEVCAP_NON_DYNAMIC) <> 0;
FCapabilities.WarmEjectSupported := (ADC.Flags And DEVCAP_WARM_EJECT_SUPPORTED) <> 0;
FCapabilities.NoDisplayInUI := (ADC.Flags And DEVCAP_NO_DISPLAY_IN_UI) <> 0;
end;


end.
