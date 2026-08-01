object FormMain: TFormMain
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
  DesignSize = (
    1100
    700)
  
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
      Width = 400
      Height = 28
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
      Width = 500
      Height = 17
      Caption = 'Sistema de validacao fiscal com DLL VB6, API C# .NET e IA integrada'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16771797
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
    Anchors = [akLeft, akTop, akRight, akBottom]
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
          Width = 30
          Height = 15
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
        object SearchBox: TSearchBox
          Left = 160
          Top = 12
          Width = 250
          Height = 23
          TabOrder = 1
          TextHint = 'Buscar por chave, CNPJ, numero...'
        end
      end
      object dbgDocumentos: TDBGrid
        Left = 0
        Top = 48
        Width = 1076
        Height = 453
        Align = alClient
        DataSource = DataModuleVFI.dsDocumentos
        ReadOnly = True
        TabOrder = 1
        OnDblClick = dbgDocumentosDblClick
      end
    end
    object tsValidacao: TTabSheet
      Caption = 'Validacao'
      object lblLog: TLabel
        Left = 8
        Top = 8
        Width = 66
        Height = 15
        Caption = 'Log de eventos'
      end
      object memLog: TMemo
        Left = 8
        Top = 32
        Width = 1053
        Height = 497
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object tsIA: TTabSheet
      Caption = 'Analise IA'
      object lblResultadoIA: TLabel
        Left = 8
        Top = 8
        Width = 129
        Height = 15
        Caption = 'Resultado da Analise IA'
      end
      object memResultadoIA: TMemo
        Left = 8
        Top = 32
        Width = 1053
        Height = 457
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object btnAnalisar: TButton
        Left = 8
        Top = 496
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
    Top = 660
    Width = 1100
    Height = 24
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvLowered
    TabOrder = 3
    object lblStatus: TLabel
      Left = 8
      Top = 3
      Width = 200
      Height = 17
      Caption = 'Pronto'
    end
  end
  
  object Shape1: TShape
    Left = 0
    Top = 657
    Width = 1100
    Height = 3
    Anchors = [akLeft, akRight, akBottom]
    Brush.Color = clNavy
    Pen.Style = psClear
  end
end
