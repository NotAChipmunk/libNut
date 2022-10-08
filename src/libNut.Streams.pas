unit libNut.Streams;

{$I libNut.Options.inc}

// TODO: THandle stream platform independence

interface

uses
  libNut.Exceptions;

const
  CipherTableSize = 1023;

type
  TSeekOrigin = (FromBeginning, FromCurrent, FromEnd);

  EStream = class(TException);

  {$REGION 'TStream'}
  TStream = class abstract
  private
    FBytesRead:    Int64;
    FBytesWritten: Int64;

    FCipherKey:   Integer;
    FCipherTable: array[0..CipherTableSize] of Byte;

    procedure SetCipherKey(const AValue: Integer);
    procedure BlockCipher(var AData; const ASize, AIndex: Int64);

    function DoRead (var   AData; const ASize: Int64): Int64; virtual;
    function DoWrite(const AData; const ASize: Int64): Int64; virtual;

    function  GetSize: Int64;              virtual;
    procedure SetSize(const ASize: Int64); virtual;

    function  GetPosition: Int64;
    procedure SetPosition(const APosition: Int64);
  public
    constructor Create;

    function Seek(const AOffset: Int64; const AOrigin: TSeekOrigin = TSeekOrigin.FromBeginning): Int64; virtual;

    function Read (var   AData; const ASize: Int64): Int64;
    function Write(const AData; const ASize: Int64): Int64;

    function LoadFromStream(const AStream: TStream): Int64;
    function SaveToStream  (const AStream: TStream): Int64;

    procedure LoadFromFile(const AFileName: String; const APreservePosition: Boolean = True);
    procedure SaveToFile  (const AFileName: String; const APreservePosition: Boolean = True);

    property Size:     Int64 read GetSize     write SetSize;
    property Position: Int64 read GetPosition write SetPosition;

    property CipherKey: Integer read FCipherKey write SetCipherKey;

    property BytesRead:    Int64 read FBytesRead;
    property BytesWritten: Int64 read FBytesWritten;
  end;
  {$ENDREGION}

  {$REGION 'TMemoryStream'}
  TMemoryStream = class(TStream)
  private
    FData:     Pointer;
    FSize:     Int64;
    FPosition: Int64;

    FAutoExpand: Boolean;

    function DoRead (var   AData; const ASize: Int64): Int64; override;
    function DoWrite(const AData; const ASize: Int64): Int64; override;

    function  GetSize: Int64;              override;
    procedure SetSize(const ASize: Int64); override;

    function GetData(const AIndex: Int64): Pointer;
  public
    constructor Create(const ASize: Int64 = 0);
    destructor  Destroy; override;

    function Seek(const AOffset: Int64; const AOrigin: TSeekOrigin = TSeekOrigin.FromBeginning): Int64; override;

    property AutoExpand: Boolean read FAutoExpand write FAutoExpand;

    property Data[const AIndex: Int64]: Pointer read GetData; default;
  end;
  {$ENDREGION}

  TFileMode = (Read, ReadWrite, Create, Closed);

  {$REGION 'THandleStream'}
  {$IF DEFINED(MSWINDOWS)}
  THandleStream = class(TStream)
  private
    FHandle: THandle;

    FCloseOnFree: Boolean;

    function DoRead (var   AData; const ASize: Int64): Int64; override;
    function DoWrite(const AData; const ASize: Int64): Int64; override;
  public
    constructor Create(const AHandle: THandle); overload;
    constructor Create(const AFileName: String; const AFileMode: TFileMode = TFileMode.Read); overload;

    destructor Destroy; override;

    function Seek(const AOffset: Int64; const AOrigin: TSeekOrigin = TSeekOrigin.FromBeginning): Int64; override;

    property Handle: THandle read FHandle;

    property CloseOnFree: Boolean read FCloseOnFree write FCloseOnFree;
  end;
  {$ENDIF}
  {$ENDREGION}

  {$REGION 'TNativeFileStream'}
  TFile = file of Byte;

  TNativeFileStream = class(TStream)
  private
    FFile: TFile;

    function DoRead (var   AData; const ASize: Int64): Int64; override;
    function DoWrite(const AData; const ASize: Int64): Int64; override;
  public
    constructor Create(const AFileName: String; const AFileMode: TFileMode = TFileMode.Read);
    destructor  Destroy; override;

    function Seek(const AOffset: Int64; const AOrigin: TSeekOrigin = TSeekOrigin.FromBeginning): Int64; override;

    property &File: TFile read FFile;
  end;
  {$ENDREGION}

  {$IF DEFINED(MSWINDOWS)}
  TFileStream = THandleStream;
  {$ELSE}
  TFileStream = TNativeFileStream;
  {$ENDIF}

