Unit TextLogger;

Interface

Uses
  Logger, Snapshot, Classes, LogSettings,
  VTreeDriver, DriverSnapshot, DeviceSnapshot,
  DeviceDrivers;

Type
  TSnapshotTextLogger<T:TStrings> = Class (TSnapshotLogger)
  Private
    FLogStorage : T;
    Class Function DeviceCapabilitiesFlagsToStr(Const ADC:TDeviceCapabilities):WideString;
  Protected
    Function AssignLogStorage(ALogStorage:TObject):Boolean; Override;
    Function GenerateUnknownDeviceLog(AAddress:Pointer):Boolean; Override;
    Function GenerateDriverRecordLog(ARecord:TDriverSnapshot):Boolean; Override;
    Function GenerateDeviceRecordLog(ARecord:TDeviceSnapshot):Boolean; Override;
    Function GenerateDeviceDriverRecordLog(ADeviceDriver:TDeviceDriver):Boolean; Override;
    Function GenerateOSVersionInfo:Boolean; Override;
    Function GenerateVTHeader:Boolean; Override;
  end;

Implementation

Uses
  Windows, Kernel, SysUtils;

Function TSnapshotTextLogger<T>.GenerateUnknownDeviceLog(AAddress:Pointer):Boolean;
begin
FLogStorage.Add(Format('      <unknown device> (0x%p)', [AAddress]));
Result := True;
end;

Function TSnapshotTextLogger<T>.GenerateVTHeader:Boolean;
begin
FLogStorage.Add('VrtuleTree v1.6');
FLogStorage.Add('Created by Martin Drab, 2013-2016');
FLogStorage.Add(Format('Run from: %s', [ParamStr(0)]));
FLogStorage.Add('');
Result := True;
end;

Function TSnapshotTextLogger<T>.GenerateOSVersionInfo:Boolean;
Var
  info : OSVERSIONINFOEXW;
begin
info.dwOSVersionInfoSize := SizeOf(info);
If RtlGetVersion(info) = 0 Then
  begin
  FLogStorage.Add(Format('OS major version: %d', [info.dwMajorVersion]));
  FLogStorage.Add(Format('OS minor version: %d', [info.dwMinorVersion]));
  FLogStorage.Add(Format('OS build number:  %d', [info.dwBuildNumber]));
  end;

FLogStorage.Add('');
Result := True;
end;

Class Function TSnapshotTextLogger<T>.DeviceCapabilitiesFlagsToStr(Const ADC:TDeviceCapabilities):WideString;
begin
Result := '';
If ADC.DeviceD1 Then
  Result := Result + 'DeviceD1, ';
If ADC.DeviceD2 Then
  Result := Result + 'DeviceD2, ';
If ADC.LockSupported Then
  Result := Result + 'LockSupported, ';
If ADC.EjectSupported Then
  Result := Result + 'EjectSupported, ';
If ADC.Removable Then
  Result := Result + 'Removable, ';
If ADC.DockDevice Then
  Result := Result + 'DockDevice, ';
If ADC.UniqueId Then
  Result := Result + 'UniqueId, ';
If ADC.SilentInstall Then
  Result := Result + 'SilentInstall, ';
If ADC.RawDeviceOK Then
  Result := Result + 'RawDeviceOK, ';
If ADC.SurpriseRemovalOK Then
  Result := Result + 'SurpriseRemovalOK, ';
If ADC.WakeFromD0 Then
  Result := Result + 'WakeFromD0, ';
If ADC.WakeFromD1 Then
  Result := Result + 'WakeFromD1, ';
If ADC.WakeFromD2 Then
  Result := Result + 'WakeFromD2, ';
If ADC.WakeFromD3 Then
  Result := Result + 'WakeFromD3, ';
If ADC.HardwareDisabled Then
  Result := Result + 'HardwareDisabled, ';
If ADC.NonDynamic Then
  Result := Result + 'NonDynamic, ';
If ADC.WarmEjectSupported Then
  Result := Result + 'WarmEjectSupported, ';
If ADC.NoDisplayInUI Then
  Result := Result + 'NoDisplayInUI, ';

