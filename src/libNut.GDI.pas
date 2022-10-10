unit libNut.GDI;

{$I libNut.Options.inc}

{$IF NOT DEFINED(MSWINDOWS)}
  {$MESSAGE FATAL 'Invalid platform'}
{$ENDIF}

interface

uses
  libNut.Types,
  libNut.Exceptions,
  libNut.Bitmaps,

  Winapi.Windows;

type
  EGDI = class(TException);

  {$REGION 'TGDIObject'}
  TGDIObject = class
  private
    FHandle: HGDIOBJ;

    function GetHandle: HGDIOBJ;
  protected
    procedure Delete;   virtual;
    procedure Recreate; virtual;
  public
    constructor Create;
    destructor  Destroy; override;

    function Select(const ADC: HDC): HGDIOBJ; inline;

    property Handle: HGDIOBJ read GetHandle;
  end;
  {$ENDREGION}

  {$REGION 'TBrush'}
  TBrushStyle = (
    Solid         = BS_SOLID,
    Hollow        = BS_HOLLOW,
    Hatches       = BS_HATCHED,
    Pattern       = BS_PATTERN,
    Indexed       = BS_INDEXED,
    DIBPattern    = BS_DIBPATTERN,
    DIBPattenPT   = BS_DIBPATTERNPT,
    Pattern8x8    = BS_PATTERN8X8,
    DIBPattern8x8 = BS_DIBPATTERN8X8,
    MonoPattern   = BS_MONOPATTERN
  );

  TBrushHatch = (
    Horizontal    = HS_HORIZONTAL,
    Vetical       = HS_VERTICAL,
    Diagonal      = HS_FDIAGONAL,
    DiagonalBack  = HS_BDIAGONAL,
    Cross         = HS_CROSS,
    DiagonalCross = HS_DIAGCROSS
  );

  TBrush = class(TGDIObject)
  private
    FColour: TRGBA32;
    FStyle:  TBrushStyle;
    FHatch:  TBrushHatch;

    procedure SetColour(const AColour: TRGBA32);
    procedure SetStyle (const AStyle:  TBrushStyle);
    procedure SetHatch (const AHatch:  TBrushHatch);
  protected
    procedure Recreate; override;
  public
    constructor Create(const AColour: TRGBA32; const AStyle: TBrushStyle = TBrushStyle.Solid; const AHatch: TBrushHatch = TBrushHatch.DiagonalCross);

    property Colour: TRGBA32     read FColour write SetColour;
    property Style:  TBrushStyle read FStyle  write SetStyle;
    property Hatch:  TBrushHatch read FHatch  write SetHatch;
  end;
  {$ENDREGION}

  {$REGION 'TPen'}
  TPenStyle = (
    Solid      = PS_SOLID,
    Dash       = PS_DASH,
    Dot        = PS_DOT,
    DashDot    = PS_DASHDOT,
    DashDotDot = PS_DASHDOTDOT,
    Hollow     = PS_NULL,
    Frame      = PS_INSIDEFRAME,
    User       = PS_USERSTYLE,
    Alternate  = PS_ALTERNATE
  );

  TPenCap = (
    Round  = PS_ENDCAP_ROUND,
    Square = PS_ENDCAP_SQUARE,
    Flat   = PS_ENDCAP_FLAT
  );

  TPenJoint = (
    Round = PS_JOIN_ROUND,
    Bevel = PS_JOIN_BEVEL,
    Miter = PS_JOIN_MITER
  );

  TPen = class(TGDIObject)
  private
    FColour: TRGBA32;
    FWidth:  Integer;
    FHeight: Integer;
    FStyle:  TPenStyle;
    FCap:    TPenCap;
    FJoint:  TPenJoint;

    procedure SetColour(const AColour: TRGBA32);
    procedure SetWidth (const AWidth:  Integer);
    procedure SetHeight(const AHeight: Integer);
    procedure SetStyle (const AStyle:  TPenStyle);
    procedure SetCap   (const ACap:    TPenCap);
    procedure SetJoint (const AJoint:  TPenJoint);
  protected
    procedure Recreate; override;
  public
    constructor Create(const AColour: TRGBA32; const AWidth: Integer = 1; const AHeight: Integer = 1; const AStyle: TPenStyle = TPenStyle.Solid; const ACap: TPenCap = TPenCap.Round; const AJoint: TPenJoint = TPenJoint.Round);

    property Colour: TRGBA32   read FColour write SetColour;
    property Width:  Integer   read FWidth  write SetWidth;
    property Height: Integer   read FHeight write SetHeight;
    property Style:  TPenStyle read FStyle  write SetStyle;
    property Cap:    TPenCap   read FCap    write SetCap;
    property Joint:  TPenJoint read FJoint  write SetJoint;
  end;
  {$ENDREGION}

  {$REGION 'TFont'}
  // TODO: Font enums
  TFont = class(TGDIObject)
  private
    FName:           String;
    FWidth:          Integer;
    FHeight:         Integer;
    FEscapement:     Integer;
    FOrientation:    Integer;
    FWeight:         Integer;
    FCharSet:        Integer;
    FOutPrecision:   Integer;
    FClipPrecision:  Integer;
    FQuality:        Integer;
    FPitchAndFamily: Integer;
    FItalic:         Boolean;
    FUnderline:      Boolean;
    FStrikeOut:      Boolean;

    procedure SetName(const AName: String);

    procedure SetIntProp (const AIndex, AValue: Integer);
    procedure SetBoolProp(const AIndex: Integer; const AValue: Boolean);
  protected
    procedure Recreate; override;
  public
    constructor Create(const AName: String; const AHeight: Integer = 0; const AWeight: Integer = 0; const AItalic: Boolean = False; const AUnderline: Boolean = False);

    property Name: String read FName write SetName;

    property Width:          Integer index 0 read FWidth          write SetIntProp;
    property Height:         Integer index 1 read FHeight         write SetIntProp;
    property Escapement:     Integer index 2 read FEscapement     write SetIntProp;
    property Orientation:    Integer index 3 read FOrientation    write SetIntProp;
    property Weight:         Integer index 4 read FWeight         write SetIntProp;
    property CharSet:        Integer index 5 read FCharSet        write SetIntProp;
    property OutPrecision:   Integer index 6 read FOutPrecision   write SetIntProp;
    property ClipPrecision:  Integer index 7 read FClipPrecision  write SetIntProp;
    property Quality:        Integer index 8 read FQuality        write SetIntProp;
    property PitchAndFamily: Integer index 9 read FPitchAndFamily write SetIntProp;

    property Italic:    Boolean index 0 read FItalic    write SetBoolProp;
    property Underline: Boolean index 1 read FUnderline write SetBoolProp;
    property Strikeout: Boolean index 2 read FStrikeout write SetBoolProp;
  end;
  {$ENDREGION}

  {$REGION 'TCanvas'}
  // TODO: Everything! =D
  TCanvas = record helper for HDC
  public
    function Select(const AObject: TGDIObject): HGDIOBJ; overload; inline;
    function Select(const AObject: HGDIOBJ):    HGDIOBJ; overload; inline;
  end;
  {$ENDREGION}

  {$REGION 'TDIB'}
  TDIB = class(TBitmap32)
  protected
    function InitMemory: Boolean; override;
  private
    FDC:     HDC;
    FHandle: HBITMAP;
    FInfo:   BITMAPINFO;
    FHeader: BITMAPINFOHEADER;

    function GetDC: HDC;
  public
    procedure BltToDC(const ADC: HDC; const X: Integer = 0; const Y: Integer = 0; const W: Integer = 0; const H: Integer = 0);

    procedure CreateDC;
    procedure ReleaseDC;

    property DC:     HDC     read GetDC;
    property Handle: HBITMAP read FHandle;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Maths;

