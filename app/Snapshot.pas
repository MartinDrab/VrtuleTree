Unit Snapshot;

Interface


Uses
  WIndows, Kernel, VTreeDriver, Classes,
  Generics.Collections;

Type
  TVTreeSnapshot = Class
    Private
      FDriverTable : TDictionary<Pointer, PDriverSnapshot>;
      FDeviceTable : TDictionary<Pointer, PDeviceSnapshot>;
      FSnapshot : PSnapshot;
      FDriverAddresses : TList;
      FDriverSizes : TList;
      FDriverNames : TStringList;
      FDriverRecords : TList<PDriverSnapshot>;
      FDeviceRecords : TList<PDeviceSnapshot>;
      Function  CopyString(AStart:Pointer; AOffset:Cardinal):WideString;
      Procedure FreeDeviceRecord(ARecord:Pointer);
      Procedure FreeDriverRecord(ARecord:Pointer);
      Function  CreateDriverRecord(ADriverInfo:PSNAPSHOT_DRIVERINFO):PDriverSnapshot;
      Function  CreateDeviceRecord(ADeviceInfo:PSNAPSHOT_DEVICEINFO; ADriverRecord:PDriverSnapshot):PDeviceSnapshot;
      Function CreateVpbRecord(AVpbInfo:PSNAPSHOT_VPBINFO):PVpbSnapshot;
      Procedure FreeVpbRecord(ARecord:PVpbSnapshot);
    Protected
      Function GetDriverRecord(AIndex:Integer):PDriverSnapshot;
      Function GetDriverRecordsCount:Integer;
    Public
      Constructor Create(ADriverAddresses:TList; ADriverSizes:TList; ADriverNames:TStringList; ARawSnapshot:Pointer); Reintroduce;
      Destructor Destroy; Override;

      Function GetDriverByAddress(AAddress:Pointer):PDriverSnapshot;
      Function GetDeviceByAddress(AAddress:Pointer):PDeviceSnapshot;
      Class Procedure FillDeviceCapabilities(Var ADC:DEVICE_CAPABILITIES; Var AResult:TDeviceCapabilities);

      Property DriverRecords [Index:Integer] : PDriverSnapshot Read GetDriverRecord;
      Property DriverRecordsCount : Integer Read GetDriverRecordsCount;
    end;



Implementation

Uses
  SysUtils, Utils;

Function TVTreeSnapshot.CopyString(AStart:Pointer; AOffset:Cardinal):WideString;
Var
  W : PWChar;
begin
W := PWChar(NativeInt(AStart) + AOffset);
Result := Copy(WideString(W), 1, Strlen(W));
end;

Procedure TVTreeSnapshot.FreeDeviceRecord(ARecord:Pointer);
Var
  R : PDeviceSnapshot;
begin
R := ARecord;
If Assigned(R.Vpb) Then
  FreeVpbRecord(R.Vpb);

SetLength(R.LowerDevices, 0);
SetLength(R.UpperDevices, 0);
Setlength(R.RemovalRelations, 0);
SetLength(R.EjectRelations, 0);
Dispose(R);
end;

Procedure TVTreeSnapshot.FreeDriverRecord(ARecord:Pointer);
Var
  R : PDriverSnapshot;
begin
R := ARecord;
SetLength(R.Devices, 0);
Dispose(R);
end;

Function TVTreeSnapshot.CreateDriverRecord(ADriverInfo:PSNAPSHOT_DRIVERINFO):PDriverSnapshot;
Var
  Index : Integer;
begin
New(Result);
Result.Address := ADriverInfo.ObjectAddress;
Result.Name := CopyString(ADriverInfo, ADriverInfo.NameOffset);
Result.MajorFunction := ADriverInfo.MajorFunction;
Result.NumberOfDevices := ADriverInfo.NumberOfDevices;
Result.ImageBase := ADriverInfo.ImageBase;
Result.ImageSize := ADriverInfo.ImageSize;
Result.DriverEntry := ADriverInfo.DriverEntry;
Result.DriverUnload := ADriverInfo.DriverUnload;
Result.Flags := ADriverInfo.Flags;
Result.StartIo := ADriverInfo.StartIo;
Result.ImagePath := '';
Index := FDriverAddresses.IndexOf(Result.ImageBase);
If Index > -1 Then
  Result.ImagePath := FDriverNames[Index];

SetLength(Result.Devices, Result.NumberOfDevices);
end;

