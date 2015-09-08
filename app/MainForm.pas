Unit MainForm;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.Menus, VTreeDriver, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.CheckLst, LogSettings, Snapshot;

Type
  TDeviceNodeType = (dntLower, dntCurrent, dntUpper);

  TDriverDisplaySettings = Record
    TreeDevices : Boolean;
    Flags : Boolean;
    MajorFunction : Boolean;
    Devices : Boolean;
    end;
  PDriverDisplaySettings = ^TDriverDisplaySettings;

  TDeviceDisplaySettings = Record
    TreeUpperDevices : Boolean;
    TreeLowerDevices : Boolean;
    Flags : Boolean;
    Characteristics : Boolean;
    VPB : Boolean;
    PnP : Boolean;
    HardwareId : Boolean;
    CompatibleId : Boolean;
    Capabilities : Boolean;
    RemovalRelations : Boolean;
    EjectRelations : Boolean;
    Security : Boolean;
    end;
  PDeviceDisplaySettings = ^TDeviceDisplaySettings;

  TForm1 = Class (TForm)
    DriverDeviceTreeView: TTreeView;
    PageControl1: TPageControl;
    DeviceTabSheet: TTabSheet;
    DriverTabSheet: TTabSheet;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Createsnapshot1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    DriverDevicesGroupBox: TGroupBox;
    DriverMajorFunctionGroupBox: TGroupBox;
    DriverDevicesListView: TListView;
    MajorFunctionListview: TListView;
    DriverGeneralInfoPanel: TPanel;
    DriverAddressLEdit: TLabeledEdit;
    DriverNameLEdit: TLabeledEdit;
    DeviceFlagsGroupBox: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    DeviceCharacteristicsGroupBox: TGroupBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    CheckBox19: TCheckBox;
    CheckBox20: TCheckBox;
    CheckBox21: TCheckBox;
    CheckBox22: TCheckBox;
    DevicePnPGroupBox: TGroupBox;
    DevicePnpListView: TListView;
    CheckBox23: TCheckBox;
    CheckBox24: TCheckBox;
    CheckBox25: TCheckBox;
    CheckBox26: TCheckBox;
    CheckBox27: TCheckBox;
    CheckBox28: TCheckBox;
    CheckBox29: TCheckBox;
    CheckBox30: TCheckBox;
    CheckBox31: TCheckBox;
    CheckBox32: TCheckBox;
    Createlog1: TMenuItem;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit5: TLabeledEdit;
    LabeledEdit6: TLabeledEdit;
    LabeledEdit7: TLabeledEdit;
    est1: TMenuItem;
    SaveDialog1: TSaveDialog;
    TabSheet1: TTabSheet;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    LogIncludeDriversChL: TCheckListBox;
    LogDriverSettingsChL: TCheckListBox;
    LogDeviceSettingsChL: TCheckListBox;
    Panel3: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Panel4: TPanel;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Panel5: TPanel;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Panel6: TPanel;
    GroupBox9: TGroupBox;
    CheckBox33: TCheckBox;
    CheckBox34: TCheckBox;
    DriverFlagsGroupBox: TGroupBox;
    CheckBox36: TCheckBox;
    CheckBox37: TCheckBox;
    CheckBox38: TCheckBox;
    CheckBox39: TCheckBox;
    CheckBox40: TCheckBox;
    CheckBox41: TCheckBox;
    CheckBox42: TCheckBox;
    CheckBox35: TCheckBox;
    DeviceVPBGroupBox: TGroupBox;
    LabeledEdit8: TLabeledEdit;
    LabeledEdit9: TLabeledEdit;
    LabeledEdit10: TLabeledEdit;
    LabeledEdit11: TLabeledEdit;
    Edit9: TEdit;
    Label9: TLabel;
    Edit10: TEdit;
    Label10: TLabel;
    CheckBox43: TCheckBox;
    CheckBox44: TCheckBox;
    CheckBox45: TCheckBox;
    CheckBox46: TCheckBox;
    CheckBox47: TCheckBox;
    CheckBox48: TCheckBox;
    DeviceGeneralInfoPanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    DeviceScrollBox: TScrollBox;
    RemovalRelationsGroupBox: TGroupBox;
    RemovalRelationsListView: TListView;
    EjectRelationsGroupBox: TGroupBox;
    EjectRelationsListView: TListView;
    View1: TMenuItem;
    DriverDisplayMenuItem: TMenuItem;
    DeviceDisplayMenuItem: TMenuItem;
    Devices1: TMenuItem;
    N2: TMenuItem;
    Flags1: TMenuItem;
    Devices2: TMenuItem;
    MajorFunction1: TMenuItem;
    Lowerdevicestree1: TMenuItem;
    Upperdevicestree1: TMenuItem;
    N3: TMenuItem;
    Flags2: TMenuItem;
    Characteristics1: TMenuItem;
    VPB1: TMenuItem;
    PnPinformation1: TMenuItem;
    HardwareIDs1: TMenuItem;
    CompatibleIDs1: TMenuItem;
    Removalrelations1: TMenuItem;
    Ejectrelations1: TMenuItem;
    Security1: TMenuItem;
    Help1: TMenuItem;
    AboutVrtuleTree1: TMenuItem;
    CompatibleIDsGroupBox: TGroupBox;
    CompatibleIDsListView: TListView;
    HardwareIDsGroupBox: TGroupBox;
    HardwareIDsListView: TListView;
    CapabilitiesGroupBox: TGroupBox;
    CapabilitiesListView: TListView;
    Capabilities1: TMenuItem;
    Procedure FormCreate(Sender: TObject);
    Procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Procedure Exit1Click(Sender: TObject);
    Procedure Createsnapshot1Click(Sender: TObject);
    Procedure DriverDeviceTreeViewChange(Sender: TObject; Node: TTreeNode);
    Procedure est1Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure LogDriverSettingsChLClickCheck(Sender: TObject);
    procedure DisplayMenuItemClick(Sender: TObject);
  Private
    FDriverAddresses : TList;
    FDriverSizes : TList;
    FDriverNames : TStringList;
    FLogSettings : TLogSettings;
    FSnapshot : TVTreeSnapshot;
    FDriverDisplaySettings : TDriverDisplaySettings;
    FDeviceDisplaySettings : TDeviceDisplaySettings;
    Function CreateSnapshot:Boolean;
    Procedure DestroySnapshot;
    Function CreateDriverNode(ADriverRecord:PDriverSnapshot):TTreeNode;
    Function CreateDeviceNode(ADeviceRecord:PDeviceSnapshot; AParent:TTreeNode; ANodeType:TDeviceNodeType):TTreeNode;
    Function CreateDeviceNodes(ADeviceRecord:PDeviceSnapshot; AParent:TTreeNode):TTreeNode;
    Procedure DisplaySnapshot;
    Procedure DisplayDriverInfo(ADriverRecord:PDriverSnapshot);
    Procedure DisplayDeviceInfo(ADeviceRecord:PDeviceSnapshot);
    Procedure DisplayVPB(AVPB:PVPBSnapshot);
    Procedure DisplayDeviceRelations(ATargetListView:TListView; ARelations:Array Of Pointer);
    Procedure LogSettingsFromGUI;
    Procedure CheckListBoxInvert(AChL:TCheckListBox);
  end;

