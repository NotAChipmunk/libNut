unit libNut.Strings;

{$I libNut.Options.inc}

interface

type
  {$REGION 'TStringHelper'}
  TStringHelper = record helper for String
  private
    function  GetChar(const AIndex: Integer): Char;
    procedure SetChar(const AIndex: Integer; const AChar: Char);

    function  GetLength: Integer;                inline;
    procedure SetLength(const ALength: Integer); inline;

    function  GetSize: Integer;              inline;
    procedure SetSize(const ASize: Integer); inline;
  public const
    CharsAlphaUpper   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    CharsAlphaLower   = 'abcdefghijklmnopqrstuvwxyz';
    CharsAlpha        = CharsAlphaUpper + CharsAlphaLower;
    CharsNumeric      = '0123456789';
    CharsAlphaNumeric = CharsAlpha + CharsNumeric;

    CharsAccentUpper = '¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷Ÿ⁄€‹›ﬁ';
    CharsAccentLower = '‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˘˙˚¸˝˛';

    CharsUpper = CharsAlphaUpper + CharsAccentUpper;
    CharsLower = CharsAlphaLower + CharsAccentLower;

    CharsHex = '0123456789ABCDEF';

    CharsQuote = '`"''';

    CharCR    = #13;
    CharLF    = #10;
    CharsCRLF = CharCR + CharLF;

    CharNull = #0;

    CharSpace = #32;
    CharTab   = #9;

    CharsWhiteSpace = CharSpace + CharTab + CharsCRLF;

    CharsIdentStart = '_' + CharsAlpha;
    CharsIdent      = CharsIdentStart + CharsNumeric;
    CharsIdentObj   = CharsIdent + '.';
  public type
    TSplitProc      = reference to procedure(const AToken: String);
    TSplitNamedProc = reference to procedure(const AName, AValue: String);
  public
    property Chars[const AIndex: Integer]: Char  read GetChar write SetChar;

    function FirstChar: Char; inline;
    function LastChar:  Char; inline;

    property Length: Integer read GetLength write SetLength;
    property Size:   Integer read GetSize   write SetSize;

    function IsEmpty:    Boolean; inline;
    function IsNotEmpty: Boolean; inline;

    procedure Clear;

    function Compare(const AStr: String; const AIgnoreCase: Boolean = False): Integer;
    function Same   (const AStr: String; const AIgnoreCase: Boolean = False): Boolean; inline;
    function Like   (const AStr: String; const AIgnoreCase: Boolean = True):  Extended;
    function Match  (const AStr: String; const AIgnoreCase: Boolean = False): Boolean;

    function Pos     (const AStr: String; const AStart: Integer = 1; const AIgnoreCase: Boolean = False; const AOutOfQuotes: Boolean = False): Integer;
    function Contains(const AStr: String; const AStart: Integer = 1; const AIgnoreCase: Boolean = False; const AOutOfQuotes: Boolean = False): Boolean; inline;

    function StartsWith(const AStr: String; const AIgnoreCase: Boolean = False; const ARemoveIfFound: Boolean = False): Boolean;
    function EndsWith  (const AStr: String; const AIgnoreCase: Boolean = False; const ARemoveIfFound: Boolean = False): Boolean;

    function IndexOf(const AStrs: array of String; const AIgnoreCase: Boolean = False): Integer;

    function ValidChars(const AValidChars: String; const AIgnoreCase: Boolean = False): Boolean;

    function SplitFirst(const ADelim: String = ' '; const ATrim: Boolean = True; const AOutOfQuotes: Boolean = False): String;
    function Split     (const ADelim: String = ' '; const ATrim: Boolean = True; const AOutOfQuotes: Boolean = False): TArray<String>;

    function SplitToken(const ARemove: Boolean = True): String;

    procedure SplitProc(const ASplitProc: TSplitProc; const ADelim: String = ' '; const AOutOfQuotes: Boolean = False);
    procedure SplitNamedProc(const ASplitNamedProc: TSplitNamedProc; const ADelim: String = ';'; const ASep: String = ':'; const AOutOfQuotes: Boolean = False);

    function Copy(const AIndex: Integer; const ACount: Integer = -1): String;

    function Start(const ACount: Integer): String; inline;

    function LTrim: String;
    function RTrim: String;
    function Trim(const AEnable: Boolean = true): String; inline;

    function Tidy: String;

    function TidyNumeric(const APlaces: Integer = 0): String;

    function Quote(const AQuote: Char = '"'): String;
    function Unquote: String;

    function Insert(const AStr: String; const AIndex: Integer): String; inline;
    function Delete(const AIndex, ACount: Integer): String; inline;

    function Replace(const AFindStr, AReplaceStr: String; const AStart: Integer = 1; const AIgnoreCase: Boolean = False; const AOutOfQuotes: Boolean = False): String;

    function LAlign(const AMask: String): String;
    function RAlign(const AMask: String): String;
    function CAlign(const AMask: String): String;

    function Uppercase(const AEnable: Boolean = True): String;
    function Lowercase(const AEnable: Boolean = True): String;
    function Capitalize: String;

    function Remap(const ACharsFrom, ACharsTo: String): String;

    function UTF8: UTF8String; inline;

    function Repeated(const ATimes: Integer): String;

    function Append(const AStr: String; const ASep: String = ' '): String;

    function UnicodeMathOffset(const ABase: Integer; const ATable: String = CharsAlpha): String;
    function UnicodeFont      (const ASansSerif: Boolean = False; const ABold: Boolean = False; const AItalic: Boolean = False): String;

    function Script:    String; inline;
    function Frakture:  String; inline;
    function Monospace: String; inline;

    function ToInteger(const ADefault: Int64    = 0):     Int64;    inline;
    function ToFloat  (const ADefault: Extended = 0):     Extended; inline;
    function ToBoolean(const ADefault: Boolean  = False): Boolean;  inline;
    function ToPointer(const ADefault: Pointer  = nil):   Pointer;  inline;

    class function FromInteger(const AValue: Int64;    const AMinSize: Integer = 0; const ABase: Integer = 10):       String; static; inline;
    class function FromFloat  (const AValue: Extended; const APrec: Integer = 6):                                     String; static; inline;
    class function FromBoolean(const AValue: Boolean;  const ATrue: String = 'True'; const AFalse: String = 'False'): String; static; inline;
    class function FromPointer(const AValue: Pointer):                                                                String; static; inline;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Types.Convert;

