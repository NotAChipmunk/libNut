unit libNut.GDIPlus;

{$I libNut.Options.inc}

{$IF NOT DEFINED(MSWINDOWS)}
  {$MESSAGE FATAL 'Invalid platform'}
{$ENDIF}

interface

uses
  libNut.Types,
  libNut.Bitmaps,

  Winapi.Windows;

type
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

  {$REGION 'TBitmap32Helper'}
  TBitmap32Helper = class helper for TBitmap32
  public
    function LoadFromFile(const AFileName: String): Boolean;
    function SaveToFile  (const AFileName: String; const AMime: String = ''; const AQuality: Integer = -1): Boolean;
  end;
  {$ENDREGION}

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

implementation

uses
  libNut.Maths;

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

{$REGION 'TBitmap32Helper'}
function TBitmap32Helper.LoadFromFile;
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

function TBitmap32Helper.SaveToFile;
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

end.
