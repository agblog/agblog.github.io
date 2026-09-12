# Section 1: Introduction & Connecting to SQL Server

## 1. Introduction to SQL Server
MS SQL Server is a **Relational Database Management System (RDBMS)** developed by Microsoft. Its core function is storing and retrieving data as required by other applications, running either on the local machine or across a network.

### Primary Use Cases:
* To create and maintain relational databases.
* To analyze data through **SQL Server Analysis Services (SSAS)**.
* To generate reports through **SQL Server Reporting Services (SSRS)**.
* To carry out ETL operations through **SQL Server Integration Services (SSIS)**.

### SQL Server Component Architecture
SQL Server operates on a client-server architecture split into two component types:
1. **Workstation Components:** Local interfaces used by operators to interact with the database engine (e.g., SSMS, SQL Server Configuration Manager, Profiler).
2. **Server Components:** Centralized background services running on the database server machine (e.g., SQL Server Engine, SQL Server Agent, SSIS, SSAS, SSRS).

---

## 2. Connecting via SQL Server Management Studio (SSMS)
SSMS is the primary graphical client tool used to write and execute SQL queries. It is not the server itself; developers connect remotely or locally using it.

### Connection Parameters:
* **Server Type:** Select `Database Engine`.
* **Server Name:** Use `(local)`, `.`, or `127.0.0.1` if installed on your machine. Otherwise, enter the server IP Address or Hostname.
* **Authentication:** 
  * **Windows Authentication:** Uses your OS login credentials (no password required).
  * **SQL Server Authentication:** Requires explicit username (`sa`) and password configured during installation.