{$REGION 'String helpers'}
const
  UnicodeMarker16BE: Word = $FEFF;
  UnicodeMarker16LE: Word = $FFFE;
  UnicodeMarker8BOM: Word = $BBEF;

function LoadString(const AStream:   TStream): String; overload;
function LoadString(const AFileName: String):  String; overload;

function SaveString(const AString: String; const AStream:   TStream; AUnicode: Boolean = True): Int64; overload;
function SaveString(const AString: String; const AFileName: String;  AUnicode: Boolean = True): Int64; overload;
{$ENDREGION}

implementation

uses
  {$IF DEFINED(MSWINDOWS)}
  Winapi.Windows,
  {$ENDIF}

  libNut.Types.Convert,
  libNut.Random;

{$REGION 'TStream'}
procedure TStream.SetCipherKey;
var
  r: TRandom;
begin
  FCipherKey := AValue;
  r.Seed := FCipherKey;

  for var i := 0 to CipherTableSize do
    FCipherTable[i] := Round($FF * r.Next);
end;

procedure TStream.BlockCipher(var AData; const ASize, AIndex: Int64);
begin
  var p: PByte := @AData;

  for var i := 0 to ASize do
  begin
    p^ := p^ xor FCipherTable[(AIndex + i) mod CipherTableSize];
    Inc(p);
  end;
end;

function TStream.DoRead;
begin
  Result := 0;
end;

function TStream.DoWrite;
begin
  Result := 0;
end;

function TStream.GetSize;
begin
  var SavedPos := Position;

  try
    Seek(0, TSeekOrigin.FromEnd);

    Result := Position;
  finally
    Position := SavedPos;
  end;
end;

procedure TStream.SetSize;
begin
  {}
end;

function TStream.GetPosition;
begin
  Result := Seek(0, TSeekOrigin.FromCurrent);
end;

procedure TStream.SetPosition;
begin
  Seek(APosition, TSeekOrigin.FromBeginning);
end;

constructor TStream.Create;
begin
  inherited;

  FBytesRead    := 0;
  FBytesWritten := 0;

  FCipherKey := 0;
end;

function TStream.Seek;
begin
  Result := 0;
end;

function TStream.Read(var AData; const ASize: Int64): Int64;
begin
  var CipherIndex := Position;

  Result := DoRead(AData, ASize);

  if Result > 0 then
  begin
    //InterlockedCompareExchange64(FBytesRead, FBytesRead + Result, FBytesRead);
    Inc(FBytesRead, Result);

    if FCipherKey <> 0 then
      BlockCipher(AData, ASize, CipherIndex);
  end;
end;

function TStream.Write(const AData; const ASize: Int64): Int64;
var
  Buffer: array of Byte;
begin
  if FCipherKey <> 0 then
  begin
    SetLength(Buffer, ASize);
    Move(AData, Buffer[0], ASize);

    BlockCipher(Buffer[0], ASize, Position);

    Result := DoWrite(Buffer[0], ASize);
  end
  else
    Result := DoWrite(AData, ASize);

  if Result > 0 then
    //InterlockedCompareExchange64(FBytesWritten, FBytesWritten + Result, FBytesWritten);
    Inc(FBytesWritten, Result);
end;

function TStream.LoadFromStream;
begin
  Result := AStream.SaveToStream(Self);
end;

function TStream.SaveToStream;
const
  BufSize = 1023;
var
  Buffer:   array[0..BufSize] of Byte;
  BufRead:  Int64;
  BufWrite: Int64;
begin
  Result := 0;

  repeat
    BufRead := Read(Buffer[0], BufSize);

    if BufRead = 0 then
      Break;

    BufWrite := AStream.Write(Buffer[0], BufRead);
    Inc(Result, BufWrite);
  until BufRead <> BufWrite;
end;

procedure TStream.LoadFromFile;
var
  Stream:  TFileStream;
  SavePos: Int64;
begin
  Stream  := TFileStream.Create(AFileName, TFileMode.Read);
  SavePos := Position;

  try
    LoadFromStream(Stream);
  finally
    if APreservePosition then
      Position := SavePos;

    Stream.Free;
  end;
end;

procedure TStream.SaveToFile;
var
  Stream:  TFileStream;
  SavePos: Int64;
begin
  Stream  := TFileStream.Create(AFileName, TFileMode.Create);
  SavePos := Position;

  try
    SaveToStream(Stream);
  finally
    if APreservePosition then
      Position := SavePos;

    Stream.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TMemoryStream'}
