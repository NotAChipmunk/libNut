unit libNut.Memory;

{$I libNut.Options.inc}

interface

type
  {$REGION 'TPointerHelper'}
  TPointerHelper = record helper for Pointer
  public const
    Size = SizeOf(Pointer);
    Bits = Size shl 3;
  public
    class function Alloc(const ASize: NativeInt): Pointer; static; inline;

    procedure Resize(const ASize: NativeInt);
    procedure Free;

    procedure Inc(const ACount: Integer = 1); inline;
    procedure Dec(const ACount: Integer = 1); inline;

    procedure Read (var   AData; const ASize: Integer; const AIncrement: Boolean = True); overload;
    procedure Write(const AData; const ASize: Integer; const AIncrement: Boolean = True); overload;

    function  Read<T> (                 const AIncrement: Boolean = True): T; overload; inline;
    procedure Write<T>(const AValue: T; const AIncrement: Boolean = True);    overload; inline;

    function Address(const AIndex: Integer): Pointer; inline;

    function  ArrayRead<T> (const AIndex: Integer): T;               inline;
    procedure ArrayWrite<T>(const AIndex: Integer; const AValue: T); inline;

    function IsNil: Boolean; inline;

    class function FromString(const AStr: String; const ADefault: Pointer = nil): Pointer; static; inline;
    function ToString: String; inline;

    class operator Implicit(const APtr: Pointer): UIntPtr; overload; inline;
    class operator Implicit(const APtr: UIntPtr): Pointer; overload; inline;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Types.Convert;

{$REGION 'TPointerHelper'}
class function TPointerHelper.Alloc;
begin
  GetMem(Result, ASize);
end;

procedure TPointerHelper.Resize;
begin
  if Self = nil then
    GetMem(Self, ASize)
  else
    ReallocMem(Self, ASize);
end;

procedure TPointerHelper.Free;
begin
  if Self = nil then
    Exit;

  FreeMem(Self);
  Self := nil;
end;

procedure TPointerHelper.Inc;
begin
  Self := Address(ACount);
end;

procedure TPointerHelper.Dec;
begin
  Self := Address(-ACount);
end;

procedure TPointerHelper.Read(var AData; const ASize: Integer; const AIncrement: Boolean = True);
begin
  Move(Self^, AData, ASize);

  if AIncrement then
    Inc(ASize);
end;

procedure TPointerHelper.Write(const AData; const ASize: Integer; const AIncrement: Boolean = True);
begin
  Move(AData, Self^, ASize);

  if AIncrement then
    Inc(ASize);
end;

function TPointerHelper.Read<T>(const AIncrement: Boolean = True): T;
begin
  Read(Result, SizeOf(Result), AIncrement);
end;

procedure TPointerHelper.Write<T>(const AValue: T; const AIncrement: Boolean = True);
begin
  Write(AValue, SizeOf(AValue), AIncrement);
end;

function TPointerHelper.Address;
begin
  Result := Pointer(IntPtr(Self) + AIndex);
end;

function TPointerHelper.ArrayRead<T>;
begin
  Move(Address(SizeOf(T) * AIndex)^, Result, SizeOf(T));
end;

procedure TPointerHelper.ArrayWrite<T>;
begin
  Move(AValue, Address(SizeOf(T) * AIndex)^, SizeOf(T));
end;

function TPointerHelper.IsNil;
begin
  Result := Self = nil;
end;

class function TPointerHelper.FromString;
begin
  Result := StrToPtr(AStr, ADefault);
end;

function TPointerHelper.ToString;
begin
  Result := PtrToStr(Self);
end;

class operator TPointerHelper.Implicit(const APtr: Pointer): UIntPtr;
begin
  Result := UIntPtr(APtr);
end;

class operator TPointerHelper.Implicit(const APtr: UIntPtr): Pointer;
begin
  Result := Pointer(APtr);
end;
{$ENDREGION}

end.