If Result <> '' Then
  Delete(Result, Length(Result) - 1, 2);
end;

Function TSnapshotTextLogger<T>.GenerateDeviceRecordLog(ARecord:TDeviceSnapshot):Boolean;
Var
  I : Integer;
  tmp : TDeviceSnapshot;
  DL : TDeviceLogSettings;
begin
DL := FLogSettings.DeviceSettings;
FLogStorage.Add(Format('    DEVICE %s (0x%p)', [ARecord.Name, ARecord.Address]));
If DL.IncludeType Then
  FLogStorage.Add(Format('      Type:            0x%x (%s)', [ARecord.DeviceType, DeviceTypeToStr(ARecord.DeviceType)]));

If DL.IncludeFlags Then
  begin
  If DL.IncludeFlagsStr Then
    FLogStorage.Add(Format('      Flags:           0x%x (%s)', [ARecord.Flags, DeviceFlagsToStr(ARecord.Flags)]))
  Else FLogStorage.Add(Format('      Flags:           0x%x', [ARecord.Flags]));
  end;

If DL.IncludeExtensionFlags Then
  begin
  If DL.IncludeExtensionFlagsStr Then
    FLogStorage.Add(Format('      Extension flags: 0x%x (%s)', [ARecord.ExtensionFlags, DeviceExtensionFlagsToStr(ARecord.ExtensionFlags)]))
  Else FLogStorage.Add(Format('      Extension flags: 0x%x', [ARecord.ExtensionFlags]));
  end;

If DL.IncludeCharacteristics Then
  begin
  If DL.IncludeCharacteristicsStr Then
    FLogStorage.Add(Format('      Characteristics: 0x%x (%s)', [ARecord.Characteristics, DeviceCharacteristicsToStr(ARecord.Characteristics)]))
  Else FLogStorage.Add(Format('      Characteristics: 0x%x', [ARecord.Characteristics]));
  end;

If DL.IncludePnPInformation Then
  begin
  If ((ARecord.Flags And DO_BUS_ENUMERATED_DEVICE) <> 0) Then
    begin
    If DL.IncludeFriendlyName Then
      FLogStorage.Add(Format('      Friendly name:     %s', [ARecord.DisplayName]));

    If DL.IncludeDescription Then
      FLogStorage.Add(Format('      Description:     %s', [ARecord.Description]));

    If DL.IncludeVendor Then
      FLogStorage.Add(Format('      Manufacturer:    %s', [ARecord.Vendor]));

    If DL.IncludeEnumerator Then
      FLogStorage.Add(Format('      Enumerator:      %s', [ARecord.Enumerator]));

    If DL.IncludeLocation Then
      FLogStorage.Add(Format('      Location:        %s', [ARecord.Location]));

    If DL.IncludeClass Then
      begin
      If DL.IncludeClassGuid Then
        FLogStorage.Add(Format('      Class:           %s (%s)', [ARecord.ClassName, ARecord.ClassGuid]))
      Else FLogStorage.Add(Format('      Class:           %s', [ARecord.ClassName]));
      end;

    If (DL.IncludeDeviceId) And ((FSnapshotFlags And VTREE_SNAPSHOT_DEVICE_ID) <> 0) Then
      FLogStorage.Add(Format('      Device ID:       %s', [ARecord.DeviceId]));

    If DL.IncludeInstanceId Then
      FLogStorage.Add(Format('      Instance ID:     %s', [ARecord.InstanceId]));

    If DL.IncludeHardwareIDs Then
      FLogStorage.Add(Format('      Hardware IDs:    (%s)', [DeviceIDListToStr(ARecord.HardwareIds)]));

    If DL.IncludeCompatibleIDs Then
      FLogStorage.Add(Format('      Compatible IDs:  (%s)', [DeviceIDListToStr(ARecord.CompatibleIds)]));

    If DL.IncludeRemovalRelations Then
      FLogStorage.Add(Format('      Removal relations: (%s)', [DeviceRelationsToStr(ARecord.RemovalRelations)]));

    If DL.IncludeEjectRelations Then
      FLogStorage.Add(Format('      Eject relations:   (%s)', [DeviceRelationsToStr(ARecord.EjectRelations)]));

    If DL.IncludeDeviceCapabilities Then
      begin
      FLogStorage.Add(       '      Device capabilities:');
      FLogStorage.Add(Format('        Flags:         (%s)', [DeviceCapabilitiesFlagsToStr(ARecord.Capabilities)]));
      FLogStorage.Add(Format('        Address:       %u', [ARecord.Capabilities.Address]));
      FLogStorage.Add(Format('        UI number:     %u', [ARecord.Capabilities.UINumber]));
      If ARecord.Capabilities.D1Latency <> 0 Then
        FLogStorage.Add(Format('        D1 latency:    %u ms', [ARecord.Capabilities.D1Latency Div 10]));

      If ARecord.Capabilities.D2Latency <> 0 Then
        FLogStorage.Add(Format('        D2 latency:    %u ms', [ARecord.Capabilities.D2Latency Div 10]));

      If ARecord.Capabilities.D3Latency <> 0 Then
        FLogStorage.Add(Format('        D3 latency:    %u ms', [ARecord.Capabilities.D3Latency Div 10]));
      end;

    FLogStorage.Add(Format('      Device node: 0x%p', [ARecord.DeviceNode]));
    If ((FSnapshotFlags And VTREE_SNAPSHOT_DEVNODE_TREE) <> 0) Then
      begin
      FLogStorage.Add(Format('      Parent: 0x%p', [ARecord.Parent]));
      FLogStorage.Add(Format('      Child: 0x%p', [ARecord.Child]));
      FLogStorage.Add(Format('      Sibling: 0x%p', [ARecord.Sibling]));
      end;
    end;
  end;

