unit VFI.Domain.Enums;

interface

uses
  System.SysUtils;

type
  TTipoDocumento = (tdNFe, tdCTe, tdMDFe);

  TTipoImposto = (tiICMS = 1, tiICMSST = 2, tiIPI = 3, tiPIS = 4, tiCOFINS = 5, tiDIFAL = 6);

  TRegimeTributario = (rtSimplesNacional = 1, rtLucroPresumido = 2, rtLucroReal = 3);

  TOrigemMercadoria = (
    omNacional = 0,
    omEstrangeiraImportacaoDireta = 1,
    omEstrangeiraMercadoInterno = 2,
    omNacionalConteudoImportacaoSuperior40 = 3,
    omNacionalConformidadeBasica = 4,
    omNacionalConteudoImportacaoInferior40 = 5,
    omEstrangeiraImportacaoDiretaSemSimilar = 6,
    omEstrangeiraMercadoInternoSemSimilar = 7,
    omNacionalConteudoImportacaoSuperior70 = 8
  );

  TStatusDocumento = (stPendente, stValidado, stRejeitado, stErro);

  TEngineCalculo = (ecVB6, ecInternal);

function TipoDocumentoToStr(const ATipo: TTipoDocumento): string;
function StrToTipoDocumento(const AStr: string): TTipoDocumento;
function StatusToStr(const AStatus: TStatusDocumento): string;
function ImpostoToStr(const AImposto: TTipoImposto): string;
function StrToImposto(const AStr: string): TTipoImposto;

implementation

function TipoDocumentoToStr(const ATipo: TTipoDocumento): string;
begin
  case ATipo of
    tdNFe:  Result := 'NFe';
    tdCTe:  Result := 'CTe';
    tdMDFe: Result := 'MDFe';
  end;
end;

function StrToTipoDocumento(const AStr: string): TTipoDocumento;
var
  Upper: string;
begin
  Upper := UpperCase(Trim(AStr));
  if Upper = 'CTE' then
    Result := tdCTe
  else if Upper = 'MDFE' then
    Result := tdMDFe
  else
    Result := tdNFe;
end;

function StatusToStr(const AStatus: TStatusDocumento): string;
begin
  case AStatus of
    stPendente:  Result := 'PENDENTE';
    stValidado:  Result := 'VALIDADO';
    stRejeitado: Result := 'REJEITADO';
    stErro:      Result := 'ERRO';
  end;
end;

function ImpostoToStr(const AImposto: TTipoImposto): string;
begin
  case AImposto of
    tiICMS:   Result := 'ICMS';
    tiICMSST: Result := 'ICMS-ST';
    tiIPI:    Result := 'IPI';
    tiPIS:    Result := 'PIS';
    tiCOFINS: Result := 'COFINS';
    tiDIFAL:  Result := 'DIFAL';
  end;
end;

function StrToImposto(const AStr: string): TTipoImposto;
var
  S: string;
begin
  S := UpperCase(Trim(AStr));
  if S = 'ICMS' then Result := tiICMS
  else if S = 'ICMS-ST' then Result := tiICMSST
  else if S = 'IPI' then Result := tiIPI
  else if S = 'PIS' then Result := tiPIS
  else if S = 'COFINS' then Result := tiCOFINS
  else if S = 'DIFAL' then Result := tiDIFAL
  else Result := tiICMS;
end;

end.
