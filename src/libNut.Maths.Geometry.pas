unit libNut.Maths.Geometry;

{$I libNut.Options.inc}

interface

uses
  libNut.Types;

type
  TAxis2D = (X, Y);
  TAxis3D = (X, Y, Z);
  TAxisV4 = (X, Y, Z, W);

  {$REGION 'TVector2f'}
  PPoint2D = ^TVector2f;
  TVector2f = record
  public
    class function  Create(const X, Y: Float): TVector2f; static; inline;
    class property _Create[const X, Y: Float]: TVector2f read Create; default;

    {$REGION 'Implicit'}
    class operator Implicit(const AValue: Float):          TVector2f; overload; inline;
    class operator Implicit(const AValue: array of Float): TVector2f; overload;
    {$ENDREGION}

    {$REGION 'Operators'}
    class operator Add(const ALeft: TVector2f; const ARight: Float):          TVector2f; overload; inline;
    class operator Add(const ALeft: TVector2f; const ARight: TVector2f):       TVector2f; overload; inline;
    class operator Add(const ALeft: TVector2f; const ARight: array of Float): TVector2f; overload;

    class operator Subtract(const ALeft: TVector2f; const ARight: Float):          TVector2f; overload; inline;
    class operator Subtract(const ALeft: TVector2f; const ARight: TVector2f):       TVector2f; overload; inline;
    class operator Subtract(const ALeft: TVector2f; const ARight: array of Float): TVector2f; overload;

    class operator Multiply(const ALeft: TVector2f; const ARight: Float):          TVector2f; overload; inline;
    class operator Multiply(const ALeft: TVector2f; const ARight: TVector2f):       TVector2f; overload; inline;
    class operator Multiply(const ALeft: TVector2f; const ARight: array of Float): TVector2f; overload;

    class operator Divide(const ALeft: TVector2f; const ARight: Float):          TVector2f; overload; inline;
    class operator Divide(const ALeft: TVector2f; const ARight: TVector2f):       TVector2f; overload; inline;
    class operator Divide(const ALeft: TVector2f; const ARight: array of Float): TVector2f; overload;
    {$ENDREGION}

    {$REGION 'Methods'}
    function Round:     TVector2f; inline;
    function Trunc:     TVector2f; inline;
    function Ceil:      TVector2f; inline;
    function Floor:     TVector2f; inline;
    function CeilFloor: TVector2f; inline;

    function Frac: TVector2f; inline;

    function Abs: TVector2f; inline;

    function DotProduct:                     Float; overload; inline;
    function DotProduct(const A: TVector2f): Float; overload; inline;

    function CrossProduct:                     Float; overload; inline;
    function CrossProduct(const A: TVector2f): Float; overload; inline;

    function Perp: TVector2f;
    function PerpDotProduct(const A: TVector2f): Float; inline;

    function Length:                        Float; overload; inline;
    function Length(const APos: TVector2f): Float; overload; inline;

    function ApproxLength:                        Float; overload;
    function ApproxLength(const APos: TVector2f): Float; overload; inline;

    function Reflect(const APos: TVector2f): TVector2f; inline;

    function Normalize: TVector2f;

    function Lerp(const ATarget: TVector2f; const APoint: Float): TVector2f; inline;

    function Rotate(const ATheta: Float):                        TVector2f; overload;
    function Rotate(const ATheta: Float; const APos: TVector2f): TVector2f; overload; inline;

    function Direction:                        Float; overload;
    function Direction(const APos: TVector2f): Float; overload; inline;

    function CircleMap: TVector2f;

    class function FromWord(const AWord: Word): TVector2f; static;
    function ToWord: Word;
    {$ENDREGION}
  case Union of
    0: (Components: array[TAxis2D] of Float);
    1: (X, Y: Float);
    2: (U, V: Float);
    3: (Sin, Cos: Float);
  end;
  {$ENDREGION}

  {$REGION 'TVector3f'}
  TVector3f = record
  public
    class function  Create(const X, Y: Float; const Z: Float = 1): TVector3f; static; inline;
    class property _Create[const X, Y: Float; const Z: Float = 1]: TVector3f read Create; default;

    {$REGION 'Implicit'}
    class operator Implicit(const AValue: Float):          TVector3f; overload; inline;
    class operator Implicit(const AValue: array of Float): TVector3f; overload;
    class operator Implicit(const AValue: TVector2f):       TVector3f; overload; inline;
    {$ENDREGION}

    {$REGION 'Operators'}
    class operator Add(const ALeft: TVector3f; const ARight: Float):          TVector3f; overload; inline;
    class operator Add(const ALeft: TVector3f; const ARight: TVector2f):       TVector3f; overload; inline;
    class operator Add(const ALeft: TVector3f; const ARight: TVector3f):       TVector3f; overload; inline;
    class operator Add(const ALeft: TVector3f; const ARight: array of Float): TVector3f; overload;

    class operator Subtract(const ALeft: TVector3f; const ARight: Float):          TVector3f; overload; inline;
    class operator Subtract(const ALeft: TVector3f; const ARight: TVector2f):       TVector3f; overload; inline;
    class operator Subtract(const ALeft: TVector3f; const ARight: TVector3f):       TVector3f; overload; inline;
    class operator Subtract(const ALeft: TVector3f; const ARight: array of Float): TVector3f; overload;

    class operator Multiply(const ALeft: TVector3f; const ARight: Float):          TVector3f; overload; inline;
    class operator Multiply(const ALeft: TVector3f; const ARight: TVector2f):       TVector3f; overload; inline;
    class operator Multiply(const ALeft: TVector3f; const ARight: TVector3f):       TVector3f; overload; inline;
    class operator Multiply(const ALeft: TVector3f; const ARight: array of Float): TVector3f; overload;

    class operator Divide(const ALeft: TVector3f; const ARight: Float):          TVector3f; overload; inline;
    class operator Divide(const ALeft: TVector3f; const ARight: TVector2f):       TVector3f; overload; inline;
    class operator Divide(const ALeft: TVector3f; const ARight: TVector3f):       TVector3f; overload; inline;
    class operator Divide(const ALeft: TVector3f; const ARight: array of Float): TVector3f; overload;
    {$ENDREGION}

    {$REGION 'Methods'}
    function Round:     TVector3f; inline;
    function Trunc:     TVector3f; inline;
    function Ceil:      TVector3f; inline;
    function Floor:     TVector3f; inline;
    function CeilFloor: TVector3f; inline;

    function Frac: TVector3f; inline;

    function Abs: TVector3f; inline;

    function DotProduct:                     Float; overload; inline;
    function DotProduct(const A: TVector3f): Float; overload; inline;

    function CrossProduct:                     TVector3f; overload; inline;
    function CrossProduct(const A: TVector3f): TVector3f; overload; inline;

    function Length:                        Float; overload; inline;
    function Length(const APos: TVector3f): Float; overload; inline;

    function Normalize: TVector3f;

    function ParallelNormal(const APos: TVector3f): TVector3f;

    function Reflect(const ASurfaceNormal: TVector3f): TVector3f;

    function Lerp(const ATarget: TVector3f; const APoint: Float): TVector3f;

    function SwapRB: TVector3f;
    {$ENDREGION}
  case Union of
    0: (Components: array[TAxis3D] of Float);

    1: (X, Y, Z: Float);
    2: (R, G, B: Float);

    3: (XY: TVector2f; W: Float);
    4: (UV: TVector2f);
  end;
  {$ENDREGION}

  {$REGION 'TVector4f'}
  TVector4f = record
  public
    class function  Create(const X, Y, Z: Float; const W: Float = 1): TVector4f; static; inline;
    class property _Create[const X, Y, Z: Float; const W: Float = 1]: TVector4f read Create; default;

    {$REGION 'Implicit'}
    class operator Implicit(const AValue: Float):          TVector4f; overload; inline;
    class operator Implicit(const AValue: array of Float): TVector4f; overload;
    class operator Implicit(const AValue: TVector3f):       TVector4f; overload; inline;
    {$ENDREGION}

    {$REGION 'Operators'}
    class operator Add(const ALeft: TVector4f; const ARight: Float):          TVector4f; overload; inline;
    class operator Add(const ALeft: TVector4f; const ARight: TVector2f):       TVector4f; overload; inline;
    class operator Add(const ALeft: TVector4f; const ARight: TVector3f):       TVector4f; overload; inline;
    class operator Add(const ALeft: TVector4f; const ARight: TVector4f):       TVector4f; overload; inline;
    class operator Add(const ALeft: TVector4f; const ARight: array of Float): TVector4f; overload;

    class operator Subtract(const ALeft: TVector4f; const ARight: Float):          TVector4f; overload; inline;
    class operator Subtract(const ALeft: TVector4f; const ARight: TVector2f):       TVector4f; overload; inline;
    class operator Subtract(const ALeft: TVector4f; const ARight: TVector3f):       TVector4f; overload; inline;
    class operator Subtract(const ALeft: TVector4f; const ARight: TVector4f):       TVector4f; overload; inline;
    class operator Subtract(const ALeft: TVector4f; const ARight: array of Float): TVector4f; overload;

    class operator Multiply(const ALeft: TVector4f; const ARight: Float):          TVector4f; overload; inline;
    class operator Multiply(const ALeft: TVector4f; const ARight: TVector2f):       TVector4f; overload; inline;
    class operator Multiply(const ALeft: TVector4f; const ARight: TVector3f):       TVector4f; overload; inline;
    class operator Multiply(const ALeft: TVector4f; const ARight: TVector4f):       TVector4f; overload; inline;
    class operator Multiply(const ALeft: TVector4f; const ARight: array of Float): TVector4f; overload;

    class operator Divide(const ALeft: TVector4f; const ARight: Float):          TVector4f; overload; inline;
    class operator Divide(const ALeft: TVector4f; const ARight: TVector2f):       TVector4f; overload; inline;
    class operator Divide(const ALeft: TVector4f; const ARight: TVector3f):       TVector4f; overload; inline;
    class operator Divide(const ALeft: TVector4f; const ARight: TVector4f):       TVector4f; overload; inline;
    class operator Divide(const ALeft: TVector4f; const ARight: array of Float): TVector4f; overload;
    {$ENDREGION}

    {$REGION 'Methods'}
    function Round:     TVector4f; inline;
    function Trunc:     TVector4f; inline;
    function Ceil:      TVector4f; inline;
    function Floor:     TVector4f; inline;
    function CeilFloor: TVector4f; inline;

    function Frac: TVector4f; inline;

    function Abs: TVector4f; inline;

    function DotProduct:                     Float; overload; inline;
    function DotProduct(const A: TVector4f): Float; overload; inline;

    function CrossProduct:                     TVector4f; overload; inline;
    function CrossProduct(const A: TVector4f): TVector4f; overload; inline;

    function Length:                        Float; overload; inline;
    function Length(const APos: TVector4f): Float; overload; inline;

    function Normalize: TVector4f;

    function ParallelNormal(const APos: TVector4f): TVector4f;

    function Reflect(const ASurfaceNormal: TVector4f): TVector4f;

    function Lerp(const ATarget: TVector4f; const APoint: Float): TVector4f;

    function Width:  Float; inline;
    function Height: Float; inline;

    function Center: TVector2f;

    function Alpha(const AAlpha: Float): TVector4f; inline;

    class function FromDWord(const ADWord: Cardinal): TVector4f; static;
    function ToDWord: Cardinal;
    {$ENDREGION}
  case Union of
    0: (Components: array[TAxisV4] of Float);

    1: (X, Y, Z, W: Float);
    2: (R, G, B, A: Float);

    3: (XYZ: TVector3f);
    4: (RGB: TVector3f);

    5: (V1, V2: TVector2f);

    6: (X1, Y1, X2, Y2: Float);
  end;
  {$ENDREGION}

  TPoint2D = TVector2f;
  TPoint3D = TVector3f;

  {$REGION 'TRect2D'}
  PRect2D = ^TRect2D;
  TRect2D = record
  public
    class function  Create(const ALeft, ATop, AWidth, AHeight: Float): TRect2D; static; inline;
    class property _Create[const ALeft, ATop, AWidth, AHeight: Float]: TRect2D read Create; default;

    function  GetCenter: TVector2f;
    procedure SetCenter(const ACenter: TVector2f);
    property  Center: TVector2f read GetCenter write SetCenter;

    function  GetSize: TVector2f; inline;
    procedure SetSize(const ASize: TVector2f); inline;
    property  Size: TVector2f read GetSize write SetSize;

    function  GetWidth: Float; inline;
    procedure SetWidth(const AWidth: Float); inline;
    property  Width: Float read GetWidth write SetWidth;

    function  GetHeight: Float; inline;
    procedure SetHeight(const AHeight: Float); inline;
    property  Height: Float read GetHeight write SetHeight;

    function Area: Float; inline;

    function Radius: Float; inline;
 case Union of
    0: (Components: array[0..3] of Float);
    1: (TopLeft, BottomRight: TVector2f);
    2: (Left, Top, Right, Bottom: Float);
  end;
  {$ENDREGION}