{$REGION 'TStringHelper'}
function TStringHelper.GetChar;
begin
  if AIndex > Length then
    Result := #0
  else
    Result := Self[AIndex];
end;

procedure TStringHelper.SetChar;
begin
  if (AIndex > 0) and (AIndex <= Length) then
    Self[AIndex] := AChar;
end;

function TStringHelper.GetLength;
begin
  Result := System.Length(Self);
end;

procedure TStringHelper.SetLength;
begin
  System.SetLength(Self, ALength);
end;

function TStringHelper.GetSize;
begin
  Result := Length * SizeOf(Char);
end;

procedure TStringHelper.SetSize;
begin
  Length := ASize div SizeOf(Char);
end;

function TStringHelper.FirstChar;
begin
  Result := Chars[1];
end;

function TStringHelper.LastChar;
begin
  Result := Chars[Length];
end;

function TStringHelper.IsEmpty;
begin
  Result := Length = 0;
end;

function TStringHelper.IsNotEmpty;
begin
  Result := Length > 0;
end;

procedure TStringHelper.Clear;
begin
  if IsEmpty then
    Exit;

  FillChar(PChar(@Self[1])^, Size, $00);
  Self := '';
end;

function TStringHelper.Compare;
var
  s1, s2: String;
begin
  Result := 0;

  s1 := Self.Lowercase(AIgnoreCase);
  s2 := AStr.Lowercase(AIgnoreCase);

  if s1.IsEmpty and s2.IsEmpty then
    Exit(0);

  if s1.Length > s2.Length then
    Exit(1)
  else if s1.Length < s2.Length then
    Exit(-1);

  for var i := 1 to s1.Length do
  begin
    Result := Ord(s1[i]) - Ord(s2[i]);

    if Result <> 0 then
      Exit;
  end;
end;

function TStringHelper.Same;
begin
  Result := Compare(AStr, AIgnoreCase) = 0;
end;

