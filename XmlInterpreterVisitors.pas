unit XmlInterpreterVisitors;

interface

uses
  XmlInterpreter,

  System.Classes;

type
  TXmlPrettyPrinter = class(TXmlInterpreterVisitor)
  private
    FList: TStringList;
    FIndent: Integer;
  private
    function GetText : string;
  protected
    procedure AddString(AStr: string);
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Visit(AExp: TXmlStartTag); override;
    procedure Visit(AExp: TXmlEndTag); override;
    procedure Visit(AExp: TXmlNode); override;
    procedure Visit(AExp: TXmlProlog); override;
    procedure Clear;

    property Text : string read GetText;
  end;


implementation

uses
  System.SysUtils;

{ TXmlPrettyPrinter }

const
  IndentAmount = 4;

constructor TXmlPrettyPrinter.Create;
begin
  inherited;

  FList := TStringList.Create;
  FIndent := IndentAmount;
end;

destructor TXmlPrettyPrinter.Destroy;
begin
  FreeAndNil(FList);

  inherited;
end;

function TXmlPrettyPrinter.GetText : string;
begin
  Result := FList.Text;
end;

procedure TXmlPrettyPrinter.AddString(AStr : string);
begin
  FList.Add(StringOfChar(' ', FIndent) + AStr);
end;

procedure TXmlPrettyPrinter.Visit(AExp : TXmlStartTag);
begin
  AddString('<' + AExp.TagName + '>');
  Inc(FIndent, IndentAmount);
end;

procedure TXmlPrettyPrinter.Visit(AExp : TXmlEndTag);
begin
  Dec(FIndent, IndentAmount);
  AddString('</' + AExp.TagName + '>');
  AddString('');
end;

procedure TXmlPrettyPrinter.Visit(AExp : TXmlNode);
begin
  if AExp.Data.IsEmpty then
    // Print an empty tag
    AddString('<' + AExp.StartTag.TagName + '/>')
  else
    AddString(Format('<%s>%s</%s>', [AExp.StartTag.TagName, AExp.Data, AExp.EndTag.TagName]));
end;

procedure TXmlPrettyPrinter.Visit(AExp : TXmlProlog);
begin
  AddString('<?xml ' + AExp.Data + '?>');
  AddString('');
end;

procedure TXmlPrettyPrinter.Clear;
begin
  FList.Clear;
end;

end.
