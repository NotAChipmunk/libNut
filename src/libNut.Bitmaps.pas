unit libNut.Bitmaps;

{$I libNut.Options.inc}

interface

uses
  libNut.Types;

type
  {$REGION 'TBitmapData'}
  TBitmapLockMode  = (Read, Write, UserBuffer);
  TBitmapLockModes = set of TBitmapLockMode;

  TBitmapData = packed record
    Width:    Integer;
    Height:   Integer;
    Stride:   Integer;
    Format:   Integer;
    Scan0:    Pointer;
    Reserved: Pointer;
    Size:     Cardinal;
    LockMode: TBitmapLockModes;
    LockX:    Cardinal;
    LockY:    Cardinal;
  end;
  {$ENDREGION}

  {$REGION 'TCustomBitmap'}
  TCustomBitmap<TPixel: record> = class abstract
  const
    IndexWidth  = 0;
    IndexHeight = 1;
  type
    PPixels = ^TPixels;
    TPixels = array[0..0] of TPixel;

    TBlockFill     = reference to procedure(ADest:          PPixels; const ALength, AStride: Integer; const APixel: TPixel);
    TBlockTransfer = reference to procedure(ADest, ASource: PPixels; const ALength, AStride, ASourceStride: Integer);
  protected
    FBitmapData: TBitmapData;

    function  InitMemory: Boolean; virtual;
    procedure InitScanlines;       virtual;
  private
    FScanLines: array of PPixels;

    FPixelVoid: TPixel;

    FBlockFill:     TBlockFill;
    FBlockTransfer: TBlockTransfer;

    function  GetDimention(const AIndex: Integer): Integer;
    procedure SetDimention(const AIndex, AValue: Integer);

    function GetScanline(const Y: Integer): PPixels;
  public
    constructor Create(const AWidth, AHeight: Integer);
    destructor  Destroy; override;

    function Lock  (var ABitmapData: TBitmapData; const X, Y, W, H: Integer; const ALockMode: TBitmapLockModes): Boolean; virtual;
    function Unlock(var ABitmapData: TBitmapData): Boolean; virtual;

    function Resize(const AWidth, AHeight: Integer): Boolean; virtual;

    procedure BasicBlockFill    (ADest:          PPixels; const ALength, AStride: Integer; const APixel: TPixel);
    procedure BasicBlockTransfer(ADest, ASource: PPixels; const ALength, AStride, ASourceStride: Integer);

    procedure Clear(const APixel: TPixel);

    function  GetPixel(const X, Y: Integer): TPixel;
    procedure SetPixel(const X, Y: Integer; const APixel: TPixel);
    property  Pixels  [const X, Y: Integer]: TPixel read GetPixel write SetPixel; default;

    function Sample(const U, V: Float): TPixel;

    procedure HLine(X, Y, ALength: Integer; const APixel: TPixel);
    procedure VLine(X, Y, ALength: Integer; const APixel: TPixel);

    procedure Line(X1, Y1, X2, Y2: Integer; const APixel: TPixel);

    procedure Bezier(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer; const APixel: TPixel; const ACount: Integer = 0);

    procedure Rectangle(X, Y, W, H: Integer; const APixel: TPixel; const AFill: Boolean = False);

    procedure Circle (CX, CY, R:      Integer; const APixel: TPixel; const AFill: Boolean = False);
    procedure Ellipse(CX, CY, RX, RY: Integer; const APixel: TPixel; const AFill: Boolean = False);

    procedure Triangle(X1, Y1, X2, Y2, X3, Y3: Integer; const APixel: TPixel; const AFill: Boolean = False);

    procedure Draw(const ABitmap: TCustomBitmap<TPixel>; const X, Y: Integer; const AFlipX: Boolean = False; const AFlipY: Boolean = False);

    property Width:  Integer index IndexWidth  read GetDimention write SetDimention;
    property Height: Integer index IndexHeight read GetDimention write SetDimention;

    property PixelVoid: TPixel read FPixelVoid write FPixelVoid;

    property BlockFill:     TBlockFill     read FBlockFill     write FBlockFill;
    property BlockTransfer: TBlockTransfer read FBlockTransfer write FBlockTransfer;

    property Bits:   Pointer read FBitmapData.Scan0;
    property Stride: Integer read FBitmapData.Stride;

    property Scanline[const Y: Integer]: PPixels read GetScanline;
  end;
  {$ENDREGION}

  {$REGION 'TSubBitmap'}
  TSubBitmap<TPixel: record> = class(TCustomBitmap<TPixel>)
  private
    FParent: TCustomBitmap<TPixel>;
  public
    constructor Create(const AParent: TCustomBitmap<TPixel>; const X, Y, W, H: Integer);
    destructor  Destroy; override;

    property Parent: TCustomBitmap<TPixel> read fParent;
  end;
  {$ENDREGION}

  {$REGION 'TBitmap'}
  TBitmap<TPixel: record> = class(TCustomBitmap<TPixel>)
  protected
    function InitMemory: Boolean; override;
  end;
  {$ENDREGION}

  {$REGION 'TRGBA32'}
  PRGBA32 = ^TRGBA32;
  TRGBA32 = record
  const
    Format = 2498570;
  public
    class function  Create(const R, G, B: Byte): TRGBA32; static;
    class property _Create[const R, G, B: Byte]: TRGBA32 read Create; default;

    class operator Implicit(AValue: TRGBA32): Cardinal; overload; inline;
    class operator Implicit(AValue: Cardinal): TRGBA32; overload; inline;

    function Alpha(const A: Byte = $FF): TRGBA32; inline;
  case Union of
    0: (Components: array[0..3] of Byte);
    1: (B, G, R, A: Byte);
    2: (ARGB:       Cardinal);
  end;
  {$ENDREGION}

  {$REGION 'TBitmap32'}
  TBitmap32 = class(TBitmap<TRGBA32>)
  public
    constructor Create(const AWidth, AHeight: Integer);

    procedure AlphaBlockFill    (ADest:          TBitmap32.PPixels; const ALength, AStride: Integer; const AColour: TRGBA32);
    procedure AlphaBlockTransfer(ADest, ASource: TBitmap32.PPixels; const ALength, AStride, ASourceStride: Integer);
  end;
  {$ENDREGION}