Var
  Form1: TForm1;

Implementation

{$R *.DFM}

Uses
  Kernel, Utils, Logger, TextLogger;

Procedure TForm1.CheckListBoxInvert(AChL:TCheckListBox);
Var
  I : Integer;
begin
For I := 0 To AChL.Count - 1 Do
  AChL.Checked[I] := Not AChL.Checked[I];

LogDriverSettingsChLClickCheck(AChL);
end;

Procedure TForm1.Button1Click(Sender: TObject);
begin
If Sender = Button1 Then
  LogIncludeDriversChL.CheckAll(cbChecked)
Else If Sender = Button2 Then
  LogIncludeDriversChL.CheckAll(cbUnchecked)
Else If Sender = Button3 Then
  CheckListBoxInvert(LogIncludeDriversChL)
Else If Sender = Button4 Then
  LogDriverSettingsChL.CheckAll(cbChecked)
Else If Sender = Button5 Then
  LogDriverSettingsChL.CheckAll(cbUnchecked)
Else If Sender = Button6 Then
  CheckListBoxInvert(LogDriverSettingsChL)
Else If Sender = Button7 Then
  LogDeviceSettingsChL.CheckAll(cbChecked)
Else If Sender = Button8 Then
  LogDeviceSettingsChL.CheckAll(cbUnchecked)
Else If Sender = Button9 Then
  CheckListBoxInvert(LogDeviceSettingsChL);
end;

Procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
DestroySnapshot;
FLogSettings.Free;
FDriverNames.Free;
FDriverSizes.Free;
FDriverAddresses.Free;
end;

Procedure TForm1.FormCreate(Sender: TObject);
Var
  I : Integer;
begin
For I := 0 To IRP_MJ_MAXIMUM_FUNCTION Do
  begin
  With MajorFunctionListView.Items.Add Do
    begin
    Caption := IrpMajorToStr(I);
    SubItems.Add('');
    SubItems.Add('');
    end;
  end;

LogDriverSettingsChL.CheckAll(cbChecked);
LogDeviceSettingsChL.CheckAll(cbChecked);

FDriverAddresses := TList.Create;
FDriverSizes := TList.Create;
FDriverNames := TStringList.Create;
FLogSettings := TLogSettings.Create;

DeviceTabSheet.TabVisible := False;
DriverTabSheet.TabVisible := False;

FDriverDisplaySettings.TreeDevices := True;
FDriverDisplaySettings.Flags := True;
FDriverDisplaySettings.MajorFunction := True;
FDriverDisplaySettings.Devices := True;

