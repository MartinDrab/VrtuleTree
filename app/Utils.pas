Unit Utils;

Interface

Uses
  Windows, Classes;

Function GetDeviceDriverList(Addresses:TList; Sizes:TList; Names:TStringList):Boolean;
Procedure DebugPrint(AMsg:WideString; AArgs:Array Of Const);
Procedure ErrorDialog(AMsg:WideString);
Procedure WarningDialog(AMsg:WideString);
Procedure InformationDialog(AMsg:WideString);

Implementation

Uses
  PSAPI, SysUtils;

Const
  STATUS_SUCCESS              =           0;
  STATUS_INFO_LENGTH_MISMATCH =   $C0000004;
  STATUS_INSUFFICIENT_RESOURCES = $C000009A;

Type
  SYSTEM_MODULE = Record
    Section : THandle;
    MappedBase : Pointer;
    ImageBase : Pointer;
    ImageSize : ULONG;
    Flags : ULONG;
    LoadOrderIndex : Word;
    InitOrderIndex : Word;
    LoadCount : Word;
    OffsetToFileName : Word;
    FullPathName : Packed Array [0..255] Of AnsiChar;
    end;
  PSYSTEM_MODULE = ^SYSTEM_MODULE;

  SYSTEM_MODULE_INFORMATION = Record
    Count : Cardinal;
    Modules : Array [0..0] Of SYSTEM_MODULE;
    end;
  PSYSTEM_MODULE_INFORMATION = ^SYSTEM_MODULE_INFORMATION;


Function NtQuerySystemInformation(SystemInformationClass:Cardinal; SystemInformation:Pointer; SystemInformationLength:Cardinal; ReturnLength:PCardinal):Cardinal; StdCall; External 'ntdll.dll';


Function GetDeviceDriverList(Addresses:TList; Sizes:TList; Names:TStringList):Boolean;
Var
  I : Integer;
  Status : Cardinal;
  smiLen : Cardinal;
  smi : PSYSTEM_MODULE_INFORMATION;
  sm : PSYSTEM_MODULE;
  ReturnLen : Cardinal;
begin
smi := Nil;
smilen := 512;
Result := False;
Status := STATUS_INFO_LENGTH_MISMATCH;
While Status = STATUS_INFO_LENGTH_MISMATCH Do
  begin
  Inc(smiLen, smiLen);
  If Assigned(smi) Then
    HeapFree(GetProcessHeap, 0, smi);

  smi := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, smiLen);
  If Assigned(smi) Then
    Status := NtQuerySystemInformation(11, smi, smiLen, @ReturnLen)
  Else Status := STATUS_INSUFFICIENT_RESOURCES;
  end;

Result := Status = 0;
If Result Then
  begin
  For I := 0 To smi.Count - 1 Do
    begin
    sm := @smi.Modules[I];
    Addresses.Add(sm.ImageBase);
    Sizes.Add(Pointer(sm.ImageSize));
    Names.Add(Copy(WideString(AnsiString(PAnsiChar(@sm.FullPathName))), 1, Strlen(PAnsiChar(@sm.FullPathName))));
    end;

  HeapFree(GetProcessHeap, 0, smi);
  end;
end;

Procedure DebugPrint(AMsg:WideString; AArgs:Array Of Const);
begin
{$IFDEF DEBUG}
OutputDebugStringW(PWideChar(Format(AMsg, AArgs)));
{$ENDIF}
end;

Procedure ErrorDialog(AMsg:WideString);
begin
MessageBoxW(0, PWideChar(AMsg), 'Error', MB_OK Or MB_ICONERROR);
end;

Procedure WarningDialog(AMsg:WideString);
begin
MessageBoxW(0, PWideChar(AMsg), 'Warning', MB_OK Or MB_ICONWARNING);
end;

Procedure InformationDialog(AMsg:WideString);
begin
MessageBoxW(0, PWideChar(AMsg), 'Information', MB_OK Or MB_ICONINFORMATION);
end;


End.