procedure AsmAlphaBlockFill    (ADest: Pointer;          const ALength, AStride: Integer; const AColour: Cardinal);
procedure AsmAlphaBlockTransfer(ADest, ASource: Pointer; const ALength, AStride, ASourceStride: Integer);

implementation

uses
  libNut.Maths;

{$REGION 'TCustomBitmap'}
function TCustomBitmap<TPixel>.InitMemory;
begin
  FBitmapData.Scan0 := nil;

  Result := True;
end;

procedure TCustomBitmap<TPixel>.InitScanlines;
begin
  SetLength(FScanlines, FBitmapData.Height);

  if FBitmapData.Height = 0 then
    Exit;

  FScanlines[0] := FBitmapData.Scan0;

  for var i := 1 to FBitmapData.Height - 1 do
    FScanlines[i] := PPixels(UIntPtr(FScanlines[i - 1]) + UIntPtr(FBitmapData.Stride));
end;

function TCustomBitmap<TPixel>.GetDimention;
begin
  case AIndex of
    IndexWidth:  Result := FBitmapData.Width;
    IndexHeight: Result := FBitmapData.Height;
  else
    Result := 0;
  end;
end;

procedure TCustomBitmap<TPixel>.SetDimention;
begin
  case AIndex of
    IndexWidth:  Resize(AValue,            FBitmapData.Height);
    IndexHeight: Resize(FBitmapData.Width, AValue);
  end;
end;

function TCustomBitmap<TPixel>.GetScanline;
begin
  if (Y < 0) or (Y >= FBitmapData.Height) then
    Result := nil
  else
    Result := FScanlines[Y];
end;

constructor TCustomBitmap<TPixel>.Create;
begin
  inherited Create;

  FBlockFill     := BasicBlockFill;
  FBlockTransfer := BasicBlockTransfer;

  Resize(AWidth, AHeight);
end;

destructor TCustomBitmap<TPixel>.Destroy;
begin
  Resize(0, 0);

  inherited;
end;

function TCustomBitmap<TPixel>.Lock;
var
  xx, yy: Int64;
  ww, hh: Int64;
  p1, p2: PByte;