type
  {$REGION 'TVector2fHelper'}
  TVector2fHelper = record helper for TVector2f
  const
    Zero: TVector2f = (X:0; Y:0);
    One:  TVector2f = (X:1; Y:1);

    North: TVector2f = (X: 0; Y:-1);
    East:  TVector2f = (X: 1; Y: 0);
    South: TVector2f = (X: 0; Y: 1);
    West:  TVector2f = (X:-1; Y: 0);

    TopLeft:     TVector2f = (X:0; Y:0);
    TopRight:    TVector2f = (X:1; Y:0);
    BottomRight: TVector2f = (X:1; Y:1);
    BottomLeft:  TVector2f = (X:0; Y:1);
  end;
  {$ENDREGION}

  {$REGION 'TVector3fHelper'}
  TVector3fHelper = record helper for TVector3f
  const
    Zero: TVector3f = (X:0; Y:0; Z:0);
    One:  TVector3f = (X:1; Y:1; Z:0);

    Unity: TVector3f = (X:0; Y:0; W:1);
  end;
  {$ENDREGION}

  {$REGION 'TVector4fHelper'}
  TVector4fHelper = record helper for TVector4f
  const
    Zero: TVector4f = (X:0; Y:0; Z:0; W:0);
    One:  TVector4f = (X:1; Y:1; Z:0; W:0);

    Unity: TVector4f = (X:0; Y:0; Z:0; W:1);
  end;
  {$ENDREGION}

