unit libNut.Engine;

{$I libNut.Options.inc}

interface

uses
  libNut.Types,
  libNut.Windows,
  libNut.Exceptions,
  libNut.Timing,
  libNut.Maths.Geometry,

  Winapi.Windows,
  Winapi.Messages,
  Winapi.MMSystem;

const
  {$REGION 'VK_PAD'}
  VK_MAX = Word(-1);

  VK_PADA = VK_MAX - 1;
  VK_PADB = VK_MAX - 2;
  VK_PADX = VK_MAX - 3;
  VK_PADY = VK_MAX - 4;

  VK_PADUP    = VK_MAX - 5;
  VK_PADDOWN  = VK_MAX - 6;
  VK_PADLEFT  = VK_MAX - 7;
  VK_PADRIGHT = VK_MAX - 8;

  VK_PADLSTICK = VK_MAX - 9;
  VK_PADRSTICK = VK_MAX - 10;

  VK_PADLSHOULDER = VK_MAX - 11;
  VK_PADRSHOULDER = VK_MAX - 12;

  VK_PADSELECT = VK_MAX - 13;
  VK_PADSTART  = VK_MAX - 14;

  VK_PADFIRST = VK_PADSTART;
  VK_PADLAST  = VK_PADA;
  {$ENDREGION}

