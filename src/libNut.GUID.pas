unit libNut.GUID;

{$I libNut.Options.inc}

interface

type
  {$REGION 'TGUIDHelper'}
  TGUIDHelper = record helper for TGUID
  public
    class function New: TGUID; static; inline;

    class function FromString(const AStr: String): TGUID; static;
    function ToString: String;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Types.Convert,
  libNut.Strings,
  libNut.Utils,
  libNut.Platform;

{$REGION 'TGUIDHelper'}
class function TGUIDHelper.New;
begin
  Result := &Platform.GenerateGUID;
end;

function TGUIDHelper.ToString;
begin
  Result := '{' + IntToHex(D1, 8) +
            '-' + IntToHex(D2, 4) +
            '-' + IntToHex(D3, 4) +
            '-' + IntToHex(D4[0], 2) + IntToHex(D4[1], 2) +
            '-' + IntToHex(D4[2], 2) + IntToHex(D4[3], 2) + IntToHex(D4[4], 2) + IntToHex(D4[5], 2) + IntToHex(D4[6], 2) + IntToHex(D4[7], 2) + '}';
end;

class function TGUIDHelper.FromString;
begin
  if AStr.IsEmpty
  or (AStr.FirstChar <> '{')
  or (AStr.LastChar <> '}')
  or (AStr.Length <> 38)
  or (AStr[10] <> '-')
  or (AStr[15] <> '-')
  or (AStr[20] <> '-')
  or (AStr[25] <> '-') then
    Exit(TGUID.Empty);

  Result.D1 := HexToInt(AStr.Copy( 2, 8));
  Result.D2 := HexToInt(AStr.Copy(11, 4));
  Result.D3 := HexToInt(AStr.Copy(16, 4));

  for var i := 0 to 7 do
    Result.D4[i] := BaseXToInt(AStr.Copy(21 + (i * 2) + &if(i > 1, 1, 0), 2), 16);
end;
{$ENDREGION}

end.