implementation

uses
  libNut.Maths;

{$REGION 'TVector2f'}
class function TVector2f.Create;
begin
  Result.X := X;
  Result.Y := Y;
end;

{$REGION 'Implicit'}
class operator TVector2f.Implicit(const AValue: Float): TVector2f;
begin
  Result := Create(AValue, AValue);
end;

class operator TVector2f.Implicit(const AValue: array of Float): TVector2f;
begin
  for var i := 0 to 1 do
  begin
    if i < System.Length(AValue) then
      Result.Components[TAxis2D(i)] := AValue[Low(AValue) + i]
    else
      Result.Components[TAxis2D(i)] := 0;
  end;
end;
{$ENDREGION}

{$REGION 'Operators'}
class operator TVector2f.Add(const ALeft: TVector2f; const ARight: Float): TVector2f;
begin
  Result.X := ALeft.X + ARight;
  Result.Y := ALeft.Y + ARight;
end;

class operator TVector2f.Add(const ALeft: TVector2f; const ARight: TVector2f): TVector2f;
begin
  Result.X := ALeft.X + ARight.X;
  Result.Y := ALeft.Y + ARight.Y;
end;

class operator TVector2f.Add(const ALeft: TVector2f; const ARight: array of Float): TVector2f;
begin
  for var i := 0 to 1 do
    if i < System.Length(ARight) then
      Result.Components[TAxis2D(i)] := ALeft.Components[TAxis2D(i)] + ARight[Low(ARight) + i]
    else
      Result.Components[TAxis2D(i)] := ALeft.Components[TAxis2D(i)];
end;

class operator TVector2f.Subtract(const ALeft: TVector2f; const ARight: Float): TVector2f;
begin
  Result.X := ALeft.X - ARight;
  Result.Y := ALeft.Y - ARight;
end;

