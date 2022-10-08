unit libNut.Types.Convert;

{$I libNut.Options.inc}

interface

type
  {$REGION 'TConvert'}
  TConvert<TType> = class abstract
  type
    TFromStrProc = reference to function(const AValue: String): TType;
    TToStrProc   = reference to function(const AValue: TType): String;
  class var
    FromStrProc: TFromStrProc;
    ToStrProc:   TToStrProc;
  public
    class function FromStr(const AValue: String): TType;
    class function ToStr  (const AValue: TType): String;

    class function &To<TResult>(const AValue: TType): TResult;
  end;
  {$ENDREGION}

{$REGION 'Converters'}
function IntToBaseX(const AValue: Int64;  const ABase: Integer = 10; const AMinSize: Integer = 0): String;
function BaseXToInt(const AValue: String; const ABase: Integer = 10; const ADefault: Int64   = 0): Int64;

function IntToStr(const AValue: Int64;  const AMinSize: Integer = 0; const ABase: Integer = 10): String;
function StrToInt(const AValue: String; const ADefault: Int64   = 0): Int64;

function FloatToStr(const AValue: Extended; const APrec:    Integer  = 6): String;
function StrToFloat(const AValue: String;   const ADefault: Extended = 0): Extended;

function BoolToStr(const AValue: Boolean; const ATrue: String = 'True'; const AFalse: String = 'False'): String;
function StrToBool(const AValue: String;  const ADefault: Boolean = False): Boolean;

function PtrToStr(const AValue: Pointer): String;
function StrToPtr(const AValue: String; const ADefault: Pointer = nil): Pointer;

function IntToBin(const AValue: Int64; const AMinSize: Integer = 8): String; inline;
function IntToOct(const AValue: Int64; const AMinSize: Integer = 3): String; inline;
function IntToHex(const AValue: Int64; const AMinSize: Integer = 2): String; inline;
{$ENDREGION}

implementation

uses
  libNut.Types;

{$REGION 'TConvert'}
class function TConvert<TType>.FromStr;
begin
  if Assigned(FromStrProc) then
    Result := FromStrProc(AValue);
end;

class function TConvert<TType>.ToStr;
begin
  if Assigned(ToStrProc) then
    Result := ToStrProc(AValue)
  else
  begin
    var PT: Pointer := TypeInfo(TType);

    // Unsigned
         if PT = TypeInfo(Byte)     then Result := IntToStr(    PByte(@AValue)^)
    else if PT = TypeInfo(Word)     then Result := IntToStr(    PWord(@AValue)^)
    else if PT = TypeInfo(Cardinal) then Result := IntToStr(PCardinal(@AValue)^)
    else if PT = TypeInfo(UInt64)   then Result := IntToStr(  PUInt64(@AValue)^)

    // Unsigned
    else if PT = TypeInfo(ShortInt) then Result := IntToStr(PShortInt(@AValue)^)
    else if PT = TypeInfo(SmallInt) then Result := IntToStr(PSmallInt(@AValue)^)
    else if PT = TypeInfo(Integer)  then Result := IntToStr( PInteger(@AValue)^)
    else if PT = TypeInfo(Int64)    then Result := IntToStr(   PInt64(@AValue)^)

    // Float
    else if PT = TypeInfo(Single)   then Result := FloatToStr(PSingle(@AValue)^)
    else if PT = TypeInfo(Double)   then Result := FloatToStr(PDouble(@AValue)^)
    else if PT = TypeInfo(Extended) then Result := FloatToStr(PExtended(@AValue)^)

    // Pointer
    else if PT = TypeInfo(Pointer) then Result := PtrToStr(PPointer(@AValue)^)

    // Boolean
    else if PT = TypeInfo(Boolean) then Result := BoolToStr(PBoolean(@AValue)^)

    // String
    else if PT = TypeInfo(String) then Result := PString(@AValue)^

    else if PT = TypeInfo(AnsiString)    then Result := String(   PAnsiString(@AValue)^)
    else if PT = TypeInfo(WideString)    then Result := String(   PWideString(@AValue)^)
    else if PT = TypeInfo(UTF8String)    then Result := String(   PUTF8String(@AValue)^)
    else if PT = TypeInfo(RawByteString) then Result := String(PRawByteString(@AValue)^)

    // Object
    else if PTypeInfo(PT)^.Kind = tkClass then Result := PObject(@AValue)^.ToString

    else
      Result := String(PTypeInfo(PT)^.Name);
  end;
