-- Seed Document Types for RegisTrack System
-- Common academic documents requested by students

-- Clear existing data (optional - comment out if you want to keep existing data)
-- DELETE FROM DocumentTypes;

-- Insert common document types
INSERT INTO DocumentTypes (Name, Description, ProcessingFee, ProcessingDays, IsActive, CreatedAt)
VALUES 
    ('Transcript of Records (TOR)', 'Official academic transcript showing all subjects taken and grades earned', 150.00, 5, 1, GETUTCDATE()),
    ('Certificate of Enrollment', 'Official certificate verifying current enrollment status', 50.00, 2, 1, GETUTCDATE()),
    ('Certificate of Grades', 'Official certificate showing grades for a specific semester or school year', 50.00, 3, 1, GETUTCDATE()),
    ('Certificate of Good Moral Character', 'Official certificate attesting to good moral standing', 50.00, 3, 1, GETUTCDATE()),
    ('Diploma', 'Official graduation diploma', 200.00, 7, 1, GETUTCDATE()),
    ('Honorable Dismissal', 'Certificate for students transferring to another institution', 100.00, 5, 1, GETUTCDATE()),
    ('Certificate of Authentication', 'Authentication of academic documents for international use', 100.00, 5, 1, GETUTCDATE()),
    ('Certificate of Units Earned', 'Certificate showing total units completed', 50.00, 3, 1, GETUTCDATE()),
    ('Certificate of Graduation', 'Certificate verifying graduation and degree completion', 100.00, 5, 1, GETUTCDATE()),
    ('Certificate of Transfer Credential', 'Credential for transferring to another school', 100.00, 5, 1, GETUTCDATE()),
    ('Form 137 (High School)', 'Permanent record for high school students', 100.00, 5, 1, GETUTCDATE()),
    ('Certificate of Completion', 'Certificate for completed courses or programs', 75.00, 3, 1, GETUTCDATE()),
    ('CAV (Certification, Authentication, Verification)', 'Document verification for employment or further studies', 150.00, 7, 1, GETUTCDATE()),
    ('Student ID Replacement', 'Replacement of lost or damaged student ID', 100.00, 3, 1, GETUTCDATE()),
    ('Course Prospectus', 'Detailed course curriculum and requirements', 50.00, 2, 1, GETUTCDATE());

-- Verify insertion
SELECT * FROM DocumentTypes ORDER BY Name;
