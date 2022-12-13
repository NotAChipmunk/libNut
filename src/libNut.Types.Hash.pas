unit libNut.Types.Hash;

{$I libNut.Options.inc}

interface

type
  THashValue = Cardinal;

  {$REGION 'THash'}
  THash<TType> = class
  type
    THashProc = reference to function(const AValue: TType): THashValue;
  class var
    HashProc: THashProc;
  public
    class function Hash      (const AValue: TType): THashValue;
    class function BinaryHash(const AValue: TType): THashValue;
  end;
  {$ENDREGION}

implementation

{$REGION 'THash'}
class function THash<TType>.Hash;
begin
  if Assigned(HashProc) then
    Result := HashProc(AValue)
  else
    Result := BinaryHash(AValue);
end;

class function THash<TType>.BinaryHash;
begin
  Result := 0;
end;
{$ENDREGION}

initialization

end.