If DL.IncludeDiskDevice Then
  begin
  tmp := FSnapshot.GetDeviceByAddress(ARecord.DiskDeviceAddress);
  If Assigned(tmp) Then
    FLogStorage.Add(Format('      Disk device:     %s (0x%p) (%s)', [tmp.Name, tmp.Address, tmp.DriverName]));
  end;

If DL.IncludeLowerDevicesCount Then
  FLogStorage.Add(Format('      Number of lower Devices: %d', [ARecord.NumberOfLowerDevices]));

If (DL.IncludeLowerDevices) And (ARecord.NumberOfLowerDevices > 0) Then
  begin
  FLogStorage.Add('      Lower devices:');
  For I := 0 To ARecord.NumberOfLowerDevices - 1 Do
    begin
    tmp := FSnapshot.GetDeviceByAddress(ARecord.LowerDevices[I]);
    If Assigned(tmp) Then
      FLogStorage.Add(Format('        %s (0x%p) (%s)', [tmp.Name, tmp.Address, tmp.DriverName]))
    Else FLogStorage.Add(Format('        <unknown> (0x%p)', [ARecord.LowerDevices[I]]));
    end;
  end;

If DL.IncludeUpperDevicesCount Then
  FLogStorage.Add(Format('      Number of upper Devices: %d', [ARecord.NumberOfUpperDevices]));

If (DL.IncludeUpperDevices) And
   (ARecord.NumberOfUpperDevices > 0) Then
  begin
  FLogStorage.Add('      Upper devices:');
  For I := 0 To ARecord.NumberOfUpperDevices - 1 Do
    begin
    tmp := FSnapshot.GetDeviceByAddress(ARecord.UpperDevices[I]);
    If Assigned(tmp) Then
      FLogStorage.Add(Format('        %s (0x%p) (%s)', [tmp.Name, tmp.Address, tmp.DriverName]))
    Else FLogStorage.Add(Format('        <unknown> (0x%p)', [ARecord.UpperDevices[I]]));
    end;
  end;

Result := True;
end;

Function TSnapshotTextLogger<T>.GenerateDriverRecordLog(ARecord:TDriverSnapshot):Boolean;
Var
  I : Integer;
  lineString : WideString;
  fd : PFAST_IO_DISPATCH;
  routineName : WideString;
  dd : TDeviceDriver;
  DL : TDriverLogSettings;