{$REGION 'TGDIObject'}
function TGDIObject.GetHandle;
begin
  if FHandle = 0 then
    Recreate;

  Result := FHandle;
end;

procedure TGDIObject.Delete;
begin
  if FHandle <> 0 then
    DeleteObject(FHandle);

  FHandle := 0;
end;

procedure TGDIObject.Recreate;
begin
  Delete;
end;

constructor TGDIObject.Create;
begin
  inherited;

  FHandle := 0;

  Recreate;
end;

destructor TGDIObject.Destroy;
begin
  Delete;

  inherited;
end;

function TGDIObject.Select;
begin
  Result := SelectObject(ADC, FHandle);
end;
{$ENDREGION}

{$REGION 'TBrush'}
procedure TBrush.SetColour;
begin
  FColour := AColour;
  Recreate;
end;

procedure TBrush.SetStyle;
begin
  FStyle := AStyle;
  Recreate;
end;

procedure TBrush.SetHatch;
begin
  FHatch := AHatch;
  Recreate;
end;

procedure TBrush.Recreate;
var
  LB: TLogBrush;
begin
  inherited;

  FillChar(LB, SizeOf(LB), 0);

  LB.lbStyle := Ord(FStyle);
  LB.lbColor := FColour;
  LB.lbHatch := Ord(FHatch);

  FHandle := CreateBrushIndirect(LB);

  if FHandle = 0 then
    raise EGDI.Create('Failed to create brush');
