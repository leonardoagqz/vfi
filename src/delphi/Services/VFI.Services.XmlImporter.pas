unit VFI.Services.XmlImporter;

interface

uses
  System.SysUtils, System.Classes, Xml.XMLDoc, Xml.XMLIntf, Xml.xmldom,
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
var
  S: string;
begin
  S := SafeXmlStr(ANode, AChild);
  Result := StrToFloatDef(S, 0);
end;

function SafeXmlCurr(const ANode: IXmlNode; const AChild: string): Currency;
var
  S: string;
begin
  S := SafeXmlStr(ANode, AChild);
  Result := StrToCurrDef(S, 0);
end;

function TXmlImporter.Importar(const AArquivo: string): TFiscalDocument;
var
  XML: IXmlDocument;
  Root, InfNode, Emit, Dest, DetNode: IXmlNode;
  DetNodes: IXmlNodeList;
  ProdNode, IcmsNode: IXmlNode;
  Item: TDocumentItem;
  i: Integer;
  Key, Tipo: string;
  IdeNode, TotalNode: IXmlNode;
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
    Result.DataEmissao := StrToDateDef(SafeXmlStr(IdeNode, 'dhEmi'), Now);
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
    TotalNode := InfNode.ChildNodes.FindNode('vPrest', '');
    if TotalNode <> nil then
      Result.ValorTotal := SafeXmlCurr(TotalNode, 'vTPrest');
    Result.XmlContent := XML.XML.Text;
    Exit;
  end;

  TotalNode := InfNode.ChildNodes.FindNode('total', '');
  if TotalNode <> nil then
  begin
    TotalNode := TotalNode.ChildNodes.FindNode('ICMSTot', '');
    if TotalNode <> nil then
      Result.ValorTotal := SafeXmlCurr(TotalNode, 'vNF');
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

    IcmsNode := DetNode.ChildNodes.FindNode('imposto', '');
    if IcmsNode <> nil then
    begin
      IcmsNode := IcmsNode.ChildNodes.FindNode('ICMS', '');
      if IcmsNode <> nil then
      begin
        if IcmsNode.ChildNodes.Count > 0 then
          Item.CST := SafeXmlStr(IcmsNode.ChildNodes[0], 'CST');
      end;
    end;

    Result.Itens.Add(Item);
  end;

  Result.XmlContent := XML.XML.Text;
end;

end.
