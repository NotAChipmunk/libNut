unit libNut.Config;

{$I libNut.Options.inc}

interface

uses
  libNut.Types,
  libNut.Collections;

type
  // TODO: Attributes should inherite from a dictionary class

  {$REGION 'TAttribute'}
  PAttribute = ^TAttribute;
  TAttribute = record
    Name:  String;
    Value: String;
  end;
  {$ENDREGION}

  {$REGION 'TAttributes'}
  TAttributes = class
  private
    FItems: TList<PAttribute>;

    function GetCount: Integer; inline;

    function GetName(const AIndex: Integer): String;

    function  GetValue(const AIndex: Integer): String;
    procedure SetValue(const AIndex: Integer; const AValue: String);

    function  GetNamed(const AName: String): String;
    procedure SetNamed(const AName, AValue: String);
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear;

    function  Find  (const AName: String): Integer;
    procedure Delete(const AName: String); inline;

    function ReadStr  (const AName: String; const ADefault: String  = ''):    String;
    function ReadInt  (const AName: String; const ADefault: Integer = 0):     Integer; inline;
    function ReadFloat(const AName: String; const ADefault: Float   = 0):     Float;   inline;
    function ReadBool (const AName: String; const ADefault: Boolean = False): Boolean; inline;

    procedure WriteStr  (const AName: String; const AValue: String);
    procedure WriteInt  (const AName: String; const AValue: Integer); inline;
    procedure WriteFloat(const AName: String; const AValue: Float);   inline;
    procedure WriteBool (const AName: String; const AValue: Boolean); inline;

    function ExpandStr(const AStr: String): String;

    property Count: Integer read GetCount;

    property Names [const AIndex: Integer]: String read GetName;
    property Values[const AIndex: Integer]: String read GetValue write SetValue;
    property Named[const AName: String]: String read GetNamed write SetNamed; default;

    // TODO: ToString / FromString
  end;
  {$ENDREGION}

implementation

uses
  libNut.Strings,
  libNut.Types.Convert;

{$REGION 'TAttributes'}
function TAttributes.GetCount;
begin
  Result := FItems.Count;
end;

function TAttributes.GetName;
begin
  Result := FItems[AIndex]^.Name;
end;

function TAttributes.GetValue;
begin
  Result := FItems[AIndex]^.Value;
end;

procedure TAttributes.SetValue;
begin
  FItems[AIndex]^.Value := AValue;
end;

function TAttributes.GetNamed;
begin
  Result := ReadStr(AName);
end;

procedure TAttributes.SetNamed;
begin
  WriteStr(AName, AValue);
end;

constructor TAttributes.Create;
begin
  inherited;

  FItems := TList<PAttribute>.Create;
end;

destructor TAttributes.Destroy;
begin
  Clear;
  FItems.Free;

  inherited;
end;

procedure TAttributes.Clear;
begin
  for var Attrib in FItems do
    Dispose(Attrib);

  FItems.Clear;
end;

function TAttributes.Find;
var
  TrimName: String;
begin
  TrimName := AName.Trim;

  if TrimName.IsEmpty then
    Exit(-1);

  for var i := FItems.Count - 1 downto 0 do
    if TrimName.Same(FItems[i]^.Name, True) then
      Exit(i);

  Result := -1;
end;

procedure TAttributes.Delete;
begin
  WriteStr(AName, '');
end;

function TAttributes.ReadStr;
var
  i: Integer;
begin
  i := Find(AName);

  if i = -1 then
    Result := ADefault
  else
    Result := FItems[i]^.Value;
end;

function TAttributes.ReadInt;
begin
  Result := StrToInt(ReadStr(AName, IntToStr(ADefault)), ADefault);
end;

function TAttributes.ReadFloat;
begin
  Result := StrToFloat(ReadStr(AName, FloatToStr(ADefault)), ADefault);
end;

function TAttributes.ReadBool;
begin
  Result := StrToBool(ReadStr(AName, BoolToStr(ADefault)), ADefault);
end;

procedure TAttributes.WriteStr;
var
  i: Integer;
  a: PAttribute;
begin
  i := Find(AName);

  if AValue.IsEmpty then
  begin
    if i = -1 then Exit;

    Dispose(FItems[i]);
    FItems.Delete(i);
  end
  else if i = -1 then
  begin
    New(a);

    a^.Name  := AName.Trim;
    a^.Value := AValue.Trim;

    FItems.Add(a);
  end
  else
    FItems[i]^.Value := AValue.Trim;
end;

procedure TAttributes.WriteInt;
begin
  WriteStr(AName, IntToStr(AValue));
end;

procedure TAttributes.WriteFloat;
begin
  WriteStr(AName, FloatToStr(AValue));
end;

procedure TAttributes.WriteBool;
begin
  WriteStr(AName, BoolToStr(AValue));
end;

function TAttributes.ExpandStr;
begin
  Result := AStr;

  for var i := 0 to FItems.Count - 1 do
    with Fitems[i]^ do
      Result := Result.Replace('%' + Name + '%', Value, 1, True);
end;

{$ENDREGION}

end.