end;

constructor TBrush.Create;
begin
  FColour := AColour;
  FStyle  := AStyle;
  FHatch  := AHatch;

  inherited Create;
end;
{$ENDREGION}

{$REGION 'TPen'}
procedure TPen.SetColour;
begin
  FColour := AColour;
  Recreate;
end;

procedure TPen.SetWidth;
begin
  FWidth := AWidth;
  Recreate;
end;

procedure TPen.SetHeight;
begin
  FWidth := AHeight;
  Recreate;
end;

procedure TPen.SetStyle;
begin
  FStyle := AStyle;
  Recreate;
end;

procedure TPen.SetCap;
begin
  FCap := ACap;
  Recreate;
end;

procedure TPen.SetJoint;
begin
  FJoint := AJoint;
  Recreate;
end;

procedure TPen.Recreate;
var
  LP: TLogPen;
begin
  inherited;

  FillChar(LP, SizeOf(LP), 0);

  LP.lopnStyle   := Ord(FStyle) or Ord(FCap) or Ord(FJoint);
  LP.lopnWidth.X := FWidth;
  LP.lopnWidth.Y := FHeight;
  LP.lopnColor   := FColour;

  FHandle := CreatePenIndirect(LP);

  if FHandle = 0 then
    raise EGDI.Create('Failed to create pen');
end;

constructor TPen.Create;
begin
  FColour := AColour;
  FWidth  := AWidth;
  FHeight := AHeight;
  FStyle  := AStyle;
  FCap    := ACap;
  FJoint  := AJoint;

  inherited Create;
end;
{$ENDREGION}

{$REGION 'TFont'}
procedure TFont.SetName;
begin
  FName := AName;
  Recreate;
end;

procedure TFont.SetIntProp;
begin
  case AIndex of
    0: FWidth          := AValue;
    1: FHeight         := AValue;
    2: FEscapement     := AValue;
    3: FOrientation    := AValue;
    4: FWeight         := AValue;
    5: FCharSet        := AValue;
    6: FOutPrecision   := AValue;
    7: FClipPrecision  := AValue;
    8: FQuality        := AValue;
    9: FPitchAndFamily := AValue;
  else
    Exit;
  end;

  Recreate;
end;

procedure TFont.SetBoolProp;
begin
  case AIndex of
    0: FItalic    := AValue;
    1: FUnderline := AValue;
    2: FStrikeOut := AValue;
  else
    Exit;
  end;

  Recreate;
end;

procedure TFont.Recreate;
var
  LF: TLogFont;
