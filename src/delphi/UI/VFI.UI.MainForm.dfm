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
    Height = 614
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
    ExplicitWidth = 1098
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
      Left = 866
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
    ExplicitWidth = 1098
    object btnImportar: TSpeedButton
      Left = 8
      Top = 2
      Width = 110
      Height = 32
      Hint = 'Importar XML fiscal [Ctrl+I]'
      Caption = 'Importar'
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
      Caption = 'Excluir'
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
      ParentShowHint = False
      ShowHint = True
      OnClick = btnConfigurarClick
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 84
    Width = 680
    Height = 614
    Align = alLeft
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 4
    Padding.Right = 4
    Padding.Bottom = 4
    TabOrder = 2
    ExplicitHeight = 606
    object pcBottom: TPageControl
      Left = 8
      Top = 416
      Width = 668
      Height = 194
      ActivePage = tsLog
      Align = alBottom
      TabOrder = 1
      ExplicitTop = 408
      object tsLog: TTabSheet
        Caption = 'Log'
        object memLog: TMemo
          Left = 0
          Top = 0
          Width = 660
          Height = 166
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
          Width = 660
          Height = 166
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
    object lvDocs: TListView
      Left = 8
      Top = 4
      Width = 668
      Height = 412
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
    Height = 614
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 8
    Padding.Bottom = 4
    TabOrder = 3
    ExplicitWidth = 414
    ExplicitHeight = 606
    object gbDetalhes: TGroupBox
      Left = 4
      Top = 4
      Width = 404
      Height = 115
      Align = alTop
      Caption = ' Detalhes '
      TabOrder = 0
      ExplicitWidth = 402
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
      Height = 491
      ActivePage = tsRegras
      Align = alClient
      TabOrder = 1
      ExplicitWidth = 402
      ExplicitHeight = 483
      object tsImpostos: TTabSheet
        Caption = 'Impostos'
        object lvImpostos: TListView
          Left = 0
          Top = 0
          Width = 396
          Height = 463
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
          Height = 463
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
          Height = 463
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
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
            Height = 427
            Align = alClient
            ScrollBars = ssBoth
            TabOrder = 0
          end
          object pnlRegrasBotoes: TPanel
            Left = 0
            Top = 427
            Width = 396
            Height = 34
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
            object btnAddRegra: TButton
              Left = 4
              Top = 4
              Width = 100
              Height = 26
              Caption = 'Adicionar Regra'
              TabOrder = 0
              OnClick = btnAddRegraClick
            end
            object btnDelRegra: TButton
              Left = 108
              Top = 4
              Width = 100
              Height = 26
              Caption = 'Excluir Regra'
              TabOrder = 1
              OnClick = btnDelRegraClick
            end
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
    TabOrder = 4
    ExplicitTop = 690
    ExplicitWidth = 1098
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
