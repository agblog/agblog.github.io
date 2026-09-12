# Section 5: Database Normalization Principles

Database normalization is the structural process of organizing tables to minimize data redundancy (duplication) and prevent accidental data inconsistencies during DML updates.

## 1. First Normal Form (1NF)
A table adheres to 1NF parameters if:
1. Data cells in each column contain strictly **atomic values** (no comma-separated array strings).
2. The table does not contain **repeating group columns** (e.g., `Employee1`, `Employee2`).
3. Each record is uniquely identified using a primary or composite key configuration.

## 2. Second Normal Form (2NF)
A table adheres to 2NF parameters if:
1. It fully meets all conditions of **1NF**.
2. Redundant data blocks are decoupled and shifted into standalone separate tables.
3. Logical structural links are established between these decoupled entities using **Foreign Keys**.

## 3. Third Normal Form (3NF)
A table adheres to 3NF parameters if:
1. It meets all conditions of **1NF and 2NF**.
2. It contains no columns that depend transitively on non-primary fields. All attributes must be fully dependent *only* upon the primary key identifier. Computed variables (e.g., `AnnualSalary` generated from multiplying a `MonthlySalary` field) are removed.
