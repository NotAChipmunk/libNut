unit libNut.Windows;

{$I libNut.Options.inc}

{$IF NOT DEFINED(MSWINDOWS)}
  {$MESSAGE FATAL 'Invalid platform'}
{$ENDIF}

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  libNut.Exceptions,
  libNut.Platform;

type
  {$REGION 'TPlatformWin'}
  TPlatformWin = class abstract(TPlatform)
  private class var
    FHighResTick: Boolean;
    FTickScale:   Double;
  public
    class constructor Create;

    class function  Time:  TTime;           override;
    class function  Ticks: Int64;           override;
    class procedure Sleep(ASeconds: TTime); override;

    class property HighResTick: Boolean read FHighResTick;
    class property TickScale:   Double  read FTickScale;

    class function ProcessMessages(const AWait: Boolean = False): Boolean; override;

    class procedure WaitVSync; override;

    class function GenerateGUID: TGUID; override;
  end;
  {$ENDREGION}

{$REGION 'Subclassing'}
type
  TSubClasProc = function(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM; uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;

function SetWindowSubclass   (hWnd: HWND; pfnSubclass: TSubClasProc; uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): BOOL;      stdcall; external comctl32;
function GetWindowSubclass   (hWnd: HWND; pfnSubclass: TSubClasProc; uIdSubclass: UINT_PTR; var pdwRefData: DWORD_PTR): BOOL; stdcall; external comctl32;
function RemoveWindowSubclass(hWnd: HWND; pfnSubclass: TSubClasProc; uIdSubclass: UINT_PTR): BOOL;                            stdcall; external comctl32;
function DefSubclassProc     (hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;                               stdcall; external comctl32;
{$ENDREGION}

type
  PWndMsg = ^TWndMsg;
  TWndMsg = record
    Msg:     Cardinal;
    Wnd:     HWND;
    WParam:  WPARAM;
    LParam:  LPARAM;
    LResult: LRESULT;
  end;

  TWindowParams = record
    ExStyle:    Cardinal;
    WindowName: String;
    Style:      Cardinal;
    X, Y, W, H: Integer;
    Menu:       HMENU;
    HInstance:  HINST;
    Param:      Pointer;
  end;

  {$REGION 'HWNDHelper'}
  THWNDHelper = record helper for HWND
  private
    function  GetLongPtr(const AIndex: Integer): NativeInt;               inline;
    procedure SetLongPtr(const AIndex: Integer; const AValue: NativeInt); inline;

    function  GetClassLongPtr(const AIndex: Integer): NativeInt;               inline;
    procedure SetClassLongPtr(const AIndex: Integer; const AValue: NativeInt); inline;

    function  GetIsPopup: Boolean;               inline;
    procedure SetIsPopup(const AValue: Boolean); inline;

    function  GetStyleMask(const AMask: Integer): Boolean;               inline;
    procedure SetStyleMask(const AMask: Integer; const AValue: Boolean); inline;

    function  GetExStyleMask(const AMask: Integer): Boolean;               inline;
    procedure SetExStyleMask(const AMask: Integer; const AValue: Boolean); inline;

    function  GetPosSize(const AIndex: Integer): Integer;
    procedure SetPosSize(const AIndex, AValue: Integer);

    function  GetClientSize(const AIndex: Integer): Integer;
    procedure SetClientSize(const AIndex, AValue: Integer);

    function  GetCaption: String;
    procedure SetCaption(const AValue: String);

    function  GetParent: HWND;          inline;
    procedure SetParent(const AParent: HWND); inline;
  public
    function SendMessage(const AMsg: Integer; const AWParam: WPARAM = 0; const ALParam: LPARAM = 0; const AQueued: Boolean = False): LRESULT; inline;

    function Rect:       TRect; inline;
    function ClientRect: TRect; inline;

    procedure Close;   inline;
    procedure Destroy; inline;

    procedure Show(const AShow: Integer = SW_SHOW); inline;
    procedure Hide; inline;

    procedure Minimize; inline;
    procedure Maximize; inline;
    procedure Restore;  inline;

    function ClassName: String;

    property Parent: HWND read GetParent write SetParent;

    property LongPtr    [const AIndex: Integer]: NativeInt read GetLongPtr      write SetLongPtr;
    property ClasLongPtr[const AIndex: Integer]: NativeInt read GetClassLongPtr write SetClassLongPtr;

    property WndProc:    NativeInt index GWL_WNDPROC    read GetLongPtr write SetLongPtr;
    property Instance:   NativeInt index GWL_HINSTANCE  read GetLongPtr write SetLongPtr;
    property WndParent:  NativeInt index GWL_HWNDPARENT read GetLongPtr write SetLongPtr;
    property Style:      NativeInt index GWL_STYLE      read GetLongPtr write SetLongPtr;
    property ExStyle:    NativeInt index GWL_EXSTYLE    read GetLongPtr write SetLongPtr;
    property UserData:   NativeInt index GWL_USERDATA   read GetLongPtr write SetLongPtr;
    property ID:         NativeInt index GWL_ID         read GetLongPtr write SetLongPtr;

    property ClassMenuName:      NativeInt index GCL_MENUNAME      read GetClassLongPtr write SetClassLongPtr;
    property ClassBackground:    NativeInt index GCL_HBRBACKGROUND read GetClassLongPtr write SetClassLongPtr;
    property ClassCursor:        NativeInt index GCL_HCURSOR       read GetClassLongPtr write SetClassLongPtr;
    property ClassIcon:          NativeInt index GCL_HICON         read GetClassLongPtr write SetClassLongPtr;
    property ClassSmallIcon:     NativeInt index GCL_HICONSM       read GetClassLongPtr write SetClassLongPtr;
    property ClassModule:        NativeInt index GCL_HMODULE       read GetClassLongPtr write SetClassLongPtr;
    property ClassAtom:          NativeInt index GCW_ATOM          read GetClassLongPtr write SetClassLongPtr;
    property ClassStyle:         NativeInt index GCL_STYLE         read GetClassLongPtr write SetClassLongPtr;
    property ClassWndProc:       NativeInt index GCL_WNDPROC       read GetClassLongPtr write SetClassLongPtr;
    property ClassWndBytesExtra: NativeInt index GCL_CBWNDEXTRA    read GetClassLongPtr write SetClassLongPtr;
    property ClassBytesExtra:    NativeInt index GCL_CBCLSEXTRA    read GetClassLongPtr write SetClassLongPtr;

    property StyleMask  [const AMask: Integer]: Boolean read GetStyleMask   write SetStyleMask;
    property ExStyleMask[const AMask: Integer]: Boolean read GetExStyleMask write SetExStyleMask;

    property IsPopup:      Boolean                        read GetIsPopup     write SetIsPopup;
    property IsChild:      Boolean index WS_CHILD         read GetStyleMask   write SetStyleMask;
    property IsMDIChild:   Boolean index WS_EX_MDICHILD   read GetExStyleMask write SetExStyleMask;
    property IsToolWindow: Boolean index WS_EX_TOOLWINDOW read GetExStyleMask write SetExStyleMask;
    property IsAppWindow:  Boolean index WS_EX_APPWINDOW  read GetExStyleMask write SetExStyleMask;

    property ClipSiblings: Boolean index WS_CLIPSIBLINGS read GetStyleMask write SetStyleMask;
    property ClipChildren: Boolean index WS_CLIPCHILDREN read GetStyleMask write SetStyleMask;

    property NoParentNotify: Boolean index WS_EX_NOPARENTNOTIFY read GetExStyleMask write SetExStyleMask;

    property Visible:  Boolean index WS_VISIBLE  read GetStyleMask write SetStyleMask;
    property Disabled: Boolean index WS_DISABLED read GetStyleMask write SetStyleMask;

    property Minimized: Boolean index WS_MINIMIZE read GetStyleMask write SetStyleMask;
    property Maximized: Boolean index WS_MAXIMIZE read GetStyleMask write SetStyleMask;

    property Sizeable: Boolean index WS_THICKFRAME read GetStyleMask write SetStyleMask;

    property StayOnTop: Boolean index WS_EX_TOPMOST read GetExStyleMask write SetExStyleMask;

    property Transparent: Boolean index WS_EX_TRANSPARENT read GetExStyleMask write SetExStyleMask;
    property Layered:     Boolean index WS_EX_LAYERED     read GetExStyleMask write SetExStyleMask;
    property Composited:  Boolean index WS_EX_COMPOSITED  read GetExStyleMask write SetExStyleMask;

    property NoActivate: Boolean index WS_EX_NOACTIVATE read GetExStyleMask write SetExStyleMask;

    property AcceptFiles: Boolean index WS_EX_ACCEPTFILES read GetExStyleMask write SetExStyleMask;

    property HasCaption:       Boolean index WS_CAPTION          read GetStyleMask   write SetStyleMask;
    property HasBorder:        Boolean index WS_BORDER           read GetStyleMask   write SetStyleMask;
    property HasDlgFrame:      Boolean index WS_DLGFRAME         read GetStyleMask   write SetStyleMask;
    property HasThickFrame:    Boolean index WS_THICKFRAME       read GetStyleMask   write SetStyleMask;
    property HasDlgModalFrame: Boolean index WS_EX_DLGMODALFRAME read GetExStyleMask write SetExStyleMask;
    property HasRaisedEdge:    Boolean index WS_EX_WINDOWEDGE    read GetExStyleMask write SetExStyleMask;
    property HasSunkenEdge:    Boolean index WS_EX_CLIENTEDGE    read GetExStyleMask write SetExStyleMask;

    property HasSysMenu: Boolean index WS_SYSMENU read GetStyleMask write SetStyleMask;

    property HasMimimizeButton: Boolean index WS_MINIMIZEBOX    read GetStyleMask   write SetStyleMask;
    property HasMaximizeButton: Boolean index WS_MAXIMIZEBOX    read GetStyleMask   write SetStyleMask;
    property HasHelpButton:     Boolean index WS_EX_CONTEXTHELP read GetExStyleMask write SetExStyleMask;

    property HasVScroll: Boolean index WS_VSCROLL read GetStyleMask write SetStyleMask;
    property HasHScroll: Boolean index WS_HSCROLL read GetStyleMask write SetStyleMask;

    property LeftScroll: Boolean index WS_EX_LEFTSCROLLBAR read GetExStyleMask write SetExStyleMask;
    property AlignRight: Boolean index WS_EX_RIGHT         read GetExStyleMask write SetExStyleMask;
    property RTLReading: Boolean index WS_EX_RTLREADING    read GetExStyleMask write SetExStyleMask;
    property RTLLayout:  Boolean index WS_EX_LAYOUTRTL     read GetExStyleMask write SetExStyleMask;

    property Left:   Integer index 0 read GetPosSize write SetPosSize;
    property Top:    Integer index 1 read GetPosSize write SetPosSize;
    property Width:  Integer index 2 read GetPosSize write SetPosSize;
    property Height: Integer index 3 read GetPosSize write SetPosSize;

    property ClientWidth:  Integer index 0 read GetClientSize write SetClientSize;
    property ClientHeight: Integer index 1 read GetClientSize write SetClientSize;

    property Caption: String read GetCaption write SetCaption;
  end;
  {$ENDREGION}

  {$REGION 'TSubclass'}
  TSubclass = class
  private
    FHandle: HWND;

    FQuitOnClose: Boolean;

    class function WndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM; uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall; static;
  public
    constructor Create(const AHandle: HWND);
    destructor  Destroy; override;

    procedure StartSubClass;
    procedure EndSubClass;

    procedure OnMessage(var AMsg: TWndMsg); virtual;

    procedure DefaultHandler(var AMsg); override;

    property Handle: HWND read FHandle;

    property QuitOnClose: Boolean read FQuitOnClose write FQuitOnClose;
  end;
  {$ENDREGION}

  {$REGION 'TControl'}
  TControl = class(TSubclass)
  private
    FWndClass: String;
    FParent:   HWND;

    function  GetParent: HWND;
    procedure SetParent(const AParent: HWND);
  public
    constructor Create(const AWndClass: String; const AParent: HWND);
    destructor  Destroy; override;

    procedure InitWindowParams(var AParams: TWindowParams); virtual;

    procedure CreateWindow;  virtual;
    procedure DestroyWindow; virtual;

    function CreateControl(const AWndClass: String): TControl;

    procedure OnCreateWindow;  virtual;
    procedure OnDestroyWindow; virtual;

    property WndClass: String read FWndClass;

    property Parent: HWND read GetParent write SetParent;
  end;
  {$ENDREGION}

  {$REGION 'TWindow'}
  TWindow = class(TControl)
  private
    class var FAtom: ATOM;

    class constructor Create;
    class destructor  Destroy;

    class function  RegisterClass:   Boolean;
    class function  UnregisterClass: Boolean;
  public
    constructor Create;
    destructor  Destroy; override;

    class function ProcessMessages(const AWait: Boolean = True): Cardinal;

    class procedure InitWindowClass(var AWndClass: WNDCLASSEX); virtual;
    procedure InitWindowParams(var AParams: TWindowParams); override;

    procedure CreateWindow; override;
  end;
  {$ENDREGION}

  EWindow = class(TException);

function DwmFlush: HRESULT; stdcall; external 'DWMAPI.DLL';
function UuidCreate(out guid: TGUID): Longint; stdcall; external 'RPCRT4.DLL';

var
  AllowDarkModeForWindow: function(hwnd: HWND; allow: LONGBOOL): BOOL; stdcall;

implementation

{uses
  Winapi.DwmApi,
  Winapi.CommCtrl,
  Winapi.UxTheme;{}

{$REGION 'TPlatformWin'}
class constructor TPlatformWin.Create;
var
  Frequency: Int64;
begin
  FHighResTick := QueryPerformanceFrequency(Frequency);

  if FHighResTick then
    FTickScale := 1 / Frequency
  else
    FTickScale := 0.001;
end;

class function TPlatformWin.Time;
var
  Ticks: Int64;
begin
  if FHighResTick then
    QueryPerformanceCounter(Ticks)
  else
    Ticks := GetTickCount64;

  Result := Ticks * FTickScale;
end;

class function TPlatformWin.Ticks;
begin
  Result := GetTickCount64;
end;

class procedure TPlatformWin.Sleep;
begin
  if ASeconds <= 0 then
    SwitchToThread
  else
    SleepEx(Round(ASeconds * 1000), True);
end;

class function TPlatformWin.ProcessMessages;
begin
  Result := TWindow.ProcessMessages(AWait) <> WM_QUIT;
end;

class procedure TPlatformWin.WaitVSync;
begin
  DwmFlush;
end;

class function TPlatformWin.GenerateGUID;
begin
  if UuidCreate(Result) <> 0 then
    Result := TGUID.Empty;
end;
{$ENDREGION}

{$REGION 'HWNDHelper'}
function THWNDHelper.GetLongPtr;
begin
  Result := GetWindowLongPtr(Self, AIndex);
end;

procedure THWNDHelper.SetLongPtr;
begin
  SetWindowLongPtr(Self, AIndex, AValue);
end;

function THWNDHelper.GetClassLongPtr;
begin
  Result := WinApi.Windows.GetClassLongPtr(Self, AIndex);
end;

procedure THWNDHelper.SetClassLongPtr;
begin
  WinApi.Windows.SetClassLongPtr(Self, AIndex, AValue);
end;

function THWNDHelper.GetIsPopup;
begin
  Result := (Style and WS_POPUP) <> 0;
end;

procedure THWNDHelper.SetIsPopup;
begin
  if AValue then
    Style := NativeInt(NativeUInt(Style) or WS_POPUP)
  else
    Style := Style and (not WS_POPUP);
end;

function THWNDHelper.GetStyleMask;
begin
  Result := (Style and AMask) <> 0
end;

procedure THWNDHelper.SetStyleMask;
begin
  if AValue then
    Style := Style or AMask
  else
    Style := Style and (not AMask);
end;

function THWNDHelper.GetExStyleMask;
begin
  Result := (ExStyle and AMask) <> 0
end;

procedure THWNDHelper.SetExStyleMask;
begin
  if AValue then
    ExStyle := ExStyle or AMask
  else
    ExStyle := ExStyle and (not AMask);
end;

function THWNDHelper.GetPosSize;
begin
  var R := Rect;

  case AIndex of
    0: Result := R.Left;
    1: Result := R.Top;
    2: Result := R.Width;
    3: Result := R.Height;
  else
    Result := 0;
  end;
end;

procedure THWNDHelper.SetPosSize;
begin
  var R := Rect;

  case AIndex of
    0: SetWindowPos(Self, 0, AValue, R.Top,  R.Width, R.Height, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
    1: SetWindowPos(Self, 0, R.Left, AValue, R.Width, R.Height, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
    2: SetWindowPos(Self, 0, R.Left, R.Top,  AValue,  R.Height, SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE);
    3: SetWindowPos(Self, 0, R.Left, R.Top,  R.Width, AValue,   SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE);
  end;
end;

function THWNDHelper.GetClientSize;
begin
  with ClientRect do
    case AIndex of
      0: Result := Right  - Left;
      1: Result := Bottom - Top;
    else
      Result := 0;
    end;
end;

procedure THWNDHelper.SetClientSize;
begin
  case AIndex of
    0: Width  := AValue + (Width  - ClientWidth);
    1: Height := AValue + (Height - ClientHeight);
  end;
end;

function THWNDHelper.GetCaption;
begin
  SetLength(Result, GetWindowTextLength(Self) + 1);
  SetLength(Result, GetWindowText(Self, PChar(Result), Length(Result)));
end;

procedure THWNDHelper.SetCaption;
begin
  SetWindowText(Self, AValue);
end;

function THWNDHelper.GetParent;
begin
  Result := WinApi.Windows.GetParent(Self);
end;

procedure THWNDHelper.SetParent;
begin
  WinApi.Windows.SetParent(Self, AParent);
end;

function THWNDHelper.SendMessage;
begin
  if AQueued then
    Result := LRESULT(PostMessage(Self, AMsg, AWParam, ALParam))
  else
    Result := WinApi.Windows.SendMessage(Self, AMsg, AWParam, ALParam);
end;

function THWNDHelper.Rect;
var
  Offset: TPoint;
begin
  FillChar(Result, SizeOf(Result), 0);
  GetWindowRect(Self, Result);

  Offset.X := Result.Left;
  Offset.Y := Result.Top;

  if Parent <> 0 then
  begin
    ScreenToClient(Parent, Offset);

    Result.Left := Offset.X;
    Result.Top  := Offset.Y;
  end;
end;

function THWNDHelper.ClientRect;
begin
  FillChar(Result, SizeOf(Result), 0);
  GetClientRect(Self, Result);
end;

procedure THWNDHelper.Close;
begin
  SendMessage(WM_CLOSE);
end;

procedure THWNDHelper.Destroy;
begin
  DestroyWindow(Self);
end;

procedure THWNDHelper.Show;
begin
  ShowWindow(Self, AShow);
end;

procedure THWNDHelper.Hide;
begin
  Show(SW_HIDE);
end;

procedure THWNDHelper.Minimize;
begin
  Show(SW_SHOWMINIMIZED);
end;

procedure THWNDHelper.Maximize;
begin
  Show(SW_SHOWMAXIMIZED);
end;

procedure THWNDHelper.Restore;
begin
  Show(SW_RESTORE);
end;

function THWNDHElper.ClassName;
begin
  SetLength(Result, 256);
  SetLength(Result, GetClassName(Self, PChar(Result), Length(Result)));
end;
{$ENDREGION}

{$REGION 'TSubclass'}
class function TSubclass.WndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM; uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
var
  SubClass: TSubclass;
  WndMsg:   TWndMsg;
begin
  SubClass := TSubclass(dwRefData);

  WndMsg.Msg     := uMsg;
  WndMsg.Wnd     := hWnd;
  WndMsg.WParam  := wParam;
  WndMsg.LParam  := lParam;
  WndMsg.LResult := 0;

  SubClass.OnMessage(WndMsg);
  Result := WndMsg.LResult;
end;

constructor TSubclass.Create(const AHandle: HWND);
begin
  inherited Create;

  FHandle := AHandle;

  FQuitOnClose := False;

  StartSubclass;
end;

destructor TSubclass.Destroy;
begin
  EndSubclass;

  inherited;
end;

procedure TSubClass.StartSubclass;
begin
  if FHandle = 0 then
    Exit;

  EndSubClass;

  if not SetWindowSubclass(FHandle, @WndProc, 1, DWORD_PTR(Self)) then
    raise EWindow.Create('Failed to subclass window');
end;

procedure TSUbclass.EndSubClass;
begin
  if FHandle = 0 then
    Exit;

  RemoveWindowSubclass(FHandle, @WndProc, DWORD_PTR(Self));
end;

procedure TSubclass.OnMessage(var AMsg: TWndMsg);
begin
  Dispatch(AMsg);

  if (AMsg.Msg = WM_CLOSE) and FQuitOnClose then
    PostQuitMessage(0);
end;

procedure TSubclass.DefaultHandler(var AMsg);
begin
  with TWndMsg(AMsg) do
    LResult := DefSubclassProc(Wnd, Msg, WParam, LParam);
end;
{$ENDREGION}

{$REGION 'TControl'}
function TControl.GetParent: HWND;
begin
  if FHandle <> 0 then
  begin
    Result  := FHandle.Parent;
    FParent := Result;
  end
  else
    Result := FParent;
end;

procedure TControl.SetParent(const AParent: HWND);
begin
  if FHandle <> 0 then
  begin
    FHandle.Parent  := AParent;
    FHandle.IsChild := AParent <> 0;
  end;

  FParent := AParent;
end;

constructor TControl.Create(const AWndClass: String; const AParent: HWND);
begin
  inherited Create(0);

  FWndClass := AWndClass;
  FParent   := AParent;
end;

destructor TControl.Destroy;
begin
  DestroyWindow;

  inherited;
end;

procedure TControl.InitWindowParams;
begin
  with AParams do
  begin
    ExStyle    := 0;
    WindowName := ClassName;
    Style      := WS_VISIBLE;
    X          := 0;
    Y          := 0;
    W          := 128;
    H          := 128;
    Menu       := 0;
    HInstance  := SysInit.HInstance;
    Param      := nil;

    if FParent <> 0 then
      Style := Style or WS_CHILD;
  end;
end;

procedure TControl.CreateWindow;
var
  Params: TWindowParams;
begin
  if FHandle <> 0 then
    DestroyWindow;

  InitWindowParams(Params);

  with Params do
    FHandle := CreateWindowEx(ExStyle, PChar(FWndClass), PChar(WindowName), Style, X, Y, W, H, FParent, Menu, HInstance, Param);

  if FHandle = 0 then
    raise EWindow.Create('Failed to create window for class "' + FWndClass + '"');

  SendMessage(FHandle, WM_SETFONT, GetStockObject(DEFAULT_GUI_FONT), 0);

  //Writeln(UpdateLayeredWindow(FHandle, GetDC(0), nil, nil, GetDC(FHandle), nil, 0, nil, ULW_COLORKEY));

  //SetLayeredWindowAttributes(FHandle, 0, 255, 1);

  //AllowDarkModeForWindow(FHandle, True);
  //SetWindowTheme(FHandle, 'DarkMode_Explorer', nil);

  //var Attrib: DWORD := 1;
  //DwmSetWindowAttribute(Handle, 20, @Attrib, SizeOf(Attrib));

  {if FParent = 0 then
  begin
    //SetLayeredWindowAttributes(FHandle, $00FF00FF, 255, LWA_ALPHA);

    //var Margins: TMargins;
    //Margins.cxLeftWidth := 0;
    //Margins.cxRightWidth := 0;
    //Margins.cyTopHeight := 0;
    //Margins.cyBottomHeight := 0;

    //DwmExtendFrameIntoClientArea(FHandle, Margins);
  end;{}

  StartSubClass;

  OnCreateWindow;
end;

procedure TControl.DestroyWindow;
begin
  EndSubClass;

  if FHandle <> 0 then
  begin
    OnDestroyWindow;

    FHandle.Destroy;
    FHandle := 0;
  end;
end;

procedure TControl.OnCreateWindow;
begin
  {}
end;

procedure TControl.OnDestroyWindow;
begin
  {}
end;

function TControl.CreateControl(const AWndClass: String): TControl;
begin
  Result := TControl.Create(AWndClass, Handle);
  Result.CreateWindow;
end;
{$ENDREGION}

{$REGION 'TWindow'}
class constructor TWindow.Create;
begin
  FAtom := 0;
end;

class destructor TWindow.Destroy;
begin
  UnregisterClass;
end;

class function TWindow.RegisterClass;
var
  WndClass: WNDCLASSEX;
begin
  if FAtom <> 0 then
    Exit(True);

  FillChar(WndClass, SizeOf(WndClass), 0);
  WndClass.cbSize := SizeOf(WndClass);

  InitWindowClass(WndClass);

  WndClass.lpszClassName := PChar(ClassName);

  FAtom := RegisterClassEx(WndClass);
  Result := FAtom <> 0;
end;

class function TWindow.UnregisterClass;
begin
  if FAtom = 0 then
    Exit(True);

  Result := WinApi.Windows.UnregisterClass(PChar(FAtom), HInstance);

  if Result then
    FAtom := 0;
end;

constructor TWindow.Create;
begin
  inherited Create(ClassName, 0);

  FQuitOnClose := True;
end;

destructor TWindow.Destroy;
begin
  inherited;
end;

class function TWindow.ProcessMessages(const AWait: Boolean = True): Cardinal;
var
  Msg: TMsg;
begin
  if AWait then
    WaitMessage;

  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
  begin
    if Msg.message = WM_QUIT then
      Break;

    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;

  Result := Msg.message;
end;

class procedure TWindow.InitWindowClass(var AWndClass: WNDCLASSEX);
begin
  with AWndClass do
  begin
    lpfnWndProc   := @DefWindowProc;
    hInstance     := SysInit.HInstance;
    hIcon         := LoadIcon(hInstance, 'MAINICON');
    hCursor       := LoadCursor(0, IDC_ARROW);
    hbrBackground := COLOR_BACKGROUND;
  end;

  if AWndClass.hIcon = 0 then
    AWndClass.hIcon := LoadIcon(0, IDI_APPLICATION);
end;

procedure TWindow.InitWindowParams(var AParams: TWindowParams);
begin
  inherited InitWindowParams(AParams);

  with AParams do
  begin
    Style := Style or WS_OVERLAPPEDWINDOW;

    X := Integer(CW_USEDEFAULT);
    Y := Integer(CW_USEDEFAULT);
    W := Integer(CW_USEDEFAULT);
    H := Integer(CW_USEDEFAULT);
  end;
end;

procedure TWindow.CreateWindow;
begin
  if not RegisterClass then
    raise EWindow.Create('Failed to register window class');

  inherited;
end;
{$ENDREGION}

initialization
  &Platform := TPlatformWin;

  {
  InitThemeLibrary;

  var ICC: TInitCommonControlsEx;

  ICC.dwSize := SizeOf(ICC);
  ICC.dwICC  := ICC_STANDARD_CLASSES;

  InitCommonControls;
  InitCommonControlsEx(ICC);

  var UxTheme := LoadLibrary('uxtheme.dll');

  AllowDarkModeForWindow := GetProcAddress(UxTheme, MAKEINTRESOURCEA(133));
  {}
end.