function TMemoryStream.DoRead;
var
  p: Pointer;
begin
  if (FPosition + ASize) > FSize then
    Result := FSize - FPosition
  else
    Result := ASize;

  p := Pointer(Cardinal(FData) + FPosition);
  Move(p^, AData, Result);

  FPosition := FPosition + Result;

  if FPosition > FSize then
    FPosition := FSize;
end;

function TMemoryStream.DoWrite;
var
  p: Pointer;
begin
  if (FPosition + ASize) > FSize then
  begin
    if FAutoExpand then
    begin
      Size   := FPosition + ASize;
      Result := ASize;
    end
    else
      Result := FSize - FPosition;
  end
  else
    Result := ASize;

  p := Pointer(UIntPtr(FData) + UIntPtr(FPosition));
  Move(AData, p^, Result);

  FPosition := FPosition + Result;

  if FPosition > FSize then
    FPosition := FSize;
end;

function TMemoryStream.GetSize;
begin
  Result := FSize;
end;

procedure TMemoryStream.SetSize;
begin
  if ASize = 0 then
  begin
    if FData <> nil then
      FreeMem(FData);

    FData := nil;
    FSize := 0;
  end
  else
  begin
    if FData = nil then
      GetMem(FData, ASize)
    else
      ReallocMem(FData, ASize);

    FSize := ASize;
  end;

  Seek(0, TSeekOrigin.FromCurrent);
end;

function TMemoryStream.GetData;
begin
  if FSize = 0 then
    Exit(nil);

  Result := Pointer(UIntPtr(FData) + UIntPtr(AIndex));
end;

constructor TMemoryStream.Create;
begin
  inherited Create;

  FData       := nil;
  FPosition   := 0;
  FAutoExpand := True;

  SetSize(ASize);
end;

destructor TMemoryStream.Destroy;
begin
  SetSize(0);

  inherited;
end;

function TMemoryStream.Seek;
begin
  case AOrigin of
    TSeekOrigin.FromBeginning: FPosition := AOffset;
    TSeekOrigin.FromCurrent:   FPosition := FPosition + AOffset;
    TSeekOrigin.FromEnd:       FPosition := FSize - AOffset;
  end;

  if FPosition < 0 then
    FPosition := 0
  else if FPosition > FSize then
    FPosition := FSize;

  Result := FPosition;
end;
{$ENDREGION}

{$REGION 'THandleStream'}
{$IF DEFINED(MSWINDOWS)}
function THandleStream.DoRead;
var
  i: Cardinal;
begin
  ReadFile(FHandle, AData, ASize, i, nil);
  Result := i;
end;

function THandleStream.DoWrite;
var
  i: Cardinal;
begin
  WriteFile(FHandle, AData, ASize, i, nil);
  Result := i;
end;

constructor THandleStream.Create(const AHandle: THandle);
begin
  inherited Create;

  FHandle      := AHandle;
  FCloseOnFree := False;
end;

constructor THandleStream.Create(const AFileName: String; const AFileMode: TFileMode = TFileMode.Read);
var
  am: LongWord;
  sm: LongWord;
  cm: LongWord;
begin
  inherited Create;

  case AFileMode of
    TFileMode.ReadWrite:
    begin
      am := GENERIC_READ or GENERIC_WRITE;
      sm := FILE_SHARE_READ;
      cm := OPEN_ALWAYS;
    end;

    TFileMode.Create:
    begin
      am := GENERIC_READ or GENERIC_WRITE;
      sm := FILE_SHARE_READ;
      cm := CREATE_ALWAYS;
    end;
  else
    am := GENERIC_READ;
    sm := FILE_SHARE_READ or FILE_SHARE_WRITE;
    cm := OPEN_EXISTING;
  end;

  FHandle := CreateFile(PWideChar(AFileName), am, sm,  nil, cm, FILE_ATTRIBUTE_NORMAL, 0);

  FCloseOnFree := True;

  if FHandle = INVALID_HANDLE_VALUE then
    raise EStream.Create('Failed to create stream "' + AFileName + '"');
end;

destructor THandleStream.Destroy;
begin
  if FCloseOnFree then
    CloseHandle(FHandle);

  inherited;
end;

function THandleStream.Seek;
var
  PosLow:  Cardinal;
  PosHigh: Cardinal;
begin
  PosLow  :=  AOffset         and $FFFFFFFF;
  PosHigh := (AOffset shr 32) and $FFFFFFFF;

  Result := SetFilePointer(FHandle, PosLow, @PosHigh, Ord(AOrigin));
  Result := Result or (PosHigh shl 32);
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TNativeFileStream'}
function TNativeFileStream.DoRead;
var
  i: Integer;