FDeviceDisplaySettings.TreeLowerDevices := True;
FDeviceDisplaySettings.TreeUpperDevices := True;
FDeviceDisplaySettings.Flags := True;
FDeviceDisplaySettings.Characteristics := True;
FDeviceDisplaySettings.VPB := True;
FDeviceDisplaySettings.PnP := True;
FDeviceDisplaySettings.HardwareId := True;
FDeviceDisplaySettings.CompatibleId := True;
FDeviceDisplaySettings.Capabilities := True;
FDeviceDisplaySettings.RemovalRelations := True;
FDeviceDisplaySettings.EjectRelations := True;
FDeviceDisplaySettings.Security := True;
end;

Procedure TForm1.DestroySnapshot;
begin
If Assigned(FSnapshot) Then
  FreeAndNil(FSnapshot);
end;

Procedure TForm1.Exit1Click(Sender: TObject);
begin
Close;
end;

Function TForm1.CreateSnapshot:Boolean;
Var
  Snapshot : Pointer;
begin
FDriverAddresses.Clear;
FDriverSizes.Clear;
FDriverNames.Clear;
Result := GetDeviceDriverList(FDriverAddresses, FDriverSizes, FDriverNames);
If Result Then
  begin
  Result := DriverCreateSnapshot(Snapshot);
  If Result Then
    begin
    FSnapshot := TVTreeSnapshot.Create(FDriverAddresses, FDriverSizes, FDriverNames, Snapshot);
    DriverFreeSnapshot(Snapshot);
    end;

  If Not  Result Then
    begin
    FDriverAddresses.Clear;
    FDriverSizes.Clear;
    FDriverNames.Clear;
    end;
  end;
end;

Procedure TForm1.Createsnapshot1Click(Sender: TObject);
Var
  Ret : Boolean;
begin
DriverDeviceTreeView.Items.Clear;
DestroySnapshot;
Ret := CreateSnapshot;
If Ret Then
  DisplaySnapshot
Else ErrorDialog('Unable to create snapshot of the system');
end;

Function TForm1.CreateDeviceNode(ADeviceRecord:PDeviceSnapshot; AParent:TTreeNode; ANodeType:TDeviceNodeType):TTreeNode;
Var
  DeviceName : WideString;
begin
If ADeviceRecord.Name <> '' Then
  DeviceName := Format('%s (0x%p) - %s', [ADeviceRecord.Name, ADeviceRecord.Address, ADeviceRecord.DriverName])
Else DeviceName := Format('<unnamed> (0x%p) - %s', [ADeviceRecord.Address, ADeviceRecord.DriverName]);

Case ANodeType Of
  dntUpper : DeviceName := 'UPP: ' + DeviceName;
  dntLower : DeviceName := 'LOW: ' + DeviceName;
  end;

Result := DriverDeviceTreeView.Items.AddChild(AParent, DeviceName);
Result.Data := ADeviceRecord;
end;

Function TForm1.CreateDeviceNodes(ADeviceRecord:PDeviceSnapshot; AParent:TTreeNode):TTreeNode;
Var
  I : Integer;
  DevNode : PDeviceSnapshot;
begin
Result := Nil;
If FDeviceDisplaySettings.TreeLowerDevices Then
  begin
  For I := ADeviceRecord.NumberOfLowerDevices - 1 DownTo 0 Do
    begin
    DevNode := FSnapshot.GetDeviceByAddress(ADeviceRecord.LowerDevices[I]);
    If Assigned(DevNode) Then
      AParent := CreateDeviceNode(DevNode, AParent, dntLower)
    Else AParent := DriverDeviceTreeView.Items.AddChild(AParent, Format('LOW: <unknown> (0x%p)', [ADeviceRecord.LowerDevices[I]]));
    end;
  end;

If FDriverDisplaySettings.TreeDevices Then
  AParent := CreateDeviceNode(ADeviceRecord, AParent, dntCurrent);

If FDeviceDisplaySettings.TreeUpperDevices Then
  begin
  For I := ADeviceRecord.NumberOfUpperDevices - 1 Downto 0 Do
    begin
    DevNode := FSnapshot.GetDeviceByAddress(ADeviceRecord.UpperDevices[I]);
    If Assigned(DevNode) Then
      AParent := CreateDeviceNode(DevNode, AParent, dntUpper)
    Else AParent := DriverDeviceTreeView.Items.AddChild(AParent, Format('UPP: <unknown> (0x%p)', [ADeviceRecord.UpperDevices[I]]));
    end;
  end;
end;

Function TForm1.CreateDriverNode(ADriverRecord:PDriverSnapshot):TTreeNode;
Var
  I : Integer;
  DevRecord : PDeviceSnapshot;
begin
Result := DriverDeviceTreeView.Items.AddChild(Nil, ADriverRecord.Name);
Result.Data := ADriverRecord;
If FDriverDisplaySettings.TreeDevices Then
  begin
  For I := 0 To ADriverRecord.NumberOfDevices - 1 Do
    begin
    DevRecord := FSnapshot.GetDeviceByAddress(ADriverRecord.Devices[I]);
    If Assigned(DevRecord) Then
      CreateDeviceNodes(DevRecord, Result)
    Else begin
      With DriverDeviceTreeView.Items.AddChild(Result, Format('<unknown> (0x%p)', [ADriverRecord.Devices[I]])) Do
        Data := Nil;
      end;
    end;
  end;
