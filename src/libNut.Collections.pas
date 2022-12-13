unit libNut.Collections;

{$I libNut.Options.inc}

interface

uses
  libNut.Types,
  libNut.Vectors,
  libNut.Streams;

type
  {$REGION 'TList'}
  TList<TItem> = class
  private type
    {$REGION 'TEnumerator'}
    TEnumerator = class
    private
      FOwner: TList<TItem>;

      FIndex: Integer;

      FLastToFirst: Boolean;
    public
      constructor Create(const AOwner: TList<TItem>; const ALastToFirst: Boolean);

      function GetCurrent: TItem;
      function MoveNext: Boolean;

      property Current: TItem read GetCurrent;
    end;
    {$ENDREGION}
  public type
    TListEvent = reference to procedure(const AItem: TItem);
  private
    FItems: TVector<TItem>;
    FCount: Integer;

    FEnumLastToFirst: Boolean;
    FAllowDuplicates: Boolean;

    FOnAdd:    TListEvent;
    FOnRemove: TListEvent;

    procedure SetAllowDuplicates(const AAllow: Boolean);

    function  GetItem(const AIndex: Integer): TItem;
    procedure SetItem(const AIndex: Integer; const AItem: TItem);
  protected
    procedure DoAdd   (const AItem: TItem); virtual;
    procedure DoRemove(const AItem: TItem); virtual;
  public
    constructor Create;
    destructor  Destroy; override;

    function GetEnumerator: TEnumerator; inline;

    procedure RemoveDuplicates;

    function Find  (const AItem: TItem): Integer;
    function Exists(const AItem: TItem): Boolean; inline;

    function  Add   (const AItem: TItem; const AIndex: Integer = -1): Integer;
    procedure Remove(const AItem: TItem);

    procedure Delete(const AIndex: Integer; ACount: Integer = 1);

    procedure Compress; inline;
    procedure Clear;

    procedure Push(const AItem: TItem); inline;
    function  Pop: TItem;

    procedure Enqueue(const AItem: TItem); inline;
    function  Dequeue: TItem;

    procedure Swap(const AIndex1, AIndex2: Integer);

    procedure Sort(AIndex1, AIndex2: Integer); overload;
    procedure Sort; overload; inline;

    procedure Shuffle;

    function IsEmpty: Boolean; inline;

    property Count: Integer read FCount;
    property Items[const AIndex: Integer]: TItem read GetItem write SetItem; default;

    property EnumLastToFirst: Boolean read FEnumLastToFirst write FEnumLastToFirst;
    property AllowDuplicates: Boolean read FAllowDuplicates write SetAllowDuplicates;

    property OnAdd:    TListEvent read FOnAdd    write FOnAdd;
    property OnRemove: TListEvent read FOnRemove write FOnRemove;
  end;
  {$ENDREGION}

  {$REGION 'TDictionay'}
  TDictionary<TKey, TValue> = class
  public type
    PPair = ^TPair;
    TPair = record
      Key:   TKey;
      Value: TValue;
    end;
  private
    FItems: TList<PPair>;

    FAutoCreate: Boolean;

    FDefault:       TValue;
    FDeleteDefault: Boolean;

    function GetCount: Integer; inline;

    function GetKey(const AIndex: Integer): TKey; inline;

    function  GetValue(const AKey: TKey): TValue;               inline;
    procedure SetValue(const AKey: TKey; const AValue: TValue); inline;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear;

    function Find  (const AKey: TKey): Integer;
    function Exists(const AKey: TKey): Boolean; inline;

    function Read(const AKey: TKey; const ADefault: TValue): TValue; overload;
    function Read(const AKey: TKey):                         TValue; overload; inline;

    procedure Write(const AKey: TKey; const AValue: TValue);

    procedure Delete(const AKey: TKey);

    property AutoCreate: Boolean read FAutoCreate write FAutoCreate;

    property DefaultValue:  TValue  read FDefault       write FDefault;
    property DeleteDefault: Boolean read FDeleteDefault write FDeleteDefault;

    property Count: Integer read GetCount;

    property Keys  [const AIndex: Integer]: TKey   read GetKey;
    property Values[const AKey:   TKey]:    TValue read GetValue write SetValue; default;

    property Items: TList<PPair> read FItems;
  end;
  {$ENDREGION}

  {$REGION 'TStrings'}
  TStrings = class(TList<String>)
  private
    function  GetText:       String;
    procedure SetText(AText: String);
  public
    procedure LoadFromStream(const AStream:   TStream);
    procedure LoadFromFile  (const AFileName: String);

    procedure SaveToStream(const AStream:   TStream; AUnicode: Boolean = True);
    procedure SaveToFile  (const AFileName: String;  AUnicode: Boolean = True);

    property AsText: String read GetText write SetText;
  end;
  {$ENDREGION}

  {$REGION 'TFloats'}
  TFloatss = class(TList<Float>)
    // TODO: Load/Save
  end;
  {$ENDREGION}

  {$REGION 'TIntegers'}
  TIntegers = class(TList<Integer>)
    // TODO: Load/Save
  end;
  {$ENDREGION}

implementation