Function TVTreeSnapshot.CreateDeviceRecord(ADeviceInfo:PSNAPSHOT_DEVICEINFO; ADriverRecord:PDriverSnapshot):PDeviceSnapshot;
Var
  tmp : PWideChar;
  pDevice : PPointer;
  K : Integer;
  AdvPnP : PSNAPSHOT_DEVICE_ADVANCED_PNP_INFO;
begin
New(Result);
Result.Address := ADeviceInfo.ObjectAddress;
Result.Name := CopyString(ADeviceInfo, ADeviceInfo.NameOffset);
Result.DriverName := ADriverRecord.Name;
Result.DriverAddress := ADriverRecord.Address;
Result.DisplayName := CopyString(ADeviceInfo, ADeviceInfo.DisplayNameOffset);
Result.Description := CopyString(ADeviceInfo, ADeviceInfo.DescriptionOffset);
Result.Vendor := CopyString(ADeviceInfo, ADeviceInfo.VendorNameOffset);
Result.Location := CopyString(ADeviceInfo, ADeviceInfo.LocationOffset);
Result.ClassName := CopyString(ADeviceInfo, ADeviceInfo.ClassNameOffset);
Result.Enumerator := CopyString(ADeviceInfo, ADeviceInfo.EnumeratorOffset);
Result.ClassGuid := CopyString(ADeviceInfo, ADeviceInfo.ClassGuidOffset);
Result.Flags := ADeviceInfo.Flags;
Result.Characteristics := ADeviceInfo.Characteristics;
Result.DeviceType := ADeviceInfo.DeviceType;
Result.DiskDeviceAddress := ADeviceInfo.DiskDevice;
Result.NumberOfLowerDevices := ADeviceInfo.NumberOfLowerDevices;
Result.NumberOfUpperDevices := ADeviceInfo.NumberOfUpperDevices;
SetLength(Result.LowerDevices, Result.NumberOfLowerDevices);
SetLength(Result.UpperDevices, Result.NumberOfUpperDevices);
pDevice := PPointer(NativeInt(ADeviceInfo) + ADeviceInfo.LowerDevicesOffset);
For K := 0 To Result.NumberOfLowerDevices - 1 Do
  begin
  Result.LowerDevices[K] := pDevice^;
  Inc(pDevice);
  end;

pDevice := PPointer(NativeInt(ADeviceInfo) + ADeviceInfo.UpperDevicesOffset);
For K := 0 To Result.NumberOfUpperDevices - 1 Do
  begin
  Result.UpperDevices[K] := pDevice^;
  Inc(pDevice);
  end;

Result.Vpb := Nil;
If Assigned(ADeviceInfo.VpbSnapshot) Then
  begin
  Result.Vpb := CreateVpbRecord(ADeviceInfo.VpbSnapshot);
  If Assigned(Result.Vpb) Then
    Result.Vpb.VpbAddress := ADeviceInfo.Vpb;
  end;

SetLength(Result.RemovalRelations, 0);
SetLength(Result.EjectRelations, 0);
Result.DeviceId := '';
Result.InstanceId := '';
SetLength(Result.HardwareIds, 0);
SetLength(Result.CompatibleIds, 0);
Result.DeviceNode := ADeviceInfo.DeviceNode;
Result.Child := ADeviceInfo.Child;
Result.Parent := ADeviceInfo.Parent;
Result.Sibling := ADeviceInfo.Sibling;
Result.ExtensionFlags := ADeviceInfo.ExtensionFlags;
Result.PowerFlags := ADeviceInfo.PowerFlags;
AdvPnP := ADeviceInfo.AdvancedPnPInfo;
If Assigned(AdvPnP) Then
  begin
  Result.DeviceId := CopyString(AdvPnP, AdvPnP.DeviceId);
  Result.InstanceId := CopyString(AdvPnP, AdvPnP.Instanceid);
  If Assigned(AdvPnP.RemovalRelations) Then
    begin
    pDevice := PPointer(NativeUInt(AdvPnP.RemovalRelations) + AdvPnP.RemovalRelations.RelationsOffset);
    SetLength(Result.RemovalRelations, AdvPnP.RemovalRelations.Count);
    For K := 0 To AdvPnP.RemovalRelations.Count - 1 Do
      begin
      Result.RemovalRelations[K] := pDevice^;
      Inc(pDevice);
      end;
    end;

  If Assigned(AdvPnP.EjectRelations) Then
    begin
    pDevice := PPointer(NativeUInt(AdvPnP.EjectRelations) + AdvPnP.EjectRelations.RelationsOffset);
    SetLength(Result.EjectRelations, AdvPnP.EjectRelations.Count);
    For K := 0 To AdvPnP.EjectRelations.Count - 1 Do
      begin
      Result.EjectRelations[K] := pDevice^;
      Inc(pDevice);
      end;
    end;

  tmp := PWideChar(NativeUInt(AdvPnP) + AdvPnP.HardwareId);
  If tmp^ <> #0 Then
    begin
    Repeat
    SetLength(Result.HardwareIds, Length(Result.HardwareIds) + 1);
    Result.HardwareIds[High(Result.HardwareIds)] := Copy(WideString(tmp), 1, StrLen(tmp));
    Inc(tmp, StrLen(tmp) + 1);
    Until tmp^ = #0;
    end;

  tmp := PWideChar(NativeUInt(AdvPnP) + AdvPnP.CompatibleId);
  If tmp^ <> #0 Then
    begin
    Repeat
    SetLength(Result.CompatibleIds, Length(Result.CompatibleIds) + 1);
    Result.CompatibleIds[High(Result.CompatibleIds)] := Copy(WideString(tmp), 1, StrLen(tmp));
    Inc(tmp, StrLen(tmp) + 1);
    Until tmp^ = #0;
    end;

  FillDeviceCapabilities(AdvPnp.DeviceCapabilities, Result.Capabilities);
  end;
