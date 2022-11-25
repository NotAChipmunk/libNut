unit libNut.Vectors;

{$I libNut.Options.inc}

interface

uses
  libNut.Streams;

type
  {$REGION 'TVector'}
  TVector<TItem> = record
  private type
    {$REGION 'TEnumerator'}
    TEnumerator = class
    private
      FOwner: ^TVector<TItem>;
      FIndex: Integer;
    public
      function GetCurrent: TItem;
      function MoveNext: Boolean;

      property Current: TItem read GetCurrent;
    end;
    {$ENDREGION}
  private
    function  GetLength: Integer;
    procedure SetLength(const ALength: Integer);

    function  GetItem(const AIndex: Integer): TItem;
    procedure SetItem(const AIndex: Integer; const AItem: TItem);
  public type
    PItemArray = ^TItemArray;
    TItemArray = array of TItem;
  public var
    ItemArray: TItemArray;
  public
    class function Create(const ALength: Integer):    TVector<TItem>; overload; static; inline;
    class function Create(const AItems:  TItemArray): TVector<TItem>; overload; static; inline;

    function GetEnumerator: TEnumerator;

    procedure Clear; inline;

    function Find  (const AItem: TItem): Integer;
    function Exists(const AItem: TItem): Boolean; inline;

    procedure Push(const AItem: TItem);
    function  Pop: TItem;

    procedure Insert(const AItem: TItem; const AIndex: Integer);
    procedure Delete(const AIndex: Integer);

    procedure Add(const AItem:   TItem);          overload; inline;
    procedure Add(const AVector: TVector<TItem>); overload; inline;
    procedure Add(const AItems:  TItemArray);     overload;

    procedure Remove(const AItem: TItem; const AAll: Boolean = False);

    function Copy(const AStart, ACount: Integer): TVector<TItem>;

    procedure Swap(const AIndex1, AIndex2: Integer);

    procedure Sort(AIndex1, AIndex2: Integer); overload;
    procedure Sort; overload; inline;

    procedure Shuffle;

    function IsEmpty: Boolean; inline;

    property Length: Integer read GetLength write SetLength;

    property Items[const AIndex: Integer]: TItem read GetItem write SetItem; default;

    property First: TItem index  0 read GetItem write SetItem;
    property Last:  TItem index -1 read GetItem write SetItem;

    class operator Implicit(const AValues: TItemArray): TVector<TItem>; overload;

    class operator Add     (const ALeft, ARight: TVector<TItem>): TVector<TItem>; overload;
    class operator Subtract(const ALeft, ARight: TVector<TItem>): TVector<TItem>; overload;
    class operator Multiply(const ALeft, ARight: TVector<TItem>): TVector<TItem>; overload;
    class operator Divide  (const ALeft, ARight: TVector<TItem>): TVector<TItem>; overload;

    class operator Add     (const ALeft: TVector<TItem>; const ARight: TItem): TVector<TItem>; overload;
    class operator Subtract(const ALeft: TVector<TItem>; const ARight: TItem): TVector<TItem>; overload;
    class operator Multiply(const ALeft: TVector<TItem>; const ARight: TItem): TVector<TItem>; overload;
    class operator Divide  (const ALeft: TVector<TItem>; const ARight: TItem): TVector<TItem>; overload;

    function ToString(const ADelim: String = ','; const AQuoted: Boolean = True): String;
    class function FromString(AString: String; const ADelim: String = ','; const AQuoted: Boolean = True): TVector<TItem>; static;
  end;
  {$ENDREGION}

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

    // TODO: Range exception
    function  GetItem(const AIndex: Integer): TItem;
    procedure SetItem(const AIndex: Integer; const AItem: TItem);

    procedure SetAllowDuplicates(const AAllow: Boolean);
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

    property First: TItem index  0 read GetItem write SetItem;
    property Last:  TItem index -1 read GetItem write SetItem;

    property EnumLastToFirst: Boolean read FEnumLastToFirst write FEnumLastToFirst;
    property AllowDuplicates: Boolean read FAllowDuplicates write SetAllowDuplicates;

    property OnAdd:    TListEvent read FOnAdd    write FOnAdd;
    property OnRemove: TListEvent read FOnRemove write FOnRemove;
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

  {$REGION 'TIntegers'}
  TIntegers = class(TList<Integer>)
    // TODO: Load/Save
  end;
  {$ENDREGION}

implementation

uses
  libNut.Strings,
  libNut.Types.Operator,
  libNut.Types.Compare,
  libNut.Types.Convert;