end;

Procedure TForm1.DisplaySnapshot;
Var
  I : Integer;
  DriverRecord : PDriverSnapshot;
begin
DriverDeviceTreeView.SortType := stNone;
For I := 0 To FSnapshot.DriverRecordsCount - 1 Do
  CreateDriverNode(FSnapshot.DriverRecords[I]);

DriverDeviceTreeView.SortType := stText;
LogIncludeDriversChL.Clear;
For I := 0 To FSnapshot.DriverRecordsCount - 1 Do
  begin
  DriverRecord := FSnapshot.DriverRecords[I];
  LogIncludeDriversChL.Items.AddObject(Format('%s (0x%p)', [DriverRecord.Name, DriverRecord.Address]), DriverRecord.Address);
  LogIncludeDriversChL.Checked[I] := True;
  end;
end;


Procedure TForm1.DriverDeviceTreeViewChange(Sender: TObject; Node: TTreeNode);
begin
DriverTabSheet.TabVisible := (Node.Selected) And (Not Assigned(Node.Parent));
DeviceTabSheet.TabVisible := (Node.Selected) And (Assigned(Node.Parent));
If Node.Selected Then
  begin
  If DriverTabSheet.TabVisible Then
    PageControl1.ActivePage := DriverTabSheet
  Else If DeviceTabSheet.TabVisible Then
    PageControl1.ActivePage := DeviceTabSheet;

  If Assigned(Node.Parent) Then
    begin
    If Assigned(Node.Data) Then
      DisplayDeviceInfo(Node.Data);
    end
  Else If Assigned(Node.Data) Then
         DisplayDriverInfo(Node.Data);
  end;
end;

Procedure TForm1.est1Click(Sender: TObject);
Var
  tmp : PDeviceSnapshot;
  DR : PDriverSnapshot;
  I, J : Integer;
  Log : TStringList;
  Logger : TSnapshotLogger;
begin
If SaveDialog1.Execute Then
  begin
  LogSettingsFromGUI;
  Logger := Nil;
  If Sender = est1 Then
    Logger := TSnapshotTextLogger.Create(FSnapshot, FLogSettings);

  If Assigned(Logger) Then
    begin
    Log := TStringList.Create;
    If Logger.Generate(Log) Then
      Log.SaveToFile(SaveDialog1.FileName);

    Logger.Free;
    Log.Free;
    end;
  end;
end;

Procedure TForm1.DisplayDriverInfo(ADriverRecord:PDriverSnapshot);
Var
  p : NativeUInt;
  I, J : Integer;
  DevNode : PDeviceSnapshot;
  DeviceName : WideString;
begin
DriverMajorFunctionGroupBox.Visible := FDriverDisplaySettings.MajorFunction;
If DriverMajorFunctionGroupBox.Visible Then
  begin
  For I := 0 To IRP_MJ_MAXIMUM_FUNCTION Do
    begin
    P := NativeUInt(ADriverRecord.MajorFunction[I]);
    For J := 0 To FDriverAddresses.Count - 1 Do
      begin
      If (p >= NativeUInt(FDriverAddresses[J])) And
         (p < NativeUInt(FDriverAddresses[J]) + NativeUInt(FDriverSizes[J])) Then
        MajorFunctionListview.Items[I].SubItems[0] := Format('%s', [FDriverNames[J]]);
      end;

    MajorFunctionListview.Items[I].SubItems[1] := Format('0x%p', [Pointer(p)]);
    end;
  end;

DriverDevicesListView.Items.BeginUpdate;
DriverDevicesListView.Clear;
DriverDevicesGroupBox.Visible := FDriverDisplaySettings.Devices;
If DriverDevicesGroupBox.Visible Then
  begin
  For I := 0 To ADriverRecord.NumberOfDevices - 1 Do
    begin
    DevNode := FSnapshot.GetDeviceByAddress(ADriverRecord.Devices[I]);
    If Assigned(DevNode) Then
      DeviceName := DevNode.Name
    Else DeviceName := '<unknown>';

    With DriverDevicesListView.Items.Add Do
      begin
      Caption := DeviceName;
      SubItems.Add(Format('0x%p', [ADriverRecord.Devices[I]]));
      Data := DevNode;
      end;
    end;
  end;

DriverDevicesListView.Items.EndUpdate;

DriverAddressLEdit.Text := Format('0x%p', [ADriverRecord.Address]);
DriverNameLEdit.Text := ADriverRecord.Name;
LabeledEdit1.Text := Format('0x%p', [ADriverRecord.ImageBase]);
LabeledEdit2.Text := Format('%d', [ADriverRecord.ImageSize]);
LabeledEdit3.Text := Format('0x%p', [ADriverRecord.DriverEntry]);
LabeledEdit4.Text := Format('0x%p', [ADriverRecord.DriverUnload]);
LabeledEdit5.Text := ADriverRecord.ImagePath;
LabeledEdit6.Text := Format('0x%p', [ADriverRecord.StartIo]);
LabeledEdit7.Text := Format('0x%x', [ADriverRecord.Flags]);

