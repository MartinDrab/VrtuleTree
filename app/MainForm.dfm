object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'VrtuleTree'
  ClientHeight = 553
  ClientWidth = 692
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DriverDeviceTreeView: TTreeView
    Left = 0
    Top = 0
    Width = 230
    Height = 553
    Align = alLeft
    Indent = 19
    ReadOnly = True
    SortType = stText
    TabOrder = 0
    OnChange = DriverDeviceTreeViewChange
  end
  object PageControl1: TPageControl
    Left = 230
    Top = 0
    Width = 462
    Height = 553
    ActivePage = DeviceTabSheet
    Align = alClient
    TabOrder = 1
    object DeviceTabSheet: TTabSheet
      Caption = 'Device'
      object DeviceScrollBox: TScrollBox
        Left = 0
        Top = 0
        Width = 454
        Height = 525
        VertScrollBar.Range = 1200
        Align = alClient
        AutoScroll = False
        TabOrder = 0
        object DeviceFlagsGroupBox: TGroupBox
          Left = 0
          Top = 137
          Width = 433
          Height = 104
          Align = alTop
          Caption = 'Flags'
          TabOrder = 0
          object CheckBox1: TCheckBox
            Left = 3
            Top = 16
            Width = 97
            Height = 17
            Caption = 'Buffered I/O'
            TabOrder = 0
          end
          object CheckBox2: TCheckBox
            Left = 3
            Top = 32
            Width = 97
            Height = 17
            Caption = 'Direct I/O'
            TabOrder = 1
          end
          object CheckBox3: TCheckBox
            Left = 3
            Top = 48
            Width = 97
            Height = 17
            Caption = 'Enumerated'
            TabOrder = 2
          end
          object CheckBox4: TCheckBox
            Left = 115
            Top = 16
            Width = 97
            Height = 17
            Caption = 'Initializing'
            TabOrder = 3
          end
          object CheckBox5: TCheckBox
            Left = 115
            Top = 32
            Width = 97
            Height = 17
            Caption = 'Exclusive'
            TabOrder = 4
          end
          object CheckBox6: TCheckBox
            Left = 115
            Top = 48
            Width = 97
            Height = 17
            Caption = 'Map I/O Buffer'
            TabOrder = 5
          end
          object CheckBox7: TCheckBox
            Left = 235
            Top = 16
            Width = 97
            Height = 17
            Caption = 'Power Inrush'
            TabOrder = 6
          end
          object CheckBox8: TCheckBox
            Left = 235
            Top = 32
            Width = 97
            Height = 17
            Caption = 'Power Pageable'
            TabOrder = 7
          end
          object CheckBox9: TCheckBox
            Left = 235
            Top = 48
            Width = 126
            Height = 17
            Caption = 'Shutdown Registered'
            TabOrder = 8
          end
          object CheckBox10: TCheckBox
            Left = 3
            Top = 64
            Width = 97
            Height = 17
            Caption = 'Verify Volume'
            TabOrder = 9
          end
          object CheckBox23: TCheckBox
            Left = 115
            Top = 64
            Width = 73
            Height = 17
            Caption = 'Named'
            TabOrder = 10
          end
          object CheckBox24: TCheckBox
            Left = 235
            Top = 64
            Width = 120
            Height = 17
            Caption = 'Boot Partition'
            TabOrder = 11
          end
          object CheckBox25: TCheckBox
            Left = 363
            Top = 16
            Width = 120
            Height = 17
            Caption = 'Long Term'
            TabOrder = 12
          end
          object CheckBox26: TCheckBox
            Left = 363
            Top = 32
            Width = 120
            Height = 17
            Caption = 'Never Last'
            TabOrder = 13
          end
          object CheckBox27: TCheckBox
            Left = 363
            Top = 48
            Width = 120
            Height = 17
            Caption = 'Low Priority FS'
            TabOrder = 14
          end
          object CheckBox28: TCheckBox
            Left = 363
            Top = 64
            Width = 120
            Height = 17
            Caption = 'Transactions'
            TabOrder = 15
          end
          object CheckBox29: TCheckBox
            Left = 3
            Top = 80
            Width = 106
            Height = 17
            Caption = 'Force Neither I/O'
            TabOrder = 16
          end
          object CheckBox30: TCheckBox
            Left = 115
            Top = 80
            Width = 120
            Height = 17
            Caption = 'Volume'
            TabOrder = 17
          end
          object CheckBox31: TCheckBox
            Left = 235
            Top = 80
            Width = 120
            Height = 17
            Caption = 'System Partition'
            TabOrder = 18
          end
          object CheckBox32: TCheckBox
            Left = 363
            Top = 81
            Width = 120
            Height = 17
            Caption = 'Critical Partition'
            TabOrder = 19
          end
        end
        object DeviceCharacteristicsGroupBox: TGroupBox
          Left = 0
          Top = 241
          Width = 433
          Height = 72
          Align = alTop
          Caption = 'Characteristics'
          TabOrder = 1
          object CheckBox11: TCheckBox
            Left = 3
            Top = 17
            Width = 126
            Height = 17
            Caption = 'Autogenerated Name'
            TabOrder = 0
          end
          object CheckBox12: TCheckBox
            Left = 3
            Top = 33
            Width = 126
            Height = 17
            Caption = 'Characteristic PnP'
            TabOrder = 1
          end
          object CheckBox13: TCheckBox
            Left = 3
            Top = 47
            Width = 142
            Height = 17
            Caption = 'Characteristic TS'
            TabOrder = 2
          end
          object CheckBox14: TCheckBox
            Left = 147
            Top = 47
            Width = 142
            Height = 17
            Caption = 'WebDAV'
            TabOrder = 3
          end
          object CheckBox15: TCheckBox
            Left = 147
            Top = 17
            Width = 94
            Height = 17
            Caption = 'Mounted'
            TabOrder = 4
          end
          object CheckBox16: TCheckBox
            Left = 147
            Top = 33
            Width = 94
            Height = 17
            Caption = 'Secure Open'
            TabOrder = 5
          end
          object CheckBox17: TCheckBox
            Left = 247
            Top = 47
            Width = 94
            Height = 17
            Caption = 'Diskette'
            TabOrder = 6
          end
          object CheckBox18: TCheckBox
            Left = 343
            Top = 47
            Width = 94
            Height = 17
            Caption = 'Read Only'
            TabOrder = 7
          end
          object CheckBox19: TCheckBox
            Left = 247
            Top = 17
            Width = 126
            Height = 17
            Caption = 'Remote'
            TabOrder = 8
          end
          object CheckBox20: TCheckBox
            Left = 247
            Top = 33
            Width = 126
            Height = 17
            Caption = 'Removable'
            TabOrder = 9
          end
          object CheckBox21: TCheckBox
            Left = 343
            Top = 17
            Width = 126
            Height = 17
            Caption = 'Virtual Volume'
            TabOrder = 10
          end
          object CheckBox22: TCheckBox
            Left = 343
            Top = 33
            Width = 126
            Height = 17
            Caption = 'Write Once'
            TabOrder = 11
          end
        end
        object DevicePnPGroupBox: TGroupBox
          Left = 0
          Top = 450
          Width = 433
          Height = 203
          Align = alTop
          Caption = 'PnP'
          TabOrder = 2
          object DevicePnpListView: TListView
            Left = 2
            Top = 15
            Width = 429
            Height = 186
            Align = alClient
            Columns = <
              item
                Caption = 'Name'
                Width = 100
              end
              item
                AutoSize = True
                Caption = 'Value'
              end>
            Items.ItemData = {
              05CD0100000900000000000000FFFFFFFFFFFFFFFF01000000FFFFFFFF000000
              000C44006900730070006C006100790020004E0061006D00650000102D1B1400
              000000FFFFFFFFFFFFFFFF01000000FFFFFFFF000000000B4400650073006300
              720069007000740069006F006E000010731B1400000000FFFFFFFFFFFFFFFF01
              000000FFFFFFFF0000000006560065006E0064006F0072000080731B14000000
              00FFFFFFFFFFFFFFFF01000000FFFFFFFF000000000543006C00610073007300
              00F0731B1400000000FFFFFFFFFFFFFFFF01000000FFFFFFFF000000000A4300
              6C00610073007300200047005500490044000060741B1400000000FFFFFFFFFF
              FFFFFF01000000FFFFFFFF00000000084C006F0063006100740069006F006E00
              00D0741B1400000000FFFFFFFFFFFFFFFF01000000FFFFFFFF000000000A4500
              6E0075006D0065007200610074006F0072000040751B1400000000FFFFFFFFFF
              FFFFFF01000000FFFFFFFF000000000944006500760069006300650020004900
              440000E8751B1400000000FFFFFFFFFFFFFFFF01000000FFFFFFFF000000000B
              49006E007300740061006E00630065002000490044000020761B14FFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFF}
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
        object DeviceVPBGroupBox: TGroupBox
          Left = 0
          Top = 313
          Width = 433
          Height = 137
          Align = alTop
          Caption = 'Volume Parameter Block'
          TabOrder = 3
          object Label9: TLabel
            Left = 8
            Top = 16
            Width = 39
            Height = 13
            Caption = 'Address'
          end
          object Label10: TLabel
            Left = 240
            Top = 16
            Width = 25
            Height = 13
            Caption = 'Flags'
          end
          object LabeledEdit8: TLabeledEdit
            Left = 2
            Top = 76
            Width = 209
            Height = 21
            EditLabel.Width = 100
            EditLabel.Height = 13
            EditLabel.Caption = 'Volume device (VDO)'
            ReadOnly = True
            TabOrder = 0
          end
          object LabeledEdit9: TLabeledEdit
            Left = 227
            Top = 76
            Width = 198
            Height = 21
            EditLabel.Width = 72
            EditLabel.Height = 13
            EditLabel.Caption = 'Storage device'
            ReadOnly = True
            TabOrder = 1
          end
          object LabeledEdit10: TLabeledEdit
            Left = 2
            Top = 113
            Width = 209
            Height = 21
            EditLabel.Width = 59
            EditLabel.Height = 13
            EditLabel.Caption = 'Volume label'
            ReadOnly = True
            TabOrder = 2
          end
          object LabeledEdit11: TLabeledEdit
            Left = 227
            Top = 113
            Width = 193
            Height = 21
            EditLabel.Width = 80
            EditLabel.Height = 13
            EditLabel.Caption = 'Reference count'
            ReadOnly = True
            TabOrder = 3
          end
          object Edit9: TEdit
            Left = 53
            Top = 16
            Width = 158
            Height = 21
            ReadOnly = True
            TabOrder = 4
          end
          object Edit10: TEdit
            Left = 277
            Top = 16
            Width = 158
            Height = 21
            ReadOnly = True
            TabOrder = 5
          end
          object CheckBox43: TCheckBox
            Left = 3
            Top = 43
            Width = 78
            Height = 17
            Caption = 'Mounted'
            TabOrder = 6
          end
          object CheckBox44: TCheckBox
            Left = 75
            Top = 43
            Width = 54
            Height = 17
            Caption = 'Locked'
            TabOrder = 7
          end
          object CheckBox45: TCheckBox
            Left = 135
            Top = 43
            Width = 73
            Height = 17
            Caption = 'Persistent'
            TabOrder = 8
          end
          object CheckBox46: TCheckBox
            Left = 208
            Top = 43
            Width = 81
            Height = 17
            Caption = 'Raw mount'
            TabOrder = 9
          end
          object CheckBox47: TCheckBox
            Left = 295
            Top = 43
            Width = 90
            Height = 17
            Caption = 'Direct writes'
            TabOrder = 10
          end
          object CheckBox48: TCheckBox
            Left = 383
            Top = 43
            Width = 74
            Height = 17
            Caption = 'Removing'
            TabOrder = 11
          end
        end
        object DeviceGeneralInfoPanel: TPanel
          Left = 0
          Top = 0
          Width = 433
          Height = 137
          Align = alTop
          TabOrder = 4
          object Label1: TLabel
            Left = 2
            Top = 8
            Width = 39
            Height = 13
            Caption = 'Address'
          end
          object Label2: TLabel
            Left = 3
            Top = 35
            Width = 27
            Height = 13
            Caption = 'Name'
          end
          object Label3: TLabel
            Left = 202
            Top = 3
            Width = 71
            Height = 13
            Caption = 'Driver Address'
          end
          object Label4: TLabel
            Left = 202
            Top = 35
            Width = 59
            Height = 13
            Caption = 'Driver Name'
          end
          object Label5: TLabel
            Left = 2
            Top = 62
            Width = 59
            Height = 13
            Caption = 'Device Type'
          end
          object Label6: TLabel
            Left = 3
            Top = 89
            Width = 25
            Height = 13
            Caption = 'Flags'
          end
          object Label7: TLabel
            Left = 202
            Top = 91
            Width = 71
            Height = 13
            Caption = 'Characteristics'
          end
          object Label8: TLabel
            Left = 2
            Top = 116
            Width = 56
            Height = 13
            Caption = 'Disk Volume'
          end
          object Edit1: TEdit
            Left = 75
            Top = 0
            Width = 121
            Height = 21
            ReadOnly = True
            TabOrder = 0
          end
          object Edit2: TEdit
            Left = 75
            Top = 27
            Width = 121
            Height = 21
            ReadOnly = True
            TabOrder = 1
          end
          object Edit3: TEdit
            Left = 279
            Top = 0
            Width = 121
            Height = 21
            ReadOnly = True
            TabOrder = 2
          end
          object Edit4: TEdit
            Left = 280
            Top = 27
            Width = 121
            Height = 21
            ReadOnly = True
            TabOrder = 3
          end
          object Edit5: TEdit
            Left = 75
            Top = 54
            Width = 326
            Height = 21
            ReadOnly = True
            TabOrder = 4
          end
          object Edit6: TEdit
            Left = 75
            Top = 81
            Width = 121
            Height = 21
            ReadOnly = True
            TabOrder = 5
          end
          object Edit7: TEdit
            Left = 279
            Top = 83
            Width = 121
            Height = 21
            ReadOnly = True
            TabOrder = 6
          end
          object Edit8: TEdit
            Left = 75
            Top = 110
            Width = 326
            Height = 21
            ReadOnly = True
            TabOrder = 7
          end
        end
        object RemovalRelationsGroupBox: TGroupBox
          Left = 0
          Top = 984
          Width = 433
          Height = 128
          Align = alTop
          Caption = 'Removal relations'
          TabOrder = 5
          object RemovalRelationsListView: TListView
            Left = 2
            Top = 15
            Width = 429
            Height = 111
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Name'
              end
              item
                Caption = 'Address'
                Width = 90
              end>
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
        object EjectRelationsGroupBox: TGroupBox
          Left = 0
          Top = 653
          Width = 433
          Height = 95
          Align = alTop
          Caption = 'Eject relations'
          TabOrder = 6
          object EjectRelationsListView: TListView
            Left = 2
            Top = 15
            Width = 429
            Height = 78
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Device'
              end
              item
                AutoSize = True
                Caption = 'Driver'
              end
              item
                Caption = 'Address'
                Width = 90
              end>
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
        object CompatibleIDsGroupBox: TGroupBox
          Left = 0
          Top = 866
          Width = 433
          Height = 118
          Align = alTop
          Caption = 'Compatible IDs'
          TabOrder = 7
          object CompatibleIDsListView: TListView
            Left = 2
            Top = 15
            Width = 429
            Height = 101
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Name'
              end>
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
        object HardwareIDsGroupBox: TGroupBox
          Left = 0
          Top = 748
          Width = 433
          Height = 118
          Align = alTop
          Caption = 'Hardware IDs'
          TabOrder = 8
          object HardwareIDsListView: TListView
            Left = 2
            Top = 15
            Width = 429
            Height = 101
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Name'
              end>
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
        object CapabilitiesGroupBox: TGroupBox
          Left = 0
          Top = 1112
          Width = 433
          Height = 85
          Align = alTop
          Caption = 'Device capabilities'
          TabOrder = 9
          object CapabilitiesListView: TListView
            Left = 2
            Top = 15
            Width = 429
            Height = 68
            Align = alClient
            Columns = <
              item
                Caption = 'Name'
                Width = 100
              end
              item
                AutoSize = True
                Caption = 'Value'
              end>
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
      end
    end
    object DriverTabSheet: TTabSheet
      Caption = 'Driver'
      ImageIndex = 1
      object DriverDevicesGroupBox: TGroupBox
        Left = 0
        Top = 209
        Width = 454
        Height = 104
        Align = alTop
        Caption = 'Devices'
        TabOrder = 0
        object DriverDevicesListView: TListView
          Left = 2
          Top = 15
          Width = 450
          Height = 87
          Align = alClient
          Columns = <
            item
              AutoSize = True
              Caption = 'Name'
            end
            item
              Caption = 'Address'
              Width = 150
            end>
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
      end
      object DriverMajorFunctionGroupBox: TGroupBox
        Left = 0
        Top = 313
        Width = 454
        Height = 190
        Align = alTop
        Caption = 'Major Function'
        TabOrder = 1
        object MajorFunctionListview: TListView
          Left = 2
          Top = 15
          Width = 450
          Height = 173
          Align = alClient
          Columns = <
            item
              Caption = 'Function'
              Width = 120
            end
            item
              AutoSize = True
              Caption = 'Driver'
            end
            item
              Caption = 'Address'
              Width = 150
            end>
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
      end
      object DriverGeneralInfoPanel: TPanel
        Left = 0
        Top = 0
        Width = 454
        Height = 209
        Align = alTop
        TabOrder = 2
        object DriverAddressLEdit: TLabeledEdit
          Left = 2
          Top = 22
          Width = 135
          Height = 21
          EditLabel.Width = 73
          EditLabel.Height = 13
          EditLabel.Caption = 'Object address'
          ReadOnly = True
          TabOrder = 0
        end
        object DriverNameLEdit: TLabeledEdit
          Left = 152
          Top = 18
          Width = 145
          Height = 21
          EditLabel.Width = 27
          EditLabel.Height = 13
          EditLabel.Caption = 'Name'
          ReadOnly = True
          TabOrder = 1
        end
        object LabeledEdit1: TLabeledEdit
          Left = 2
          Top = 64
          Width = 135
          Height = 21
          EditLabel.Width = 97
          EditLabel.Height = 13
          EditLabel.Caption = 'Image base address'
          ReadOnly = True
          TabOrder = 2
        end
        object LabeledEdit2: TLabeledEdit
          Left = 152
          Top = 64
          Width = 145
          Height = 21
          EditLabel.Width = 51
          EditLabel.Height = 13
          EditLabel.Caption = 'Image size'
          ReadOnly = True
          TabOrder = 3
        end
        object LabeledEdit3: TLabeledEdit
          Left = 2
          Top = 104
          Width = 135
          Height = 21
          EditLabel.Width = 55
          EditLabel.Height = 13
          EditLabel.Caption = 'DriverEntry'
          ReadOnly = True
          TabOrder = 4
        end
        object LabeledEdit4: TLabeledEdit
          Left = 152
          Top = 104
          Width = 145
          Height = 21
          EditLabel.Width = 62
          EditLabel.Height = 13
          EditLabel.Caption = 'DriverUnload'
          NumbersOnly = True
          TabOrder = 5
        end
        object LabeledEdit5: TLabeledEdit
          Left = 2
          Top = 182
          Width = 295
          Height = 21
          EditLabel.Width = 55
          EditLabel.Height = 13
          EditLabel.Caption = 'Image path'
          ReadOnly = True
          TabOrder = 6
        end
        object LabeledEdit6: TLabeledEdit
          Left = 2
          Top = 144
          Width = 135
          Height = 21
          EditLabel.Width = 36
          EditLabel.Height = 13
          EditLabel.Caption = 'StartIO'
          ReadOnly = True
          TabOrder = 7
        end
        object LabeledEdit7: TLabeledEdit
          Left = 152
          Top = 144
          Width = 145
          Height = 21
          EditLabel.Width = 25
          EditLabel.Height = 13
          EditLabel.Caption = 'Flags'
          ReadOnly = True
          TabOrder = 8
        end
        object DriverFlagsGroupBox: TGroupBox
          Left = 303
          Top = 0
          Width = 146
          Height = 201
          Caption = 'Flags'
          TabOrder = 9
          object CheckBox36: TCheckBox
            Left = 11
            Top = 43
            Width = 103
            Height = 17
            Caption = 'Legacy driver'
            TabOrder = 0
          end
          object CheckBox37: TCheckBox
            Left = 11
            Top = 66
            Width = 103
            Height = 17
            Caption = 'Built-in driver'
            TabOrder = 1
          end
          object CheckBox38: TCheckBox
            Left = 11
            Top = 89
            Width = 132
            Height = 17
            Caption = 'Reinitialization'
            TabOrder = 2
          end
          object CheckBox39: TCheckBox
            Left = 11
            Top = 112
            Width = 103
            Height = 17
            Caption = 'Initialized'
            TabOrder = 3
          end
          object CheckBox40: TCheckBox
            Left = 11
            Top = 135
            Width = 132
            Height = 17
            Caption = 'Boot reinitialization'
            TabOrder = 4
          end
          object CheckBox41: TCheckBox
            Left = 11
            Top = 158
            Width = 103
            Height = 17
            Caption = 'Legacy resources'
            TabOrder = 5
          end
          object CheckBox42: TCheckBox
            Left = 11
            Top = 181
            Width = 134
            Height = 17
            Caption = 'Base filesystem driver'
            TabOrder = 6
          end
          object CheckBox35: TCheckBox
            Left = 11
            Top = 20
            Width = 134
            Height = 17
            Caption = 'DriverUnload invoked'
            TabOrder = 7
          end
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Log Settings'
      ImageIndex = 2
      object GroupBox6: TGroupBox
        Left = 0
        Top = 63
        Width = 185
        Height = 462
        Align = alLeft
        Caption = 'Include Drivers'
        TabOrder = 0
        object LogIncludeDriversChL: TCheckListBox
          Left = 2
          Top = 73
          Width = 181
          Height = 387
          Align = alClient
          ItemHeight = 13
          TabOrder = 0
        end
        object Panel3: TPanel
          Left = 2
          Top = 15
          Width = 181
          Height = 58
          Align = alTop
          TabOrder = 1
          object Button1: TButton
            Left = 0
            Top = 2
            Width = 57
            Height = 25
            Caption = 'Select all'
            TabOrder = 0
            OnClick = Button1Click
          end
          object Button2: TButton
            Left = 0
            Top = 27
            Width = 177
            Height = 25
            Caption = 'Unselect all'
            TabOrder = 1
            OnClick = Button1Click
          end
          object Button3: TButton
            Left = 120
            Top = 2
            Width = 57
            Height = 25
            Caption = 'Invert'
            TabOrder = 2
            OnClick = Button1Click
          end
        end
      end
      object GroupBox7: TGroupBox
        Left = 185
        Top = 63
        Width = 118
        Height = 462
        Align = alLeft
        Caption = 'Driver Settings'
        TabOrder = 1
        object LogDriverSettingsChL: TCheckListBox
          Left = 2
          Top = 73
          Width = 114
          Height = 387
          OnClickCheck = LogDriverSettingsChLClickCheck
          Align = alClient
          ItemHeight = 13
          Items.Strings = (
            'File name'
            'Image base address'
            'Image size'
            'DriverEntry'
            'DriverUnload'
            'StartIo'
            'Flags'
            'Flags as string'
            'Major functions'
            'Number of devices'
            'Devices')
          TabOrder = 0
        end
        object Panel4: TPanel
          Left = 2
          Top = 15
          Width = 114
          Height = 58
          Align = alTop
          TabOrder = 1
          object Button4: TButton
            Left = 4
            Top = 2
            Width = 57
            Height = 25
            Caption = 'Select all'
            TabOrder = 0
            OnClick = Button1Click
          end
          object Button5: TButton
            Left = 4
            Top = 27
            Width = 116
            Height = 25
            Caption = 'Unselect all'
            TabOrder = 1
            OnClick = Button1Click
          end
          object Button6: TButton
            Left = 63
            Top = 2
            Width = 57
            Height = 25
            Caption = 'Invert'
            TabOrder = 2
            OnClick = Button1Click
          end
        end
      end
      object GroupBox8: TGroupBox
        Left = 303
        Top = 63
        Width = 150
        Height = 462
        Align = alLeft
        Caption = 'Device Settings'
        TabOrder = 2
        object LogDeviceSettingsChL: TCheckListBox
          Left = 2
          Top = 73
          Width = 146
          Height = 387
          OnClickCheck = LogDriverSettingsChLClickCheck
          Align = alClient
          ItemHeight = 13
          Items.Strings = (
            ' Type'
            ' Disk Device'
            ' Number of upper devices'
            ' Upper devices'
            ' Number of lower devices'
            ' Lower devices'
            ' Flags'
            ' Flags as string'
            ' Characteristics'
            ' Characteristics as string'
            ' Plug&Play information'
            ' Friendly name'
            ' Description'
            ' Manufacturer'
            ' Enumerator'
            ' Location'
            ' Class'
            ' Class GUID'
            'Device ID'
            'Instance ID'
            'Hardware IDs'
            'Compatible IDs'
            'Container ID'
            'Removal relations'
            'Eject relations'
            'Security')
          TabOrder = 0
        end
        object Panel5: TPanel
          Left = 2
          Top = 15
          Width = 146
          Height = 58
          Align = alTop
          TabOrder = 1
          object Button7: TButton
            Left = 2
            Top = 2
            Width = 59
            Height = 25
            Caption = 'Select all'
            TabOrder = 0
            OnClick = Button1Click
          end
          object Button8: TButton
            Left = 2
            Top = 27
            Width = 139
            Height = 25
            Caption = 'Unselect all'
            TabOrder = 1
            OnClick = Button1Click
          end
          object Button9: TButton
            Left = 82
            Top = 2
            Width = 59
            Height = 25
            Caption = 'Invert'
            TabOrder = 2
            OnClick = Button1Click
          end
        end
      end
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 454
        Height = 63
        Align = alTop
        TabOrder = 3
        object GroupBox9: TGroupBox
          Left = 1
          Top = 1
          Width = 452
          Height = 56
          Align = alTop
          Caption = 'General'
          TabOrder = 0
          object CheckBox33: TCheckBox
            Left = 3
            Top = 16
            Width = 175
            Height = 17
            Caption = 'Include VrtuleTree information'
            Checked = True
            State = cbChecked
            TabOrder = 0
          end
          object CheckBox34: TCheckBox
            Left = 3
            Top = 36
            Width = 175
            Height = 17
            Caption = 'Include OS version information'
            Checked = True
            State = cbChecked
            TabOrder = 1
          end
        end
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 144
    Top = 88
    object File1: TMenuItem
      Caption = 'File'
      object Createsnapshot1: TMenuItem
        Caption = 'Create snapshot'
        OnClick = Createsnapshot1Click
      end
      object Createlog1: TMenuItem
        Caption = 'Create log'
        object est1: TMenuItem
          Caption = 'Test...'
          OnClick = est1Click
        end
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object DriverDisplayMenuItem: TMenuItem
        Caption = 'Driver'
        object Devices1: TMenuItem
          Caption = 'Devices (tree)'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object N2: TMenuItem
          Caption = '-'
        end
        object Flags1: TMenuItem
          Caption = 'Flags'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object Devices2: TMenuItem
          Caption = 'Devices'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object MajorFunction1: TMenuItem
          Caption = 'Major Function'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
      end
      object DeviceDisplayMenuItem: TMenuItem
        Caption = 'Device'
        object Lowerdevicestree1: TMenuItem
          Caption = 'Lower devices (tree)'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object Upperdevicestree1: TMenuItem
          Caption = 'Upper devices (tree)'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object N3: TMenuItem
          Caption = '-'
        end
        object Flags2: TMenuItem
          Caption = 'Flags'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object Characteristics1: TMenuItem
          Caption = 'Characteristics'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object VPB1: TMenuItem
          Caption = 'VPB'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object PnPinformation1: TMenuItem
          Caption = 'PnP information'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object HardwareIDs1: TMenuItem
          Caption = 'Hardware IDs'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object CompatibleIDs1: TMenuItem
          Caption = 'Compatible IDs'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object Capabilities1: TMenuItem
          Caption = 'Capabilities'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object Removalrelations1: TMenuItem
          Caption = 'Removal relations'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object Ejectrelations1: TMenuItem
          Caption = 'Eject relations'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
        object Security1: TMenuItem
          Caption = 'Security'
          Checked = True
          OnClick = DisplayMenuItemClick
        end
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object AboutVrtuleTree1: TMenuItem
        Caption = 'About VrtuleTree'
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 136
    Top = 40
  end
end