begin
  FillChar(ABitmapData, 0, SizeOf(ABitmapData));

  if (X >= Integer(FBitmapData.Width)) or (Y >= Integer(FBitmapData.Height)) then
    Exit(False);

  xx := X; yy := Y;
  ww := W; hh := H;

  ClampDelta(xx, ww, 0, FBitmapData.Width);
  ClampDelta(yy, hh, 0, FBitmapData.Height);

  ABitmapData.Width    := ww;
  ABitmapData.Height   := hh;
  ABitmapData.LockMode := ALockMode;
  ABitmapData.LockX    := xx;
  ABitmapData.LockY    := yy;
  ABitmapData.Reserved := FBitmapData.Scan0;

  if TBitmapLockMode.UserBuffer in ALockMode then
  begin
    if {(FBitmapData.Format <> TPixel.Format) or} (Integer(ABitmapData.Width) <> ww) or (Integer(ABitmapData.Height) <> hh) then
      Exit(False);

    if TBitmapLockMode.Read in ALockMode then
    begin
      // TODO: Change to use BasicBlockTransfer

      p1 := Pointer(Integer(FScanlines[yy]) + (xx shl 2));
      p2 := Pointer(FBitmapData.Scan0);

      for var i := 0 to hh - 1 do
      begin
        Move(p1^, p2^, ww shl 2);

        Inc(p1, FBitmapData.Stride);
        Inc(p2, ABitmapData.Stride);
      end;
    end;
  end
  else
  begin
    ABitmapData.Stride := FBitmapData.Stride;
    ABitmapData.Scan0  := Pointer(Integer(FScanlines[yy]) + (xx shl 2));
    ABitmapData.Format := FBitmapData.Format;
  end;

  Result := True;
end;

function TCustomBitmap<TPixel>.Unlock;
var
  p1, p2: PByte;
begin
  Result := ABitmapData.Reserved = FBitmapData.Scan0;

  if not Result then
    Exit;

  if (TBitmapLockMode.UserBuffer in ABitmapData.LockMode) and (TBitmapLockMode.Write in ABitmapData.LockMode) then
  begin
    // MAYBE: Change to use BasicBlockTransfer
    p1 := Pointer(Integer(FScanlines[ABitmapData.LockX]) + Integer(ABitmapData.LockY shl 2));
    p2 := Pointer(ABitmapData.Scan0);

    for var i := 0 to ABitmapData.Height - 1 do
    begin
      Move(p2^, p1^, ABitmapData.Width shl 2);

      Inc(p1, FBitmapData.Stride);
      Inc(p2, ABitmapData.Stride);
    end;
  end;

  FillChar(ABitmapData, 0, SizeOf(ABitmapData));
end;

procedure TCustomBitmap<TPixel>.BasicBlockFill;
begin
  for var i := 0 to ALength - 1 do
  begin
    //ADest^[i * AStride] := APixel;
    ADest^[0] := APixel;
    ADest  := ADest + AStride;
  end;
end;

procedure TCustomBitmap<TPixel>.BasicBlockTransfer;
begin
  for var i := 0 to ALength - 1 do
  begin
    //ADest^[i * AStride] := ASource^[i * ASourceStride];
    ADest^  := ASource^;
    ADest   := ADest   + AStride;
    ASource := ASource + ASourceStride;
  end;
end;

function TCustomBitmap<TPixel>.Resize;
begin
  Result := True;

  FBitmapData.Width  := AWidth;
  FBitmapData.Height := AHeight;
  FBitmapData.Size   := FBitmapData.Stride * AHeight;

  Result := InitMemory;

  if Result then
    InitScanlines;
end;

procedure TCustomBitmap<TPixel>.Clear;
begin
  for var i := 0 to FBitmapData.Height - 1 do
    BasicBlockFill(FScanlines[i], FBitmapData.Width, 1, APixel);
end;

function TCustomBitmap<TPixel>.GetPixel;
begin
  if (X < 0) or (X >= FBitmapData.Width) or (Y < 0) or (Y >= FBitmapData.Height) then
    Result := FPixelVoid
  else
    Result := FScanlines[Y]^[X];
end;

procedure TCustomBitmap<TPixel>.SetPixel;
begin
  if (X < 0) or (X >= FBitmapData.Width) or (Y < 0) or (Y >= FBitmapData.Height) then
    Exit;

  if Assigned(FBlockFill) then
    FBlockFill(@FScanlines[Y]^[X], 1, 1, APixel)
  else
    FScanlines[Y]^[X] := APixel;
end;

function TCustomBitmap<TPixel>.Sample;
var
  IX: Integer;
  IY: Integer;
