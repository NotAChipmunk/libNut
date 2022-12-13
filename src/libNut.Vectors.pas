unit libNut.Vectors;

{$I libNut.Options.inc}

interface

uses
  libNut.Types;

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
    function  GetLength: Integer;                inline;
    procedure SetLength(const ALength: Integer); inline;

    function  GetItem(const AIndex: Integer): TItem;
    procedure SetItem(const AIndex: Integer; const AItem: TItem);
  public
    ItemArray: TArray<TItem>;

    function GetEnumerator: TEnumerator;

    class operator Implicit(const AVector: TVector<TItem>): TArray <TItem>; inline;
    class operator Implicit(const AArray:  TArray <TItem>): TVector<TItem>; inline;

    procedure Push(const AItem:  TItem);          overload;
    procedure Push(const AItems: TArray <TItem>); overload;
    procedure Push(const AItems: TVector<TItem>); overload; inline;

    function Pop: TItem;

    function Copy(const AIndex: Integer; const ACount: Integer = -1): TVector<TItem>;

    procedure Clear; inline;
    function IsEmpty: Boolean; inline;
    
    property Length: Integer read GetLength write SetLength;

    property Items[const AIndex: Integer]: TItem read GetItem write SetItem; default;

    property First: TItem index  0 read GetItem write SetItem;
    property Last:  TItem index -1 read GetItem write SetItem;

    function ToString(const ADelim: String = ','; const AQuoted: Boolean = True): String;
    class function FromString(AString: String; const ADelim: String = ','; const AQuoted: Boolean = True): TVector<TItem>; static;
  end;
  {$ENDREGION}

  TVector2Index = 0..1;
  TVector3Index = 0..2;
  TVector4Index = 0..3;

  TVector2<TItem> = array[TVector2Index] of TItem;
  TVector3<TItem> = array[TVector3Index] of TItem;
  TVector4<TItem> = array[TVector4Index] of TItem;
 
  TVector2f = TVector2<Float>;
  TVector3f = TVector3<Float>;
  TVector4f = TVector4<Float>;

  TVector2i = TVector2<Integer>;
  TVector3i = TVector3<Integer>;
  TVector4i = TVector4<Integer>;
 
implementation

uses
  libNut.Strings,
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

function TVector<TItem>.GetEnumerator;
begin
  Result := TEnumerator.Create;

  Result.FOwner := @Self;
  Result.FIndex := -1;
end;

class operator TVector<TItem>.Implicit(const AVector: TVector<TItem>): TArray<TItem>;
begin
  Result := AVector.ItemArray;
end;

class operator TVector<TItem>.Implicit(const AArray: TArray<TItem>): TVector<TItem>;
begin
  Result.ItemArray := AArray;
end;

procedure TVector<TItem>.Push(const AItem: TItem);
begin
  Length := Length + 1;
  Last   := AItem;
end;

procedure TVector<TItem>.Push(const AItems: TArray<TItem>);
var
  AddStart: Integer;
begin
  AddStart := Length;
  Length := Length + System.Length(AItems);

  //Move(AItems[Low(AItems)], ItemArray[AddStart], SizeOf(TItem) * (System.Length(AItems) - 1));
  for var i := 0 to System.Length(AItems) - 1 do
    ItemArray[AddStart + i] := AItems[Low(AItems) + i];
end;

procedure TVector<TItem>.Push(const AItems: TVector<TItem>);
begin
  Push(AItems.ItemArray);
end;

function TVector<TItem>.Pop;
begin
  Result := Last;
  Length := Length - 1;
end;

function TVector<TItem>.Copy;
var
  CopyLen: Integer;
begin
  if ACount = 0 then
    Exit
  else if (ACount < 0) or ((AIndex + ACount) > Length) then
    CopyLen := Length - AIndex
  else
    CopyLen := ACount;

  Result.Length := CopyLen;
  Move(ItemArray[AIndex], Result.ItemArray[0], CopyLen * SizeOf(TItem));
end;

procedure TVector<TItem>.Clear;
begin
  Length := 0;
end;

function TVector<TItem>.IsEmpty;
begin
  Result := Length = 0;
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

end.
