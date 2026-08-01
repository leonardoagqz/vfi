object DataModuleVFI: TDataModuleVFI
  OldCreateOrder = False
  Height = 480
  Width = 640
  object Connection: TADOConnection
    LoginPrompt = False
    Left = 48
    Top = 24
  end
  object qryDocumentos: TADOQuery
    Connection = Connection
    Left = 48
    Top = 96
  end
  object qryItens: TADOQuery
    Connection = Connection
    Left = 48
    Top = 168
  end
  object qryImpostos: TADOQuery
    Connection = Connection
    Left = 48
    Top = 240
  end
  object dsDocumentos: TDataSource
    DataSet = qryDocumentos
    Left = 160
    Top = 96
  end
  object dsItens: TDataSource
    DataSet = qryItens
    Left = 160
    Top = 168
  end
  object dsImpostos: TDataSource
    DataSet = qryImpostos
    Left = 160
    Top = 240
  end
end
