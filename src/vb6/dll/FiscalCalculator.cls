VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "FiscalCalculator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Description = "Calculadora Fiscal - ICMS, ICMS-ST, IPI, PIS, COFINS"

Option Explicit

' Enumeracoes
Public Enum TaxType
    ttICMS = 1
    ttICMSST = 2
    ttIPI = 3
    ttPIS = 4
    ttCOFINS = 5
    ttDIFAL = 6
End Enum

Public Enum TaxRegime
    trSimplesNacional = 1
    trLucroPresumido = 2
    trLucroReal = 3
End Enum

Public Enum OrigemMercadoria
    omNacional = 0
    omEstrangeiraImportacaoDireta = 1
    omEstrangeiraMercadoInterno = 2
    omNacionalConteudoImportacaoSuperior40 = 3
    omNacionalConformidadeBasica = 4
    omNacionalConteudoImportacaoInferior40 = 5
    omEstrangeiraImportacaoDiretaSemSimilar = 6
    omEstrangeiraMercadoInternoSemSimilar = 7
    omNacionalConteudoImportacaoSuperior70 = 8
End Enum

' Estrutura de retorno do calculo
Public Type TaxResult
    TaxType As TaxType
    BaseCalculo As Double
    Aliquota As Double
    ValorImposto As Double
    ValorBaseReduzida As Double
    PercentualReducao As Double
    CST As String
    CFOP As String
    Sucesso As Boolean
    MensagemErro As String
End Type

' Calcula ICMS
Public Function CalcularICMS(ByVal ValorProduto As Double, _
                              ByVal AliquotaICMS As Double, _
                              ByVal PercentualReducao As Double, _
                              ByVal Frete As Double, _
                              ByVal Seguro As Double, _
                              ByVal OutrasDespesas As Double, _
                              ByVal Desconto As Double, _
                              ByVal Origem As OrigemMercadoria, _
                              ByVal Regime As TaxRegime, _
                              ByRef Resultado As TaxResult) As Boolean
    
    On Error GoTo ErroHandler
    
    If ValorProduto <= 0 Then
        Resultado.MensagemErro = "Valor do produto deve ser maior que zero"
        GoTo ErroHandler
    End If
    
    If AliquotaICMS <= 0 Then
        Resultado.MensagemErro = "Aliquota de ICMS deve ser maior que zero"
        GoTo ErroHandler
    End If
    
    ' Base de calculo = valor produto + frete + seguro + despesas - desconto
    Dim BaseNormal As Double
    BaseNormal = ValorProduto + Frete + Seguro + OutrasDespesas - Desconto
    
    ' Aplica reducao de base de calculo se houver
    Dim BaseCalculo As Double
    If PercentualReducao > 0 Then
        BaseCalculo = BaseNormal * (1 - (PercentualReducao / 100))
        Resultado.PercentualReducao = PercentualReducao
        Resultado.ValorBaseReduzida = BaseCalculo
    Else
        BaseCalculo = BaseNormal
        Resultado.PercentualReducao = 0
        Resultado.ValorBaseReduzida = 0
    End If
    
    Dim ValorICMS As Double
    ValorICMS = BaseCalculo * (AliquotaICMS / 100)
    ValorICMS = Round(ValorICMS, 2)
    
    ' Preenche resultado
    Resultado.TaxType = ttICMS
    Resultado.BaseCalculo = Round(BaseCalculo, 2)
    Resultado.Aliquota = AliquotaICMS
    Resultado.ValorImposto = ValorICMS
    Resultado.CST = "00"
    Resultado.CFOP = "5101"
    Resultado.Sucesso = True
    Resultado.MensagemErro = ""
    
    CalcularICMS = True
    Exit Function
    
ErroHandler:
    Resultado.Sucesso = False
    If Len(Resultado.MensagemErro) = 0 Then
        Resultado.MensagemErro = "Erro ao calcular ICMS: " & Err.Description
    End If
    CalcularICMS = False
End Function

' Calcula ICMS-ST (Substituicao Tributaria)
Public Function CalcularICMSST(ByVal ValorProduto As Double, _
                                ByVal AliquotaICMSInterna As Double, _
                                ByVal AliquotaICMSInterestadual As Double, _
                                ByVal MVA As Double, _
                                ByVal Frete As Double, _
                                ByVal Seguro As Double, _
                                ByVal OutrasDespesas As Double, _
                                ByVal Desconto As Double, _
                                ByRef Resultado As TaxResult) As Boolean
    
    On Error GoTo ErroHandler
    
    If ValorProduto <= 0 Then
        Resultado.MensagemErro = "Valor do produto deve ser maior que zero"
        GoTo ErroHandler
    End If
    
    Dim BaseNormal As Double
    BaseNormal = ValorProduto + Frete + Seguro + OutrasDespesas - Desconto
    
    ' ICMS proprio (interestadual)
    Dim ICMSProprio As Double
    ICMSProprio = BaseNormal * (AliquotaICMSInterestadual / 100)
    
    ' Base ST = base normal * (1 + MVA/100)
    Dim BaseST As Double
    BaseST = BaseNormal * (1 + (MVA / 100))
    
    ' ICMS ST = (BaseST * aliquota interna) - ICMS proprio
    Dim ICMSST As Double
    ICMSST = (BaseST * (AliquotaICMSInterna / 100)) - ICMSProprio
    
    If ICMSST < 0 Then
        ICMSST = 0
    End If
    
    ICMSST = Round(ICMSST, 2)
    
    Resultado.TaxType = ttICMSST
    Resultado.BaseCalculo = Round(BaseST, 2)
    Resultado.Aliquota = AliquotaICMSInterna
    Resultado.ValorImposto = ICMSST
    Resultado.CST = "60"
    Resultado.CFOP = "5405"
    Resultado.Sucesso = True
    Resultado.MensagemErro = ""
    
    CalcularICMSST = True
    Exit Function
    
