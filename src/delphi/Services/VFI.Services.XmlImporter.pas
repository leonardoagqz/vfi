unit VFI.Services.XmlImporter;

interface

uses
  System.SysUtils, Xml.XMLDoc, Xml.XMLIntf,
  VFI.Domain.Entities, VFI.Domain.Enums;

type
  TXmlImporter = class
  public
    function Importar(const AArquivo: string): TFiscalDocument;
  end;

implementation

function SafeXmlStr(const ANode: IXmlNode; const AChild: string): string;
var
  Child: IXmlNode;
begin
  Result := '';
  if ANode = nil then Exit;
  Child := ANode.ChildNodes.FindNode(AChild, '');
  if Child <> nil then
    Result := Child.Text;
end;

function SafeXmlFloat(const ANode: IXmlNode; const AChild: string): Double;
begin
  Result := StrToFloatDef(SafeXmlStr(ANode, AChild), 0);
end;

function SafeXmlCurr(const ANode: IXmlNode; const AChild: string): Currency;
begin
  Result := StrToCurrDef(SafeXmlStr(ANode, AChild), 0);
end;

procedure ExtrairICMS(const AImpNode: IXmlNode; const ADoc: TFiscalDocument; const AItemId: Integer);
var
  IcmsNode, DetNode: IXmlNode;
  Calc: TTaxCalculation;
begin
  IcmsNode := AImpNode.ChildNodes.FindNode('ICMS', '');
  if IcmsNode = nil then Exit;
  if IcmsNode.ChildNodes.Count = 0 then Exit;
  DetNode := IcmsNode.ChildNodes[0];

  Calc := TTaxCalculation.Create;
  Calc.DocumentId := ADoc.Id;
  Calc.ItemId := AItemId;
  Calc.TipoImposto := tiICMS;
  Calc.BaseCalculo := SafeXmlCurr(DetNode, 'vBC');
  Calc.Aliquota := SafeXmlFloat(DetNode, 'pICMS');
  Calc.ValorImposto := SafeXmlCurr(DetNode, 'vICMS');
  Calc.CST := SafeXmlStr(DetNode, 'CST');
  Calc.CFOP := '';
  Calc.Engine := ecInternal;
  ADoc.Calculos.Add(Calc);
end;

procedure ExtrairIPI(const AImpNode: IXmlNode; const ADoc: TFiscalDocument; const AItemId: Integer);
var
  IpiNode, DetNode: IXmlNode;
  Calc: TTaxCalculation;
begin
  IpiNode := AImpNode.ChildNodes.FindNode('IPI', '');
  if IpiNode = nil then Exit;
  DetNode := IpiNode.ChildNodes.FindNode('IPITrib', '');
  if DetNode = nil then Exit;

  Calc := TTaxCalculation.Create;
  Calc.DocumentId := ADoc.Id;
  Calc.ItemId := AItemId;
  Calc.TipoImposto := tiIPI;
  Calc.BaseCalculo := SafeXmlCurr(DetNode, 'vBC');
  Calc.Aliquota := SafeXmlFloat(DetNode, 'pIPI');
  Calc.ValorImposto := SafeXmlCurr(DetNode, 'vIPI');
  Calc.CST := SafeXmlStr(DetNode, 'CST');
  Calc.Engine := ecInternal;
  ADoc.Calculos.Add(Calc);
end;

procedure ExtrairPIS(const AImpNode: IXmlNode; const ADoc: TFiscalDocument; const AItemId: Integer);
var
  PisNode, DetNode: IXmlNode;
  Calc: TTaxCalculation;
begin
  PisNode := AImpNode.ChildNodes.FindNode('PIS', '');
  if PisNode = nil then Exit;
  if PisNode.ChildNodes.Count = 0 then Exit;
  DetNode := PisNode.ChildNodes[0];

  Calc := TTaxCalculation.Create;
  Calc.DocumentId := ADoc.Id;
  Calc.ItemId := AItemId;
  Calc.TipoImposto := tiPIS;
  Calc.BaseCalculo := SafeXmlCurr(DetNode, 'vBC');
  Calc.Aliquota := SafeXmlFloat(DetNode, 'pPIS');
  Calc.ValorImposto := SafeXmlCurr(DetNode, 'vPIS');
  Calc.CST := SafeXmlStr(DetNode, 'CST');
  Calc.Engine := ecInternal;
  ADoc.Calculos.Add(Calc);
end;

procedure ExtrairCOFINS(const AImpNode: IXmlNode; const ADoc: TFiscalDocument; const AItemId: Integer);
var
  CofNode, DetNode: IXmlNode;
  Calc: TTaxCalculation;
begin
  CofNode := AImpNode.ChildNodes.FindNode('COFINS', '');
  if CofNode = nil then Exit;
  if CofNode.ChildNodes.Count = 0 then Exit;
  DetNode := CofNode.ChildNodes[0];

  Calc := TTaxCalculation.Create;
  Calc.DocumentId := ADoc.Id;
  Calc.ItemId := AItemId;
  Calc.TipoImposto := tiCOFINS;
  Calc.BaseCalculo := SafeXmlCurr(DetNode, 'vBC');
  Calc.Aliquota := SafeXmlFloat(DetNode, 'pCOFINS');
  Calc.ValorImposto := SafeXmlCurr(DetNode, 'vCOFINS');
  Calc.CST := SafeXmlStr(DetNode, 'CST');
  Calc.Engine := ecInternal;
  ADoc.Calculos.Add(Calc);
