CREATE TABLE [dbo].[Users] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [FirstName]       NVARCHAR (100) NOT NULL,
    [LastName]        NVARCHAR (100) NOT NULL,
    [Email]           NVARCHAR (255) NOT NULL,
    [StudentId]       NVARCHAR (50)  NOT NULL,
    [Role]            NVARCHAR (20)  NOT NULL,
    [PasswordHash]    NVARCHAR (255) NOT NULL,
    [IsActive]        BIT            NOT NULL,
    [CreatedAt]       DATETIME2 (7)  NOT NULL,
    [UpdatedAt]       DATETIME2 (7)  NULL,
    [IsEmailVerified] BIT            DEFAULT (CONVERT([bit],(0))) NOT NULL,
    [OtpCode]         NVARCHAR (MAX) NULL,
    [OtpExpiresAt]    DATETIME2 (7)  NULL
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Users_Email]
    ON [dbo].[Users]([Email] ASC);
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Users_StudentId]
    ON [dbo].[Users]([StudentId] ASC);
GO

ALTER TABLE [dbo].[Users]
    ADD CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([Id] ASC);
GO

