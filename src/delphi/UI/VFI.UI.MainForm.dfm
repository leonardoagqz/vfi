object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'VFI - Validador Fiscal Inteligente'
  ClientHeight = 720
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
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 680
    Top = 84
    Width = 4
    Height = 402
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 486
    Width = 1100
    Height = 4
    Cursor = crVSplit
    Align = alBottom
  end
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
    DesignSize = (
      1100
      48)
    object lblTitle: TLabel
      Left = 16
      Top = 4
      Width = 259
      Height = 23
      Caption = 'VFI - Validador Fiscal Inteligente'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -17
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSub: TLabel
      Left = 16
      Top = 28
      Width = 340
      Height = 13
      Caption = 
        'Importacao XML | Validacao Automatica | Analise IA | Regras Fisc' +
        'ais'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13619151
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblCount: TLabel
      Left = 983
      Top = 14
      Width = 97
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
      Hint = 'Importar XML fiscal'
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
      Hint = 'Excluir documento'
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
      Hint = 'Analisar com IA'
      Caption = 'Analisar com IA'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnAnalisarIAClick
    end
    object btnConfigurar: TSpeedButton
      Left = 372
      Top = 2
      Width = 120
      Height = 32
      Hint = 'Configurar chave API DeepSeek'
      Caption = 'Configurar API'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnConfigurarClick
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
      Height = 115
      Align = alTop
      Caption = ' Detalhes '
      TabOrder = 0
      object lblTipo: TLabel
        Left = 12
        Top = 22
        Width = 26
        Height = 13
        Caption = 'Tipo:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTipoVal: TLabel
        Left = 90
        Top = 22
        Width = 3
        Height = 13
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNumero: TLabel
        Left = 160
        Top = 22
        Width = 46
        Height = 13
        Caption = 'Numero:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNumeroVal: TLabel
        Left = 220
        Top = 22
        Width = 3
        Height = 13
      end
      object lblValor: TLabel
        Left = 280
        Top = 22
        Width = 29
        Height = 13
        Caption = 'Valor:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblValorVal: TLabel
        Left = 322
        Top = 22
        Width = 3
        Height = 13
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatus: TLabel
        Left = 12
        Top = 44
        Width = 35
        Height = 13
        Caption = 'Status:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatusVal: TLabel
        Left = 90
        Top = 44
        Width = 3
        Height = 13
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
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
        Top = 66
        Width = 49
        Height = 13
        Caption = 'Emitente:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblEmitenteVal: TLabel
        Left = 90
        Top = 66
        Width = 3
        Height = 13
      end
      object lblCNPJE: TLabel
        Left = 12
        Top = 84
        Width = 55
        Height = 13
        Caption = 'CNPJ Emit.:'
      end
      object lblCNPJEVal: TLabel
        Left = 90
        Top = 84
        Width = 3
        Height = 13
      end
      object lblDest: TLabel
        Left = 12
        Top = 100
        Width = 66
        Height = 13
        Caption = 'Destinatario:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDestVal: TLabel
        Left = 90
        Top = 100
        Width = 3
        Height = 13
      end
    end
    object pcDetalhes: TPageControl
      Left = 4
      Top = 119
      Width = 404
      Height = 279
      ActivePage = tsImpostos
      Align = alClient
      TabOrder = 1
      object tsImpostos: TTabSheet
        Caption = 'Impostos'
        object lvImpostos: TListView
          Left = 0
          Top = 0
          Width = 396
          Height = 249
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
          Height = 249
          Align = alClient
          Columns = <>
          GridLines = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
      end
      object tsAnaliseIA: TTabSheet
        Caption = 'Analise IA'
        object memResultadoIA: TMemo
          Left = 0
          Top = 0
          Width = 396
          Height = 249
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
      object tsRegras: TTabSheet
        Caption = 'Regras Fiscais'
        object memRegrasFiscais: TMemo
          Left = 0
          Top = 0
          Width = 396
          Height = 249
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Consolas'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssBoth
          TabOrder = 0
          OnChange = memRegrasFiscaisChange
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 490
    Width = 1100
    Height = 208
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Right = 8
    Padding.Bottom = 4
    TabOrder = 4
    object pcBottom: TPageControl
      Left = 8
      Top = 0
      Width = 1084
      Height = 204
      ActivePage = tsLog
      Align = alClient
      TabOrder = 0
      object tsLog: TTabSheet
        Caption = 'Log'
        object memLog: TMemo
          Left = 0
          Top = 0
          Width = 1076
          Height = 174
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
      object tsValidacoes: TTabSheet
        Caption = 'Validacao Automatica'
        object memValidacoes: TMemo
          Left = 0
          Top = 0
          Width = 1076
          Height = 174
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
    Top = 698
    Width = 1100
    Height = 22
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvLowered
    TabOrder = 5
    object lblStatusMsg: TLabel
      Left = 8
      Top = 3
      Width = 35
      Height = 13
      Caption = 'Pronto'
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
end
