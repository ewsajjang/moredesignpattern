unit XmlStrategy;

interface

uses
  Document, XmlParser, XmlInterpreter, XmlInterpreterVisitors;

type
  TXmlStrategy = class(TDocumentStrategy)
  private
    FParser: TXmlParser;
    FInterpreter: TXmlInterpreter;
    FVisitor: TXmlPrettyPrinter;
  protected
  public
    constructor Create(ADocument: TDocument); override;
    destructor  Destroy; override;

    procedure SearchAndReplace(const AFindText, AReplaceText: string); override;
    procedure PrettyPrint; override;
  end;

implementation

uses
  System.Classes, System.SysUtils;

{ TXmlStrategy }

constructor TXmlStrategy.Create(ADocument : TDocument);
begin
  inherited;

  FParser := TXmlParser.Create;
  FInterpreter := TXmlInterpreter.Create;
  FVisitor := TXmlPrettyPrinter.Create;
end;

destructor TXmlStrategy.Destroy;
begin
  FreeAndNil(FParser);
  FreeAndNil(FInterpreter);
  FreeAndNil(FVisitor);

  inherited;
end;

procedure TXmlStrategy.SearchAndReplace(const AFindText, AReplaceText: string);
begin
  FParser.Parse(Document.Text, FInterpreter.XmlDoc);
  FInterpreter.XmlDoc.SearchAndReplace(AFindText, AReplaceText, False);
  // Pretty print as well, just so we can get some output
  FVisitor.Clear;
  FInterpreter.XmlDoc.Accept(FVisitor);
  Document.Text := FVisitor.Text;
end;

procedure TXmlStrategy.PrettyPrint;
begin
  FParser.Parse(Document.Text, FInterpreter.XmlDoc);
  FVisitor.Clear;
  FInterpreter.XmlDoc.Accept(FVisitor);
  Document.Text := FVisitor.Text;
end;

end.
