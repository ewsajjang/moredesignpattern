program MoreDesignPatterns;

uses
  Forms,
  MainForm in 'MainForm.pas' {MainDlg},
  XmlParser in 'XmlParser.pas',
  XmlInterpreter in 'XmlInterpreter.pas',
  XmlInterpreterVisitors in 'XmlInterpreterVisitors.pas',
  CsvParser in 'CsvParser.pas',
  DocumentCmds in 'DocumentCmds.pas',
  Document in 'Document.pas',
  CmdFacade in 'CmdFacade.pas',
  CsvStrategy in 'CsvStrategy.pas',
  SearchReplaceForm in 'SearchReplaceForm.pas' {SearchReplaceDlg},
  XmlStrategy in 'XmlStrategy.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainDlg, MainDlg);
  Application.Run;
end.
