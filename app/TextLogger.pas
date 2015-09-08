Unit TextLogger;

Interface

Uses
  Logger, Snapshot, Classes, LogSettings,
  VTreeDriver;

Type
  TSnapshotTextLogger = Class (TSnapshotLogger)
  Protected
Function GenerateUnknownDeviceLog(AAddress:Pointer; ALog:TStrings):Boolean; Override;
    Function GenerateDriverRecordLog(ARecord:PDriverSnapshot; ALog:TStrings):Boolean; Override;
    Function GenerateDeviceRecordLog(ARecord:PDeviceSnapshot; ALog:TStrings):Boolean; Override;
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
ALog.Add('VrtuleTree v1.0');
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

Function TSnapshotTextLogger.GenerateDeviceRecordLog(ARecord:PDeviceSnapshot; ALog:TStrings):Boolean;
Var
  I : Integer;
  tmp : PDeviceSnapshot;
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

Function TSnapshotTextLogger.GenerateDriverRecordLog(ARecord:PDriverSnapshot; ALog:TStrings):Boolean;
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
  For I := 0 To 28 Do
    ALog.Add(Format('    %s: 0x%p', [IrpMajorToStr(I), ARecord.MajorFunction[I]]));
  end;

If DL.IncludeNumberOfDevices Then
  ALog.Add(Format('  Number of devices:  %d', [ARecord.NumberOfDevices]));

Result := True;
end;


End.