begin
  System.BlockRead(FFile, AData, ASize, i);
  Result := i;
end;

function TNativeFileStream.DoWrite;
var
  i: Integer;
begin
  System.BlockWrite(FFile, AData, ASize, i);
  Result := i;
end;

constructor TNativeFileStream.Create;
begin
  inherited Create;

  System.AssignFile(FFile, AFileName);

  case AFileMode of
    TFileMode.Create: Rewrite(FFile);
    TFileMode.Closed: raise EStream.Create('Invalid file mode');
  else
    Reset(FFile);
  end;

  Seek(0);
end;

destructor TNativeFileStream.Destroy;
begin
  System.CloseFile(FFile);

  inherited;
end;

function TNativeFileStream.Seek;
begin
  case AOrigin of
    TSeekOrigin.FromBeginning: System.Seek(FFile, AOffset);
    TSeekOrigin.FromCurrent:   System.Seek(FFile, System.FilePos (FFile) + AOffset);
    TSeekOrigin.FromEnd:       System.Seek(FFile, System.FileSize(FFile) - AOffset);
  end;

  Result := FilePos(FFile);
end;
{$ENDREGION}

{$REGION 'String helpers'}
function LoadString(const AStream: TStream): String;
var
  Pos, Len:  Int64;
  Encoding:  Word;
  EncodeLen: Integer;

  AnsiBuff: AnsiString;
  UTF8Buff: UTF8String;

  P: PWideChar;
begin
  if not Assigned(AStream) then
    Exit('');

  Pos := AStream.Position;
  Len := AStream.Size - Pos;

  EncodeLen := AStream.Read(Encoding, 2);

  if (EncodeLen = 2) and ((Encoding = UnicodeMarker16BE) or (Encoding = UnicodeMarker16LE)) then
  begin
    Dec(Len, 2);

    SetLength(Result, Len div SizeOf(WideChar));
    if AStream.Read(Result[1], Len) = 0 then
      Exit('');

    if Encoding = UnicodeMarker16LE then
    begin
      Result := Result + #0;
      P := @Result[1];

      while P^ <> #0 do
      begin
        P^ := WideChar(System.Swap(Word(P^)));
        Inc(P);
      end;

      Result := System.Copy(Result, 1, System.Length(Result) - 1);
    end;
  end
  else if (EncodeLen = 2) and (Encoding = UnicodeMarker8BOM) then
  begin
    Len := Len - 3;

    if Len <= 0 then
      Exit('');

    AStream.Seek(1, TSeekOrigin.FromCurrent);

    System.SetLength(UTF8Buff, Len div SizeOf(UTF8Char));

    if (AStream.Read(UTF8Buff[1], Len) div SizeOf(UTF8Char)) = 0 then
      Exit('');

    Result := WideString(UTF8Buff);
  end
  else
  begin
    System.SetLength(AnsiBuff, Len div SizeOf(AnsiChar));

    if EncodeLen = 1 then
      AnsiBuff[1] := AnsiChar(Encoding and $FF)
    else if EncodeLen = 2 then
    begin
      AnsiBuff[1] := AnsiChar( Encoding        and $FF);
      AnsiBuff[2] := AnsiChar((Encoding shr 8) and $FF);
    end;

    if (AStream.Read(AnsiBuff[EncodeLen + 1], Len - EncodeLen) div SizeOf(AnsiChar)) = 0 then
      Exit('');

    Result := WideString(AnsiBuff);
  end;
end;

function LoadString(const AFileName: String): String;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, TFileMode.Read);

  try
    Result := LoadString(Stream);
  finally
    Stream.Free;
  end;
end;

function SaveString(const AString: String; const AStream: TStream; AUnicode: Boolean = True): Int64;
var
  Len:      Int64;
  AnsiBuff: AnsiString;
begin
  if not Assigned(AStream) then
    Exit(0);

  if AUnicode then
  begin
    if AStream.Write(UnicodeMarker16BE, 2) <> 2 then
      Exit(0);

    Len    := System.Length(AString) * SizeOf(WideChar);
    Result := AStream.Write(AString[1], Len);
  end
  else
  begin
    AnsiBuff := AnsiString(AString);
    Len      := System.Length(AnsiBuff) * SizeOf(AnsiChar);
    Result   := AStream.Write(AnsiBuff[1], Len);
  end;
end;

function SaveString(const AString: String; const AFileName: String; AUnicode: Boolean = True): Int64;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, TFileMode.Create);

  try
    Result := SaveString(AString, Stream, AUnicode);
  finally
    Stream.Free;
  end;
end;
{$ENDREGION}

end.