end;

procedure ExtrairImpostos(const ADetNode: IXmlNode; const ADoc: TFiscalDocument; const AItemId: Integer);
var
  ImpNode: IXmlNode;
begin
  ImpNode := ADetNode.ChildNodes.FindNode('imposto', '');
  if ImpNode = nil then Exit;
  ExtrairICMS(ImpNode, ADoc, AItemId);
  ExtrairIPI(ImpNode, ADoc, AItemId);
  ExtrairPIS(ImpNode, ADoc, AItemId);
  ExtrairCOFINS(ImpNode, ADoc, AItemId);
end;

function TXmlImporter.Importar(const AArquivo: string): TFiscalDocument;
var
  XML: IXmlDocument;
  Root, InfNode, Emit, Dest, ProdNode, DetNode: IXmlNode;
  DetNodes: IXmlNodeList;
  Item: TDocumentItem;
  i: Integer;
  Key, Tipo: string;
  IdeNode: IXmlNode;
begin
  Result := nil;
  if not FileExists(AArquivo) then Exit;

  XML := LoadXmlDocument(AArquivo);
  XML.Active := True;
  Root := XML.DocumentElement;
  if Root = nil then Exit;

  if Root.NodeName = 'nfeProc' then
  begin
    InfNode := Root.ChildNodes.FindNode('NFe', '');
    if InfNode = nil then Exit;
    InfNode := InfNode.ChildNodes.FindNode('infNFe', '');
    Key := InfNode.Attributes['Id'];
    Tipo := 'NFe';
  end
  else if Root.NodeName = 'cteProc' then
  begin
    InfNode := Root.ChildNodes.FindNode('CTe', '');
    if InfNode = nil then Exit;
    InfNode := InfNode.ChildNodes.FindNode('infCte', '');
    Key := InfNode.Attributes['Id'];
    Tipo := 'CTe';
  end
  else
    Exit;

  Emit := InfNode.ChildNodes.FindNode('emit', '');
  Dest := InfNode.ChildNodes.FindNode('dest', '');

  Result := TFiscalDocument.Create;
  Result.Tipo := StrToTipoDocumento(Tipo);
  Result.Chave := Copy(Key, 4, 44);

  IdeNode := InfNode.ChildNodes.FindNode('ide', '');
  if IdeNode <> nil then
  begin
    Result.Numero := SafeXmlStr(IdeNode, 'nCT');
    if Result.Numero = '' then
      Result.Numero := SafeXmlStr(IdeNode, 'nNF');
    Result.DataEmissao := Now;
  end;

  if Emit <> nil then
  begin
    Result.CnpjEmitente := SafeXmlStr(Emit, 'CNPJ');
    Result.NomeEmitente := SafeXmlStr(Emit, 'xNome');
  end;

  if Dest <> nil then
  begin
    Result.CnpjDestinatario := SafeXmlStr(Dest, 'CNPJ');
    Result.NomeDestinatario := SafeXmlStr(Dest, 'xNome');
  end;

  if Tipo = 'CTe' then
  begin
    DetNode := InfNode.ChildNodes.FindNode('vPrest', '');
    if DetNode <> nil then
      Result.ValorTotal := SafeXmlCurr(DetNode, 'vTPrest');

    DetNodes := InfNode.ChildNodes;
    for i := 0 to DetNodes.Count - 1 do
    begin
      DetNode := DetNodes[i];
      if DetNode.NodeName <> 'imp' then Continue;
      ExtrairICMS(DetNode, Result, 0);
    end;
  end
  else
  begin
    DetNode := InfNode.ChildNodes.FindNode('total', '');
    if DetNode <> nil then
    begin
      DetNode := DetNode.ChildNodes.FindNode('ICMSTot', '');
      if DetNode <> nil then
        Result.ValorTotal := SafeXmlCurr(DetNode, 'vNF');
    end;

    DetNodes := InfNode.ChildNodes;
    for i := 0 to DetNodes.Count - 1 do
    begin
      DetNode := DetNodes[i];
      if DetNode.NodeName <> 'det' then Continue;

      ProdNode := DetNode.ChildNodes.FindNode('prod', '');
      if ProdNode = nil then Continue;

      Item := TDocumentItem.Create;
      Item.CodigoProduto := SafeXmlStr(ProdNode, 'cProd');
      Item.NomeProduto := SafeXmlStr(ProdNode, 'xProd');
      Item.NCM := SafeXmlStr(ProdNode, 'NCM');
      Item.CFOP := SafeXmlStr(ProdNode, 'CFOP');
      Item.Quantidade := SafeXmlFloat(ProdNode, 'qCom');
      Item.ValorUnitario := SafeXmlCurr(ProdNode, 'vUnCom');
      Item.ValorTotal := SafeXmlCurr(ProdNode, 'vProd');
      Result.Itens.Add(Item);

      ExtrairImpostos(DetNode, Result, Result.Itens.Count - 1);
    end;
  end;

  Result.XmlContent := XML.XML.Text;
end;

end.
