unit libNut.DOM;

{$I libNut.Options.inc}

interface

uses
  libNut.Types,
  libNut.Collections,
  libNut.Config;

type
  TDOMElement = (Text, CData, Comment, Attribute, Node);

  {$REGION 'TDOMCustomElement'}
  TDOMCustomElement = class abstract
  private
    FParent: TDOMCustomElement;
    FName:   String;
    FType:   TDOMElement;
  public
    constructor Create(const AParent: TDOMCustomElement);
    destructor  Destroy; override;

    procedure Clear; virtual;

    procedure FromString(const AString: String); virtual; abstract;

    property Parent: TDOMCustomElement read FParent;
    property Name:   String            read FName;
    property &Type:  TDOMElement       read FType;

    property AsString: String read ToString write FromString;
  end;
  {$ENDREGION}

  {$REGION 'TDOMTextElement'}
  TDOMTextElement = class(TDOMCustomElement)
  private
    FText: String;
  public
    constructor Create(const AParent: TDOMCustomElement);

    procedure Clear; override;

    function  ToString: String;                  override;
    procedure FromString(const AString: String); override;

    property RawText: String read FText write FText;
  end;
  {$ENDREGION}

  {$REGION 'TDOMAttribElement'}
  TDOMAttribElement = class(TDOMCustomElement)
  private
    FAttribs: TAttributes;
  public
    constructor Create(const AParent: TDOMCustomElement);
    destructor  Destroy; override;

    procedure Clear; override;

    property Attributes: TAttributes read FAttribs;
  end;
  {$ENDREGION}

  {$REGION 'TDOMNodeElement'}
  TDOMNodeElement = class(TDOMAttribElement)
  private
    FChildren: TList<TDOMCustomElement>;

    function GetCount: Integer; inline;

    function GetChild(const AIndex: Integer): TDOMCustomElement; inline;
  public
    constructor Create(const AParent: TDOMCustomElement);
    destructor  Destroy; override;

    procedure Clear; override;

    property Count: Integer read GetCount;

    property Children[const AIndex: Integer]: TDOMCustomElement read GetChild; default;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Strings,
  libNut.Types.Convert;

{$REGION 'TDOMCustomElement'}
constructor TDOMCustomElement.Create;
begin
  inherited Create;

  FParent := AParent;
  FName   := '';
end;

destructor TDOMCustomElement.Destroy;
begin
  Clear;

  inherited;
end;

procedure TDOMCustomElement.Clear;
begin
  {}
end;
{$ENDREGION}

{$REGION 'TDOMTextElement'}
constructor TDOMTextElement.Create;
begin
  inherited;

  FType := TDOMElement.Text;
end;

procedure TDOMTextElement.Clear;
begin
  FText := '';
end;

function TDOMTextElement.ToString;
begin
  if FType = TDOMElement.Text then
    Result := FText //TODO: .Unmarkup
  else
    Result := FText;
end;

procedure TDOMTextElement.FromString;
begin
  if FType = TDOMElement.Text then
    FText := AString //TODO: .Markup
  else
    FText := AString;
end;
{$ENDREGION}

{$REGION 'TDOMAttribElement'}
constructor TDOMAttribElement.Create;
begin
  inherited;

  FType    := TDOMElement.Attribute;
  FAttribs := TAttributes.Create;
end;

destructor TDOMAttribElement.Destroy;
begin
  FAttribs.Free;

  inherited;
end;

procedure TDOMAttribElement.Clear;
begin
  FAttribs.Clear;
end;
{$ENDREGION}

{$REGION 'TDOMNodeElement'}
function TDOMNodeElement.GetCount;
begin
  Result := FChildren.Count;
end;

function TDOMNodeElement.GetChild;
begin
  Result := FChildren[AIndex];
end;

constructor TDOMNodeElement.Create;
begin
  inherited;

  FType := TDOMElement.Node;

  FChildren := TList<TDOMCustomElement>.Create;
end;

destructor TDOMNodeElement.Destroy;
begin
  inherited;

  FChildren.Free;
end;

procedure TDOMNodeElement.Clear;
begin
  for var Child in FChildren do
    Child.Free;

  FChildren.Clear;
end;

{$ENDREGION}

end.