end;

class function TConvert<TType>.&To<TResult>;
begin
  Result := TConvert<TResult>.FromStr(ToStr(AValue));
end;
{$ENDREGION}

{$REGION 'Converters'}
const
  BaseXChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

function IntToBaseX;
begin
  Result := '';

  if (ABase > Length(BaseXChars)) or (ABase < 2) then
    Exit;

  var Neg := AValue < 0;
  var Val := Abs(AValue);

  if Val = 0 then
    Result := BaseXChars[1]
  else
    while Val > 0 do
    begin
      Result := BaseXChars[(Val mod Cardinal(ABase)) + 1] + Result;
      Val := Val div Int64(ABase);
    end;

  if AMinSize > 0 then
    while Length(Result) < AMinSize do
      Result := BaseXChars[1] + Result;

  if Neg then
    Result := '-' + Result;
end;

function BaseXToInt;
var
  Valid: String;
  BaseV: Integer;
begin
  if (ABase = 0) or (ABase > Length(BaseXChars)) or (Length(AValue) = 0) then
    Exit(ADefault);

  Valid := Copy(BaseXChars, 1, ABase);

  Result := 0;

  for var C in AValue do
  begin
    if (C = ' ') or (C = ',') then
      Continue;

    BaseV := Pos(C, Valid);

    if BaseV = 0 then
      Exit(ADefault);

    Result := Result * ABase + (BaseV - 1);
  end;
end;

type
  TIntBase = record
    Base:    Integer;
    Prefix:  String;
    Postfix: String;
  end;

const
  IntBases: array[0..7] of TIntBase = (
    (Base:16; Prefix:'0x'; Postfix:''), (Base:16; Prefix:'0'; Postfix:'h'),
    (Base:16; Prefix:'$';  Postfix:''), (Base:16; Prefix:'#'; Postfix:''),
    (Base: 8; Prefix:'0o'; Postfix:''), (Base: 8; Prefix:'0'; Postfix:'o'),
    (Base: 2; Prefix:'0b'; Postfix:''), (Base: 2; Prefix:'0'; Postfix:'b')
  );


function IntToStr;
begin
  Result := IntToBaseX(AValue, ABase, AMinSize);

  for var Base in IntBases do
    if Base.Base = ABase then
      Exit(Base.Prefix + Result + Base.PostFix);
end;

function StrToInt;
var
  V: String;
begin
  Result := ADefault;

  V := '';
  for var C in AValue do
    if (C <> ' ') and (C <> ',') then
      V := V + C;

  if Length(V) = 0 then
    Exit;

  var Neg := V[1] = '-';
  if Neg then
  begin
    V := Copy(V, 2, Length(V));

    if Length(V) = 0 then
      Exit;
  end;

  try
    for var Base in IntBases do
      if (Copy(V, 1, Length(Base.Prefix)) = Base.Prefix) and
         (Copy(V, Length(V) - Length(Base.Postfix) + 1, Length(Base.Postfix)) = Base.Postfix) then
        Exit(BaseXToInt(Copy(V, Length(Base.Prefix) + 1, Length(V) - Length(Base.Prefix) - Length(Base.PostFix)), Base.Base, ADefault));

    Result := BaseXToInt(V, 10, ADefault);
  finally
    if Neg and (Result > 0) then
      Result := -Result;
  end;
end;

function FloatToStr;
var
  S: ShortString;
begin
  Str(AValue:APrec:APrec, S);
  Result := String(S);
end;

function StrToFloat;
var
  ErrCode: Integer;