class operator TVector2f.Subtract(const ALeft: TVector2f; const ARight: TVector2f): TVector2f;
begin
  Result.X := ALeft.X - ARight.X;
  Result.Y := ALeft.Y - ARight.Y;
end;

class operator TVector2f.Subtract(const ALeft: TVector2f; const ARight: array of Float): TVector2f;
begin
  for var i := 0 to 1 do
    if i < System.Length(ARight) then
      Result.Components[TAxis2D(i)] := ALeft.Components[TAxis2D(i)] - ARight[Low(ARight) + i]
    else
      Result.Components[TAxis2D(i)] := ALeft.Components[TAxis2D(i)];
end;

class operator TVector2f.Multiply(const ALeft: TVector2f; const ARight: Float): TVector2f;
begin
  Result.X := ALeft.X * ARight;
  Result.Y := ALeft.Y * ARight;
end;

class operator TVector2f.Multiply(const ALeft: TVector2f; const ARight: TVector2f): TVector2f;
begin
  Result.X := ALeft.X * ARight.X;
  Result.Y := ALeft.Y * ARight.Y;
end;

class operator TVector2f.Multiply(const ALeft: TVector2f; const ARight: array of Float): TVector2f;
begin
  for var i := 0 to 1 do
    if i < System.Length(ARight) then
      Result.Components[TAxis2D(i)] := ALeft.Components[TAxis2D(i)] * ARight[Low(ARight) + i]
    else
      Result.Components[TAxis2D(i)] := ALeft.Components[TAxis2D(i)];
end;

class operator TVector2f.Divide(const ALeft: TVector2f; const ARight: Float): TVector2f;
begin
  Result.X := ALeft.X / ARight;
  Result.Y := ALeft.Y / ARight;
end;

class operator TVector2f.Divide(const ALeft: TVector2f; const ARight: TVector2f): TVector2f;
begin
  Result.X := ALeft.X / ARight.X;
  Result.Y := ALeft.Y / ARight.Y;
end;

class operator TVector2f.Divide(const ALeft: TVector2f; const ARight: array of Float): TVector2f;
begin
  for var i := 0 to 1 do
    if i < System.Length(ARight) then
      Result.Components[TAxis2D(i)] := ALeft.Components[TAxis2D(i)] / ARight[Low(ARight) + i]
    else
      Result.Components[TAxis2D(i)] := ALeft.Components[TAxis2D(i)];
end;
{$ENDREGION}

{$REGION 'Methods'}
function TVector2f.Round;
begin
  Result.X := System.Round(X);
  Result.Y := System.Round(Y);
end;

function TVector2f.Trunc;
begin
  Result.X := System.Trunc(X);
  Result.Y := System.Trunc(Y);;
end;

function TVector2f.Ceil;
begin
  Result.X := libNut.Maths.Ceil(X);
  Result.Y := libNut.Maths.Ceil(Y);
end;

function TVector2f.Floor;
begin
  Result.X := libNut.Maths.Floor(X);
  Result.Y := libNut.Maths.Floor(Y);
end;

function TVector2f.CeilFloor;
begin
  Result.X := libNut.Maths.CeilFloor(X);
  Result.Y := libNut.Maths.CeilFloor(Y);
end;

function TVector2f.Frac;
begin
  Result.X := System.Frac(X);
  Result.Y := System.Frac(Y);
end;

function TVector2f.Abs;
begin
  Result.X := System.Abs(X);
  Result.Y := System.Abs(Y);
end;

function TVector2f.DotProduct: Float;
begin
  Result := DotProduct(Self);
end;

function TVector2f.DotProduct(const A: TVector2f): Float;
begin
  Result := (X * A.X) + (Y * A.Y);
end;

function TVector2f.CrossProduct: Float;
begin
  Result := CrossProduct(Self);
end;

function TVector2f.CrossProduct(const A: TVector2f): Float;
begin
  Result := (X * A.Y) - (Y * A.X);
end;

function TVector2f.Perp: TVector2f;
begin
  Result.X := -Y;
  Result.Y :=  X;
end;

function TVector2f.PerpDotProduct(const A: TVector2f): Float;
begin
  Result := (X * A.Y) - (Y * A.X);
end;

function TVector2f.Length: Float;
begin
  Result := Sqrt(DotProduct);
end;

function TVector2f.Length(const APos: TVector2f): Float;
begin
  Result := (Self - APos).Length;
end;

function TVector2f.ApproxLength: Float;
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

function TVector2f.ApproxLength(const APos: TVector2f): Float;
begin
  Result := (Self - APos).ApproxLength;
end;

function TVector2f.Reflect;
begin
  Result := Self + APos * (-2 * Self.DotProduct(APos));
end;

function TVector2f.Normalize;
var
  Len: Float;
begin
  Len := Length;

  if Len > 0 then
    Result := Self / Len
  else
    Result := Zero;
end;

function TVector2f.Lerp;
begin
  Result.X := libNut.Maths.Lerp(X, ATarget.X, APoint);
  Result.Y := libNut.Maths.Lerp(Y, ATarget.Y, APoint);
end;

function TVector2f.Rotate(const ATheta: Float): TVector2f;
var
  SC: TVector2f;
begin
  // TODO: SC := SinCos(ATheta);

  Result.X := SC.Y * X - SC.X * Y;
  Result.Y := SC.X * X + SC.Y * Y
end;

function TVector2f.Rotate(const ATheta: Float; const APos: TVector2f): TVector2f;
begin
  Result := (Self - APos).Rotate(ATheta);
end;