begin
DL := FLogSettings.DriverSettings;
FLogStorage.Add(Format('DRIVER %s (0x%p)', [ARecord.Name, ARecord.Address]));
If DL.IncludeFileName Then
  FLogStorage.Add(Format('  Filename:           %s', [ARecord.ImagePath]));

If DL.IncludeImageBase Then
  FLogStorage.Add(Format('  Image base address: 0x%p', [ARecord.ImageBase]));

If DL.IncludeImageSize Then
  FLogStorage.Add(Format('  Image size:         %d', [ARecord.ImageSize]));

If DL.IncludeDriverEntry Then
  FLogStorage.Add(Format('  DriverEntry:        0x%p', [ARecord.DriverEntry]));

If DL.IncludeDriverUnload Then
  FLogStorage.Add(Format('  DriverUnload:       0x%p', [ARecord.DriverUnload]));

If DL.IncludeStartIo Then
  FLogStorage.Add(Format('  StartIo:            0x%p', [ARecord.StartIo]));

If DL.IncludeFlags Then
  begin
  If DL.IncludeFlagsStr Then
    FLogStorage.Add(Format('  Flags:              0x%x (%s)', [ARecord.Flags, DriverFlagsToStr(ARecord.Flags)]))
  Else FLogStorage.Add(Format('  Flags:              0x%x', [ARecord.Flags]));
  end;

If DL.IncludeMajorFunctions Then
  begin
  FLogStorage.Add('  MajorFunction');
  For I := 0 To 27 Do
    begin
    dd := FDriverList.GetDriverByRange(ARecord.MajorFunction[I]);
    routineName := FSnapshot.TranslateAddress(FSpecialValues, ARecord.MajorFunction[I]);
    lineString := Format('    %s: 0x%p', [IrpMajorToStr(I), ARecord.MajorFunction[I]]);
    If Assigned(dd) Then
      begin
      lineString := Format('%s (%s', [lineString, dd.FileName]);
      If routineName <> '' Then
        lineString := Format('%s!%s', [lineString, routineName]);

      lineString := lineString + ')';
      end;

    FLogStorage.Add(lineString);
    end;
  end;

If (DL.IncludeFastIoDispatch) And
  ((FSnapshotFlags And VTREE_SNAPSHOT_FAST_IO_DISPATCH) <> 0) Then
  begin
  FLogStorage.Add('  Fast I/O Dispatch');
  FLogStorage.Add(Format('    Address: 0x%p', [ARecord.FastIoAddress]));
  If Assigned(ARecord.FastIoAddress) Then
    begin
    fd := @ARecord.FastIoDispatch;
    FLogStorage.Add(Format('    Size: %u (%u routines)', [fd.SizeOfFastIoDispatch, (fd.SizeOfFastIoDispatch Div SizeOf(Pointer)) - 1]));
    For I := Low(fd.Routines) To (fd.SizeOfFastIoDispatch Div SizeOf(Pointer)) - 2 Do
      begin
      dd := FDriverList.GetDriverByRange(fd.Routines[I]);
      lineString := Format('    %s: 0x%p', [FastIoIndexToStr(I), fd.Routines[I]]);
      If Assigned(dd) Then
        begin
        routineName := FSnapshot.TranslateAddress(FSpecialValues, fd.Routines[I]);
        lineString := Format('%s (%s', [lineString, dd.FileName]);
        If routineName <> '' Then
          lineString := Format('%s!%s', [lineString, routineName]);

        lineString := lineString + ')';
        end;

      FLogStorage.Add(lineString);
      end;
    end;
  end;

If DL.IncludeNumberOfDevices Then
  FLogStorage.Add(Format('  Number of devices:  %d', [ARecord.NumberOfDevices]));

Result := True;
end;

Function TSnapshotTextLogger<T>.GenerateDeviceDriverRecordLog(ADeviceDriver:TDeviceDriver):Boolean;
begin
Result := True;
end;

Function TSnapshotTextLogger<T>.AssignLogStorage(ALogStorage:TObject):Boolean;
begin
FLogStorage := (ALogStorage As T);
Result := True;
end;

End.

