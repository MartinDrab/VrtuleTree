Unit AbstractSnapshotRecord;

Interface

Uses
  Windows, SysUtils;

Type
  TSnapshotRecordType = (
    srtDriver,
    srtDevice
  );

  TPointerArray = Array Of Pointer;
  TWideStringArray = Array Of WideString;

  TAbstractSnapshotRecord = Class
  Private
    FRecordType : TSnapshotRecordType;
  Protected
    Function CopyString(AStart:Pointer; AOffset:Cardinal):WideString;
  Public
    Constructor Create(ARecordType:TSnapshotRecordType); Reintroduce;

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


End.
