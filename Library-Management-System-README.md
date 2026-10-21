# Library Management System | SQL Business Analysis

A PostgreSQL portfolio project exploring library operations through relational data and business-focused SQL queries. The project demonstrates how raw operational tables can be queried to answer practical questions about borrowing activity, member engagement, book availability, staff activity, and overdue loans.

> **Portfolio focus:** SQL querying, data exploration, operational reporting, KPI thinking, and translating business questions into structured analysis.

## Project Overview

Libraries need to understand which books are being borrowed, how members use the collection, which issues remain outstanding, and how day-to-day circulation is managed. This project models those workflows and uses PostgreSQL queries to investigate them.

The analysis uses six datasets:

- `books.csv` — catalog, category, author, publisher, rental price, and status
- `branch.csv` — branch details and manager references
- `employees.csv` — employee, position, salary, and branch
- `members.csv` — member information and registration date
- `issued_status.csv` — book issue transactions
- `return_status.csv` — return records

The SQL source file is [`sql/Library-System-Management-P2.sql`](sql/Library-System-Management-P2.sql). It contains the table definitions, relationships, data manipulation statements, analysis queries, and a stored procedure attempt for processing book returns.

## Business Questions This Project Answers

| Business question | Why it matters | SQL approach |
|---|---|---|
| Which members have issued more than one book? | Helps identify repeat borrowing and member engagement. | `GROUP BY`, `COUNT`, `HAVING` |
| Which books have not been returned? | Helps monitor outstanding loans. | `LEFT JOIN`, `IS NULL` |
| Which unreturned books may be overdue? | Supports follow-up on loans older than the assumed 30-day period. | Date arithmetic, joins, return-record checks |
| Which categories have the most issue activity? | Helps explore demand across the collection. | `JOIN`, `GROUP BY`, `COUNT` |
| What is the summed rental-price value of issues by category? | Provides a price-based view of issue activity, subject to the metric caveat below. | `SUM`, `JOIN`, `GROUP BY` |
| Which employees processed issues? | Helps inspect circulation activity by staff member. | `WHERE` filtering |
| Which books belong to a selected category? | Supports catalog filtering and collection review. | `WHERE` |
| Which members registered within the last 180 days? | Supports recent-registration analysis. | `CURRENT_DATE`, `INTERVAL` |
| How are employees associated with branch managers? | Connects staff records to branch context. | Joins and a self-join |
| Which books exceed a selected rental-price threshold? | Creates a subset of higher-priced catalog items. | `WHERE`, `CREATE TABLE AS` |

## Key Findings & SQL Highlights

The SQL file contains the executable queries. The snippets below are selected examples to make the project understandable at a glance; they are not a substitute for running the full script against a validated database.

### 1. Find members who issued more than one book

**Business question:** Which members have more than one issue record?

```sql
SELECT
    issued_member_id,
    COUNT(issued_id) AS issue_count
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1
ORDER BY issue_count DESC;
```

**How to read the result:** Each row represents a member ID with more than one recorded issue. The count measures issue records, not necessarily distinct titles or currently active loans.

**Analyst takeaway:** This query can be extended by joining `members` to include member names, then used to segment borrowing activity.

### 2. Identify issues with no matching return record

**Business question:** Which issued books have no associated return record?

```sql
SELECT
    i.issued_id,
    i.issued_member_id,
    i.issued_book_name,
    i.issued_date
FROM issued_status AS i
LEFT JOIN return_status AS r
    ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL
ORDER BY i.issued_date;
```

**How to read the result:** The query keeps every issue and filters to rows where no return row matches the issue ID.

**Analyst takeaway:** This is a useful starting point for an outstanding-loans report. It detects missing return records; it does not by itself establish whether a loan is overdue.

### 3. Find potentially overdue, unreturned books

**Business question:** Which loans are older than 30 days and have no matching return record?

```sql
SELECT
    i.issued_member_id,
    m.member_name,
    b.book_title,
    i.issued_date,
    CURRENT_DATE - i.issued_date AS days_since_issue
FROM issued_status AS i
JOIN members AS m
    ON m.member_id = i.issued_member_id
JOIN books AS b
    ON b.isbn = i.issued_book_isbn
WHERE NOT EXISTS (
    SELECT 1
    FROM return_status AS r
    WHERE r.issued_id = i.issued_id
)
AND i.issued_date < CURRENT_DATE - 30
ORDER BY days_since_issue DESC;
```

**How to read the result:** The output identifies issues older than the assumed 30-day lending period with no return row. `days_since_issue` is elapsed time since issue, not the number of days overdue.

**Analyst takeaway:** A production version should use a stored due date and a reliable return status rather than relying on a fixed assumption.

### 4. Compare issue activity by book category

**Business question:** How many issue records are associated with each category, and what is the sum of their catalog rental prices?

```sql
SELECT
    b.category,
    SUM(b.rental_price) AS total_rental_price_sum,
    COUNT(i.issued_id) AS total_issued_records
FROM issued_status AS i
JOIN books AS b
    ON i.issued_book_isbn = b.isbn
GROUP BY b.category
ORDER BY total_issued_records DESC;
```

**How to read the result:** Each row represents a category with issue activity. The count is the number of matched issue records. The sum adds the book's listed rental price for each matched issue record.

**Metric caveat:** This sum is not confirmed revenue collected. The dataset does not show payments or actual rental charges. Interpret it as a rental-price sum associated with issue records.

### 5. Create a per-book issue-count summary table

**Business question:** How many times has each catalog book been issued?

