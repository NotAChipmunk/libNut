unit libNut.FileSystem;

{$I libNut.Options.inc}

{$IF NOT DEFINED(MSWINDOWS)}
  // TODO: Move everything to platform independant TPlatform members
  {$MESSAGE FATAL 'Invalid platform'}
{$ENDIF}

interface

uses
  Winapi.Windows;

{$REGION 'Path functions'}
const
  // Path and device separator
  PathSeparator      = '\';
  DeviceSeparator    = ':';
  ExtensionSeparator = '.';

function ExcludePathTrail(const APath: String): String;
function IncludePathTrail(const APath: String): String;

function GetFilePath        (const AFileName: String): String;
function GetFileName        (const AFileName: String; const ANoExtension: Boolean = False): String;
function GetFileExtension   (const AFileName: String): String;
function ChangeFileExtension(const AFileName, ANewExtension: String): String;

function AppFile(const AExtension: String): String; inline;
{$ENDREGION}

{$REGION 'FileSystem functions'}
function CreateDir (const APath: String): Boolean; inline;
function RemoveDir (const APath: String): Boolean; inline;
function CreatePath(const APath: String): Boolean;

function GetFileSize(const APath: String): Int64;

const
  faReadOnly  = 1;
  faHidden    = 2;
  faSysFile   = 4;
  faVolumeID  = 8;
  faDirectory = 16;
  faArchive   = 32;
  faAnyFile   = 63;

function GetFileAttributes(const AFileName: String): Integer; inline;
function SetFileAttributes(const AFileName: String; const AAttributes: Integer): Boolean; inline;

function CopyFile  (const ASource, ADest:     String): Boolean; inline;
function RenameFile(const AOldName, ANewName: String): Boolean; inline;
function DeleteFile(const AFileName:         String): Boolean; inline;

function NewerFile(const AFile1, AFile2: String; const ASameIsNewer: Boolean = False): Boolean;

function TouchFile(AFileName: String; ACreated: Boolean = False; AAccessed: Boolean = True; AModified: Boolean = True; ATimeHigh: Cardinal = 0; ATimeLow: Cardinal = 0): Boolean;

function FileSystemExists(const APath: String; const AAnyFile: Boolean = True; const AAttributes: Integer = faAnyFile): Boolean;
function PathExists      (const APath: String): Boolean; inline;
function FileExists      (const APath: String): Boolean; inline;
{$ENDREGION}

{$REGION 'TFileSystemEnum'}
type
  // File system enumeration
  TFileSystemEnum = class
  private
    function FindNextAttrMatch: Boolean;
  public
    Data:    TWin32FindData;
    Handle:  Cardinal;
    Attrs:   Cardinal;
    Done:    Boolean;
    AnyFile: Boolean;

    constructor Create(const APath: String; const AAttr: Cardinal; const AAnyFile: Boolean = False);
    destructor  Destroy; override;

    function Next: Boolean;
  end;
{$ENDREGION}

{$REGION 'File location functions'}
function ImageName: String;
function ImagePath: String; inline;

function WorkingPath: String;
function WindowsPath: String;
function SystemPath:  String;
function SystemRoot:  String; inline;

function ExpandPath(const APath: String): String;
{$ENDREGION}

implementation

uses
  libNut.Strings;

{$REGION 'Path functions'}
function ExcludePathTrail;
begin
  Result := APath;

  if (Result.Length > 1) and (APath[Result.Length] = PathSeparator) and (APath[Result.Length - 1] <> DeviceSeparator) then
    Result := Result.Copy(1, Result.Length - 1);
end;

function IncludePathTrail;
begin
  Result := APath;

  if Result.IsEmpty or (Result[Result.Length] <> PathSeparator) then
    Result := Result + PathSeparator;
end;

function GetFilePath;
var
  i: Integer;
begin
  for i := AFileName.Length downto 1 do
    if AFileName[i] = PathSeparator then
      Break;

  Result := AFileName.Copy(1, i);
end;

function GetFileName;
var
  i: Integer;
begin
  for i := AFileName.Length downto 1 do
    if AFileName[i] = PathSeparator then
      Break;

  Result := AFileName.Copy(i + 1);

  if ANoExtension then
    Result := Result.Copy(1, Result.Length - GetFileExtension(Result).Length);
end;

function GetFileExtension;
var
  i: Integer;
