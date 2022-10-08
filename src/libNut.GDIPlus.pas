unit libNut.GDIPlus;

{$I libNut.Options.inc}

interface

uses
  libNut.Types,
  libNut.Bitmaps,

  Winapi.Windows;

type
  {$REGION 'TPixel32'}
  PPixel32 = ^TPixel32;
  TPixel32 = record
  const
    Format = 2498570;
  public
    class function  Create(const R, G, B: Byte): TPixel32; static;
    class property _Create[const R, G, B: Byte]: TPixel32 read Create; default;

    class operator Implicit(AValue: TPixel32): Cardinal; overload; inline;
    class operator Implicit(AValue: Cardinal): TPixel32; overload; inline;

    function Alpha(const A: Byte = $FF): TPixel32; inline;
  case Union of
    0: (Components: array[0..3] of Byte);
    1: (B, G, R, A: Byte);
    2: (ARGB:       Cardinal);
  end;
  {$ENDREGION}

  {$REGION 'TBitmap32'}
  TBitmap32 = class(TCustomBitmap<TPixel32>)
  private
    FDC:     HDC;
    FHandle: HBITMAP;
    FInfo:   BITMAPINFO;
    FHeader: BITMAPINFOHEADER;

    function GetDC: HDC;
  public
    function Resize(const AWidth, AHeight: Integer): Boolean; override;

    procedure AlphaBlockFill    (ADest:          TBitmap32.PPixels; const ALength, AStride: Integer; const AColour: TPixel32);
    procedure AlphaBlockTransfer(ADest, ASource: TBitmap32.PPixels; const ALength, AStride, ASourceStride: Integer);

    procedure BltToDC(const ADC: HDC; const X: Integer = 0; const Y: Integer = 0; const W: Integer = 0; const H: Integer = 0);

    procedure CreateDC;
    procedure ReleaseDC;

    function LoadFromFile(const AFileName: String): Boolean; virtual;
    function SaveToFile  (const AFileName: String; const AMime: String = ''; const AQuality: Integer = -1): Boolean; virtual;

    property DC:     HDC     read GetDC;
    property Handle: HBITMAP read FHandle;
  end;
  {$ENDREGION}

  {$REGION 'Codec'}
  TEncoderParameter = packed record
    GUID:           TGUID;
    NumberOfValues: Cardinal;
    ParamType:      Cardinal;
    Value:          Pointer;
  end;

  PEncoderParameters = ^TEncoderParameters;
  TEncoderParameters = packed record
    Count: Cardinal;
    Param: array of TEncoderParameter;
  end;

  TImageCodecInfo = packed record
    CLSID:              TGUID;
    FormatID:           TGUID;
    CodecName:          PWideChar;
    DllName:            PWideChar;
    FormatDescription:  PWideChar;
    FilenameExtension:  PWideChar;
    MimeType:           PWideChar;
    Flags:              Cardinal;
    Version:            Cardinal;
    SigCount:           Cardinal;
    SigSize:            Cardinal;
    SigPattern:         PByte;
    SigMask:            PByte;
  end;

  PImageCodecInfos = ^TImageCodecInfos;
  TImageCodecInfos = array[0..255] of TImageCodecInfo;
  {$ENDREGION}

  TGDIPlusStartupInput = packed record
    Version: Cardinal;

    DebugCallback:            Pointer;
    SuppressBackgroundThread: LongBool;
    SuppressExternalCodecs:   LongBool;
  end;

  TGDIPlusObject = Pointer;

{$REGION 'API'}
const
  GDIPlus = 'GDIPlus.dll';

function  GdiplusStartup(out Token: LongWord; const Input: TGDIPlusStartupInput; Output: Pointer): Integer; stdcall; external GDIPlus;
procedure GdiplusShutdown(Token: LongWord); stdcall; external GDIPlus;

function GdipCreateBitmapFromScan0(Width, Height, Stride: Integer; Format: Integer; Scan0: Pointer; var Bitmap: TGDIPlusObject): Integer; stdcall; external GDIPlus;

function GdipLoadImageFromFile(const FileName: PWideChar; var Image: TGDIPlusObject): Integer; stdcall; external GDIPlus;
function GdipSaveImageToFile  (Image: TGDIPlusObject; const FileName: PWideChar; const CLSIDEncoder: TGUID; const Params: PEncoderParameters): Integer; stdcall; external GDIPlus;

function GdipGetImageEncodersSize(var NumEncoders, Size: LongWord): Integer; stdcall; external GDIPlus;
function GdipGetImageEncoders    (    NumEncoders, Size: LongWord; Encoders: PImageCodecInfos): Integer; stdcall; external GDIPlus;

function GdipDisposeImage(Image: TGDIPlusObject): Integer; stdcall; external GDIPlus;

