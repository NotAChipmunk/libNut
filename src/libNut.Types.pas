unit libNut.Types;

{$I libNut.Options.inc}

interface

type
  Union = Byte;

  Float = Single;

  TProcedure         = reference to procedure;
  TFunction<TResult> = reference to function: TResult;

  PTypeInfo = ^TTypeInfo;
  TTypeInfo = packed record
    Kind: TTypeKind;
    Name: ShortString;
  end;

  PObject = ^TObject;

  TTime = type Double;

  TArray<TItem> = array of TItem;

implementation

end.
