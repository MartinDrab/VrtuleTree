Unit MainForm;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.Menus, VTreeDriver, Vcl.StdCtrls, Generics.Collections,
  Vcl.ExtCtrls, Vcl.CheckLst, LogSettings,
  Snapshot, DeviceDrivers,
  AbstractSnapshotRecord, DriverSnapshot, DeviceSnapshot;

Type
  TDeviceNodeType = (dntLower, dntCurrent, dntUpper, dntPnP);
  TDeviceTreeType = (dttDeviceTree, dttPnPTree);

  TDriverDisplaySettings = Record
    TreeDevices : Boolean;
    Flags : Boolean;
    MajorFunction : Boolean;
    Devices : Boolean;
    FastIo : Boolean;
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
    DeviceNode : Boolean;
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
    CapabilitiesGroupBox: TGroupBox;
    CapabilitiesListView: TListView;
    Capabilities1: TMenuItem;
    CheckBox49: TCheckBox;
    CheckBox50: TCheckBox;
    CheckBox51: TCheckBox;
    CheckBox52: TCheckBox;
    CheckBox53: TCheckBox;
    CheckBox54: TCheckBox;
    CheckBox55: TCheckBox;
    CheckBox56: TCheckBox;
    CheckBox57: TCheckBox;
    CheckBox58: TCheckBox;
    DriverDeviceTreePopupMenu: TPopupMenu;
    Gotodriver1: TMenuItem;
    Expandall1: TMenuItem;
    Collapse1: TMenuItem;
    OtherSettingsTabSheet: TTabSheet;
    OtherSettingsCaptureGroupBox: TGroupBox;
    CaptureDeviceIdCheckBox: TCheckBox;
    CaptureFastIoDispatchCheckBox: TCheckBox;
    CaptureDevnodeTreeCheckBox: TCheckBox;
    FastIODispatch1: TMenuItem;
    DeviceNode1: TMenuItem;
    TreeTypeMenuItem: TMenuItem;
    DeviceTreeMenuItem: TMenuItem;
    PnPTreeMenuItem: TMenuItem;
    LoadedDriversTabSheet: TTabSheet;
    LoadedDriversListView: TListView;
    LoadedDriversSettingsGroupBox: TGroupBox;
    LDVerifySignaturesCheckBox: TCheckBox;
    LDNoLifeTimeCheckBox: TCheckBox;
    LDCheckCRLsCheckBox: TCheckBox;
    LDCertNamesCheckBox: TCheckBox;
    DriverScrollBox: TScrollBox;
    FastIoDispatchGroupBox: TGroupBox;
    FastIoDispatchPanel: TPanel;
    FastIoDispatchListView: TListView;
    Label11: TLabel;
    Label12: TLabel;
    FastIoDispatchAddressEdit: TEdit;
    FastIoDispatchSizeEdit: TEdit;
    CheckBox59: TCheckBox;
    CheckBox60: TCheckBox;
    Procedure FormCreate(Sender: TObject);
    Procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Procedure Exit1Click(Sender: TObject);
    Procedure Createsnapshot1Click(Sender: TObject);
    Procedure DriverDeviceTreeViewChange(Sender: TObject; Node: TTreeNode);
    Procedure est1Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure LogDriverSettingsChLClickCheck(Sender: TObject);
    procedure DisplayMenuItemClick(Sender: TObject);
    procedure AboutVrtuleTree1Click(Sender: TObject);
    procedure DeviceJumpOnEvent(Sender: TObject);
    procedure DriverJumpOnEvent(Sender: TObject);
    procedure Gotodriver1Click(Sender: TObject);
    procedure Expandall1Click(Sender: TObject);
    procedure DriverDeviceTreePopupMenuPopup(Sender: TObject);
    procedure DriverDevicesJumpOnEvent(Sender: TObject);
    procedure DriverMajorFunctionJumpOnEvent(Sender: TObject);
    procedure Collapse1Click(Sender: TObject);
    procedure TreeTypeSubItemOnClick(Sender: TObject);
    procedure LoadedDriversTabSheetShow(Sender: TObject);
    procedure LoadedDriversListViewData(Sender: TObject; Item: TListItem);
    procedure DriverScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  Private
    FSpecialValues : SPECIAL_VALUES;
    FDriverList : TDeviceDriverList;
    FLogSettings : TLogSettings;
    FSnapshot : TVTreeSnapshot;
    FDriverDisplaySettings : TDriverDisplaySettings;
    FDeviceDisplaySettings : TDeviceDisplaySettings;
    FDeviceAddressToTreeNode : TDictionary<Pointer, TTreeNode>;
    FDriverAddressToTreeNode : TDictionary<Pointer, TTreeNode>;
    FImageBaseToDriverAddress : TDictionary<Pointer, Pointer>;
    FSnapshotFlags : Cardinal;
    FSnapshotType : TDeviceTreeType;
    FDriverListOptions : TDriverListOptions;
    Function CreateSnapshot:Boolean;
    Procedure DestroySnapshot;
    Function CreateDriverNode(ADriverRecord:TDriverSnapshot):TTreeNode;
    Function CreateDeviceNode(ADeviceRecord:TDeviceSnapshot; AParent:TTreeNode; ANodeType:TDeviceNodeType):TTreeNode;
    Function CreateDeviceNodes(ADeviceRecord:TDeviceSnapshot; AParent:TTreeNode):TTreeNode;
    Procedure DisplaySnapshot;
    Procedure DisplayDriverInfo(ADriverRecord:TDriverSnapshot);
    Procedure DisplayDeviceInfo(ADeviceRecord:TDeviceSnapshot);
    Procedure DisplayVPB(Const AVPB:TVPBSnapshot);
    Procedure DisplayDeviceRelations(ARelations:Array Of Pointer; ARelationName:WideString);
    Procedure LogSettingsFromGUI;
    Procedure CheckListBoxInvert(AChL:TCheckListBox);
    Procedure ListViewAddNameValue(AListView:TListView; AName:WideString; AValue:WideString; AData:Pointer = Nil);
    Procedure GoToDriver(AAddress:Pointer; AIgnoreIfNonexistent:Boolean = False);
    Procedure GoToDevice(AAddress:Pointer; AIgnoreIfNonexistent:Boolean = False);

    Function CreateNode(AParent:TTreeNode; ACaption:WideString; AData:TAbstractSnapshotRecord):TTreeNode;
    FUnction IsDriverNode(ANode:TTreeNode):Boolean;
    Function IsDeviceNode(ANode:TTreeNode):Boolean;

    Function DeviceTextFromAddress(ADeviceAddress:Pointer):WideString;
    Function DeviceTextFromNode(ADeviceNode:Pointer; ADeviceAddress:Pointer):WideString;

    Procedure DriverListOptionsFromGUI;
  end;

