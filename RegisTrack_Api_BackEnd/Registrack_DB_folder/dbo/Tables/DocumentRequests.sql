CREATE TABLE [dbo].[DocumentRequests] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [ReferenceNumber] NVARCHAR (50)   NOT NULL,
    [UserId]          INT             NOT NULL,
    [DocumentTypeId]  INT             NOT NULL,
    [Status]          NVARCHAR (20)   NOT NULL,
    [Quantity]        INT             NOT NULL,
    [Purpose]         NVARCHAR (1000) NOT NULL,
    [Notes]           NVARCHAR (2000) NOT NULL,
    [RequestDate]     DATETIME2 (7)   NOT NULL,
    [ProcessedDate]   DATETIME2 (7)   NULL,
    [ApprovedDate]    DATETIME2 (7)   NULL,
    [CompletedDate]   DATETIME2 (7)   NULL,
    [ProcessedBy]     INT             NULL,
    [ApprovedBy]      INT             NULL,
    [DocumentUrl]     NVARCHAR (500)  NOT NULL,
    [EmailSent]       BIT             NOT NULL,
    [LastEmailSentAt] DATETIME2 (7)   NULL
);
GO

ALTER TABLE [dbo].[DocumentRequests]
    ADD CONSTRAINT [FK_DocumentRequests_DocumentTypes_DocumentTypeId] FOREIGN KEY ([DocumentTypeId]) REFERENCES [dbo].[DocumentTypes] ([Id]);
GO

ALTER TABLE [dbo].[DocumentRequests]
    ADD CONSTRAINT [FK_DocumentRequests_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);
GO

CREATE NONCLUSTERED INDEX [IX_DocumentRequests_DocumentTypeId]
    ON [dbo].[DocumentRequests]([DocumentTypeId] ASC);
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_DocumentRequests_ReferenceNumber]
    ON [dbo].[DocumentRequests]([ReferenceNumber] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_DocumentRequests_UserId]
    ON [dbo].[DocumentRequests]([UserId] ASC);
GO

ALTER TABLE [dbo].[DocumentRequests]
    ADD CONSTRAINT [PK_DocumentRequests] PRIMARY KEY CLUSTERED ([Id] ASC);
GO

