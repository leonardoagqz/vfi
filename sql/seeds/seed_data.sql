-- VFI - Seed Data para Demonstracao

USE VFI_DB;
GO

INSERT INTO FiscalDocument (DocumentType, DocumentKey, DocumentNumber, IssueDate, IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status)
VALUES
('NFe', '35240112345678901234567890123456789012345678', '000001001', '2024-01-15', '12345678000199', 'Distribuidora ABC Ltda', '98765432000188', 'Comercio XYZ S.A.', 15000.00, '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe"><NFe><infNFe><ide><cUF>35</cUF><natOp>Venda</natOp></ide></infNFe></NFe></nfeProc>', 'PENDENTE'),
('CTe', '35240198765432109876543210987654321098765432', '000002001', '2024-02-20', '11222333000144', 'Transportadora Expressa Ltda', '99888777000155', 'Industria Delta Ltda', 8500.00, '<cteProc xmlns="http://www.portalfiscal.inf.br/cte"><CTe><infCte><ide><cUF>35</cUF></ide></infCte></CTe></cteProc>', 'PENDENTE'),
('NFe', '35240155556666777788889999000011112222333344', '000003001', '2024-03-10', '44455566000177', 'Fornecedor Beta Eireli', '33344455000166', 'Varejista Gama Ltda', 32000.00, '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe"><NFe><infNFe><ide><cUF>35</cUF></ide></infNFe></NFe></nfeProc>', 'PENDENTE');

INSERT INTO DocumentItem (DocumentId, ProductCode, ProductName, NCM, CFOP, Quantity, UnitValue, TotalValue, CST)
VALUES
(1, 'P001', 'Produto A - Industrializado', '84714900', '5101', 10.0000, 500.0000, 5000.00, '00'),
(1, 'P002', 'Produto B - Material Escritorio', '48201000', '5101', 50.0000, 100.0000, 5000.00, '00'),
(1, 'P003', 'Produto C - Componente Eletronico', '85340000', '5101', 5.0000, 1000.0000, 5000.00, '00'),
(2, 'S001', 'Frete Rodoviario SP-RJ', '00000000', '5351', 1.0000, 8500.0000, 8500.00, NULL);

INSERT INTO TaxCalculation (DocumentId, ItemId, TaxType, TaxBase, TaxRate, TaxValue, CalculationEngine)
VALUES
(1, 1, 'ICMS', 5000.00, 0.1800, 900.00, 'VB6'),
(1, 2, 'ICMS', 5000.00, 0.1800, 900.00, 'VB6'),
(1, 3, 'ICMS', 5000.00, 0.1800, 900.00, 'VB6'),
(1, 3, 'IPI',  5000.00, 0.1000, 500.00, 'VB6');
GO
