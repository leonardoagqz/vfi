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
    Height = 56
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
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSub: TLabel
      Left = 16
      Top = 33
      Caption = 'Importe XMLs fiscais | Impostos extraidos automaticamente | Validacao automatica | DeepSeek IA'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13619151
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblCount: TLabel
      Left = 940
      Top = 18
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
    Top = 56
    Width = 1100
    Height = 42
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object btnImportar: TSpeedButton
      Left = 8
      Top = 4
      Width = 110
      Height = 34
      Hint = 'Importar um XML fiscal [Ctrl+I]'
      Caption = 'Importar XML'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnImportarClick
    end
    object btnImportarVarios: TSpeedButton
      Left = 124
      Top = 4
      Width = 110
      Height = 34
      Hint = 'Importar varios XMLs de uma vez'
      Caption = 'Importar Varios'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnImportarVariosClick
    end
    object btnAtualizar: TSpeedButton
      Left = 240
      Top = 4
      Width = 90
      Height = 34
      Hint = 'Atualizar lista [Ctrl+R]'
      Caption = 'Atualizar'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnAtualizarClick
    end
    object btnExcluir: TSpeedButton
      Left = 336
      Top = 4
      Width = 80
      Height = 34
      Hint = 'Excluir documento selecionado [Del]'
      Caption = 'Excluir'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnExcluirClick
    end
    object btnAnalisarIA: TSpeedButton
      Left = 460
      Top = 4
      Width = 150
      Height = 34
      Hint = 'Analisar documento com DeepSeek IA [Ctrl+A]'
      Caption = 'Analisar com IA'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnAnalisarIAClick
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 98
    Width = 680
    Height = 392
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
      Height = 384
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
    Top = 98
    Width = 4
    Height = 392
    Align = alLeft
  end
  object pnlRight: TPanel
    Left = 684
    Top = 98
    Width = 416
    Height = 392
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
      Height = 140
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
        Left = 100
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
        Left = 100
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
        Left = 100
        Top = 56
        Caption = '-'
      end
      object lblCNPJE: TLabel
        Left = 12
        Top = 74
        Caption = 'CNPJ Emit.:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCNPJEVal: TLabel
        Left = 100
        Top = 74
        Caption = '-'
      end
      object lblDest: TLabel
        Left = 200
        Top = 20
        Caption = 'Destinatario:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDestVal: TLabel
        Left = 290
        Top = 20
        Width = 100
        Caption = '-'
      end
      object lblCNPJD: TLabel
        Left = 200
        Top = 38
        Caption = 'CNPJ Dest.:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCNPJDVal: TLabel
        Left = 290
        Top = 38
        Caption = '-'
      end
      object lblValor: TLabel
        Left = 200
        Top = 56
        Caption = 'Valor:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblValorVal: TLabel
        Left = 290
        Top = 56
        Caption = '-'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatus: TLabel
        Left = 200
        Top = 74
        Caption = 'Status:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatusVal: TLabel
        Left = 290
        Top = 74
        Caption = '-'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ShapeStatus: TShape
        Left = 354
        Top = 76
        Width = 12
        Height = 12
        Brush.Color = clBtnFace
        Pen.Style = psClear
        Shape = stCircle
      end
    end
    object gbValidacao: TGroupBox
      Left = 4
      Top = 144
      Width = 404
      Height = 80
      Align = alTop
      Caption = ' Validacao Automatica '
      TabOrder = 1
      object memValidacao: TMemo
        Left = 2
        Top = 17
        Width = 400
        Height = 61
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
      Top = 224
      Width = 404
      Height = 100
      Align = alTop
      Caption = ' Impostos (0) '
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
      Top = 324
      Width = 404
      Height = 64
      Align = alClient
      Caption = ' Itens (0) '
      TabOrder = 3
      object lvItens: TListView
        Left = 2
        Top = 17
        Width = 400
        Height = 45
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
    Top = 490
    Width = 1100
    Height = 188
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object pcLog: TPageControl
      Left = 0
      Top = 0
      Width = 1100
      Height = 188
      Align = alClient
      TabOrder = 0
      object tsLog: TTabSheet
        Caption = ' Log de Operacoes '
        object memLog: TMemo
          Left = 0
          Top = 0
          Width = 1092
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
        Caption = ' Analise IA (DeepSeek) '
        object memIA: TMemo
          Left = 0
          Top = 0
          Width = 1092
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
