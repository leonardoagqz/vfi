Attribute VB_Name = "TestFiscalCalculator"

Option Explicit

' Modulo de testes unitarios para FiscalCalculator
' Executar via Immediate Window ou via script de build

Public Sub TestAll()
    Debug.Print "========================================"
    Debug.Print "VFI - Testes da DLL FiscalCalculator"
    Debug.Print "========================================"
    
    TestCalcularICMS
    TestCalcularICMSST
    TestCalcularIPI
    TestCalcularPIS
    TestCalcularCOFINS
    TestCalcularDIFAL
    TestCalcularCargaTotal
    TestValidarCNPJ
    TestValidarChaveNFe
    
    Debug.Print "========================================"
    Debug.Print "Testes concluidos."
    Debug.Print "========================================"
End Sub

Public Sub AssertEqual(TestName As String, Expected As Double, Actual As Double, Optional Tolerance As Double = 0.01)
    If Abs(Expected - Actual) <= Tolerance Then
        Debug.Print "[PASS] " & TestName
    Else
        Debug.Print "[FAIL] " & TestName & " - Esperado: " & Expected & ", Obtido: " & Actual
    End If
End Sub

Public Sub AssertTrue(TestName As String, Condition As Boolean)
    If Condition Then
        Debug.Print "[PASS] " & TestName
    Else
        Debug.Print "[FAIL] " & TestName
    End If
End Sub

Public Sub TestCalcularICMS()
    Dim calc As New FiscalCalculator
    Dim res As TaxResult
    
    ' Teste basico: R$ 1000, 18% ICMS = R$ 180
    calc.CalcularICMS 1000, 18, 0, 0, 0, 0, 0, omNacional, trLucroReal, res
    AssertEqual "ICMS Basico", 180, res.ValorImposto
    AssertTrue "ICMS Basico Sucesso", res.Sucesso
    
    ' Teste com frete: R$ 1000 + R$ 100 frete, 18% = R$ 198
    calc.CalcularICMS 1000, 18, 0, 100, 0, 0, 0, omNacional, trLucroReal, res
    AssertEqual "ICMS com Frete", 198, res.ValorImposto
    
    ' Teste com reducao de base: R$ 1000, 50% reducao, 18% = R$ 90
    calc.CalcularICMS 1000, 18, 50, 0, 0, 0, 0, omNacional, trLucroReal, res
    AssertEqual "ICMS com Reducao 50%", 90, res.ValorImposto
    
    ' Teste valor zero deve falhar
    calc.CalcularICMS 0, 18, 0, 0, 0, 0, 0, omNacional, trLucroReal, res
    AssertTrue "ICMS Valor Zero Falha", Not res.Sucesso
    
    Set calc = Nothing
End Sub

Public Sub TestCalcularICMSST()
    Dim calc As New FiscalCalculator
    Dim res As TaxResult
    
    ' Cenario: produto R$ 1000, aliquota interna 18%, interestadual 12%, MVA 40%
    ' ICMS proprio = 1000 * 0.12 = 120
    ' Base ST = 1000 * 1.40 = 1400
    ' ICMS ST = 1400 * 0.18 - 120 = 252 - 120 = 132
    calc.CalcularICMSST 1000, 18, 12, 40, 0, 0, 0, 0, res
    AssertEqual "ICMS-ST Basico", 132, res.ValorImposto
    AssertTrue "ICMS-ST Sucesso", res.Sucesso
    
    Set calc = Nothing
End Sub

Public Sub TestCalcularIPI()
    Dim calc As New FiscalCalculator
    Dim res As TaxResult
    
    calc.CalcularIPI 1000, 10, 0, 0, 0, res
    AssertEqual "IPI 10%", 100, res.ValorImposto
    AssertTrue "IPI Sucesso", res.Sucesso
    
    Set calc = Nothing
End Sub

Public Sub TestCalcularPIS()
    Dim calc As New FiscalCalculator
    Dim res As TaxResult
    
    calc.CalcularPIS 1000, 1.65, trLucroReal, res
    AssertEqual "PIS 1.65% Lucro Real", 16.5, res.ValorImposto
    AssertTrue "PIS Sucesso", res.Sucesso
    AssertTrue "PIS CST Lucro Real", res.CST = "01"
    
    calc.CalcularPIS 1000, 0.65, trSimplesNacional, res
    AssertTrue "PIS CST Simples", res.CST = "49"
    
    Set calc = Nothing
End Sub

Public Sub TestCalcularCOFINS()
    Dim calc As New FiscalCalculator
    Dim res As TaxResult
    
    calc.CalcularCOFINS 1000, 7.6, trLucroReal, res
    AssertEqual "COFINS 7.6%", 76, res.ValorImposto
    AssertTrue "COFINS CST Lucro Real", res.CST = "01"
    
    Set calc = Nothing
End Sub

Public Sub TestCalcularDIFAL()
    Dim calc As New FiscalCalculator
    Dim res As TaxResult
    
    ' Cenario: R$ 1000, destino 18%, interestadual 12%, partilha destino 60%
    ' ICMS interestadual = 1000 * 0.12 = 120
    ' ICMS destino total = 1000 * 0.18 = 180
    ' Diferencial = 180 - 120 = 60
    ' Parcela destino = 60 * 0.60 = 36
    calc.CalcularDIFAL 1000, 18, 12, 60, 0, 0, 0, res
    AssertEqual "DIFAL Parcela Destino", 36, res.ValorImposto
    AssertTrue "DIFAL Sucesso", res.Sucesso
    
    Set calc = Nothing
End Sub

Public Sub TestCalcularCargaTotal()
    Dim calc As New FiscalCalculator
    Dim carga As Double
    
    ' R$ 1000, ICMS 18%, IPI 10%, PIS 1.65%, COFINS 7.6%
    ' ICMS = 180, IPI = 100, PIS = 16.5, COFINS = 76
    ' Total = 372.5
    carga = calc.CalcularCargaTotal(1000, 18, 10, 1.65, 7.6, trLucroReal, 0, 0, 0, 0)
    AssertEqual "Carga Total", 372.5, carga
    
    Set calc = Nothing
End Sub

Public Sub TestValidarCNPJ()
    ' CNPJ valido conhecido
    AssertTrue "CNPJ Valido", modValidators.ValidarCNPJ("11222333000181")
    
    ' CNPJ invalido (digito errado)
    AssertTrue "CNPJ Invalido", Not modValidators.ValidarCNPJ("11222333000182")
    
    ' CNPJ curto
    AssertTrue "CNPJ Tamanho Errado", Not modValidators.ValidarCNPJ("12345")
End Sub

Public Sub TestValidarChaveNFe()
    ' Chave de NF-e de exemplo (44 digitos, DV valido)
    AssertTrue "Chave NFe 44 digitos", modValidators.ValidarChaveNFe("35240112345678901234567890123456789012345678")
    
    ' Chave curta
    AssertTrue "Chave NFe Tamanho Errado", Not modValidators.ValidarChaveNFe("12345")
End Sub
