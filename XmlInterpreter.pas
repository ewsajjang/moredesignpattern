unit XmlInterpreter;

{$B-}

interface

uses
  System.SysUtils, System.Contnrs, System.Generics.Collections;

type
  // Forward declaration of base visitor class
  TXmlInterpreterVisitor = class;

  // Abstract base expression class
  TXmlExpression = class
  private
  protected
    function DoSearchAndReplace(const ATarget, ASearch, AReplace: string): string;
  public
    // Declaring these methods abstract forces descendant classes to implement them
    procedure SearchAndReplace(const ASearch, AReplace: string; ADoTags: Boolean = False); virtual; abstract;
    procedure Accept(AVisitor: TXmlInterpreterVisitor); virtual; abstract;
  end;

  TXmlStartTag = class(TXmlExpression)
  private
    FTagName: string;
  protected
  public
    procedure SearchAndReplace(const ASearch, AReplace: string; ADoTags: Boolean = False); override;
    procedure Accept(AVisitor: TXmlInterpreterVisitor); override;

    property TagName: string read FTagName write FTagName;
  end;

  TXmlEndTag = class(TXmlExpression)
  private
    FTagName: string;
  protected
  public
    procedure SearchAndReplace(const ASearch, AReplace: string; ADoTags: Boolean = False); override;
    procedure Accept(AVisitor: TXmlInterpreterVisitor); override;

    property TagName: string read FTagName write FTagName;
  end;

  TXmlTagList = class;

  TXmlNode = class(TXmlExpression)
  private
    FStartTag: TXmlStartTag;
    FData: string;
    FTagList: TXmlTagList;
    FEndTag: TXmlEndTag;
  public
    destructor Destroy; override;

    procedure SearchAndReplace(const ASearch, AReplace: string; ADoTags: Boolean = False); override;
    procedure Accept(AVisitor: TXmlInterpreterVisitor); override;

    property StartTag: TXmlStartTag read FStartTag write FStartTag;
    property EndTag: TXmlEndTag read FEndTag write FEndTag;
    property Data: string read FData write FData;
    property TagList: TXmlTagList read FTagList write FTagList;
  end;

  TXmlTagList = class(TXmlExpression)
  private
    FList: TObjectList<TXmlNode>;

    function GetItem(Index: Integer): TXmlNode;
  protected
  public
    constructor Create;
    destructor Destroy; override;

    function Add: TXmlNode;
    procedure SearchAndReplace(const ASearch, AReplace: string; ADoTags: Boolean = False); override;
    procedure Accept(AVisitor: TXmlInterpreterVisitor); override;

    property Items[Index: Integer]: TXmlNode read GetItem; default;
  end;

  TXmlProlog = class(TXmlExpression)
  private
    FData: string;
  protected
  public
    procedure SearchAndReplace(const ASearch, AReplace: string; ADoTags: Boolean = False); override;
    procedure Accept(AVisitor: TXmlInterpreterVisitor); override;

    property Data: string read FData write FData;
  end;

  TXmlDoc = class(TXmlExpression)
  private
    FProlog: TXmlProlog;
    FTagList: TXmlTagList;
  protected
  public
    destructor Destroy; override;

    procedure Clear;
    procedure SearchAndReplace(const ASearch, AReplace: string; ADoTags: Boolean = False); override;
    procedure Accept(AVisitor: TXmlInterpreterVisitor); override;

    property Prolog: TXmlProlog read FProlog write FProlog;
    property TagList: TXmlTagList read FTagList write FTagList;
  end;

  // Equates to Client in the Interpreter pattern
  TXmlInterpreter = class
  private
    FXmlDoc: TXmlDoc;
  protected
  public
    constructor Create;
    destructor Destroy; override;

    property XmlDoc: TXmlDoc read FXmlDoc write FXmlDoc;
  end;

  // Base AVisitor class
  TXmlInterpreterVisitor = class
  private
  protected
    // Visit methods are virtual so that AVisitor descendants can choose
    // which methods to implement - it may not be necessary to implement them all
    procedure Visit(AExp: TXmlStartTag); overload; virtual;
    procedure Visit(AExp: TXmlEndTag); overload; virtual;
    procedure Visit(AExp: TXmlNode); overload; virtual;
    procedure Visit(AExp: TXmlTagList); overload; virtual;
    procedure Visit(AExp: TXmlProlog); overload; virtual;
    procedure Visit(AExp: TXmlDoc); overload; virtual;
  public
  end;

  EXmlInterpreterError = class(Exception);

implementation

uses
  System.Classes;

{ TXmlExpression }

function TXmlExpression.DoSearchAndReplace(const ATarget, ASearch,
  AReplace: string): string;
begin
  Result := StringReplace(ATarget, ASearch, AReplace, [rfReplaceAll, rfIgnoreCase]);
end;

{ TXmlStartTag }

procedure TXmlStartTag.SearchAndReplace(const ASearch, AReplace: string;
  ADoTags: Boolean);
begin
  if not ADoTags then
    Exit;

  TagName := DoSearchAndReplace(TagName, ASearch, AReplace);
end;

procedure TXmlStartTag.Accept(AVisitor: TXmlInterpreterVisitor);
begin
  AVisitor.Visit(Self);
