-- VFI - Validador Fiscal Inteligente
-- Migration 001: Create Database and Tables
-- SQL Server

CREATE DATABASE VFI_DB;
GO

USE VFI_DB;
GO

CREATE TABLE FiscalDocument (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    DocumentType    VARCHAR(20)  NOT NULL, -- NFe, CTe, MDFe
    DocumentKey     VARCHAR(44)  NOT NULL UNIQUE,
    DocumentNumber  VARCHAR(20)  NOT NULL,
    IssueDate       DATETIME2    NOT NULL,
    IssuerCNPJ      VARCHAR(14)  NOT NULL,
    IssuerName      VARCHAR(200) NOT NULL,
    RecipientCNPJ   VARCHAR(14)  NOT NULL,
    RecipientName   VARCHAR(200) NOT NULL,
    TotalValue      DECIMAL(18,2) NOT NULL,
    XMLContent      XML          NULL,
    Status          VARCHAR(20)  NOT NULL DEFAULT 'PENDENTE', -- PENDENTE, VALIDADO, REJEITADO, ERRO
    CreatedAt       DATETIME2    NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2    NOT NULL DEFAULT GETDATE()
);

CREATE TABLE DocumentItem (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId      INT          NOT NULL,
    ProductCode     VARCHAR(60)  NOT NULL,
    ProductName     VARCHAR(200) NOT NULL,
    NCM             VARCHAR(8)   NOT NULL,
    CFOP            VARCHAR(4)   NOT NULL,
    Quantity        DECIMAL(18,4) NOT NULL,
    UnitValue       DECIMAL(18,4) NOT NULL,
    TotalValue      DECIMAL(18,2) NOT NULL,
    CST             VARCHAR(3)   NULL,
    CONSTRAINT FK_Item_Document FOREIGN KEY (DocumentId) REFERENCES FiscalDocument(Id)
);

CREATE TABLE TaxCalculation (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId      INT          NULL,
    ItemId          INT          NULL,
    TaxType         VARCHAR(10)  NOT NULL, -- ICMS, ST, IPI, PIS, COFINS
    TaxBase         DECIMAL(18,2) NOT NULL,
    TaxRate         DECIMAL(7,4) NOT NULL,
    TaxValue        DECIMAL(18,2) NOT NULL,
    CalculationEngine VARCHAR(20) NOT NULL DEFAULT 'VB6', -- VB6, INTERNAL
    CreatedAt       DATETIME2    NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Tax_Document FOREIGN KEY (DocumentId) REFERENCES FiscalDocument(Id),
    CONSTRAINT FK_Tax_Item FOREIGN KEY (ItemId) REFERENCES DocumentItem(Id)
);

CREATE TABLE ValidationLog (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId      INT          NOT NULL,
    ValidationType  VARCHAR(30)  NOT NULL, -- XSD, SEFAZ_RULE, BUSINESS, AI
    IsValid         BIT          NOT NULL,
    ErrorMessage    VARCHAR(500) NULL,
    ErrorCode       VARCHAR(20)  NULL,
    ValidatedAt     DATETIME2    NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Validation_Document FOREIGN KEY (DocumentId) REFERENCES FiscalDocument(Id)
);

CREATE TABLE AIAnalysisLog (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    DocumentId      INT          NOT NULL,
    Model           VARCHAR(50)  NOT NULL,
    Prompt          NVARCHAR(MAX) NOT NULL,
    Response        NVARCHAR(MAX) NULL,
    AnomaliesFound  INT          NOT NULL DEFAULT 0,
    ConfidenceScore DECIMAL(5,2) NULL,
    TokensUsed      INT          NULL,
    CreatedAt       DATETIME2    NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_AIAnalysis_Document FOREIGN KEY (DocumentId) REFERENCES FiscalDocument(Id)
);

CREATE INDEX IX_FiscalDocument_DocumentType ON FiscalDocument(DocumentType);
CREATE INDEX IX_FiscalDocument_IssuerCNPJ ON FiscalDocument(IssuerCNPJ);
CREATE INDEX IX_FiscalDocument_Status ON FiscalDocument(Status);
CREATE INDEX IX_DocumentItem_DocumentId ON DocumentItem(DocumentId);
CREATE INDEX IX_TaxCalculation_DocumentId ON TaxCalculation(DocumentId);
GO

CREATE TABLE AiRule (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Description     NVARCHAR(500) NOT NULL,
    Severity        NVARCHAR(50)  NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2     NULL
);
GO