type
  TEngine = class;

  {$REGION 'Input'}
  TButtonState = (Up, Released, Pressed, Held);

  TButtonStateHelper = record helper for TButtonState
    function IsUp:       Boolean; inline;
    function IsReleased: Boolean; inline;
    function IsPressed:  Boolean; inline;
    function IsHeld:     Boolean; inline;

    function Down: Boolean; inline;
  end;

  TGamePadID = (None = -1, Pad1, Pad2);

  TInput = record
  private
    FEngine: TEngine;

    FButtons: array[Word] of TButtonState;

    FMousePos:     TVector2f;
    FMousePosLast: TVector2f;
    FMouseScroll:  Integer;
    FMouseOver:    Boolean;

    FGamePad: TGamePadID;

    FPadLStick:   TVector2f;
    FPadRStick:   TVector2f;
    FPadShoulder: Float;

    FPadLStickLast:   TVector2f;
    FPadRStickLast:   TVector2f;
    FPadShoulderLast: Float;

    function GetButtonNoPoll(AButton: Word): TButtonState; inline;

    function GetButtonState(const AButton: Word):    TButtonState;
    function GetButtonBool (const AButton: Integer): Boolean; inline;

    function GetMousePos:  TVector2f;
    function GetMouseOver: Boolean;

    procedure ButtonPressed (const AButton: Word);
    procedure ButtonReleased(const AButton: Word);

    procedure MouseMoved   (const AX, AY: Integer; const AEvent: Boolean = True);
    procedure MouseScrolled(const ADelta: Integer);

    procedure SetGamePad(const AGamePad: TGamePadID);

    function GetGamePadStick(const AIndex: Integer): TVector2f;
    function GetGamePadShoulder: Float;
  public
    procedure PollGamePadButtons(const AEvent: Boolean = False);
    procedure PollGamePadSticks (const AEvent: Boolean = False);

    procedure Reset;
    procedure ResetScroll;

    property Buttons[const AButton: Word]: TButtonState read GetButtonState; default;
    property ButtonsNoPoll[AButton: Word]: TButtonState read GetButtonNoPoll;

    property MousePos:    TVector2f read GetMousePos;
    property MouseScroll: Integer   read FMouseScroll;
    property MouseOver:   Boolean   read GetMouseOver;

    property GamePad: TGamePadID read FGamePad write SetGamePad;

    property GamePadLStick: TVector2f index 0 read GetGamePadStick;
    property GamePadRStick: TVector2f index 1 read GetGamePadStick;

    property GamePadShoulder: Float read GetGamePadShoulder;

    {$REGION 'Buttons'}
    property LMouse: Boolean index VK_LBUTTON read GetButtonBool;
    property MMouse: Boolean index VK_MBUTTON read GetButtonBool;
    property RMouse: Boolean index VK_RBUTTON read GetButtonBool;

    property Up:    Boolean index VK_UP    read GetButtonBool;
    property Down:  Boolean index VK_DOWN  read GetButtonBool;
    property Left:  Boolean index VK_LEFT  read GetButtonBool;
    property Right: Boolean index VK_RIGHT read GetButtonBool;

    property GamePadA: Boolean index VK_PADA read GetButtonBool;
    property GamePadB: Boolean index VK_PADB read GetButtonBool;
    property GamePadX: Boolean index VK_PADX read GetButtonBool;
    property GamePadY: Boolean index VK_PADY read GetButtonBool;

    property GamePadUp:    Boolean index VK_PADUP    read GetButtonBool;
    property GamePadDown:  Boolean index VK_PADDOWN  read GetButtonBool;
    property GamePadLeft:  Boolean index VK_PADLEFT  read GetButtonBool;
    property GamePadRight: Boolean index VK_PADRIGHT read GetButtonBool;

    property GamePadLStickButton: Boolean index VK_PADLSTICK read GetButtonBool;
    property GamePadRStickButton: Boolean index VK_PADLSTICK read GetButtonBool;

    property GamePadLShoulder: Boolean index VK_PADLSHOULDER read GetButtonBool;
    property GamePadRShoulder: Boolean index VK_PADLSHOULDER read GetButtonBool;

    property GamePadSelect: Boolean index VK_PADSELECT read GetButtonBool;
    property GamePadStart:  Boolean index VK_PADSTART  read GetButtonBool;

    property Escape: Boolean index VK_ESCAPE read GetButtonBool;
    property Back:   Boolean index VK_BACK   read GetButtonBool;
    property Enter:  Boolean index VK_RETURN read GetButtonBool;
    property Space:  Boolean index VK_SPACE  read GetButtonBool;
    property Tab:    Boolean index VK_TAB    read GetButtonBool;

    property Shift:  Boolean index VK_SHIFT  read GetButtonBool;
    property LShift: Boolean index VK_LSHIFT read GetButtonBool;
    property RShift: Boolean index VK_RSHIFT read GetButtonBool;

    property Ctrl:  Boolean index VK_CONTROL  read GetButtonBool;
    property LCtrl: Boolean index VK_LCONTROL read GetButtonBool;
    property RCtrl: Boolean index VK_RCONTROL read GetButtonBool;

    property Alt: Boolean index VK_MENU read GetButtonBool;

    property Menu: Boolean index VK_APPS read GetButtonBool;

    property Insert: Boolean index VK_INSERT read GetButtonBool;
    property Delete: Boolean index VK_DELETE read GetButtonBool;
    property Home:   Boolean index VK_HOME   read GetButtonBool;
    property &End:   Boolean index VK_END    read GetButtonBool;
    property PgUp:   Boolean index VK_PRIOR  read GetButtonBool;
    property PgDown: Boolean index VK_NEXT   read GetButtonBool;

    property F1:  Boolean index VK_F1  read GetButtonBool;
    property F2:  Boolean index VK_F2  read GetButtonBool;
    property F3:  Boolean index VK_F3  read GetButtonBool;
    property F4:  Boolean index VK_F4  read GetButtonBool;
    property F5:  Boolean index VK_F5  read GetButtonBool;
    property F6:  Boolean index VK_F6  read GetButtonBool;
    property F7:  Boolean index VK_F7  read GetButtonBool;
    property F8:  Boolean index VK_F8  read GetButtonBool;
    property F9:  Boolean index VK_F9  read GetButtonBool;
    property F10: Boolean index VK_F10 read GetButtonBool;
    property F11: Boolean index VK_F11 read GetButtonBool;
    property F12: Boolean index VK_F12 read GetButtonBool;
    {$ENDREGION}
  end;
  {$ENDREGION}

  {$REGION 'TEngine'}
  TEngine = class(TWindow)
  private
    FTitle: String;

    FScale: Float;

    FWidth:  Integer;
    FHeight: Integer;

    FFullScreen: Boolean;
    FResizeable: Boolean;
    FVSync:      Boolean;

    FSpeed:      TTime;
    FThrottle:   TTime;
    FTargetFPS:  Double;
    FFrameDelta: TTime;

    FUpdateCount: Integer;
    FFrameCount:  Integer;

    FFramesPerSecond: Integer;
    FSecondsPerFrame: TTime;

    FElapsed: TStopwatch;

    FRunning: Boolean;
    FActive:  Boolean;

    FShowFrameDelta:      Boolean;
    FShowFramesPerSecond: Boolean;
    FShowSecondsPerFrame: Boolean;
    FShowElapsed:         Boolean;

    FDeviceContext: HDC;

    procedure SetTitle(const ATitle: String);
    procedure UpdateTitle;

    procedure SetScale(const AScale: Float);

    procedure SetFullScreen(const AFullScreen: Boolean);
    procedure SetResizeable(const AResizeable: Boolean);
  public
    Input: TInput;

    class procedure Run(const AWidth: Integer = 640; const AHeight: Integer = 480; const AScale: Float = 1; const AVSync: Boolean = True; const AFullScreen: Boolean = False; const AResizeable: Boolean = False);

    constructor Create;
    destructor  Destroy; override;

    class procedure InitWindowClass(var AWndClass: WNDCLASSEX); override;
    procedure InitWindowParams(var AParams: TWindowParams);     override;

    procedure SetDisplay(const AWidth, AHeight: Integer; const AScale: Float; const AFullScreen, AResizeable: Boolean); overload; virtual;
    procedure SetDisplay(const AWidth, AHeight: Integer; AScale: Float = 0);                                            overload;

    procedure Start;
    procedure Stop;

    procedure Update(const ADelta: TTime); virtual;

    procedure WaitVSync; virtual;
    procedure Prepare;   virtual;
    procedure Render;    virtual;
    procedure Present;   virtual;

    procedure OnCreateWindow;  override;
    procedure OnDestroyWindow; override;

    procedure OnInitialize; virtual;
    procedure OnFinalize;   virtual;

    procedure OnMessage(var AMsg: TWndMsg); override;

    function OnUpdate(const ADelta: TTime): Boolean; virtual;
    function OnRender: Boolean; virtual;

    procedure OnDisplayChanged; virtual;

    procedure OnActivate;   virtual;
    procedure OnDeactivate; virtual;

    procedure OnButtonPressed (const AButton: Word); virtual;
    procedure OnButtonReleased(const AButton: Word); virtual;

    procedure OnMouseMoved(const ADeltaX, ADeltaY: Float; const ADeltaScroll: Integer); virtual;

    procedure OnGamePadMoved(const ADeltaL, ADeltaR: TVector2f; const ADeltaShoulder: Float); virtual;

    property Title: String read FTitle write SetTitle;

    property Scale: Float read FScale write SetScale;

    property Width:  Integer read FWidth;
    property Height: Integer read FHeight;

    property FullScreen: Boolean read FFullScreen write SetFullScreen;
    property Resizeable: Boolean read FResizeable write SetResizeable;
    property VSync:      Boolean read FVSync      write FVSync;

    property Speed:    TTime read FSpeed    write FSpeed;
    property Throttle: TTime read FThrottle write FThrottle;

    property TargetFPS: Double read FTargetFPS write FTargetFPS;

    property Active:  Boolean read FActive;
    property Running: Boolean read FRunning;

    property ShowFramesPerSecond: Boolean read FShowFramesPerSecond write FShowFramesPerSecond;
    property ShowSecondsPerFrame: Boolean read FShowSecondsPerFrame write FShowSecondsPerFrame;
    property ShowFrameDelta:      Boolean read FShowFrameDelta      write FShowFrameDelta;
    property ShowElapsed:         Boolean read FShowElapsed         write FShowElapsed;

    property DeviceContext: HDC read FDeviceContext;
  end;
  {$ENDREGION}

  EEngine = class(TException);

