unit CsvParser;

interface

uses
  System.Classes;

type
  TCsvParser = class; // Forward declaration

  TCsvParserStateClass = class of TCsvParserState;
  TCsvParserState = class
  private
    FParser: TCsvParser;

    procedure ChangeState(ANewState: TCsvParserStateClass);
    procedure AddCharToCurrField(AChar: Char);
    procedure AddCurrFieldToList;
  public
    constructor Create(AParser: TCsvParser);

    procedure ProcessChar(AChar: Char; APos: Integer); virtual; abstract;
  end;

  TCsvParserFieldStartState = class(TCsvParserState)
    procedure ProcessChar(AChar: Char; APos: Integer); override;
  end;

  TCsvParserScanFieldState = class(TCsvParserState)
    procedure ProcessChar(AChar: Char; APos: Integer); override;
  end;

  TCsvParserScanQuotedState = class(TCsvParserState)
    procedure ProcessChar(AChar: Char; APos: Integer); override;
  end;

  TCsvParserEndQuotedState = class(TCsvParserState)
    procedure ProcessChar(AChar: Char; APos: Integer); override;
  end;

  TCsvParserGotErrorState = class(TCsvParserState)
    procedure ProcessChar(AChar: Char; APos: Integer); override;
  end;

  TCsvParser = class
  private
    FState: TCsvParserState;
    // Cache state objects for greater performance
    FFieldStartState: TCsvParserFieldStartState;
    FScanFieldState: TCsvParserScanFieldState;
    FScanQuotedState: TCsvParserScanQuotedState;
    FEndQuotedState: TCsvParserEndQuotedState;
    FGotErrorState: TCsvParserGotErrorState;
    // Fields used during parsing
    FCurrField: String;
    FFieldList: TStrings;

    function GetState: TCsvParserStateClass;
    procedure SetState(const Value: TCsvParserStateClass);
  protected
    procedure AddCharToCurrField(AChar: Char);
    procedure AddCurrFieldToList;

    property State: TCsvParserStateClass read GetState write SetState;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ExtractFields(const ASource: string; AFieldList: TStrings);
  end;

implementation

uses
  System.SysUtils, System.Character;

{ TCsvParser }

constructor TCsvParser.Create;
begin
  inherited ;

  FFieldStartState := TCsvParserFieldStartState.Create(Self);
  FScanFieldState := TCsvParserScanFieldState.Create(Self);
  FScanQuotedState := TCsvParserScanQuotedState.Create(Self);
  FEndQuotedState := TCsvParserEndQuotedState.Create(Self);
  FGotErrorState := TCsvParserGotErrorState.Create(Self);
end;

destructor TCsvParser.Destroy;
begin
  FreeAndNil(FFieldStartState);
  FreeAndNil(FScanFieldState);
  FreeAndNil(FScanQuotedState);
  FreeAndNil(FEndQuotedState);
  FreeAndNil(FGotErrorState);

  inherited;
end;

function TCsvParser.GetState: TCsvParserStateClass;
begin
  Result := TCsvParserStateClass(FState.ClassType);
end;

procedure TCsvParser.SetState(const Value: TCsvParserStateClass);
begin
  if Value = TCsvParserFieldStartState then
    FState := FFieldStartState
  else if Value = TCsvParserScanFieldState then
    FState := FScanFieldState
  else if Value = TCsvParserScanQuotedState then
    FState := FScanQuotedState
  else if Value = TCsvParserEndQuotedState then
    FState := FEndQuotedState
  else if Value = TCsvParserGotErrorState then
    FState := FGotErrorState
end;

procedure TCsvParser.ExtractFields(const ASource: string; AFieldList: TStrings);
var
  i: Integer;
  LChar: Char;
begin
  FFieldList := AFieldList;
  Assert(Assigned(FFieldList), 'FieldList not assigned');

  // Initialize by clearing the string list, and starting in FieldStart state
  FFieldList.Clear;
  State := TCsvParserFieldStartState;
  FCurrField := EmptyStr;
  // Read through all the characters in the string
  for i := 1 to Length(ASource) do
  begin
    // Get the next character
    LChar := ASource[i];
    FState.ProcessChar(LChar, i);
  end;

  // If we are in the ScanQuoted or GotError state at the end
  // of the string, there was a problem with a closing quote
  if (State = TCsvParserScanQuotedState) or (State = TCsvParserGotErrorState) then
    raise Exception.Create('Missing closing quote');

  // If the current field is not empty, add it to the list
  if not FCurrField.IsEmpty then
    AddCurrFieldToList;
end;

procedure TCsvParser.AddCharToCurrField(AChar: Char);
begin
  FCurrField := FCurrField + AChar;
end;

procedure TCsvParser.AddCurrFieldToList;
begin
  FFieldList.Add(FCurrField);
  // Clear the field in preparation for collecting the next one
  FCurrField := EmptyStr;
end;

{ TCsvParserState }

constructor TCsvParserState.Create(AParser: TCsvParser);
begin
  inherited Create;

  FParser := AParser;
end;

procedure TCsvParserState.ChangeState(ANewState: TCsvParserStateClass);
begin
  FParser.State := ANewState;
end;

procedure TCsvParserState.AddCharToCurrField(AChar: Char);
begin
  FParser.AddCharToCurrField(AChar);
end;

procedure TCsvParserState.AddCurrFieldToList;
begin
  FParser.AddCurrFieldToList;
end;

{ TCsvParserFieldStartState }

procedure TCsvParserFieldStartState.ProcessChar(AChar: Char; APos: Integer);
begin
  case AChar of
    '"': ChangeState(TCsvParserScanQuotedState);
    ',': AddCurrFieldToList;
  else
    AddCharToCurrField(AChar);
    ChangeState(TCsvParserScanFieldState);
  end;
end;

{ TCsvParserScanFieldState }

procedure TCsvParserScanFieldState.ProcessChar(AChar: Char; APos: Integer);
begin
  if AChar = ',' then
  begin
    AddCurrFieldToList;
    ChangeState(TCsvParserFieldStartState);
  end
  else
    AddCharToCurrField(AChar);
end;

{ TCsvParserScanQuotedState }

procedure TCsvParserScanQuotedState.ProcessChar(AChar: Char; APos: Integer);
begin
  if AChar = '"' then
    ChangeState(TCsvParserEndQuotedState)
  else
    AddCharToCurrField(AChar);
end;

{ TCsvParserEndQuotedState }

procedure TCsvParserEndQuotedState.ProcessChar(AChar: Char; APos: Integer);
begin
  if AChar = ',' then
  begin
    AddCurrFieldToList;
    ChangeState(TCsvParserFieldStartState);
  end
  else
    ChangeState(TCsvParserGotErrorState);
end;

{ TCsvParserGotErrorState }

procedure TCsvParserGotErrorState.ProcessChar(AChar: Char; APos: Integer);
begin
  raise Exception.CreateFmt('Error in line at position %d', [APos]);
end;

end.