end;


Constructor TVtreeSnapshot.Create(ADriverAddresses:TList; ADriverSizes:TList; ADriverNames:TStringList; ARawSnapshot:Pointer);
Var
  Ret : Boolean;
  DriverRecord : PDriverSnapshot;
  DeviceRecord : PDeviceSnapshot;
  DriverList : PSNAPSHOT_DRIVERLIST;
  DriverInfo : PSNAPSHOT_DRIVERINFO;
  DeviceInfo : PSNAPSHOT_DEVICEINFO;
  DriverInfoHandle : PPointer;
  DeviceInfoHandle : PPointer;
  I, J : Integer;
begin
Inherited Create;
FDeviceTable := TDictionary<Pointer, PDeviceSnapshot>.Create;
FDriverTable := TDictionary<Pointer, PDriverSnapshot>.Create;
FDriverRecords := TList<PDriverSnapshot>.Create;
FDeviceRecords := TList<PDeviceSnapshot>.Create;
FDriverAddresses := ADriverAddresses;
FDriverSizes := ADriverSizes;
FDriverNames := ADriverNames;
DriverList := ARawSnapshot;
New(FSnapshot);
FSnapshot.NumberOfDrivers := DriverList.NumberOfDrivers;
SetLength(FSnapshot.Drivers, FSnapshot.NumberOfDrivers);
DriverInfoHandle := PPointer(NativeInt(DriverList) + DriverList.DriversOffset);
For I := 0 To DriverList.NumberOfDrivers - 1 Do
  begin
  DriverInfo := DriverInfoHandle^;
  FSnapshot.Drivers[I] := DriverInfo.ObjectAddress;
  DriverRecord := CreateDriverRecord(DriverInfo);
  Ret := Assigned(DriverRecord);
  If Ret Then
    begin
    DeviceInfoHandle := PPointer(NativeInt(DriverInfo) + DriverInfo.DevicesOffset);
    For J := 0 To DriverRecord.NumberOfDevices - 1 Do
      begin
      DeviceInfo := DeviceInfoHandle^;
      DriverRecord.Devices[J] := DeviceInfo.ObjectAddress;
      DeviceRecord := CreateDeviceRecord(DeviceInfo, DriverRecord);
      Ret := Assigned(DeviceRecord);
      If Ret Then
        begin
        FDeviceTable.Add(DeviceRecord.Address, DeviceRecord);
        FDeviceRecords.Add(DeviceRecord);
        Inc(DeviceInfoHandle);
        end;

      If Not Ret Then
        begin
        FDeviceTable.Clear;
        Break;
        end;
      end;

    FDriverTable.Add(DriverRecord.Address, DriverRecord);
    FDriverRecords.Add(DriverRecord);
    Inc(DriverInfoHandle);
    end;

  If Not Ret Then
    begin
    FDriverTable.Clear;
    Break;
    end;
  end;

If Not  Ret Then
  begin
  SetLength(FSnapshot.Drivers, 0);
  Dispose(FSnapshot);
  FSnapshot := Nil;
  end;
end;

Destructor TVTreeSnapshot.Destroy;
Var
  I : Integer;
