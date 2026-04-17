# RegisTrack Backend API

## Overview
RegisTrack is a Student Document Request & Tracking System backend API built with ASP.NET Core 10.0. Students submit document requests, admins process and manage them.

## Technology Stack
- **Framework**: ASP.NET Core 10.0
- **Database**: SQL Server with Entity Framework Core
- **Auth**: JWT Bearer Authentication
- **Password Hashing**: BCrypt

## Roles
- `Student` — registers, submits and tracks their own document requests
- `Admin` — manages everything (document types, requirements, announcements, processes requests)

## Project Structure
```
Doctrack-backend-api/
├── Controllers/
│   ├── Auth/
│   │   └── AuthController.cs
│   ├── Admin/
│   │   ├── AnnouncementsController.cs
│   │   ├── DocumentTypesController.cs
│   │   ├── DocumentRequirementsController.cs
│   │   └── SeedController.cs
│   └── Student/
│       └── DocumentRequestsController.cs
├── Models/
├── DTOs/
├── Data/
├── Migrations/
├── Program.cs
└── appsettings.json
```

## API Endpoints

### Auth (`/api/Auth`)
| Method | Endpoint | Access |
|--------|----------|--------|
| POST | `/api/Auth/register` | Public |
| POST | `/api/Auth/login` | Public |

### Document Requests (`/api/DocumentRequests`)
| Method | Endpoint | Access |
|--------|----------|--------|
| GET | `/api/DocumentRequests` | Authenticated |
| GET | `/api/DocumentRequests/{id}` | Authenticated |
| GET | `/api/DocumentRequests/reference/{ref}` | Public |
| POST | `/api/DocumentRequests` | Student |
| PUT | `/api/DocumentRequests/{id}` | Admin |
| DELETE | `/api/DocumentRequests/{id}` | Student, Admin |
| POST | `/api/DocumentRequests/{id}/upload` | Admin |

### Document Types (`/api/DocumentTypes`)
| Method | Endpoint | Access |
|--------|----------|--------|
| GET | `/api/DocumentTypes` | Public |
| GET | `/api/DocumentTypes/{id}` | Public |
| POST | `/api/DocumentTypes` | Admin |
| PUT | `/api/DocumentTypes/{id}` | Admin |
| DELETE | `/api/DocumentTypes/{id}` | Admin |

### Document Requirements (`/api/DocumentRequirements`)
| Method | Endpoint | Access |
|--------|----------|--------|
| GET | `/api/DocumentRequirements` | Public |
| GET | `/api/DocumentRequirements/{id}` | Public |
| POST | `/api/DocumentRequirements` | Admin |
| PUT | `/api/DocumentRequirements/{id}` | Admin |
| DELETE | `/api/DocumentRequirements/{id}` | Admin |

### Announcements (`/api/Announcements`)
| Method | Endpoint | Access |
|--------|----------|--------|
| GET | `/api/Announcements` | Public |
| GET | `/api/Announcements/{id}` | Public |
| POST | `/api/Announcements` | Admin |
| PUT | `/api/Announcements/{id}` | Admin |
| DELETE | `/api/Announcements/{id}` | Admin |

### Seed (`/api/Seed`)
| Method | Endpoint | Access |
|--------|----------|--------|
| POST | `/api/Seed/document-types` | Admin |
| DELETE | `/api/Seed/document-types` | Admin |

## Document Request Status Flow
```
Request → InProcess → Approve → Receive → Download
```
- Students can only delete requests in `Request` status
- Admin moves requests through the workflow

## Setup

### Prerequisites
- .NET 10.0 SDK
- SQL Server (LocalDB or Express)

### Installation

1. **Update connection string** in `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=DocTrackerDB;Trusted_Connection=True;TrustServerCertificate=True"
  },
  "Jwt": {
    "Key": "YourSuperSecretKeyThatIsAtLeast32CharactersLong!",
    "Issuer": "DoctrackAPI",
    "Audience": "DoctrackClient"
  }
}
```

2. **Run migrations**:
```bash
dotnet ef database update
```

3. **Run the application**:
```bash
dotnet run
```

API available at: `http://localhost:5097`  
Swagger UI at: `http://localhost:5097/swagger`

## Contributors
- Roa, Sharla M. - Back End Developer
- Momo, Stelah Marish D. - Documentation
- Monsuller, Ronaly S. - Front End Developer
- Bulso, Daniel C. - Mobile Developer