Var
  Form1: TForm1;

Implementation

{$R *.DFM}

Uses
  Kernel, Utils, Logger, TextLogger,
  AboutForm;


Function TForm1.CreateNode(AParent:TTreeNode; ACaption:WideString; AData:TAbstractSnapshotRecord):TTreeNode;
begin
Result := DriverDeviceTreeView.Items.AddChild(AParent, ACaption);
Result.Data := AData;
end;

FUnction TForm1.IsDriverNode(ANode:TTreeNode):Boolean;
Var
  r : TAbstractSnapshotRecord;
begin
r := ANode.Data;
Result := r.RecordType = srtDriver;
end;

Function TForm1.IsDeviceNode(ANode:TTreeNode):Boolean;
Var
  r : TAbstractSnapshotRecord;
begin
r := ANode.Data;
Result := r.RecordType = srtDevice;
end;

Procedure TForm1.ListViewAddNameValue(AListView:TListView; AName:WideString; AValue:WideString; AData:Pointer = Nil);
begin
With AListView.Items.Add Do
  begin
  Caption := AName;
  SubItems.Add(AValue);
  Data := AData;
  end;
end;

Procedure TForm1.CheckListBoxInvert(AChL:TCheckListBox);
Var
  I : Integer;
begin
For I := 0 To AChL.Count - 1 Do
  AChL.Checked[I] := Not AChL.Checked[I];

LogDriverSettingsChLClickCheck(AChL);
end;

Procedure TForm1.Collapse1Click(Sender: TObject);
Var
  tn : TTreeNode;
begin
tn := DriverDeviceTreeView.Selected;
If Assigned(tn) Then
  tn.Collapse(True)
Else WarningDialog('No item selected');
end;

Procedure TForm1.AboutVrtuleTree1Click(Sender: TObject);
begin
WIth TABoutBox.Create(Application) Do
  begin
  ShowModal;
  Free;
  end;
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
FImageBaseToDriverAddress.Free;
FDeviceAddressToTreeNode.Free;
FDriverAddressToTreeNode.Free;
FLogSettings.Free;
FDriverList.Free;
end;

Procedure TForm1.FormCreate(Sender: TObject);
Var
  I : Integer;
begin
DriverListOptionsFromGUI;
FSnapshotType := dttDeviceTree;
FImageBaseToDriverAddress := TDictionary<Pointer, Pointer>.Create;
FDeviceAddressToTreeNode := TDictionary<Pointer, TTreeNode>.Create;
FDriverAddressToTreeNode := TDictionary<Pointer, TTreeNode>.Create;
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
FDriverList := TDeviceDriverList.Create;
FLogSettings := TLogSettings.Create;

DeviceTabSheet.TabVisible := False;
DriverTabSheet.TabVisible := False;

FDriverDisplaySettings.TreeDevices := True;
FDriverDisplaySettings.Flags := True;
FDriverDisplaySettings.MajorFunction := True;
FDriverDisplaySettings.Devices := True;
FDriverDisplaySettings.FastIo := True;

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
FDeviceDisplaySettings.DeviceNode := True;
DriverGetSpecialValues(@FSpecialValues);
end;

Procedure TForm1.DestroySnapshot;
begin
If Assigned(FSnapshot) Then
  FreeAndNil(FSnapshot);
end;

Procedure TForm1.DeviceJumpOnEvent(Sender: TObject);
Var
  deviceAddress : Pointer;
begin
deviceAddress := Pointer((Sender As TComponent).Tag);
If Assigned(deviceAddress) Then
  GotoDevice(deviceAddress);
end;

Procedure TForm1.Exit1Click(Sender: TObject);
begin
Close;
end;

Procedure TForm1.Expandall1Click(Sender: TObject);
Var
  tn : TTreeNode;
begin
tn := DriverDeviceTreeView.Selected;
If Assigned(tn) Then
  tn.Expand(True);
end;

Function TForm1.CreateSnapshot:Boolean;
Var
  Snapshot : Pointer;
begin
FDriverList.Clear;
FImageBaseToDriverAddress.Clear;
DriverListOptionsFromGUI;
FDriverList.Options := FDriverListOptions;
Result := FDriverList.Enumerate;
If Result Then
  begin
  FSnapshotFlags := 0;
  If CaptureDeviceIdCheckBox.Checked Then
    FSnapshotFlags := (FSnapshotFlags Or VTREE_SNAPSHOT_DEVICE_ID);

  If CaptureFastIoDispatchCheckBox.Checked Then
    FSnapshotFlags := (FSnapshotFlags Or VTREE_SNAPSHOT_FAST_IO_DISPATCH);

  If CaptureDevnodeTreeCheckBox.Checked Then
    FSnapshotFlags := (FSnapshotFlags Or VTREE_SNAPSHOT_DEVNODE_TREE);

  Result := DriverCreateSnapshot(FSnapshotFlags, Snapshot);
  If Result Then
    begin
    FSnapshot := TVTreeSnapshot.Create(FDriverList, Snapshot);
    DriverFreeSnapshot(Snapshot);
    end;

  If Not  Result Then
    FDriverList.Clear;
  end;
end;

Procedure TForm1.Createsnapshot1Click(Sender: TObject);
Var
  Ret : Boolean;
begin
FDriverAddressToTreeNode.Clear;
FDeviceAddressToTreeNode.Clear;
DriverDeviceTreeView.Items.Clear;
DestroySnapshot;
Ret := CreateSnapshot;
If Ret Then
  DisplaySnapshot
