unit libNut.Maths.Geometry2D;

{$I libNut.Options.inc}

interface

uses
  libNut.Types,
  libNut.Maths,
  libNut.Vectors;

type
  {$REGION 'TPoint2D'}
  PPoint = ^TPoint2D;
  TPoint2D = record
  public
    {$REGION 'Consturctors'}
    class function  Create(const X, Y: Float): TPoint2D; static; inline;
    class property _Create[const X, Y: Float]: TPoint2D read Create; default;
    {$ENDREGION}

    {$REGION 'Implicit'}
    class operator Implicit(const AValue: Float):          TPoint2D;
    class operator Implicit(const AValue: array of Float): TPoint2D;
    {$ENDREGION}

    {$REGION 'Operators'}
    class operator Add(const ALeft: TPoint2D; const ARight: Float):          TPoint2D; overload; inline;
    class operator Add(const ALeft: TPoint2D; const ARight: TPoint2D):       TPoint2D; overload; inline;
    class operator Add(const ALeft: TPoint2D; const ARight: array of Float): TPoint2D; overload;

    class operator Subtract(const ALeft: TPoint2D; const ARight: Float):          TPoint2D; overload; inline;
    class operator Subtract(const ALeft: TPoint2D; const ARight: TPoint2D):       TPoint2D; overload; inline;
    class operator Subtract(const ALeft: TPoint2D; const ARight: array of Float): TPoint2D; overload;

    class operator Multiply(const ALeft: TPoint2D; const ARight: Float):          TPoint2D; overload; inline;
    class operator Multiply(const ALeft: TPoint2D; const ARight: TPoint2D):       TPoint2D; overload; inline;
    class operator Multiply(const ALeft: TPoint2D; const ARight: array of Float): TPoint2D; overload;

    class operator Divide(const ALeft: TPoint2D; const ARight: Float):          TPoint2D; overload; inline;
    class operator Divide(const ALeft: TPoint2D; const ARight: TPoint2D):       TPoint2D; overload; inline;
    class operator Divide(const ALeft: TPoint2D; const ARight: array of Float): TPoint2D; overload;

    class operator Negative(const ALeft: TPoint2D): TPoint2D;
    {$ENDREGION}

    {$REGION 'Methods'}
    function Round:     TPoint2D; inline;
    function Trunc:     TPoint2D; inline;
    function Ceil:      TPoint2D; inline;
    function Floor:     TPoint2D; inline;
    function CeilFloor: TPoint2D; inline;

    function Frac: TPoint2D; inline;

    function Abs: TPoint2D; inline;

    function DotProduct:                    Float; overload; inline;
    function DotProduct(const A: TPoint2D): Float; overload; inline;

    function CrossProduct:                    Float; overload; inline;
    function CrossProduct(const A: TPoint2D): Float; overload; inline;

    function Perp: TPoint2D;
    function PerpDotProduct(const A: TPoint2D): Float; inline;

    function Length:                       Float; overload; inline;
    function Length(const APos: TPoint2D): Float; overload; inline;

    function ApproxLength:                       Float; overload;
    function ApproxLength(const APos: TPoint2D): Float; overload; inline;

    function Reflect(const APos: TPoint2D): TPoint2D; inline;

    procedure Normalize; inline;
    function  Normalized: TPoint2D;

    function Lerp(const ATarget: TPoint2D; const APoint: Float): TPoint2D; inline;

    function Rotate(const ATheta: Float):                       TPoint2D; overload;
    function Rotate(const ATheta: Float; const APos: TPoint2D): TPoint2D; overload; inline;

    function Direction:                       Float; overload;
    function Direction(const APos: TPoint2D): Float; overload; inline;

    function CircleMap: TPoint2D;

    class function FromWord(const AWord: Word): TPoint2D; static;
    function ToWord: Word;
    {$ENDREGION}
  case Union of
    0: (Vector: TVector2f);
    1: (X, Y:   Float);
  end;
  {$ENDREGION}

  {$REGION 'TRectangle'}
  PRectangle = ^TRectangle;
  TRectangle = record
  private
    {$REGION 'Property methods'}
    function  GetWidth: Float;               inline;
    procedure SetWidth(const AWidth: Float); inline;

    function  GetHeight: Float;                inline;
    procedure SetHeight(const AHeight: Float); inline;

    function  GetPosition: TPoint2D;
    procedure SetPosition(const APosition: TPoint2D);

    function  GetCenter: TPoint2D;
    procedure SetCenter(const ACenter: TPoint2D);

    function  GetSize: TPoint2D;
    procedure SetSize(const ASize: TPoint2D);
    {$ENDREGION}
  public
    {$REGION 'Constructors'}
    class function  Create(const ALeft, ATop, AWidth, AHeight: Float): TRectangle; static;
    class property _Create[const ALeft, ATop, AWidth, AHeight: Float]: TRectangle read Create; default;
    {$ENDREGION}

    {$REGION 'Implicit'}
    class operator Implicit(const AValue: array of Float): TRectangle;
    {$ENDREGION}

    {$REGION 'Operators'}

    {$ENDREGION}

    {$REGION 'Methods'}
    function Round:     TRectangle; inline;
    function Trunc:     TRectangle; inline;
    function Ceil:      TRectangle; inline;
    function Floor:     TRectangle; inline;
    function CeilFloor: TRectangle; inline;

    procedure Normalize;
    function  Normalized: TRectangle; inline;
    {$ENDREGION}

    {$REGION 'Properties'}
    property Width:  Float read GetWidth  write SetWidth;
    property Height: Float read GetHeight write SetHeight;

    property Position: TPoint2D read GetPosition write SetPosition;
    property Center:   TPoint2D read GetCenter   write SetCenter;
    property Size:     TPoint2D read GetSize     write SetSize;
    {$ENDREGION}
  case Union of
    0: (Vector:                   TVector4f);
    1: (TopLeft, BottomRight:     TPoint2D);
    2: (Left, Top, Right, Bottom: Float);
  end;
  {$ENDREGION}

