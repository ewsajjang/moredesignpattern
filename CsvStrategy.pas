unit CsvStrategy;

interface

uses
  Document, CsvParser;

type
  TCsvStrategy = class(TDocumentStrategy)
  private
    FParser: TCsvParser;
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

{ TCsvStrategy }

constructor TCsvStrategy.Create(ADocument : TDocument);
begin
  inherited;

  FParser := TCsvParser.Create;
end;

destructor TCsvStrategy.Destroy;
begin
  FreeAndNil(FParser);

  inherited;
end;

procedure TCsvStrategy.SearchAndReplace(const AFindText, AReplaceText : string);
begin
  Document.Text := StringReplace(Document.Text,AFindText,AReplaceText,[rfReplaceAll,rfIgnoreCase]);
end;

procedure TCsvStrategy.PrettyPrint;
const
  INDENT_STR = '    ';
var
  LTempList: TStringList;
  LFieldList: TStringList;
  i, j: Integer;
  LTemp: string;
begin
  // Break the document into lines
  LTempList := TStringList.Create;
  LFieldList := TStringList.Create;
  // Collect result into temporary string in case there is an error
  LTemp := EmptyStr;
  try
    LTempList.Text := Document.Text;
    for i := 0 to LTempList.Count - 1 do
    begin
      FParser.ExtractFields(LTempList[i], LFieldList);
      // Use simplistic printing scheme of numbering rows, printing fields
      // on new rows, indented slightly
      LTemp := LTemp + Format('Line %d'#13#10,[i]);
      for j := 0 to LFieldList.Count - 1 do
        LTemp := LTemp + Format('%sField %d = %s'#13#10,[INDENT_STR, j, LFieldList[j]]);
      LTemp := LTemp + #13#10;
    end;
    Document.Text := LTemp;
  finally
    FreeAndNil(LFieldList);
    FreeAndNil(LTempList);
  end;
end;

end.