implementation

uses
  libNut.Types.Convert,
  libNut.Maths,
  libNut.Platform;

{$REGION 'TInput'}
function TButtonStateHelper.IsUp;
begin
  Result := Self = TButtonState.Up;
end;

function TButtonStateHelper.IsReleased;
begin
  Result := Self = TButtonState.Released;
end;

function TButtonStateHelper.IsPressed;
begin
  Result := Self = TButtonState.Pressed;
end;

function TButtonStateHelper.IsHeld;
begin
  Result := Self = TButtonState.Held;
end;

function TButtonStateHelper.Down: Boolean;
begin
  Result := Self in [TButtonState.Pressed, TButtonState.Held];
end;

function TInput.GetButtonNoPoll;
begin
  Result := FButtons[AButton];
end;

function TInput.GetButtonState;
begin
  case AButton of
    VK_LSHIFT, VK_RSHIFT, VK_LCONTROL, VK_RCONTROL:
    begin
      if (GetKeyState(AButton) and $8000) > 0 then
      begin
        if FButtons[AButton] in [TButtonState.Pressed, TButtonState.Held] then
          FButtons[AButton] := TButtonState.Held
        else
          FButtons[AButton] := TButtonState.Pressed;
      end
      else
      begin
        if FButtons[AButton] in [TButtonState.Pressed, TButtonState.Held] then
          FButtons[AButton] := TButtonState.Released
        else
          FButtons[AButton] := TButtonState.Up;
      end;

      Result := FButtons[AButton];
    end;

    VK_PADFIRST..VK_PADLAST:
    begin
      if FGamePad <> TGamePadID.None then
        PollGamePadButtons;

      Result := FButtons[AButton];
    end;
  else
    Result := FButtons[AButton];

    case Result of
      TButtonState.Pressed:  FButtons[AButton] := TButtonState.Held;
      TButtonState.Released: FButtons[AButton] := TButtonState.Up;
    end;
  end;