end;

{ TXmlEndTag }

procedure TXmlEndTag.SearchAndReplace(const ASearch, AReplace: string;
  ADoTags: Boolean);
begin
  if not ADoTags then
    Exit;

  TagName := DoSearchAndReplace(TagName, ASearch, AReplace);
end;

procedure TXmlEndTag.Accept(AVisitor: TXmlInterpreterVisitor);
begin
  AVisitor.Visit(Self);
end;

{ TXmlNode }

destructor TXmlNode.Destroy;
begin
  FreeAndNil(FStartTag);
  FreeAndNil(FEndTag);
  FreeAndNil(FTagList);

  inherited;
end;

procedure TXmlNode.SearchAndReplace(const ASearch, AReplace: string;
  ADoTags: Boolean);
begin
  if Assigned(StartTag) then
    StartTag.SearchAndReplace(ASearch, AReplace, ADoTags);

  // Since have either a taglist, or data, just search one
  if Assigned(TagList) then
    TagList.SearchAndReplace(ASearch, AReplace, ADoTags)
  else
    Data := DoSearchAndReplace(Data, ASearch, AReplace);

  if Assigned(EndTag) then
    EndTag.SearchAndReplace(ASearch, AReplace, ADoTags);
end;

procedure TXmlNode.Accept(AVisitor: TXmlInterpreterVisitor);
begin
  if Assigned(TagList) then
  begin
    // Visit the tags separately
    if Assigned(StartTag) then
      StartTag.Accept(AVisitor);
    TagList.Accept(AVisitor);
    if Assigned(EndTag) then
      EndTag.Accept(AVisitor);
  end
  else
    // Just visit this (data) node, as can get at the tags from Self
    // Mainly done differently than SearchAndReplace above to make the
    // pretty-printer easier to code.
    AVisitor.Visit(Self);
end;

{ TXmlTagList }

constructor TXmlTagList.Create;
begin
  FList := TObjectList<TXmlNode>.Create(True); // So list manages memory
end;

destructor TXmlTagList.Destroy;
begin
  FreeAndNil(FList);

  inherited;
end;

function TXmlTagList.Add: TXmlNode;
begin
  Result := TXmlNode.Create;
  FList.Add(Result);
end;

function TXmlTagList.GetItem(Index: Integer): TXmlNode;
begin
  Result := nil;

  if (Index >= 0) and (Index < FList.Count) then
    Result := FList[Index];
end;

procedure TXmlTagList.SearchAndReplace(const ASearch, AReplace: string;
  ADoTags: Boolean);
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    Items[i].SearchAndReplace(ASearch, AReplace, ADoTags);
end;

procedure TXmlTagList.Accept(AVisitor: TXmlInterpreterVisitor);
var
  i: Integer;
begin
  AVisitor.Visit(Self);
  for i := 0 to FList.Count - 1 do
    Items[i].Accept(AVisitor);
end;

{ TXmlProlog }

procedure TXmlProlog.SearchAndReplace(const ASearch, AReplace: string;
  ADoTags: Boolean);
begin
  Data := DoSearchAndReplace(Data, ASearch, AReplace);
end;

procedure TXmlProlog.Accept(AVisitor: TXmlInterpreterVisitor);
begin
  AVisitor.Visit(Self);
end;

{ TXmlDoc }

destructor TXmlDoc.Destroy;
begin
  Clear;

  inherited;
end;

procedure TXmlDoc.Clear;
begin
  FreeAndNil(FProlog);
  FreeAndNil(FTagList);
end;

procedure TXmlDoc.SearchAndReplace(const ASearch, AReplace: string;
  ADoTags: Boolean);
begin
  if Assigned(Prolog) then
    Prolog.SearchAndReplace(ASearch, AReplace, ADoTags);

  if Assigned(TagList) then
    TagList.SearchAndReplace(ASearch, AReplace, ADoTags);
end;

procedure TXmlDoc.Accept(AVisitor: TXmlInterpreterVisitor);
begin
  AVisitor.Visit(Self);
  if Assigned(Prolog) then
    Prolog.Accept(AVisitor);

  if Assigned(TagList) then
    TagList.Accept(AVisitor);
end;

{ TXmlInterpreter }

constructor TXmlInterpreter.Create;
begin
  inherited;

  FXmlDoc := TXmlDoc.Create;
end;

destructor TXmlInterpreter.Destroy;
begin
  FreeAndNil(FXmlDoc);

  inherited;
end;

{ TXmlInterpreterVisitor }

procedure TXmlInterpreterVisitor.Visit(AExp: TXmlStartTag);
begin
end;

procedure TXmlInterpreterVisitor.Visit(AExp: TXmlEndTag);
begin
end;

procedure TXmlInterpreterVisitor.Visit(AExp: TXmlNode);
begin
end;

procedure TXmlInterpreterVisitor.Visit(AExp: TXmlTagList);
begin
end;

procedure TXmlInterpreterVisitor.Visit(AExp: TXmlProlog);
begin
end;

procedure TXmlInterpreterVisitor.Visit(AExp: TXmlDoc);
begin
end;

end.
