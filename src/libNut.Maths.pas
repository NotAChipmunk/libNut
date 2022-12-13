unit libNut.Maths;

{$I libNut.Options.inc}

interface

type
  TSign = (Neg = -1, Zero = 0, Pos = 1);

const
  PI2 = PI * 2;

{$REGION 'Range'}
function Min(const A, B: Int64):    Int64;    overload;
function Min(const A, B: Extended): Extended; overload;

function Max(const A, B: Int64):    Int64;    overload;
function Max(const A, B: Extended): Extended; overload;

function Clamp(const AValue, AMin, AMax: Int64):    Int64;    overload;
function Clamp(const AValue, AMin, AMax: Extended): Extended; overload;

function ClampDelta(var AValue, ALength: Int64;    const AMin, AMax: Int64):    Int64;    overload;
function ClampDelta(var AValue, ALength: Extended; const AMin, AMax: Extended): Extended; overload;
{$ENDREGION}

{$REGION 'Rounding'}
function Ceil     (const AValue: Extended): Int64;
function Floor    (const AValue: Extended): Int64;
function CeilFloor(const AValue: Extended): Int64;

function UnitToByte(const AValue: Extended): Byte;
function ByteToUnit(const AValue: Byte):     Single; inline;
{$ENDREGION}

{$REGION 'Sign'}
function Sign(const AValue: Int64):    TSign; overload;
function Sign(const AValue: Extended): TSign; overload;
{$ENDREGION}

{$REGION 'Interpolation'}
function LinearStep  (const APoint: Extended; const AMin: Extended = 0; const AMax: Extended = 1): Extended;
function SmoothStep  (const APoint: Extended; const AMin: Extended = 0; const AMax: Extended = 1): Extended;
function SmootherStep(const APoint: Extended; const AMin: Extended = 0; const AMax: Extended = 1): Extended;
function CosStep     (const APoint: Extended; const AMin: Extended = 0; const AMax: Extended = 1): Extended;
function BellStep    (const APoint: Extended; const AMin: Extended = 0; const AMax: Extended = 1): Extended;

function Lerp(const AMin, AMax, APoint: Extended): Extended;

function Map(const AValue, AFromLow, AFromHigh, AToLow, AToHigh: Extended): Extended;
{$ENDREGION}

{$REGION 'Geometric'}
function DegToRad(const ADeg: Extended): Extended;
function RadToDeg(const ARad: Extended): Extended;

function NormToRad(const ANorm: Extended): Extended;
function RadToNorm(const ARad:  Extended): Extended;

procedure SinCos(const ATheta: Extended; var ASin, ACos: Extended); inline;
{$ENDREGION}

{$REGION 'Exponent'}
function Pow(const ABase, AExponent: Extended): Extended;
{$ENDREGION}

implementation

{$REGION 'Range'}
function Min(const A, B: Int64): Int64;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Min(const A, B: Extended): Extended;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Max(const A, B: Int64): Int64;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function Max(const A, B: Extended): Extended;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function Clamp(const AValue, AMin, AMax: Int64): Int64;
begin
  if AValue < AMin then
    Result := AMin
  else if AValue > AMax then
    Result := AMax
  else
    Result := AValue;
end;

function Clamp(const AValue, AMin, AMax: Extended): Extended;
begin
  if AValue < AMin then
    Result := AMin
  else if AValue > AMax then
    Result := AMax
  else
    Result := AValue;
end;

function ClampDelta(var AValue, ALength: Int64; const AMin, AMax: Int64): Int64;
begin
  Result := 0;

  if AValue < AMin then
  begin
    Result  := AMin - AValue;
    ALength := ALength - Result;
    AValue  := AMin;
  end;

  if (AValue + ALength) > AMax then
    ALength := AMax - AValue;

  if ALength < 0 then
    ALength := 0;
end;