Else ErrorDialog('Unable to create snapshot of the system');
end;

Function TForm1.CreateDeviceNode(ADeviceRecord:TDeviceSnapshot; AParent:TTreeNode; ANodeType:TDeviceNodeType):TTreeNode;
Var
  tmp : WideString;
  DeviceName : WideString;
begin
If ANodeType <> dntPnP Then
  begin
  If ADeviceRecord.Name <> '' Then
    DeviceName := Format('%s (0x%p) - %s', [ADeviceRecord.Name, ADeviceRecord.Address, ADeviceRecord.DriverName])
  Else DeviceName := Format('<unnamed> (0x%p) - %s', [ADeviceRecord.Address, ADeviceRecord.DriverName]);

  Case ANodeType Of
    dntUpper : DeviceName := 'UPP: ' + DeviceName;
    dntLower : DeviceName := 'LOW: ' + DeviceName;
    end;

  Result := CreateNode(AParent, deviceName, ADeviceRecord);
  If ANodeType = dntCurrent Then
    FDeviceAddressToTreeNode.Add(ADeviceRecord.Address, Result);
  end
Else begin
  DeviceName := '';
  If (Length(ADeviceRecord.Description) > 1) And (ADeviceRecord.Description[1] = '@') Then
    begin
    If LoadStringFromPath(ADeviceRecord.Description, DeviceName) Then
      DeviceName := Format('%s (0x%p)', [DeviceName, ADeviceRecord.DeviceNode])
    Else DeviceName := '';
    end;

  If DeviceName = '' Then
    DeviceName := DeviceTextFromNode(ADeviceRecord.DeviceNode, ADeviceRecord.Address);

  Result := CreateNode(AParent, DeviceName, ADeviceRecord);
  FDeviceAddressToTreeNode.Add(ADeviceRecord.Address, Result);
  end;
end;

Function TForm1.CreateDeviceNodes(ADeviceRecord:TDeviceSnapshot; AParent:TTreeNode):TTreeNode;
Var
  I : Integer;
  DevNode : TDeviceSnapshot;
begin
Result := Nil;
If FDeviceDisplaySettings.TreeLowerDevices Then
  begin
  For I := ADeviceRecord.NumberOfLowerDevices - 1 DownTo 0 Do
    begin
    DevNode := FSnapshot.GetDeviceByAddress(ADeviceRecord.LowerDevices[I]);
    If Assigned(DevNode) Then
      AParent := CreateDeviceNode(DevNode, AParent, dntLower)
    Else begin
      AParent := CreateNode(AParent, Format('LOW: <unknown> (0x%p)', [ADeviceRecord.LowerDevices[I]]), Nil);
      FDeviceAddressToTreeNode.Add(ADeviceRecord.LowerDevices[I], AParent);
      end;
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
    Else begin
      AParent := CreateNode(AParent, Format('UPP: <unknown> (0x%p)', [ADeviceRecord.LowerDevices[I]]), Nil);
      FDeviceAddressToTreeNode.Add(ADeviceRecord.UpperDevices[I], AParent);
      end;
    end;
  end;
end;

Function TForm1.CreateDriverNode(ADriverRecord:TDriverSnapshot):TTreeNode;
Var
  I : Integer;
  DevRecord : TDeviceSnapshot;
begin
Result := CreateNode(Nil, ADriverRecord.Name, ADriverRecord);
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

FDriverAddressToTreeNode.Add(ADriverRecord.Address, Result);
If (Not FImageBaseToDriverAddress.ContainsKey(ADriverRecord.ImageBase)) And
   (Assigned(ADriverRecord.ImageBase)) Then
  FImageBaseToDriverAddress.Add(ADriverRecord.ImageBase, ADriverRecord.Address);
end;

Procedure TForm1.DisplaySnapshot;
Var
  I : Integer;
  DriverRecord : TDriverSnapshot;

  deviceRecord : TDeviceSnapshot;
  pnpDevices : TList<TDeviceSnapshot>;
  devnodeToTreeNode : TDictionary<Pointer, TTreeNode>;
  tn : TTreeNode;
  deviceAdded : Boolean;
begin
DriverDeviceTreeView.SortType := stNone;
Case FSnapshotType Of
  dttDeviceTree : begin
    For I := 0 To FSnapshot.DriverRecordsCount - 1 Do
      CreateDriverNode(FSnapshot.DriverRecords[I]);

    LogIncludeDriversChL.Clear;
    For I := 0 To FSnapshot.DriverRecordsCount - 1 Do
      begin
      DriverRecord := FSnapshot.DriverRecords[I];
      LogIncludeDriversChL.Items.AddObject(Format('%s (0x%p)', [DriverRecord.Name, DriverRecord.Address]), DriverRecord.Address);
      LogIncludeDriversChL.Checked[I] := True;
      end;
    end;
  dttPnPTree : begin
    devNodeToTreeNode := TDictionary<Pointer, TTreeNode>.Create;
    pnpDevices := TList<TDeviceSnapshot>.Create;
    For I := 0 To FSnapshot.DeviceRecordsCount - 1 Do
      begin
      deviceRecord := FSnapshot.DeviceRecords[I];
      If (deviceRecord.Flags And DO_BUS_ENUMERATED_DEVICE) <> 0 Then
        begin
        If Not Assigned(deviceRecord.Parent) Then
          begin
          tn := CreateDeviceNode(deviceRecord, Nil, dntPnP);
          devNodeToTreeNode.Add(deviceRecord.DeviceNode, tn);
          end
        Else pnpDevices.Add(deviceRecord);
        end;
      end;

    deviceAdded := False;
    While pnpDevices.Count > 0 Do
      begin
      For I := 0 To pnpDevices.Count - 1 Do
        begin
        deviceRecord := pnpDevices[I];
        deviceAdded := devNodeToTreeNode.TryGetValue(deviceRecord.Parent, tn);
        If deviceAdded Then
          begin
          pnpDevices.Delete(I);
          tn := CreateDeviceNode(deviceRecord, tn, dntPnP);
          devNodeToTreeNode.Add(deviceRecord.DeviceNode, tn);
          Break;
          end;
        end;

        If Not deviceAdded Then
          Break;
      end;

    If pnpDevices.Count > 0 Then
        begin
        For deviceRecord in pnpDevices Do
          CreateDeviceNode(deviceRecord, Nil, dntPnP);
        end;

    pnpDevices.Free;
    devNodeToTreeNode.Free;
    end;
  end;

