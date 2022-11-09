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

    class function  GetAllEnv: String;                                                                       virtual;
    class function  GetEnv(const AName: String; const ADefault: String = ''): String;                        virtual;
    class procedure SetEnv(const AName: String; const AValue:   String; const APersistent: Boolean = False); virtual;

    class function ExpandEnv(const AValue: String): String;

    class function  GetClipboardStr: String;                                             virtual;
    class procedure SetClipboardStr(const AStr: String; const AUnicode: Boolean = True); virtual;
  end;
  {$ENDREGION}

  TPlatformClass = class of TPlatform;

var
  &Platform: TPlatformClass = TPlatform;

implementation

uses
  libNut.Types.Convert,
  libNut.Strings,
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

class function TPlatform.GetAllEnv;
begin
  Result := '';
end;

class function TPlatform.GetEnv;
begin
  Result := ADefault;
end;

class procedure TPlatform.SetEnv;
begin
  {}
end;

class function TPlatform.ExpandEnv;
var
  NamBuf: String;
  VarBuf: String;
  EnvBuf: String;
  i:      Integer;
begin
  Result := AValue;

  EnvBuf := GetAllEnv;

  i := 0;

  repeat
    VarBuf := '';

    while EnvBuf[i] <> #0 do
    begin
      VarBuf := VarBuf + EnvBuf[i];
      Inc(i);
    end;

    Inc(i);

    NamBuf := VarBuf.SplitFirst('=');
    Result := Result.Replace('%' + NamBuf + '%', VarBuf);
  until EnvBuf[i] = #0;
end;

class function TPlatform.GetClipboardStr;
begin
  Result := '';
end;

class procedure TPlatform.SetClipboardStr;
begin
  {}
end;
{$ENDREGION}

end.
