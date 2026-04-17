CREATE TABLE [dbo].[DocumentTypes] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [Name]           NVARCHAR (100)  NOT NULL,
    [Description]    NVARCHAR (500)  NOT NULL,
    [ProcessingFee]  DECIMAL (18, 2) NOT NULL,
    [ProcessingDays] INT             NOT NULL,
    [IsActive]       BIT             NOT NULL,
    [CreatedAt]      DATETIME2 (7)   NOT NULL
);
GO

ALTER TABLE [dbo].[DocumentTypes]
    ADD CONSTRAINT [PK_DocumentTypes] PRIMARY KEY CLUSTERED ([Id] ASC);
GO