type
  {$REGION 'TPoint2DHelper'}
  TPoint2DHelper = record helper for TPoint2D
  const
    Zero:  TPoint2D = (Vector:(0, 0));
    Unity: TPoint2D = (Vector:(1, 1));

    Left:  TPoint2D = (Vector:(-1,  0));
    Up:    TPoint2D = (Vector:( 0, -1));
    Right: TPoint2D = (Vector:( 1,  0));
    Down:  TPoint2D = (Vector:( 0,  1));
  end;
  {$ENDREGION}

  {$REGION 'TRectangleHelper'}
  TRectangleHelper = record helper for TRectangle
  const
    Zero:  TRectangle = (Vector:(0, 0, 0, 0));
    Unity: TRectangle = (Vector:(0, 0, 1, 1));

    DefaultViewport: TRectangle = (Vector:(-1, -1, 1, 1));

    UnityC: TRectangle = (Vector:(-0.5, -0.5, 0.5, 0.5));
  end;
  {$ENDREGION}

implementation

{$REGION 'TPoint2D'}
{$REGION 'Constructors'}
class function TPoint2D.Create;
begin
  Result.X := X;
  Result.Y := Y;
end;
{$ENDREGION}

{$REGION 'Implicit'}
class operator TPoint2D.Implicit(const AValue: Float): TPoint2D;
begin
  Result.X := AValue;
  Result.Y := AValue;
end;

class operator TPoint2D.Implicit(const AValue: array of Float): TPoint2D;
begin
  for var i := 0 to 1 do
  begin
    if i < System.Length(AValue) then
      Result.Vector[i] := AValue[Low(AValue) + i]
    else
      Result.Vector[i] := 0;
  end;
end;
{$ENDREGION}

{$REGION 'Operators'}
class operator TPoint2D.Add(const ALeft: TPoint2D; const ARight: Float): TPoint2D;
begin
  Result.X := ALeft.X + ARight;
  Result.Y := ALeft.Y + ARight;
end;

class operator TPoint2D.Add(const ALeft: TPoint2D; const ARight: TPoint2D): TPoint2D;
begin
  Result.X := ALeft.X + ARight.X;
  Result.Y := ALeft.Y + ARight.Y;
end;

class operator TPoint2D.Add(const ALeft: TPoint2D; const ARight: array of Float): TPoint2D;
begin
  for var i := 0 to 1 do
    if i < System.Length(ARight) then
      Result.Vector[i] := ALeft.Vector[i] + ARight[Low(ARight) + i]
    else
      Result.Vector[i] := ALeft.Vector[i];
end;

class operator TPoint2D.Subtract(const ALeft: TPoint2D; const ARight: Float): TPoint2D;
begin
  Result.X := ALeft.X - ARight;
  Result.Y := ALeft.Y - ARight;
end;

class operator TPoint2D.Subtract(const ALeft: TPoint2D; const ARight: TPoint2D): TPoint2D;
begin
  Result.X := ALeft.X - ARight.X;
  Result.Y := ALeft.Y - ARight.Y;
end;

class operator TPoint2D.Subtract(const ALeft: TPoint2D; const ARight: array of Float): TPoint2D;
begin
  for var i := 0 to 1 do
    if i < System.Length(ARight) then
      Result.Vector[i] := ALeft.Vector[i] - ARight[Low(ARight) + i]
    else
      Result.Vector[i] := ALeft.Vector[i];
end;

