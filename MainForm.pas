unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Menus;

type
  TMainDlg = class(TForm)
    CloseMenuItem: TMenuItem;
    EditMenuItem: TMenuItem;
    ExitMenuItem: TMenuItem;
    FileMenuItem: TMenuItem;
    MainMenu: TMainMenu;
    Memo: TMemo;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    OpenMenuItem: TMenuItem;
    PrettyPrintMenuItem: TMenuItem;
    RedoMenuItem: TMenuItem;
    SearchandReplaceMenuItem: TMenuItem;
    UndoMenuItem: TMenuItem;

    procedure FormCreate(Sender: TObject);

    procedure CloseMenuItemClick(Sender: TObject);
    procedure ExitMenuItemClick(Sender: TObject);
    procedure OpenMenuItemClick(Sender: TObject);
    procedure PrettyPrintMenuItemClick(Sender: TObject);
    procedure RedoMenuItemClick(Sender: TObject);
    procedure SearchandReplaceMenuItemClick(Sender: TObject);
    procedure UndoMenuItemClick(Sender: TObject);
  private
  public
  end;

var
  MainDlg: TMainDlg;

implementation

{$R *.dfm}

uses
  CmdFacade;

procedure TMainDlg.FormCreate(Sender: TObject);
begin
  Commands.RegisterMemo(Memo);
end;

procedure TMainDlg.OpenMenuItemClick(Sender: TObject);
begin
  Commands.OpenDocument;
end;

procedure TMainDlg.CloseMenuItemClick(Sender: TObject);
begin
  Commands.CloseDocument;
end;

procedure TMainDlg.ExitMenuItemClick(Sender: TObject);
begin
  Close;
end;

procedure TMainDlg.UndoMenuItemClick(Sender: TObject);
begin
  Commands.Undo;
end;

procedure TMainDlg.RedoMenuItemClick(Sender: TObject);
begin
  Commands.Redo;
end;

procedure TMainDlg.SearchandReplaceMenuItemClick(Sender: TObject);
begin
  Commands.SearchAndReplace;
end;

procedure TMainDlg.PrettyPrintMenuItemClick(Sender: TObject);
begin
  Commands.PrettyPrint;
end;

end.