function TStringHelper.Like;
var
  S1, S2:   String;
  MaxRange: Byte;

  procedure Prepare(var St1: String; const St2: String);
  var
    i: Byte;
  begin
    i := 1;

    while i <= St1.Length do
      if St2.Pos(St1.Chars[i]) = 0 then
        St1 := St1.Delete(i, 1)
      else
        Inc(i);
  end;

  procedure SubMatch(Elem, CurPos, Len: Integer);
  begin
    if (Len + S1.Length - Elem + 1 <= MaxRange) or (Len + S2.Length - CurPos + 1 <= MaxRange) then
      Exit;

    if (CurPos > S2.Length) or (Elem > S1.Length) then
    begin
      if Len > MaxRange then
        MaxRange := Len;

      Exit;
    end;

    if S1.Chars[Elem] = S2.Chars[CurPos] then
      SubMatch(Elem + 1, CurPos + 1, Len + 1)
    else
    begin
      SubMatch(Elem + 1, CurPos,     Len);
      SubMatch(Elem,     CurPos + 1, Len);
    end;
  end;
begin
  if IsEmpty or AStr.IsEmpty then
    Exit(-1);

  S1 := LowerCase(AIgnoreCase);
  S2 := AStr.LowerCase(AIgnoreCase);

  Prepare(S1, S2);
  Prepare(S2, S1);

  MaxRange := 0;
  SubMatch(1, 1, 0);

  if Length > AStr.Length then
    Result := MaxRange / Length
  else
    Result := MaxRange / AStr.Length;
end;

function TStringHelper.Match;
var
  MStr, CStr: String;

  function Comp(MaskI, StrI: Integer): Boolean;
  begin
    if MaskI > MStr.Length then
      Exit(StrI = CStr.Length + 1);

    if StrI > CStr.Length then
      Exit(False);

    var m := MStr.Chars[MaskI];

    if m = '*' then
      Result := Comp(Succ(MaskI), Succ(StrI)) or Comp(MaskI, Succ(StrI))
    else if (m = '?') or (m = cStr.Chars[StrI]) then
      Result := Comp(Succ(MaskI), Succ(StrI))
    else
      Result := False;
  end;
begin
  if AStr.Copy(1, 1) = '!' then
    Result := Contains(AStr.Copy(2), 1, AIgnoreCase)
  else
  begin
    CStr := LowerCase(AIgnoreCase);
    MStr := AStr.LowerCase(AIgnoreCase);

    Result := Comp(1, 1);
  end;
end;

function TStringHelper.Pos;
begin
  if AOutOfQuotes then
  begin
    var q: Char := #0;

    for var i := AStart to Length do
      if q <> #0 then
      begin
        if Self.Chars[i] = q then
          q := #0;
      end
      else if System.Pos(Self.Chars[i], CharsQuote) > 0 then
        q  := Self.Chars[i]
      else if Copy(i, AStr.Length).Same(AStr, AIgnoreCase) then
        Exit(i);
  end
  else
    for var i := AStart to Length do
      if Copy(i, AStr.Length).Same(AStr, AIgnoreCase) then
        Exit(i);

  Result := 0;
end;

function TStringHelper.Contains;
begin
  Result := Pos(AStr, AStart, AIgnoreCase, AOutOfQuotes) > 0;
end;

function TStringHelper.StartsWith;
begin
  Result := Copy(1, AStr.Length).Compare(AStr, AIgnoreCase) = 0;

  if Result and ARemoveIfFound then
    Self := Copy(AStr.Length + 1);
end;

function TStringHelper.EndsWith;
begin
  Result := Copy(1 + Length - AStr.Length, AStr.Length).Compare(AStr, AIgnoreCase) = 0;

  if Result and ARemoveIfFound then
    Self := Copy(1, Length - AStr.Length);
end;

function TStringHelper.IndexOf;
begin
  for var i := Low(AStrs) to High(AStrs) do
    if Compare(AStrs[i], AIgnoreCase) = 0 then
      Exit((i - Low(AStrs)) + 1);

  Result := 0;
end;

function TStringHelper.ValidChars;
begin
  for var C in Self do
    if AValidChars.Pos(String(C)) = 0 then
      Exit(False);

  Result := True;
end;