function TVector2f.Direction: Float;
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

function TVector2f.Direction(const APos: TVector2f): Float;
begin
  Result := (Self - APos).Direction;
end;

function TVector2f.CircleMap;
begin
  Result := Create(X * Sqrt(1 - Y * Y / 2), Y * Sqrt(1 - X * X / 2));
end;

class function TVector2f.FromWord;
begin
  Result.X := ByteToUnit( AWord         and $FF);
  Result.Y := ByteToUnit((AWord shr  8) and $FF);
end;

function TVector2f.ToWord;
begin
  Result := (UnitToByte(Y) shl 8) or UnitToByte(X);
end;
{$ENDREGION}
{$ENDREGION}

{$REGION 'TVector3f'}
class function TVector3f.Create;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

{$REGION 'Implicit'}
class operator TVector3f.Implicit(const AValue: Float): TVector3f;
begin
  Result := Create(AValue, AValue, AValue);
end;

class operator TVector3f.Implicit(const AValue: array of Float): TVector3f;
begin
  for var i := 0 to 2 do
  begin
    if i < System.Length(AValue) then
      Result.Components[TAxis3D(i)] := AValue[Low(AValue) + i]
    else
      Result.Components[TAxis3D(i)] := Unity.Components[TAxis3D(i)];
  end;
end;

class operator TVector3f.Implicit(const AValue: TVector2f): TVector3f;
begin
  Result.XY := AValue;
  Result.Z  := 0;
end;
{$ENDREGION}

{$REGION 'Operators'}
class operator TVector3f.Add(const ALeft: TVector3f; const ARight: Float): TVector3f;
begin
  Result.X := ALeft.X + ARight;
  Result.Y := ALeft.Y + ARight;
  Result.Z := ALeft.Z + ARight;
end;

class operator TVector3f.Add(const ALeft: TVector3f; const ARight: TVector2f): TVector3f;
begin
  Result.X := ALeft.X + ARight.X;
  Result.Y := ALeft.Y + ARight.Y;
  Result.Z := ALeft.Z;
end;

class operator TVector3f.Add(const ALeft: TVector3f; const ARight: TVector3f): TVector3f;
begin
  Result.X := ALeft.X + ARight.X;
  Result.Y := ALeft.Y + ARight.Y;
  Result.Z := ALeft.Z + ARight.Z;
end;

class operator TVector3f.Add(const ALeft: TVector3f; const ARight: array of Float): TVector3f;
begin
  for var i := 0 to 2 do
    if i < System.Length(ARight) then
      Result.Components[TAxis3D(i)] := ALeft.Components[TAxis3D(i)] + ARight[Low(ARight) + i]
    else
      Result.Components[TAxis3D(i)] := ALeft.Components[TAxis3D(i)];
end;

class operator TVector3f.Subtract(const ALeft: TVector3f; const ARight: Float): TVector3f;
begin
  Result.X := ALeft.X - ARight;
  Result.Y := ALeft.Y - ARight;
  Result.Z := ALeft.Z - ARight;
end;

class operator TVector3f.Subtract(const ALeft: TVector3f; const ARight: TVector2f): TVector3f;
begin
  Result.X := ALeft.X - ARight.X;
  Result.Y := ALeft.Y - ARight.Y;
  Result.Z := ALeft.Z;
end;

class operator TVector3f.Subtract(const ALeft: TVector3f; const ARight: TVector3f): TVector3f;
begin
  Result.X := ALeft.X - ARight.X;
  Result.Y := ALeft.Y - ARight.Y;
  Result.Z := ALeft.Z - ARight.Z;
end;

class operator TVector3f.Subtract(const ALeft: TVector3f; const ARight: array of Float): TVector3f;
begin
  for var i := 0 to 2 do
    if i < System.Length(ARight) then
      Result.Components[TAxis3D(i)] := ALeft.Components[TAxis3D(i)] - ARight[Low(ARight) + i]
    else
      Result.Components[TAxis3D(i)] := ALeft.Components[TAxis3D(i)];
end;

class operator TVector3f.Multiply(const ALeft: TVector3f; const ARight: Float): TVector3f;
begin
  Result.X := ALeft.X * ARight;
  Result.Y := ALeft.Y * ARight;
  Result.Z := ALeft.Z * ARight;
end;

class operator TVector3f.Multiply(const ALeft: TVector3f; const ARight: TVector2f): TVector3f;
begin
  Result.X := ALeft.X * ARight.X;
  Result.Y := ALeft.Y * ARight.Y;
  Result.Z := ALeft.Z;
end;

class operator TVector3f.Multiply(const ALeft: TVector3f; const ARight: TVector3f): TVector3f;
begin
  Result.X := ALeft.X * ARight.X;
  Result.Y := ALeft.Y * ARight.Y;
  Result.Z := ALeft.Z * ARight.Z;
end;

class operator TVector3f.Multiply(const ALeft: TVector3f; const ARight: array of Float): TVector3f;
begin
  for var i := 0 to 2 do
    if i < System.Length(ARight) then
      Result.Components[TAxis3D(i)] := ALeft.Components[TAxis3D(i)] * ARight[Low(ARight) + i]
    else
      Result.Components[TAxis3D(i)] := ALeft.Components[TAxis3D(i)];
end;

class operator TVector3f.Divide(const ALeft: TVector3f; const ARight: Float): TVector3f;
begin
  Result.X := ALeft.X / ARight;
  Result.Y := ALeft.Y / ARight;
  Result.Z := ALeft.Z / ARight;
end;