DriverFlagsGroupBox.Visible := FDriverDisplaySettings.Flags;
If DriverFlagsGroupBox.Visible Then
  begin
  CheckBox35.Checked := (ADriverRecord.Flags And DRVO_UNLOAD_INVOKED) > 0;
  CheckBox36.Checked := (ADriverRecord.Flags And DRVO_LEGACY_DRIVER) > 0;
  CheckBox37.Checked := (ADriverRecord.Flags And DRVO_BUILTIN_DRIVER) > 0;
  CheckBox38.Checked := (ADriverRecord.Flags And DRVO_REINIT_REGISTERED) > 0;
  CheckBox39.Checked := (ADriverRecord.Flags And DRVO_INITIALIZED) > 0;
  CheckBox40.Checked := (ADriverRecord.Flags And DRVO_BOOTREINIT_REGISTERED) > 0;
  CheckBox41.Checked := (ADriverRecord.Flags And DRVO_LEGACY_RESOURCES) > 0;
  CheckBox42.Checked := (ADriverRecord.Flags And DRVO_BASE_FILESYSTEM_DRIVER) > 0;
  end;
end;

Procedure TForm1.DisplayMenuItemClick(Sender: TObject);
Var
  M : TMenuItem;
begin
M := Sender As TMenuItem;
M.Checked := Not M.Checked;
If M.Parent = DriverDisplayMenuItem Then
  begin
  Case M.MenuIndex Of
    0 : FDriverDisplaySettings.TreeDevices := M.Checked;
    2 : FDriverDisplaySettings.Flags := M.Checked;
    3 : FDriverDisplaySettings.Devices := M.Checked;
    4 : FDriverDisplaySettings.MajorFunction := M.Checked;
    end;
  end
Else If M.Parent = DeviceDisplayMenuItem Then
  begin
  Case M.MenuIndex Of
    0 : FDeviceDisplaySettings.TreeLowerDevices := M.Checked;
    1 : FDeviceDisplaySettings.TreeUpperDevices := M.Checked;
    3 : FDeviceDisplaySettings.Flags := M.Checked;
    4 : FDeviceDisplaySettings.Characteristics := M.Checked;
    5 : FDeviceDisplaySettings.VPB := M.Checked;
    6 : FDeviceDisplaySettings.PnP := M.Checked;
    7 : FDeviceDisplaySettings.HardwareId := M.Checked;
    8 : FDeviceDisplaySettings.CompatibleId := M.Checked;
    9 : FDeviceDisplaySettings.Capabilities := M.Checked;
    10 : FDeviceDisplaySettings.RemovalRelations := M.Checked;
    11 : FDeviceDisplaySettings.EjectRelations := M.Checked;
    12 : FDeviceDisplaySettings.Security := M.Checked;
    end;
  end;

If Assigned(FSnapshot) Then
  begin
  DriverDeviceTreeView.Items.Clear;
  DisplaySnapshot;
  end;
end;

Procedure TForm1.DisplayDeviceInfo(ADeviceRecord:PDeviceSnapshot);
Var
  I : Integer;
  DiskDevNode : PDeviceSnapshot;
  DiskDevName : WideString;
begin
Edit1.Text := Format('0x%p', [ADeviceRecord.Address]);
Edit2.Text := ADeviceRecord.Name;
Edit3.Text := Format('0x%p', [ADeviceRecord.DriverAddress]);
Edit4.Text := ADeviceRecord.DriverName;
Edit5.Text := Format('%d (%s)', [ADeviceRecord.DeviceType, DeviceTypeToStr(ADeviceRecord.DeviceType)]);
Edit6.Text := Format('0x%x', [ADeviceRecord.Flags]);
Edit7.Text := Format('0x%x', [ADeviceRecord.Characteristics]);
If Assigned(ADeviceRecord.DiskDeviceAddress) Then
  begin
  DiskDevNode := FSnapshot.GetDeviceByAddress(ADeviceRecord.DiskDeviceAddress);
  If Assigned(DiskDevNode) Then
    DiskDevName := Format('%S (0x%p)', [DiskDevNode.Name, ADeviceRecord.DiskDeviceAddress])
  Else DiskDevName := Format('<unknown> (0x%p)', [ADeviceRecord.DiskDeviceAddress]);
  end
Else DiskDevName:= Format('<none> (0x%p)', [Nil]);

Edit8.Text := DiskDevName;