function TStringHelper.SplitFirst;
begin
  Self := Self.Trim(ATrim);

  var i := Pos(ADelim, 1, False, AOutOfQuotes);

  if i = 0 then
  begin
    Result := Self;
    Self   := '';
  end
  else
  begin
    Result := Copy(1, i - 1).Trim(ATrim);
    Self   := Copy(i + ADelim.Length).Trim(ATrim);
  end;

  if AOutOfQuotes then
    Result := Result.Unquote;
end;

function TStringHelper.Split;
begin
  var s := Self.Trim(ATrim);

  while not s.IsEmpty do
  begin
    var e := s.SplitFirst(ADelim, ATrim, AOutofQuotes);

    if not e.IsEmpty then
    begin
      System.SetLength(Result, System.Length(Result) + 1);

      Result[High(Result)] := e;
    end
    else
      Break;
  end;
end;

function TStringHelper.SplitToken;
const
  DblTokens: array[0..19] of String{$IFDEF MSWINDOWS}[2]{$ENDIF} = (
    '<>', '==', '!=', '<=', '>=', '<<', '>>', '&&', '||', '+=', '-=',
    '++', '--', '&=', '^=', '|=', ':=', '/*', '*/', '//'
  );
begin
  Result := '';

  if IsEmpty then
    Exit;

  var i := 1;

  if CharsWhitespace.Contains(Self.Chars[i]) then
    while (i < Length) and CharsWhitespace.Contains(Self.Chars[i]) do
      Inc(i);

  if i > Length then
    Exit;

  var c := Self.Chars[i];

  if CharsQuote.Contains(c) then
  begin
    repeat
      Result := Result + Self.Chars[i];

      Inc(i);

      if Self.Chars[i] = c then
      begin
        Inc(i);
        Break;
      end;
    until i > Length;

    if Result.Chars[Result.Length] <> c then
      Result := Result + c;
  end
  else if CharsNumeric.Contains(c) then
  begin
    var f := False;

    repeat
      Result := Result + Self.Chars[i];

      Inc(i);

      if i > Length then
        Break;

      if (not f) and (Self.Chars[i] = '.') then
      begin
        Result := Result + '.';
        f      := True;

        Inc(i);
      end
    until (i > Length) or (not CharsNumeric.Contains(Self.Chars[i]))
  end
  else if CharsIdentStart.Contains(c) then
    repeat
      Result := Result + Self.Chars[i];

      Inc(i);
    until (i > Length) or (not (CharsIdent + '.').Contains(Self.Chars[i]))
  else
  begin
    Result := c;
    Inc(i);

    if i < Length then
      for var j := Low(DblTokens) to High(DblTokens) do
        if (String(DblTokens[j]).Chars[1] = c) and (String(DblTokens[j]).Chars[2] = Self[i]) then
        begin
          Result := Result + Self.Chars[i];
          Inc(i);
          Break;
        end;
  end;

  if ARemove then
    Self := Copy(i).Trim;
end;

procedure TStringHelper.SplitProc;
var
  S, V: String;
begin
  S := Self;

  while S.IsNotEmpty do
  begin
    V := S.SplitFirst(ADelim, True, AOutOfQuotes);

    if V.IsEmpty then
      Continue;

    ASplitProc(V);
  end;
end;

procedure TStringHelper.SplitNamedProc;
begin
  SplitProc(procedure(const AToken: String)
  var
    V, N: String;
  begin
    V := AToken;
    N := V.SplitFirst(ASep, True, AOutOfQuotes);
    ASplitNamedProc(N, V);
  end, ADelim, AOutOfQuotes);
end;

function TStringHelper.Copy;
begin
  if ACount = -1 then
    Result := System.Copy(Self, AIndex, Length)
  else
    Result := System.Copy(Self, AIndex, ACount);
end;

function TStringHelper.Start;
begin
  if ACount < 0 then
    Result := Copy(1, Length + ACount)
  else
    Result := Copy(1, ACount);
end;

function TStringHelper.LTrim;
var
  i: Integer;
begin
  for i := 1 to Length do
    if CharsWhitespace.Pos(Self.Chars[i]) = 0 then
      Break;

  Result := Copy(i);
end;

function TStringHelper.RTrim;
var
  i: Integer;