DriverDeviceTreeView.SortType := stText;
end;


Procedure TForm1.DriverDevicesJumpOnEvent(Sender: TObject);
Var
  L : TListItem;
  deviceAddress : Pointer;
begin
L := (Sender As TListView).Selected;
If Assigned(L) Then
  begin
  deviceAddress := L.Data;
  If Assigned(deviceAddress) Then
    GotoDevice(deviceAddress);
  end
Else WarningDialog('No device selected');
end;

Procedure TForm1.DriverDeviceTreePopupMenuPopup(Sender: TObject);
Var
  tn : TTreeNode;
begin
tn := DriverDeviceTreeView.Selected;
Gotodriver1.Enabled := Assigned(tn);
Expandall1.Enabled := Assigned(tn);
Collapse1.Enabled := Assigned(tn);
end;

Procedure TForm1.DriverDeviceTreeViewChange(Sender: TObject; Node: TTreeNode);
begin
DriverTabSheet.TabVisible := (Node.Selected) And (IsDriverNode(Node));
DeviceTabSheet.TabVisible := (Node.Selected) And (IsDeviceNode(Node));
If Node.Selected Then
  begin
  If DriverTabSheet.TabVisible Then
    PageControl1.ActivePage := DriverTabSheet
  Else If DeviceTabSheet.TabVisible Then
    PageControl1.ActivePage := DeviceTabSheet;

  If Assigned(Node.Data) Then
    begin
    If IsDeviceNode(Node) Then
      DisplayDeviceInfo(Node.Data)
    Else If IsDriverNode(Node) Then
      DisplayDriverInfo(Node.Data);
    end;
  end;
end;

Procedure TForm1.DriverJumpOnEvent(Sender: TObject);
Var
  driverAddress : Pointer;
begin
driverAddress := Pointer((Sender As TComponent).Tag);
If Assigned(driverAddress) Then
  GotoDriver(driverAddress);
end;

Procedure TForm1.DriverMajorFunctionJumpOnEvent(Sender: TObject);
Var
  L : TListItem;
  driverAddress : Pointer;
begin
L := (Sender As TListView).Selected;
If Assigned(L) Then
  begin
  driverAddress := L.Data;
  If Assigned(driverAddress) Then
    GotoDriver(driverAddress);
  end
Else WarningDialog('No item selected');
end;

procedure TForm1.DriverScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
Var
  I : Integer;
  sb : TScrollBox;
begin
sb := (Sender As TScrollBox);
for I := 1 to Mouse.WheelScrollLines do
  Try
    If WheelDelta > 0 then
      sb.Perform(WM_VSCROLL, SB_LINEUP, 0)
    Else
      sb.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  Finally
    sb.Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
  end;
end;

Procedure TForm1.est1Click(Sender: TObject);
Var
  Log : TStringList;
  Logger : TSnapshotLogger;
begin
If SaveDialog1.Execute Then
  begin
  LogSettingsFromGUI;
  Logger := Nil;
  If Sender = est1 Then
    Logger := TSnapshotTextLogger<TStrings>.Create(FSnapshot, FLogSettings, FSnapshotFlags, FDriverList, FSpecialValues);

  If Assigned(Logger) Then
    begin
    Log := TStringList.Create;
    If Logger.Generate(Log) Then
      Log.SaveToFile(SaveDialog1.FileName);

    Log.Free;
    Logger.Free;
    end;
  end;
end;

Procedure TForm1.DisplayDriverInfo(ADriverRecord:TDriverSnapshot);
Var
  p : Pointer;
  I : Integer;
  DevNode : TDeviceSnapshot;
  DeviceName : WideString;
  driverAddress : Pointer;
  dd : TDeviceDriver;
  routineName : WideString;
  fd : PFAST_IO_DISPATCH;
begin
DriverMajorFunctionGroupBox.Visible := FDriverDisplaySettings.MajorFunction;
If DriverMajorFunctionGroupBox.Visible Then
  begin
  For I := 0 To IRP_MJ_MAXIMUM_FUNCTION Do
    begin
    P := ADriverRecord.MajorFunction[I];
    dd := FDriverList.GetDriverByRange(p);
    If Assigned(dd) Then
      begin
      MajorFunctionListView.Items[I].Data := dd.ImageBase;
      MajorFunctionListview.Items[I].SubItems[0] := Format('%s', [dd.FileName]);
      end
    Else MajorFunctionListview.Items[I].SubItems[0] := '<not found>';

    routineName := FSnapshot.TranslateAddress(FSpecialValues, p);
    If routineName <> '' Then
      MajorFunctionListview.Items[I].SubItems[1] := Format('%s', [routineName])
    Else MajorFunctionListview.Items[I].SubItems[1] := Format('0x%p', [p]);
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
      Data := ADriverRecord.Devices[I];
      end;
    end;
  end;

DriverDevicesListView.Items.EndUpdate;

DriverAddressLEdit.Text := Format('0x%p', [ADriverRecord.Address]);
DriverAddressLEdit.Tag := NativeInt(ADriverRecord.Address);
DriverNameLEdit.Text := ADriverRecord.Name;
DriverNameLEdit.Tag := NativeInt(ADriverRecord.Address);
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