{$REGION 'TVector'}
{$REGION 'TEnumerator'}
function TVector<TItem>.TEnumerator.GetCurrent;
begin
  Result := FOwner^[FIndex];
end;

function TVector<TItem>.TEnumerator.MoveNext;
begin
  Result := FIndex < FOwner^.Length - 1;

  if Result then
    Inc(FIndex);
end;
{$ENDREGION}

function TVector<TItem>.GetLength;
begin
  Result := System.Length(ItemArray);
end;

procedure TVector<TItem>.SetLength;
begin
  System.SetLength(ItemArray, ALength);
end;

function TVector<TItem>.GetItem;
begin
  if (AIndex < 0) or (AIndex >= Length) then
    Result := ItemArray[Length - 1]
  else
    Result := ItemArray[AIndex];
end;

procedure TVector<TItem>.SetItem;
begin
  if (AIndex < 0) or (AIndex >= Length) then
    ItemArray[Length - 1] := AItem
  else
    ItemArray[AIndex] := AItem;
end;

class function TVector<TItem>.Create(const ALength: Integer): TVector<TItem>;
begin
  Result.Length := ALength;
end;

class function TVector<TItem>.Create(const AItems: TItemArray): TVector<TItem>;
begin
  Result.Add(AItems);
end;

function TVector<TItem>.GetEnumerator;
begin
  Result := TEnumerator.Create;

  Result.FOwner := @Self;
  Result.FIndex := -1;
end;

procedure TVector<TItem>.Clear;
begin
  Length := 0;
end;

function TVector<TItem>.Find;
begin
  for var i := 0 to Length - 1 do
    if TCompare<TItem>.Compare(ItemArray[i], AItem) = 0 then
      Exit(i);

  Result := -1;
end;

function TVector<TItem>.Exists;
begin
  Result := Find(AItem) > -1;
end;

procedure TVector<TItem>.Push;
begin
  Length := Length + 1;
  Last := AItem;
end;

function TVector<TItem>.Pop;
begin
  Result := Last;
  Length := Length - 1;
end;

procedure TVector<TItem>.Insert;
begin
  if (AIndex < 0) or (AIndex >= Length) then
    Push(AItem)
  else
  begin
    Length := Length + 1;
    Move(ItemArray[AIndex], ItemArray[AIndex + 1], (Length - AIndex) * SizeOf(TItem));
    ItemArray[AIndex] := AItem;
  end;
end;

procedure TVector<TItem>.Delete;
begin
  if (AIndex < 0) or (AIndex >= (Length - 1)) then
    Pop
  else
  begin
    Move(ItemArray[AIndex + 1], ItemArray[AIndex], (Length - 1) * SizeOf(TItem));
    Length := Length - 1;
  end;
end;

procedure TVector<TItem>.Add(const AItem: TItem);
begin
  Push(AItem);
end;

procedure TVector<TItem>.Add(const AVector: TVector<TItem>);
begin
  Add(AVector.ItemArray);
end;

procedure TVector<TItem>.Add(const AItems: TItemArray);
var
  l: Integer;
begin
  l := Length;

  Length := l + System.Length(AItems);

  for var i := 0 to System.Length(AItems) - 1 do
    ItemArray[l + i] := AItems[Low(AItems) + i];
end;

procedure TVector<TItem>.Remove;
var
  i: Integer;
begin
  while Length > 0 do
  begin
    i := Find(AItem);

    if i = -1 then
      Exit;

    Delete(i);

    if not AAll then
      Exit;
  end;
end;

function TVector<TItem>.Copy;
var
  CopyLen: Integer;
begin
  if ACount = 0 then
    Exit
  else if (AStart + ACount) > Length then
    CopyLen := Length - AStart
  else
    CopyLen := ACount;

  Result.Length := CopyLen;
  Move(ItemArray[AStart], Result.ItemArray[0], CopyLen * SizeOf(TItem));
end;

procedure TVector<TItem>.Swap;
begin
  if (AIndex1 < 0) or (AIndex1 >= Length) or (AIndex2 < 0) or (AIndex2 >= Length) or (AIndex1 = AIndex2) then
    Exit;

  var Temp := ItemArray[AIndex1];
  ItemArray[AIndex1] := ItemArray[AIndex2];
  ItemArray[AIndex2] := Temp;
end;

procedure TVector<TItem>.Sort(AIndex1, AIndex2: Integer);
var
  i, j: Integer;
  m:    Integer;
begin
  repeat
    i := AIndex1;
    j := AIndex2;

    m := (AIndex1 + AIndex2) shr 1;

    repeat
      while TCompare<TItem>.Compare(ItemArray[i], ItemArray[m]) < 0 do Inc(i);
      while TCompare<TItem>.Compare(ItemArray[j], ItemArray[m]) > 0 do Dec(j);

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