begin
For I := 0 To FDeviceRecords.Count - 1 Do
  FreeDeviceRecord(FDeviceRecords[I]);

FDeviceRecords.Free;
For I := 0 To FDriverRecords.Count - 1 Do
  FreeDriverRecord(FDriverRecords[I]);

FDriverRecords.Free;
FDeviceTable.Free;
FDriverTable.Free;
Inherited Destroy;
end;

Function TVTreeSnapshot.GetDriverRecordsCount:Integer;
begin
Result := FDriverRecords.Count;
end;

Function TVTreeSnapshot.GetDriverRecord(AIndex:Integer):PDriverSnapshot;
begin
Result := FDriverRecords[AIndex];
end;


Function TVTreeSnapshot.GetDriverByAddress(AAddress:Pointer):PDriverSnapshot;
begin
If Not FDriverTable.TryGetValue(AAddress, Result) Then
  Result := Nil;
end;

Function TVTreeSnapshot.GetDeviceByAddress(AAddress:Pointer):PDeviceSnapshot;
begin
If Not FDeviceTable.TryGetValue(AAddress, Result) Then
  Result := Nil;
end;

Function TVTreeSnapshot.CreateVpbRecord(AVpbInfo:PSNAPSHOT_VPBINFO):PVpbSnapshot;
begin
New(Result);
Result.VpbAddress := Nil;
Result.Name := CopyString(AVpbInfo, AVpbInfo.VolumeLabel);
Result.FileSystemDevice := AVpbInfo.FileSystemDevice;
Result.VolumeDevice := AVpbInfo.VolumeDevice;
Result.Flags := AVpbInfo.Flags;
Result.ReferenceCount := AVpbInfo.ReferenceCount;
end;

Procedure TVTreeSnapshot.FreeVpbRecord(ARecord:PVpbSnapshot);
begin
Dispose(ARecord);
end;

Class Procedure TVTreeSnapshot.FillDeviceCapabilities(Var ADC:DEVICE_CAPABILITIES; Var AResult:TDeviceCapabilities);
begin
AResult.Version := ADC.Version;
AResult.UINumber := ADC.UINumber;
AResult.Address := ADC.Address;
AResult.D1Latency := ADC.D1Latency;
AResult.D2Latency := ADC.D2Latency;
AResult.D3Latency := ADC.D3Latency;
AResult.DeviceD1 := (ADC.Flags And DEVCAP_DEVICE_D1) <> 0;
AResult.DeviceD2 := (ADC.Flags And DEVCAP_DEVICE_D2) <> 0;
AResult.LockSupported := (ADC.Flags And DEVCAP_LOCK_SUPPORTED) <> 0;
AResult.EjectSupported := (ADC.Flags And DEVCAP_EJECT_SUPPORTED) <> 0;
AResult.Removable := (ADC.Flags And DEVCAP_REMOVABLE) <> 0;
AResult.DockDevice := (ADC.Flags And DEVCAP_DOCK_DEVICE) <> 0;
AResult.UniqueId := (ADC.Flags And DEVCAP_UNIQUE_ID) <> 0;
AResult.SilentInstall := (ADC.Flags And DEVCAP_SILENT_INSTALL) <> 0;
AResult.RawDeviceOK := (ADC.Flags And DEVCAP_RAW_DEVICE_OK) <> 0;
AResult.SurpriseRemovalOK := (ADC.Flags And DEVCAP_SURPRISE_REMOVAL_OK) <> 0;
AResult.WakeFromD0 := (ADC.Flags And DEVCAP_WAKE_FROM_D0) <> 0;
AResult.WakeFromD1 := (ADC.Flags And DEVCAP_WAKE_FROM_D1) <> 0;
AResult.WakeFromD2 := (ADC.Flags And DEVCAP_WAKE_FROM_D2) <> 0;
AResult.wakeFromD3 := (ADC.Flags And DEVCAP_WAKE_FROM_D3) <> 0;
AResult.HardwareDisabled := (ADC.Flags And DEVCAP_HARDWARE_DISABLED) <> 0;
AResult.NonDynamic := (ADC.Flags And DEVCAP_NON_DYNAMIC) <> 0;
AResult.WarmEjectSupported := (ADC.Flags And DEVCAP_WARM_EJECT_SUPPORTED) <> 0;
AResult.NoDisplayInUI := (ADC.Flags And DEVCAP_NO_DISPLAY_IN_UI) <> 0;
end;



End.