ErroHandler:
    Resultado.Sucesso = False
    If Len(Resultado.MensagemErro) = 0 Then
        Resultado.MensagemErro = "Erro ao calcular ICMS-ST: " & Err.Description
    End If
    CalcularICMSST = False
End Function

' Calcula IPI
Public Function CalcularIPI(ByVal ValorProduto As Double, _
                             ByVal AliquotaIPI As Double, _
                             ByVal Frete As Double, _
                             ByVal Seguro As Double, _
                             ByVal OutrasDespesas As Double, _
                             ByRef Resultado As TaxResult) As Boolean
    
    On Error GoTo ErroHandler
    
    If ValorProduto <= 0 Then
        Resultado.MensagemErro = "Valor do produto deve ser maior que zero"
        GoTo ErroHandler
    End If
    
    If AliquotaIPI <= 0 Then
        Resultado.MensagemErro = "Aliquota de IPI deve ser maior que zero"
        GoTo ErroHandler
    End If
    
    Dim BaseIPI As Double
    BaseIPI = ValorProduto + Frete + Seguro + OutrasDespesas
    
    Dim ValorIPI As Double
    ValorIPI = BaseIPI * (AliquotaIPI / 100)
    ValorIPI = Round(ValorIPI, 2)
    
    Resultado.TaxType = ttIPI
    Resultado.BaseCalculo = Round(BaseIPI, 2)
    Resultado.Aliquota = AliquotaIPI
    Resultado.ValorImposto = ValorIPI
    Resultado.CST = "50"
    Resultado.CFOP = "5101"
    Resultado.Sucesso = True
    Resultado.MensagemErro = ""
    
    CalcularIPI = True
    Exit Function
    
ErroHandler:
    Resultado.Sucesso = False
    If Len(Resultado.MensagemErro) = 0 Then
        Resultado.MensagemErro = "Erro ao calcular IPI: " & Err.Description
    End If
    CalcularIPI = False
End Function

' Calcula PIS
Public Function CalcularPIS(ByVal ValorProduto As Double, _
                             ByVal AliquotaPIS As Double, _
                             ByVal Regime As TaxRegime, _
                             ByRef Resultado As TaxResult) As Boolean
    
    On Error GoTo ErroHandler
    
    If ValorProduto <= 0 Then
        Resultado.MensagemErro = "Valor do produto deve ser maior que zero"
        GoTo ErroHandler
    End If
    
    Dim ValorPIS As Double
    ValorPIS = ValorProduto * (AliquotaPIS / 100)
    ValorPIS = Round(ValorPIS, 2)
    
    Resultado.TaxType = ttPIS
    Resultado.BaseCalculo = Round(ValorProduto, 2)
    Resultado.Aliquota = AliquotaPIS
    Resultado.ValorImposto = ValorPIS
    
    Select Case Regime
        Case trLucroReal
            Resultado.CST = "01"
        Case trLucroPresumido
            Resultado.CST = "04"
        Case trSimplesNacional
            Resultado.CST = "49"
    End Select
    
    Resultado.CFOP = "5101"
    Resultado.Sucesso = True
    Resultado.MensagemErro = ""
    
    CalcularPIS = True
    Exit Function
    
ErroHandler:
    Resultado.Sucesso = False
    If Len(Resultado.MensagemErro) = 0 Then
        Resultado.MensagemErro = "Erro ao calcular PIS: " & Err.Description
    End If
    CalcularPIS = False
End Function

