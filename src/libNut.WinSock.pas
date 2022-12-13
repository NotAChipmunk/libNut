unit libNut.WinSock;

{$I libNut.Options.inc}

{$IF NOT DEFINED(MSWINDOWS)}
  {$MESSAGE FATAL 'Invalid platform'}
{$ENDIF}

interface

uses
  libNut.Types,
  libNut.Streams,
  libNut.Threads,
  libNut.Collections,

  Winapi.Windows,
  Winapi.WinSock;

type
  TTCPSession      = class;
  TTCPSessionClass = class of TTCPSession;

  {$REGION 'TTCPSocket'}
  TTCPSocket = class(TStream)
  private
    FSocket: TSocket;
  protected
    function DoRead (var   AData; const ASize: Int64): Int64; override;
    function DoWrite(const AData; const ASize: Int64): Int64; override;
  public
    Buffer: AnsiString;

    class constructor Create;

    constructor Create(const ASocket: TSocket = 0);
    destructor  Destroy; override;

    procedure Close;

    function Bind   (const APort: Word; const AHost: String = '0.0.0.0'):   Integer;
    function Connect(const APort: Word; const AHost: String = 'localhost'): Integer;
    function Listen (const ABackLog: Integer = 1): Integer; inline;
    function Accept (var ASockAddr: TSockAddr): TTCPSocket;

    procedure ClearBuffer;

    function ReadAll     (const ATimeout: TTime = 0): AnsiString;
    function ReadToBuffer(const ATimeout: TTime = 0): Integer;

    function  CheckRead: Boolean;
    procedure SetBlocking(const ABlocking: Boolean);

    property Socket: TSocket read FSocket;
  end;
  {$ENDREGION}

  {$REGION 'TTCPServer'}
  TTCPServer = class(TThread)
  private
    FPort: Word;
    FBind: String;

    FSocket: TTCPSocket;

    FSessionClass: TTCPSessionClass;
    FSessions: TList<TTCPSession>;

    FConnectionThrottle: TTime;
    FSessionThrottle:    TTime;

    FBlockedIPs: TIntegers;

    FMaxConnections:      Integer;
    FMaxConnectionsPerIP: Integer;

    FBytesIn:  Int64;
    FBytesOut: Int64;

    procedure SetPort(const APort: Word);
    procedure SetBind(const ABind: String);
  protected
    procedure ClearSessions;
  public
    constructor Create(const ASessionClass: TTCPSessionClass);
    destructor  Destroy; override;

    function OnStart: Boolean; override;
    function OnStop:  Integer; override;

    function OnConnect(const ASocket: TTCPSocket; const ASockAddr: TSockAddr): Boolean; virtual;

    function Execute:                                     Boolean; override;
    function SessionExecute(const ASession: TTCPSession): Boolean; virtual;

    property Port: Word   read FPort write SetPort;
    property Bind: String read FBind write SetBind;

    property Socket: TTCPSocket read FSocket;

    property ConnectionThrottle: TTime read FConnectionThrottle write FConnectionThrottle;
    property SessionThrottle:    TTime read FSessionThrottle    write FSessionThrottle;

    property BlockedIPs: TIntegers read FBlockedIPs;

    property MaxConnections:      Integer read FMaxConnections      write FMaxConnections;
    property MaxConnectionsPerIP: Integer read FMaxConnectionsPerIP write FMaxConnectionsPerIP;

    property BytesIn:  Int64 read FBytesIn;
    property BytesOut: Int64 read FBytesOut;
  end;
  {$ENDREGION}

  {$REGION 'TTCPSession'}
  TTCPSession = class(TThread)
  private
    FServer: TTCPServer;
    FSocket: TTCPSocket;

    FIPv4Int: Integer;
    FIPv4Str: String;
  protected
    procedure OnRead (const ASize: Int64);
    procedure OnWrite(const ASize: Int64);
  public
    constructor Create(const AServer: TTCPServer; const ASocket: TTCPSocket; const ASockAddr: TSockAddr); virtual;
    destructor  Destroy; override;

    procedure OnCreate;  virtual;
    procedure OnDestroy; virtual;

    function Execute: Boolean; override;

    procedure Disconnect;

    property Server: TTCPServer read FServer;
    property Socket: TTCPSocket read FSocket;

    property IPv4Str: String  read FIPv4Str;
    property IPv4Int: Integer read fIPv4Int;
  end;
  {$ENDREGION}

{$REGION 'Socket functions'}
function GetIPv4FromHost(const AHostName: String; var AIPv4: String): Boolean;
{$ENDREGION}

implementation

uses
  libNut.Platform,
  libNut.Utils,
  libNut.Timing,
  libNut.Types.Convert;

{$REGION 'Socket functions'}
function GetIPv4FromHost;
var
  HEnt: PHostEnt;
  i:    Integer;