class operator TVector3f.Divide(const ALeft: TVector3f; const ARight: TVector2f): TVector3f;
begin
  Result.X := ALeft.X / ARight.X;
  Result.Y := ALeft.Y / ARight.Y;
  Result.Z := ALeft.Z;
end;

class operator TVector3f.Divide(const ALeft: TVector3f; const ARight: TVector3f): TVector3f;
begin
  Result.X := ALeft.X / ARight.X;
  Result.Y := ALeft.Y / ARight.Y;
  Result.Z := ALeft.Z / ARight.Z;
end;

class operator TVector3f.Divide(const ALeft: TVector3f; const ARight: array of Float): TVector3f;
begin
  for var i := 0 to 2 do
    if i < System.Length(ARight) then
      Result.Components[TAxis3D(i)] := ALeft.Components[TAxis3D(i)] / ARight[Low(ARight) + i]
    else
      Result.Components[TAxis3D(i)] := ALeft.Components[TAxis3D(i)];
end;
{$ENDREGION}

{$REGION 'Methods'}
function TVector3f.Round;
begin
  Result.XY := XY.Round;
  Result.Z  := System.Round(Z);
end;

function TVector3f.Trunc;
begin
  Result.XY := XY.Trunc;
  Result.Z  := System.Trunc(Z);
end;

function TVector3f.Ceil;
begin
  Result.XY := XY.Ceil;
  Result.Z  := libNut.Maths.Ceil(Z);
end;

function TVector3f.Floor;
begin
  Result.XY := XY.Floor;
  Result.Z  := libNut.Maths.Floor(Z);
end;

function TVector3f.CeilFloor;
begin
  Result.XY := XY.CeilFloor;
  Result.Z  := libNut.Maths.CeilFloor(Z);
end;

function TVector3f.Frac;
begin
  Result.XY := XY.Frac;
  Result.Z  := System.Frac(Z);
end;

function TVector3f.Abs;
begin
  Result.XY := XY.Abs;
  Result.Z  := System.Abs(Z);
end;

function TVector3f.DotProduct: Float;
begin
  Result := DotProduct(Self);
end;

function TVector3f.DotProduct(const A: TVector3f): Float;
begin
  Result := (X * A.X) + (Y * A.Y) + (Z + A.Z);
end;

function TVector3f.CrossProduct: TVector3f;
begin
  Result := CrossProduct(Self);
end;

function TVector3f.CrossProduct(const A: TVector3f): TVector3f;
begin
  Result.X := (Y * A.Z) - (Z * A.Y);
  Result.Y := (Z * A.X) - (X * A.Z);
  Result.Z := (X * A.Y) - (Y * A.X);
end;

function TVector3f.Length: Float;
begin
  Result := Sqrt(DotProduct);
end;

function TVector3f.Length(const APos: TVector3f): Float;
begin
  Result := (Self - APos).Length;
end;

function TVector3f.Normalize;
var
  Len: Float;
begin
  Len := Length;

  if Len > 0 then
    Result := Self / Len
  else
    Result := Zero;
end;

function TVector3f.ParallelNormal;
begin
  Result := APos * (DotProduct(APos) / Sqr(Length));
end;

function TVector3f.Reflect;
begin
  Result := Self - ASurfaceNormal * DotProduct(ASurfaceNormal) * 2;
end;

function TVector3f.Lerp;
begin
  Result.X := libNut.Maths.Lerp(X, ATarget.X, APoint);
  Result.Y := libNut.Maths.Lerp(Y, ATarget.Y, APoint);
  Result.Y := libNut.Maths.Lerp(Z, ATarget.Z, APoint);
end;

function TVector3f.SwapRB;
begin
  Result.R := B;
  Result.G := G;
  Result.B := R;
end;
{$ENDREGION}
{$ENDREGION}

{$REGION 'TVector4f'}
class function TVector4f.Create;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
  Result.W := W;
end;

{$REGION 'Implicit'}
class operator TVector4f.Implicit(const AValue: Float): TVector4f;
begin
  Result := Create(AValue, AValue, AValue, AValue);
end;

class operator TVector4f.Implicit(const AValue: array of Float): TVector4f;
begin
  for var i := 0 to 3 do
  begin
    if i < System.Length(AValue) then
      Result.Components[TAxisV4(i)] := AValue[Low(AValue) + i]
    else
      Result.Components[TAxisV4(i)] := Unity.Components[TAxisV4(i)];
  end;
end;

class operator TVector4f.Implicit(const AValue: TVector3f): TVector4f;
begin
  Result.XYZ := AValue;
  Result.W   := 1;
end;
{$ENDREGION}

{$REGION 'Operators'}
class operator TVector4f.Add(const ALeft: TVector4f; const ARight: Float): TVector4f;
begin
  Result.X := ALeft.X + ARight;
  Result.Y := ALeft.Y + ARight;
  Result.Z := ALeft.Z + ARight;
  Result.W := ALeft.W + ARight;
end;

class operator TVector4f.Add(const ALeft: TVector4f; const ARight: TVector2f): TVector4f;
begin
  Result.X := ALeft.X + ARight.X;
  Result.Y := ALeft.Y + ARight.Y;
  Result.Z := ALeft.Z;
  Result.W := ALeft.W;
end;

class operator TVector4f.Add(const ALeft: TVector4f; const ARight: TVector3f): TVector4f;
begin
  Result.X := ALeft.X + ARight.X;
  Result.Y := ALeft.Y + ARight.Y;
  Result.Z := ALeft.Z + ARight.Z;
  Result.W := ALeft.W;
