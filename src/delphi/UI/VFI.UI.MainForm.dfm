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
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 16
      Top = 8
      Caption = 'VFI - Validador Fiscal Inteligente'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitle: TLabel
      Left = 16
      Top = 35
      Caption = 'Clean Architecture | Repository Pattern | SOLID | Delphi 12 | DeepSeek IA'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16771797
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblDocCount: TLabel
      Left = 960
      Top = 20
      Width = 120
      Height = 15
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = '0 documento(s)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16771797
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 60
    Width = 700
    Height = 430
    Align = alLeft
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    Padding.Right = 4
    Padding.Bottom = 8
    TabOrder = 1
    object StringGridDocs: TStringGrid
      Left = 8
      Top = 8
      Width = 688
      Height = 414
      Align = alClient
      DefaultRowHeight = 22
      FixedCols = 0
      RowCount = 2
      TabOrder = 0
      OnClick = StringGridDocsClick
    end
  end
  object Splitter1: TSplitter
    Left = 700
    Top = 60
    Width = 4
    Height = 430
    Align = alLeft
    Color = clBtnFace
    ParentColor = False
  end
  object pnlRight: TPanel
    Left = 704
    Top = 60
    Width = 396
    Height = 430
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 4
    Padding.Top = 8
    Padding.Right = 8
    Padding.Bottom = 8
    TabOrder = 2
    object gbDetalhes: TGroupBox
      Left = 4
      Top = 8
      Width = 384
      Height = 200
      Align = alTop
      Caption = ' Detalhes do Documento '
      TabOrder = 0
      object lblTipo: TLabel
        Left = 12
        Top = 24
        Width = 26
        Height = 15
        Caption = 'Tipo:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTipoVal: TLabel
        Left = 120
        Top = 24
        Width = 6
        Height = 15
        Caption = '-'
      end
      object lblNumero: TLabel
        Left = 12
        Top = 44
        Width = 42
        Height = 15
        Caption = 'Numero:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblNumeroVal: TLabel
        Left = 120
        Top = 44
        Width = 6
        Height = 15
        Caption = '-'
      end
      object lblEmitente: TLabel
        Left = 12
        Top = 64
        Width = 50
        Height = 15
        Caption = 'Emitente:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblEmitenteVal: TLabel
        Left = 120
        Top = 64
        Width = 250
        Height = 15
        Caption = '-'
      end
      object lblCNPJE: TLabel
        Left = 12
        Top = 84
        Width = 66
        Height = 15
        Caption = 'CNPJ Emit.:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCNPJEVal: TLabel
        Left = 120
        Top = 84
        Width = 6
        Height = 15
        Caption = '-'
      end
      object lblDest: TLabel
        Left = 12
        Top = 104
        Width = 68
        Height = 15
        Caption = 'Destinatario:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDestVal: TLabel
        Left = 120
        Top = 104
        Width = 250
        Height = 15
        Caption = '-'
      end
      object lblCNPJD: TLabel
        Left = 12
        Top = 124
        Width = 64
        Height = 15
        Caption = 'CNPJ Dest.:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCNPJDVal: TLabel
        Left = 120
        Top = 124
        Width = 6
        Height = 15
        Caption = '-'
      end
      object lblValor: TLabel
        Left = 12
        Top = 144
        Width = 33
        Height = 15
        Caption = 'Valor:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblValorVal: TLabel
        Left = 120
        Top = 144
        Width = 6
        Height = 15
        Caption = '-'
      end
      object lblStatus: TLabel
        Left = 12
        Top = 164
        Width = 38
        Height = 15
        Caption = 'Status:'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatusVal: TLabel
        Left = 120
        Top = 164
        Width = 6
        Height = 15
        Caption = '-'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object gbItens: TGroupBox
      Left = 4
      Top = 208
      Width = 384
      Height = 218
      Align = alClient
      Caption = ' Itens do Documento '
      TabOrder = 1
      object memItens: TMemo
        Left = 2
        Top = 17
        Width = 380
        Height = 199
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
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 490
    Width = 1100
    Height = 210
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 4
    Padding.Right = 8
    Padding.Bottom = 4
    TabOrder = 3
    object pcLog: TPageControl
      Left = 8
      Top = 4
      Width = 1084
      Height = 166
      Align = alClient
      TabOrder = 0
      object tsLog: TTabSheet
        Caption = 'Log de Operacoes'
        object memLog: TMemo
          Left = 0
          Top = 0
          Width = 1076
          Height = 136
          Align = alClient
          BorderStyle = bsNone
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
        Caption = 'Resultado Analise IA (DeepSeek)'
        object memIA: TMemo
          Left = 0
          Top = 0
          Width = 1076
          Height = 136
          Align = alClient
          BorderStyle = bsNone
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
    object pnlActions: TPanel
      Left = 8
      Top = 170
      Width = 1084
      Height = 36
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object btnImportar: TBitBtn
        Left = 0
        Top = 2
        Width = 110
        Height = 32
        Hint = 'Importar um arquivo XML fiscal (NFe ou CTe)'
        Caption = 'Importar XML'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = btnImportarClick
      end
      object btnImportarVarios: TBitBtn
        Left = 116
        Top = 2
        Width = 110
        Height = 32
        Hint = 'Importar varios arquivos XML de uma vez'
        Caption = 'Importar Varios'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnImportarVariosClick
      end
      object btnExcluir: TBitBtn
        Left = 232
        Top = 2
        Width = 80
        Height = 32
        Hint = 'Excluir o documento selecionado'
        Caption = 'Excluir'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnClick = btnExcluirClick
      end
      object btnAtualizar: TBitBtn
        Left = 318
        Top = 2
        Width = 80
        Height = 32
        Hint = 'Atualizar a lista de documentos'
        Caption = 'Atualizar'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnClick = btnAtualizarClick
      end
      object btnValidar: TButton
        Left = 440
        Top = 2
        Width = 110
        Height = 32
        Hint = 'Validar CNPJ, NCM, CFOP e chave fiscal do documento selecionado'
        Caption = 'Validar'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnClick = btnValidarClick
      end
      object btnCalcular: TButton
        Left = 556
        Top = 2
        Width = 120
        Height = 32
        Hint = 'Calcular ICMS (18%) para cada item do documento'
        Caption = 'Calcular ICMS'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        OnClick = btnCalcularClick
      end
      object btnAnalisarIA: TButton
        Left = 682
        Top = 2
        Width = 140
        Height = 32
        Hint = 'Enviar documento para analise fiscal com DeepSeek IA'
        Caption = 'Analisar com IA'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        OnClick = btnAnalisarIAClick
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
    TabOrder = 4
    object lblStatusMsg: TLabel
      Left = 8
      Top = 3
      Width = 400
      Height = 15
      Caption = 'Pronto'
    end
  end
end