FastIoDispatchGroupBox.Visible := (FDriverDisplaySettings.FastIo) And ((FSnapshotFlags And VTREE_SNAPSHOT_FAST_IO_DISPATCH) <> 0) And (Assigned(ADriverRecord.FastIoAddress));
If FastIoDispatchGroupBox.Visible Then
  begin
  FastIoDispatchListView.Clear;
  FastIoDispatchSizeEdit.Text := '';
  fd := @ADriverRecord.FastIoDispatch;
  FastIoDispatchAddressEdit.Text := Format('0x%p', [ADriverRecord.FastIoAddress]);
  FastIoDispatchSizeEdit.Text := Format('%u (%u routines)', [fd.SizeOfFastIoDispatch, (fd.SizeOfFastIoDispatch Div SizeOf(Pointer)) - 1]);
  FastIoDispatchListView.Items.BeginUpdate;
  For I := 0 To (fd.SizeOfFastIoDispatch Div SizeOf(Pointer)) - 2 Do
    begin
    p := fd.Routines[I];
    routineName := FSnapshot.TranslateAddress(FSpecialValues, p);
    With FastIoDispatchListView.Items.Add Do
      begin
      Caption := FastIoIndexToStr(I);
      dd := FDriverList.GetDriverByRange(p);
      If Assigned(dd) Then
        SubItems.Add(dd.FileName)
      Else If Assigned(p) Then
        SubItems.Add('<not found>')
      Else SubItems.Add('');

      If routineName <> '' Then
        SubItems.Add(Format('%s', [routineName]))
      Else SubItems.Add(Format('0x%p', [p]));
      end;
    end;

  FastIoDispatchListView.Items.EndUpdate;
  end;
end;

Procedure TForm1.DisplayMenuItemClick(Sender: TObject);
Var
  tn : TTreeNode;
  objectAddress : Pointer;
  M : TMenuItem;
  sr : TAbstractSnapshotRecord;
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
    5 : FDriverDisplaySettings.FastIo := M.Checked;
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
    13 : FDeviceDisplaySettings.DeviceNode := M.Checked;
    end;
  end;

If Assigned(FSnapshot) Then
  begin
  tn := DriverDeviceTreeView.Selected;
  If Assigned(tn) Then
    begin
    sr := tn.Data;
    Case sr.RecordType Of
      srtDriver : objectAddress := (sr As TDriverSnapshot).Address;
      srtDevice : objectAddress := (sr As TDeviceSnapshot).Address;
      Else objectAddress := Nil;
      end;
    end
  Else objectAddress := Nil;

  FDriverAddressToTreeNode.Clear;
  FDeviceAddressToTreeNode.Clear;
  DriverDeviceTreeView.Items.Clear;
  FImageBaseToDriverAddress.Clear;
  DisplaySnapshot;
  If Assigned(objectAddress) Then
    begin
    Case sr.RecordType Of
      srtDriver: GotoDriver(objectAddress, True);
      srtDevice: GotoDevice(objectAddress, True);
      end;
    end;
  end;
end;

Procedure TForm1.DisplayDeviceInfo(ADeviceRecord:TDeviceSnapshot);
Var
  DiskDevNode : TDeviceSnapshot;
  DiskDevName : WideString;

Const
  extensionFlagValues : Array [0..9] Of Cardinal = (
    DOE_UNLOAD_PENDING,
    DOE_DELETE_PENDING,
    DOE_REMOVE_PENDING,
    DOE_REMOVE_PROCESSED,
    DOE_START_PENDING,
    DOE_STARTIO_REQUESTED,
    DOE_STARTIO_REQUESTED_BYKEY,
    DOE_STARTIO_CANCELABLE,
    DOE_STARTIO_DEFERRED,
    DOE_STARTIO_NO_CANCEL);

Var
  I : Integer;
  da : Pointer;
  devCaps : TDeviceCapabilities;
  extensionFlagCheckBoxes : Array [0..9] Of TCheckBox;
begin
Edit1.Text := Format('0x%p', [ADeviceRecord.Address]);
Edit1.Tag := NativeInt(ADeviceRecord.Address);
Edit2.Text := ADeviceRecord.Name;
Edit2.Tag := NativeInt(ADeviceRecord.Address);
Edit3.Text := Format('0x%p', [ADeviceRecord.DriverAddress]);
Edit3.Tag := NativeInt(ADeviceRecord.DriverAddress);
Edit4.Text := ADeviceRecord.DriverName;
Edit4.Tag := NativeInt(ADeviceRecord.DriverAddress);
Edit5.Text := Format('%d (%s)', [ADeviceRecord.DeviceType, DeviceTypeToStr(ADeviceRecord.DeviceType)]);
Edit6.Text := Format('0x%x', [ADeviceRecord.Flags]);
Edit7.Text := Format('0x%x', [ADeviceRecord.Characteristics]);

Edit8.Text := DeviceTextFromAddress(ADeviceRecord.DiskDeviceAddress);
Edit8.Tag := NativeInt(ADeviceRecord.DiskDeviceAddress);

