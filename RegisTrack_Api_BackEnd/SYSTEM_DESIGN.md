# Registracker System Design

## Overview

Registracker is a document request tracking system for students. It allows students to submit document requests (e.g., transcripts, certificates), and admins to process, approve, and fulfill those requests. The system sends email notifications at every stage.

---

## Tech Stack

| Layer       | Technology                        |
|-------------|-----------------------------------|
| Runtime     | .NET 10 (ASP.NET Core Web API)    |
| Database    | SQL Server (via Entity Framework Core) |
| Auth        | JWT Bearer Tokens + BCrypt        |
| Email       | SMTP (async queue-based)          |
| File Storage| Local filesystem (`/uploads/documents`) |

---

## Architecture

```
Client (Frontend / Mobile)
        │
        ▼
  ASP.NET Core Web API
  ┌─────────────────────────────────────────┐
  │  Controllers                            │
  │  ├── Auth (register, login, OTP)        │
  │  ├── Admin                              │
  │  │   ├── AnnouncementsController        │
  │  │   ├── DocumentTypesController        │
  │  │   ├── DocumentRequirementsController │
  │  │   └── SeedController                │
  │  └── Student                           │
  │      └── DocumentRequestsController    │
  │                                         │
  │  Services                               │
  │  ├── EmailService (builds email HTML)   │
  │  ├── EmailQueue (in-memory channel)     │
  │  └── EmailWorker (background sender)   │
  └─────────────────────────────────────────┘
        │                    │
        ▼                    ▼
   SQL Server DB        SMTP Server
   (EF Core)            (Gmail / etc.)
```

---

## Data Model

```
User
├── Id, FirstName, LastName
├── Email (unique), StudentId (unique)
├── Role: Student | Admin
├── PasswordHash (BCrypt)
├── IsActive, IsEmailVerified
├── OtpCode, OtpExpiresAt
└── DocumentRequests[]

DocumentType
├── Id, Name, Description
├── ProcessingFee, ProcessingDays
├── IsActive
├── Requirements[]
└── DocumentRequests[]

DocumentRequirement
├── Id, DocumentTypeId (FK)
├── RequirementName, Description
├── IsMandatory, DisplayOrder
└── DocumentType

DocumentRequest
├── Id, ReferenceNumber (unique, e.g. DR202604150001)
├── UserId (FK), DocumentTypeId (FK)
├── Status: Request → InProcess → Approve → Receive → Download
├── Quantity, Purpose, Notes
├── RequestDate, ProcessedDate, ApprovedDate, CompletedDate
├── ProcessedBy, ApprovedBy
├── DocumentUrl (uploaded file path)
└── EmailSent, LastEmailSentAt

Announcement
├── Id, Title, Content
├── Priority: Low | Normal | High | Urgent
├── IsActive, PublishedDate, ExpiryDate
└── CreatedBy
```

---

## Request Lifecycle

```
[Student submits]
      │
      ▼
   Request
      │  Admin picks up
      ▼
  InProcess
      │  Admin approves
      ▼
   Approve
      │  Student receives physically
      ▼
   Receive
      │  Document uploaded / available
      ▼
  Download
```

Status transitions are strictly validated — you can't skip steps or go backwards except for specific rollbacks (e.g., `InProcess → Request`, `Approve → InProcess`).

---

## Authentication Flow

```
Register → OTP sent via email
        ↓
Verify Email (OTP) → JWT issued
        ↓
Login → JWT issued (24hr expiry)
```

- Passwords hashed with BCrypt
- JWT contains: `userId`, `email`, `role`, `studentId`
- OTP expires in 10 minutes, rate-limited (1 per minute)

---

## Authorization

| Endpoint                        | Roles Allowed         |
|---------------------------------|-----------------------|
| POST /api/DocumentRequests      | Student               |
| PUT /api/DocumentRequests/{id}  | Admin, Staff          |
| DELETE /api/DocumentRequests/{id}| Student (own), Admin |
| POST /api/DocumentRequests/{id}/upload | Admin, Staff   |
| GET /api/DocumentRequests       | All authenticated     |
| GET /api/DocumentRequests/reference/{ref} | Public (anonymous) |
| Admin controllers               | Admin                 |

---

## Email System

Uses a non-blocking queue pattern:

```
Controller
    │ calls QueueXxxEmail()
    ▼
EmailService → builds HTML body
    │ calls Enqueue()
    ▼
EmailQueue (Channel<EmailMessage>)
    │ background reads
    ▼
EmailWorker (IHostedService)
    │ calls SendAsync()
    ▼
SmtpEmailSender → sends via SMTP
```

Email triggers:
- Registration → OTP verification email
- Request created → confirmation email
- Status updated → status update email

---

## File Upload

- Endpoint: `POST /api/DocumentRequests/{id}/upload`
- Allowed types: PDF, JPG, JPEG, PNG
- Max size: 10MB
- Stored at: `uploads/documents/{ReferenceNumber}_{GUID}.ext`
- Served statically at: `/uploads/documents/...`

---

## Reference Number Format

```
DR{YYYYMMDD}{SEQUENCE:D4}
Example: DR202604150001
```

Generated per-day, sequential, unique index enforced in DB.

---

## Project Structure

```
/Controllers
  /Admin      → AnnouncementsController, DocumentTypesController,
                DocumentRequirementsController, SeedController
  /Auth       → AuthController
  /Student    → DocumentRequestsController
/Data         → ApplicationDbContext (EF Core)
/DTOs         → Request/Response shapes per feature
/Models       → EF Core entities
/Services     → EmailService, EmailQueue, EmailWorker
/Migrations   → EF Core migration history
/uploads      → Uploaded document files (runtime)
Program.cs    → DI setup, middleware pipeline
```
