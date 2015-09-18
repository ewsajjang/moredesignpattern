unit DocumentCmds;

interface

uses
  Document;

type
  TDocumentCmd = class(TObject)
  private
    FDocument: TDocument;
  protected
    procedure DoExecute; virtual; abstract;
    procedure DoRollback; virtual;

    // Used Self Encapsulate Field refactoring here. Now descendant commands
    // can access the document, even if they are declared in other units
    property Document: TDocument read FDocument write FDocument;
  public
    constructor Create(ADocument: TDocument);

    procedure Execute;
    procedure Rollback; // Reverse effect of Execute
  end;

  TDocumentCmdClass = class of TDocumentCmd;

  TOpenCmd = class(TDocumentCmd)
  private
  protected
    procedure DoExecute; override;
  public
  end;

  TCloseCmd = class(TDocumentCmd)
  private
  protected
    procedure DoExecute; override;
  public
  end;

  TSearchAndReplaceCmd = class(TDocumentCmd)
  private
    FOriginalDoc: TDocumentMemento;
    FFindText: string;
    FReplaceText: string;

    procedure ShowSearchReplaceDialog;
  protected
    procedure DoExecute; override;
    procedure DoRollback; override;
  public
  end;

  TPrettyPrintCmd = class(TDocumentCmd)
  private
    FOriginalDoc: TDocumentMemento;
  protected
    procedure DoExecute; override;
    procedure DoRollback; override;
  public
    destructor Destroy; override;
  end;

implementation

uses
  SearchReplaceForm,

  Vcl.Dialogs, System.SysUtils;

{ TDocumentCommand }

constructor TDocumentCmd.Create(ADocument: TDocument);
begin
  inherited Create;

  FDocument := ADocument;
end;

procedure TDocumentCmd.DoRollback;
begin
end;

procedure TDocumentCmd.Execute;
begin
  if Assigned(FDocument) then
    DoExecute;
end;

procedure TDocumentCmd.Rollback;
begin
  if Assigned(FDocument) then
    DoRollback;
end;

{ TOpenCommand }

procedure TOpenCmd.DoExecute;
var
  LFileName: string;
begin
  if PromptForFileName(LFileName, 'XML files (*.xml)|*.xml|CSV files (*.csv)|*.csv') then
    FDocument.OpenFile(LFileName);
end;

{ TCloseCommand }

procedure TCloseCmd.DoExecute;
begin
  FDocument.CloseFile;
end;

{ TSearchAndReplaceCommand }

procedure TSearchAndReplaceCmd.ShowSearchReplaceDialog;
var
  LReplaceDialog: TSearchReplaceDlg;
begin
  FFindText := '';
  FReplaceText := '';

  // Ask for the the find and replace text
  LReplaceDialog := TSearchReplaceDlg.Create(nil);
  try
    if LReplaceDialog.Execute then
    begin
      // Perform the search and replace
      FFindText := LReplaceDialog.FindText;
      FReplaceText := LReplaceDialog.ReplaceText;
    end;
  finally
    FreeAndNil(LReplaceDialog);
  end;
end;

procedure TSearchAndReplaceCmd.DoExecute;
begin
  // Just in case, make sure the current memento is freed
  FreeAndNil(FOriginalDoc);
  // Keep a copy of the document
  FOriginalDoc := FDocument.Memento;

  // Show the S&R dialog if no search has yet been done
  if FFindText.IsEmpty then
    ShowSearchReplaceDialog;

  // Only do sensible operations
  if not FFindText.IsEmpty then
    FDocument.SearchAndReplace(FFindText, FReplaceText);
end;

procedure TSearchAndReplaceCmd.DoRollback;
begin
  if Assigned(FOriginalDoc) then
    FDocument.Memento := FOriginalDoc;
end;

{ TPrettyPrintCommand }

destructor TPrettyPrintCmd.Destroy;
begin
  FreeAndNil(FOriginalDoc);

  inherited;
end;

procedure TPrettyPrintCmd.DoExecute;
begin
  // Just in case, make sure the current memento is freed
  FreeAndNil(FOriginalDoc);
  FOriginalDoc := FDocument.Memento;
  FDocument.PrettyPrint;
end;

procedure TPrettyPrintCmd.DoRollback;
begin
  if Assigned(FOriginalDoc) then
    FDocument.Memento := FOriginalDoc;
end;

end.
