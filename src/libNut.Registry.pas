unit libNut.Registry;

{$I libNut.Options.inc}

{$IF NOT DEFINED(MSWINDOWS)}
  {$MESSAGE FATAL 'Invalid platform'}
{$ENDIF}

interface

uses
  Winapi.Windows;

type
  {$REGION 'TRegistry'}
  TRegistry = class
  private
    FRoot:  HKEY;
    FPath:  String;
    FWow64: Boolean;

    FHandle: HKEY;

    FReadOnly: Boolean;

    procedure SetRoot (const ARoot: HKEY);   inline;
    procedure SetPath (const APath: String); inline;
    procedure SetWow64(const AWow64: Boolean); inline;
  public
    constructor Create(const ARoot: HKEY; const APath: String; const AReadOnly: Boolean = True; const AWow64: Boolean = False);
    destructor  Destroy; override;

    function  Open(const ARoot: HKEY; const APath: String; const AReadOnly: Boolean = True; const AWow64: Boolean = False): Boolean;
    procedure Close;

    function ReadPtr (const AKey: String; const APtr: Pointer; var   ASize: Cardinal): Cardinal;
    function WritePtr(const AKey: String; const APtr: Pointer; const ASize: Cardinal; const ADataType: Cardinal): Boolean;

    function Read(const AKey: String; const ADefault: String   = ''): String;   overload;
    function Read(const AKey: String; const ADefault: Cardinal = 0):  Cardinal; overload;

    function Write(const AKey: String; const AValue: String):   Boolean; overload; inline;
    function Write(const AKey: String; const AValue: Cardinal): Boolean; overload; inline;

    function Delete(const AKey: String): Boolean;

    class function ReadKey(const ARoot: HKEY; const APath, AKey: String; const ADefault: String   = ''): String;   overload;
    class function ReadKey(const ARoot: HKEY; const APath, AKey: String; const ADefault: Cardinal = 0):  Cardinal; overload;

    class function WriteKey(const ARoot: HKEY; const APath, AKey: String; const AValue: String):   Boolean; overload;
    class function WriteKey(const ARoot: HKEY; const APath, AKey: String; const AValue: Cardinal): Boolean; overload;

    class function DeleteKey(const ARoot: HKEY; const APath, AKey: String): Boolean;

    property Root:  HKEY    read FRoot  write SetRoot;
    property Path:  String  read FPath  write SetPath;
    property Wow64: Boolean read FWow64 write SetWow64;

    property Handle: HKEY read FHandle;

    property ReadOnly: Boolean read FReadOnly;
  end;
  {$ENDREGION}

implementation

{$REGION 'TRegistry'}
procedure TRegistry.SetRoot;
begin
  Open(ARoot, FPath, FReadOnly, FWow64);
end;

procedure TRegistry.SetPath;
begin
  Open(FRoot, APath, FReadOnly, FWow64);
end;

procedure TRegistry.SetWow64;
begin
  Open(FRoot, FPath, FReadOnly, AWow64);
end;

constructor TRegistry.Create;
begin
  inherited Create;

  FHandle   := REG_NONE;
  FReadOnly := True;

  Open(ARoot, APath, AReadOnly, AWow64);
end;

destructor TRegistry.Destroy;
begin
  Close;

  inherited;
end;

function TRegistry.Open;
var
  Flags: Cardinal;
begin
  Close;

  FRoot  := ARoot;
  FPath  := APath;
  FWow64 := AWow64;

  if AWow64 then
    Flags := KEY_WOW64_64KEY
  else
    Flags := 0;

  FReadOnly := AReadOnly;

  if FReadOnly then
    Result := RegOpenKeyEx(ARoot, PChar(APath), 0, Flags or KEY_READ, FHandle) = ERROR_SUCCESS
  else
  begin
    Result := RegCreateKeyEx(ARoot, PChar(APath), 0, nil, REG_OPTION_NON_VOLATILE, Flags or KEY_READ or KEY_WRITE, nil, FHandle, nil) = ERROR_SUCCESS;

    if not Result then
      Result := Open(ARoot, APath, True, AWow64);
  end;

  if not Result then
  begin
    FReadOnly := True;
    FHandle   := REG_NONE;
  end;
end;