uses
  libNut.Strings,
  libNut.Types.Compare,
  libNut.Types.Convert;

{$REGION 'TList'}
{$REGION 'TEnumerator'}
constructor TList<TItem>.TEnumerator.Create(const AOwner: TList<TItem>; const ALastToFirst: Boolean);
begin
  inherited Create;

  FOwner := AOwner;

  FLastToFirst := ALastToFirst;

  if FLastToFirst then
    FIndex := FOwner.Count
  else
    FIndex := -1;
end;

function TList<TItem>.TEnumerator.GetCurrent;
begin
  Result := FOwner.FItems[FIndex];
end;

function TList<TItem>.TEnumerator.MoveNext: Boolean;
begin
  if FLastToFirst then
  begin
    Result := FIndex > 0;

    if Result then
      Dec(FIndex);
  end
  else
  begin
    Result := FIndex < FOwner.Count - 1;

    if Result then
      Inc(FIndex);
  end;
end;
{$ENDREGION}

procedure TList<TItem>.SetAllowDuplicates;
begin
  FAllowDuplicates := AAllow;

  if not FAllowDuplicates then
    RemoveDuplicates;
end;

function TList<TItem>.GetItem;
begin
  Result := FItems[AIndex];
end;

procedure TList<TItem>.SetItem;
begin
  FItems[AIndex] := AItem;
end;

procedure TList<TItem>.DoAdd;
begin
  if Assigned(FOnAdd) then
    FOnAdd(AItem);
end;

procedure TList<TItem>.DoRemove;
begin
  if Assigned(FOnRemove) then
    FOnRemove(AItem);
end;

constructor TList<TItem>.Create;
begin
  inherited;

  FCount := 0;

  FEnumLastToFirst := False;
  FAllowDuplicates := True;
end;

destructor TList<TItem>.Destroy;
begin
  inherited;
end;

function TList<TItem>.GetEnumerator;
begin
  Result := TEnumerator.Create(Self, FEnumLastToFirst);
end;

procedure TList<TItem>.RemoveDuplicates;
begin
  for var i := FCount - 1 downto 0 do
    for var j := i - 1 downto 0 do
      if TCompare<TItem>.Compare(FItems[i], FItems[j]) = 0 then
      begin
        Delete(i);
        Break;
      end;
end;

function TList<TItem>.Find;
begin
  if FEnumLastToFirst then
  begin
    for var i := FCount - 1 downto 0 do
      if TCompare<TItem>.Compare(FItems[i], AItem) = 0 then
        Exit(i);
  end
  else
  begin
    for var i := 0 to FCount - 1 do
      if TCompare<TItem>.Compare(FItems[i], AItem) = 0 then
        Exit(i);
  end;

  Result := -1;
end;

function TList<TItem>.Exists;
begin
  Result := Find(AItem) > -1;
end;

function TList<TItem>.Add;
begin
  if not FAllowDuplicates then
  begin
    var i := Find(AItem);

    if i > -1 then
      Exit(i);
  end;

  if FCount = FItems.Length then
    FItems.Length := FItems.Length + 32;

  if (AIndex > -1) and (AIndex < FCount) then
  begin
    Result := AIndex;

    Move(FItems.ItemArray[AIndex], FItems.ItemArray[Result + 1], (FCount - Result) * SizeOf(TItem));
  end
  else
    Result := FCount;

  FItems[Result] := AItem;
  Inc(FCount);

  DoAdd(AItem);
end;

procedure TList<TItem>.Remove;
begin
  for var i := FCount - 1 downto 0 do
    if TCompare<TItem>.Compare(FItems[i], AItem) = 0 then
      Delete(i);
end;

procedure TList<TItem>.Delete;
begin
  if (AIndex < 0) or (AIndex >= FCount) or (ACount <= 0) then
    Exit;

  if (AIndex + ACount) > FCount then
    ACount := FCount - AIndex;

  Dec(FCount, ACount);

  for var i := AIndex + (ACount - 1) downto AIndex do
    DoRemove(FItems[i]);

  if AIndex < FCount then
    Move(FItems.ItemArray[AIndex + ACount], FItems.ItemArray[AIndex], (FCount - AIndex + ACount) * SizeOf(TItem));
end;

procedure TList<TItem>.Compress;
begin
  FItems.Length := FCount;
end;

procedure TList<TItem>.Clear;
begin
  for var i := FCount - 1 downto 0 do
    DoRemove(FItems[i]);

  FItems.Clear;
  FCount := 0;
end;

function TList<TItem>.IsEmpty;
begin
  Result := FCount = 0;
end;

procedure TList<TItem>.Push;
begin
  Add(AItem);
end;

function TList<TItem>.Pop;
begin
  if FCount = 0 then
    Exit;

  Result := FItems[FCount - 1];
  Delete(FCount - 1);
end;

procedure TList<TItem>.Enqueue;
begin
  Add(AItem);
end;

function TList<TItem>.Dequeue;
begin
  if FCount = 0 then
    Exit;

  Result := FItems[0];
  Delete(0);
end;