begin
  IX := Round(FBitmapData.Width  * Abs(Frac(U)));
  IY := Round(FBitmapData.Height * Abs(Frac(V)));

  GetPixel(IX, IY);
end;

procedure TCustomBitmap<TPixel>.HLine;
begin
  if (ALength <= 0) or (Y < 0) or (Y >= FBitmapData.Height) or (X >= FBitmapData.Width) then
    Exit;

  if X < 0 then
  begin
    ALength := ALength + X;
    X       := 0;
  end;

  if ALength<= 0 then
    Exit;

  if (X + ALength) >= FBitmapData.Width then
    ALength := FBitmapData.Width - X;

  BlockFill(@FScanlines[Y]^[X], ALength, 1, APixel);
end;

procedure TCustomBitmap<TPixel>.VLine;
begin
  if (ALength <= 0) or (X < 0) or (X >= FBitmapData.Width) or (Y >= FBitmapData.Height) then
    Exit;

  if Y < 0 then
  begin
    ALength := ALength + Y;
    Y       := 0;
  end;

  if ALength <= 0 then
    Exit;

  if (Y + ALength) >= FBitmapData.Height then
    ALength := FBitmapData.Height - Y;

  BlockFill(@FScanlines[Y]^[X], ALength, FBitmapData.Stride div SizeOf(TPixel), APixel);
end;

procedure TCustomBitmap<TPixel>.Line;
var
  DX, DY: Integer;
  SX, SY: Integer;
  E, ES:  Integer;
begin
  DX := Abs(X2 - X1);
  DY := Abs(Y2 - Y1);

  if X1 < X2 then SX := 1 else SX := -1;
  if Y1 < Y2 then SY := 1 else SY := -1;

  if DX > DY then E := DX else E := -DY;
  E := E div 2;

  repeat
    SetPixel(X1, Y1, APixel);

    if (X1 = X2) and (Y1 = Y2) then
      Break;

    ES := E;
    if ES > -DX then begin E := E - DY; X1 := X1 + SX; end;
    if ES <  DY then begin E := E + DX; Y1 := Y1 + SY; end;
  until False;
end;

procedure TCustomBitmap<TPixel>.Bezier;
var
  Resolution, T:  Float;
  XC, YC, SX, SY: Integer;
  C:              Integer;
  P1, P2, P3:     Float;
begin
  if ACount = 0 then
    C := 50
  else
    C := ACount;

  Resolution := 1 / C;

  SX := X1;
  SY := Y1;

  T := 0;

  while T < 1 do
  begin
    P1 := Pow(1 - T, 3);
    P2 := Pow(1 - T, 2);
    P3 := Pow(    T, 3);

    XC := Round(P1 * X1 + 3 * T * P2 * X2 + 3 * T * T * (1 - T) * X3 + P3 * X4);
    YC := Round(P1 * Y1 + 3 * T * P2 * Y2 + 3 * T * T * (1 - T) * Y3 + P3 * Y4);

    Line(SX, SY, XC, YC, APixel);

    SX := XC;
    SY := YC;

    T := T + Resolution;
  end;

  Line(SX, SY, X4, Y4, APixel);
end;

procedure TCustomBitmap<TPixel>.Rectangle;
begin
  if AFill then
    for var i := Y to Y + H - 1 do
      HLine(X, i, W, APixel)
  else
  begin
    HLine(X,         Y,         W, APixel);
    HLine(X,         Y + H - 1, W, APixel);
    VLine(X,         Y,         H, APixel);
    VLine(X + W - 1, Y,         H, APixel);
  end;
end;

procedure TCustomBitmap<TPixel>.Circle;
var
  X, Y, P: Integer;
begin
  X := 0;
  Y := R;
  P := 3 - 2 * R;

  while Y >= X do
  begin
    if AFill then
    begin
      HLine(CX - X, CY - Y, 1 + X * 2, APixel);
      HLine(CX - Y, CY - X, 1 + Y * 2, APixel);
      HLine(CX - X, CY + Y, 1 + X * 2, APixel);
      HLine(CX - Y, CY + X, 1 + Y * 2, APixel);
    end
    else
    begin
      SetPixel(CX - X, CY - Y, APixel);
      SetPixel(CX - Y, CY - X, APixel);
      SetPixel(CX + Y, CY - X, APixel);
      SetPixel(CX + X, CY - Y, APixel);
      SetPixel(CX - X, CY + Y, APixel);
      SetPixel(CX - Y, CY + X, APixel);
      SetPixel(CX + Y, CY + X, APixel);
      SetPixel(CX + X, CY + Y, APixel);
    end;

		if P < 0 then
    begin
      P := P + (4 * X) + 6;
      X := X + 1;
    end
    else
    begin
      P := P + 4 * (X - Y) + 10;
      X := X + 1;
      Y := Y - 1;
    end;
  end;