end;

function TInput.GetButtonBool;
begin
  Result := GetButtonState(AButton).Down;
end;

function TInput.GetMousePos;
var
  CursorPos: TPoint;
begin
  GetCursorPos(CursorPos);

  if Assigned(FEngine) then
  begin
    ScreenToClient(FEngine.Handle, CursorPos);
    MouseMoved(CursorPos.X, CursorPos.Y, False);
    Result := FMousePos;
  end
  else
    Result := TVector2f[CursorPos.X, CursorPos.Y];
end;

function TInput.GetMouseOver: Boolean;
begin
  GetMousePos;
  Result := FMouseOver;
end;

procedure TInput.ButtonPressed;
begin
  if FButtons[AButton] = TButtonState.Pressed then
    Exit;

  FButtons[AButton] := TButtonState.Pressed;

  if Assigned(FEngine) then
    FEngine.OnButtonPressed(AButton);
end;

procedure TInput.ButtonReleased;
begin
  if FButtons[AButton] = TButtonState.Released then
    Exit;

  FButtons[AButton] := TButtonState.Released;

  if Assigned(FEngine) then
    FEngine.OnButtonReleased(AButton);
end;

procedure TInput.MouseMoved;
var
  SX, SY: Extended;
begin
  SX := AX;
  SY := AY;

  if Assigned(FEngine) then
  begin
    var Rect: TRect;
    GetClientRect(FEngine.Handle, Rect);

    SX := (FEngine.FWidth  / Rect.Width)  * SX;
    SY := (FEngine.FHeight / Rect.Height) * SY;

    FMouseOver := (SX >= 0) and (SX < FEngine.FWidth) and (SY >= 0) and (SY < FEngine.FHeight);
  end;

  FMousePos := TVector2f[SX, SY];

  if Assigned(FEngine) and AEvent then
    FEngine.OnMouseMoved(FMousePos.X - FMousePosLast.X, FMousePos.Y - FMousePosLast.Y, 0);

  FMousePosLast := FMousePos;
end;

procedure TInput.MouseScrolled;
begin
  FMouseScroll := FMouseScroll + ADelta;

  if Assigned(FEngine) then
    FEngine.OnMouseMoved(0, 0, ADelta);
end;

procedure TInput.SetGamePad;
begin
  if FGamePad <> TGamePadID.None then
    joyReleaseCapture(Ord(FGamePad));

  FGamePad := AGamePad;

  if FGamePad > TGamePadID.None then
    if joySetCapture(FEngine.Handle, Ord(FGamePad), 0, True) <> JOYERR_NOERROR then
      FGamePad := TGamePadID.None;
end;

function TInput.GetGamePadStick;
begin
  PollGamePadSticks(False);

  case AIndex of
    0: Result := FPadLStick;
    1: Result := FPadRStick;
  else
    Result := TVector2f.Zero
  end;
end;

function TInput.GetGamePadShoulder;
begin
  PollGamePadSticks(False);

  Result := FPadShoulder;
end;

