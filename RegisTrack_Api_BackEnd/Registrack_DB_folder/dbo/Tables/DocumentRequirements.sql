CREATE TABLE [dbo].[DocumentRequirements] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [DocumentTypeId]  INT            NOT NULL,
    [RequirementName] NVARCHAR (200) NOT NULL,
    [Description]     NVARCHAR (500) NOT NULL,
    [IsMandatory]     BIT            NOT NULL,
    [DisplayOrder]    INT            NOT NULL,
    [CreatedAt]       DATETIME2 (7)  NOT NULL
);
GO

ALTER TABLE [dbo].[DocumentRequirements]
    ADD CONSTRAINT [FK_DocumentRequirements_DocumentTypes_DocumentTypeId] FOREIGN KEY ([DocumentTypeId]) REFERENCES [dbo].[DocumentTypes] ([Id]) ON DELETE CASCADE;
GO

CREATE NONCLUSTERED INDEX [IX_DocumentRequirements_DocumentTypeId]
    ON [dbo].[DocumentRequirements]([DocumentTypeId] ASC);
GO

ALTER TABLE [dbo].[DocumentRequirements]
    ADD CONSTRAINT [PK_DocumentRequirements] PRIMARY KEY CLUSTERED ([Id] ASC);
GO

