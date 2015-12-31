Unit DeviceDrivers;

Interface

Uses
  Windows, Kernel,
  Classes, Generics.Collections;

Type
  TDriverListOption = (
    dloVerifyDigitalSignatures,
    dloNoLifetimeTimeStamps,
    dloCheckCRLs,
    dloCaptureCertNames
  );
  TDriverListOptions = Set Of TDriverListOption;

  TCertNameArray = Array Of WideString;
  TDeviceDriver = Class
  Private
    FImageBase : Pointer;
    FImageSize : Cardinal;
    FFileName : WideString;
    FFilePresent : Boolean;
    FCertNames : TCertNameArray;
    FSignatureStatus : Cardinal;
    FTimeStampExpired : Boolean;
    Procedure TranslateFileName;
  Public
    Constructor Create(Var AModule:SYSTEM_MODULE; AOptions:TDriverListOptions); Reintroduce;
    Destructor Destroy; Override;

    Property ImageBase : Pointer Read FImageBase;
    Property ImageSize : Cardinal Read FImageSize;
    Property FileName : WideString Read FFileName;
    Property FilePresent : Boolean Read FFilePresent;
    Property CertNames : TCertNameArray Read FCertNames;
    Property SignatureStatus : Cardinal Read FSignatureStatus;
    Property TimeStampExpired : Boolean Read FTimeStampExpired;
  end;

  TDeviceDriverList = Class
  Private
    FFileNameTable : TDictionary<WideString, TDeviceDriver>;
    FImageBaseTable : TDictionary<Pointer, TDeviceDriver>;
    FDriverList : TList<TDeviceDriver>;
    FOptions : TDriverListOptions;
  Protected
    Function GetDriver(AIndex:Integer):TDeviceDriver;
    Function GetDriverCount:Integer;
  Public
    Constructor Create;
    Destructor Destroy; Override;

    Procedure Clear;
    Function Enumerate:Boolean;
    Function GetDriverByImageBase(AImageBase:Pointer):TDeviceDriver;
    Function GetDriverByFileName(AFileName:WideString):TDeviceDriver;
    Function GetDriverByRange(AAddress:Pointer):TDeviceDriver;

    Property Driver[Index:Integer] : TDeviceDriver Read GetDriver;
    Property DriverCount : Integer Read GetDriverCount;
    Property Options : TDriverListOptions Read FOptions Write FOptions;
  end;


Implementation

Uses
  SysUtils, CodeSigning;

(** TDeviceDriver **)

Constructor TDeviceDriver.Create(Var AModule:SYSTEM_MODULE; AOptions:TDriverListOptions);
Var
  I : Integer;
  err : Cardinal;
  cn : TStringList;
  cso : TCodeSigningOptionSet;
begin
Inherited Create;
FImageBase := AModule.ImageBase;
FImageSize := AModule.ImageSize;
FFileName := Copy(WideString(AnsiString(PAnsiChar(@AModule.FullPathName))), 1, Strlen(PAnsiChar(@AModule.FullPathName)));
TranslateFileName;
FSignatureStatus := ERROR_SUCCESS;
SetLength(FCertNames, 0);
FTimeStampExpired := False;
FFilePresent := FileExists(FFileName);
If FFilePresent Then
  begin
  If (dloVerifyDigitalSignatures In AOptions) Then
    begin
    cso := [];
    If (dloCheckCRLs In AOptions) Then
      cso := cso + [csoCheckRevocations];

    If (dloNoLifetimeTimeStamps In AOptions) Then
      cso := cso + [csoNoLifetimeTimeStamps];

    FSignatureStatus := IsCodeSigned(FFileName, cso);
    If (FSignatureStatus = $800b0101) And
       (dloNoLifetimeTimeStamps In AOptions) Then
       begin
       cso := cso - [csoNoLifetimeTimeStamps];
       FTimeStampExpired := IsCodeSigned(FFilename, cso) = ERROR_SUCCESS;
       end;
    end;

  If (dloCaptureCertNames In AOptions) Then
    begin
    cn := TStringList.Create;
    err := GetFileCertificateNames(FFileName, cn);
    If err = ERROR_SUCCESS Then
      begin
      SetLength(FCertNames, cn.Count);
      For I := 0 To cn.Count - 1 Do
        FCertNames[I] := cn[I];
      end
    Else begin
      SetLength(FCertNames, 1);
      FCertNames[0] := Format('%s (%d)', [SysErrorMessage(err), err]);
      end;

    cn.Free;
    end;
  end;