CapabilitiesGroupBox.Visible := False;
DevicePnPGroupBox.Visible := False;
DeviceVPBGroupBox.Visible := False;
DeviceCharacteristicsGroupBox.Visible := False;
DeviceFlagsGroupBox.Visible := False;

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

  extensionFlagCheckBoxes[0] := CheckBox49;
  extensionFlagCheckBoxes[1] := CheckBox52;
  extensionFlagCheckBoxes[2] := CheckBox53;
  extensionFlagCheckBoxes[3] := CheckBox50;
  extensionFlagCheckBoxes[4] := CheckBox57;
  extensionFlagCheckBoxes[5] := CheckBox54;
  extensionFlagCheckBoxes[6] := CheckBox51;
  extensionFlagCheckBoxes[7] := CheckBox56;
  extensionFlagCheckBoxes[8] := CheckBox55;
  extensionFlagCheckBoxes[9] := CheckBox58;
  For I := Low(extensionFlagValues) To High(extensionFlagValues) Do
    extensionFlagCheckBoxes[I].Checked := ((ADeviceRecord.ExtensionFlags And extensionFlagValues[I]) <> 0);
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
    DevicePnPListView.Clear;
    DevicePnPListView.Items.BeginUpdate;
    ListViewAddNameValue(DevicePnPListView, 'Friendly name', ADeviceRecord.DisplayName);
    ListViewAddNameValue(DevicePnPListView, 'Description', ADeviceRecord.Description);
    ListViewAddNameValue(DevicePnPListView, 'Manufacturer', ADeviceRecord.Vendor);
    ListViewAddNameValue(DevicePnPListView, 'Class', ADeviceRecord.ClassName);
    ListViewAddNameValue(DevicePnPListView, 'Class GUID', ADeviceRecord.ClassGuid);
    ListViewAddNameValue(DevicePnPListView, 'Location', ADeviceRecord.Location);
    ListViewAddNameValue(DevicePnPListView, 'Enumerator', ADeviceRecord.Enumerator);
    If (FSnapshotFlags And VTREE_SNAPSHOT_DEVICE_ID) <> 0 Then
      ListViewAddNameValue(DevicePnPListView, 'Device ID', ADeviceRecord.DeviceId);

    ListViewAddNameValue(DevicePnPListView, 'Instance ID', ADeviceRecord.InstanceId);
    If (FDeviceDisplaySettings.HardwareId) And (Length(ADeviceRecord.HardwareIds) > 0) Then
      begin
      For I := 0 To High(ADeviceRecord.HardwareIds) Do
        ListViewAddNameValue(DevicePnPListView, 'Hardware ID', ADeviceRecord.HardwareIds[I]);
      end;

    If (FDeviceDisplaySettings.CompatibleId) And (Length(ADeviceRecord.CompatibleIds) > 0) Then
      begin
      For I := 0 To High(ADeviceRecord.CompatibleIds) Do
        ListViewAddNameValue(DevicePnPListView, 'Compatible ID', ADeviceRecord.CompatibleIds[I]);
      end;

    If (FDeviceDisplaySettings.DeviceNode) And ((FSnapshotFlags And VTREE_SNAPSHOT_DEVNODE_TREE) <> 0) Then
      begin
      da := FSnapshot.GetDeviceAddressFromDeviceNode(ADeviceRecord.DeviceNode);
      ListViewAddNameValue(DevicePnPListView, 'Devnode', DeviceTextFromNode(ADeviceRecord.DeviceNode, da), da);
      da := FSnapshot.GetDeviceAddressFromDeviceNode(ADeviceRecord.Parent);
      ListViewAddNameValue(DevicePnPListView, 'Parent', DeviceTextFromNode(ADeviceRecord.Parent, da), da);
      da := FSnapshot.GetDeviceAddressFromDeviceNode(ADeviceRecord.Child);
      ListViewAddNameValue(DevicePnPListView, 'Child', DeviceTextFromNode(ADeviceRecord.Child, da), da);
      da := FSnapshot.GetDeviceAddressFromDeviceNode(ADeviceRecord.Sibling);
      ListViewAddNameValue(DevicePnPListView, 'Sibling', DeviceTextFromNode(ADeviceRecord.Sibling, da), da);
      end;

    If (FDeviceDisplaySettings.RemovalRelations) And (Length(ADeviceRecord.RemovalRelations) > 0) Then
      DisplayDeviceRelations(ADeviceRecord.RemovalRelations, 'Removal');

    If (FDeviceDisplaySettings.EjectRelations) And (Length(ADeviceRecord.EjectRelations) > 0) Then
      DisplayDeviceRelations(ADeviceRecord.EjectRelations, 'Eject');

    DevicePnPListView.Items.EndUpdate;
    CapabilitiesGroupBox.Visible := (FDeviceDisplaySettings.Capabilities);
    If CapabilitiesGroupBox.Visible Then
      begin
      devCaps := ADeviceRecord.Capabilities;
      CapabilitiesListView.Clear;
      CapabilitiesListView.Items.BeginUpdate;
      If devCaps.DeviceD1 Then
        ListViewAddNameValue(CapabilitiesListView, 'D1 state', Format('%u', [Ord(devCaps.DeviceD1)]));

      If devCaps.DeviceD2 Then
        ListViewAddNameValue(CapabilitiesListView, 'D2 state', Format('%u', [Ord(devCaps.DeviceD2)]));

      If devCaps.LockSupported Then
        ListViewAddNameValue(CapabilitiesListView, 'Lock supported', Format('%u', [Ord(devCaps.LockSupported)]));

      If devCaps.EjectSupported Then
        ListViewAddNameValue(CapabilitiesListView, 'Eject supported', Format('%u', [Ord(devCaps.EjectSupported)]));

      If devCaps.Removable Then
        ListViewAddNameValue(CapabilitiesListView, 'Removable', Format('%u', [Ord(devCaps.Removable)]));

      If devCaps.DockDevice Then
        ListViewAddNameValue(CapabilitiesListView, 'Dock device', Format('%u', [Ord(devCaps.DockDevice)]));

      If devCaps.UniqueId Then
        ListViewAddNameValue(CapabilitiesListView, 'UniqueId', Format('%u', [Ord(devCaps.UniqueId)]));

      If devCaps.SilentInstall Then
        ListViewAddNameValue(CapabilitiesListView, 'Silent install', Format('%u', [Ord(devCaps.SilentInstall)]));

      If devCaps.RawDeviceOK Then
        ListViewAddNameValue(CapabilitiesListView, 'Raw device OK', Format('%u', [Ord(devCaps.RawDeviceOK)]));

      If devCaps.SurpriseRemovalOK Then
        ListViewAddNameValue(CapabilitiesListView, 'Surprise removal', Format('%u', [Ord(devCaps.SurpriseRemovalOK)]));

      If devCaps.WakeFromD0 Then
        ListViewAddNameValue(CapabilitiesListView, 'Wake from D0', Format('%u', [Ord(devCaps.WakeFromD0)]));

      If devCaps.WakeFromD1 Then
        ListViewAddNameValue(CapabilitiesListView, 'Wake from D1', Format('%u', [Ord(devCaps.WakeFromD1)]));

      If devCaps.WakeFromD2 Then
        ListViewAddNameValue(CapabilitiesListView, 'Wake from D2', Format('%u', [Ord(devCaps.WakeFromD2)]));

      If devCaps.WakeFromD3 Then
        ListViewAddNameValue(CapabilitiesListView, 'Wake from D3', Format('%u', [Ord(devCaps.WakeFromD3)]));

      If devCaps.HardwareDisabled Then
        ListViewAddNameValue(CapabilitiesListView, 'HW disabled', Format('%u', [Ord(devCaps.HardwareDisabled)]));

      If devCaps.NonDynamic Then
        ListViewAddNameValue(CapabilitiesListView, 'Non-dynamic', Format('%u', [Ord(devCaps.NonDynamic)]));

      If devCaps.WarmEjectSupported Then
        ListViewAddNameValue(CapabilitiesListView, 'Warm eject', Format('%u', [Ord(devCaps.WarmEjectSupported)]));

      If devCaps.NoDisplayInUI Then
        ListViewAddNameValue(CapabilitiesListView, 'No display in UI', Format('%u', [Ord(devCaps.NoDisplayInUI)]));

      ListViewAddNameValue(CapabilitiesListView, 'Address', Format('%u', [devCaps.Address]));
      If Not devCaps.NoDisplayInUI Then
        ListViewAddNameValue(CapabilitiesListView, 'UI number', Format('%u', [devCaps.UINumber]));

      If devCaps.D1Latency <> 0 Then
        ListViewAddNameValue(CapabilitiesListView, 'D1 latency', Format('%u ms', [devCaps.D1Latency Div 10]));

      If devCaps.D2Latency <> 0 Then
        ListViewAddNameValue(CapabilitiesListView, 'D2 latency', Format('%u ms', [devCaps.D2Latency Div 10]));

      If devCaps.D3Latency <> 0 Then
        ListViewAddNameValue(CapabilitiesListView, 'D3 latency', Format('%u ms', [devCaps.D3Latency Div 10]));

      CapabilitiesListView.Items.EndUpdate;
      end;
    end;
  end;