class operator TPoint2D.Multiply(const ALeft: TPoint2D; const ARight: Float): TPoint2D;
begin
  Result.X := ALeft.X * ARight;
  Result.Y := ALeft.Y * ARight;
end;

class operator TPoint2D.Multiply(const ALeft: TPoint2D; const ARight: TPoint2D): TPoint2D;
begin
  Result.X := ALeft.X * ARight.X;
  Result.Y := ALeft.Y * ARight.Y;
end;

class operator TPoint2D.Multiply(const ALeft: TPoint2D; const ARight: array of Float): TPoint2D;
begin
  for var i := 0 to 1 do
    if i < System.Length(ARight) then
      Result.Vector[i] := ALeft.Vector[i] * ARight[Low(ARight) + i]
    else
      Result.Vector[i] := ALeft.Vector[i];
end;

class operator TPoint2D.Divide(const ALeft: TPoint2D; const ARight: Float): TPoint2D;
begin
  Result.X := ALeft.X / ARight;
  Result.Y := ALeft.Y / ARight;
end;

class operator TPoint2D.Divide(const ALeft: TPoint2D; const ARight: TPoint2D): TPoint2D;
begin
  Result.X := ALeft.X / ARight.X;
  Result.Y := ALeft.Y / ARight.Y;
end;

class operator TPoint2D.Divide(const ALeft: TPoint2D; const ARight: array of Float): TPoint2D;
begin
  for var i := 0 to 1 do
    if i < System.Length(ARight) then
      Result.Vector[i] := ALeft.Vector[i] / ARight[Low(ARight) + i]
    else
      Result.Vector[i] := ALeft.Vector[i];
end;

class operator TPoint2D.Negative(const ALeft: TPoint2D): TPoint2D;
begin
  Result.X := -ALeft.X;
  Result.Y := -ALeft.Y;
end;
{$ENDREGION}

{$REGION 'Methods'}
function TPoint2D.Round;
begin
  Result.X := System.Round(X);
  Result.Y := System.Round(Y);
end;

function TPoint2D.Trunc;
begin
  Result.X := System.Trunc(X);
  Result.Y := System.Trunc(Y);;
end;

function TPoint2D.Ceil;
begin
  Result.X := libNut.Maths.Ceil(X);
  Result.Y := libNut.Maths.Ceil(Y);
end;

function TPoint2D.Floor;
begin
  Result.X := libNut.Maths.Floor(X);
  Result.Y := libNut.Maths.Floor(Y);
end;

function TPoint2D.CeilFloor;
begin
  Result.X := libNut.Maths.CeilFloor(X);
  Result.Y := libNut.Maths.CeilFloor(Y);
end;

function TPoint2D.Frac;
begin
  Result.X := System.Frac(X);
  Result.Y := System.Frac(Y);
end;

function TPoint2D.Abs;
begin
  Result.X := System.Abs(X);
  Result.Y := System.Abs(Y);
end;

function TPoint2D.DotProduct: Float;
begin
  Result := DotProduct(Self);
end;

function TPoint2D.DotProduct(const A: TPoint2D): Float;
begin
  Result := (X * A.X) + (Y * A.Y);
end;

function TPoint2D.CrossProduct: Float;
begin
  Result := CrossProduct(Self);
end;

function TPoint2D.CrossProduct(const A: TPoint2D): Float;
begin
  Result := (X * A.Y) - (Y * A.X);
end;

function TPoint2D.Perp: TPoint2D;
begin
  Result.X := -Y;
  Result.Y :=  X;
end;

function TPoint2D.PerpDotProduct(const A: TPoint2D): Float;
begin
  Result := (X * A.Y) - (Y * A.X);
end;

function TPoint2D.Length: Float;
begin
  Result := Sqrt(DotProduct);
end;

function TPoint2D.Length(const APos: TPoint2D): Float;
begin
  Result := (Self - APos).Length;
end;

function TPoint2D.ApproxLength: Float;
var
  DX, DY, DT: Float;
begin
  DX := System.Abs(X);
  DY := System.Abs(Y);

  if DX <= DY then
  begin
    DT := DX;
    DX := DY;
    DY := DT;
  end;

  Result := DX + DY * 0.414213562;
end;

function TPoint2D.ApproxLength(const APos: TPoint2D): Float;
begin
  Result := (Self - APos).ApproxLength;
end;

function TPoint2D.Reflect;
begin
  Result := Self + APos * (-2 * Self.DotProduct(APos));
end;

procedure TPoint2D.Normalize;
begin
  Self := Normalized;
end;

function TPoint2D.Normalized;
var
  Len: Float;
begin
  Len := Length;

  if Len <> 0 then
    Result := Self / Len
  else
    Result := Self;
end;

function TPoint2D.Lerp;
begin
  Result.X := libNut.Maths.Lerp(X, ATarget.X, APoint);
  Result.Y := libNut.Maths.Lerp(Y, ATarget.Y, APoint);
