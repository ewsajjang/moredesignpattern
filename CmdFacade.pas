unit CmdFacade;

interface

uses
  Document, DocumentCmds,

  System.Classes, System.Contnrs,
  Vcl.StdCtrls,

  System.Generics.Collections;

type
  TCmdFacade = class(TObject)
  private
    FCmdList: TObjectList<TDocumentCmd>;
    FCmdIdx: Integer;
    // Possibly this should be registered, rather than created here
    FDocument: TDocument;
    FMemo: TMemo;
    procedure ClearOldCmd;
    procedure PerformCmd(ACmdClass: TDocumentCmdClass; ClearCmdList: Boolean);
    procedure UpdateMemo;
  protected
  public
    constructor Create;
    destructor Destroy; override;

    procedure OpenDocument;
    procedure CloseDocument;
    procedure Undo;
    procedure Redo;
    procedure SearchAndReplace;
    procedure PrettyPrint;

    // This allows a memo control to be updated when the document content
    // changes. This should really be an Observer etc, but the session is
    // only so long!
    procedure RegisterMemo(AMemo: TMemo);
  end;

var
  Commands: TCmdFacade;

implementation

uses
  System.SysUtils, System.Math;

var
  InstanceCnt: Integer = 0;

{ TCommandFacade }

constructor TCmdFacade.Create;
begin
  if InstanceCnt >= 1 then
    raise Exception.Create('Only one instance of TCommandFacade allowed');

  inherited;

  FCmdList := TObjectList<TDocumentCmd>.Create(True); // Frees the list objects itself
  FCmdIdx := -1;
  FDocument := TDocument.Create;
  Inc(InstanceCnt);
end;

destructor TCmdFacade.Destroy;
begin
  FDocument.Free;
  FCmdList.Free;
  Dec(InstanceCnt);

  inherited;
end;

procedure TCmdFacade.ClearOldCmd;
var
  i: Integer;
begin
  for i := FCmdList.Count - 1 downto FCmdIdx + 1 do
  begin
    FCmdList.Delete(i);
  end;
end;

procedure TCmdFacade.PerformCmd(ACmdClass: TDocumentCmdClass; ClearCmdList: Boolean);
var
  LNewCmd: TDocumentCmd;
begin
  LNewCmd := ACmdClass.Create(FDocument);
  try
    LNewCmd.Execute;
    if ClearCmdList then
      FCmdList.Clear
    else
    begin
      // If have done an undo and then choose a new command, clear the
      // old following commands
      ClearOldCmd;
      FCmdIdx := FCmdList.Add(LNewCmd);
    end;
  except
    // Only add command to the command list if doesn't raise an exception
    LNewCmd.Free;
  end;
end;

procedure TCmdFacade.UpdateMemo;
begin
  if Assigned(FMemo) then
    FMemo.Lines.Text := FDocument.Text;
end;

procedure TCmdFacade.OpenDocument;
begin
  PerformCmd(TOpenCmd, True);
  UpdateMemo;
end;

procedure TCmdFacade.CloseDocument;
begin
  PerformCmd(TCloseCmd, True);
  UpdateMemo;
end;

procedure TCmdFacade.Redo;
begin
  if FCmdIdx < FCmdList.Count - 1 then
  begin
    Inc(FCmdIdx);
    if InRange(FCmdIdx, 0, FCmdList.Count - 1) then
    begin
      FCmdList[FCmdIdx].Execute;
      UpdateMemo;
    end;
  end;
end;

procedure TCmdFacade.Undo;
begin
  if InRange(FCmdIdx, 0, FCmdList.Count - 1) then
  begin
    FCmdList[FCmdIdx].Rollback;
    UpdateMemo;
    if FCmdIdx > -1 then
      Dec(FCmdIdx);
  end;
end;

procedure TCmdFacade.SearchAndReplace;
begin
  PerformCmd(TSearchAndReplaceCmd, False);
  UpdateMemo;
end;

procedure TCmdFacade.PrettyPrint;
begin
  PerformCmd(TPrettyPrintCmd, False);
  UpdateMemo;
end;

procedure TCmdFacade.RegisterMemo(AMemo: TMemo);
begin
  FMemo := AMemo;
end;

initialization
  Commands := TCmdFacade.Create;

finalization
  FreeAndNil(Commands);

end.
