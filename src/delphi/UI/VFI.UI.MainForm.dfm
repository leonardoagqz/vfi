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
  object pnlTop: TPanel
    Left = 0; Top = 0; Width = 1100; Height = 48
    Align = alTop; BevelOuter = bvNone; Color = 3158064; ParentBackground = False; TabOrder = 0
    object lblTitle: TLabel
      Left = 16; Top = 4; Caption = 'VFI - Validador Fiscal Inteligente'
      Font.Color = clWhite; Font.Height = -17; Font.Name = 'Segoe UI'; Font.Style = [fsBold]; ParentFont = False
    end
    object lblSub: TLabel
      Left = 16; Top = 28; Caption = 'Importacao XML | Validacao Automatica | Analise IA | Regras Fiscais'
      Font.Color = 13619151; Font.Height = -11; Font.Name = 'Segoe UI'; Font.Style = []; ParentFont = False
    end
    object lblCount: TLabel
      Left = 960; Top = 14; Alignment = taRightJustify; Anchors = [akTop, akRight]
      Caption = '0 documento(s)'; Font.Color = 13619151; Font.Height = -13; Font.Name = 'Segoe UI'; Font.Style = [fsBold]; ParentFont = False
    end
  end
  object pnlToolbar: TPanel
    Left = 0; Top = 48; Width = 1100; Height = 36
    Align = alTop; BevelOuter = bvLowered; TabOrder = 1
    object btnImportar: TSpeedButton
      Left = 8; Top = 2; Width = 110; Height = 32; Hint = 'Importar XML fiscal [Ctrl+I]'
      Caption = 'Importar'; Flat = True; ParentShowHint = False; ShowHint = True; OnClick = btnImportarClick
    end
    object btnExcluir: TSpeedButton
      Left = 122; Top = 2; Width = 110; Height = 32; Hint = 'Excluir documento [Del]'
      Caption = 'Excluir'; Flat = True; ParentShowHint = False; ShowHint = True; OnClick = btnExcluirClick
    end
    object btnAnalisarIA: TSpeedButton
      Left = 236; Top = 2; Width = 130; Height = 32; Hint = 'Analisar com IA [Ctrl+A]'
      Caption = 'Analisar com IA'; Flat = True; ParentShowHint = False; ShowHint = True; OnClick = btnAnalisarIAClick
    end
    object btnConfigurar: TSpeedButton
      Left = 372; Top = 2; Width = 120; Height = 32; Hint = 'Configurar chave API DeepSeek'
      Caption = 'Configurar API'; Flat = True; ParentShowHint = False; ShowHint = True; OnClick = btnConfigurarClick
    end
  end
  object pnlLeft: TPanel
    Left = 0; Top = 84; Width = 680; Height = 614; Align = alLeft
    BevelOuter = bvNone; Padding.Left = 8; Padding.Top = 4; Padding.Right = 4; Padding.Bottom = 4; TabOrder = 2
    object pcBottom: TPageControl
      Left = 8; Top = 416; Width = 664; Height = 194; Align = alBottom; TabOrder = 1
      object tsLog: TTabSheet
        Caption = 'Log'
        object memLog: TMemo
          Left = 0; Top = 0; Width = 656; Height = 164; Align = alClient
          Font.Charset = DEFAULT_CHARSET; Font.Color = clWindowText; Font.Height = -11
          Font.Name = 'Consolas'; Font.Style = []; ParentFont = False
          ReadOnly = True; ScrollBars = ssBoth; TabOrder = 0
        end
      end
      object tsValidacoes: TTabSheet
        Caption = 'Validacao Automatica'
        object memValidacoes: TMemo
          Left = 0; Top = 0; Width = 656; Height = 164; Align = alClient
          Font.Charset = DEFAULT_CHARSET; Font.Color = clWindowText; Font.Height = -11
          Font.Name = 'Consolas'; Font.Style = []; ParentFont = False
          ReadOnly = True; ScrollBars = ssBoth; TabOrder = 0
        end
      end
    end
    object lvDocs: TListView
      Left = 8; Top = 4; Width = 664; Height = 412; Align = alClient
      ReadOnly = True; RowSelect = True; TabOrder = 0; ViewStyle = vsReport; OnSelectItem = lvDocsSelectItem
    end
  end
  object Splitter1: TSplitter
    Left = 680; Top = 84; Width = 4; Height = 614; Align = alLeft
  end
  object pnlRight: TPanel
    Left = 684; Top = 84; Width = 416; Height = 614; Align = alClient
    BevelOuter = bvNone; Padding.Left = 4; Padding.Top = 4; Padding.Right = 8; Padding.Bottom = 4; TabOrder = 3
    object gbDetalhes: TGroupBox
      Left = 4; Top = 4; Width = 404; Height = 115; Align = alTop; Caption = ' Detalhes '; TabOrder = 0
      object lblTipo: TLabel; Left = 12; Top = 22; Caption = 'Tipo:'; Font.Style = [fsBold]; ParentFont = False; end
      object lblTipoVal: TLabel; Left = 90; Top = 22; Font.Style = [fsBold]; ParentFont = False; end
      object lblNumero: TLabel; Left = 160; Top = 22; Caption = 'Numero:'; Font.Style = [fsBold]; ParentFont = False; end
      object lblNumeroVal: TLabel; Left = 220; Top = 22; end
      object lblValor: TLabel; Left = 280; Top = 22; Caption = 'Valor:'; Font.Style = [fsBold]; ParentFont = False; end
      object lblValorVal: TLabel; Left = 322; Top = 22; Font.Style = [fsBold]; ParentFont = False; end
      object lblStatus: TLabel; Left = 12; Top = 44; Caption = 'Status:'; Font.Style = [fsBold]; ParentFont = False; end
      object lblStatusVal: TLabel; Left = 90; Top = 44; Font.Style = [fsBold]; ParentFont = False; end
      object ShapeStatus: TShape; Left = 70; Top = 46; Width = 12; Height = 12; Brush.Color = clBtnFace; Pen.Style = psClear; Shape = stCircle; end
      object lblEmitente: TLabel; Left = 12; Top = 66; Caption = 'Emitente:'; Font.Style = [fsBold]; ParentFont = False; end
      object lblEmitenteVal: TLabel; Left = 90; Top = 66; Width = 300; end
      object lblCNPJE: TLabel; Left = 12; Top = 84; Caption = 'CNPJ Emit.:'; end
      object lblCNPJEVal: TLabel; Left = 90; Top = 84; end
      object lblDest: TLabel; Left = 12; Top = 100; Caption = 'Destinatario:'; Font.Style = [fsBold]; ParentFont = False; end
      object lblDestVal: TLabel; Left = 90; Top = 100; Width = 300; end
    end
    object pcDetalhes: TPageControl
      Left = 4; Top = 119; Width = 404; Height = 491; Align = alClient; TabOrder = 1
      object tsImpostos: TTabSheet
        Caption = 'Impostos'
        object lvImpostos: TListView
          Left = 0; Top = 0; Width = 396; Height = 461; Align = alClient; GridLines = True
          ReadOnly = True; RowSelect = True; TabOrder = 0; ViewStyle = vsReport
        end
      end
      object tsItens: TTabSheet
        Caption = 'Itens'
        object lvItens: TListView
          Left = 0; Top = 0; Width = 396; Height = 461; Align = alClient; GridLines = True
          ReadOnly = True; RowSelect = True; TabOrder = 0; ViewStyle = vsReport
        end
      end
      object tsAnaliseIA: TTabSheet
        Caption = 'Analise IA'
        object memResultadoIA: TMemo
          Left = 0; Top = 0; Width = 396; Height = 461; Align = alClient
          Font.Name = 'Consolas'; Font.Size = 10; ParentFont = False
          ReadOnly = True; ScrollBars = ssBoth; TabOrder = 0
        end
      end
      object tsRegras: TTabSheet
        Caption = 'Regras Fiscais'
        object memRegrasFiscais: TMemo
          Left = 0; Top = 0; Width = 396; Height = 461; Align = alClient
          Font.Name = 'Consolas'; Font.Size = 10; ParentFont = False
          ScrollBars = ssBoth; TabOrder = 0; OnChange = memRegrasFiscaisChange
        end
      end
    end
  end
  object PopupExcluir: TPopupMenu
    Left = 128; Top = 88
    object miExcluirSelecionado: TMenuItem; Caption = 'Excluir selecionado'; ShortCut = 46; OnClick = miExcluirSelecionadoClick; end
    object miLimparTudo: TMenuItem; Caption = 'Limpar tudo...'; OnClick = miLimparTudoClick; end
  end
  object pnlStatus: TPanel
    Left = 0; Top = 698; Width = 1100; Height = 22; Align = alBottom
    Alignment = taLeftJustify; BevelOuter = bvLowered; TabOrder = 5
    object lblStatusMsg: TLabel; Left = 8; Top = 3; Caption = 'Pronto'; end
  end
end
