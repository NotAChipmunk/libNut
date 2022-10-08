unit libNut.Cadencer;

{$I libNut.Options.inc}

interface

uses
  libNut.Types,
  libNut.Timing;

type
  TOnTick = reference to function(const ADelta: TTime): Boolean;

  {$REGION 'TCadencer'}
  TCadencer = record
  private
    FTickDelta:  TTime;
    FDeltaTotal: TTime;
    FDelta:      TTime;

    FTickCount:  Integer;

    FElapsed:     TStopwatch;
    FTPSTimer:    TStopwatch;
    FTickTimer:   TStopwatch;
    FUpdateTimer: TStopwatch;

    FOnTick:   TOnTick;
    FOnUpdate: TProcedure;

    function GetElapsed: TTime; inline;
  public
    Speed:      Double;
    Throttle:   TTime;
    TargetTPS:  Double;

    TicksPerSecond: Integer;
    SecondsPerTick: TTime;

    class function Create: TCadencer; static;

    procedure Reset;

    function Update: Boolean;

    property Elapsed: TTime read GetElapsed;

    property OnTick:   TOnTick    read FOnTick   write FOnTick;
    property OnUpdate: TProcedure read FOnUpdate write FOnUpdate;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Platform,
  libNut.Types.Convert;

{$REGION 'TCadencer'}
function TCadencer.GetElapsed;
begin
  Result := FElapsed.Elapsed;
end;

class function TCadencer.Create;
begin
  FillChar(Result, SizeOf(Result), 0);

  Result.Speed     := 1;
  Result.TargetTPS := 60;
end;

procedure TCadencer.Reset;
begin
  inherited;

  FTickCount := 0;

  TicksPerSecond := 0;
  SecondsPerTick := 0;

  FTickDelta  := 1;
  FDeltaTotal := 0;

  FElapsed.Reset;
  FTPSTimer.Reset;
  FTickTimer.Reset;
  FUpdateTimer.Reset;
end;

function TCadencer.Update;
var
  TPSTime: TTime;
begin
  SecondsPerTick := FTickTimer.Reset;

  FDelta      := Speed * TargetTPS * SecondsPerTick;
  FDeltaTotal := FDeltaTotal + FDelta;

  if not Assigned(FOnTick) then
    Exit(False);

  Result := FOnTick(FDelta);
  if not Result then
    Exit;

  Inc(FTickCount);

  TPSTime := FTPSTimer.Elapsed;

  if TPSTime >= 1 then
  begin
    FTPSTimer.Reset;

    TicksPerSecond := Round(FTickCount / TPSTime);
    FTickDelta     := FDeltaTotal / FTickCount;

    FTickCount  := 0;
    FDeltaTotal := 0;

    if Assigned(OnUpdate) then
      OnUpdate;
  end;

  if Throttle > 0 then
    &Platform.Sleep(Throttle);
end;
{$ENDREGION}

end.