end;

class operator TVector4f.Add(const ALeft: TVector4f; const ARight: TVector4f): TVector4f;
begin
  Result.X := ALeft.X + ARight.X;
  Result.Y := ALeft.Y + ARight.Y;
  Result.Z := ALeft.Z + ARight.Z;
  Result.W := ALeft.W + ARight.W;
end;

class operator TVector4f.Add(const ALeft: TVector4f; const ARight: array of Float): TVector4f;
begin
  for var i := 0 to 3 do
    if i < System.Length(ARight) then
      Result.Components[TAxisV4(i)] := ALeft.Components[TAxisV4(i)] + ARight[Low(ARight) + i]
    else
      Result.Components[TAxisV4(i)] := ALeft.Components[TAxisV4(i)];
end;

class operator TVector4f.Subtract(const ALeft: TVector4f; const ARight: Float): TVector4f;
begin
  Result.X := ALeft.X - ARight;
  Result.Y := ALeft.Y - ARight;
  Result.Z := ALeft.Z - ARight;
  Result.W := ALeft.W - ARight;
end;

class operator TVector4f.Subtract(const ALeft: TVector4f; const ARight: TVector2f): TVector4f;
begin
  Result.X := ALeft.X - ARight.X;
  Result.Y := ALeft.Y - ARight.Y;
  Result.Z := ALeft.Z;
  Result.W := ALeft.W;
end;

class operator TVector4f.Subtract(const ALeft: TVector4f; const ARight: TVector3f): TVector4f;
begin
  Result.X := ALeft.X - ARight.X;
  Result.Y := ALeft.Y - ARight.Y;
  Result.Z := ALeft.Z - ARight.Z;
  Result.W := ALeft.W;
end;

class operator TVector4f.Subtract(const ALeft: TVector4f; const ARight: TVector4f): TVector4f;
begin
  Result.X := ALeft.X - ARight.X;
  Result.Y := ALeft.Y - ARight.Y;
  Result.Z := ALeft.Z - ARight.Z;
  Result.W := ALeft.W - ARight.W;
end;

class operator TVector4f.Subtract(const ALeft: TVector4f; const ARight: array of Float): TVector4f;
begin
  for var i := 0 to 3 do
    if i < System.Length(ARight) then
      Result.Components[TAxisV4(i)] := ALeft.Components[TAxisV4(i)] - ARight[Low(ARight) + i]
    else
      Result.Components[TAxisV4(i)] := ALeft.Components[TAxisV4(i)];
end;

class operator TVector4f.Multiply(const ALeft: TVector4f; const ARight: Float): TVector4f;
begin
  Result.X := ALeft.X * ARight;
  Result.Y := ALeft.Y * ARight;
  Result.Z := ALeft.Z * ARight;
  Result.W := ALeft.W * ARight;
end;

class operator TVector4f.Multiply(const ALeft: TVector4f; const ARight: TVector2f): TVector4f;
begin
  Result.X := ALeft.X * ARight.X;
  Result.Y := ALeft.Y * ARight.Y;
  Result.Z := ALeft.Z;
  Result.W := ALeft.W;
end;

class operator TVector4f.Multiply(const ALeft: TVector4f; const ARight: TVector3f): TVector4f;
begin
  Result.X := ALeft.X * ARight.X;
  Result.Y := ALeft.Y * ARight.Y;
  Result.Z := ALeft.Z * ARight.Z;
  Result.W := ALeft.W;
end;

class operator TVector4f.Multiply(const ALeft: TVector4f; const ARight: TVector4f): TVector4f;
begin
  Result.X := ALeft.X * ARight.X;
  Result.Y := ALeft.Y * ARight.Y;
  Result.Z := ALeft.Z * ARight.Z;
  Result.W := ALeft.W * ARight.W;
end;

class operator TVector4f.Multiply(const ALeft: TVector4f; const ARight: array of Float): TVector4f;
begin
  for var i := 0 to 3 do
    if i < System.Length(ARight) then
      Result.Components[TAxisV4(i)] := ALeft.Components[TAxisV4(i)] * ARight[Low(ARight) + i]
    else
      Result.Components[TAxisV4(i)] := ALeft.Components[TAxisV4(i)];
end;

class operator TVector4f.Divide(const ALeft: TVector4f; const ARight: Float): TVector4f;
begin
  Result.X := ALeft.X / ARight;
  Result.Y := ALeft.Y / ARight;
  Result.Z := ALeft.Z / ARight;
  Result.W := ALeft.W / ARight;
end;

class operator TVector4f.Divide(const ALeft: TVector4f; const ARight: TVector2f): TVector4f;
begin
  Result.X := ALeft.X / ARight.X;
  Result.Y := ALeft.Y / ARight.Y;
  Result.Z := ALeft.Z;
  Result.W := ALeft.W;
end;

class operator TVector4f.Divide(const ALeft: TVector4f; const ARight: TVector3f): TVector4f;
begin
  Result.X := ALeft.X / ARight.X;
  Result.Y := ALeft.Y / ARight.Y;
  Result.Z := ALeft.Z / ARight.Z;
  Result.W := ALeft.W;
end;

class operator TVector4f.Divide(const ALeft: TVector4f; const ARight: TVector4f): TVector4f;
begin
  Result.X := ALeft.X / ARight.X;
  Result.Y := ALeft.Y / ARight.Y;
  Result.Z := ALeft.Z / ARight.Z;
  Result.W := ALeft.W / ARight.W;
end;