end;

procedure TCustomBitmap<TPixel>.Ellipse;
var
  XX, YY: Integer;
  X2:     Integer;
begin
  if (RX = 0) or (RY = 0) then
    Exit;

  if RY = 1 then
  begin
    HLine(CX, CY, 1 + RX, APixel);
    Exit;
  end;

  if RX = 1 then
  begin
    VLine(CX, CY, 1 + RY, APixel);
    Exit;
  end;

  XX := 0;

  if AFill then
  begin
    HLine(CX - RX, CY, 1 + (RX * 2), APixel);

    for YY := 0 to RY do
    begin
      XX := Round(RX / RY * Sqrt((Sqr(RY)) - Sqr(YY - 0.5)));

      HLine(CX - XX, CY + YY, 1 + (XX * 2), APixel);
      HLine(CX - XX, CY - YY, 1 + (XX * 2), APixel);
    end;
  end
  else
  begin
    X2 := RX;

    for YY := 0 to RY - 1 do
    begin
      XX := Round(RX / (RY - 1) * Sqrt(Sqr(RY - 1) - Sqr(YY - 0.5)));

      for var j := xx to x2 do
      begin
        SetPixel(CX + j, CY + YY, APixel);
        SetPixel(CX - j, CY + YY, APixel);
        SetPixel(CX + j, CY - YY, APixel);
        SetPixel(CX - j, CY - YY, APixel);
      end;

      X2 := XX;
    end;

    for var j := 0 to XX - 1 do
    begin
      SetPixel(CX + j, CY + RY, APixel);
      SetPixel(CX - j, CY + RY, APixel);
      SetPixel(CX + j, CY - RY, APixel);
      SetPixel(CX - j, CY - RY, APixel);
    end;
  end;
end;

procedure TCustomBitmap<TPixel>.Triangle;
var
 AX, BX:     Integer;
 XX, YY:     Integer;
 NY, XY:     Integer;
 P1, P2, P3: Integer;
 Q1, Q2, Q3: Integer;
begin
  if not AFill then
  begin
    Line(X1, Y1, X2, Y2, APixel);
    Line(X2, Y2, X3, Y3, APixel);
    Line(X3, Y3, X1, Y1, APixel);

    Exit;
  end;

  NY := y1; XY := y1;

  if Y2 < NY then NY := Y2;
  if Y2 > XY then XY := Y2;
  if Y3 < NY then NY := Y3;
  if Y3 > XY then XY := Y3;

  P1 := X1 - X3; Q1 := Y1 - Y3;
  P2 := X2 - X1; Q2 := Y2 - Y1;
  P3 := X3 - X2; Q3 := Y3 - Y2;

  for YY := NY to XY do
  begin
    AX := FBitmapData.Width;
    BX := -1;

    if (Y3 >= YY) or (Y1 >= YY) then
      if (Y3 <= yy) or (Y1 <= yy) then
        if not (Y3 = Y1) then
        begin
          XX := (YY - Y3) * P1 div Q1 + X3;

          if XX < AX then AX := XX;
          if XX > BX then BX := XX;
        end;

    if (Y1 >= YY) or (Y2 >= YY) then
      if (Y1 <= YY) or (Y2 <= YY) then
        if not (Y1 = Y2) then
        begin
          XX := (YY - Y1) * P2 div Q2 + X1;

          if XX < AX then AX := XX;
          if XX > BX then BX := XX;
        end;

    if (Y2 >= YY) or (Y3 >= YY) then
      if (Y2 <= YY) or (Y3 <= YY) then
        if not (Y2 = Y3) then
        begin
          XX := (YY - Y2) * P3 div Q3 + X2;

          if XX < AX then AX := XX;
          if XX > BX then BX := XX;
        end;

    if AX <= BX then
      HLine(AX, YY, BX - AX, APixel);
  end;
end;

procedure TCustomBitmap<TPixel>.Draw;
var
  Scan:       Integer;
  XX, YY:     Int64;
  WW, HH:     Int64;
  DX, DY:     Int64;
  DestData:   TBitmapData;
  SourceData: TBitmapData;
  PDest:      PByte;
  PSource:    PByte;
