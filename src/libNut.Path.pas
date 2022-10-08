unit libNut.Path;

{$I libNut.Options.inc}

interface

{$REGION 'Path\Name'}
const
  PathSeparator      = {$IF DEFINED(MSWINDOWS)}'\'{$ELSE}'/'{$ENDIF};
  DeviceSeparator    = ':';
  ExtensionSeparator = '.';

function ExcludePathTrail(const Path: String): String;
function IncludePathTrail(const Path: String): String;

function GetFilePath        (const FileName: String): String;
function GetFileName        (const FileName: String; const NoExtension: Boolean = False): String;
function GetFileExtension   (const FileName: String): String;
function ChangeFileExtension(const FileName, NewExtension: String): String;

function AppFile(const Extension: String): String; inline;
{$ENDREGION}

implementation

uses
  libNut.Strings;

{$REGION 'Path\Name'}
function ExcludePathTrail;
begin
  Result := Path;

  if (Path.LastChar = PathSeparator) and (Path[Result.Length - 1] <> DeviceSeparator) then
    Result := Result.Copy(1, Result.Length - 1);
end;

function IncludePathTrail;
begin
  Result := Path;

  if Result.LastChar <> PathSeparator then
    Result := Result + PathSeparator;
end;

function GetFilePath;
var
  i: Integer;
begin
  for i := FileName.Length downto 1 do
    if FileName[i] = PathSeparator then
      Break;

  Result := FileName.Copy(1, i);
end;

function GetFileName;
var
  i: Integer;
begin
  for i := FileName.Length downto 1 do
    if FileName[i] = PathSeparator then
      Break;

  Result := FileName.Copy(i + 1);

  if NoExtension then
    Result := Result.Copy(1, Result.Length - GetFileExtension(Result).Length);
end;

function GetFileExtension;
var
  i: Integer;
begin
  Result := GetFileName(FileName);

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
  for i := FileName.Length downto 1 do
    if FileName[i] = ExtensionSeparator then
      Exit(FileName.Copy(1, i - 1) + NewExtension)
    else if FileName[i] = PathSeparator then
      Break;

  Result := FileName + NewExtension;
end;

function AppFile;
begin
  Result := ChangeFileExtension(ParamStr(0), ExtensionSeparator + Extension);
end;
{$ENDREGION}

end.