procedure TList<TItem>.Swap;
begin
  if (AIndex1 < 0) or (AIndex1 > FCount - 1) or (AIndex2 < 0) or (AIndex2 > FCount - 1) or (AIndex1 = AIndex2) then
    Exit;

  var Temp := FItems[AIndex1];
  FItems[AIndex1] := FItems[AIndex2];
  FItems[AIndex2] := Temp;
end;

procedure TList<TItem>.Sort(AIndex1, AIndex2: Integer);
var
  i, j: Integer;
  m:    Integer;
begin
  repeat
    i := AIndex1;
    j := AIndex2;

    m := (AIndex1 + AIndex2) shr 1;

    repeat
      while TCompare<TItem>.Compare(FItems[i], FItems[m]) < 0 do Inc(i);
      while TCompare<TItem>.Compare(FItems[j], FItems[m]) > 0 do Dec(j);

      if i <= j then
      begin
        Swap(i, j);

        if m = i then
          m := j
        else if m = j then
          m := i;

        Inc(i);
        Dec(j);
      end;
    until i > j;

    if AIndex1 < j then
      Sort(AIndex1, j);

    AIndex1 := i;
  until i >= AIndex2;
end;

procedure TList<TItem>.Sort;
begin
  Sort(0, FCount - 1);
end;

procedure TList<TItem>.Shuffle;
begin
  for var i := 0 to FCount - 1 do
    Swap(i, Random(FCount));
end;
{$ENDREGION}

{$REGION 'TDictionary'}
function TDictionary<TKey, TValue>.GetCount;
begin
  Result := FItems.Count;
end;

function TDictionary<TKey, TValue>.GetKey;
begin
  Result := FItems[AIndex].Key;
end;

function TDictionary<TKey, TValue>.GetValue;
begin
  Result := Read(AKey);
end;

procedure TDictionary<TKey, TValue>.SetValue;
begin
  Write(AKey, AValue);
end;

constructor TDictionary<TKey, TValue>.Create;
begin
  inherited;

  FItems := TList<PPair>.Create;
  FItems.AllowDuplicates := False;

  FAutoCreate    := True;
  FDeleteDefault := True;
end;

destructor TDictionary<TKey, TValue>.Destroy;
begin
  Clear;

  FItems.Free;

  inherited;
end;

procedure TDictionary<TKey, TValue>.Clear;
begin
  for var p in FItems do
    Dispose(p);

  FItems.Clear;
end;

function TDictionary<TKey, TValue>.Find;
begin
  for var i := FItems.Count - 1 downto 0 do
    if TCompare<TKey>.Compare(AKey, FItems[i].Key) = 0 then
      Exit(i);

  Result := -1;
end;

function TDictionary<TKey, TValue>.Exists;
begin
  Result := Find(AKey) > -1;
end;

function TDictionary<TKey, TValue>.Read(const AKey: TKey; const ADefault: TValue): TValue;
var
  i: Integer;
begin
  i := Find(AKey);

  if i = -1 then
    Result := ADefault
  else
    Result := FItems[i]^.Value;
end;

function TDictionary<TKey, TValue>.Read(const AKey: TKey): TValue;
begin
  Result := Read(AKey, FDefault);
end;

procedure TDictionary<TKey, TValue>.Write;
var
  IsDefault: Boolean;
  i: Integer;
  p: PPair;
begin
  IsDefault := TCompare<TValue>.Compare(AValue, FDefault) = 0;

  i := Find(AKey);

  if i = -1 then
  begin
    if FAutoCreate and (not IsDefault) then
    begin
      New(p);

      p^.Key   := AKey;
      p^.Value := AValue;

      FItems.Add(P);
    end;
  end
  else
  begin
    if IsDefault and FDeleteDefault then
    begin
      Dispose(FItems[i]);
      FItems.Delete(i);
    end
    else
      FItems[i]^.Value := AValue;
  end;
end;

procedure TDictionary<TKey, TValue>.Delete;
var
  i: Integer;
begin
  i := Find(AKey);

  if i = -1 then
    Exit;

  Dispose(FItems[i]);
  Fitems.Delete(i);
end;
{$ENDREGION}

{$REGION 'TStrings'}
procedure TStrings.LoadFromStream;
begin
  AsText := LoadString(AStream);
end;

procedure TStrings.LoadFromFile;
begin
  AsText := LoadString(AFileName);
end;

procedure TStrings.SaveToStream;
begin
  SaveString(AsText, AStream, AUnicode);
end;

procedure TStrings.SaveToFile;
begin
  SaveString(AsText, AFileName, AUnicode);
end;

function TStrings.GetText;
begin
  Result := '';

  for var i := 0 to Count - 1 do
    Result := Result + Items[i].RTrim + String.CharsCRLF;
end;

procedure TStrings.SetText;
begin
  Clear;

  while AText.IsNotEmpty do
  begin
    Add(AText.SplitFirst(String.CharCR, False).RTrim);

    if AText.FirstChar = String.CharLF then
      AText := AText.Copy(2);
  end;
end;
{$ENDREGION}

{$REGION 'TFloats'}

{$ENDREGION}

{$REGION 'TIntegers'}

{$ENDREGION}

end.