begin
  WW := ABitmap.Width;  XX := X;
  HH := ABitmap.Height; YY := Y;

  DX := ClampDelta(XX, WW, 0, Width);
  DY := ClampDelta(YY, HH, 0, Height);

  if not Lock(DestData, XX, YY, WW, HH, [TBitmapLockMode.Read, TBitmapLockMode.Write]) then
    Exit;

  try
    if not ABitmap.Lock(SourceData, DX, DY, WW, HH, [TBitmapLockMode.Read]) then
      Exit;

    try
      PDest := Pointer(DestData.Scan0);

      if AFlipY then
        PSource := Pointer(UIntPtr(SourceData.Scan0) + (UIntPtr(ABitmap.FBitmapData.Stride) * UIntPtr(ABitmap.Height - 1)))
      else
        PSource := Pointer(SourceData.Scan0);

      for Scan := 0 to HH - 1 do
      begin
        if AFlipX then
          FBlockTransfer(Pointer(PDest), Pointer(UIntPtr(PSource) + (UIntPtr(SourceData.Width - 1) * SizeOf(TPixel))), WW, 1, -1)
        else
          FBlockTransfer(Pointer(PDest), Pointer(PSource), WW, 1, 1);

        Inc(PDest, DestData.Stride);

        if AFlipY then
          Dec(PSource, SourceData.Stride)
        else
          Inc(PSource, SourceData.Stride);
      end;
    except
    end;

    ABitmap.Unlock(SourceData);
  finally
    Unlock(DestData);
  end;
end;
{$ENDREGION}

{$REGION 'TSubBitmap'}
constructor TSubBitmap<TPixel>.Create;
begin
  inherited Create(0, 0);

  FillChar(FBitmapData, SizeOf(FBitmapData), 0);

  if AParent.Lock(FBitmapData, X, Y, W, H, [TBitmapLockMode.Read, TBitmapLockMode.Write]) then
  begin
    FParent := AParent;
    Resize(FBitmapData.Width, FBitmapData.Height);
  end
  else
    FParent := nil;
end;

destructor TSubBitmap<TPixel>.Destroy;
begin
  if FParent <> nil then
    Parent.Unlock(FBitmapData);

  inherited;
end;
{$ENDREGION}

{$REGION 'TBitmap'}
function TBitmap<TPixel>.InitMemory;
begin
  if FBitmapData.Scan0 <> nil then
    FreeMem(FBitmapData.Scan0);

  if (FBitmapData.Width <> 0) and (FBitmapData.Height <> 0) then
  begin
    GetMem(FBitmapData.Scan0, (FBitmapData.Width * SizeOf(TPixel)) * FBitmapData.Height);

    if FBitmapData.Scan0 = nil then
      Exit(False);

    FBitmapData.Stride   := FBitmapData.Width * SizeOf(TPixel);
    FBitmapData.LockMode := [TBitmapLockMode.Read, TBitmapLockMode.Write];
  end;

  Result := True;
end;
{$ENDREGION}

{$REGION 'TRGBA32'}
class function TRGBA32.Create;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
  Result.A := $FF;
end;

class operator TRGBA32.Implicit(AValue: TRGBA32): Cardinal;
begin
  Result := AValue.ARGB;
end;

class operator TRGBA32.Implicit(AValue: Cardinal): TRGBA32;
begin
  Result.ARGB := AValue;
end;

function TRGBA32.Alpha;
begin
  Result := Self;
  Result.A := A;
end;
{$ENDREGION}

{$REGION 'TBitmap32'}
constructor TBitmap32.Create(const AWidth, AHeight: Integer);
begin
  inherited;

  BlockFill     := AlphaBlockFill;
  BlockTransfer := AlphaBlockTransfer;
end;

procedure TBitmap32.AlphaBlockFill;
begin
  AsmAlphaBlockFill(ADest, ALength, AStride * SizeOf(TRGBA32), AColour);
end;

procedure TBitmap32.AlphaBlockTransfer;
begin
  AsmAlphaBlockTransfer(ADest, ASource, ALength, AStride * SizeOf(TRGBA32), ASourceStride * SizeOf(TRGBA32));
end;
{$ENDREGION}

{$REGION 'AlphaBlockXXX'}
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

end.
