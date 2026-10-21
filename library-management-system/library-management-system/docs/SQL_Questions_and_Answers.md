# Library Management System — SQL Questions & Answers

This document explains the SQL tasks in the supplied PostgreSQL script. Each section states the business question, gives a query, and explains the SQL concepts used.

> **Important:** The examples below are based on the supplied project. Where the original SQL has a syntax, logic, or schema limitation, that is called out explicitly. Test queries against your actual imported data before reporting numeric results.

## Table of contents

1. [Create a new book record](#1-create-a-new-book-record)
2. [Update a member's address](#2-update-a-members-address)
3. [Delete an issue record](#3-delete-an-issue-record)
4. [Books issued by a specific employee](#4-books-issued-by-a-specific-employee)
5. [Members who issued more than one book](#5-members-who-issued-more-than-one-book)
6. [Create a per-book issue-count summary](#6-create-a-per-book-issue-count-summary)
7. [Books in a specific category](#7-books-in-a-specific-category)
8. [Rental-price total and issue count by category](#8-rental-price-total-and-issue-count-by-category)
9. [Members registered in the last 180 days](#9-members-registered-in-the-last-180-days)
10. [Employees with manager and branch details](#10-employees-with-manager-and-branch-details)
11. [Books above a rental-price threshold](#11-books-above-a-rental-price-threshold)
12. [Books not yet returned](#12-books-not-yet-returned)
13. [Identify potentially overdue books](#13-identify-potentially-overdue-books)
14. [Record a return and update availability](#14-record-a-return-and-update-availability)

---

## 1. Create a new book record

**Business question:** How do we add a new book to the library catalog?

```sql
INSERT INTO books
    (isbn, book_title, category, rental_price, status, author, publisher)
VALUES
    ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic',
     6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

**Answer / explanation:** `INSERT INTO` creates a new row. The column list makes the mapping between each column and its value explicit. The ISBN is the primary key, so it must be unique.

**Concepts:** `INSERT`, primary key, column/value mapping.

**Verification:**

```sql
SELECT *
FROM books
WHERE isbn = '978-1-60129-456-2';
```

**Caution:** The supplied issue data already references the title *To Kill a Mockingbird* under a different ISBN. Confirm whether this new ISBN is intended to represent a separate catalog record.

## 2. Update a member's address

**Business question:** How do we update the address for member `C103`?

```sql
UPDATE members
SET member_address = '135 Oak St'
WHERE member_id = 'C103';
```

**Answer / explanation:** `UPDATE` changes the selected row. The `WHERE` clause is essential; without it, every member's address would be overwritten.

**Concepts:** `UPDATE`, `SET`, `WHERE`.

**Verification:**

```sql
SELECT member_id, member_name, member_address
FROM members
WHERE member_id = 'C103';
```

## 3. Delete an issue record

**Business question:** How do we delete issue `IS121` from `issued_status`?

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

**Answer / explanation:** `DELETE` removes the row matching the issue ID. `issued_id` is the primary key.

**Concepts:** `DELETE`, filtering by primary key.

**Caution:** The supplied schema makes `return_status.issued_id` a foreign key to `issued_status.issued_id`. If a return row references `IS121`, PostgreSQL may reject the deletion because the default foreign-key behavior is restrictive. Check dependent rows first:

```sql
SELECT *
FROM return_status
WHERE issued_id = 'IS121';
```

For a real circulation system, preserving issue history is generally preferable to deleting transactions.

## 4. Books issued by a specific employee

**Business question:** Which issue records were processed by employee `E101`?

```sql
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';
```

**Answer / explanation:** The `WHERE` clause filters issue records to the selected employee. The query returns issue details, including member ID, book name, issue date, ISBN, and employee ID.

**Concepts:** `SELECT`, `WHERE`.

To display the employee name and book title from the related tables:

```sql
SELECT
    i.issued_id,
    e.emp_name,
    i.issued_book_name,
    i.issued_date,
    i.issued_member_id
FROM issued_status AS i
JOIN employees AS e
    ON e.emp_id = i.issued_emp_id
WHERE i.issued_emp_id = 'E101';
```

## 5. Members who issued more than one book

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

**Answer / explanation:** `GROUP BY` creates one group per member. `COUNT` counts issue records in each group. `HAVING` filters aggregated groups, so only members with more than one issue record remain.

**Concepts:** `COUNT`, `GROUP BY`, `HAVING`, sorting.

To show member names as well:

```sql
SELECT
    m.member_id,
    m.member_name,
    COUNT(i.issued_id) AS issue_count
FROM members AS m
JOIN issued_status AS i
    ON i.issued_member_id = m.member_id
GROUP BY m.member_id, m.member_name
HAVING COUNT(i.issued_id) > 1
ORDER BY issue_count DESC, m.member_name;
```

## 6. Create a per-book issue-count summary

**Business question:** How many times has each catalog book been issued?

```sql
DROP TABLE IF EXISTS total_book_issued_cnt;

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

Inspect the summary:

```sql
SELECT *
FROM total_book_issued_cnt
ORDER BY issue_count DESC, book_title;
```

**Answer / explanation:** The query joins issue transactions to the catalog through ISBN, groups by each book, and counts issue IDs. `CREATE TABLE ... AS SELECT` (CTAS) materializes the query result as a new table.

**Concepts:** `INNER JOIN`, `COUNT`, `GROUP BY`, CTAS.

**Interpretation:** This counts issue records, not necessarily unique members or currently outstanding copies. Because it uses an inner join, catalog books with zero matching issue records do not appear. To include those books, start from `books` and `LEFT JOIN` `issued_status`.

## 7. Books in a specific category

**Business question:** Which books belong to the `Classic` category?

```sql
SELECT book_title
FROM books
WHERE category = 'Classic'
ORDER BY book_title;
```

**Answer / explanation:** The query filters the catalog by category and returns the title of each matching book.

**Concepts:** `SELECT`, `WHERE`.

The category string must match the stored value. If category spelling or capitalization is inconsistent, normalize the data or use a deliberate case-insensitive comparison.

## 8. Rental-price total and issue count by category

**Business question:** For each category with issue activity, what is the sum of catalog rental prices and how many issue records exist?

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

**Answer / explanation:** The join associates each issue record with its catalog book. The query then groups by category and calculates a sum and count.

**Concepts:** `INNER JOIN`, `SUM`, `COUNT`, `GROUP BY`.

**Metric caveat:** The original column alias `total_rental_income` can be misleading. `SUM(b.rental_price)` sums the rental price once for each matched issue record; it is not necessarily actual collected income, because the schema does not record payments or rental charges. A clearer alias is `total_rental_price_sum`. For issue-based potential rental value, `SUM(b.rental_price)` per issue is equivalent only if each issue incurs exactly the listed price.

## 9. Members registered in the last 180 days

**Business question:** Which members registered during the last 180 days relative to the date the query runs?

```sql
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'
ORDER BY reg_date DESC;
```

**Answer / explanation:** `CURRENT_DATE` returns the current date in PostgreSQL. Subtracting an interval creates a date boundary; the filter returns registrations on or after that boundary.

**Concepts:** Date filtering, `CURRENT_DATE`, `INTERVAL`.

**Correction to supplied SQL:** The supplied expression uses `INTERVAL '180'`. Use `INTERVAL '180 days'` to explicitly express the intended duration.

## 10. Employees with manager and branch details

**Business question:** How can we display each employee with their branch address and the name of that branch's manager?

```sql
SELECT
    e.emp_id,
    e.emp_name,
    e.position,
    e.salary,
    e.branch_id,
    manager.emp_name AS manager_name,
    b.branch_address
FROM employees AS e
JOIN branch AS b
    ON b.branch_id = e.branch_id
JOIN employees AS manager
    ON b.manager_id = manager.emp_id
ORDER BY b.branch_id, e.emp_name;
```

**Answer / explanation:** The `employees` table is joined twice: once for the employee and again through the alias `manager` to find the manager's name. This is a self-join. The branch table supplies branch information.

**Concepts:** Multiple joins, table aliases, self-join.

**Caveat:** These are inner joins, so employees whose branch or manager reference does not match a row will be excluded. Use `LEFT JOIN` if you want to retain those employees for data-quality review.

## 11. Books above a rental-price threshold

**Business question:** How can we create a table of books with a rental price greater than 7?

```sql
DROP TABLE IF EXISTS expensive_books;

CREATE TABLE expensive_books AS
SELECT *
FROM books
WHERE rental_price > 7;
```

Inspect the result:

```sql
SELECT *
FROM expensive_books
ORDER BY rental_price DESC;
```

**Answer / explanation:** The query filters books using a numeric comparison and materializes the matching rows in `expensive_books`.

**Concepts:** `WHERE`, comparison operators, CTAS.

**Caveat:** A CTAS table does not automatically inherit the original table's primary-key and foreign-key constraints. Also, this is a snapshot: it will not automatically update when the `books` table changes.

## 12. Books not yet returned

**Business question:** Which issued books do not have a matching return record?

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

**Answer / explanation:** A `LEFT JOIN` keeps every issue record. If no return record matches, the right-hand columns are `NULL`; filtering on `r.return_id IS NULL` identifies issues with no return row.

**Concepts:** `LEFT JOIN`, `IS NULL`, anti-join pattern.

**Caveat:** This identifies issues with no matching return row. If a return row exists but has a missing `return_date`, the issue is not included by this pattern. This is generally more reliable than treating a missing date as proof that no return record exists.

## 13. Identify potentially overdue books

**Business question:** Which books have been issued for more than 30 days and have no return record? Show member ID, member name, book title, issue date, and days elapsed since issue.

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

**Answer / explanation:** The query joins issues to members and books, calculates elapsed days using date subtraction, and uses `NOT EXISTS` to exclude issues with any return record. The 30-day condition identifies issues older than the assumed lending period.

**Concepts:** Joins, date arithmetic, correlated subquery, `NOT EXISTS`.

**Important interpretation:** The value shown is `days_since_issue`, not exact days overdue. To calculate days overdue, subtract the assumed 30-day loan period: `(CURRENT_DATE - i.issued_date) - 30`. The query uses the prompt's assumed 30-day period; a production database should store each issue's due date. It also assumes any return record means the book has been returned, even if the return record is incomplete.

## 14. Record a return and update availability

**Business question:** How can a return operation add a return record and set the associated book's status to `yes`?

The supplied script attempts this with a PL/pgSQL procedure named `add_return_records`. The supplied procedure currently references a `book_quality` column that is absent from its `CREATE TABLE return_status` definition, so it will fail unless the schema is updated.

### Suggested compatible schema change

If book condition is part of the intended data model, add the missing column:

```sql
ALTER TABLE return_status
ADD COLUMN IF NOT EXISTS book_quality VARCHAR(10);
```

### Suggested procedure

This version records the ISBN as well as the return date and quality. Run it only after the tables and required columns are in place.

```sql
CREATE OR REPLACE PROCEDURE add_return_records(
    p_return_id VARCHAR(10),
    p_issued_id VARCHAR(10),
    p_book_quality VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(20);
    v_book_name VARCHAR(60);
BEGIN
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Issue ID % does not exist', p_issued_id;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM return_status
        WHERE issued_id = p_issued_id
    ) THEN
        RAISE EXCEPTION 'Issue ID % already has a return record', p_issued_id;
    END IF;

    INSERT INTO return_status
        (return_id, issued_id, return_book_name, return_date,
         return_book_isbn, book_quality)
    VALUES
        (p_return_id, p_issued_id, v_book_name, CURRENT_DATE,
         v_isbn, p_book_quality);

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;
```

Call the procedure:

```sql
CALL add_return_records('RS138', 'IS135', 'Good');
```

Verify the result:

```sql
SELECT *
FROM return_status
WHERE issued_id = 'IS135';

SELECT isbn, book_title, status
FROM books
WHERE isbn = (
    SELECT issued_book_isbn
    FROM issued_status
    WHERE issued_id = 'IS135'
);
```

**Answer / explanation:** The procedure retrieves the ISBN and title for the issue, inserts a return record, changes the catalog status to `yes`, and raises a notice. The transaction succeeds or fails as a unit when called under PostgreSQL's normal transaction behavior.

**Concepts:** PL/pgSQL, stored procedures, `SELECT ... INTO`, `IF`, `EXISTS`, `INSERT`, `UPDATE`, `RAISE NOTICE`, `CALL`.

**Business rule to confirm:** This assumes `yes` means the book is available and that each ISBN represents one physical copy. If the library owns multiple copies per ISBN, use a copy-level inventory model instead.

---

## Validation checklist

Before publishing query results or screenshots, run these checks against your own database:

```sql
-- Table row counts
SELECT 'books' AS table_name, COUNT(*) FROM books
UNION ALL SELECT 'branch', COUNT(*) FROM branch
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'members', COUNT(*) FROM members
UNION ALL SELECT 'issued_status', COUNT(*) FROM issued_status
UNION ALL SELECT 'return_status', COUNT(*) FROM return_status;

-- Issues that reference a missing catalog ISBN (should return no rows)
SELECT i.*
FROM issued_status AS i
LEFT JOIN books AS b ON b.isbn = i.issued_book_isbn
WHERE b.isbn IS NULL;

-- Return rows with no matching issue (should return no rows if integrity is enforced)
SELECT r.*
FROM return_status AS r
LEFT JOIN issued_status AS i ON i.issued_id = r.issued_id
WHERE i.issued_id IS NULL;

-- Issues that have multiple return rows
SELECT issued_id, COUNT(*) AS return_count
FROM return_status
GROUP BY issued_id
HAVING COUNT(*) > 1;
```

## Summary

This project practices core SQL skills in a practical library domain. Its strongest portfolio story is not just that it contains queries, but that it connects business questions to relational data, explains the SQL concepts used, and transparently identifies data-model and data-quality improvements.