begin
  for i := Length downto 1 do
    if CharsWhitespace.Pos(Self.Chars[i]) = 0 then
      Break;

  Result := Copy(1, i);
end;

function TStringHelper.Trim;
begin
  if AEnable then
    Result := Self.LTrim.RTrim
  else
    Result := Self;
end;

function TStringHelper.Tidy;
var
  i: Integer;
  c: Char;

  function SkipWhitespace: Boolean;
  begin
    Result := CharsWhitespace.Contains(c);

    if not Result then
      Exit;

    while (i <= Length) and CharsWhitespace.Contains(Self.Chars[i]) do
      Inc(i);

    i := i - 1;
  end;
begin
  Result := '';

  if IsEmpty then
    Exit;

  i := 1;
  var q := #0;

  repeat
    c := Self.Chars[i];

    if q <> #0 then
    begin
      if c = q then
        q := #0;

      Result := Result + c;
    end
    else
    begin
      var w := SkipWhitespace;

      if i > Length then
        Break;

      if w then
        c := Self.Chars[i];

      if CharsQuote.Contains(c) then
        q := c;

      if CharsWhitespace.Contains(c) then
        c := #32;

      Result := Result + c;
    end;

    Inc(i);
  until i > Length;

  Result := Result.Trim;
end;

function TStringHelper.TidyNumeric;
begin
  Result := Trim;

  if Result.Pos('.') > 0 then
  begin
    while Result.LastChar = '0' do
      Result := Result.Copy(1, Result.Length - 1);

    if Result.LastChar = '.' then
      Result := Result.Copy(1, Result.Length - 1);
  end;

  while (not Result.IsEmpty) and (Result.FirstChar = '0') do
    Result := Result.Copy(2);

  var i := Result.Pos('.') - 1;

  if i < 1 then
    i := Result.Length;

  repeat
    i := i - 3;

    if i < 1 then
      Break;

    Result := Result.Insert(',', i);
  until False;

  if Result.IsEmpty or (Result.FirstChar = '.') then
    Result := '0' + Result;

  if APlaces > 0 then
  begin
    var Mask := String('0').Repeated(APlaces);

    i := Result.Pos('.');

    if i = 0 then
      Result := Result + '.' + Mask
    else
    begin
      var D := Result.SplitFirst('.');

      Result := D + '.' + Result.LAlign(Mask).Copy(1, APlaces);
    end;
  end;
end;

function TStringHelper.Quote;
begin
  Result := Trim;

  if Result.IsEmpty then
    Exit(AQuote + AQuote);

  if Result.FirstChar <> AQuote then
    Result := AQuote + Result;

  if Result.LastChar <> AQuote then
    Result := Result + AQuote;
end;

function TStringHelper.Unquote;
begin
  Result := Trim;

  if Result.IsEmpty then
    Exit;

  var q := Result.FirstChar;

  if CharsQuote.Contains(q) then
  begin
    Result := Result.Copy(2);
    if Result.IsEmpty then
      Exit;

    if Result.LastChar = q then
      Result := Result.Copy(1, Result.Length - 1);
  end;
end;

function TStringHelper.Insert;
begin
  Result := Copy(1, AIndex) + AStr + Copy(AIndex + 1);
end;

function TStringHelper.Delete;
begin
  Result := Copy(1, AIndex - 1) + Copy(AIndex + ACount);
end;

function TStringHelper.Replace;
begin
  Result := Self;
  var p := AStart;

  var i := Result.Pos(AFindStr, p, AIgnoreCase, AOutOfQuotes);

  while i > 0 do
  begin
    Result := Result.Copy(1, i - 1) + AReplaceStr + Result.Copy(i + AFindStr.Length);

    p := p + AReplaceStr.Length + 1;
    i := Result.Pos(AFindStr, p, AIgnoreCase, AOutOfQuotes);
  end;
end;

function TStringHelper.LAlign;
begin
  Result := AMask;

  for var i := 1 to Length do
    if i > Result.Length then
      Exit
    else
      Result.Chars[i] := Self.Chars[i];
end;

function TStringHelper.RAlign;
begin
  Result := AMask;

  for var i := 1 to Length do
  begin
    var j := Result.Length - i + 1;

    if j < 1 then
      Exit;

    Result.Chars[j] := Self.Chars[Length - i + 1];
  end;