class operator TVector4f.Divide(const ALeft: TVector4f; const ARight: array of Float): TVector4f;
begin
  for var i := 0 to 3 do
    if i < System.Length(ARight) then
      Result.Components[TAxisV4(i)] := ALeft.Components[TAxisV4(i)] + ARight[Low(ARight) + i]
    else
      Result.Components[TAxisV4(i)] := ALeft.Components[TAxisV4(i)];
end;
{$ENDREGION}

{$REGION 'Methods'}
function TVector4f.Round;
begin
  Result.XYZ := XYZ.Round;
  Result.W   := System.Round(W);
end;

function TVector4f.Trunc;
begin
  Result.XYZ := XYZ.Trunc;
  Result.W   := System.Trunc(W);
end;

function TVector4f.Ceil;
begin
  Result.XYZ := XYZ.Ceil;
  Result.W   := libNut.Maths.Ceil(W);
end;

function TVector4f.Floor;
begin
  Result.XYZ := XYZ.Floor;
  Result.W   := libNut.Maths.Floor(W);
end;

function TVector4f.CeilFloor;
begin
  Result.XYZ := XYZ.CeilFloor;
  Result.W   := libNut.Maths.CeilFloor(W);
end;

function TVector4f.Frac;
begin
  Result.XYZ := XYZ.Frac;
  Result.W   := System.Frac(W);
end;

function TVector4f.Abs;
begin
  Result.XYZ := XYZ.Abs;
  Result.W   := System.Abs(W);
end;
function TVector4f.DotProduct: Float;
begin
  Result := DotProduct(Self);
end;

function TVector4f.DotProduct(const A: TVector4f): Float;
begin
  Result := XYZ.DotProduct(A.XYZ);
end;

function TVector4f.CrossProduct: TVector4f;
begin
  Result := CrossProduct(Self);
end;

function TVector4f.CrossProduct(const A: TVector4f): TVector4f;
begin
  Result.XYZ := XYZ.CrossProduct(A.XYZ);
  Result.W   := 1;
end;

function TVector4f.Length: Float;
begin
  Result := Sqrt(DotProduct);
end;

function TVector4f.Length(const APos: TVector4f): Float;
begin
  Result := (Self - APos).Length;
end;

function TVector4f.Normalize;
var
  Len: Float;
begin
  Len := Length;

  if Len > 0 then
    Result := Self / Len
  else
    Result := Zero;
end;

function TVector4f.ParallelNormal;
begin
  Result.XYZ := Self.XYZ.ParallelNormal(APos.XYZ);
  Result.W   := 1;
end;

function TVector4f.Reflect;
begin
  Result.XYZ := Self.XYZ.Reflect(ASurfaceNormal.XYZ);
  Result.W   := 1;
end;

function TVector4f.Lerp;
begin
  Result.X := libNut.Maths.Lerp(X, ATarget.X, APoint);
  Result.Y := libNut.Maths.Lerp(Y, ATarget.Y, APoint);
  Result.Y := libNut.Maths.Lerp(Z, ATarget.Z, APoint);
  Result.W := libNut.Maths.Lerp(W, ATarget.W, APoint);
end;

function TVector4f.Width;
begin
  Result := X2 - X1;
end;

function TVector4f.Height;
begin
  Result := Y2 - Y1;
end;

function TVector4f.Center;
begin
  Result.X := X1 + (Width  / 2);
  Result.Y := Y1 + (Height / 2);
end;

function TVector4f.Alpha;
begin
  Result.RGB := Self.RGB;
  Result.A   := AAlpha;
end;

class function TVector4f.FromDWord;
begin
  Result.X := ByteToUnit( ADWord         and $FF);
  Result.Y := ByteToUnit((ADWord shr  8) and $FF);
  Result.Z := ByteToUnit((ADWord shr 16) and $FF);
  Result.W := ByteToUnit((ADWord shr 24) and $FF);
end;

function TVector4f.ToDWord;
begin
  Result := (UnitToByte(W) shl 24) or (UnitToByte(Z) shl 16) or (UnitToByte(Y) shl 8) or UnitToByte(X);
end;
{$ENDREGION}
{$ENDREGION}

{$REGION 'TRect2D'}
class function TRect2D.Create;
begin
  Result.Left   := ALeft;
  Result.Top    := ATop;
  Result.Right  := ALeft + AWidth;
  Result.Bottom := ATop  + AHeight;
end;

function TRect2D.GetCenter;
begin
  Result.X := Left + (Width  / 2);
  Result.Y := Top  + (Height / 2);
end;

procedure TRect2D.SetCenter;
var
  w, h: Float;
begin
  w := Width;
  h := Height;

  Left := ACenter.X - (w / 2);
  Top  := ACenter.Y - (h / 2);

  Width  := w;
  Height := h;
end;

function TRect2D.GetSize;
begin
  Result := TVector2f[Width, Height];
end;

procedure TRect2D.SetSize;
begin
  Width  := ASize.X;
  Height := ASize.Y;
end;

function TRect2D.GetWidth;
begin
  Result := Right - Left;
end;

procedure TRect2D.SetWidth;
begin
  Right := Left + AWidth;
end;

function TRect2D.GetHeight;
begin
  Result := Bottom - Top;
end;

procedure TRect2D.SetHeight;
begin
  Bottom := Top + AHeight;
end;

function TRect2D.Area;
begin
  Result := Width * Height;
end;

function TRect2D.Radius;
begin
  Result := (Size / 2).Length;
end;
{$ENDREGION}

end.
