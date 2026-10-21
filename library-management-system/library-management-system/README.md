# Library Management System — PostgreSQL SQL Project

A relational database project built with **PostgreSQL** to model library operations and answer practical questions about books, members, employees, branches, book issues, and returns.

The project demonstrates database design, table relationships, data manipulation, joins, aggregation, subqueries/filters, summary tables, overdue analysis, and a stored procedure workflow.

## Project at a glance

- **Database:** PostgreSQL
- **Language:** SQL / PL/pgSQL
- **Data format:** CSV
- **Domain:** Library operations and circulation analytics
- **Core entities:** Books, branches, employees, members, issued books, and returns

## Repository structure

```text
library-management-system/
├── README.md
├── data/
│   ├── books.csv
│   ├── branch.csv
│   ├── employees.csv
│   ├── issued_status.csv
│   ├── members.csv
│   └── return_status.csv
├── docs/
│   └── SQL_Questions_and_Answers.md
└── sql/
    └── Library-System-Management-P2.sql
```

## Business problem

A library needs a consistent way to track its catalog, branches, staff, registered members, book issues, and returns. This project creates a relational structure for those records and uses SQL to answer questions such as:

- Which members have borrowed multiple books?
- Which books have not been returned?
- Which categories have the most issue activity?
- Which employees processed book issues?
- Which unreturned books may be overdue?
- How can a return operation update a book's availability?

## Data model

| Table | Purpose | Primary key |
|---|---|---|
| `books` | Catalog information, category, rental price, availability status, author, publisher | `isbn` |
| `branch` | Branch address, contact number, and manager reference | `branch_id` |
| `employees` | Employee details, position, salary, and assigned branch | `emp_id` |
| `members` | Member details and registration date | `member_id` |
| `issued_status` | Records of book issues, members, issue dates, books, and issuing employees | `issued_id` |
| `return_status` | Return records linked to an issue and, where populated, a book ISBN | `return_id` |

### Relationships

- `employees.branch_id` references `branch.branch_id`.
- `issued_status.issued_member_id` references `members.member_id`.
- `issued_status.issued_book_isbn` references `books.isbn`.
- `issued_status.issued_emp_id` references `employees.emp_id`.
- `return_status.issued_id` references `issued_status.issued_id`.
- `return_status.return_book_isbn` references `books.isbn`.

The branch manager is represented by `branch.manager_id`, which stores an employee ID. The supplied SQL does not declare this as a foreign-key constraint.

## Dataset

The repository contains six CSV datasets. The current files contain the following row counts (including any blank rows in the CSV files):

| File | Rows | Columns |
|---|---:|---:|
| `books.csv` | 35 | 7 |
| `branch.csv` | 5 | 4 |
| `employees.csv` | 11 | 5 |
| `issued_status.csv` | 35 | 6 |
| `members.csv` | 12 | 4 |
| `return_status.csv` | 18 | 5 |

**Data-quality note:** `issued_status.csv` contains a blank row, and some records in `return_status.csv` have missing book-name/ISBN values. Inspect and clean these values before importing if you want strict, production-style validation. The SQL seed data and CSV files should also be checked for consistency before combining them.

## Setup and run

### 1. Create a database

Using `psql`:

```sql
CREATE DATABASE library_management;
```

Connect to it:

```bash
psql -d library_management
```

Alternatively, create and open a database named `library_management` in pgAdmin.

### 2. Create the tables

Open `sql/Library-System-Management-P2.sql` and execute the table-definition section first. The script includes `DROP TABLE IF EXISTS`, so running it can delete existing tables with the same names and their data. Use a disposable practice database or back up data before executing it.

### 3. Import CSV data (optional)

The SQL script includes some sample `INSERT` statements. If you choose to import the CSV files instead, use PostgreSQL's `\copy` from `psql` after creating the matching tables. Example:

```sql
\copy books FROM 'data/books.csv' WITH (FORMAT csv, HEADER true);
```

Run the command from a working directory where the relative path exists, or use an absolute path. Repeat for each table, respecting foreign-key load order:

1. `books`, `branch`, `members`
2. `employees`
3. `issued_status`
4. `return_status`

**Important:** Do not import a CSV and run duplicate seed `INSERT` statements against the same tables without checking primary keys first. The supplied files have data-quality and schema differences that may need to be resolved before a complete import succeeds.

