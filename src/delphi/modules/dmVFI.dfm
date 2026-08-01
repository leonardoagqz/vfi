object DataModuleVFI: TDataModuleVFI
  OldCreateOrder = False
  Height = 480
  Width = 640
  object Connection: TFDConnection
    Params.Strings = (
      'Database=VFI_DB'
      'Server=localhost'
      'DriverID=MSSQL'
      'User_Name=vfi_app'
      'Password=Vfi@2024#Dev')
    LoginPrompt = False
    Left = 48
    Top = 24
  end
  object qryDocumentos: TFDQuery
    Connection = Connection
    Left = 48
    Top = 96
  end
  object qryItens: TFDQuery
    Connection = Connection
    Left = 48
    Top = 168
  end
  object qryImpostos: TFDQuery
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
  object FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink
    Left = 48
    Top = 304
  end
end
