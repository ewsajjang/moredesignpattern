unit SearchReplaceForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TSearchReplaceDlg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    SearchEdit: TEdit;
    ReplaceEdit: TEdit;
    OkBtn: TButton;
    CancelBtn: TButton;
  private
    function GetFindText: string;
    function GetReplaceText: string;
  public
    function Execute: Boolean;

    property FindText: string read GetFindText;
    property ReplaceText: string read GetReplaceText;
  end;

implementation

{$R *.dfm}

{ TSearchReplaceDlg }

function TSearchReplaceDlg.GetFindText: string;
begin
  Result := SearchEdit.Text;
end;

function TSearchReplaceDlg.GetReplaceText: string;
begin
  Result := ReplaceEdit.Text;
end;

function TSearchReplaceDlg.Execute: Boolean;
begin
  Result := ShowModal = mrOk;
end;

end.