procedure TInput.PollGamePadButtons;
var
  JoyInfo: JOYINFOEX;

  procedure SetButton(AButton: Word; AState: Boolean);
  begin
    if AState then
    begin
      if FButtons[AButton] in [TButtonState.Pressed, TButtonState.Held] then
        FButtons[AButton] := TButtonState.Held
      else
      begin
        FButtons[AButton] := TButtonState.Pressed;

        if AEvent then
          FEngine.OnButtonPressed(AButton);
      end;
    end
    else
    begin
      if FButtons[AButton] in [TButtonState.Pressed, TButtonState.Held] then
      begin
        FButtons[AButton] := TButtonState.Released;

        if AEvent then
          FEngine.OnButtonPressed(AButton);
      end
      else
        FButtons[AButton] := TButtonState.Up;
    end;
  end;
begin
  if FGamePad = TGamePadID.None then
    Exit;

  JoyInfo.dwSize  := SizeOf(JoyInfo);
  JoyInfo.dwFlags := JOY_RETURNPOV or JOY_RETURNBUTTONS;

  JoyGetPosEx(Ord(FGamePad), @JoyInfo);

  SetButton(VK_PADA, (JoyInfo.wButtons and $0001) > 0);
  SetButton(VK_PADB, (JoyInfo.wButtons and $0002) > 0);
  SetButton(VK_PADX, (JoyInfo.wButtons and $0004) > 0);
  SetButton(VK_PADY, (JoyInfo.wButtons and $0008) > 0);

  SetButton(VK_PADLSHOULDER, (JoyInfo.wButtons and $0010) > 0);
  SetButton(VK_PADRSHOULDER, (JoyInfo.wButtons and $0020) > 0);

  SetButton(VK_PADLSTICK, (JoyInfo.wButtons and $0100) > 0);
  SetButton(VK_PADRSTICK, (JoyInfo.wButtons and $0200) > 0);

  SetButton(VK_PADSELECT, (JoyInfo.wButtons and $0040) > 0);
  SetButton(VK_PADSTART,  (JoyInfo.wButtons and $0080) > 0);

  case JoyInfo.dwPOV of
    JOY_POVLEFT:
    begin
      SetButton(VK_PADLEFT,  True);
      SetButton(VK_PADRIGHT, False);
      SetButton(VK_PADUP,    False);
      SetButton(VK_PADDOWN,  False);
    end;

    JOY_POVRIGHT:
    begin
      SetButton(VK_PADLEFT,  False);
      SetButton(VK_PADRIGHT, True);
      SetButton(VK_PADUP,    False);
      SetButton(VK_PADDOWN,  False);
    end;

    JOY_POVFORWARD:
    begin
      SetButton(VK_PADLEFT,  False);
      SetButton(VK_PADRIGHT, False);
      SetButton(VK_PADUP,    True);
      SetButton(VK_PADDOWN,  False);
    end;

    JOY_POVBACKWARD:
    begin
      SetButton(VK_PADLEFT,  False);
      SetButton(VK_PADRIGHT, False);
      SetButton(VK_PADUP,    False);
      SetButton(VK_PADDOWN,  True);
    end;
  else
    SetButton(VK_PADLEFT,  False);
    SetButton(VK_PADRIGHT, False);
    SetButton(VK_PADUP,    False);
    SetButton(VK_PADDOWN,  False);
  end;
end;

procedure TInput.PollGamePadSticks;
var
  JoyInfo: JOYINFOEX;
  DL, DR:  TVector2f;
  DS:      Float;
begin
  if FGamePad = TGamePadID.None then
    Exit;

  JoyInfo.dwSize  := SizeOf(JoyInfo);
  JoyInfo.dwFlags := JOY_RETURNX or JOY_RETURNY or JOY_RETURNZ or JOY_RETURNR or JOY_RETURNU or JOY_RETURNV;

  JoyGetPosEx(Ord(FGamePad), @JoyInfo);

  FPadLStick.X := Map(JoyInfo.wXpos, 0, $FFFF, -1, 1);
  FPadLStick.Y := Map(JoyInfo.wYpos, 0, $FFFF, -1, 1);

  FPadRStick.X := Map(JoyInfo.dwUpos, 0, $FFFF, -1, 1);
  FPadRStick.Y := Map(JoyInfo.dwRpos, 0, $FFFF, -1, 1);

  FPadShoulder := Map(JoyInfo.wZpos, 0, $FFFF, -1, 1);

  DL := FPadLStick - FPadLStickLast;
  DR := FPadRStick - FPadRStickLast;

  DS := FPadShoulder - FPadShoulderLast;

  if AEvent and ((DL.X <> 0) or (DL.Y <> 0) or (DR.X <> 0) or (DR.Y <> 0) or (DS <> 0)) then
  begin
    FEngine.OnGamePadMoved(DL, DR, DS);

    FPadLStickLast := FPadLStick;
    FPadRStickLast := FPadRStick;

    FPadShoulderLast := FPadShoulder;
  end;