function GdipGetImageWidth (Image: TGDIPlusObject; var Width:  Cardinal): Integer; stdcall; external GDIPlus;
function GdipGetImageHeight(Image: TGDIPlusObject; var Height: Cardinal): Integer; stdcall; external GDIPlus;

function GdipBitmapLockBits  (Bitmap: TGDIPlusObject; const Box: TRect; Flags: Cardinal; Format: Integer; var BitmapData: TBitmapData): Integer; stdcall; external GDIPlus;
function GdipBitmapUnlockBits(Bitmap: TGDIPlusObject; var BitmapData: TBitmapData): Integer; stdcall; external GDIPlus;
{$ENDREGION}

function InitializeGDIPlus: Boolean;

procedure AsmAlphaBlockFill    (ADest: Pointer;          const ALength, AStride: Integer; const AColour: Cardinal);
procedure AsmAlphaBlockTransfer(ADest, ASource: Pointer; const ALength, AStride, ASourceStride: Integer);

implementation

uses
  libNut.Maths;

{$REGION 'TPixel32'}
class function TPixel32.Create;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
  Result.A := $FF;
end;

class operator TPixel32.Implicit(AValue: TPixel32): Cardinal;
begin
  Result := AValue.ARGB;
end;

class operator TPixel32.Implicit(AValue: Cardinal): TPixel32;
begin
  Result.ARGB := AValue;
end;

function TPixel32.Alpha;
begin
  Result := Self;
  Result.A := A;
end;
{$ENDREGION}

{$REGION 'TBitmap32'}
function TBitmap32.GetDC;
begin
  if FDC = 0 then
    CreateDC;

  Result := FDC;
end;

function TBitmap32.Resize;
begin
  BlockFill     := AlphaBlockFill;
  BlockTransfer := AlphaBlockTransfer;

  if FHandle <> 0 then
    DeleteObject(FHandle);

  FHandle := 0;

  FillChar(FBitmapData, SizeOf(FBitmapData), 0);

  if (AWidth <> 0) and (AHeight <> 0) then
  begin
    with FHeader do
    begin
      biSize        := SizeOf(FHeader);
      biWidth       := AWidth;
      biHeight      := -AHeight;
      biPlanes      := 1;
      biBitCount    := 32;
      biCompression := BI_RGB;
    end;

    FInfo.bmiHeader := FHeader;

    FHandle := CreateDIBSection(0, FInfo, DIB_RGB_COLORS, Pointer(FBitmapData.Scan0), 0, 0);

    if FHandle = 0 then
    begin
      inherited Resize(0, 0);
      Exit(False);
    end;

    FBitmapData.Stride   := AWidth * 4;
    FBitmapData.LockMode := [TBitmapLockMode.Read, TBitmapLockMode.Write];
    FBitmapData.Format   := TPixel32.Format;
  end;

  Result := inherited Resize(AWidth, AHeight);
end;

procedure TBitmap32.AlphaBlockFill;
begin
  AsmAlphaBlockFill(ADest, ALength, AStride * SizeOf(TPixel32), AColour);
end;

procedure TBitmap32.AlphaBlockTransfer;
begin
  AsmAlphaBlockTransfer(ADest, ASource, ALength, AStride * SizeOf(TPixel32), ASourceStride * SizeOf(TPixel32));
end;

{$REGION 'Assembly'}
const
  AlphaBias = $00800080;

procedure AsmAlphaBlockFill(ADest: Pointer; const ALength, AStride: Integer; const AColour: Cardinal);
{$IF DEFINED(CPUX86)}
var
  c1, c2: UIntPtr;
begin
  if ALength = 0 then
    Exit;

  asm
    push ebx
    push edi

    mov edi, ADest

    mov  eax, AColour

    mov ecx, eax
    shr ecx, 24

    mov  ebx, eax
    and  eax, $00FF00FF
    and  ebx, $FF00FF00
    imul eax, ecx
    shr  ebx, 8
    imul ebx, ecx
    add  eax, AlphaBias
    and  eax, $FF00FF00
    shr  eax, 8
    add  ebx, AlphaBias
    and  ebx, $FF00FF00
    or   eax, ebx

    mov  c1, ecx
    mov  c2, eax

    mov ecx, ALength

  @1:
    push ecx

    mov  ecx, c1
    mov  eax, c2

    mov  edx, [edi]
    xor  ecx, $000000FF
    mov  ebx, edx
    and  edx, $00FF00FF
    and  ebx, $FF00FF00
    imul edx, ecx
    shr  ebx, 8
    imul ebx, ecx
    add  edx, AlphaBias
    and  edx, $FF00FF00
    shr  edx, 8
    add  ebx, AlphaBias
    and  ebx, $FF00FF00
    or   ebx, edx

    add eax, ebx

    mov [edi], eax

    pop ecx

    add edi, AStride

    dec ecx
    jnz @1

    pop edi
    pop ebx
  end;