DisplayVPB(ADeviceRecord.Vpb);
end;

Procedure TForm1.LoadedDriversListViewData(Sender: TObject; Item: TListItem);
Var
  s : WideString;
  cn : WideString;
  dd : TDeviceDriver;
begin
With Item Do
  begin
  dd := FDriverList.Driver[Index];
  Caption := Format('0x%p', [dd.ImageBase]);
  SubItems.Add(Format('%d KB', [dd.ImageSize Div 1024]));
  SubItems.Add(dd.FileName);
  If dd.FilePresent Then
    begin
    Case dd.SignatureStatus Of
      $0        : SubItems.Add('Signed');
      $800b0100 : SubItems.Add('Not signed');
      $800b0101 : begin
        If dd.TimeStampExpired Then
          Subitems.Add('Timestamp expired')
        Else SubItems.Add('Expired');
        end
      Else SubItems.Add(Format('0x%x', [dd.SignatureStatus]));
      end;
    end
  Else SubItems.Add('<file not found>');

  cn := '';
  For s In dd.CertNames Do
    cn := cn + s + ', ';

  If Length(dd.CertNames) > 0 Then
    System.Delete(cn, Length(cn) - 1, 2);

  SubItems.Add(cn);
  end;
end;

Procedure TForm1.LoadedDriversTabSheetShow(Sender: TObject);
begin
LoadedDriversListView.Items.Count := FDriverList.DriverCount;
LoadedDriversListView.Invalidate;
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
    For I := 11 To 25 Do
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
FLogSettings.General.IncludeDeviceDrivers := CheckBox59.Checked;
FLogSettings.DriverSettings.IncludeEmptyMajorFunctions := CheckBox60.Checked;

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
FLogSettings.DriverSettings.IncludeFastIoDispatch := LogDriverSettingsChl.Checked[11];

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
FLogSettings.DeviceSettings.IncludeDeviceId := LogDeviceSettingsChL.Checked[18];
FLogSettings.DeviceSettings.IncludeInstanceId := LogDeviceSettingsChL.Checked[19];
FLogSettings.DeviceSettings.IncludeHardwareIDs := LogDeviceSettingsChL.Checked[20];
FLogSettings.DeviceSettings.IncludeCompatibleIDs := LogDeviceSettingsChL.Checked[21];
FLogSettings.DeviceSettings.IncludeDeviceCapabilities := LogDeviceSettingsChL.Checked[22];
FLogSettings.DeviceSettings.IncludeRemovalRelations := LogDeviceSettingsChL.Checked[23];
FLogSettings.DeviceSettings.IncludeEjectRelations := LogDeviceSettingsChL.Checked[24];
FLogSettings.DeviceSettings.IncludeSecurity := LogDeviceSettingsChL.Checked[25];
FLogSettings.DeviceSettings.IncludeExtensionFlags := LogDeviceSettingsChL.Checked[26];
FLogSettings.DeviceSettings.IncludeExtensionFlagsStr := LogDeviceSettingsChL.Checked[27];
end;

Procedure TForm1.TreeTypeSubItemOnClick(Sender: TObject);
Var
  M : TMenuItem;
begin
M := (Sender As TMenuItem);
If Not M.Checked Then
  begin
  M.Checked := True;
  FSnapshotType := TDeviceTreeType(M.MenuIndex);
  end;
end;

Procedure TForm1.DisplayVPB(Const AVPB:TVPBSnapshot);
Var
  FSDevice : TDeviceSnapshot;
  FSDeviceName : WideString;
  VolDevice : TDeviceSnapshot;
  VolDeviceName : WideString;
