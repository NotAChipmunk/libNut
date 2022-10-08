unit libNut.Exceptions;

{$I libNut.Options.inc}

interface

type
  {$REGION 'TException'}
  TException = class
  private
    FDetails:  String;
    FExitCode: Integer;

  public
    constructor Create(const ADetails: String = ''; const AExitCode: Integer = -1);

    property Details:  String  read FDetails;
    property ExitCode: Integer read FExitCode;
  end;
  {$ENDREGION}

  TExceptionClass = class of TException;

  ERuntime  = class(TException);
  ESafecall = class(TException);
  EAbstract = class(TException);

procedure ExceptionHandler(ExceptObject: TObject; ExceptAddr: Pointer);

implementation

uses
  libNut.Platform,
  libNut.Types.Convert;

{$REGION 'TException'}
constructor TException.Create;
begin
  inherited Create;

  FDetails  := ADetails;
  FExitCode := AExitCode;
end;
{$ENDREGION}

{$REGION 'Error handlers'}
procedure ErrorHandler(ErrorCode: Byte; ErrorAddr: Pointer);
var
  SErrorCode: ShortString;
begin
  Str(ErrorCode, SErrorCode);

  raise ERuntime.Create('Runtime error #' + String(SErrorCode)) at ErrorAddr;
end;

procedure SafecallErrorHandler(ErrorCode: HResult; ErrorAddr: Pointer);
var
  SErrorCode: ShortString;
begin
  Str(ErrorCode, SErrorCode);

  raise ESafecall.Create('Safecall error #' + String(SErrorCode)) at ErrorAddr;
end;

procedure AbstractErrorHandler;
begin
  raise EAbstract.Create('Abstract error');
end;

function GetExceptionClass(P: PExceptionRecord): TExceptionClass;
begin
  Result := TException;
end;

function GetExceptionObject(P: PExceptionRecord): IntPtr;
begin
  Result := IntPtr(TException.Create('Access violation'));
end;

procedure ExceptionHandler(ExceptObject: TObject; ExceptAddr: Pointer);
begin
  &Platform.Exception(ExceptObject, ExceptAddr);
end;
{$ENDREGION}

initialization
  {$REGION 'Error handlers'}
  ErrorProc         := ErrorHandler;
  SafecallErrorProc := SafecallErrorHandler;
  AbstractErrorProc := AbstractErrorHandler;

  ExceptionClass := TException;

  ExceptClsProc := @GetExceptionClass;
  ExceptObjProc := @GetExceptionObject;

  ExceptProc := @ExceptionHandler;
  {$ENDREGION}
end.