end;
{$ELSEIF DEFINED(CPUX64)}
var
  c1, c2: UIntPtr;
asm
  push rbx
  push rdi

  mov rdi, ADest

  mov  eax, AColour

  mov ecx, eax
  shr ecx, 24

  mov  ebx, eax
  and  eax, $00FF00FF
  and  ebx, $FF00FF00
  imul eax, ecx
  shr  ebx, 8
  imul ebx, ecx
  add  eax, AlphaBias
  and  eax, $FF00FF00
  shr  eax, 8
  add  ebx, AlphaBias
  and  ebx, $FF00FF00
  or   eax, ebx

  mov  c1, ecx
  mov  c2, eax

  mov ecx, ACount

@1:
  push rcx

  mov  ecx, c1
  mov  eax, c2

  mov  edx, [edi]
  xor  ecx, $000000FF
  mov  ebx, edx
  and  edx, $00FF00FF
  and  ebx, $FF00FF00
  imul edx, ecx
  shr  ebx, 8
  imul ebx, ecx
  add  edx, AlphaBias
  and  edx, $FF00FF00
  shr  edx, 8
  add  ebx, AlphaBias
  and  ebx, $FF00FF00
  or   ebx, edx

  add eax, ebx

  mov [edi], eax

  pop rcx

  add edi, AStride

  dec ecx
  jnz @1

  pop rdi
  pop rbx
