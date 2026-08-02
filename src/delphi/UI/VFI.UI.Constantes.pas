unit VFI.UI.Constantes;

interface

const
  COR_STATUS_PENDENTE  = $004090FF;
  COR_STATUS_VALIDADO  = $0040B840;
  COR_STATUS_REJEITADO = $004040F0;
  COR_FUNDO_VALIDO     = $00E0FFE0;
  COR_FUNDO_REJEITADO  = $00E0E0FF;
  COR_TOPO             = 3158064;
  COR_TEXTO_SECUNDARIO = 13619151;

  DIR_XML_EXEMPLOS = 'docs\xml-exemplos\';
  DIR_RESOURCES    = 'src\delphi\Resources\';

  ARQ_REGRAS_FISCAIS = 'regras_fiscais.txt';
  ARQ_CONFIG         = 'vfi.ini';

  DEEPSEEK_ENDPOINT  = 'https://api.deepseek.com/v1/chat/completions';
  DEEPSEEK_MODELO    = 'deepseek-chat';

implementation

end.
