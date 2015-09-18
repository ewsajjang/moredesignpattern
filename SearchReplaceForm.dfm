object SearchReplaceDlg: TSearchReplaceDlg
  Left = 504
  Top = 342
  Caption = 'Search and Replace'
  ClientHeight = 145
  ClientWidth = 332
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 28
    Width = 49
    Height = 13
    Caption = 'Search for'
  end
  object Label2: TLabel
    Left = 10
    Top = 68
    Width = 62
    Height = 13
    Caption = 'Replace with'
  end
  object SearchEdit: TEdit
    Left = 76
    Top = 24
    Width = 249
    Height = 21
    TabOrder = 0
  end
  object ReplaceEdit: TEdit
    Left = 76
    Top = 64
    Width = 249
    Height = 21
    TabOrder = 1
  end
  object OkBtn: TButton
    Left = 164
    Top = 112
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object CancelBtn: TButton
    Left = 248
    Top = 112
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
