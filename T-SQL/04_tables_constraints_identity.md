# Section 4: Tables, Integrity Constraints & Identity Columns

## 1. Creating Tables & Setting Constraints
Constraints specify formatting and logical evaluation rules for column records. If a structural operation violates a constraint, the action aborts.

```sql
-- Create a lookup parent table
CREATE TABLE tblGender (
    ID INT NOT NULL PRIMARY KEY,
    Gender NVARCHAR(50) NOT NULL
);

-- Create a child table with Foreign Key and Default Constraints
CREATE TABLE tblPerson (
    ID INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Email NVARCHAR(50) NOT NULL,
    GenderID INT,
    Age INT
);

-- Establish Foreign Key constraint downstream
ALTER TABLE tblPerson 
ADD CONSTRAINT tblPerson_GenderID_FK 
FOREIGN KEY (GenderID) REFERENCES tblGender(ID);

-- Add a Default Constraint for GenderID
ALTER TABLE tblPerson
ADD CONSTRAINT DF_tblPerson_GenderID 
DEFAULT 1 FOR GenderID;

-- Add a CHECK Constraint limiting allowable Age span
ALTER TABLE tblPerson
ADD CONSTRAINT CK_tblPerson_Age 
CHECK (Age > 0 AND Age < 150);
```

---

## 2. Auto-Incrementing Identity Columns
Identity properties automatically compute numeric sequences upon insertion. They accept optional seed and increment values (defaulting to 1,1).

```sql
CREATE TABLE tblIdentityExample (
    PersonId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(20)
);

-- Explicitly overriding identity rules to fill gaps or data migrations
SET IDENTITY_INSERT tblIdentityExample ON;

INSERT INTO tblIdentityExample (PersonId, Name) 
VALUES (2, 'John');

SET IDENTITY_INSERT tblIdentityExample OFF;

-- Reseeding an identity tracking value back to 0 after deleting rows
DBCC CHECKIDENT('tblIdentityExample', RESEED, 0);
```

### Retrieving Identity Values:
* `SCOPE_IDENTITY()`: Returns the last identity value created within the **same session and same scope** (most secure configuration).
* `@@IDENTITY`: Returns the last identity value created within the **same session across any scope** (can include triggers).
* `IDENT_CURRENT('TableName')`: Returns the last identity value created for a **specific table across any session/scope**.