end;

function TPoint2D.Rotate(const ATheta: Float): TPoint2D;
var
  S, C: Extended;
begin
  libNut.Maths.SinCos(ATheta, S, C);

  Result.X := C * X - S * Y;
  Result.Y := S * X + C * Y
end;

function TPoint2D.Rotate(const ATheta: Float; const APos: TPoint2D): TPoint2D;
begin
  Result := (Self - APos).Rotate(ATheta);
end;

function TPoint2D.Direction: Float;
begin
  Result := 0;

  if Y > 0 then
    Result := System.ArcTan(X / Y)
  else if Y < 0 then
  begin
    Result := System.ArcTan(X / Y);

    if X < 0 then
      Result := Result - Pi
    else
      Result := Result + Pi;
  end
  else
  begin
    if X < 0 then
      Result := - Pi / 2
    else if X > 0 then
      Result := Pi / 2;
  end;
end;

function TPoint2D.Direction(const APos: TPoint2D): Float;
begin
  Result := (Self - APos).Direction;
end;

function TPoint2D.CircleMap;
begin
  Result := Create(X * Sqrt(1 - Y * Y / 2), Y * Sqrt(1 - X * X / 2));
end;

class function TPoint2D.FromWord;
begin
  Result.X := ByteToUnit( AWord         and $FF);
  Result.Y := ByteToUnit((AWord shr  8) and $FF);
end;

function TPoint2D.ToWord;
begin
  Result := (UnitToByte(Y) shl 8) or UnitToByte(X);
end;
{$ENDREGION}
{$ENDREGION}

{$REGION 'TRectangle'}
{$REGION 'Property methods'}
function TRectangle.GetWidth;
begin
  Result := Right - Left;
end;

procedure TRectangle.SetWidth;
begin
  Right := Left + AWidth;
end;

function TRectangle.GetHeight;
begin
  Result := Bottom - Top;
end;

procedure TRectangle.SetHeight;
begin
  Bottom := Top + AHeight;
end;

function TRectangle.GetSize;
begin
  Result := [Width, Height];
end;

procedure TRectangle.SetSize;
begin
  Width  := ASize.X;
  Height := ASize.Y;
end;

function TRectangle.GetPosition;
begin
  Result := [Left, Top];
end;

procedure TRectangle.SetPosition;
var
  w, h: Float;
begin
  w := Width;
  h := Height;

  Left := APosition.X;
  Top  := APosition.Y;

  Width  := W;
  Height := H;
end;

function TRectangle.GetCenter;
begin
  Result :=
  [
    Left + (Width  / 2),
    Top  + (Height / 2)
  ];
end;

procedure TRectangle.SetCenter;
begin
  Position := ACenter - (Size / 2);
end;
{$ENDREGION}

{$REGION 'Constructors'}
class function TRectangle.Create;
begin
  Result.Left   := ALeft;
  Result.Top    := ATop;
  Result.Right  := ALeft + AWidth;
  Result.Bottom := ATop  + AHeight;
end;
{$ENDREGION}

{$REGION 'Implicit'}
class operator TRectangle.Implicit(const AValue: array of Float): TRectangle;
begin
  for var i := 0 to 3 do
  begin
    if i < System.Length(AValue) then
      Result.Vector[i] := AValue[Low(AValue) + i]
    else
      Result.Vector[i] := 0;
  end;
end;
{$ENDREGION}

{$REGION 'Operators'}

{$ENDREGION}

{$REGION 'Methods'}
function TRectangle.Round;
begin
  Result.TopLeft     := TopLeft.Round;
  Result.BottomRight := BottomRight.Round;
end;

function TRectangle.Trunc;
begin
  Result.TopLeft     := TopLeft.Trunc;
  Result.BottomRight := BottomRight.Trunc;
end;

function TRectangle.Ceil;
begin
  Result.TopLeft     := TopLeft.Ceil;
  Result.BottomRight := BottomRight.Ceil;
end;

function TRectangle.Floor;
begin
  Result.TopLeft     := TopLeft.Floor;
  Result.BottomRight := BottomRight.Floor;
end;

function TRectangle.CeilFloor;
begin
  Result.TopLeft     := TopLeft.CeilFloor;
  Result.BottomRight := BottomRight.CeilFloor;
end;

procedure TRectangle.Normalize;
var
  t: Float;
begin
  if Left > Right then
  begin
    t     := Left;
    Left  := Right;
    Right := t;
  end;

  if Top > Bottom then
  begin
    t      := Top;
    Top    := Bottom;
    Bottom := t;
  end;
end;

function TRectangle.Normalized;
begin
  Result := Self;
  Result.Normalize;
end;
{$ENDREGION}
{$ENDREGION}

end.