begin
  AIPv4 := '';

  HEnt := GetHostByName(PAnsiChar(AnsiString(AHostName)));
  
  if HEnt = nil then 
    Exit(False);

  for i := 0 to HEnt^.h_length - 1 do
    AIPv4 := AIPv4 + IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.';

  SetLength(AIPv4, Length(AIPv4) - 1);

  Result := True;
end;
{$ENDREGION}

{$REGION 'TTCPSocket'}
function TTCPSocket.DoRead;
var
  i: Integer;
begin
  if IOCTLSocket(FSocket, FIONREAD, i) <> 0 then
    Exit(0);

  Result := Recv(FSocket, AData, ASize, 0);
end;

function TTCPSocket.DoWrite;
begin
  Result := Send(FSocket, AData, ASize, 0);
end;

class constructor TTCPSocket.Create;
var
  WSAData: TWSAData;
begin
  WSAStartup(MakeLong(2, 2), WSAData);
end;

constructor TTCPSocket.Create;
begin
  inherited Create;

  if ASocket = 0 then
    FSocket := Winapi.WinSock.Socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
  else
    FSocket := ASocket;

  ClearBuffer;
end;

destructor TTCPSocket.Destroy;
begin
  Close;

  inherited;
end;

procedure TTCPSocket.Close;
begin
  WinApi.WinSock.closesocket(FSocket);
  FSocket := 0;
end;

function TTCPSocket.Bind;
var
  IPv4:   String;
  AddrIn: TSockAddrIn;
begin
  if not GetIPv4FromHost(AHost, IPv4) then
    Exit(WSAEHOSTUNREACH);

  FillChar(AddrIn, SizeOf(AddrIn), 0);

  AddrIn.sin_family      := AF_INET;
  AddrIn.sin_addr.S_addr := INet_Addr(PAnsiChar(AnsiString(IPv4)));
  AddrIn.sin_port        := HToNS(APort);

  Result := Winapi.WinSock.Bind(FSocket, AddrIn, SizeOf(AddrIn));
end;

function TTCPSocket.Connect;
var
  IPv4:   String;
  AddrIn: TSockAddrIn;
begin
  if not GetIPv4FromHost(AHost, IPv4) then
    Exit(WSAEHOSTUNREACH);

  FillChar(AddrIn, SizeOf(AddrIn), 0);

  AddrIn.sin_family      := AF_INET;
  AddrIn.sin_addr.S_addr := INet_Addr(PAnsiChar(AnsiString(IPv4)));
  AddrIn.sin_port        := HToNS(APort);

  Result := Winapi.WinSock.Connect(FSocket, AddrIn, SizeOf(AddrIn));
end;

function TTCPSocket.Listen;
begin
  Result := Winapi.WinSock.Listen(FSocket, ABackLog);
end;

function TTCPSocket.Accept;
var
  FDSet:    TFDSet;
  SockSize: Integer;
  InSocket: TSocket;
begin
  FDSet.fd_count    := 1;
  FDSet.fd_array[0] := FSocket;

  if Select(0, @FDSet, nil, nil, nil) <> 1 then
    Exit(nil);

  SockSize := SizeOf(ASockAddr);
  InSocket := Winapi.WinSock.Accept(FSocket, @ASockAddr, @SockSize);

  if InSocket <> 0 then
    Result := TTCPSocket.Create(InSocket)
  else
    Result := nil;
end;

procedure TTCPSocket.ClearBuffer;
begin
  Buffer := '';
end;

function TTCPSocket.ReadAll;
  function TryReadAll: AnsiString;
  const
    BufSize = 1024;
  var
    Buf:  AnsiString;
    Len:  Int64;
  begin
    SetLength(Buf, BufSize);

    Result := '';

    repeat
      Len := Read(Buf[1], BufSize);
      if Len <= 0 then 
        Break;

      Result := Result + Copy(Buf, 1, Len);
    until False;
  end;
var
  Timeout: TStopwatch;
begin
  Timeout.Reset;

  repeat
    Result := TryReadAll;

    if Length(Result) > 0 then
      Exit;
  until Timeout.Expired(ATimeout);
end;

function TTCPSocket.ReadToBuffer;
var
  Buf: AnsiString;
begin
  Buf    := ReadAll(ATimeout);
  Result := Length(Buf);
  Buffer := Buffer + Buf;
end;

function TTCPSocket.CheckRead;
begin
  Result := (FSocket <> 0) and (Recv(FSocket, nil^, 0, MSG_OOB) <> 0);
end;

procedure TTCPSocket.SetBlocking;
var
  Blocking: Integer;
begin
  Blocking := &if(ABlocking, 0, 1);
  IOCTLSocket(FSocket, FIONBIO, Blocking);
end;
{$ENDREGION}

{$REGION 'TTCPServer'}
procedure TTCPServer.SetPort;
var
  Restart: Boolean;
