Unit Logger;

Interface

Uses
  Snapshot, LogSettings, Classes,
  VTreeDriver, DriverSnapshot, DeviceSnapshot,
  DeviceDrivers;

Type
  TSnapshotLogger = Class
  Protected
    FSnapshotFlags : Cardinal;
    FDriverList : TDeviceDriverList;
    FSnapshot : TVTreeSnapshot;
    FLogSettings : TLogSettings;
    FSpecialValues : SPECIAL_VALUES;
    Function AssignLogStorage(ALogStorage:TObject):Boolean; Virtual; Abstract;
    Function GenerateUnknownDeviceLog(AAddress:Pointer):Boolean; Virtual; Abstract;
    Function GenerateDriverRecordLog(ARecord:TDriverSnapshot):Boolean; Virtual; Abstract;
    Function GenerateDeviceRecordLog(ARecord:TDeviceSnapshot):Boolean; Virtual; Abstract;
    Function GenerateOSVersionInfo:Boolean; Virtual; Abstract;
    Function GenerateDeviceDriverRecordLog(ADeviceDriver:TDeviceDriver):Boolean; Virtual; Abstract;
    Function GenerateVTHeader:Boolean; Virtual; Abstract;
  Public
    Constructor Create(ASnapshot:TVTreeSnapshot; ALogSettings:TLogSettings; ASnapshotFlags:Cardinal; ADriverList:TDeviceDriverList; Var ASpecialValues:SPECIAL_VALUES); Reintroduce;
    Destructor Destroy; Override;
    Function Generate(ALogStorage:TObject):Boolean;
  end;

Implementation

Uses
  SysUtils;

Constructor TSnapshotLogger.Create(ASnapshot:TVTreeSnapshot; ALogSettings:TLogSettings; ASnapshotFlags:Cardinal; ADriverList:TDeviceDriverList; Var ASpecialValues:SPECIAL_VALUES);
begin
Inherited Create;
FSnapshot := ASnapshot;
FLogSettings := ALogSettings;
FDriverList := ADriverList;
FSnapshotFlags := ASnapshotFlags;
FSpecialValues := ASpecialValues;
end;

Destructor TSnapshotLogger.Destroy;
begin
Inherited Destroy;
end;

Function TSnapshotLogger.Generate(ALogStorage:TObject):Boolean;
Var
  dd : TDeviceDriver;
  I, J : Integer;
  tmp : TDeviceSnapshot;
  DR : TDriverSnapshot;
begin
Result := AssignLogStorage(ALogStorage);
If Result Then
  begin
  If FLogSettings.General.IncludeVTHeader Then
    GenerateVTHeader;

  If FLogSettings.General.IncludeOSVersion Then
    GenerateOSVersionInfo;

  If FLogSettings.General.IncludeDeviceDrivers Then
    begin
    For I := 0 To FDriverList.DriverCount - 1 Do
      begin
      dd := FDriverList.Driver[I];
      GenerateDeviceDriverRecordLog(dd);
      end;
    end;

  For I := 0 To FSnapshot.DriverRecordsCount - 1 Do
    begin
    DR := FSnapshot.DriverRecords[I];
    If FLogSettings.DriverIncluded(DR.Address) Then
      begin
      GenerateDriverRecordLog(DR);
      If FLogSettings.DriverSettings.IncludeDevices Then
        begin
        For J := 0 To DR.NumberOfDevices - 1 Do
          begin
          tmp := FSnapshot.GetDeviceByAddress(DR.Devices[J]);
          If Assigned(tmp) Then
            GenerateDeviceRecordLog(tmp)
          Else GenerateUnknownDeviceLog(DR.Devices[J]);
          end;
        end;
      end;
    end;
  end;
end;



End.

