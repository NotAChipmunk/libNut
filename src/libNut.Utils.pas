unit libNut.Utils;

{$I libNut.Options.inc}

interface

{$REGION 'if'}
function &if(const ACondition: Boolean; const ATrue: String   = 'True'; const AFalse: String   = 'False'): String;   overload; inline;
function &if(const ACondition: Boolean; const ATrue: Integer  = 1;      const AFalse: Integer  = 0):       Integer;  overload; inline;
function &if(const ACondition: Boolean; const ATrue: Extended = 1;      const AFalse: Extended = 0):       Extended; overload; inline;
{$ENDREGION}

implementation

{$REGION 'if'}
function &if(const ACondition: Boolean; const ATrue, AFalse: String): String;
begin
  if ACondition then Result := ATrue else Result := AFalse;
end;

function &if(const ACondition: Boolean; const ATrue, AFalse: Integer): Integer;
begin
  if ACondition then Result := ATrue else Result := AFalse;
end;

function &if(const ACondition: Boolean; const ATrue, AFalse: Extended): Extended;
begin
  if ACondition then Result := ATrue else Result := AFalse;
end;
{$ENDREGION}

end.
