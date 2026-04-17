CREATE TABLE [dbo].[Announcements] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Title]         NVARCHAR (200) NOT NULL,
    [Content]       NVARCHAR (MAX) NOT NULL,
    [Priority]      NVARCHAR (20)  NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [PublishedDate] DATETIME2 (7)  NOT NULL,
    [ExpiryDate]    DATETIME2 (7)  NULL,
    [CreatedBy]     INT            NOT NULL,
    [CreatedAt]     DATETIME2 (7)  NOT NULL,
    [UpdatedAt]     DATETIME2 (7)  NULL
);
GO

ALTER TABLE [dbo].[Announcements]
    ADD CONSTRAINT [PK_Announcements] PRIMARY KEY CLUSTERED ([Id] ASC);
GO