procedure TRegistry.Close;
begin
  if FHandle <> REG_NONE then
    RegCloseKey(FHandle);

  FHandle := REG_NONE;

  FReadOnly := True;
end;

function TRegistry.ReadPtr;
begin
  if FHandle = REG_NONE then
    Exit(REG_NONE);

  if RegQueryValueEx(FHandle, PChar(AKey), nil, @Result, APtr, @ASize) <> ERROR_SUCCESS then
    Result := REG_NONE;
end;

function TRegistry.WritePtr;
begin
  if (FHandle = REG_NONE) or FReadOnly then
    Exit(False);

  Result := RegSetValueEx(FHandle, PChar(AKey), 0, ADataType, APtr, ASize) = ERROR_SUCCESS;
end;

function TRegistry.Read(const AKey: String; const ADefault: String = ''): String;
var
  Size: Cardinal;
begin
  Size := 1024;
  SetLength(Result, Size);

  case ReadPtr(AKey, PChar(Result), Size) of
    REG_SZ: SetLength(Result, Size - 1);

    REG_EXPAND_SZ:
    begin
      SetLength(Result, Size - 1);
      // TODO: Result := TEnvironment.Expand(Result);
    end;
  else
    Result := ADefault;
  end;
end;

function TRegistry.Read(const AKey: String; const ADefault: Cardinal = 0): Cardinal;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);

  if ReadPtr(AKey, @Result, Size) <> REG_DWORD then
    Result := ADefault;
end;

function TRegistry.Write(const AKey: String; const AValue: String): Boolean;
begin
  Result := WritePtr(AKey, PChar(AValue), Length(AValue), REG_SZ);
end;

function TRegistry.Write(const AKey: String; const AValue: Cardinal): Boolean;
begin
  Result := WritePtr(AKey, @AValue, SizeOf(AValue), REG_DWORD);
end;

function TRegistry.Delete;
begin
  if (FHandle = REG_NONE) or FReadOnly then
    Exit(False);

  Result := RegDeleteValue(FHandle, PChar(AKey)) = ERROR_SUCCESS;
end;

class function TRegistry.ReadKey(const ARoot: HKEY; const APath, AKey: String; const ADefault: String = ''): String;
begin
  with TRegistry.Create(ARoot, APath, True, False) do try
    if Handle = REG_NONE then
      Open(ARoot, APath, True, True);

    if Handle = REG_NONE then
      Exit(ADefault);

    Result := Read(AKey, ADefault);
  finally
    Free;
  end;
end;

class function TRegistry.ReadKey(const ARoot: HKEY; const APath, AKey: String; const ADefault: Cardinal = 0):  Cardinal;
begin
  with TRegistry.Create(ARoot, APath, True, False) do try
    if Handle = REG_NONE then
      Open(ARoot, APath, True, True);

    if Handle = REG_NONE then
      Exit(ADefault);

    Result := Read(AKey, ADefault);
  finally
    Free;
  end;
end;

class function TRegistry.WriteKey(const ARoot: HKEY; const APath, AKey: String; const AValue: String): Boolean;
begin
  with TRegistry.Create(ARoot, APath, False, False) do try
    if (Handle = REG_NONE) or ReadOnly then
      Open(ARoot, APath, False, True);

    if (Handle = REG_NONE) or ReadOnly then
      Exit(False);

    Result := Write(AKey, AValue);
  finally
    Free;
  end;
end;

class function TRegistry.WriteKey(const ARoot: HKEY; const APath, AKey: String; const AValue: Cardinal): Boolean;
begin
  with TRegistry.Create(ARoot, APath, False, False) do try
    if (Handle = REG_NONE) or ReadOnly then
      Open(ARoot, APath, False, True);

    if (Handle = REG_NONE) or ReadOnly then
      Exit(False);

    Result := Write(AKey, AValue);
  finally
    Free;
  end;
end;

class function TRegistry.DeleteKey;
begin
  with TRegistry.Create(ARoot, APath, False, False) do try
    if (Handle = REG_NONE) or ReadOnly then
      Open(ARoot, APath, False, True);

    if (Handle = REG_NONE) or ReadOnly then
      Exit(False);

    Result := Delete(AKey);
  finally
    Free;
  end;
end;
{$ENDREGION}

end.