end;

Destructor TDeviceDriver.Destroy;
begin
SetLength(FCertNames, 0);
Inherited Destroy;
end;

Procedure TDeviceDriver.TranslateFileName;
Var
  windir : Array [0..MAX_PATH] Of WideChar;
  wd : WideString;
begin
ZeroMemory(@windir, SizeOf(windir));
GetWindowsDirectoryW(@windir, MAX_PATH);
wd := Copy(WideString(Windir), 1, StrLen(winDir));
If (Length(FFileName) > 1) And (FFileName[1] <> '\') Then
  FFileName := Format('\??\%s\%s', [wd, FFileName]);

If Pos(WideString('\SystemRoot\'), FFileName) = 1 Then
  begin
  Delete(FFileName, 1, Length('\SystemRoot\'));
  FFileName := Format('\??\%s\%s', [wd, FFileName]);
  end;
end;


(** TDeviceDriverList **)

Constructor TDeviceDriverList.Create;
begin
Inherited Create;
FOptions := [dloVerifyDigitalSignatures] + [dloCaptureCertnames];
FDriverList := TList<TDeviceDriver>.Create;
FImageBaseTable := TDictionary<Pointer, TDeviceDriver>.Create;
FFileNameTable := TDictionary<WideString, TDeviceDriver>.Create;
end;

Destructor TDeviceDriverList.Destroy;
begin
Clear;
FFileNameTable.Free;
FImageBaseTable.Free;
FDriverList.Free;
Inherited Destroy;
end;

Function TDeviceDriverList.Enumerate:Boolean;
Var
  dd : TDeviceDriver;
  I : Integer;
  status : Cardinal;
  smiLen : Cardinal;
  smi : PSYSTEM_MODULE_INFORMATION;
  sm : PSYSTEM_MODULE;
  ReturnLen : Cardinal;
  opt : TDriverListOptions;
begin
opt := FOptions;
smi := Nil;
smilen := 512;
Result := False;
status := STATUS_INFO_LENGTH_MISMATCH;
While status = STATUS_INFO_LENGTH_MISMATCH Do
  begin
  Inc(smiLen, smiLen);
  If Assigned(smi) Then
    HeapFree(GetProcessHeap, 0, smi);

  smi := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, smiLen);
  If Assigned(smi) Then
    status := NtQuerySystemInformation(11, smi, smiLen, ReturnLen)
  Else status := STATUS_INSUFFICIENT_RESOURCES;
  end;

Result := status = 0;
If Result Then
  begin
  Clear;
  For I := 0 To smi.Count - 1 Do
    begin
    dd := TDeviceDriver.Create(smi.Modules[I], opt);
    FDriverList.Add(dd);
    FImageBaseTable.Add(dd.ImageBase, dd);
    FFileNameTable.Add(dd.FileName, dd);
    end;

  HeapFree(GetProcessHeap, 0, smi);
  end;
end;

Function TDeviceDriverList.GetDriverByImageBase(AImageBase:Pointer):TDeviceDriver;
begin
If Not FImageBaseTable.TryGetValue(AImageBase, Result) Then
  Result := Nil;
end;

Function TDeviceDriverList.GetDriverByFileName(AFileName:WideString):TDeviceDriver;
begin
If Not FFileNameTable.TryGetValue(AFileName, Result) Then
  Result := Nil;
end;

Function TDeviceDriverList.GetDriverByRange(AAddress:Pointer):TDeviceDriver;
Var
  dd : TDeviceDriver;
begin
Result := Nil;
For dd In FDriverList Do
  begin
  If (NativeUInt(dd.ImageBase) <= NativeUInt(AAddress)) And
     (NativeUInt(dd.ImageBase) + dd.ImageSize > NativeUInt(AAddress)) Then
    begin
    Result := dd;
    Break;
    end;
  end;
end;

Function TDeviceDriverList.GetDriver(AIndex:Integer):TDeviceDriver;
begin
Result := FDriverList[AIndex];
end;

Function TDeviceDriverList.GetDriverCount:Integer;
begin
Result := FDriverList.Count;
end;

Procedure TDeviceDriverList.Clear;
Var
  dd : TDeviceDriver;
begin
FFileNameTable.Clear;
FImageBaseTable.Clear;
For dd In FDriverList Do
  dd.Free;

FDriverList.Clear;
end;



End.