function ClampDelta(var AValue, ALength: Extended; const AMin, AMax: Extended): Extended;
begin
  Result := 0;

  if AValue < AMin then
  begin
    Result  := AMin - AValue;
    ALength := ALength - Result;
    AValue  := AMin;
  end;

  if (AValue + ALength) > AMax then
    ALength := AMax - AValue;

  if ALength < 0 then
    ALength := 0;
end;
{$ENDREGION}

{$REGION 'Rounding'}
function Ceil;
begin
  Result := Trunc(AValue);

  if Frac(AValue) > 0 then
    Inc(Result);
end;

function Floor;
begin
  Result := Trunc(AValue);

  if Frac(AValue) < 0 then
    Dec(Result);
end;

function CeilFloor;
var
  F: Extended;
begin
  Result := Trunc(AValue);

  F := Frac(AValue);

  if F > 0 then
    Inc(Result)
  else if F < 0 then
    Dec(Result);
end;

function UnitToByte;
begin
  if AValue >= 1 then
    Result := 255
  else if AValue <= 0 then
    Result := 0
  else
    Result := Round(255 * AValue);
end;

function ByteToUnit;
begin
  Result := AValue / 255;
end;
{$ENDREGION}

{$REGION 'Sign'}
function Sign(const AValue: Int64): TSign;
begin
  if AValue < 0 then
    Result := TSign.Neg
  else if AValue > 0 then
    Result := TSign.Pos
  else
    Result := TSign.Zero;
end;

function Sign(const AValue: Extended): TSign;
begin
  if AValue < 0 then
    Result := TSign.Neg
  else if AValue > 0 then
    Result := TSign.Pos
  else
    Result := TSign.Zero;
end;
{$ENDREGION}

{$REGION 'Interpolation'}
function LinearStep;
begin
  if APoint <= AMin then
    Exit(0);

  if APoint >= AMax then
    Exit(1);

  Result := (APoint - AMin) / (AMax - AMin);
end;

function SmoothStep;
begin
  Result := LinearStep(APoint, AMin, AMax);
  Result := Result * Result * (3 - 2 * Result);
end;

function SmootherStep;
begin
  Result := LinearStep(APoint, AMin, AMax);
  Result := Result * Result * Result * (Result * (Result * 6 - 15) + 10);
end;

function CosStep;
begin
  Result := LinearStep(APoint, AMin, AMax);
  Result := (1 - Cos(Result * PI)) * 0.5;
end;

function BellStep;
begin
  Result := LinearStep(APoint, AMin, AMax);
  Result := (1 - Cos(Result * PI * 2)) * 0.5;
end;

function Lerp;
begin
  Result := AMin + (AMax - AMin) * APoint;
end;

function Map;
begin
  Result := (((AToHigh - AToLow) / (AFromHigh - AFromLow)) * AValue) + AToLow;
end;
{$ENDREGION}

{$REGION 'Geometric'}
function DegToRad;
begin
  Result := ADeg * (PI / 180);
end;

function RadToDeg;
begin
  Result := ARad * (180 / PI);
end;

function NormToRad;
begin
  Result := ANorm * PI2;
end;

function RadToNorm;
begin
  Result := ARad / PI2;
end;

procedure SinCos;
{$IF SizeOf(Extended) > SizeOf(Double)}
begin
  SineCosine(ATheta, ASin, ACos);
{$ELSE}
var
  S, C: Double;
begin
  SineCosine(ATheta, S, C);

  ASin := S;
  ACos := C;
{$ENDIF}
end;
{$ENDREGION}

{$REGION 'Exponent'}
function Pow;
begin
  if AExponent = 0 then
    Result := 1
  else if (ABase = 0) and (AExponent > 0) then
    Result := 0
  else
  begin
    Result := Exp(Abs(Ln(ABase)) * Abs(AExponent));

    if ABase     < 0 then Result := -1 * Result;
    if AExponent < 0 then Result :=  1 / Result;
  end;
end;
{$ENDREGION}

end.
