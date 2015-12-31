Unit TextLogger;

Interface

Uses
  Logger, Snapshot, Classes, LogSettings,
  VTreeDriver, DriverSnapshot, DeviceSnapshot;

Type
  TSnapshotTextLogger = Class (TSnapshotLogger)
  Protected
    Function GenerateUnknownDeviceLog(AAddress:Pointer; ALog:TStrings):Boolean; Override;
    Function GenerateDriverRecordLog(ARecord:TDriverSnapshot; ALog:TStrings):Boolean; Override;
    Function GenerateDeviceRecordLog(ARecord:TDeviceSnapshot; ALog:TStrings):Boolean; Override;
    Function GenerateOSVersionInfo(ALog:TStrings):Boolean; Override;
    Function GenerateVTHeader(ALog:TStrings):Boolean; Override;
  end;

Implementation

Uses
  Windows, Kernel, SysUtils;

Function TSnapshotTextLogger.GenerateUnknownDeviceLog(AAddress:Pointer; ALog:TStrings):Boolean;
begin
ALog.Add(Format('      <unknown device> (0x%p)', [AAddress]));
Result := True;
end;

Function TSnapshotTextLogger.GenerateVTHeader(ALog:TStrings):Boolean;
begin
ALog.Add('VrtuleTree v1.5');
ALog.Add('Created by Martin Drab, 2013');
ALog.Add(Format('Run from: %s', [ParamStr(0)]));
ALog.Add('');
Result := True;
end;

Function TSnapshotTextLogger.GenerateOSVersionInfo(ALog:TStrings):Boolean;
Var
  info : OSVERSIONINFOEXW;
begin
info.dwOSVersionInfoSize := SizeOf(info);
If GetVersionEx(info) Then
  begin
  ALog.Add(Format('OS major version: %d', [info.dwMajorVersion]));
  ALog.Add(Format('OS minor version: %d', [info.dwMinorVersion]));
  ALog.Add(Format('OS build number:  %d', [info.dwBuildNumber]));
  end;

ALog.Add('');
Result := True;
end;

Function DeviceCapabilitiesFlagsToStr(Const ADC:TDeviceCapabilities):WideString;
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

Function TSnapshotTextLogger.GenerateDeviceRecordLog(ARecord:TDeviceSnapshot; ALog:TStrings):Boolean;
Var
  I : Integer;
  tmp : TDeviceSnapshot;
  DL : TDeviceLogSettings;
begin
DL := FLogSettings.DeviceSettings;
ALog.Add(Format('    DEVICE %s (0x%p)', [ARecord.Name, ARecord.Address]));
If DL.IncludeType Then
  ALog.Add(Format('      Type:            0x%x (%s)', [ARecord.DeviceType, DeviceTypeToStr(ARecord.DeviceType)]));

If DL.IncludeFlags Then
  begin
  If DL.IncludeFlagsStr Then
    ALog.Add(Format('      Flags:           0x%x (%s)', [ARecord.Flags, DeviceFlagsToStr(ARecord.Flags)]))
  Else ALog.Add(Format('      Flags:           0x%x', [ARecord.Flags]));
  end;

If DL.IncludeExtensionFlags Then
  begin
  If DL.IncludeExtensionFlagsStr Then
    ALog.Add(Format('      Extension flags: 0x%x (%s)', [ARecord.ExtensionFlags, DeviceExtensionFlagsToStr(ARecord.ExtensionFlags)]))
  Else ALog.Add(Format('      Extension flags: 0x%x', [ARecord.ExtensionFlags]));
  end;

If DL.IncludeCharacteristics Then
  begin
  If DL.IncludeCharacteristicsStr Then
    ALog.Add(Format('      Characteristics: 0x%x (%s)', [ARecord.Characteristics, DeviceCharacteristicsToStr(ARecord.Characteristics)]))
  Else ALog.Add(Format('      Characteristics: 0x%x', [ARecord.Characteristics]));
  end;