DeviceFlagsGroupBox.Visible := FDeviceDisplaySettings.Flags;
If DeviceFlagsGroupBox.Visible Then
  begin
  CheckBox1.Checked := (ADeviceRecord.Flags And DO_BUFFERED_IO) <> 0;
  CheckBox2.Checked := (ADeviceRecord.Flags And DO_DIRECT_IO) <> 0;
  CheckBox3.Checked := (ADeviceRecord.Flags And DO_BUS_ENUMERATED_DEVICE) <> 0;
  CheckBox4.Checked := (ADeviceRecord.Flags And DO_DEVICE_INITIALIZING) <> 0;
  CheckBox5.Checked := (ADeviceRecord.Flags And DO_EXCLUSIVE) <> 0;
  CheckBox6.Checked := (ADeviceRecord.Flags And DO_MAP_IO_BUFFER) <> 0;
  CheckBox7.Checked := (ADeviceRecord.Flags And DO_POWER_INRUSH) <> 0;
  CheckBox8.Checked := (ADeviceRecord.Flags And DO_POWER_PAGABLE) <> 0;
  CheckBox9.Checked := (ADeviceRecord.Flags And DO_SHUTDOWN_REGISTERED) <> 0;
  CheckBox10.Checked := (ADeviceRecord.Flags And DO_VERIFY_VOLUME) <> 0;
  CheckBox23.Checked := (ADeviceRecord.Flags And DO_DEVICE_HAS_NAME) <> 0;
  CheckBox24.Checked := (ADeviceRecord.Flags And DO_SYSTEM_BOOT_PARTITION) <> 0;
  CheckBox25.Checked := (ADeviceRecord.Flags And DO_LONG_TERM_REQUESTS) <> 0;
  CheckBox26.Checked := (ADeviceRecord.Flags And DO_NEVER_LAST_DEVICE) <> 0;
  CheckBox27.Checked := (ADeviceRecord.Flags And DO_LOW_PRIORITY_FILESYSTEM) <> 0;
  CheckBox28.Checked := (ADeviceRecord.Flags And DO_SUPPORTS_TRANSACTIONS) <> 0;
  CheckBox29.Checked := (ADeviceRecord.Flags And DO_FORCE_NEITHER_IO) <> 0;
  CheckBox30.Checked := (ADeviceRecord.Flags And DO_VOLUME_DEVICE_OBJECT) <> 0;
  CheckBox31.Checked := (ADeviceRecord.Flags And DO_SYSTEM_SYSTEM_PARTITION) <> 0;
  CheckBox32.Checked := (ADeviceRecord.Flags And DO_SYSTEM_CRITICAL_PARTITION) <> 0;
  end;

DeviceCharacteristicsGroupBox.Visible := FDeviceDisplaySettings.Characteristics;
If DeviceCharacteristicsGroupBox.Visible Then
  begin
  CheckBox11.Checked := (ADeviceRecord.Characteristics And FILE_AUTOGENERATED_DEVICE_NAME) <> 0;
  CheckBox12.Checked := (ADeviceRecord.Characteristics And FILE_CHARACTERISTIC_PNP_DEVICE) <> 0;
  CheckBox13.Checked := (ADeviceRecord.Characteristics And FILE_CHARACTERISTIC_TS_DEVICE) <> 0;
  CheckBox14.Checked := (ADeviceRecord.Characteristics And FILE_CHARACTERISTIC_WEBDAV_DEVICE) <> 0;
  CheckBox15.Checked := (ADeviceRecord.Characteristics And FILE_DEVICE_IS_MOUNTED) <> 0;
  CheckBox16.Checked := (ADeviceRecord.Characteristics And FILE_DEVICE_SECURE_OPEN) <> 0;
  CheckBox17.Checked := (ADeviceRecord.Characteristics And FILE_FLOPPY_DISKETTE) <> 0;
  CheckBox18.Checked := (ADeviceRecord.Characteristics And FILE_READ_ONLY_DEVICE) <> 0;
  CheckBox19.Checked := (ADeviceRecord.Characteristics And FILE_REMOTE_DEVICE) <> 0;
  CheckBox20.Checked := (ADeviceRecord.Characteristics And FILE_REMOVABLE_MEDIA) <> 0;
  CheckBox21.Checked := (ADeviceRecord.Characteristics And FILE_VIRTUAL_VOLUME) <> 0;
  CheckBox22.Checked := (ADeviceRecord.Characteristics And FILE_WRITE_ONCE_MEDIA) <> 0;
  end;

