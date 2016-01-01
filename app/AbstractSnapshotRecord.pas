Unit AbstractSnapshotRecord;

Interface

Uses
  Windows, SysUtils, Classes;

Type
  TSnapshotRecordType = (
    srtDriver,
    srtDevice,
    srtLoadedDriver
  );

  TPointerArray = Array Of Pointer;
  TWideStringArray = Array Of WideString;

  TAbstractSnapshotRecord = Class
  Private
    FRecordType : TSnapshotRecordType;
  Protected
    Procedure ReadString(AStream:TStream; Var AString:WideString);
    Procedure ReadPointer(AStream:TStream; Var APointer:Pointer);
    Procedure Read32(AStream:TStream; Var AValue:Cardinal);
    Procedure Read64(AStream:TStream; Var AValue:UInt64);
    Procedure ReadPointerArray(AStream:TStream; Var AValue:TPointerArray);

    Procedure WriteString(AStream:TStream; AString:WideString);
    Procedure WritePointer(AStream:TStream; APointer:Pointer);
    Procedure Write32(AStream:TStream; AValue:Cardinal);
    Procedure Write64(AStream:TStream; AValue:UInt64);
    Procedure WritePointerArray(AStream:TStream; AValue:TPointerArray);

    Function CopyString(AStart:Pointer; AOffset:Cardinal):WideString;
  Public
    Constructor Create(ARecordType:TSnapshotRecordType); Reintroduce;

    Procedure SaveToStream(AStream:TStream); Virtual;
    Procedure LoadFromStream(AStream:TStream); Virtual;

    Property RecordType : TSnapshotRecordType Read FRecordType;
  end;

Implementation

Constructor TAbstractSnapshotRecord.Create(ARecordType:TSnapshotRecordType);
begin
Inherited Create;
FRecordType := ARecordType;
end;


Function TAbstractSnapshotRecord.CopyString(AStart:Pointer; AOffset:Cardinal):WideString;
Var
  W : PWChar;
begin
W := PWChar(NativeInt(AStart) + AOffset);
Result := Copy(WideString(W), 1, Strlen(W));
end;


Procedure TAbstractSnapshotRecord.ReadString(AStream:TStream; Var AString:WideString);
Var
  len : Cardinal;
begin
Read32(AStream, len);
SetLength(AString, len);
AStream.Read(PWideChar(AString)^, len*SizeOf(WideChar));
end;

Procedure TAbstractSnapshotRecord.ReadPointer(AStream:TStream; Var APointer:Pointer);
begin
AStream.Read(APointer, SizeOf(Pointer));
end;

Procedure TAbstractSnapshotRecord.Read32(AStream:TStream; Var AValue:Cardinal);
begin
AStream.Read(AValue, SizeOf(Cardinal));
end;

Procedure TAbstractSnapshotRecord.Read64(AStream:TStream; Var AValue:UInt64);
begin
AStream.Read(AValue, SizeOf(UInt64));
end;

Procedure TAbstractSnapshotRecord.ReadPointerArray(AStream:TStream; Var AValue:TPointerArray);
Var
  I : Integer;
  len : Cardinal;
begin
Read32(AStream, len);
SetLength(AValue, len);
For I := Low(AValue) To High(AValue) Do
  ReadPointer(AStream, AValue[I]);
end;

Procedure TAbstractSnapshotRecord.WriteString(AStream:TStream; AString:WideString);
Var
  len : Cardinal;
begin
len := Length(AString);
Write32(AStream, len);
AStream.Write(PWideChar(AString)^, len*SizeOf(WideChar));
end;

Procedure TAbstractSnapshotRecord.WritePointer(AStream:TStream; APointer:Pointer);
begin
AStream.Write(APointer, SizeOf(Pointer));
end;

Procedure TAbstractSnapshotRecord.Write32(AStream:TStream; AValue:Cardinal);
begin
AStream.Write(AValue, SizeOf(Cardinal));
end;

Procedure TAbstractSnapshotRecord.Write64(AStream:TStream; AValue:UInt64);
begin
AStream.Write(AValue, SizeOf(UInt64));
end;

Procedure TAbstractSnapshotRecord.WritePointerArray(AStream:TStream; AValue:TPointerArray);
Var
  I : Integer;
  len : Cardinal;
begin
len := Length(AValue);
Write32(AStream, len);
for I := Low(AValue) To High(AValue) Do
  WritePointer(AStream, AValue[I]);
end;

Procedure TAbstractSnapshotRecord.SaveToStream(AStream:TStream);
begin
AStream.Write(FRecordType, SizeOf(FRecordType));
end;

Procedure TAbstractSnapshotRecord.LoadFromStream(AStream:TStream);
begin
AStream.Read(FRecordType, SizeOf(FRecordType));
end;



End.

