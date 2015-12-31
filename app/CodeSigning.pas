Unit CodeSigning;

Interface

Uses
  Windows, Classes;

Type
  TCodeSigningOptions = (
    csoCheckRevocations,
    csoNoLifeTimeTimeStamps
  );
  TCodeSigningOptionSet = Set Of TCodeSigningOptions;

Function IsCodeSigned(AFileName:Widestring; AOptions:TCodeSigningOptionSet):Cardinal;
Function GetFileCertificateNames(AFilename:WideString; ACertNames:TStringList):Cardinal;

Implementation

Uses
  SysUtils;

Const
  CERT_SECTION_TYPE_ANY = $FF;      // Any Certificate type

Function ImageEnumerateCertificates(FileHandle: THandle; TypeFilter: WORD; out CertificateCount: DWORD; Indicies: PDWORD; IndexCount: Integer): BOOL; Stdcall; External 'Imagehlp.dll';
Function ImageGetCertificateHeader(FileHandle: THandle; CertificateIndex: Integer; Var CertificateHeader: TWinCertificate): BOOL; stdcall; external 'Imagehlp.dll';
Function ImageGetCertificateData(FileHandle: THandle; CertificateIndex: Integer; Certificate: PWinCertificate; var RequiredLength: DWORD): BOOL; stdcall; external 'Imagehlp.dll';

Const
  CERT_NAME_SIMPLE_DISPLAY_TYPE = 4;
  PKCS_7_ASN_ENCODING = $00010000;
  X509_ASN_ENCODING = $00000001;

Type
  PCCERT_CONTEXT = type Pointer;
  HCRYPTPROV_LEGACY = type Pointer;
  PFN_CRYPT_GET_SIGNER_CERTIFICATE = type Pointer;

  CRYPT_VERIFY_MESSAGE_PARA = Record
    cbSize: DWORD;
    dwMsgAndCertEncodingType: DWORD;
    hCryptProv: HCRYPTPROV_LEGACY;
    pfnGetSignerCertificate: PFN_CRYPT_GET_SIGNER_CERTIFICATE;
    pvGetArg: Pointer;
  end;

Function CryptVerifyMessageSignature(const pVerifyPara: CRYPT_VERIFY_MESSAGE_PARA; dwSignerIndex: DWORD; pbSignedBlob: PByte; cbSignedBlob: DWORD; pbDecoded: PBYTE; pcbDecoded: PDWORD; ppSignerCert: PCCERT_CONTEXT): BOOL; stdcall; external 'Crypt32.dll';
Function CertGetNameStringW(pCertContext:PCCERT_CONTEXT; dwType:DWORD; dwFlags:DWORD; pvTypePara:Pointer; pszNameString:PWideChar; cchNameString:DWORD): DWORD; stdcall; external 'Crypt32.dll';
Function CertFreeCertificateContext(pCertContext: PCCERT_CONTEXT): BOOL; stdcall; external 'Crypt32.dll';
Function CertCreateCertificateContext(dwCertEncodingType: DWORD; pbCertEncoded: PBYTE; cbCertEncoded: DWORD): PCCERT_CONTEXT; stdcall; external 'Crypt32.dll';

// WinTrust.dll
const
  WINTRUST_ACTION_GENERIC_VERIFY_V2: TGUID = '{00AAC56B-CD44-11d0-8CC2-00C04FC295EE}';
  WTD_CHOICE_FILE = 1;
  WTD_REVOKE_NONE = 0;
  WTD_UI_NONE = 2;

  WTD_REVOKE_WHOLECHAIN = $1;
  WTD_REVOCATION_CHECK_CHAIN = $40;
  WTD_LIFETIME_SIGNING_FLAG = $800;
  WTD_DISABLE_MD2_MD4 = $2000;

Type
  PWinTrustFileInfo = ^TWinTrustFileInfo;
  TWinTrustFileInfo = Record
    cbStruct: DWORD;                    // = sizeof(WINTRUST_FILE_INFO)
    pcwszFilePath: PWideChar;           // required, file name to be verified
    hFile: THandle;                     // optional, open handle to pcwszFilePath
    pgKnownSubject: PGUID;              // optional: fill if the subject type is known
  end;

  PWinTrustData = ^TWinTrustData;
  TWinTrustData = Record
    cbStruct: DWORD;
    pPolicyCallbackData: Pointer;
    pSIPClientData: Pointer;
    dwUIChoice: DWORD;
    fdwRevocationChecks: DWORD;
    dwUnionChoice: DWORD;
    pFile: PWinTrustFileInfo;
    dwStateAction: DWORD;
    hWVTStateData: THandle;
    pwszURLReference: PWideChar;
    dwProvFlags: DWORD;
    dwUIContext: DWORD;
  end;