begin
  Result := GetFileName(AFileName);

  i := Result.Pos(ExtensionSeparator);

  if i = 0 then
    Result := ''
  else
    Result := Result.Copy(i);
end;

function ChangeFileExtension;
var
  i: Integer;
begin
  for i := AFileName.Length downto 1 do
    if AFileName[i] = ExtensionSeparator then
      Exit(AFileName.Copy(1, i - 1) + ANewExtension)
    else if AFileName[i] = PathSeparator then
      Break;

  Result := AFileName + ANewExtension;
end;

function AppFile;
begin
  Result := ChangeFileExtension(ParamStr(0), '.' + AExtension);
end;
{$ENDREGION}

{$REGION 'FileSystem functions'}
function CreateDir;
begin
  Result := CreateDirectory(PChar(APath), nil);
end;

function RemoveDir;
begin
  Result := RemoveDirectory(PChar(APath));
end;

function CreatePath;
  function CreatePathNext(var Path: String): Boolean;
  begin
    Path := ExcludePathTrail(Path);

    if (Path.Length < 3) or PathExists(Path) or (GetFilePath(Path) = Path) then
      Exit(True);

    Result := CreatePath(GetFilePath(Path)) and CreateDir(Path);
  end;
var
  BuildPath: String;
begin
  BuildPath := APath;
  Result := CreatePathNext(BuildPath);
end;

function GetFileSize;
begin
  with TFileSystemEnum.Create(APath, faArchive or faSysFile or faHidden or faReadOnly) do try
    if Done then
      Result := -1
    else
      Result := (Data.nFileSizeHigh shl 32) or Data.nFileSizeLow
  finally
    Free;
  end;
end;

function GetFileAttributes;
begin
  Result := Winapi.Windows.GetFileAttributes(PChar(AFileName));
end;

function SetFileAttributes;
begin
  Result := Winapi.Windows.SetFileAttributes(PChar(AFileName), AAttributes);
end;

function CopyFile;
begin
  Result := Winapi.Windows.CopyFile(PChar(ASource), PChar(ADest), False);
end;

function RenameFile;
begin
  Result := Winapi.Windows.MoveFile(PChar(AOldName), PChar(ANewName));
end;

function DeleteFile;
begin
  SetFileAttributes(AFileName, faArchive);
  Result := Winapi.Windows.DeleteFile(PChar(AFileName));
end;

