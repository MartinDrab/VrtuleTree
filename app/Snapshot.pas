Unit Snapshot;

Interface


Uses
  WIndows, Kernel, VTreeDriver, Classes,
  Generics.Collections,
  DeviceSnapshot, DriverSnapshot, DeviceDrivers;

Type
  TVTreeSnapshot = Class
    Private
      FDeviceDriverList : TDeviceDriverList;
      FDriverTable : TDictionary<Pointer, TDriverSnapshot>;
      FDeviceTable : TDictionary<Pointer, TDeviceSnapshot>;
      FDevNodeTable : TDictionary<Pointer, TDeviceSnapshot>;
      FDriverRecords : TList<TDriverSnapshot>;
      FDeviceRecords : TList<TDeviceSnapshot>;
    Protected
      Function GetDriverRecord(AIndex:Integer):TDriverSnapshot;
      Function GetDriverRecordsCount:Integer;
      Function GetDeviceRecord(AIndex:Integer):TDeviceSnapshot;
      Function GetDeviceRecordsCount:Integer;
    Public
      Constructor Create(ADeviceDriverList:TDeviceDriverList; ARawSnapshot:Pointer); Reintroduce;
      Destructor Destroy; Override;

      Function GetDriverByAddress(AAddress:Pointer):TDriverSnapshot;
      Function GetDeviceByAddress(AAddress:Pointer):TDeviceSnapshot;
      Function GetDeviceByDeviceNode(ADeviceNode:Pointer):TDeviceSnapshot;
      Function GetDeviceAddressFromDeviceNode(ADeviceNode:Pointer):Pointer;

      Class Function TranslateAddress(Var ASpecialValues:SPECIAL_VALUES; AAddress:Pointer):WideString;

      Property DriverRecords [Index:Integer] : TDriverSnapshot Read GetDriverRecord;
      Property DriverRecordsCount : Integer Read GetDriverRecordsCount;
      Property DeviceRecords [Index:Integer] : TDeviceSnapshot Read GetDeviceRecord;
      Property DeviceRecordsCount : Integer Read GetDeviceRecordsCount;
    end;



Implementation

Uses
  SysUtils, Utils;


Constructor TVTreeSnapshot.Create(ADeviceDriverList:TDeviceDriverList; ARawSnapshot:Pointer);
Var
  Ret : Boolean;
  DriverRecord : TDriverSnapshot;
  DeviceRecord : TDeviceSnapshot;
  DriverList : PSNAPSHOT_DRIVERLIST;
  DriverInfo : PSNAPSHOT_DRIVERINFO;
  DeviceInfo : PSNAPSHOT_DEVICEINFO;
  DriverInfoHandle : PPointer;
  DeviceInfoHandle : PPointer;
  I, J : Integer;
begin
Inherited Create;
FDeviceTable := TDictionary<Pointer, TDeviceSnapshot>.Create;
FDriverTable := TDictionary<Pointer, TDriverSnapshot>.Create;
FDevNodeTable := TDictionary<Pointer, TDeviceSnapshot>.Create;
FDriverRecords := TList<TDriverSnapshot>.Create;
FDeviceRecords := TList<TDeviceSnapshot>.Create;
FDeviceDriverList := ADeviceDriverList;
DriverList := ARawSnapshot;
DriverInfoHandle := PPointer(NativeInt(DriverList) + DriverList.DriversOffset);
For I := 0 To DriverList.NumberOfDrivers - 1 Do
  begin
  DriverInfo := DriverInfoHandle^;
  DriverRecord := TDriverSnapshot.Create(DriverInfo, FDeviceDriverList);
  Ret := Assigned(DriverRecord);
  If Ret Then
    begin
    DeviceInfoHandle := PPointer(NativeInt(DriverInfo) + DriverInfo.DevicesOffset);
    For J := 0 To DriverRecord.NumberOfDevices - 1 Do
      begin
      DeviceInfo := DeviceInfoHandle^;
      DriverRecord.Devices[J] := DeviceInfo.ObjectAddress;
      DeviceRecord := TDeviceSnapshot.Create(DeviceInfo, DriverRecord);
      Ret := Assigned(DeviceRecord);
      If Ret Then
        begin
        FDeviceTable.Add(DeviceRecord.Address, DeviceRecord);
        FDeviceRecords.Add(DeviceRecord);
        If ((DeviceRecord.Flags And DO_BUS_ENUMERATED_DEVICE) <> 0) And
           (Assigned(DeviceRecord.DeviceNode)) Then
           FDevNodeTable.Add(DeviceRecord.DeviceNode, DeviceRecord);

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
end;

Destructor TVTreeSnapshot.Destroy;
Var
  der : TDeviceSnapshot;
  drr : TDriverSnapshot;
begin
For der In FDeviceRecords Do
  der.Free;

FDeviceRecords.Free;
For drr In FDriverRecords Do
  drr.Free;

FDriverRecords.Free;
FDevNodeTable.Free;
FDeviceTable.Free;
FDriverTable.Free;
Inherited Destroy;
end;

Function TVTreeSnapshot.GetDriverRecordsCount:Integer;
begin
Result := FDriverRecords.Count;
end;

Function TVTreeSnapshot.GetDriverRecord(AIndex:Integer):TDriverSnapshot;
begin
Result := FDriverRecords[AIndex];
end;


Function TVTreeSnapshot.GetDriverByAddress(AAddress:Pointer):TDriverSnapshot;
begin
If Not FDriverTable.TryGetValue(AAddress, Result) Then
  Result := Nil;
end;

Function TVTreeSnapshot.GetDeviceByAddress(AAddress:Pointer):TDeviceSnapshot;
begin
If Not FDeviceTable.TryGetValue(AAddress, Result) Then
  Result := Nil;
end;

Function TVTreeSnapshot.GetDeviceRecord(AIndex:Integer):TDeviceSnapshot;
begin
Result := FDeviceRecords[AIndex];
end;

Function TVTreeSnapshot.GetDeviceRecordsCount:Integer;
begin
Result := FDeviceRecords.Count;
end;

Function TVTreeSnapshot.GetDeviceByDeviceNode(ADeviceNode:Pointer):TDeviceSnapshot;
begin
If Not FDevNodeTable.TryGetValue(ADeviceNode, Result) Then
  Result := Nil;
end;

Function TVTreeSnapshot.GetDeviceAddressFromDeviceNode(ADeviceNode:Pointer):Pointer;
Var
  ds : TDeviceSnapshot;
begin
Result := Nil;
If FDevNodeTable.TryGetValue(ADeviceNode, ds) Then
  Result := ds.Address;
end;

Class Function TVTreeSnapshot.TranslateAddress(Var ASpecialValues:SPECIAL_VALUES; AAddress:Pointer):WideString;
Const
  RoutineNameArray : Array [0..8] Of WideString = (
    'IopInvalidDeviceRequest',
    'FsRtlAcquireFileExclusive',
    'FsRtlCopyRead',
    'FsRtlCopyWrite',
    'FsRtlMdlReadDev',
    'FsRtlMdlReadCompleteDev',
    'FsRtlPrepareMdlWriteDev',
    'FsRtlMdlWriteCompleteDev',
    'FsRtlReleaseFile'
  );

Var
  I : Integer;
begin
Result := '';
For I := Low(ASpecialValues.RoutineAddress) To High(ASpecialValues.RoutineAddress) Do
  begin
  If ASpecialValues.RoutineAddress[I] = AAddress Then
    begin
    Result := RoutineNameArray[I];
    Break;
    end;
  end;
end;


End.

