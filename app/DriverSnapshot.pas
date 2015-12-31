Unit DriverSnapshot;

interface

Uses
  Kernel, VTreeDriver, AbstractSnapshotRecord, Classes,
  DeviceDrivers;

Type
  TDriverSnapshot = Class (TAbstractSnapshotRecord)
    Private
      FName : WideString;
      FAddress : Pointer;
      FDriverEntry : Pointer;
      FDriverUnload : Pointer;
      FStartIo : Pointer;
      FFlags : Cardinal;
      FImageBase : Pointer;
      FImageSize : Cardinal;
      FImagePath : WideString;
      FMajorFunction : TDriverMajorFunctions;
      FNumberOfDevices : Integer;
      FDevices : Array Of Pointer;
      FFastIoAddress : Pointer;
      FFastIoDispatch : FAST_IO_DISPATCH;
    Protected
      Function GetDevice(AIndex:Integer):Pointer;
      Procedure SetDevice(AIndex:Integer; AValue:Pointer);
    Public
      Constructor Create(ADriverInfo:PSNAPSHOT_DRIVERINFO; ADeviceDriverList:TDeviceDriverList); Reintroduce;
      Destructor Destroy; Override;

      Property Name : WideString Read FName;
      Property Address : Pointer Read FAddress;
      Property DriverEntry : Pointer Read FDriverEntry;
      Property DriverUnload : Pointer Read FDriverUnload;
      Property StartIo : Pointer Read FStartIo;
      Property Flags : Cardinal Read FFlags;
      Property ImageBase : Pointer Read FImageBase;
      Property ImageSize : Cardinal Read FImageSize;
      Property ImagePath : WideString Read FImagePath;
      Property MajorFunction : TDriverMajorFunctions Read FMajorFunction;
      Property NumberOfDevices : Integer Read FNumberofDevices;
      Property Devices [Index:Integer]:Pointer Read GetDevice Write SetDevice;
      Property FastIoAddress : Pointer Read FFastIoAddress;
      Property FastIoDispatch : FAST_IO_DISPATCH Read FFastIoDispatch;
    end;


implementation


Constructor TDriverSnapshot.Create(ADriverInfo:PSNAPSHOT_DRIVERINFO; ADeviceDriverList:TDeviceDriverList);
Var
  dd : TDeviceDriver;
begin
Inherited Create(srtDriver);
FAddress := ADriverInfo.ObjectAddress;
FName := CopyString(ADriverInfo, ADriverInfo.NameOffset);
FMajorFunction := ADriverInfo.MajorFunction;
FNumberOfDevices := ADriverInfo.NumberOfDevices;
FImageBase := ADriverInfo.ImageBase;
FImageSize := ADriverInfo.ImageSize;
FDriverEntry := ADriverInfo.DriverEntry;
FDriverUnload := ADriverInfo.DriverUnload;
FFlags := ADriverInfo.Flags;
FStartIo := ADriverInfo.StartIo;
FImagePath := '';
dd := ADeviceDriverList.GetDriverByImageBase(FImageBase);
If Assigned(dd) Then
  FImagePath := dd.FileName;

SetLength(FDevices, FNumberOfDevices);
FFastIoAddress := ADriverInfo.FastIoAddress;
FFastIoDispatch := ADriverInfo.FastIoDispatch;
end;


Destructor TDriverSnapshot.Destroy;
begin
SetLength(FDevices, 0);
Inherited Destroy;
end;

Function TDriverSnapshot.GetDevice(AIndex:Integer):Pointer;
begin
Result := FDevices[AIndex];
end;

Procedure TDriverSnapshot.SetDevice(AIndex:Integer; AValue:Pointer);
begin
FDevices[AIndex] := AValue;
end;

end.

