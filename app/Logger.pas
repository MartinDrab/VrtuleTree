Unit Logger;

Interface

Uses
  Snapshot, LogSettings, Classes,
  VTreeDriver, DriverSnapshot, DeviceSnapshot;

Type
  TSnapshotLogger = Class
  Protected
    FSnapshot : TVTreeSnapshot;
    FLogSettings : TLogSettings;
    Function GenerateUnknownDeviceLog(AAddress:Pointer; ALog:TStrings):Boolean; Virtual; Abstract;
    Function GenerateDriverRecordLog(ARecord:TDriverSnapshot; ALog:TStrings):Boolean; Virtual; Abstract;
    Function GenerateDeviceRecordLog(ARecord:TDeviceSnapshot; ALog:TStrings):Boolean; Virtual; Abstract;
    Function GenerateOSVersionInfo(ALog:TStrings):Boolean; Virtual; Abstract;
    Function GenerateVTHeader(ALog:TStrings):Boolean; Virtual; Abstract;
  Public
    Constructor Create(ASnapshot:TVTreeSnapshot; ALogSettings:TLogSettings);
    Destructor Destroy; Override;
    Function Generate(ALog:TStrings):Boolean;
  end;

Implementation

Uses
  SysUtils;

Constructor TSnapshotLogger.Create(ASnapshot:TVTreeSnapshot; ALogSettings:TLogSettings);
begin
Inherited Create;
FSnapshot := ASnapshot;
FLogSettings := ALogSettings;
end;

Destructor TSnapshotLogger.Destroy;
begin
Inherited Destroy;
end;

Function TSnapshotLogger.Generate(ALog:TStrings):Boolean;
Var
  I, J : Integer;
  tmp : TDeviceSnapshot;
  DR : TDriverSnapshot;
begin
Result := True;
If FLogSettings.General.IncludeVTHeader Then
  GenerateVTHeader(ALog);

If FLogSettings.General.IncludeOSVersion Then
  GenerateOSVersionInfo(ALog);

For I := 0 To FSnapshot.DriverRecordsCount - 1 Do
  begin
  DR := FSnapshot.DriverRecords[I];
  If FLogSettings.DriverIncluded(DR.Address) Then
    begin
    GenerateDriverRecordLog(DR, ALog);
    If FLogSettings.DriverSettings.IncludeDevices Then
      begin
      For J := 0 To DR.NumberOfDevices - 1 Do
        begin
        tmp := FSnapshot.GetDeviceByAddress(DR.Devices[J]);
        If Assigned(tmp) Then
          GenerateDeviceRecordLog(tmp, ALog)
        Else GenerateUnknownDeviceLog(DR.Devices[J], ALog);
        end;
      end;
    end;
  end;

Result := True;
end;

End.