If ((ADeviceRecord.Flags And DO_BUS_ENUMERATED_DEVICE) <> 0) Then
  begin
  DevicePnPGroupBox.Visible := FDeviceDisplaySettings.PnP;
  If DevicePnPGroupBox.Visible Then
    begin
    With DevicePnpListView Do
      begin
      Items[0].SubItems[0] := ADeviceRecord.DisplayName;
      Items[1].SubItems[0] := ADeviceRecord.Description;
      Items[2].SubItems[0] := ADeviceRecord.Vendor;
      Items[3].SubItems[0] := ADeviceRecord.ClassName;
      Items[4].SubItems[0] := ADeviceRecord.ClassGuid;
      Items[5].SubItems[0] := ADeviceRecord.Location;
      Items[6].SubItems[0] := ADeviceRecord.Enumerator;
      Items[7].SubItems[0] := ADeviceRecord.DeviceId;
      Items[8].SubItems[0] := ADeviceRecord.InstanceId;
      end;
    end;

  HardwareIDsGroupBox.Visible := (FDeviceDisplaySettings.HardwareId) And (Length(ADeviceRecord.HardwareIds) > 0);
  If HardwareIDsGroupBox.Visible Then
    begin
    HardwareIDsListView.Items.BeginUpdate;
    HardwareIDsListView.Clear;
    For I := 0 To High(ADeviceRecord.HardwareIds) Do
      begin
      With HardwareIDsListView.Items.Add Do
        Caption := ADeviceRecord.HardwareIds[I];
      end;

    HardwareIDsListView.Items.EndUpdate;
    end;

  CompatibleIDsGroupBox.Visible := (FDeviceDisplaySettings.CompatibleId) And (Length(ADeviceRecord.CompatibleIds) > 0);
  If CompatibleIDsGroupBox.Visible Then
    begin
    CompatibleIDsListView.Items.BeginUpdate;
    CompatibleIDsListView.Clear;
    For I := 0 To High(ADeviceRecord.CompatibleIds) Do
      begin
      With CompatibleIDsListView.Items.Add Do
        Caption := ADeviceRecord.CompatibleIds[I];
      end;

    CompatibleIDsListView.Items.EndUpdate;
    end;

  RemovalRelationsGroupBox.Visible := (FDeviceDisplaySettings.RemovalRelations) And (Length(ADeviceRecord.RemovalRelations) > 0);
  If RemovalRelationsGroupBox.Visible Then
    DisplayDeviceRelations(RemovalRelationsListView, ADeviceRecord.RemovalRelations);

  EjectRelationsGroupBox.Visible := (FDeviceDisplaySettings.EjectRelations) And (Length(ADeviceRecord.EjectRelations) > 0);
  If EjectRelationsGroupBox.Visible Then
    DisplayDeviceRelations(EjectRelationsListView, ADeviceRecord.EjectRelations);

  CapabilitiesGroupBox.Visible := (FDeviceDisplaySettings.Capabilities);
  end
Else begin
  DevicePnPGroupBox.Visible := False;
  HardwareIDsGroupBox.Visible := False;
  CompatibleIDsGroupBox.Visible := False;
  EjectRelationsGroupBox.Visible := False;
  RemovalRelationsGroupBox.Visible := False;
  end;

DisplayVPB(ADeviceRecord.Vpb);
end;

Procedure TForm1.LogDriverSettingsChLClickCheck(Sender: TObject);
Var
  I : Integer;
begin
If Sender = LogDriverSettingsChL Then
  begin
  If Not LogDriverSettingsChL.Checked[6] Then
    LogDriverSettingsChL.Checked[7] := False;
  end
Else If Sender = LogDeviceSettingsChL Then
  begin
  If Not LogDeviceSettingsChL.Checked[6] Then
    LogDeviceSettingsChL.Checked[7] := False;

  If Not LogDeviceSettingsChL.Checked[8] Then
    LogDeviceSettingsChL.Checked[9] := False;

  If Not LogDeviceSettingsChL.Checked[10] Then
    begin
    For I := 11 To 17 Do
      LogDeviceSettingsChL.Checked[I] := False;
    end;
  end;
end;

Procedure TForm1.LogSettingsFromGUI;
Var
  I : Integer;
begin
FLogSettings.General.IncludeVTHeader := CheckBox33.Checked;
FLogSettings.General.IncludeOSVersion := CheckBox34.Checked;

FLogSettings.Clear;
For I := 0 To LogIncludeDriversChL.Count - 1 Do
  begin
  If LogIncludeDriversChL.Checked[I] Then
    FLogSettings.IncludeDriver(LogIncludeDriversChL.Items.Objects[I]);
  end;

FLogSettings.DriverSettings.IncludeFileName := LogDriverSettingsChl.Checked[0];
FLogSettings.DriverSettings.IncludeImageBase := LogDriverSettingsChl.Checked[1];
FLogSettings.DriverSettings.IncludeImageSize := LogDriverSettingsChl.Checked[2];
FLogSettings.DriverSettings.IncludeDriverEntry := LogDriverSettingsChl.Checked[3];
FLogSettings.DriverSettings.IncludeDriverUnload := LogDriverSettingsChl.Checked[4];
FLogSettings.DriverSettings.IncludeStartIo := LogDriverSettingsChl.Checked[5];
FLogSettings.DriverSettings.IncludeFlags := LogDriverSettingsChl.Checked[6];
FLogSettings.DriverSettings.IncludeFlagsStr := LogDriverSettingsChl.Checked[7];
FLogSettings.DriverSettings.IncludeMajorFunctions := LogDriverSettingsChl.Checked[8];
FLogSettings.DriverSettings.IncludeNumberOfDevices := LogDriverSettingsChl.Checked[9];
FLogSettings.DriverSettings.IncludeDevices := LogDriverSettingsChl.Checked[10];

