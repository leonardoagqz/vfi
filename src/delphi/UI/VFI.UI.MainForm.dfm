object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'VFI - Validador Fiscal Inteligente'
  ClientHeight = 700
  ClientWidth = 1100
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
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
    Height = 52
    Align = alTop
    BevelOuter = bvNone
    Color = 3158064
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 16
      Top = 6
      Caption = 'VFI - Validador Fiscal Inteligente'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -18
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSub: TLabel
      Left = 16
      Top = 32
      Caption = 'Importe XMLs  |  Validacao automatica  |  Impostos extraidos do XML  |  Analise IA'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13619151
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblCount: TLabel
      Left = 940
      Top = 16
      Width = 140
      Height = 17
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = '0 documento(s)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13619151
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlToolbar: TPanel
    Left = 0
    Top = 52
    Width = 1100
    Height = 38
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object btnImportar: TSpeedButton
      Left = 8
      Top = 3
      Width = 120
      Height = 32
      Hint = 'Importar XML fiscal [Ctrl+I]'
      Caption = 'Importar'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnImportarClick
    end
    object btnExcluir: TSpeedButton
      Left = 134
      Top = 3
      Width = 120
      Height = 32
      Hint = 'Excluir documento [Del]'
      Caption = 'Excluir'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnExcluirClick
    end
    object btnAnalisarIA: TSpeedButton
      Left = 260
      Top = 3
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
    Top = 96
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
    Left = 144
    Top = 96
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
    Top = 90
    Width = 680
    Height = 396
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
      Height = 388
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
    Top = 90
    Width = 4
    Height = 396
    Align = alLeft
  end
  object pnlRight: TPanel
    Left = 684
    Top = 90
    Width = 416
    Height = 396
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
      Height = 130
      Align = alTop
      Caption = ' Detalhes '
      TabOrder = 0
      object lblTipo: TLabel
        Left = 12
        Top = 20
        Caption = 'Tipo:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTipoVal: TLabel
        Left = 110
        Top = 20
        Caption = '-'
      end
      object lblNumero: TLabel
        Left = 12
        Top = 38
        Caption = 'Numero:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNumeroVal: TLabel
        Left = 110
        Top = 38
        Caption = '-'
      end
      object lblEmitente: TLabel
        Left = 12
        Top = 56
        Caption = 'Emitente:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblEmitenteVal: TLabel
        Left = 110
        Top = 56
        Width = 280
        Caption = '-'
      end
      object lblCNPJE: TLabel
        Left = 12
        Top = 74
        Caption = 'CNPJ:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCNPJEVal: TLabel
        Left = 110
        Top = 74
        Caption = '-'
      end
      object lblDest: TLabel
        Left = 12
        Top = 92
        Caption = 'Dest.:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDestVal: TLabel
        Left = 110
        Top = 92
        Width = 280
        Caption = '-'
      end
      object lblCNPJD: TLabel
        Left = 12
        Top = 110
        Caption = 'CNPJ Dest.:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCNPJDVal: TLabel
        Left = 110
        Top = 110
        Caption = '-'
      end
      object lblValor: TLabel
        Left = 220
        Top = 20
        Caption = 'Valor:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblValorVal: TLabel
        Left = 270
        Top = 20
        Caption = '-'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatus: TLabel
        Left = 220
        Top = 40
        Caption = 'Status:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatusVal: TLabel
        Left = 270
        Top = 40
        Caption = '-'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ShapeStatus: TShape
        Left = 250
        Top = 42
        Width = 12
        Height = 12
        Brush.Color = clBtnFace
        Pen.Style = psClear
        Shape = stCircle
      end
    end
    object gbValidacao: TGroupBox
      Left = 4
      Top = 134
      Width = 404
      Height = 60
      Align = alTop
      Caption = ' Validacao '
      TabOrder = 1
      object memValidacao: TMemo
        Left = 2
        Top = 17
        Width = 400
        Height = 41
        Align = alClient
        BorderStyle = bsNone
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
    end
    object gbImpostos: TGroupBox
      Left = 4
      Top = 194
      Width = 404
      Height = 100
      Align = alTop
      Caption = ' Impostos '
      TabOrder = 2
      object lvImpostos: TListView
        Left = 2
        Top = 17
        Width = 400
        Height = 81
        Align = alClient
        Columns = <>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object gbItens: TGroupBox
      Left = 4
      Top = 294
      Width = 404
      Height = 98
      Align = alClient
      Caption = ' Itens '
      TabOrder = 3
      object lvItens: TListView
        Left = 2
        Top = 17
        Width = 400
        Height = 79
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
  object pnlBottom: TPanel
    Left = 0
    Top = 486
    Width = 1100
    Height = 192
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object pcLog: TPageControl
      Left = 0
      Top = 0
      Width = 1100
      Height = 192
      Align = alClient
      TabOrder = 0
      object tsLog: TTabSheet
        Caption = 'Log'
        object memLog: TMemo
          Left = 0
          Top = 0
          Width = 1092
          Height = 162
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
          Width = 1092
          Height = 162
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
