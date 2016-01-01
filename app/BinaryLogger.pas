Unit BinaryLogger;

Interface

Uses
  Windows, Classes,
  VTreeDriver, Logger, DeviceDrivers, DeviceSnapshot, DriverSnapshot;

Type
  TBinaryLogHeader = Record
    VTreeMajorVersion : Cardinal;
    VTreeMinorVersion : Cardinal;
    LoggerVersion : Cardinal;
    PointerSize : Cardinal;
    SnapshotFlags : Cardinal;
    SpecialValues : SPECIAL_VALUES;
    end;
  PBinaryLogHeader = ^TBinaryLogHeader;

  TBinaryVersionInfo = Record
    Major : Cardinal;
    Minor : Cardinal;
    BuildNumber : Cardinal;
    Padding : Cardinal;
    End;
   PBinaryVersionInfo = ^TBinaryVersionInfo;

  TSnapshotBinaryLogger<T:TStream> = Class (TSnapshotLogger)
  Private
    FLogStorage : T;
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

Function TSnapshotBinaryLogger<T>.AssignLogStorage(ALogStorage:TObject):Boolean;
begin
FLogStorage := (ALogStorage As T);
Result := True;
end;

Function TSnapshotBinaryLogger<T>.GenerateUnknownDeviceLog(AAddress:Pointer):Boolean;
begin
Result := True;
end;

Function TSnapshotBinaryLogger<T>.GenerateDriverRecordLog(ARecord:TDriverSnapshot):Boolean;
begin
ARecord.SaveToStream(FLogStorage);
Result := True;
end;

Function TSnapshotBinaryLogger<T>.GenerateDeviceRecordLog(ARecord:TDeviceSnapshot):Boolean;
begin
ARecord.SaveToStream(FLogStorage);
Result := True;
end;

Function TSnapshotBinaryLogger<T>.GenerateDeviceDriverRecordLog(ADeviceDriver:TDeviceDriver):Boolean;
begin
ADeviceDriver.SaveToStream(FLogStorage);
Result := True;
end;

Function TSnapshotBinaryLogger<T>.GenerateOSVersionInfo:Boolean;
begin
Result := True;
end;

Function TSnapshotBinaryLogger<T>.GenerateVTHeader:Boolean;
begin
Result := True;
end;

End.
