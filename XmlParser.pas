unit XmlParser;

{$B-}
{
  Grammar
  -------

  We will not be able to parse all XML documents. In particular, we will ignore
  DTDs, attributes, the contents of a prolog, escaped characters (eg &lt;) and
  empty element tags (eg <NothingHere/>. We will be able to cope with empty
  files, though.

  In this BNF, '?' is a character, not the representation of an empty string,
  for which we will use 'e'

  * = zero or more (Kleene closure)
  + = 1 or more (positive closure)
  ^ = 0 or 1 (use superscript 0..1 in article)

  XmlDoc     -> Prolog^ TagList^
  Prolog     -> <?xml PrologData?>
  TagList    -> Node*
  Node       -> StartTag [Data | TagList] EndTag
  StartTag   -> <TagName>
  EndTag     -> </TagName>
  PrologData -> [Any printable characters except <,>,/ and ? ]*
  Data       -> [Any printable characters except <,> and / ]*
  TagName    -> [Any printable characters except <,>,/,space,?]+
}

interface

uses
  XmlInterpreter,

  System.SysUtils, System.Classes, System.Character;

const
  // Token types are the characters 0 to 255, along with the following
  ttEndOfDoc = -1;

type
  TTokenType = Integer;

  TXmlToken = class
  private
    FTokenType: TTokenType;
    FAsString: string;
  public
    property TokenType: TTokenType read FTokenType write FTokenType;
    property AsString: string read FAsString write FAsString;
  end;

  TXmlLexicalAnalyser = class
  private
    FText: string;
    FPosition: Integer;

    procedure SetText(const Value: string);
  public
    procedure GetNextToken(var ANextToken: TXmlToken);
    procedure RollBack(var AToken: TXmlToken);

    property Text: string read FText write SetText;
    property Position: Integer read FPosition;
  end;

  TXmlParser = class
  private
    FToken: TXmlToken;
    FLexAnalyser: TXmlLexicalAnalyser;
    FLastTag: string;

    procedure Match(const ATokenType: TTokenType); overload;
    procedure Match(const AChar: Char); overload;
    procedure RollBack;
    function FollowSymbol: string;
    procedure ConsumeWhiteSpace;

    // Implemantation of EBNF
    procedure XmlDoc(Exp: TXmlDoc);
    procedure Prolog(Exp: TXmlDoc);
    procedure TagList(Exp: TXmlDoc); overload;
    procedure TagList(Exp: TXmlNode); overload;
    procedure Node(Exp: TXmlTagList);
    procedure StartTag(Exp: TXmlNode);
    procedure EndTag(Exp: TXmlNode);
    function PrologData: string;
    function Data: string;
    function TagName: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse(const ADocString: string; ADoc: TXmlDoc);
  end;

  EXmlParserError = class(Exception);

implementation

{ TXmlLexicalAnalyser }

procedure TXmlLexicalAnalyser.GetNextToken(var ANextToken: TXmlToken);
begin
  // Read the next character
  if FPosition > FText.Length then
  begin
    // At the end of the document
    ANextToken.AsString := #0;
    ANextToken.TokenType := ttEndOfDoc;
  end
  else
  begin
    // Return the character
    ANextToken.AsString := FText[FPosition];
    ANextToken.TokenType := FText[FPosition].ToUCS4Char;
    Inc(FPosition);
  end;
end;

procedure TXmlLexicalAnalyser.RollBack(var AToken: TXmlToken);
begin
  if Position > 1 then
    Dec(FPosition);

  if Position > 1 then
  begin
    AToken.AsString := FText[FPosition - 1];
    AToken.TokenType := FText[FPosition - 1].ToUCS4Char;
  end;
end;

procedure TXmlLexicalAnalyser.SetText(const Value: string);
begin
  FPosition := 1;
  FText := Value;
end;

{ TXmlParser }

constructor TXmlParser.Create;
begin
  inherited;
  FToken := TXmlToken.Create;
  FLexAnalyser := TXmlLexicalAnalyser.Create;
end;

destructor TXmlParser.Destroy;
begin
  FToken.Free;
  FLexAnalyser.Free;
  inherited;
end;

procedure TXmlParser.Match(const ATokenType: TTokenType);
begin
  // If the token type T matches the FLookahead token type then FLookAhead is
  // set to the next token, otherwise an exception is raised
  if FToken.TokenType = ATokenType then
    FLexAnalyser.GetNextToken(FToken)
  else
    raise EXmlParserError.CreateFmt('XML syntax error. Expected %s but got %s at %d',
      [Char(ATokenType), Char(FToken.TokenType), FLexAnalyser.Position]);
end;

procedure TXmlParser.Match(const AChar: Char);
begin
  Match(AChar.ToUCS4Char);
end;

procedure TXmlParser.RollBack;
begin
  FLexAnalyser.RollBack(FToken);
end;

function TXmlParser.FollowSymbol: string;
begin
  // Peek at symbol after the lookahead one
  Match(FToken.TokenType);
  Result := FToken.AsString;
  RollBack;
end;

procedure TXmlParser.ConsumeWhiteSpace;
const
  SPACE_CHAR = ' ';
begin
  // Eats 'whitespace' ie chars 0 to 32 inclusive. Here instead of lexical
  // analyser because white space may be allowed sometimes.
  while (FToken.TokenType <> ttEndOfDoc) and (FToken.AsString <= SPACE_CHAR) do
    FLexAnalyser.GetNextToken(FToken);
end;

procedure TXmlParser.XmlDoc(Exp: TXmlDoc);
begin
  // XmlDoc -> Prolog* TagList*
  ConsumeWhiteSpace;
  if FToken.AsString = '<' then
  begin
    // Looking for either a Prolog or a TagList
    if FollowSymbol = '?' then
    begin
      Prolog(Exp);
      ConsumeWhiteSpace;
    end;
    TagList(Exp);
  end;
  ConsumeWhiteSpace;
  Match(ttEndOfDoc);
end;

procedure TXmlParser.Prolog(Exp: TXmlDoc);
begin
  Exp.Prolog := TXmlProlog.Create;
  // Prolog -> <?xml Data?>
  Match('<');
  Match('?');
  Match('x');
  Match('m');
  Match('l');
  ConsumeWhiteSpace;
  Exp.Prolog.Data := PrologData;
  Match('?');
  Match('>');
end;

procedure TXmlParser.TagList(Exp: TXmlDoc);
begin
  Exp.TagList := TXmlTagList.Create;
  // TagList -> Node*
  while FToken.AsString.Equals('<') and not FollowSymbol.Equals('/') do
    Node(Exp.TagList);
end;

procedure TXmlParser.TagList(Exp: TXmlNode);
begin
  Exp.TagList := TXmlTagList.Create;

  // TagList -> Node*
  while FToken.AsString.Equals('<') and not FollowSymbol.Equals('/') do
    Node(Exp.TagList);
end;

procedure TXmlParser.Node(Exp: TXmlTagList);
var
  TempNode: TXmlNode;
begin
  // Node -> StartTag [Data | TagList] EndTag
  // Check to see if this is a new start tag, or the end tag of the list
  TempNode := Exp.Add;
  StartTag(TempNode);
  ConsumeWhiteSpace;
  if FToken.AsString.Equals('<') and not FollowSymbol.Equals('/') then
    // Have the start of another taglist
    TagList(TempNode)
  else
    // Have a data node, possibly empty
    TempNode.Data := Data;

  EndTag(TempNode);
  ConsumeWhiteSpace;
end;

procedure TXmlParser.StartTag(Exp: TXmlNode);
begin
  Exp.StartTag := TXmlStartTag.Create;
  // StartTag -> <TagName>
  Match('<');
  Exp.StartTag.TagName := TagName;
  Match('>');
end;

procedure TXmlParser.EndTag(Exp: TXmlNode);
begin
  Exp.EndTag := TXmlEndTag.Create;
  // EndTag -> </TagName>
  Match('<');
  Match('/');
  Exp.EndTag.TagName := TagName;
  Match('>');
end;

function TXmlParser.PrologData: string;
begin
  Result := EmptyStr;

  // Data -> [Any printable characters except <,>,/ and ? ]*
  while not(FToken.TokenType in [0 .. 31, Ord('<'), Ord('>'), Ord('/'), Ord('?')]) do
  begin
    Result := Result + FToken.AsString;
    Match(FToken.TokenType);
  end;
end;

function TXmlParser.Data: string;
begin
  Result := '';

  // Data -> [Any printable characters except <,> and / ]*
  while not(FToken.TokenType in [0 .. 31, Ord('<'), Ord('>'), Ord('/')]) do
  begin
    Result := Result + FToken.AsString;
    Match(FToken.TokenType);
  end;
end;

function TXmlParser.TagName: string;
begin
  Result := '';

  // TagName  -> [Any printable characters except <,>,/,space]+
  while not(FToken.TokenType in [0 .. 32, Ord('<'), Ord('>'), Ord('/')]) do
  begin
    Result := Result + FToken.AsString;
    Match(FToken.TokenType);
  end;
end;

procedure TXmlParser.Parse(const ADocString: string; ADoc: TXmlDoc);
begin
  ADoc.Clear;
  if ADocString.IsEmpty then
    // Nothing to parse
    Exit;

  FLastTag := EmptyStr;
  FLexAnalyser.Text := ADocString;
  FLexAnalyser.GetNextToken(FToken);
  XmlDoc(ADoc);
end;

end.