end;

procedure TInput.Reset;
begin
  FillChar(FButtons, SizeOf(FButtons), 0);

  FMousePos     := TVector2f.Zero;
  FMousePosLast := FMousePos;
  FMouseOver    := False;

  FPadLStick := TVector2f.Zero;
  FPadRStick := TVector2f.Zero;

  FPadLStickLast := FPadLStick;
  FPadRStickLast := FPadRStick;

  FPadShoulder     := 0;
  FPadShoulderLast := FPadShoulder;

  ResetScroll;
end;

procedure TInput.ResetScroll;
begin
  FMouseScroll := 0;
end;
{$ENDREGION}

{$REGION 'TEngine'}
procedure TEngine.SetTitle;
begin
  FTitle := ATitle;

  UpdateTitle;
end;

procedure TEngine.UpdateTitle;
var
  T, TC: String;
begin
  if Handle = 0 then
    Exit;

  T := FTitle;

  if Length(T) = 0 then
    T := ClassName;

  if FRunning then
  begin
    if FShowFramesPerSecond and (FFramesPerSecond > 0) then
      T := T + '  ●  ' + IntToStr(FFramesPerSecond) + ' fps';

    if FShowSecondsPerFrame and (FSecondsPerFrame > 0) then
      T := T + '  ●  ' + FloatToStr(FSecondsPerFrame, 7) + ' spf';

    if FShowFrameDelta and (FFrameDelta > 0) then
      T := T + '  ●  ' + FloatToStr(FFrameDelta, 4) + ' delta';

    if FShowElapsed and (FElapsed.Elapsed > 0) then
      T := T + '  ●  ' + FElapsed.Elapsed.ToString(False);
  end;

  TC := Handle.Caption;

  if T <> TC then
    Handle.Caption := T;
end;

procedure TEngine.SetScale;
begin
  SetDisplay(FWidth, FHeight, AScale, FFullScreen, FResizeable);
end;

procedure TEngine.SetFullScreen;
begin
  SetDisplay(FWidth, FHeight, FScale, AFullScreen, FResizeable);
end;

procedure TEngine.SetResizeable;
begin
  SetDisplay(FWidth, FHeight, FScale, FFullScreen, AResizeable);
end;

class procedure TEngine.Run;
begin
  ReportMemoryLeaksOnShutdown := True;

  try
    with Create do try
      FWidth  := AWidth;
      FHeight := AHeight;

      FScale := AScale;

      FResizeable := AResizeable;
      FFullScreen := AFullScreen;
      FVSync      := AVSync;

      Start;
    finally
      Free;
    end;
  except on E: TException do
    &Platform.Exception(E, ExceptAddr);
  end;
end;

constructor TEngine.Create;
begin
  inherited;

  FScale := 1;

  FWidth  := 640;
  FHeight := 480;

  FFullScreen := False;
  FResizeable := False;
  FVSync      := True;

  FFramesPerSecond := 0;
  FSecondsPerFrame := 0;

  FSpeed      := 1;
  FThrottle   := 0;
  FTargetFPS  := 60;
  FFrameDelta := 0;

  FUpdateCount := 0;
  FFrameCount  := 0;

  FActive  := False;
  FRunning := False;

  FElapsed.Reset;

  FShowFramesPerSecond := True;
  FShowSecondsPerFrame := False;
  FShowFrameDelta      := True;
  FShowElapsed         := True;

  Input.FEngine := Self;
  Input.Reset;

  QuitOnClose := True;

  CreateWindow;
end;

destructor TEngine.Destroy;
begin
  Stop;

  inherited;
end;

class procedure TEngine.InitWindowClass;
begin
  inherited;

  //AWndClass.hbrBackground := GetStockObject(BLACK_BRUSH);
  AWndClass.style         := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
end;

procedure TEngine.InitWindowParams;
begin
  inherited;

  AParams.W := 0;
  AParams.H := 0;

  AParams.X := 0;
  AParams.Y := 0;

  AParams.Style := 0;