FLogSettings.DeviceSettings.IncludeType := LogDeviceSettingsChL.Checked[0];
FLogSettings.DeviceSettings.IncludeDiskDevice := LogDeviceSettingsChL.Checked[1];
FLogSettings.DeviceSettings.IncludeUpperDevicesCount := LogDeviceSettingsChL.Checked[2];
FLogSettings.DeviceSettings.IncludeUpperDevices := LogDeviceSettingsChL.Checked[3];
FLogSettings.DeviceSettings.IncludeLowerDevicesCount := LogDeviceSettingsChL.Checked[4];
FLogSettings.DeviceSettings.IncludeLowerDevices := LogDeviceSettingsChL.Checked[5];
FLogSettings.DeviceSettings.IncludeFlags := LogDeviceSettingsChL.Checked[6];
FLogSettings.DeviceSettings.IncludeFlagsStr := LogDeviceSettingsChL.Checked[7];
FLogSettings.DeviceSettings.IncludeCharacteristics := LogDeviceSettingsChL.Checked[8];
FLogSettings.DeviceSettings.IncludeCharacteristicsStr := LogDeviceSettingsChL.Checked[9];
FLogSettings.DeviceSettings.IncludePnPInformation := LogDeviceSettingsChL.Checked[10];
FLogSettings.DeviceSettings.IncludeFriendlyName := LogDeviceSettingsChL.Checked[11];
FLogSettings.DeviceSettings.IncludeDescription := LogDeviceSettingsChL.Checked[12];
FLogSettings.DeviceSettings.IncludeVendor := LogDeviceSettingsChL.Checked[13];
FLogSettings.DeviceSettings.IncludeEnumerator := LogDeviceSettingsChL.Checked[14];
FLogSettings.DeviceSettings.IncludeLocation := LogDeviceSettingsChL.Checked[15];
FLogSettings.DeviceSettings.IncludeClass := LogDeviceSettingsChL.Checked[16];
FLogSettings.DeviceSettings.IncludeClassGuid := LogDeviceSettingsChL.Checked[17];
end;

Procedure TForm1.DisplayVPB(AVPB:PVPBSnapshot);
Var
  FSDevice : PDeviceSnapshot;
  FSDeviceName : WideString;
  VolDevice : PDeviceSnapshot;
  VolDeviceName : WideString;
begin
DeviceVPBGroupBox.Visible := (FDeviceDisplaySettings.VPB) And (Assigned(AVPB));
If DeviceVPBGroupBox.Visible Then
  begin
  Edit9.Text := Format('0x%p', [AVPB.VpbAddress]);
  Edit10.Text := Format('0x%x', [AVPB.Flags]);
  LabeledEdit11.Text := Format('%d', [AVPB.ReferenceCount]);
  FSDeviceName := '<unknown>';
  FSDevice := FSnapshot.GetDeviceByAddress(AVPB.FileSystemDevice);
  If Assigned(FSDevice) Then
    LabeledEdit8.Text := Format('%s (0x%p)', [FSDevice.Name, FSDevice.Address]);

  VolDeviceName := '<unknown>';
  VolDevice := FSnapshot.GetDeviceByAddress(AVPB.VolumeDevice);
  If Assigned(VolDevice) Then
    LabeledEdit9.Text := Format('%s (0x%p)', [VolDevice.Name, VolDevice.Address]);

  LabeledEdit10.Text := AVPB.Name;
  CheckBox43.Checked := (AVPB.Flags And VPB_MOUNTED) > 0;
  CheckBox44.Checked := (AVPB.Flags And VPB_LOCKED) > 0;
  CheckBox45.Checked := (AVPB.Flags And VPB_PERSISTENT) > 0;
  CheckBox48.Checked := (AVPB.Flags And VPB_REMOVE_PENDING) > 0;
  CheckBox46.Checked := (AVPB.Flags And VPB_RAW_MOUNT) > 0;
  CheckBox47.Checked := (AVPB.Flags And VPB_DIRECT_WRITES_ALLOWED) > 0;
  end;
end;

Procedure TForm1.DisplayDeviceRelations(ATargetListView:TListView; ARelations:Array Of Pointer);
Var
  I : Integer;
  ds : PDeviceSnapshot;
  deviceName : WideString;
  drivername : WideString;
begin
ATargetListView.Clear;
For I := Low(ARelations) To High(ARelations) Do
  begin
  ds := FSnapshot.GetDeviceByAddress(ARelations[I]);
  If Assigned(ds) Then
    begin
    If ds.Name <> '' Then
      deviceName := Format('%s (0x%p)', [ds.Name, ARelations[I]])
    Else deviceName := Format('<unnamed> (0x%p)', [ARelations[I]]);

    driverName := ds.DriverName;
    end
  Else begin
    deviceName := Format('<unknown> (0x%p)', [ARelations[I]]);
    driverName := '<unknown>';
    end;

  With ATargetListView.Items.Add Do
    begin
    Caption := deviceName;
    SubItems.Add(driverName);
    SubItems.Add(Format('0x%p', [ARelations[I]]));
    end;
  end;
end;

End.

