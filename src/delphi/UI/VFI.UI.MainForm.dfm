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
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 24
      Top = 12
      Caption = 'VFI - Validador Fiscal Inteligente'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitle: TLabel
      Left = 24
      Top = 44
      Caption = 'Clean Architecture | Repository Pattern | SOLID | DeepSeek IA'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pcMain: TPageControl
    Left = 8
    Top = 88
    Width = 1084
    Height = 569
    ActivePage = tsDocumentos
    TabOrder = 1
    object tsDocumentos: TTabSheet
      Caption = 'Documentos Fiscais'
      object pnlHeader: TPanel
        Left = 0
        Top = 0
        Width = 1076
        Height = 48
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblFiltro: TLabel
          Left = 8
          Top = 16
          Caption = 'Filtro:'
        end
        object cbFiltroTipo: TComboBox
          Left = 48
          Top = 12
          Width = 100
          Height = 23
          Style = csDropDownList
          TabOrder = 0
        end
      end
      object StringGridDocs: TStringGrid
        Left = 0
        Top = 48
        Width = 1076
        Height = 493
        Align = alClient
        DefaultRowHeight = 22
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
        TabOrder = 1
        OnDblClick = StringGridDocsDblClick
      end
    end
    object tsValidacao: TTabSheet
      Caption = 'Log Validacao'
      object lblLog: TLabel
        Left = 8
        Top = 8
        Caption = 'Log de eventos'
      end
      object memLog: TMemo
        Left = 8
        Top = 32
        Width = 1060
        Height = 500
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object tsIA: TTabSheet
      Caption = 'Analise IA (DeepSeek)'
      object lblResultadoIA: TLabel
        Left = 8
        Top = 8
        Caption = 'Resultado da Analise IA (DeepSeek)'
      end
      object memResultadoIA: TMemo
        Left = 8
        Top = 32
        Width = 1060
        Height = 460
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object btnAnalisar: TButton
        Left = 8
        Top = 500
        Width = 120
        Height = 32
        Caption = 'Analisar com IA'
        TabOrder = 1
        OnClick = btnAnalisarIAClick
      end
    end
  end
  object pnlActions: TPanel
    Left = 0
    Top = 660
    Width = 1100
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnImportar: TButton
      Left = 8
      Top = 4
      Width = 100
      Height = 32
      Caption = 'Importar XML'
      TabOrder = 0
      OnClick = btnImportarClick
    end
    object btnValidar: TButton
      Left = 116
      Top = 4
      Width = 100
      Height = 32
      Caption = 'Validar'
      TabOrder = 1
      OnClick = btnValidarClick
    end
    object btnCalcular: TButton
      Left = 224
      Top = 4
      Width = 120
      Height = 32
      Caption = 'Calcular Impostos'
      TabOrder = 2
      OnClick = btnCalcularClick
    end
    object btnAnalisarIA: TButton
      Left = 352
      Top = 4
      Width = 100
      Height = 32
      Caption = 'Analisar IA'
      TabOrder = 3
      OnClick = btnAnalisarIAClick
    end
    object btnRefresh: TBitBtn
      Left = 976
      Top = 4
      Width = 100
      Height = 32
      Caption = 'Atualizar'
      TabOrder = 4
      OnClick = btnRefreshClick
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 700
    Width = 1100
    Height = 24
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvLowered
    TabOrder = 3
    object lblStatus: TLabel
      Left = 8
      Top = 2
      Caption = 'Pronto'
    end
  end
  object Shape1: TShape
    Left = 0
    Top = 660
    Width = 1100
    Height = 3
    Brush.Color = clNavy
    Pen.Style = psClear
  end
end