end;

procedure TEngine.SetDisplay(const AWidth, AHeight: Integer; const AScale: Float; const AFullScreen, AResizeable: Boolean);
var
  SWidth:  Integer;
  SHeight: Integer;
begin
  FScale := AScale;
  if FScale < 1 then
    FScale := 1;

  FWidth  := AWidth;
  FHeight := AHeight;

  SWidth  := Round(FWidth  * FScale);
  SHeight := Round(FHeight * FScale);

  FResizeable := AResizeable;

  //if AHeight <> 0 then
  //  FAspectRatio := AWidth / AHeight
  //else
  //  FAspectRatio := 1;

  if Handle = 0 then
  begin
    FFullScreen := AFullScreen;
    Exit;
  end;

  if AFullScreen then
  begin
    if (SWidth <> GetSystemMetrics(SM_CXSCREEN)) or (SHeight <> GetSystemMetrics(SM_CYSCREEN)) then
    begin
      var DevMode: TDevMode;

      FillChar(DevMode, SizeOf(DevMode), 0);

      DevMode.dmSize       := SizeOf(DevMode);
      DevMode.dmPelsWidth  := SWidth;
      DevMode.dmPelsHeight := SHeight;
      DevMode.dmBitsPerPel := 32;
      DevMode.dmFields     := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT;

      FFullScreen := ChangeDisplaySettings(DevMode, CDS_FULLSCREEN) = DISP_CHANGE_SUCCESSFUL;
    end;
  end
  else
  begin
    if FFullScreen then
      ChangeDisplaySettings(TDevMode(nil^), 0);

    FFullScreen := False;
  end;

  if FFullScreen then
  begin
    Handle.Style := NativeInt(WS_POPUP);
    Handle.Maximize;
  end
  else
  begin
    var Style := WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX;

    if FResizeable then
      Style := Style or WS_SIZEBOX or WS_MAXIMIZEBOX;

    Handle.Style := Style;
    Handle.Restore;

    ShowWindow(Handle, SW_SHOW);

    var Rect: TRect;

    Rect := TRect.Create(0, 0, SWidth, SHeight);
    AdjustWindowRectEx(Rect, Style, False, 0);

    MoveWindow(
      Handle,
      (GetSystemMetrics(SM_CXSCREEN) div 2) - (Rect.Width  div 2),
      (GetSystemMetrics(SM_CYSCREEN) div 2) - (Rect.Height div 2),
      Rect.Width, Rect.Height, True
    );
  end;

  OnDisplayChanged;
end;

procedure TEngine.SetDisplay(const AWidth, AHeight: Integer; AScale: Float = 0);
begin
  if AScale = 0 then
    AScale := FScale;

  SetDisplay(AWidth, AHeight, AScale, FFullScreen, FResizeable);
end;

procedure TEngine.Start;
var
  FPSTimer: TStopwatch;

  FrameTimer:  TStopwatch;
  UpdateTimer: TStopwatch;

  Delta:       TTime;
  DeltaTotal:  TTime;

  FPSTime: TTime;
begin
  if FRunning then
    Exit;

  try
    FUpdateCount := 0;
    FFrameCount  := 0;

    DeltaTotal := 0;

    FFramesPerSecond := 0;
    FSecondsPerFrame := 0;
    FFrameDelta      := 1;

    SetDisplay(FWidth, FHeight, FScale, FFullScreen, FResizeable);
    FElapsed.Reset;

    OnInitialize;

    FPSTimer.Reset;
    FrameTimer.Reset;
    UpdateTimer.Reset;

    FRunning := True;

    repeat
      FSecondsPerFrame := FrameTimer.Reset;

      Delta      := FSpeed * FTargetFPS * FSecondsPerFrame;
      DeltaTotal := DeltaTotal + Delta;

      Update(Delta);
      Render;

      FPSTime := FPSTimer.Elapsed;

      if FPSTime >= 1 then
      begin
        FPSTimer.Reset;

        FFramesPerSecond := Round(FFrameCount / FPSTime);
        FFrameDelta      := DeltaTotal / FUpdateCount;

        FUpdateCount := 0;
        FFrameCount  := 0;
        DeltaTotal   := 0;

        UpdateTitle;
      end;

      if ProcessMessages(False) = WM_QUIT then
        Stop;

      if FThrottle > 0 then
        &Platform.Sleep(FThrottle);
    until not FRunning;

    OnFinalize;
  finally
    if FFullScreen then
      ChangeDisplaySettings(TDevMode(nil^), 0);

    Stop;
  end;