begin
DeviceVPBGroupBox.Visible := (FDeviceDisplaySettings.VPB) And (Assigned(AVPB.VpbAddress));
If DeviceVPBGroupBox.Visible Then
  begin
  Edit9.Text := Format('0x%p', [AVPB.VpbAddress]);
  Edit10.Text := Format('0x%x', [AVPB.Flags]);
  LabeledEdit11.Text := Format('%d', [AVPB.ReferenceCount]);
  FSDeviceName := '<unknown>';
  FSDevice := FSnapshot.GetDeviceByAddress(AVPB.FileSystemDevice);
  If Assigned(FSDevice) Then
    LabeledEdit8.Text := Format('%s (0x%p)', [FSDevice.Name, FSDevice.Address])
  Else If Assigned(AVPB.FileSystemDevice) Then
    LabeledEdit8.Text := Format('<unknown> (0x%p)', [AVPB.FileSystemDevice]);

  LabeledEdit8.Tag := NativeInt(AVPB.FileSystemDevice);
  VolDeviceName := '<unknown>';
  VolDevice := FSnapshot.GetDeviceByAddress(AVPB.VolumeDevice);
  If Assigned(VolDevice) Then
    LabeledEdit9.Text := Format('%s (0x%p)', [VolDevice.Name, VolDevice.Address])
  Else If Assigned(AVPB.VolumeDevice) Then
    LabeledEdit9.Text := Format('<unknown> (0x%p)', [AVPB.VolumeDevice]);

  LabeledEdit9.Tag := NativeInt(AVPB.VolumeDevice);
  LabeledEdit10.Text := AVPB.Name;
  CheckBox43.Checked := (AVPB.Flags And VPB_MOUNTED) > 0;
  CheckBox44.Checked := (AVPB.Flags And VPB_LOCKED) > 0;
  CheckBox45.Checked := (AVPB.Flags And VPB_PERSISTENT) > 0;
  CheckBox48.Checked := (AVPB.Flags And VPB_REMOVE_PENDING) > 0;
  CheckBox46.Checked := (AVPB.Flags And VPB_RAW_MOUNT) > 0;
  CheckBox47.Checked := (AVPB.Flags And VPB_DIRECT_WRITES_ALLOWED) > 0;
  end;
end;

Procedure TForm1.DisplayDeviceRelations(ARelations:Array Of Pointer; ARelationName:WideString);
Var
  I : Integer;
  ds : TDeviceSnapshot;
  deviceName : WideString;
  drivername : WideString;
begin
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

  ListViewAddNameValue(DevicePnPListView, ARelationName, Format('%s (0x%p)', [deviceName, ARelations[I]]), ARelations[I]);
  end;
end;


Procedure TForm1.GoToDriver(AAddress:Pointer; AIgnoreIfNonexistent:Boolean = False);
Var
  tn : TTreeNode;
begin
If FDriverAddressToTreeNode.TryGetValue(AAddress, tn) Then
  begin
  DriverDeviceTreeView.SetFocus;
  DriverDeviceTreeView.Selected := tn;
  end
Else If Not AIgnoreIfNonexistent Then
  WarningDialog('No tree node found for the driver');
end;

Procedure TForm1.Gotodriver1Click(Sender: TObject);
Var
  driverSnapshot : TDriverSnapshot;
  deviceSnapshot : TDeviceSnapshot;
  tn : TTreeNode;
begin
tn := DriverDeviceTreeView.Selected;
If Assigned(tn) Then
  begin
  If IsDeviceNode(tn) Then
    begin
    deviceSnapshot := tn.Data;
    GotoDriver(deviceSnapshot.DriverAddress);
    end
  Else If (IsDriverNode(tn)) Then
    begin
    driverSnapshot := tn.Data;
    GotoDriver(driverSnapshot.Address);
    end;
  end
Else WarningDialog('No item selected');
end;

Procedure TForm1.GoToDevice(AAddress:Pointer; AIgnoreIfNonexistent:Boolean = False);
Var
  tn : TTreeNode;
begin
If FDeviceAddressToTreeNode.TryGetValue(AAddress, tn) Then
  begin
  DriverDeviceTreeView.SetFocus;
  DriverDeviceTreeView.Selected := tn;
  end
Else If Not AIgnoreIfNonexistent Then
  WarningDialog('No tree node found for the device');
end;

Function TForm1.DeviceTextFromAddress(ADeviceAddress:Pointer):WideString;
Var
  deviceRecord : TDeviceSnapshot;
begin
If Assigned(ADeviceAddress) Then
  begin
  deviceRecord := FSnapshot.GetDeviceByAddress(ADeviceAddress);
  If Assigned(deviceRecord) Then
    Result := Format('%S (0x%p)', [deviceRecord.Name, ADeviceAddress])
  Else Result := Format('<unknown> (0x%p)', [ADeviceAddress]);
  end
Else Result := Format('<none> (0x%p)', [Nil]);
end;

Function TForm1.DeviceTextFromNode(ADeviceNode:Pointer; ADeviceAddress:Pointer):WideString;
Var
  fn : WideString;
  desc : WideString;
  ds : TDeviceSnapshot;
begin
Result := Format('0x%p', [ADeviceNode]);
If Assigned(ADeviceAddress) Then
  begin
  ds := FSnapshot.GetDeviceByAddress(ADeviceAddress);
  If Assigned(ds) Then
    begin
    Result := '';
    fn := ds.DisplayName;
    If (Length(fn) > 1) And (fn[1] = '@') Then
      begin
      If Not LoadStringFromPath(fn, fn) Then
        fn := ds.DisplayName;
      end;

    desc := ds.Description;
    If (Length(desc) > 1) And (desc[1] = '@') Then
      begin
      If Not LoadStringFromPath(desc, desc) Then
        desc := ds.Description;
      end;

    If fn <> '' Then
      begin
      Result := fn;
      If desc <> '' Then
        Result := Format('%s %s', [Result, desc]);
      end
    Else Result := desc;

    Result := Format('%s (0x%p)', [Result, ADeviceNode]);
    end
  Else Result := Format('<not found> (0x%p)', [ADeviceNode]);
  end;
end;


Procedure TForm1.DriverListOptionsFromGUI;
begin
FDriverListOptions := [];
If LDVerifySignaturesCheckBox.Checked Then
  FDriverListOptions := FDriverListOptions + [dloVerifyDigitalSignatures];

If LDNoLifeTimeCheckBox.Checked Then
  FDriverListOptions := FDriverListOptions + [dloNoLifetimeTimeStamps];

If Self.LDCheckCRLsCheckBox.Checked Then
  FDriverListOptions := FDriverListOptions + [dloCheckCRLs];

If LDCertNamesCheckBox.Checked Then
  FDriverListOptions := FDriverListOptions + [dloCaptureCertNames];
end;


End.