end;
{$ELSE}
begin
  {$MESSAGE WARNING 'Unsupported CPU. Don't use AlphaTransfers'}
end;
{$ENDIF}

procedure AsmAlphaBlockTransfer(ADest, ASource: Pointer; const ALength, AStride, ASourceStride: Integer);
{$IF DEFINED(CPUX86)}
asm
  test ecx, ecx
  js   @4

  push ebx
  push esi
  push edi

  mov esi, ASource
  mov edi, ADest

@1:
  mov  eax, [esi]

  test eax, $FF000000
  jz   @3

  push ecx

  mov ecx, eax
  shr ecx, 24

  cmp ecx, $FF
  jz  @2

  mov  ebx, eax
  and  eax, $00FF00FF
  and  ebx, $FF00FF00
  imul eax, ecx
  shr  ebx, 8
  imul ebx, ecx
  add  eax, AlphaBias
  and  eax, $FF00FF00
  shr  eax, 8
  add  ebx, AlphaBias
  and  ebx, $FF00FF00
  or   eax, ebx

  mov  edx, [edi]
  xor  ecx, $000000FF
  mov  ebx, edx
  and  edx, $00FF00FF
  and  ebx, $FF00FF00
  imul edx, ecx
  shr  ebx, 8
  imul ebx, ecx
  add  edx, AlphaBias
  and  edx, $FF00FF00
  shr  edx, 8
  add  ebx, AlphaBias
  and  ebx, $FF00FF00
  or   ebx, edx

  add eax, ebx
@2:
  mov [edi], eax

  pop ecx
@3:
  add esi, ASourceStride
  add edi, AStride

  dec ecx
  jnz @1

  pop edi
  pop esi
  pop ebx
@4:
end;
{$ELSEIF DEFINED(CPUX64)}
asm
  push rbx
  push rsi
  push rdi

  mov rsi, ASource
  mov rdi, ADest

  mov ecx, ACount
  test ecx, ecx
  js   @4

@1:
  push rcx

  mov  eax, [rsi]

  test eax, $FF000000
  jz   @3

  push rcx

  mov ecx, eax
  shr ecx, 24

  cmp ecx, $FF
  jz  @2

  mov  ebx, eax
  and  eax, $00FF00FF
  and  ebx, $FF00FF00
  imul eax, ecx
  shr  ebx, 8
  imul ebx, ecx
  add  eax, AlphaBias
  and  eax, $FF00FF00
  shr  eax, 8
  add  ebx, AlphaBias
  and  ebx, $FF00FF00
  or   eax, ebx

  mov  edx, [rdi]
  xor  ecx, $000000FF
  mov  ebx, edx
  and  edx, $00FF00FF
  and  ebx, $FF00FF00
  imul edx, ecx
  shr  ebx, 8
  imul ebx, ecx
  add  edx, AlphaBias
  and  edx, $FF00FF00
  shr  edx, 8
  add  ebx, AlphaBias
  and  ebx, $FF00FF00
  or   ebx, edx

  add eax, ebx
@2:
  mov [rdi], eax

  pop rcx
@3:
  add esi, ASourceStride
  add edi, AStride

  pop rcx
  dec ecx
  jnz @1

  pop rdi
  pop rsi
  pop rbx
@4:
end;
{$ELSE}
begin
  {$MESSAGE WARNING 'Unsupported CPU. Don't use AlphaTransfers'}
end;
{$ENDIF}
{$ENDREGION}

procedure TBitmap32.BltToDC;
begin
  //SetStretchBltMode(ADC, WinApi.Windows.HALFTONE);

  if (W = 0) or (H = 0) then
    SetDIBitsToDevice(ADC, X, Y, FBitmapData.Width, FBitmapData.Height, 0, 0, 0, FBitmapData.Height, FBitmapData.Scan0, FInfo, DIB_RGB_COLORS)
  else
    StretchDIBits(ADC, x, y, w, h, 0, 0, FBitmapData.Width, FBitmapData.Height, FBitmapData.Scan0, FInfo, DIB_RGB_COLORS, SRCCOPY);
end;

procedure TBitmap32.CreateDC;
var
  ScreenDC: HDC;
begin
  if FDC <> 0 then
    Exit;

  ScreenDC := Winapi.Windows.GetDC(0);

  try
    FDC := CreateCompatibleDC(ScreenDC);
    SelectObject(FDC, FHandle);
  finally
    Winapi.Windows.ReleaseDC(0, ScreenDC);
  end;
end;

procedure TBitmap32.ReleaseDC;
begin
  if FDC = 0 then
    Exit;

  Winapi.Windows.ReleaseDC(0, FDC);
  FDC := 0;
end;

function TBitmap32.LoadFromFile;
var
  Image:       TGDIPlusObject;
  ABitmapData: TBitmapData;
  w, h:        Cardinal;
begin
  Result := False;

  if not InitializeGDIPlus then
    Exit;

  Image := nil;

  if GdipLoadImageFromFile(@AFileName[1], Image) <> 0 then
    Exit;

  try
    GdipGetImageWidth (Image, w);
    GdipGetImageHeight(Image, h);

    if not Resize(w, h) then
      Exit;

    ABitmapData.Width  := w;
    ABitmapData.Height := h;
    ABitmapData.Stride := FBitmapData.Stride;
    ABitmapData.Scan0  := FBitmapData.Scan0;
    ABitmapData.Format := FBitmapData.Format;

    if GdipBitmapLockBits(Image, TRect.Create(0, 0, w, h), 5, FBitmapData.Format, ABitmapData) <> 0 then
      Exit;

    GdipBitmapUnlockBits(Image, ABitmapData);
  finally
    GdipDisposeImage(Image);
  end;

  Result := True;
end;

function TBitmap32.SaveToFile;
var
  Image:   TGDIPlusObject;
  Encoder: TGUID;
  Params:  TEncoderParameters;
  Num:     LongWord;
  Size:    LongWord;
  i:       Integer;
  Codec:   TImageCodecInfos;
  QParam:  LongWord;
begin
  Result := False;

  if not InitializeGDIPlus then
    Exit;

  GdipGetImageEncodersSize(Num, Size);

  if GDIPGetImageEncoders(Num, Size, @Codec) <> 0 then
    Exit;

  QParam := $FFFFFFFF;
  for i := 0 to Num - 1 do
    if String(Codec[i].MimeType) = AMime then
    begin
      Encoder := Codec[i].CLSID;
      QParam := i;

      Break;
    end;

  if QParam = $FFFFFFFF then
    Exit;

  SetLength(Params.Param, 1);

  if AQuality <> -1 then
  begin
    QParam := Clamp(AQuality, 0, 100);

    SetLength(Params.Param, 1);

    with Params, Param[0] do
    begin
      Count := 1;

      NumberOfValues := 1;
      ParamType      := 4;
      Value          := @QParam;
    end;
  end;

  if GdipCreateBitmapFromScan0(Width, Height, FBitmapData.Stride, FBitmapData.Format, FBitmapData.Scan0, Image) <> 0 then
    Exit;

  try
    if AQuality <> -1 then
      Result := GdipSaveImageToFile(Image, @AFileName[1], Encoder, @Params) = 0
    else
      Result := GdipSaveImageToFile(Image, @AFileName[1], Encoder, nil) = 0;
  finally
    GdipDisposeImage(Image);
  end;
end;
{$ENDREGION}

var
  GDIPlusToken: LongWord = 0;

function InitializeGDIPlus;
const
  StartupInput: TGDIPlusStartupInput = (Version:                  1;
                                        DebugCallback:            nil;
                                        SuppressBackgroundThread: False;
                                        SuppressExternalCodecs:   False);
begin
  if GDIPlusToken <> 0 then
    Exit(True);

  Result := GDIPlusStartup(GDIPlusToken, StartupInput, nil) = 0;
end;

end.