### 4. Run the analysis queries

Execute the query sections in the SQL file, or use the documented question-by-question examples in [`docs/SQL_Questions_and_Answers.md`](docs/SQL_Questions_and_Answers.md).

## SQL skills demonstrated

- DDL: `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`
- DML: `INSERT`, `UPDATE`, `DELETE`
- Filtering: `WHERE`, date conditions, `IS NULL`
- Aggregation: `COUNT`, `SUM`, `GROUP BY`, `HAVING`
- Joins: `INNER JOIN`, `LEFT JOIN`, self-join
- CTAS: `CREATE TABLE ... AS SELECT`
- Referential integrity: primary and foreign keys
- PostgreSQL date arithmetic
- PL/pgSQL procedure structure and `CALL`

## Key analysis questions

The accompanying Q&A document describes the tasks, query logic, and relevant SQL for:

1. Add a new book record.
2. Update a member's address.
3. Delete a book-issue record.
4. Retrieve books issued by a specific employee.
5. Find members who issued more than one book.
6. Create a per-book issue-count summary table.
7. Retrieve books in a specified category.
8. Calculate issue counts and rental-price totals by category.
9. Find recently registered members.
10. Show employees alongside their branch manager and branch details.
11. Create a table of books above a rental-price threshold.
12. List books not yet returned.
13. Identify potentially overdue, unreturned books.
14. Record a return and update the book's availability status.

See [`docs/SQL_Questions_and_Answers.md`](docs/SQL_Questions_and_Answers.md) for the full documentation and caveats.

## Important implementation notes

This repository documents the SQL that was supplied and highlights places to improve it. Before describing the project as production-ready, address these issues:

1. **Return procedure/schema mismatch:** The procedure inserts into `return_status.book_quality`, but the supplied table definition does not create that column. Add the column or remove it from the procedure's insert.
2. **Procedure return ISBN:** The procedure looks up the issued book and updates `books.status`, but it does not populate `return_book_isbn` in the return row. Consider inserting it so the return record is complete.
3. **Procedure naming:** `add_return_records` is a **procedure**, not a function, because it is declared with `CREATE OR REPLACE PROCEDURE` and invoked with `CALL`.
4. **Recent-registration filter:** The original `INTERVAL '180'` should be written as `INTERVAL '180 days'` to make the intended 180-day period explicit.
5. **Overdue logic:** The overdue query should exclude any issue with a return record, rather than relying only on `return_date IS NULL`, because the supplied return records may contain incomplete data.
6. **Repeated returns:** The supplied procedure does not prevent multiple return records for the same issue. Add validation/constraints if this is intended to be a robust circulation system.
7. **Availability semantics:** Updating a book's `status` to `yes` on return assumes the status column means “available.” If multiple copies of a title exist, model individual copies or inventory counts instead of a single status per ISBN.
8. **Data consistency:** CSVs and SQL seed statements should be reconciled before loading them into one database. Some CSV rows have missing values, and sample issue/return data may not match the script's inserts.

## Possible future improvements

- Add a normalized `book_copies` table to track multiple physical copies.
- Add a due date to each issue rather than hard-coding a 30-day lending period.
- Add constraints for valid availability values and positive rental prices.
- Add a foreign key from `branch.manager_id` to `employees.emp_id`.
- Use `NUMERIC(10,2)` rather than floating-point types for money-like values.
- Add views for current loans, overdue loans, and branch-level activity.
- Build a dashboard using Power BI, Tableau, Metabase, or a Python visualization stack.
- Add automated tests for referential integrity and query results.

## How to present this project on a resume

**Library Management System | PostgreSQL, SQL, Data Analysis**

- Designed a relational schema for books, members, employees, branches, issue records, and returns.
- Wrote SQL queries using joins, aggregations, `GROUP BY`/`HAVING`, date filters, and null handling to answer library operations questions.
- Built summary tables with CTAS and explored a PL/pgSQL procedure to record returns and update book availability.
- Identified data-quality and schema-integrity issues and documented improvements for reliable reporting.

## Notes

This is a learning and portfolio project. The supplied SQL and CSV files are retained as project inputs; the documentation calls out known gaps rather than implying that every script runs unchanged end-to-end.