end;

function TStringHelper.CAlign;
begin
  Result := AMask;

  for var i := 1 to Length do
  begin
    var j := ((AMask.Length shr 1) - (Length shr 1) + i);

    if j < 1 then
      Continue
    else if j > Result.Length then
      Exit;

    Result.Chars[j] := Self.Chars[i];
  end;
end;

function TStringHelper.Uppercase;
begin
  Result := Self;

  if AEnable then
    Result := Result.Remap(CharsLower, CharsUpper);
end;

function TStringHelper.Lowercase;
begin
  Result := Self;

  if AEnable then
    Result := Result.Remap(CharsUpper, CharsLower);
end;

function TStringHelper.Capitalize;
var
  j: Integer;
begin
  Result := Self.Lowercase;

  for var i := 1 to Result.Length do
  begin
    j := System.Pos(Result[i], CharsLower);
    if j > 0 then
    begin
      Result[i] := CharsUpper[j];
      Break;
    end;
  end;
end;

function TStringHelper.Remap;
var
  j: Integer;
begin
  Result := Self;

  if (ACharsFrom.Length <> ACharsTo.Length) or ACharsFrom.IsEmpty then
    Exit;

  for var i := 1 to Length do
  begin
    j := System.Pos(Result[i], ACharsFrom);

    if j > 0 then
      Result[i] := ACharsTo[j];
  end;
end;

function TStringHelper.UTF8;
begin
  Result := UTF8String(Self);
end;

function TStringHelper.Repeated;
begin
  Result := '';

  for var i := 1 to ATimes do
    Result := Result + Self;
end;

function TStringHelper.Append;
begin
  Result := Self;

  if AStr.IsEmpty then
    Exit;

  if not Result.IsEmpty then
    if not Result.EndsWith(ASep, False, False) then
      Result := Result + ASep;

  Result := Result + AStr;
end;

function TStringHelper.UnicodeMathOffset;
begin
  Result := '';

  for var c in Self do
  begin
    var i := ATable.Pos(c);

    if i > 0 then
      Result := Result + Char($D835) + Char(ABase + i - 1)
    else
      Result := Result + C;
  end;
end;

function TStringHelper.UnicodeFont;
var
  Base: Word;
begin
  if (not ASansSerif) and (not ABold) and (not AItalic) then
    Exit(Self);

  if ASansSerif then
    Base := $DDA0
  else
    Base := $DBCC;

  if ABold then
    Base := Base + $34;

  if AItalic then
    Base := Base + $68;

  Result := UnicodeMathOffset(Base);

  if (not ASansSerif) and (not ABold) then
    Exit;

  if ASansSerif then
    Base := $DFE2
  else
    Base := $DFC4;

  if ABold then
    Base := Base + $A;

  Result := Result.UnicodeMathOffset(Base, CharsNumeric);
end;

function TStringHelper.Script;
begin
  Result := UnicodeMathOffset($DCD0);
end;

function TStringHelper.Frakture;
begin
  Result := UnicodeMathOffset($DD6C);
end;

function TStringHelper.Monospace;
begin
  Result := UnicodeMathOffset($DE70);
  Result := Result.UnicodeMathOffset($DFF6, CharsNumeric);
end;

function TStringHelper.ToInteger;
begin
  Result := StrToInt(Self, ADefault);
end;

function TStringHelper.ToFloat;
begin
  Result := StrToFloat(Self, ADefault);
end;

function TStringHelper.ToBoolean;
begin
  Result := StrToBool(Self, ADefault);
end;

function TStringHelper.ToPointer;
begin
  Result := StrToPtr(Self, ADefault);
end;

class function TStringHelper.FromInteger;
begin
  Result := IntToStr(AValue, AMinSize, ABase);
end;

class function TStringHelper.FromFloat;
begin
  Result := FloatToStr(AValue, APrec);
end;

class function TStringHelper.FromBoolean;
begin
  Result := BoolToStr(AValue, ATrue, AFalse);
end;

class function TStringHelper.FromPointer;
begin
  Result := PtrToStr(AValue);
end;
{$ENDREGION}

end.
