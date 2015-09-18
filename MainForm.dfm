object MainDlg: TMainDlg
  Left = 353
  Top = 82
  Caption = 'More Design Patterns - SDC 2004'
  ClientHeight = 554
  ClientWidth = 489
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 489
    Height = 554
    Align = alClient
    ReadOnly = True
    TabOrder = 0
  end
  object MainMenu: TMainMenu
    Left = 20
    Top = 12
    object FileMenuItem: TMenuItem
      Caption = 'File'
      object OpenMenuItem: TMenuItem
        Caption = 'Open...'
        OnClick = OpenMenuItemClick
      end
      object CloseMenuItem: TMenuItem
        Caption = 'Close'
        OnClick = CloseMenuItemClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ExitMenuItem: TMenuItem
        AutoHotkeys = maManual
        Caption = 'E&xit'
        OnClick = ExitMenuItemClick
      end
    end
    object EditMenuItem: TMenuItem
      Caption = 'Edit'
      object UndoMenuItem: TMenuItem
        Caption = 'Undo'
        OnClick = UndoMenuItemClick
      end
      object RedoMenuItem: TMenuItem
        Caption = 'Redo'
        OnClick = RedoMenuItemClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object SearchandReplaceMenuItem: TMenuItem
        Caption = 'Search and Replace...'
        OnClick = SearchandReplaceMenuItemClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object PrettyPrintMenuItem: TMenuItem
        Caption = 'Pretty-print'
        OnClick = PrettyPrintMenuItemClick
      end
    end
  end
end
