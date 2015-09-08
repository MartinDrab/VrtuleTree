Unit scmDrivers;

{
 Prace s ovladaci pomoci rutin Spravce sluzeb (Service Control Manager)
}

Interface

Function SCMDriverInstall(Name:WideString; FileName:WideString):Boolean;
Function SCMDriverLoad(Name:WideString):Boolean;
Function SCMDriverUnload(Name:WideString):Boolean;
Function SCMDriverUninstall(Name:WideString):Boolean;

Implementation

Uses Windows, WinSvc, SysUtils;

Function SCMDriverInstall(Name:WideString; FileName:WideString):Boolean;
{
 Nainstaluje sluzbu popisujici ovladac. Vse obstara volani CreateService, ktere provede
 potrebne zapisy do registru.
 InterniJmeno - interni jmeno nove vytvarene sluzby.
 JmenoSouboru - cele jmeno souboru ovladace.
}
Var
  hScm : SC_HANDLE;
  hService : SC_HANDLE;
begin
hScm := OpenSCManagerW(Nil, Nil, SC_MANAGER_CREATE_SERVICE);
Result := hScm > 0;
If Result Then
  begin
  hService := CreateServiceW(hScm, PWideChar(Name), PWideChar(Name), GENERIC_READ,SERVICE_KERNEL_DRIVER, SERVICE_DEMAND_START, SERVICE_ERROR_NORMAL, PWideChar(FileName), Nil, Nil, Nil, Nil, Nil);
  Result := (hService > 0) Or (GetLastError = ERROR_SERVICE_EXISTS);
  If hService > 0 Then
    CloseServiceHandle(hService);

  CloseServiceHandle(hScm);
  end;
end;

Function SCMDriverLoad(Name:WideString):Boolean;
{
 Nacte ovladac do pameti jadra. Provadi se stejne jako spousteni obycejne sluzby - pomoci
 volani StartService.
 InterjniJmeno - interni jmeno sluzby popisujici ovladac.
}
Var
  hScm : SC_HANDLE;
  hService : SC_HANDLE;
  Dummy : PWideChar;
begin
hScm := OpenSCManagerW(Nil, Nil, SC_MANAGER_CONNECT);
Result := hScm > 0;
If Result Then
  begin
  hService := OpenServiceW(hScm, PWideChar(Name), SERVICE_START);
  Result := hService > 0;
  If Result Then
    begin
    Result := StartServiceW(hService, 0, Dummy);
    If Not Result Then
      Result := GetLastError = ERROR_SERVICE_ALREADY_RUNNING;

    CloseServiceHandle(hService);
    end;

  CloseServiceHandle(hScm);
  end;
end;

Function SCMDriverUnload(Name:WideString):Boolean;
{
 Pokusi se uvolnit ovladac z jadra stejne jako se zastavuje beh obycejne sluzby. K tomu se
 pouziva volani StopService.
 InterniJmeno - interni jmeno sluzby ovladace.
}
Var
  hScm : SC_HANDLE;
  hService : SC_HANDLE;
  ServiceStatus : SERVICE_STATUS;
begin
hScm := OpenSCManagerW(Nil, Nil, SC_MANAGER_CONNECT);
Result := hScm > 0;
If Result Then
  begin
  hService := OpenServiceW(hScm, PWideChar(Name), SERVICE_STOP);
  Result := hService > 0;
  If Result Then
    begin
    Result := ControlService(hService, SERVICE_CONTROL_STOP, ServiceStatus);
    CloseServiceHandle(hService);
    end;

  CloseServiceHandle(hScm);
  end;
end;

Function SCMDriverUninstall(Name:WideString):Boolean;
{
 Odstrani zaznam o sluzbe ovladace z registru pomoci rutiny DeleteService. Ovladace, ktere
 nemaji zapis v registru, nepreziji restart pocitace.
 InterniJmeno - interni jmeno sluzby, ktera se ma odstranit.
}
Var
  hScm : SC_HANDLE;
  hService : SC_HANDLE;
begin
hScm := OpenSCManagerW(Nil, Nil, SC_MANAGER_CONNECT);
Result := hScm > 0;
If Result Then
  begin
  hService := OpenServiceW(hScm, PWideChar(Name), SERVICE_ALL_ACCESS);
  Result := hService > 0;
  If Result Then
    begin
    Result := DeleteService(hService);
    CloseServiceHandle(hService);
    end;

  CloseServiceHandle(hScm);
  end;
end;

End.

