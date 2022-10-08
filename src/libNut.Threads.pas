unit libNut.Threads;

{$I libNut.Options.inc}

interface

uses
  {$IF DEFINED(MSWINDOWS)}
  Winapi.Windows,
  {$ENDIF}

  libNut.Exceptions,
  libNut.Types;

type
  {$REGION 'TRTLCriticalSectionHelper'}
  {$IF DEFINED(MSWINDOWS)}
  TRTLCriticalSectionHelper = record helper for TRTLCriticalSection
    class function Create: TRTLCriticalSection; static;

    procedure Free; inline;

    procedure Enter; inline;
    procedure Leave; inline;

    procedure Section(const AProc: TProcedure);
  end;
  {$ENDIF}
  {$ENDREGION}

  {$REGION 'TThread'}
  TThread = class
  private type
    PFork = ^TFork;
    TFork = record
      Handle: TThreadID;
      Proc:   TProcedure;
    end;

  private
    FHandle:   TThreadID;
    FRunning:  Boolean;
    FExitCode: Integer;

    FFreeOnStop: Boolean;

    class function ForkProc  (AFork:   PFork):   Integer; static;
    class function ThreadProc(AThread: TThread): Integer; static;
  public
    {$IF DEFINED(MSWINDOWS)}
    CriticalSection: TRTLCriticalSection;
    {$ENDIF}

    class procedure Fork(const AProc: TProcedure);

    constructor Create(const AFreeOnStop: Boolean = False);
    destructor  Destroy; override;

    function Execute: Boolean; virtual;

    procedure Start;
    procedure Stop(const AWait: Boolean = True);

    procedure Pause;
    procedure Resume;

    procedure Wait;

    function OnStart: Boolean; virtual;
    function OnStop:  Integer; virtual;

    procedure OnPause;  virtual;
    procedure OnResume; virtual;

    procedure OnException(AException: TException); virtual;

    property Handle:   TThreadID read FHandle;
    property Running:  Boolean   read FRunning;
    property ExitCode: Integer   read FExitCode write FExitCode;

    property FreeOnStop: Boolean read FFreeOnStop write FFreeOnStop;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Platform;

{$REGION 'TRTLCriticalSectionHelper'}
{$IF DEFINED(MSWINDOWS)}
class function TRTLCriticalSectionHelper.Create;
begin
  InitializeCriticalSection(Result);
end;

procedure TRTLCriticalSectionHelper.Free;
begin
  DeleteCriticalSection(Self);
end;

procedure TRTLCriticalSectionHelper.Enter;
begin
  EnterCriticalSection(Self);
end;

procedure TRTLCriticalSectionHelper.Leave;
begin
  LeaveCriticalSection(Self);
end;

procedure TRTLCriticalSectionHelper.Section;
begin
  Enter;
  try
    AProc;
  finally
    Leave;
  end;
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TThread'}
class function TThread.ForkProc;
begin
  try
    AFork^.Proc();
  finally
    Dispose(AFork);

    EndThread(0);
  end;

  Result := 0;
end;

class function TThread.ThreadProc;
begin
  Result := 0;

  try
    if not AThread.OnStart then
      Exit;

    try
      while AThread.FRunning and AThread.Execute do ;
    except on E: TException do
      AThread.OnException(E);
    end;

  finally
    AThread.FHandle  := 0;
    AThread.FRunning := False;

    AThread.FExitCode := AThread.OnStop;

    EndThread(AThread.FExitCode);
  end;
end;

class procedure TThread.Fork;
var
  Fork: PFork;
begin
  New(Fork);

  Fork^.Proc := AProc;

  BeginThread(nil, 0, @ForkProc, Fork, 0, Fork^.Handle)
end;

constructor TThread.Create;
begin
  inherited Create;

  FHandle  := 0;
  FRunning := False;

  {$IF DEFINED(MSWINDOWS)}
  CriticalSection := TRTLCriticalSection.Create;
  {$ENDIF}

  FFreeOnStop := AFreeOnStop;
end;

destructor TThread.Destroy;
begin
  Stop;

  {$IF DEFINED(MSWINDOWS)}
  CriticalSection.Free;
  {$ENDIF}

  inherited;
end;

function TThread.Execute;
begin
  Result := False;
end;

procedure TThread.Start;
begin
  if FHandle <> 0 then
    Exit;

  FRunning := True;

  BeginThread(nil, 0, @ThreadProc, Pointer(Self), 0, FHandle);
end;

procedure TThread.Stop;
begin
  if FHandle = 0 then
    Exit;

  FRunning := False;

  if AWait then
    Wait;
end;

procedure TThread.Pause;
begin
  if FHandle = 0 then
    Exit;

  {$IF DEFINED(MSWINDOWS)}
  SuspendThread(FHandle);
  {$ENDIF}

  OnPause;
end;

procedure TThread.Resume;
begin
  if FHandle = 0 then
    Exit;

  OnResume;

  {$IF DEFINED(MSWINDOWS)}
  ResumeThread(FHandle);
  {$ENDIF}
end;

procedure TThread.Wait;
begin
  while FRunning do
    &Platform.Sleep(100);
end;

function TThread.OnStart;
begin
  Result := True;
end;

function TThread.OnStop;
begin
  Result := FExitCode;
end;

procedure TThread.OnPause;
begin
  {}
end;

procedure TThread.OnResume;
begin
  {}
end;

procedure TThread.OnException;
begin
  &Platform.Exception(AException, ExceptAddr);
end;
{$ENDREGION}

end.