begin
  Val(AValue, Result, ErrCode);

  if ErrCode <> 0 then
    Result := ADefault;
end;

function BoolToStr;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

function StrToBool;
var
  c1, c2: AnsiChar;
begin
  if Length(AValue) = 0 then
    Exit(ADefault);

  c1 := AnsiChar(AValue[1]);

  if Length(AValue) > 1 then
    c2 := AnsiChar(AValue[2])
  else
    c2 := #0;

  if ((c1 in ['O', 'o']) and (c2 in ['N', 'n', 'K', 'k'])) or
     ((c1 in ['E', 'e']) and (c2 in ['N', 'n'])) or
      (c1 in ['Y', 'y', 'T', 't', #1]) then
    Result := True
  else
    Result := StrToInt(AValue) <> 0;
end;

function PtrToStr;
begin
  Result := IntToStr(UIntPtr(AValue), SizeOf(Pointer) shl 1, 16);
end;

function StrToPtr;
begin
  Result := Pointer(UIntPtr(StrToInt(AValue, UIntPtr(ADefault))));
end;

function IntToBin;
begin
  Result := IntToStr(AValue, AMinSize, 2);
end;

function IntToOct;
begin
  Result := IntToStr(AValue, AMinSize, 8);
end;

function IntToHex;
begin
  Result := IntToStr(AValue, AMinSize, 16);
end;
{$ENDREGION}

initialization
  {$REGION 'Unsigned'}
  TConvert<Byte>    .FromStrProc := function(const AValue: String): Byte     begin Result := StrToInt(AValue) end;
  TConvert<Word>    .FromStrProc := function(const AValue: String): Word     begin Result := StrToInt(AValue) end;
  TConvert<Cardinal>.FromStrProc := function(const AValue: String): Cardinal begin Result := StrToInt(AValue) end;
  TConvert<UInt64>  .FromStrProc := function(const AValue: String): Uint64   begin Result := StrToInt(AValue) end;
  {$ENDREGION}

  {$REGION 'Signed'}
  TConvert<ShortInt>.FromStrProc := function(const AValue: String): ShortInt begin Result := StrToInt(AValue) end;
  TConvert<SmallInt>.FromStrProc := function(const AValue: String): SmallInt begin Result := StrToInt(AValue) end;
  TConvert<Integer> .FromStrProc := function(const AValue: String): Integer  begin Result := StrToInt(AValue) end;
  TConvert<Int64>   .FromStrProc := function(const AValue: String): Int64    begin Result := StrToInt(AValue) end;
  {$ENDREGION}

  {$REGION 'Float'}
  TConvert<Single>  .FromStrProc := function(const AValue: String): Single   begin Result := StrToFloat(AValue) end;
  TConvert<Double>  .FromStrProc := function(const AValue: String): Double   begin Result := StrToFloat(AValue) end;
  TConvert<Extended>.FromStrProc := function(const AValue: String): Extended begin Result := StrToFloat(AValue) end;
  {$ENDREGION}

  {$REGION 'Pointer'}
  TConvert<Pointer>.FromStrProc := function(const AValue: String): Pointer begin Result := StrToPtr(AValue) end;
  {$ENDREGION}

  {$REGION 'Boolean'}
  TConvert<Boolean>.FromStrProc := function(const AValue: String): Boolean begin Result := StrToBool(AValue) end;
  {$ENDREGION}

  {$REGION 'String'}
  TConvert<String>       .FromStrProc := function(const AValue: String): String        begin Result := String       (AValue) end;
  TConvert<AnsiString>   .FromStrProc := function(const AValue: String): AnsiString    begin Result := AnsiString   (AValue) end;
  TConvert<WideString>   .FromStrProc := function(const AValue: String): WideString    begin Result := WideString   (AValue) end;
  TConvert<UTF8String>   .FromStrProc := function(const AValue: String): UTF8String    begin Result := UTF8String   (AValue) end;
  TConvert<RawByteString>.FromStrProc := function(const AValue: String): RawByteString begin Result := RawByteString(AValue) end;
  {$ENDREGION}
end.
