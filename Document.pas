unit Document;

interface

uses
  System.Classes;

type
  TDocumentMemento = class(TObject)
  private
    FText: string;
  end;

  TDocumentStrategy = class;

  TDocument = class
  private
    FFileText: TStringList;
    FStrategy: TDocumentStrategy;
  private
    function GetText: string;
    procedure SetText(const Value: string);
    function GetMemento: TDocumentMemento;
    procedure SetMemento(const Value: TDocumentMemento);
  protected
  public
    constructor Create;
    destructor Destroy; override;

    procedure OpenFile(const FileName: string);
    procedure CloseFile;
    procedure SearchAndReplace(const FindText, ReplaceText: string);
    procedure PrettyPrint;

    property Text: string read GetText write SetText;
    property Memento: TDocumentMemento read GetMemento write SetMemento;
  end;

  TDocumentStrategy = class
  private
    FDocument: TDocument;
  protected
    property Document: TDocument read FDocument write FDocument;
  public
    constructor Create(ADocument: TDocument); virtual;

    procedure SearchAndReplace(const AFindText, AReplaceText: string); virtual; abstract;
    procedure PrettyPrint; virtual; abstract;
  end;

implementation

uses
  CsvStrategy, XmlStrategy,

  System.SysUtils;

{ TDocument }

constructor TDocument.Create;
begin
  inherited;

  FFileText := TStringList.Create;
end;

destructor TDocument.Destroy;
begin
  FreeAndNil(FFileText);
  FreeAndNil(FStrategy);

  inherited;
end;

function TDocument.GetText: string;
begin
  Result := FFileText.Text;
end;

procedure TDocument.SetText(const Value: string);
begin
  FFileText.Text := Value;
end;

function TDocument.GetMemento: TDocumentMemento;
begin
  // Create a new memento, store the current document state, and return it
  Result := TDocumentMemento.Create;
  Result.FText := Text;
end;

procedure TDocument.SetMemento(const Value: TDocumentMemento);
begin
  // Update the document state from the memento. Normally this would be more complex
  Text := Value.FText;
end;

procedure TDocument.OpenFile(const FileName: string);
const
  CSV_FILE_EXT = '.csv';
  XML_FILE_EXT = '.xml';
begin
  FFileText.LoadFromFile(FileName);
  // Could use Factory Method here, but for now, just inline the code to
  // create the new strategy object
  FreeAndNil(FStrategy);
  if ExtractFileExt(FileName).Equals(CSV_FILE_EXT) then
    FStrategy := TCsvStrategy.Create(Self)
  else if ExtractFileExt(FileName).Equals(XML_FILE_EXT) then
    FStrategy := TXmlStrategy.Create(Self);
end;

procedure TDocument.CloseFile;
begin
  FFileText.Clear;
end;

procedure TDocument.SearchAndReplace(const FindText, ReplaceText: string);
begin
  if Assigned(FStrategy) then
    FStrategy.SearchAndReplace(FindText, ReplaceText);
end;

procedure TDocument.PrettyPrint;
begin
  if Assigned(FStrategy) then
    FStrategy.PrettyPrint;
end;

{ TDocumentStrategy }

constructor TDocumentStrategy.Create(ADocument: TDocument);
begin
  inherited Create;

  FDocument := ADocument;
end;

end.