' Calcula COFINS
Public Function CalcularCOFINS(ByVal ValorProduto As Double, _
                                ByVal AliquotaCOFINS As Double, _
                                ByVal Regime As TaxRegime, _
                                ByRef Resultado As TaxResult) As Boolean
    
    On Error GoTo ErroHandler
    
    If ValorProduto <= 0 Then
        Resultado.MensagemErro = "Valor do produto deve ser maior que zero"
        GoTo ErroHandler
    End If
    
    Dim ValorCOFINS As Double
    ValorCOFINS = ValorProduto * (AliquotaCOFINS / 100)
    ValorCOFINS = Round(ValorCOFINS, 2)
    
    Resultado.TaxType = ttCOFINS
    Resultado.BaseCalculo = Round(ValorProduto, 2)
    Resultado.Aliquota = AliquotaCOFINS
    Resultado.ValorImposto = ValorCOFINS
    
    Select Case Regime
        Case trLucroReal
            Resultado.CST = "01"
        Case trLucroPresumido
            Resultado.CST = "04"
        Case trSimplesNacional
            Resultado.CST = "49"
    End Select
    
    Resultado.CFOP = "5101"
    Resultado.Sucesso = True
    Resultado.MensagemErro = ""
    
    CalcularCOFINS = True
    Exit Function
    
ErroHandler:
    Resultado.Sucesso = False
    If Len(Resultado.MensagemErro) = 0 Then
        Resultado.MensagemErro = "Erro ao calcular COFINS: " & Err.Description
    End If
    CalcularCOFINS = False
End Function

' Calcula DIFAL (Diferencial de Aliquota)
Public Function CalcularDIFAL(ByVal ValorProduto As Double, _
                               ByVal AliquotaInternaDestino As Double, _
                               ByVal AliquotaInterestadual As Double, _
                               ByVal PercentualPartilhaDestino As Double, _
                               ByVal Frete As Double, _
                               ByVal Seguro As Double, _
                               ByVal OutrasDespesas As Double, _
                               ByRef Resultado As TaxResult) As Boolean
    
    On Error GoTo ErroHandler
    
    If ValorProduto <= 0 Then
        Resultado.MensagemErro = "Valor do produto deve ser maior que zero"
        GoTo ErroHandler
    End If
    
    Dim BaseCalculo As Double
    BaseCalculo = ValorProduto + Frete + Seguro + OutrasDespesas
    
    ' ICMS interestadual
    Dim ICMSInterestadual As Double
    ICMSInterestadual = BaseCalculo * (AliquotaInterestadual / 100)
    
    ' ICMS total devido ao destino
    Dim ICMSTotal As Double
    ICMSTotal = BaseCalculo * (AliquotaInternaDestino / 100)
    
    ' Diferencial = ICMS destino - ICMS interestadual
    Dim Diferencial As Double
    Diferencial = ICMSTotal - ICMSInterestadual
    
    If Diferencial < 0 Then
        Diferencial = 0
    End If
    
    ' Partilha: parcela do destino
    Dim ParcelaDestino As Double
    ParcelaDestino = Diferencial * (PercentualPartilhaDestino / 100)
    ParcelaDestino = Round(ParcelaDestino, 2)
    
    Resultado.TaxType = ttDIFAL
    Resultado.BaseCalculo = Round(BaseCalculo, 2)
    Resultado.Aliquota = AliquotaInternaDestino - AliquotaInterestadual
    Resultado.ValorImposto = ParcelaDestino
    Resultado.CST = "90"
    Resultado.CFOP = "6102"
    Resultado.Sucesso = True
    Resultado.MensagemErro = ""
    
    CalcularDIFAL = True
    Exit Function
    
ErroHandler:
    Resultado.Sucesso = False
    If Len(Resultado.MensagemErro) = 0 Then
        Resultado.MensagemErro = "Erro ao calcular DIFAL: " & Err.Description
    End If
    CalcularDIFAL = False
End Function

' Calcula carga tributaria total de um item
Public Function CalcularCargaTotal(ByVal ValorProduto As Double, _
                                    ByVal AliquotaICMS As Double, _
                                    ByVal AliquotaIPI As Double, _
                                    ByVal AliquotaPIS As Double, _
                                    ByVal AliquotaCOFINS As Double, _
                                    ByVal Regime As TaxRegime, _
                                    ByVal Frete As Double, _
                                    ByVal Seguro As Double, _
                                    ByVal OutrasDespesas As Double, _
                                    ByVal Desconto As Double) As Double
    
    On Error GoTo ErroHandler
    
    Dim resICMS As TaxResult
    Dim resIPI As TaxResult
    Dim resPIS As TaxResult
    Dim resCOFINS As TaxResult
    
    CalcularICMS ValorProduto, AliquotaICMS, 0, Frete, Seguro, _
                 OutrasDespesas, Desconto, omNacional, Regime, resICMS
    
    CalcularIPI ValorProduto + Frete + Seguro + OutrasDespesas, _
                AliquotaIPI, Frete, Seguro, OutrasDespesas, resIPI
    
    CalcularPIS ValorProduto, AliquotaPIS, Regime, resPIS
    CalcularCOFINS ValorProduto, AliquotaCOFINS, Regime, resCOFINS
    
    Dim CargaTotal As Double
    CargaTotal = resICMS.ValorImposto + resIPI.ValorImposto + _
                 resPIS.ValorImposto + resCOFINS.ValorImposto
    
    CalcularCargaTotal = Round(CargaTotal, 2)
    Exit Function
    
ErroHandler:
    CalcularCargaTotal = -1
End Function