begin
  inherited;

  FillChar(LF, SizeOf(LF), 0);

  for var i := 1 to Length(FName) do
  begin
    if i = High(LF.lfFaceName) then
      Break;

    LF.lfFaceName[i - 1] := FName[i];
  end;

  LF.lfWidth          := FWidth;
  LF.lfWidth          := FHeight;
  LF.lfEscapement     := FEscapement;
  LF.lfOrientation    := FOrientation;
  LF.lfWeight         := FWeight;
  LF.lfCharSet        := FCharSet;
  LF.lfOutPrecision   := FOutPrecision;
  LF.lfClipPrecision  := FClipPrecision;
  LF.lfQuality        := FQuality;
  LF.lfPitchAndFamily := FPitchAndFamily;
  LF.lfItalic         := Byte(FItalic);
  LF.lfUnderline      := Byte(FUnderline);
  LF.lfStrikeOut      := Byte(FStrikeOut);

  FHandle := CreateFontIndirect(LF);

  if FHandle = 0 then
    raise EGDI.Create('Failed to create font');
end;

constructor TFont.Create;
begin
  FName := AName;

  FWidth          := 0;
  FHeight         := AHeight;
  FEscapement     := 0;
  FOrientation    := 0;
  FWeight         := AWeight;
  FCharSet        := 0;
  FOutPrecision   := 0;
  FClipPrecision  := 0;
  FQuality        := 0;
  FPitchAndFamily := 0;

  FItalic    := AItalic;
  FUnderline := AUnderline;
  FStrikeOut := False;

  inherited Create;
end;
{$ENDREGION}

{$REGION 'TCanvas'}
function TCanvas.Select(const AObject: TGDIObject): HGDIOBJ;
begin
  Result := SelectObject(Self, AObject.Handle);
end;

function TCanvas.Select(const AObject: HGDIOBJ): HGDIOBJ;
begin
  Result := SelectObject(Self, AObject);
end;
{$ENDREGION}

{$REGION 'TDIB'}
function TDIB.InitMemory;
begin
  if FHandle <> 0 then
    DeleteObject(FHandle);

  FHandle := 0;

  if (FBitmapData.Width <> 0) and (FBitmapData.Height <> 0) then
  begin
    with FHeader do
    begin
      biSize        := SizeOf(FHeader);
      biWidth       := FBitmapData.Width;
      biHeight      := -FBitmapData.Height;
      biPlanes      := 1;
      biBitCount    := 32;
      biCompression := BI_RGB;
    end;

    FInfo.bmiHeader := FHeader;

    FHandle := CreateDIBSection(0, FInfo, DIB_RGB_COLORS, Pointer(FBitmapData.Scan0), 0, 0);

    if FHandle = 0 then
      Exit(False);

    FBitmapData.Stride   := FBitmapData.Width * 4;
    FBitmapData.LockMode := [TBitmapLockMode.Read, TBitmapLockMode.Write];
    FBitmapData.Format   := TRGBA32.Format;
  end;

  Result := True;
end;

function TDIB.GetDC;
begin
  if FDC = 0 then
    CreateDC;

  Result := FDC;
end;

procedure TDIB.BltToDC;
begin
  //SetStretchBltMode(ADC, WinApi.Windows.HALFTONE);

  if (W = 0) or (H = 0) then
    SetDIBitsToDevice(ADC, X, Y, FBitmapData.Width, FBitmapData.Height, 0, 0, 0, FBitmapData.Height, FBitmapData.Scan0, FInfo, DIB_RGB_COLORS)
  else
    StretchDIBits(ADC, x, y, w, h, 0, 0, FBitmapData.Width, FBitmapData.Height, FBitmapData.Scan0, FInfo, DIB_RGB_COLORS, SRCCOPY);
end;

procedure TDIB.CreateDC;
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

procedure TDIB.ReleaseDC;
begin
  if FDC = 0 then
    Exit;

  Winapi.Windows.ReleaseDC(0, FDC);
  FDC := 0;
end;
{$ENDREGION}

end.
