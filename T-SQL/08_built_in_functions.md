# Section 8: Built-in String, Mathematical & Date Functions

SQL Server contains built-in scalar manipulation operations grouped by the data type boundaries they evaluate.

## 1. Core String Functions
```sql
-- Search for a character starting position index (Returns 4)
SELECT CHARINDEX('@', 'john@email.com');

-- Extract a target substring framework (Returns 'john')
SELECT SUBSTRING('john@email.com', 1, 4);

-- Replace text patterns cleanly
SELECT REPLACE('://olddomain.com', 'olddomain', 'newdomain');

-- STUFF deletes a sequence and inserts a new one inside a string
SELECT STUFF('TestString', 5, 6, 'Clear');
```

## 2. Date & Time Functions
```sql
-- Check if a string is a valid date formatting (Returns 1 for True, 0 for False)
SELECT ISDATE('2026-09-12');

-- Extract explicit components from a DateTime layout
SELECT 
    DAY(GETDATE()) AS DayOfMonth,
    MONTH(GETDATE()) AS MonthNum,
    DATENAME(MONTH, GETDATE()) AS MonthNameString;

-- Add or calculate intervals between targets
SELECT DATEADD(day, 30, GETDATE()) AS DateIn30Days;
SELECT DATEDIFF(year, '2000-01-01', GETDATE()) AS AgeInYears;

-- EOMONTH returns the last day of the month for a specific date input
SELECT EOMONTH('2026-02-15') AS LastDayOfFeb; -- Returns 2026-02-28
```

## 3. CAST and CONVERT
Both operations convert expressions from one data type to another. However, `CONVERT` provides an optional style parameter for formatting outputs (highly utilized for DateTime to string patterns).

```sql
-- Generic casting standard
SELECT CAST(12345 AS VARCHAR(10));

-- Styled conversion formatting (Style 103 returns British format 'DD/MM/YYYY')
SELECT CONVERT(VARCHAR(10), GETDATE(), 103);
```