Function WinVerifyTrust(hwnd: HWND; const ActionID: TGUID; ActionData: Pointer): Longint; stdcall; external wintrust;

{-----------------------------------------------}

Function IsCodeSigned(AFileName:Widestring; AOptions:TCodeSigningOptionSet):Cardinal;
var
  file_info: TWinTrustFileInfo;
  trust_data: TWinTrustData;
begin
FillChar(file_info, SizeOf(file_info), 0);
file_info.cbStruct := sizeof(file_info);
file_info.pcwszFilePath := PWideChar(AFileName);
FillChar(trust_data, SizeOf(trust_data), 0);
trust_data.cbStruct := sizeof(trust_data);
trust_data.dwUIChoice := WTD_UI_NONE;
trust_data.fdwRevocationChecks := WTD_REVOKE_NONE;
If (csoCheckRevocations In AOptions) Then
  trust_data.fdwRevocationChecks := WTD_REVOKE_WHOLECHAIN;

  trust_data.dwUnionChoice := WTD_CHOICE_FILE;
trust_data.pFile := @file_info;
trust_data.dwProvFlags := 0;
If (csoCheckRevocations In AOptions) Then
  trust_data.dwProvFlags := (trust_data.dwProvFlags Or WTD_REVOCATION_CHECK_CHAIN);

If (csoNoLifeTimeTimeStamps In AOptions) Then
  trust_data.dwProvFlags := (trust_data.dwProvFlags Or WTD_LIFETIME_SIGNING_FLAG);

Result := WinVerifyTrust(INVALID_HANDLE_VALUE, WINTRUST_ACTION_GENERIC_VERIFY_V2, @trust_data);
end;

{-----------------------------------------------}

Function GetFileCertificateNames(AFilename:WideString; ACertNames:TStringList):Cardinal;
var
  I : Integer;
  hExe: THandle;
  Cert: PWinCertificate;
  CertContext: PCCERT_CONTEXT;
  CertCount: DWORD;
  CertName: WideString;
  CertNameLen: DWORD;
  VerifyParams: CRYPT_VERIFY_MESSAGE_PARA;
begin
Result := ERROR_SUCCESS;
hExe := CreateFileW(PWideChar(AFileName), GENERIC_READ, FILE_SHARE_READ, Nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_RANDOM_ACCESS, 0);
If hExe <> INVALID_HANDLE_VALUE Then
  begin
  Try
    If ImageEnumerateCertificates(hExe, CERT_SECTION_TYPE_ANY, CertCount, nil, 0) Then
      begin
      GetMem(Cert, SizeOf(TWinCertificate) + 3); // ImageGetCertificateHeader writes an DWORD at bCertificate for some reason
      For I := 0 To CertCount - 1 Do
        begin
        Try
          Cert.dwLength := 0;
          Cert.wRevision := WIN_CERT_REVISION_1_0;
          If ImageGetCertificateHeader(hExe, I, Cert^) Then
            begin
            ReallocMem(Cert, SizeOf(TWinCertificate) + Cert.dwLength);
            If ImageGetCertificateData(hExe, I, Cert, Cert.dwLength) Then
              begin
              FillChar(VerifyParams, SizeOf(VerifyParams), 0);
              VerifyParams.cbSize := SizeOf(VerifyParams);
              VerifyParams.dwMsgAndCertEncodingType := X509_ASN_ENCODING or PKCS_7_ASN_ENCODING;
              If CryptVerifyMessageSignature(VerifyParams, 0, @Cert.bCertificate, Cert.dwLength, Nil, Nil, @CertContext) Then
                begin
                Try
                  CertNameLen := CertGetNameStringW(CertContext, CERT_NAME_SIMPLE_DISPLAY_TYPE, 0, Nil, nil, 0);
                  SetLength(CertName, CertNameLen - 1);
                  CertGetNameStringW(CertContext, CERT_NAME_SIMPLE_DISPLAY_TYPE, 0, Nil, PWideChar(CertName), CertNameLen);
                  ACertNames.Add(CertName);
                Finally
                  CertFreeCertificateContext(CertContext)
                  end;
                end
              Else Result := GetLastError;
              end
            Else Result := GetLastError;
            end
          Else Result := GetLastError;
          Finally
            FreeMem(Cert);
            end;

        If Result <> ERROR_SUCCESS Then
          Break;
        end;
      end
    Else Result := GetLastError;
    Finally
      CloseHandle(hExe);
      end;
  end
Else Result := GetLastError;
end;


End.