```sql
CREATE TABLE total_book_issued_cnt AS
SELECT
    b.book_title,
    b.isbn,
    COUNT(i.issued_id) AS issue_count
FROM issued_status AS i
JOIN books AS b
    ON i.issued_book_isbn = b.isbn
GROUP BY b.book_title, b.isbn;
```

**How to read the result:** The summary stores one row per book matched to an issue record, with its total issue count.

**Analyst takeaway:** A materialized summary can simplify repeated reporting, but this CTAS table is a snapshot and will not refresh automatically when the source tables change.

### 6. Find recently registered members

**Business question:** Which members registered during the last 180 days?

```sql
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'
ORDER BY reg_date DESC;
```

**How to read the result:** The query uses the date on which it is run, so its results change over time.

**Analyst takeaway:** Relative-date filters are useful for recurring reports, provided the time window is clearly documented.

## Other Tasks Included in the SQL File

The supplied SQL script also covers:

- Adding a new book to the catalog
- Updating a member's address
- Deleting an issue record
- Retrieving issue records processed by a specific employee
- Filtering books by category
- Creating a table of books above a rental-price threshold
- Displaying employees with branch and manager details
- Defining and testing a PL/pgSQL procedure intended to record returns and update book availability

See [`docs/SQL_Questions_and_Answers.md`](docs/SQL_Questions_and_Answers.md) for the expanded question-by-question explanation.

## Database Schema at a Glance

| Table | Role in the data model |
|---|---|
| `books` | Catalog and rental-price information |
| `branch` | Library branch and manager reference |
| `employees` | Staff and branch assignment |
| `members` | Member registration information |
| `issued_status` | Issue transaction records |
| `return_status` | Return transaction records |

The SQL script defines primary keys and relationships between issue records, members, books, employees, and branches. `branch.manager_id` is used in the manager join, but the supplied script does not declare it as a foreign key.

## SQL Skills Demonstrated

- **Data definition:** `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`
- **Data manipulation:** `INSERT`, `UPDATE`, `DELETE`
- **Filtering:** `WHERE`, `IS NULL`, date conditions
- **Aggregation:** `COUNT`, `SUM`, `GROUP BY`, `HAVING`
- **Joins:** `INNER JOIN`, `LEFT JOIN`, self-join
- **Summary creation:** `CREATE TABLE AS SELECT` (CTAS)
- **Date analysis:** `CURRENT_DATE` and `INTERVAL`
- **Procedural SQL:** PL/pgSQL procedure structure and `CALL`
- **Data integrity:** Primary keys and foreign keys

## How to Run the Project

1. Create a PostgreSQL database, for example `library_management`.
2. Open `sql/Library-System-Management-P2.sql` in pgAdmin or run it through `psql`.
3. Review the `DROP TABLE IF EXISTS` statements before execution; they can remove existing tables with the same names.
4. Import CSV files from `data/` only after creating the tables and checking for duplicate seed inserts.
5. Run the analysis queries and inspect the returned rows.
6. Compare the outputs with the business questions above before publishing screenshots or numeric conclusions.

Example database creation:

```sql
CREATE DATABASE library_management;
```

CSV import order should respect the foreign-key dependencies: catalog, branches, and members first; employees next; then issue and return records. The supplied CSV files and SQL seed statements should be reconciled before loading both into the same database.

## Data & Implementation Caveats

This is a learning and portfolio project based on the supplied files. A few issues should be reviewed before treating it as production-ready:

1. The supplied return procedure inserts into `return_status.book_quality`, but the supplied table definition does not create that column. The procedure will need a matching schema change or an adjusted insert.
2. Some return records in the CSV have missing values. Validate them before drawing conclusions about return status.
3. The script includes sample inserts as well as CSV datasets. Loading both without checking for duplicate primary keys can cause conflicts.
4. The original recent-registration query uses `INTERVAL '180'`; `INTERVAL '180 days'` expresses the intended window more clearly.
5. The original overdue query labels elapsed days as overdue days. The query should distinguish `days_since_issue` from days overdue.
6. Summing catalog rental prices is not equivalent to actual revenue unless the business rules and payment data support that interpretation.
7. The supplied return procedure does not prevent repeated returns for the same issue. A robust implementation should validate this behavior.
8. A single availability status per ISBN may not accurately represent multiple physical copies of the same title.

These are documented limitations and improvement opportunities, not claims that the original script already resolves them.

## Recommended Next Steps

- Add a due date to each issue record and build an overdue-loan report.
- Create views for outstanding issues, borrowing by category, and branch-level activity.
- Add integrity checks for missing or duplicated issue/return records.
- Track physical copies separately if the library can own multiple copies of a book.
- Use `NUMERIC(10,2)` rather than floating-point types for monetary values.
- Build a dashboard in Power BI, Tableau, or another reporting tool after validating query outputs.

## Resume Description

**Library Management System | PostgreSQL, SQL, Business Analysis**

- Modeled library operations across catalog, member, employee, branch, issue, and return tables.
- Developed SQL queries using joins, aggregation, date filters, and subqueries to investigate borrowing activity and outstanding loans.
- Created summary tables to support book-level circulation analysis.
- Documented data-quality and schema limitations and proposed improvements to reporting reliability.

## Repository Files

- [`sql/Library-System-Management-P2.sql`](sql/Library-System-Management-P2.sql) — supplied SQL script
- [`docs/SQL_Questions_and_Answers.md`](docs/SQL_Questions_and_Answers.md) — expanded explanations for the project tasks
- [`data/`](data/) — six CSV datasets

---

**Disclaimer:** This is an educational portfolio project. Findings should be described as query outputs only after the queries have been run against a validated database. No numerical business result is asserted here without a verified query output.