begin
  Restart := Running;

  if Restart then
    Stop;

  FPort := APort;

  if Restart then
    Start;
end;

procedure TTCPServer.SetBind;
var
  Restart: Boolean;
begin
  Restart := Running;

  if Restart then
    Stop;

  FBind := FBind;

  if Restart then
    Start;
end;

procedure TTCPServer.ClearSessions;
begin
  CriticalSection.Enter;

  try
    for var i := FSessions.Count - 1 downto 0 do
      FSessions[i].Free;
  finally
    CriticalSection.Leave;
  end;
end;

constructor TTCPServer.Create;
begin
  inherited Create;

  FreeOnStop := False;

  if ASessionClass = nil then
    FSessionClass := TTCPSession
  else
    FSessionClass := ASessionClass;

  FSessions := TList<TTCPSession>.Create;

  FPort := 8081;
  FBind := '0.0.0.0';

  FBlockedIPs := TIntegers.Create;

  FConnectionThrottle := 0.25;
  FSessionThrottle    := 0.05;

  FMaxConnections      := 0;
  FMaxConnectionsPerIP := 0;
end;

destructor TTCPServer.Destroy;
begin
  FSessions.Free;
  FBlockedIPs.Free;

  inherited;
end;

function TTCPServer.OnStart;
begin
  FBytesIn  := 0;
  FBytesOut := 0;

  if Assigned(FSocket) then
    OnStop;

  FSocket := TTCPSocket.Create;

  if FSocket.Bind(FPort, FBind) <> 0 then
    Exit(False);

  if FSocket.Listen <> 0 then
    Exit(False);

  Result := inherited;
end;

function TTCPServer.OnStop;
begin
  ClearSessions;

  FSocket.Free;
  FSocket := nil;

  Result := inherited;
end;

function TTCPServer.OnConnect;
begin
  Result := True;
end;

function TTCPServer.Execute;
var
  InSocket: TTCPSocket;
  Session:  TTCPSession;
  SockAddr: TSockAddr;
begin
  Result := True;

  &Platform.Sleep(FConnectionThrottle);

  if (FMaxConnections > 0) and (FSessions.Count >= FMaxConnections) then
    Exit;

  InSocket := FSocket.Accept(SockAddr);
  if InSocket = nil then
    Exit;

  if FBlockedIPs.Exists(SockAddr.SIn_Addr.S_Addr) then
  begin
    InSocket.Free;
    Exit;
  end;

  if FMaxConnectionsPerIP > 0 then
  begin
    CriticalSection.Enter;
    try
      var i: Integer := 0;

      for Session in FSessions do
        if Session.FIPv4Int = SockAddr.SIn_Addr.S_Addr then
        begin
          Inc(i);

          if i = FMaxConnectionsPerIP then
          begin
            InSocket.Free;
            Exit;
          end;
        end;
    finally
      CriticalSection.Leave;
    end;
  end;

  if not OnConnect(InSocket, SockAddr) then
  begin
    InSocket.Free;
    Exit(False);
  end;

  Session := TTCPSession(FSessionClass.NewInstance);
  Session.Create(Self, InSocket, SockAddr);
end;

function TTCPServer.SessionExecute;
begin
  Result := True;
end;
{$ENDREGION}

{$REGION 'TTCPSession'}
procedure TTCPSession.OnRead;
begin
  if ASize > 0 then
    AtomicIncrement(FServer.FBytesIn, ASize);
end;

procedure TTCPSession.OnWrite;
begin
  if ASize > 0 then
    AtomicIncrement(FServer.FBytesOut, ASize);
end;

constructor TTCPSession.Create;
begin
  inherited Create;

  FreeOnStop := True;

  FServer := AServer;
  FSocket := ASocket;

  FSocket.OnRead  := OnRead;
  FSocket.OnWrite := OnWrite;

  FIPv4Str := String(INet_NToA(ASockAddr.SIn_Addr));
  FIPv4Int := ASockAddr.SIn_Addr.S_Addr;

  FServer.CriticalSection.Section(
    procedure
    begin
      FServer.FSessions.Add(Self);
    end
  );

  FSocket.SetBlocking(False);

  OnCreate;

  Start;
end;

destructor TTCPSession.Destroy;
begin
  OnDestroy;

  FServer.CriticalSection.Section(
    procedure
    begin
      FServer.FSessions.Remove(Self);
    end
  );

  inherited;
end;

procedure TTCPSession.OnCreate;
begin
  {}
end;

procedure TTCPSession.OnDestroy;
begin
  {}
end;

function TTCPSession.Execute;
begin
  if not FSocket.CheckRead then
    Exit(False);

  &Platform.Sleep(FServer.FSessionThrottle);

  Result := FServer.SessionExecute(Self);
end;

procedure TTCPSession.Disconnect;
begin
  FSocket.Close;
end;
{$ENDREGION}

end.
