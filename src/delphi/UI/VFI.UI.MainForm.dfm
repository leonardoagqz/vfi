object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'VFI - Validador Fiscal Inteligente'
  ClientHeight = 700
  ClientWidth = 1100
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    Color = 3158064
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 16
      Top = 4
      Caption = 'VFI - Validador Fiscal Inteligente'
      Font.Color = clWhite
      Font.Height = -17
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSub: TLabel
      Left = 16
      Top = 28
      Caption = 'Importacao de XML  |  Validacao automatica  |  Extracao de impostos  |  Analise IA'
      Font.Color = 13619151
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblCount: TLabel
      Left = 940
      Top = 14
      Width = 140
      Height = 17
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = '0 documento(s)'
      Font.Color = 13619151
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlToolbar: TPanel
    Left = 0
    Top = 48
    Width = 1100
    Height = 36
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object btnImportar: TSpeedButton
      Left = 8
      Top = 2
      Width = 110
      Height = 32
      Hint = 'Importar XML fiscal [Ctrl+I]'
      Caption = 'Importar  '
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnImportarClick
    end
    object btnExcluir: TSpeedButton
      Left = 122
      Top = 2
      Width = 110
      Height = 32
      Hint = 'Excluir documento [Del]'
      Caption = 'Excluir  '
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnExcluirClick
    end
    object btnAnalisarIA: TSpeedButton
      Left = 236
      Top = 2
      Width = 130
      Height = 32
      Hint = 'Analisar com IA [Ctrl+A]'
      Caption = 'Analisar com IA'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnAnalisarIAClick
    end
  end
  object PopupImportar: TPopupMenu
    Left = 16
    Top = 88
    object miImportarUm: TMenuItem
      Caption = 'Importar um arquivo...'
      ShortCut = 16457
      OnClick = miImportarUmClick
    end
    object miImportarVarios: TMenuItem
      Caption = 'Importar varios arquivos...'
      OnClick = miImportarVariosClick
    end
  end
  object PopupExcluir: TPopupMenu
    Left = 128
    Top = 88
    object miExcluirSelecionado: TMenuItem
      Caption = 'Excluir selecionado'
      ShortCut = 46
      OnClick = miExcluirSelecionadoClick
    end
    object miLimparTudo: TMenuItem
      Caption = 'Limpar tudo...'
      OnClick = miLimparTudoClick
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 84
    Width = 680
    Height = 402
    Align = alLeft
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 4
    Padding.Right = 4
    Padding.Bottom = 4
    TabOrder = 2
    object lvDocs: TListView
      Left = 8
      Top = 4
      Width = 668
      Height = 394
      Align = alClient
      Columns = <>
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnSelectItem = lvDocsSelectItem
    end
  end
  object Splitter1: TSplitter
    Left = 680
    Top = 84
    Width = 4
    Height = 402
    Align = alLeft
  end
  object pnlRight: TPanel
    Left = 684
    Top = 84
    Width = 416
    Height = 402
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 8
    Padding.Bottom = 4
    TabOrder = 3
    object gbDetalhes: TGroupBox
      Left = 4
      Top = 4
      Width = 404
      Height = 155
      Align = alTop
      Caption = ' Detalhes do Documento '
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object lblTipo: TLabel
        Left = 12
        Top = 20
        Width = 70
        Caption = 'Tipo:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTipoVal: TLabel
        Left = 90
        Top = 20
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNumero: TLabel
        Left = 160
        Top = 20
        Width = 55
        Caption = 'Numero:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNumeroVal: TLabel
        Left = 220
        Top = 20
        ParentFont = False
      end
      object lblValor: TLabel
        Left = 280
        Top = 20
        Width = 38
        Caption = 'Valor:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblValorVal: TLabel
        Left = 322
        Top = 20
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatus: TLabel
        Left = 12
        Top = 44
        Width = 42
        Caption = 'Status:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatusVal: TLabel
        Left = 90
        Top = 44
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ShapeStatus: TShape
        Left = 70
        Top = 46
        Width = 12
        Height = 12
        Brush.Color = clBtnFace
        Pen.Style = psClear
        Shape = stCircle
      end
      object lblEmitente: TLabel
        Left = 12
        Top = 65
        Width = 55
        Caption = 'Emitente:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblEmitenteVal: TLabel
        Left = 90
        Top = 65
        Width = 300
        Caption = '-'
        ParentFont = False
      end
      object lblCNPJE: TLabel
        Left = 12
        Top = 83
        Width = 70
        Caption = 'CNPJ Emit.:'
        ParentFont = False
      end
      object lblCNPJEVal: TLabel
        Left = 90
        Top = 83
        ParentFont = False
      end
      object lblDest: TLabel
        Left = 12
        Top = 101
        Width = 70
        Caption = 'Destinatario:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDestVal: TLabel
        Left = 90
        Top = 101
        Width = 300
        Caption = '-'
        ParentFont = False
      end
      object lblCNPJD: TLabel
        Left = 12
        Top = 119
        Width = 60
        Caption = 'CNPJ Dest.:'
        ParentFont = False
      end
      object lblCNPJDVal: TLabel
        Left = 90
        Top = 119
        ParentFont = False
      end
      object lblValidacao: TLabel
        Left = 12
        Top = 138
        Width = 380
        Height = 13
        AutoSize = False
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pcDetalhes: TPageControl
      Left = 4
      Top = 159
      Width = 404
      Height = 239
      Align = alClient
      TabOrder = 1
      object tsImpostos: TTabSheet
        Caption = 'Impostos'
        object lvImpostos: TListView
          Left = 0
          Top = 0
          Width = 396
          Height = 209
          Align = alClient
          Columns = <>
          GridLines = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
      end
      object tsItens: TTabSheet
        Caption = 'Itens'
        object lvItens: TListView
          Left = 0
          Top = 0
          Width = 396
          Height = 209
          Align = alClient
          Columns = <>
          GridLines = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 486
    Width = 1100
    Height = 192
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Right = 8
    Padding.Bottom = 4
    TabOrder = 4
    object pcLog: TPageControl
      Left = 8
      Top = 0
      Width = 1084
      Height = 188
      Align = alClient
      TabOrder = 0
      object tsLog: TTabSheet
        Caption = 'Log'
        object memLog: TMemo
          Left = 0
          Top = 0
          Width = 1076
          Height = 158
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Consolas'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
      object tsIA: TTabSheet
        Caption = 'Analise IA'
        object memIA: TMemo
          Left = 0
          Top = 0
          Width = 1076
          Height = 158
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Consolas'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 678
    Width = 1100
    Height = 22
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvLowered
    TabOrder = 5
    object lblStatusMsg: TLabel
      Left = 8
      Top = 3
      Caption = 'Pronto'
    end
  end
end
