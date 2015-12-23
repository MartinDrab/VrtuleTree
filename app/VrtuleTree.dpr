Program VrtuleTree;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  scmDrivers in 'scmDrivers.pas',
  VTreeDriver in 'VTreeDriver.pas',
  Kernel in 'Kernel.pas',
  Utils in 'Utils.pas',
  LogSettings in 'LogSettings.pas',
  Snapshot in 'Snapshot.pas',
  Logger in 'Logger.pas',
  TextLogger in 'TextLogger.pas',
  AboutForm in 'AboutForm.pas' {AboutBox};

{$R *.res}

Var
  Ret : Boolean;
Begin
Application.Initialize;
Ret := DriverInstall;
If Ret Then
  begin
  Ret := DriverLoad;
  If Ret Then
    begin
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
    DriverUnload;
    end
  Else ErrorDialog('Failed to load the driver');

  DriverUninstall;
  end
Else ErrorDialog('Failed to install the driver');
End.

