unit libNut.Timing;

{$I libNut.Options.inc}

interface

uses
  libNut.Types;

type
  {$REGION 'TTimeHelper'}
  TTimeHelper = record helper for TTime
  public const
    MSPerSecond = Int64(1000);
    MSPerMinute = Int64(MSPerSecond * 60);
    MSPerHour   = Int64(MSPerMinute * 60);
    MSPerDay    = Int64(MSPerHour   * 24);
    MSPerWeek   = Int64(MSPerDay    * 7);
    MSPerYear   = Int64(MSPerWeek   * 52);
  public
    class function FromString(const AStr: String): TTime; static;
    function ToString(const AWantMS: Boolean = False): String;
  end;
  {$ENDREGION}

  {$REGION 'TStopwatch'}
  TStopwatch = record
  public
    Start: TTime;

    function Reset: TTime;

    function Elapsed: TTime; inline;

    function Split: TTime; inline;

    function Expired     (const ASeconds: TTime): Boolean;  inline;
    function ExpiredDelta(const ASeconds: TTime): TTime;

    function WaitFor(const ASeconds: TTime; const AResetBefore: Boolean = True; const AResetAfter: Boolean = False): TTime;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Platform,
  libNut.Strings,
  libNut.Types.Convert;

{$REGION 'TTimeHelper'}
class function TTimeHelper.FromString;
var
  S1, S2: String;
  T1, T2: Int64;
begin
  S1 := AStr;

  T1 := 0;

  while not S1.IsEmpty do
  begin
    S2 := S1.SplitToken(True);
    if S2.IsEmpty then
      Break;

    T2 := S2.ToInteger;

    S2 := S1.SplitToken(True).LowerCase;
    if S2.IsEmpty then
      Break;

    if S2 = 'ms' then
      T1 := T1 + T2
    else if S2 = 's' then
      T1 := T1 + (T2 * MSPerSecond)
    else if S2 = 'm' then
      T1 := T1 + (T2 * MSPerMinute)
    else if S2 = 'h' then
      T1 := T1 + (T2 * MSPerHour)
    else if S2 = 'd' then
      T1 := T1 + (T2 * MSPerDay)
    else if S2 = 'w' then
      T1 := T1 + (T2 * MSPerWeek)
    else if S2 = 'y' then
      T1 := T1 + (T2 * MSPerYear);
  end;

  Result := T1 / MSPerSecond;
end;

function TTimeHelper.ToString;
var
  MS: Int64;
  Y, W, D, H, M, S: Integer;

  function GetPeriod(Len: Int64): Int64;
  begin
    if MS >= Len then
    begin
      Result := MS div Len;
      MS     := MS mod Len;
    end
    else
      Result := 0;
  end;
begin
  MS := Round(Self * MSPerSecond);

  Y := GetPeriod(MSPerYear);
  W := GetPeriod(MSPerWeek);
  D := GetPeriod(MSPerDay);
  H := GetPeriod(MSPerHour);
  M := GetPeriod(MSPerMinute);
  S := GetPeriod(MSPerSecond);

  Result := '';

  if Y > 0 then Result := Result.Append(IntToStr(Y) + 'y');
  if W > 0 then Result := Result.Append(IntToStr(W) + 'w');
  if D > 0 then Result := Result.Append(IntToStr(D) + 'd');
  if H > 0 then Result := Result.Append(IntToStr(H) + 'h');
  if M > 0 then Result := Result.Append(IntToStr(M) + 'm');

  if (S > 0) or (Result.IsEmpty and not AWantMS) then
    Result := Result.Append(IntToStr(S) + 's');

  if AWantMS then
    Result := Result.Append(IntToStr(Integer(MS)) + 'ms');
end;
{$ENDREGION}

{$REGION 'TStopwatch'}
function TStopwatch.Reset;
begin
  Result := Elapsed;
  Start  := &Platform.Time;
end;

function TStopwatch.Elapsed;
begin
  Result := &Platform.Time - Start;
end;

function TStopwatch.Split;
begin
  Result := Elapsed;
  Reset;
end;

function TStopwatch.Expired;
begin
  Result := ExpiredDelta(ASeconds) <= 0;
end;

function TStopwatch.ExpiredDelta;
begin
  Result := ASeconds - Elapsed;

  if Result <= 0 then
    Reset;
end;

function TStopwatch.WaitFor;
begin
  if AResetBefore then
    Reset;

  if ASeconds > 0 then
  begin
    while Elapsed < ASeconds do
      &Platform.Sleep(0);

    Result := (Elapsed / ASeconds);
  end
  else
    Result := 1;

  if AResetAfter then
    Reset;
end;
{$ENDREGION}

end.