If DL.IncludePnPInformation Then
  begin
  If ((ARecord.Flags And DO_BUS_ENUMERATED_DEVICE) <> 0) Then
    begin
    If DL.IncludeFriendlyName Then
      ALog.Add(Format('      Friendly name:     %s', [ARecord.DisplayName]));

    If DL.IncludeDescription Then
      ALog.Add(Format('      Description:     %s', [ARecord.Description]));

    If DL.IncludeVendor Then
      ALog.Add(Format('      Manufacturer:    %s', [ARecord.Vendor]));

    If DL.IncludeEnumerator Then
      ALog.Add(Format('      Enumerator:      %s', [ARecord.Enumerator]));

    If DL.IncludeLocation Then
      ALog.Add(Format('      Location:        %s', [ARecord.Location]));

    If DL.IncludeClass Then
      begin
      If DL.IncludeClassGuid Then
        ALog.Add(Format('      Class:           %s (%s)', [ARecord.ClassName, ARecord.ClassGuid]))
      Else ALog.Add(Format('      Class:           %s', [ARecord.ClassName]));
      end;

    If DL.IncludeDeviceId Then
      ALog.Add(Format('      Device ID:       %s', [ARecord.DeviceId]));

    If DL.IncludeInstanceId Then
      ALog.Add(Format('      Instance ID:     %s', [ARecord.InstanceId]));

    If DL.IncludeHardwareIDs Then
      ALog.Add(Format('      Hardware IDs:    (%s)', [DeviceIDListToStr(ARecord.HardwareIds)]));

    If DL.IncludeCompatibleIDs Then
      ALog.Add(Format('      Compatible IDs:  (%s)', [DeviceIDListToStr(ARecord.CompatibleIds)]));

    If DL.IncludeRemovalRelations Then
      ALog.Add(Format('      Removal relations: (%s)', [DeviceRelationsToStr(ARecord.RemovalRelations)]));

    If DL.IncludeEjectRelations Then
      ALog.Add(Format('      Eject relations:   (%s)', [DeviceRelationsToStr(ARecord.EjectRelations)]));

    If DL.IncludeDeviceCapabilities Then
      begin
      ALog.Add(       '      Device capabilities: (');
      ALog.Add(Format('        Flags:         (%s)', [DeviceCapabilitiesFlagsToStr(ARecord.Capabilities)]));
      ALog.Add(Format('        Address:       %u', [ARecord.Capabilities.Address]));
      ALog.Add(Format('        UI number:     %u', [ARecord.Capabilities.UINumber]));
      If ARecord.Capabilities.D1Latency <> 0 Then
        ALog.Add(Format('        D1 latency:    %u ms', [ARecord.Capabilities.D1Latency Div 10]));

      If ARecord.Capabilities.D2Latency <> 0 Then
        ALog.Add(Format('        D2 latency:    %u ms', [ARecord.Capabilities.D2Latency Div 10]));

      If ARecord.Capabilities.D3Latency <> 0 Then
        ALog.Add(Format('        D3 latency:    %u ms', [ARecord.Capabilities.D3Latency Div 10]));

      ALog.Add('      )');
      end;
    end;
  end;

If DL.IncludeDiskDevice Then
  begin
  tmp := FSnapshot.GetDeviceByAddress(ARecord.DiskDeviceAddress);
  If Assigned(tmp) Then
    ALog.Add(Format('      Disk device:     %s (0x%p) (%s)', [tmp.Name, tmp.Address, tmp.DriverName]));
  end;

If DL.IncludeLowerDevicesCount Then
  ALog.Add(Format('      Number of lower Devices: %d', [ARecord.NumberOfLowerDevices]));

If (DL.IncludeLowerDevices) And (ARecord.NumberOfLowerDevices > 0) Then
  begin
  ALog.Add('      Lower devices:');
  For I := 0 To ARecord.NumberOfLowerDevices - 1 Do
    begin
    tmp := FSnapshot.GetDeviceByAddress(ARecord.LowerDevices[I]);
    If Assigned(tmp) Then
      ALog.Add(Format('        %s (0x%p) (%s)', [tmp.Name, tmp.Address, tmp.DriverName]))
    Else ALog.Add(Format('        <unknown> (0x%p)', [ARecord.LowerDevices[I]]));
    end;
  end;

If DL.IncludeUpperDevicesCount Then
  ALog.Add(Format('      Number of upper Devices: %d', [ARecord.NumberOfUpperDevices]));

If (DL.IncludeUpperDevices) And
   (ARecord.NumberOfUpperDevices > 0) Then
  begin
  ALog.Add('      Upper devices:');
  For I := 0 To ARecord.NumberOfUpperDevices - 1 Do
    begin
    tmp := FSnapshot.GetDeviceByAddress(ARecord.UpperDevices[I]);
    If Assigned(tmp) Then
      ALog.Add(Format('        %s (0x%p) (%s)', [tmp.Name, tmp.Address, tmp.DriverName]))
    Else ALog.Add(Format('        <unknown> (0x%p)', [ARecord.UpperDevices[I]]));
    end;
  end;

Result := True;
end;

Function TSnapshotTextLogger.GenerateDriverRecordLog(ARecord:TDriverSnapshot; ALog:TStrings):Boolean;
Var
  I : Integer;
  DL : TDriverLogSettings;
begin
DL := FLogSettings.DriverSettings;
ALog.Add(Format('DRIVER %s (0x%p)', [ARecord.Name, ARecord.Address]));
If DL.IncludeFileName Then
  ALog.Add(Format('  Filename:           %s', [ARecord.ImagePath]));

If DL.IncludeImageBase Then
  ALog.Add(Format('  Image base address: 0x%p', [ARecord.ImageBase]));

If DL.IncludeImageSize Then
  ALog.Add(Format('  Image size:         %d', [ARecord.ImageSize]));

If DL.IncludeDriverEntry Then
  ALog.Add(Format('  DriverEntry:        0x%p', [ARecord.DriverEntry]));

If DL.IncludeDriverUnload Then
  ALog.Add(Format('  DriverUnload:       0x%p', [ARecord.DriverUnload]));

If DL.IncludeStartIo Then
  ALog.Add(Format('  StartIo:            0x%p', [ARecord.StartIo]));

If DL.IncludeFlags Then
  begin
  If DL.IncludeFlagsStr Then
    ALog.Add(Format('  Flags:              0x%x (%s)', [ARecord.Flags, DriverFlagsToStr(ARecord.Flags)]))
  Else ALog.Add(Format('  Flags:              0x%x', [ARecord.Flags]));
  end;

If DL.IncludeMajorFunctions Then
  begin
  ALog.Add('  MajorFunction');
  For I := 0 To 27 Do
    ALog.Add(Format('    %s: 0x%p', [IrpMajorToStr(I), ARecord.MajorFunction[I]]));
  end;

If DL.IncludeNumberOfDevices Then
  ALog.Add(Format('  Number of devices:  %d', [ARecord.NumberOfDevices]));

Result := True;
end;



End.

