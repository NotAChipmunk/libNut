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

    TBlockFill     = reference to procedure(ADest:          PPixels; const ALength, AStride: Integer; const AColour: TPixel);
    TBlockTransfer = reference to procedure(ADest, ASource: PPixels; const ALength, AStride, ASourceStride: Integer);
  protected
    FBitmapData: TBitmapData;
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

    procedure BasicBlockFill    (ADest:          PPixels; const ALength, AStride: Integer; const AColour: TPixel);
    procedure BasicBlockTransfer(ADest, ASource: PPixels; const ALength, AStride, ASourceStride: Integer);

    procedure Clear(const AColour: TPixel);

    function  GetPixel(const X, Y: Integer): TPixel;
    procedure SetPixel(const X, Y: Integer; const AColour: TPixel);
    property  Pixels  [const X, Y: Integer]: TPixel read GetPixel write SetPixel; default;

    function Sample(const U, V: Float): TPixel;

    procedure HLine(X, Y, ALength: Integer; const AColour: TPixel);
    procedure VLine(X, Y, ALength: Integer; const AColour: TPixel);

    procedure Line(X1, Y1, X2, Y2: Integer; const AColour: TPixel);

    procedure Bezier(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer; const AColour: TPixel; const ACount: Integer = 0);

    procedure Box(X, Y, W, H: Integer; const AColour: TPixel; const AFill: Boolean = False);

    procedure Circle (CX, CY, R:      Integer; const AColour: TPixel; const AFill: Boolean = False);
    procedure Ellipse(CX, CY, RX, RY: Integer; const AColour: TPixel; const AFill: Boolean = False);

    procedure Triangle(X1, Y1, X2, Y2, X3, Y3: Integer; const AColour: TPixel; const AFill: Boolean = False);

    procedure Render(const ABitmap: TCustomBitmap<TPixel>; const X, Y: Integer; const AFlipX: Boolean = False; const AFlipY: Boolean = False);

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
  public
    function Resize(const AWidth, AHeight: Integer): Boolean; override;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Maths;

{$REGION 'TCustomBitmap'}
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
    // TODO: Change to use BasicBlockTransfer
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
    //ADest^[i * AStride] := AColour;
    ADest^[0] := AColour;
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

  SetLength(FScanlines, AHeight);

  if AHeight = 0 then
    Exit(False);

  FScanlines[0] := FBitmapData.Scan0;

  for var i := 1 to AHeight - 1 do
    FScanlines[i] := PPixels(UIntPtr(FScanlines[i - 1]) + UIntPtr(FBitmapData.Stride));
end;

procedure TCustomBitmap<TPixel>.Clear;
begin
  for var i := 0 to FBitmapData.Height - 1 do
    BasicBlockFill(FScanlines[i], FBitmapData.Width, 1, AColour);
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
    FBlockFill(@FScanlines[Y]^[X], 1, 1, AColour)
  else
    FScanlines[Y]^[X] := AColour;
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

  BlockFill(@FScanlines[Y]^[X], ALength, 1, AColour);
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

  BlockFill(@FScanlines[Y]^[X], ALength, FBitmapData.Stride div SizeOf(TPixel), AColour);
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
    SetPixel(X1, Y1, AColour);

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

    Line(SX, SY, XC, YC, AColour);

    SX := XC;
    SY := YC;

    T := T + Resolution;
  end;

  Line(SX, SY, X4, Y4, AColour);
end;

procedure TCustomBitmap<TPixel>.Box;
begin
  if AFill then
    for var i := Y to Y + H - 1 do
      HLine(X, i, W, AColour)
  else
  begin
    HLine(X,         Y,         W, AColour);
    HLine(X,         Y + H - 1, W, AColour);
    VLine(X,         Y,         H, AColour);
    VLine(X + W - 1, Y,         H, AColour);
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
			HLine(CX - X, CY - Y, 1 + X * 2, AColour);
			HLine(CX - Y, CY - X, 1 + Y * 2, AColour);
			HLine(CX - X, CY + Y, 1 + X * 2, AColour);
			HLine(CX - Y, CY + X, 1 + Y * 2, AColour);
    end
    else
    begin
			SetPixel(CX - X, CY - Y, AColour);
			SetPixel(CX - Y, CY - X, AColour);
			SetPixel(CX + Y, CY - X, AColour);
			SetPixel(CX + X, CY - Y, AColour);
			SetPixel(CX - X, CY + Y, AColour);
			SetPixel(CX - Y, CY + X, AColour);
			SetPixel(CX + Y, CY + X, AColour);
			SetPixel(CX + X, CY + Y, AColour);
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
    HLine(CX, CY, 1 + RX, AColour);
    Exit;
  end;

  if RX = 1 then
  begin
    VLine(CX, CY, 1 + RY, AColour);
    Exit;
  end;

  XX := 0;

  if AFill then
  begin
    HLine(CX - RX, CY, 1 + (RX * 2), AColour);

    for YY := 0 to RY do
    begin
      XX := Round(RX / RY * Sqrt((Sqr(RY)) - Sqr(YY - 0.5)));

      HLine(CX - XX, CY + YY, 1 + (XX * 2), AColour);
      HLine(CX - XX, CY - YY, 1 + (XX * 2), AColour);
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
        SetPixel(CX + j, CY + YY, AColour);
        SetPixel(CX - j, CY + YY, AColour);
        SetPixel(CX + j, CY - YY, AColour);
        SetPixel(CX - j, CY - YY, AColour);
      end;

      X2 := XX;
    end;

    for var j := 0 to XX - 1 do
    begin
      SetPixel(CX + j, CY + RY, AColour);
      SetPixel(CX - j, CY + RY, AColour);
      SetPixel(CX + j, CY - RY, AColour);
      SetPixel(CX - j, CY - RY, AColour);
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
    Line(X1, Y1, X2, Y2, AColour);
    Line(X2, Y2, X3, Y3, AColour);
    Line(X3, Y3, X1, Y1, AColour);

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
      HLine(AX, YY, BX - AX, AColour);
  end;
end;

procedure TCustomBitmap<TPixel>.Render;
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
function TBitmap<TPixel>.Resize;
begin
  if FBitmapData.Scan0 <> nil then
    FreeMem(FBitmapData.Scan0);

  FillChar(FBitmapData, SizeOf(FBitmapData), 0);

  if (AWidth <> 0) and (AHeight <> 0) then
  begin
    GetMem(FBitmapData.Scan0, (AWidth * SizeOf(TPixel)) * AHeight);

    if FBitmapData.Scan0 = nil then
    begin
      inherited Resize(0, 0);
      Exit(False);
    end;

    FBitmapData.Stride   := AWidth * SizeOf(TPixel);
    FBitmapData.LockMode := [TBitmapLockMode.Read, TBitmapLockMode.Write];
  end;

  Result := inherited Resize(AWidth, AHeight);
end;
{$ENDREGION}

end.