procedure TVector<TItem>.Sort;
begin
  Sort(0, Length - 1);
end;

procedure TVector<TItem>.Shuffle;
begin
  for var i := 0 to Length - 1 do
    Swap(i, Random(Length));
end;

function TVector<TItem>.IsEmpty;
begin
  Result := Length = 0;
end;

class operator TVector<TItem>.Implicit(const AValues: TItemArray): TVector<TItem>;
begin
  Result.Add(AValues);
end;

class operator TVector<TItem>.Add(const ALeft, ARight: TVector<TItem>): TVector<TItem>;
begin
  Result.Length := ALeft.Length;

  for var i := 0 to Result.Length - 1 do
    if i < ARight.Length then
      Result[i] := TOperator<TItem>.Add(ALeft[i], ARight[i])
    else
      Result[i] := ALeft[i];
end;

class operator TVector<TItem>.Subtract(const ALeft, ARight: TVector<TItem>): TVector<TItem>;
begin
  Result.Length := ALeft.Length;

  for var i := 0 to Result.Length - 1 do
    if i < ARight.Length then
      Result[i] := TOperator<TItem>.Subtract(ALeft[i], ARight[i])
    else
      Result[i] := ALeft[i];
end;

class operator TVector<TItem>.Multiply(const ALeft, ARight: TVector<TItem>): TVector<TItem>;
begin
  Result.Length := ALeft.Length;

  for var i := 0 to Result.Length - 1 do
    if i < ARight.Length then
      Result[i] := TOperator<TItem>.Multiply(ALeft[i], ARight[i])
    else
      Result[i] := ALeft[i];
end;

class operator TVector<TItem>.Divide(const ALeft, ARight: TVector<TItem>): TVector<TItem>;
begin
  Result.Length := ALeft.Length;

  for var i := 0 to Result.Length - 1 do
    if i < ARight.Length then
      Result[i] := TOperator<TItem>.Divide(ALeft[i], ARight[i])
    else
      Result[i] := ALeft[i];
end;

class operator TVector<TItem>.Add(const ALeft: TVector<TItem>; const ARight: TItem): TVector<TItem>;
begin
  Result.Length := ALeft.Length;

  for var i := 0 to Result.Length - 1 do
    Result[i] := TOperator<TItem>.Add(ALeft[i], ARight)
end;

class operator TVector<TItem>.Subtract(const ALeft: TVector<TItem>; const ARight: TItem): TVector<TItem>;
begin
  Result.Length := ALeft.Length;

  for var i := 0 to Result.Length - 1 do
    Result[i] := TOperator<TItem>.Subtract(ALeft[i], ARight)
end;

class operator TVector<TItem>.Multiply(const ALeft: TVector<TItem>; const ARight: TItem): TVector<TItem>;
begin
  Result.Length := ALeft.Length;

  for var i := 0 to Result.Length - 1 do
    Result[i] := TOperator<TItem>.Multiply(ALeft[i], ARight)
end;

class operator TVector<TItem>.Divide(const ALeft: TVector<TItem>; const ARight: TItem): TVector<TItem>;
begin
  Result.Length := ALeft.Length;

  for var i := 0 to Result.Length - 1 do
    Result[i] := TOperator<TItem>.Divide(ALeft[i], ARight)
end;

function TVector<TItem>.ToString;
var
  SItem: String;
begin
  Result := '';

  for var i := 0 to Length - 1 do
  begin
    SItem := TConvert<TItem>.ToStr(ItemArray[i]);

    if AQuoted then
      SItem := SItem.Quote;

    Result := Result.Append(Sitem, ADelim);
  end;
end;

class function TVector<TItem>.FromString;
var
  SItem: String;
begin
  while AString.IsNotEmpty do
  begin
    SItem := AString.SplitFirst(ADelim, True, AQuoted);

    if SItem.IsEmpty then
      Exit;

    if AQuoted then
      SItem := SItem.Unquote;

    Result.Push(TConvert<TItem>.FromStr(SItem));
  end;
end;
{$ENDREGION}

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

procedure TList<TItem>.SetAllowDuplicates;
begin
  FAllowDuplicates := AAllow;

  if not FAllowDuplicates then
    RemoveDuplicates;
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

procedure TList<TItem>.Clear;
begin
  for var i := FCount - 1 downto 0 do
    DoRemove(FItems[i]);

  FItems.Length := 0;
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

{$REGION 'TIntegers'}

{$ENDREGION}

end.
