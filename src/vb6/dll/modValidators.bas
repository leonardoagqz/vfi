Attribute VB_Name = "modValidators"

Option Explicit

' Valida CNPJ
Public Function ValidarCNPJ(ByVal CNPJ As String) As Boolean
    Dim i As Integer
    Dim j As Integer
    Dim digito1 As Integer
    Dim digito2 As Integer
    Dim soma As Integer
    Dim peso As Integer
    Dim numeros(13) As Integer
    Dim cnpjLimpo As String
    
    cnpjLimpo = ""
    For i = 1 To Len(CNPJ)
        If IsNumeric(Mid(CNPJ, i, 1)) Then
            cnpjLimpo = cnpjLimpo & Mid(CNPJ, i, 1)
        End If
    Next i
    
    If Len(cnpjLimpo) <> 14 Then
        ValidarCNPJ = False
        Exit Function
    End If
    
    ' Preenche array
    For i = 1 To 14
        numeros(i) = CInt(Mid(cnpjLimpo, i, 1))
    Next i
    
    ' Primeiro digito verificador
    soma = 0
    peso = 5
    For i = 1 To 12
        soma = soma + (numeros(i) * peso)
        peso = peso - 1
        If peso < 2 Then peso = 9
    Next i
    
    digito1 = soma Mod 11
    If digito1 < 2 Then digito1 = 0 Else digito1 = 11 - digito1
    
    ' Segundo digito verificador
    soma = 0
    peso = 6
    For i = 1 To 13
        soma = soma + (numeros(i) * peso)
        peso = peso - 1
        If peso < 2 Then peso = 9
    Next i
    
    digito2 = soma Mod 11
    If digito2 < 2 Then digito2 = 0 Else digito2 = 11 - digito2
    
    ValidarCNPJ = (digito1 = numeros(13) And digito2 = numeros(14))
End Function

' Valida chave de NF-e (44 digitos)
Public Function ValidarChaveNFe(ByVal Chave As String) As Boolean
    Dim chaveLimpa As String
    Dim i As Integer
    
    chaveLimpa = ""
    For i = 1 To Len(Chave)
        If IsNumeric(Mid(Chave, i, 1)) Then
            chaveLimpa = chaveLimpa & Mid(Chave, i, 1)
        End If
    Next i
    
    If Len(chaveLimpa) <> 44 Then
        ValidarChaveNFe = False
        Exit Function
    End If
    
    ' Valida digito verificador da chave (DV)
    Dim soma As Integer
    Dim peso As Integer
    Dim digito As Integer
    
    soma = 0
    peso = 2
    For i = 43 To 1 Step -1
        soma = soma + (CInt(Mid(chaveLimpa, i, 1)) * peso)
        peso = peso + 1
        If peso > 9 Then peso = 2
    Next i
    
    digito = 11 - (soma Mod 11)
    If digito >= 10 Then digito = 0
    
    ValidarChaveNFe = (digito = CInt(Mid(chaveLimpa, 44, 1)))
End Function

' Valida CFOP (4 digitos)
Public Function ValidarCFOP(ByVal CFOP As String) As Boolean
    Dim cfopLimpo As String
    Dim cfopInt As Integer
    
    cfopLimpo = Trim(CFOP)
    If Len(cfopLimpo) <> 4 Then
        ValidarCFOP = False
        Exit Function
    End If
    
    If Not IsNumeric(cfopLimpo) Then
        ValidarCFOP = False
        Exit Function
    End If
    
    cfopInt = CInt(cfopLimpo)
    
    ' Valida faixas validas de CFOP
    ValidarCFOP = (cfopInt >= 1000 And cfopInt <= 7999)
End Function

' Valida NCM (8 digitos)
Public Function ValidarNCM(ByVal NCM As String) As Boolean
    Dim ncmLimpo As String
    
    ncmLimpo = Trim(NCM)
    If Len(ncmLimpo) <> 8 Then
        ValidarNCM = False
        Exit Function
    End If
    
    ValidarNCM = IsNumeric(ncmLimpo)
End Function
