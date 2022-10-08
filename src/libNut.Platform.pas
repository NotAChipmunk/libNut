unit libNut.Platform;

{$I libNut.Options.inc}

interface

type
  {$REGION 'TPlatform'}
  TPlatform = class abstract
  public
    class procedure Exception(const ExceptObject: TObject; const ExceptAddr: Pointer); virtual;

    class function  Time:  TTime;           virtual;
    class function  Ticks: Int64;           virtual;
    class procedure Sleep(ASeconds: TTime); virtual;

    class function ProcessMessages(const AWait: Boolean = False): Boolean; virtual;

    class procedure WaitVSync; virtual;

    class function GenerateGUID: TGUID; virtual;
  end;
  {$ENDREGION}

  TPlatformClass = class of TPlatform;

var
  &Platform: TPlatformClass = TPlatform;

implementation

uses
  libNut.Types.Convert,
  libNut.Exceptions;

{$REGION 'TPlatform'}
class procedure TPlatform.Exception;
var
  ErrorMessage: String;
  ErrorCode:    Integer;
begin
  ErrorMessage := ExceptObject.ClassName + ' at ' + PtrToStr(ExceptAddr);

  if (ExceptObject is TException) then
  begin
    if Length(TException(ExceptObject).Details) > 0 then
      ErrorMessage := ErrorMessage + #13#10 + TException(ExceptObject).Details;

    ErrorCode := TException(ExceptObject).ExitCode;

    //TODO: Log(ErrorMessage, TLogEvent.Error);
  end
  else
    ErrorCode := -1;

  if ErrorCode <> 0 then
    Halt(ErrorCode);
end;

class function TPlatform.Time;
begin
  Result := 0;
end;

class function TPlatform.Ticks;
begin
  Result := 0;
end;

class procedure TPlatform.Sleep;
begin
  {}
end;

class function TPlatform.ProcessMessages;
begin
  Sleep(0);
  Result := True;
end;

class procedure TPlatform.WaitVSync;
begin
  {}
end;

class function TPlatform.GenerateGUID;
begin
  Result := TGUID.Empty;
end;
{$ENDREGION}

end.
