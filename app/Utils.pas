Unit Utils;

Interface

Uses
  Windows, Classes;

Procedure DebugPrint(AMsg:WideString; AArgs:Array Of Const);
Procedure ErrorDialog(AMsg:WideString);
Procedure WarningDialog(AMsg:WideString);
Procedure InformationDialog(AMsg:WideString);
Function LoadStringFromPath(APath:WideString; Var AResult:WideString):Boolean;

Implementation

Uses
  PSAPI, SysUtils;


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

Function LoadStringFromPath(APath:WideString; Var AResult:WideString):Boolean;
Var
  hMod : HMODULE;
  fileName : WideString;
  commaIndex : Integer;
  resId : Integer;
  buffer : Array [0..MAX_PATH] Of WideChar;
  resBuffer : Array [0..MAX_PATH] Of WideChar;
begin
AResult := '';
Result := APath[1] = '@';
If Result Then
  begin
  commaIndex := System.Pos(',', APath);
  Result := commaIndex > 0;
  If Result Then
    begin
    fileName := Copy(APath, 2, commaIndex - 2);
    Try
      resId := StrToInt64(Copy(APath, commaIndex + 1, Length(APath) - commaIndex));
    Except
      Result := False;
      end;

    If Result Then
      begin
      Zeromemory(@buffer, SizeOf(buffer));
      Result := ExpandEnvironmentStringsW(PWideChar(fileName), buffer, MAX_PATH) > 0;
      If Result Then
        begin
        fileName := Copy(WideString(buffer), 1, StrLen(buffer));
        hMod := LoadLibraryEx(PWideChar(fileName), 0, DONT_RESOLVE_DLL_REFERENCES);
        Result := hMod <> 0;
        If Result Then
          begin
          ZeroMemory(@resBuffer, SizeOf(resBuffer));
          Result := LoadStringW(hMod, Abs(ResId), resBuffer, MAX_PATH) > 0;
          If Result Then
            begin
            AResult := Copy(WideString(resBuffer), 1, StrLen(resBuffer));
            end;

          FreeLibrary(hMod);
          end
        Else ErrorDialog(SysErrorMessage(GetLastError));
        end;
      end;
    end;
  end;
end;

End.

