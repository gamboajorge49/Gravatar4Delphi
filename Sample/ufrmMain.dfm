object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Gravatar for Delphi'
  ClientHeight = 408
  ClientWidth = 719
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnShow = FormShow
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 719
    Height = 408
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlMain'
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 622
    ExplicitHeight = 332
    object Image1: TImage
      AlignWithMargins = True
      Left = 295
      Top = 3
      Width = 421
      Height = 402
      Align = alClient
      ExplicitLeft = 392
      ExplicitTop = 56
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
    object GroupBox1: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 286
      Height = 402
      Align = alLeft
      TabOrder = 0
      ExplicitHeight = 326
      object Label1: TLabel
        Left = 9
        Top = 209
        Width = 43
        Height = 15
        Caption = 'Size (Px)'
      end
      object Label2: TLabel
        Left = 9
        Top = 92
        Width = 38
        Height = 15
        Caption = 'Default'
      end
      object Label3: TLabel
        Left = 147
        Top = 92
        Width = 34
        Height = 15
        Caption = 'Rating'
      end
      object lbEmail: TLabeledEdit
        Left = 9
        Top = 23
        Width = 268
        Height = 23
        EditLabel.Width = 29
        EditLabel.Height = 15
        EditLabel.Caption = 'Email'
        TabOrder = 0
        Text = ''
      end
      object leApiKey: TLabeledEdit
        Left = 9
        Top = 66
        Width = 268
        Height = 23
        EditLabel.Width = 63
        EditLabel.Height = 15
        EditLabel.Caption = 'API Key (v3)'
        TabOrder = 1
        Text = ''
      end
      object btnGererate: TButton
        Left = 9
        Top = 267
        Width = 75
        Height = 25
        Caption = 'Generate'
        TabOrder = 9
        OnClick = btnGererateClick
      end
      object btnProfileV3: TButton
        Left = 9
        Top = 296
        Width = 75
        Height = 25
        Caption = 'Profile v3'
        TabOrder = 10
        OnClick = btnProfileV3Click
      end
      object btnQrCodeV3: TButton
        Left = 9
        Top = 325
        Width = 75
        Height = 25
        Caption = 'QR v3'
        TabOrder = 11
        OnClick = btnQrCodeV3Click
      end
      object CheckBox1: TCheckBox
        Left = 177
        Top = 190
        Width = 97
        Height = 17
        Caption = 'Center'
        TabOrder = 6
        OnClick = CheckBox1Click
      end
      object chStretch: TCheckBox
        Left = 177
        Top = 227
        Width = 97
        Height = 17
        Caption = 'Stretch'
        TabOrder = 8
        OnClick = chStretchClick
      end
      object SpinEdit1: TSpinEdit
        Left = 9
        Top = 224
        Width = 121
        Height = 24
        MaxValue = 99999
        MinValue = 80
        TabOrder = 7
        Value = 80
      end
      object cbDefault: TComboBox
        Left = 9
        Top = 109
        Width = 130
        Height = 25
        Style = csOwnerDrawFixed
        ItemHeight = 19
        TabOrder = 2
        OnChange = cbDefaultChange
      end
      object cbRating: TComboBox
        Left = 147
        Top = 109
        Width = 130
        Height = 25
        Style = csOwnerDrawFixed
        ItemHeight = 19
        TabOrder = 3
      end
      object leDefault: TLabeledEdit
        Left = 9
        Top = 154
        Width = 268
        Height = 23
        EditLabel.Width = 56
        EditLabel.Height = 15
        EditLabel.Caption = 'Url Default'
        Enabled = False
        TabOrder = 4
        Text = ''
      end
      object chkUseV3: TCheckBox
        Left = 9
        Top = 182
        Width = 153
        Height = 17
        Caption = 'Use v3 (SHA256)'
        TabOrder = 5
      end
    end
  end
end
