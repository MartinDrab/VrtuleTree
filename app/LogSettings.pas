Unit LogSettings;

Interface

Uses
  Classes, Generics.Collections;

Type
  TDeviceLogSettings = Record
    IncludeType : Boolean;
    IncludeDiskDevice : Boolean;

    IncludeUpperDevicesCount : Boolean;
    IncludeUpperDevices : Boolean;
    IncludeLowerDevicesCount : Boolean;
    IncludeLowerDevices : Boolean;

    IncludeFlags : Boolean;
    IncludeFlagsStr : Boolean;
    IncludeCharacteristics : Boolean;
    IncludeCharacteristicsStr : Boolean;

    IncludePnPInformation : Boolean;
    IncludeFriendlyName : Boolean;
    IncludeDescription : Boolean;
    IncludeVendor : Boolean;
    IncludeEnumerator : Boolean;
    IncludeLocation : Boolean;
    IncludeClass : Boolean;
    IncludeClassGuid : Boolean;

    IncludeExtensionFlags : Boolean;
    IncludeExtensionFlagsStr : Boolean;
    IncludeRemovalRelations : Boolean;
    IncludeEjectRelations : Boolean;
    IncludeDeviceId : Boolean;
    IncludeInstanceId : Boolean;
    IncludeHardwareIDs : Boolean;
    IncludeCompatibleIDs : Boolean;
    IncludeDeviceCapabilities : Boolean;

    IncludeSecurity : Boolean;
    end;
  PDeviceLogSettings = ^TDeviceLogSettings;

  TDriverLogSettings = Record
    IncludeFileName : Boolean;
    IncludeImageBase : Boolean;
    IncludeImageSize : Boolean;
    IncludeDriverEntry : Boolean;
    IncludeDriverUnload : Boolean;
    IncludeStartIo : Boolean;
    IncludeFlags : Boolean;
    IncludeFlagsStr : Boolean;
    IncludeMajorFunctions : Boolean;
    IncludeNumberOfDevices : Boolean;
    IncludeDevices : Boolean;
    IncludeFastIoDispatch : Boolean;
    end;
  PDriverLogSettings = ^TDriverLogSettings;

  TGeneralLogSettings = Record
    IncludeVTHeader : Boolean;
    IncludeOSVersion : Boolean;
    IncludeDeviceDrivers : Boolean;
    end;
  PGeneralLogSettings = ^TGeneralLogSettings;

  TLogSettings = Class
    Private
      FIncludedDrivers : TList<Pointer>;
    Public
      General : TGeneralLogSettings;
      DriverSettings : TDriverLogSettings;
      DeviceSettings : TDeviceLogSettings;
      Procedure IncludeDriver(AAddress:Pointer);
      Function DriverIncluded(AAddress:Pointer):Boolean;
      Procedure Clear;
      Constructor Create; Overload;
      Constructor Create(ASettings:TLogSettings); Overload;
      Destructor Destroy; Override;

      Procedure LoadFromStream(AStream:TStream);
      Procedure SaveToStream(AStream:TStream);
    end;

Implementation

Procedure TLogSettings.IncludeDriver(AAddress:Pointer);
begin
FIncludedDrivers.Add(AAddress);
end;

Procedure TLogSettings.Clear;
begin
FIncludedDrivers.Clear;
end;

Constructor TLogSettings.Create;
begin
Inherited Create;
FIncludedDrivers := TList<Pointer>.Create;
end;

Destructor TLogSettings.Destroy;
begin
FIncludedDrivers.Free;
Inherited Destroy;
end;

Function TLogSettings.DriverIncluded(AAddress:Pointer):Boolean;
begin
Result := FIncludedDrivers.Contains(AAddress);
end;

Constructor TLogSettings.Create(ASettings:TLogSettings);
Var
 I : Integer;
begin
Create;
General := ASettings.General;
DriverSettings := ASettings.DriverSettings;
DeviceSettings := ASettings.DeviceSettings;
For I := 0 To ASettings.FIncludedDrivers.Count - 1 Do
  FIncludedDrivers.Add(ASettings.FIncludedDrivers[I]);
end;

Procedure TLogSettings.LoadFromStream(AStream:TStream);
begin
end;

Procedure TLogSettings.SaveToStream(AStream:TStream);
begin
end;



End.