end;

procedure TEngine.Stop;
begin
  FRunning := False;
end;

procedure TEngine.Update;
begin
  if OnUpdate(ADelta) then
    Inc(FUpdateCount);
end;

procedure TEngine.WaitVSync;
begin
  DwmFlush;
end;

procedure TEngine.Prepare;
begin
  {}
end;

procedure TEngine.Render;
begin
  if FVSync then
    &Platform.WaitVSync;

  Prepare;

  if OnRender then
  begin
    Inc(FFrameCount);
    Present;
  end;
end;

procedure TEngine.Present;
begin
  {}
end;

procedure TEngine.OnCreateWindow;
begin
  inherited;

  FDeviceContext := GetDC(Handle);

  if FDeviceContext = 0 then
    raise EEngine.Create('Failed to get device context');
end;

procedure TEngine.OnDestroyWindow;
begin
  if FDeviceContext <> 0 then
  begin
    ReleaseDC(Handle, FDeviceContext);
    FDeviceContext := 0;
  end;

  inherited;
end;

procedure TEngine.OnInitialize;
begin
  {}
end;

procedure TEngine.OnFinalize;
begin
  {}
end;

procedure TEngine.OnMessage;
begin
  case AMsg.Msg of
    WM_ERASEBKGND:
    begin
      if FRunning then
      begin
        AMsg.LResult := LRESULT(-1);
        Exit;
      end;
    end;

    WM_SIZE: if FResizeable and FRunning then Render;

    WM_ACTIVATE:
    begin
      FActive := (AMsg.wParam and $FFFF) > 0;

      if FActive then
        OnActivate
      else
        OnDeactivate;
    end;

    WM_KEYDOWN, WM_SYSKEYDOWN: Input.ButtonPressed (AMsg.wParam);
    WM_KEYUP,   WM_SYSKEYUP:   Input.ButtonReleased(AMsg.wParam);

    WM_LBUTTONDOWN: begin Input.ButtonPressed(VK_LBUTTON); SetCapture(Handle); end;
    WM_MBUTTONDOWN: begin Input.ButtonPressed(VK_MBUTTON); SetCapture(Handle); end;
    WM_RBUTTONDOWN: begin Input.ButtonPressed(VK_RBUTTON); SetCapture(Handle); end;

    WM_LBUTTONUP: begin Input.ButtonReleased(VK_LBUTTON); ReleaseCapture; end;
    WM_MBUTTONUP: begin Input.ButtonReleased(VK_MBUTTON); ReleaseCapture; end;
    WM_RBUTTONUP: begin Input.ButtonReleased(VK_RBUTTON); ReleaseCapture; end;

    WM_MOUSEMOVE:  Input.MouseMoved(AMsg.lParam and $FFFF, (AMsg.lParam shr 16) and $FFFF);
    WM_MOUSEWHEEL: Input.MouseScrolled(SmallInt((AMsg.wParam and $FFFF0000) shr 16) div WHEEL_DELTA);

    MM_JOY1BUTTONDOWN, MM_JOY1BUTTONUP,
    MM_JOY2BUTTONDOWN, MM_JOY2BUTTONUP:
      Input.PollGamePadButtons(True);

    MM_JOY1MOVE, MM_JOY1ZMOVE,
    MM_JOY2MOVE, MM_JOY2ZMOVE:
      Input.PollGamePadSticks(True);
  end;

  inherited;
end;

function TEngine.OnUpdate;
begin
  Result := True;
end;

function TEngine.OnRender;
begin
  Result := True;
end;

procedure TEngine.OnDisplayChanged;
begin
  {}
end;

procedure TEngine.OnActivate;
begin
  {}
end;

procedure TEngine.OnDeactivate;
begin
  {}
end;

procedure TEngine.OnButtonPressed;
begin
  {}
end;

procedure TEngine.OnButtonReleased;
begin
  {}
end;

procedure TEngine.OnMouseMoved;
begin
  {}
end;

procedure TEngine.OnGamePadMoved;
begin
  {}
end;
{$ENDREGION}

end.