function NewerFile;
  function GetWriteTime(FileName: String; var FileTime: TFileTime): Boolean;
  var
    Handle: THandle;
  begin
    Handle := CreateFile(PChar(FileName), 0, FILE_SHARE_READ {or FILE_SHARE_WRITE{}, nil, OPEN_EXISTING, 0, 0);

    if Handle = INVALID_HANDLE_VALUE then
      Exit(False);

    try
      Result := GetFileTime(Handle, nil, nil, @FileTime);
    finally
      CloseHandle(Handle);
    end;
  end;
var
  Time1: TFileTime;
  Time2: TFileTime;
  Comp:  Integer;
begin
  GetWriteTime(AFile1, Time1);
  GetWriteTime(AFile2, Time2);

  Comp := CompareFileTime(Time1, Time2);

  if Comp < 0 then
    Result := False
  else if Comp > 0 then
    Result := True
  else
    Result := ASameIsNewer;
end;

function TouchFile;
var
  Time:      TFileTime;
  PCreated:  PFileTime;
  PAccessed: PFileTime;
  PModified: PFileTime;
  Handle:    THandle;
begin
  if not FileSystemExists(AFileName) then
    Exit(False);

  Time.dwHighDateTime := ATimeHigh;
  Time.dwLowDateTime  := ATimeLow;

  if ACreated  then PCreated  := @Time else PCreated  := nil;
  if AAccessed then PAccessed := @Time else PAccessed := nil;
  if AModified then PModified := @Time else PModified := nil;

  Handle := CreateFile(PChar(AFileName), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if Handle = 0 then
    Exit(False);

  try
    Result := SetFileTime(Handle, PCreated, PAccessed, PModified);
  finally
    CloseHandle(Handle);
  end;
end;

function FileSystemExists;
begin
  with TFileSystemEnum.Create(APath, AAttributes, AAnyFile) do try
    Result := not Done;
  finally
    Free;
  end;
end;

function PathExists;
begin
  Result := FileSystemExists(APath, False, faDirectory or faArchive or faSysFile or faHidden or faReadOnly);
end;

function FileExists;
begin
  Result := FileSystemExists(APath, False, faArchive or faSysFile or faHidden or faReadOnly);
end;
{$ENDREGION}

{$REGION 'TFileSystemEnum'}
function TFileSystemEnum.FindNextAttrMatch;
begin
  while (Data.dwFileAttributes and Attrs <> 0) do
    if not FindNextFileW(Handle, Data) then
      Exit(False);

  Result := True;
end;

constructor TFileSystemEnum.Create;
begin
  inherited Create;

  Attrs := not AAttr and (faHidden or faSysFile or faVolumeID or faDirectory);
  AnyFile := AAnyFile;

  Handle := FindFirstFile(PChar(APath), Data);

  if Handle = INVALID_HANDLE_VALUE then
    Done := True
  else if AnyFile then
    Done := False
  else
    Done := not FindNextAttrMatch;
end;

destructor TFileSystemEnum.Destroy;
begin
  if Handle <> INVALID_HANDLE_VALUE then
    FindClose(Handle);

  inherited;
end;

function TFileSystemEnum.Next;
begin
  if FindNextFile(Handle, Data) then
  begin
    if AnyFile then
      Result := True
    else
      Result := FindNextAttrMatch;
  end
  else
    Result := False;

  Done := not Result;
end;
{$ENDREGION}

{$REGION 'File location functions'}
function ImageName;
begin
  Result.Length := MAX_PATH;
  Result.Length := GetModuleFileName(HInstance, PChar(Result), Result.Length);
end;

function ImagePath;
begin
  Result := GetFilePath(ImageName);
end;

function WorkingPath;
begin
  Result.Length := MAX_PATH;
  Result.Length := GetCurrentDirectory(Result.Length, PChar(Result));
  Result := IncludePathTrail(Result);
end;

function WindowsPath;
begin
  Result.Length := MAX_PATH;
  Result.Length := GetWindowsDirectory(PChar(Result), Result.Length);
  Result := IncludePathTrail(Result);
end;

function SystemPath;
begin
  Result.Length := MAX_PATH;
  Result.Length := GetSystemDirectory(PChar(Result), Result.Length);
  Result := IncludePathTrail(Result);
end;

function SystemRoot;
begin
  Result := SystemPath.Copy(1, 3);
end;

function ExpandPath;
var
  i, j:      Integer;
  LastDelim: Boolean;
  c:         Char;
  TempName:  String;
  UNC:       Boolean;
begin
  Result := '';
  if APath.IsEmpty then
    Exit;

  if APath[1] = '.' then
    TempName := WorkingPath + PathSeparator + APath
  else
    TempName := APath;

  // TempName := PathMacros.Expand(TempName);

  UNC := TempName.Copy(1, 2) = PathSeparator + PathSeparator;
  if UNC then
    TempName := TempName.Copy(2);

  i := 1; j := 1;
  LastDelim := False;

  while i <= TempName.Length do
  begin
    c := TempName[i];

    if c = PathSeparator then
    begin
      if j < i then
      begin
        if (i = 1) or (TempName[i - 1] <> PathSeparator) then
          Result := Result + TempName.Copy(j, i - j);

        j := i;

        LastDelim := True;
      end;
    end

    else if c = '.' then
    begin
      if LastDelim then
      begin
        if i < TempName.Length then
        begin
          if (TempName[i + 1] = '.') and ((i + 1 >= TempName.Length) or (TempName[i + 2] <> '.')) then
          begin
            if Result.Length > 1 then
              Result := GetFilePath(ExcludePathTrail(Result));

            j := i;
          end

          else if TempName[i + 1] = PathSeparator then
          begin
            Result := IncludePathTrail(Result);
            Inc(i);
            j := i + 1;
          end
          else
            LastDelim := False;
        end
        else
        begin
          Result := ExcludePathTrail(Result);
          j := i + 1;
        end;
      end;
    end
    else
      LastDelim := False;

    Inc(i);
  end;

  if (i - j > 1) or (TempName[i] <> PathSeparator) then
    Result := Result + TempName.Copy(j, i - j);

  if UNC then
    Result := PathSeparator + Result;
end;
{$ENDREGION}

end.
