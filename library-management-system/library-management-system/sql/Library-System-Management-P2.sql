--Library Management System- p2

DROP TABLE IF EXISTS books;
Create Table books 
(
 isbn VARCHAR(20) PRIMARY KEY,	
 book_title VARCHAR(60),	
 category VARCHAR(20),	
 rental_price FLOAT,	
 status VARCHAR(5),	
 author VARCHAR(25),	
 publisher VARCHAR(30)
);

DROP TABLE IF EXISTS branch;
Create Table branch
(
 branch_id VARCHAR(5) PRIMARY KEY,
 manager_id VARCHAR(5),	
 branch_address VARCHAR(15),
 contact_no VARCHAR(15)
);

DROP TABLE IF EXISTS employees;
Create Table employees
(
emp_id VARCHAR (5) PRIMARY KEY,
emp_name VARCHAR (20),	
position VARCHAR (10),	
salary VARCHAR (6),
branch_id VARCHAR (5)
);

Alter Table employees
Alter Column salary Type Float USING salary::double precision;


DROP TABLE IF EXISTS members;
Create Table members
(
 member_id	VARCHAR (5) PRIMARY KEY,
 member_name	VARCHAR (15),
 member_address VARCHAR (15),	
 reg_date DATE
);


DROP TABLE IF EXISTS issued_status;
Create Table issued_status
(
 issued_id VARCHAR (5) PRIMARY KEY,
 issued_member_id VARCHAR (5),
 issued_book_name VARCHAR(60),
 issued_date	DATE,
 issued_book_isbn VARCHAR(20),
 issued_emp_id VARCHAR (5)
);

DROP TABLE IF EXISTS return_status;
Create Table return_status
(
 return_id	VARCHAR (5) PRIMARY KEY,
 issued_id VARCHAR (5),
 return_book_name VARCHAR(60),
 return_date	DATE,
 return_book_isbn VARCHAR(20)
);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_id
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

Alter Table return_status
Add Constraint fk_return_book_isbn
Foreign Key (return_book_isbn)
References books(isbn);

Alter Table issued_status
Add Constraint fk_issued_member_id
Foreign Key (issued_member_id)
References members(member_id);

Alter Table issued_status
Add Constraint fk_issued_book_isbn
Foreign Key (issued_book_isbn)
References books(isbn);

Alter Table issued_status
Add Constraint fk_issued_emp_id
Foreign Key (issued_emp_id)
References employees(emp_id);

Alter Table employees
Add Constraint fk_branch_id
Foreign Key (branch_id)
References branch(branch_id);

Select * From issued_status;
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id) 
VALUES
('IS106', 'C108', 'Animal Farm', '2024-03-10', '978-0-330-25864-8', 'E104'),
('IS107', 'C108', 'One Hundred Years of Solitude', '2024-03-11', '978-0-14-118776-1', 'E104'),
('IS108', 'C108', 'The Great Gatsby', '2024-03-12', '978-0-525-47535-5', 'E104'),
('IS109', 'C109', 'Jane Eyre', '2024-03-13', '978-0-141-44171-6', 'E105'),
('IS110', 'C110', 'The Alchemist', '2024-03-14', '978-0-307-37840-1', 'E105'),
('IS111', 'C109', 'Harry Potter and the Sorcerers Stone', '2024-03-15', '978-0-679-76489-8', 'E105'),
('IS112', 'C109', 'A Game of Thrones', '2024-03-16', '978-0-09-957807-9', 'E106'),
('IS113', 'C109', 'A Peoples History of the United States', '2024-03-17', '978-0-393-05081-8', 'E106'),
('IS114', 'C109', 'The Guns of August', '2024-03-18', '978-0-19-280551-1', 'E106'),
('IS115', 'C109', 'The Histories', '2024-03-19', '978-0-14-044930-3', 'E107'),
('IS116', 'C110', 'Guns, Germs, and Steel: The Fates of Human Societies', '2024-03-20', '978-0-393-91257-8', 'E107'),
('IS117', 'C110', '1984', '2024-03-21', '978-0-679-64115-3', 'E107'),
('IS118', 'C101', 'Pride and Prejudice', '2024-03-22', '978-0-14-143951-8', 'E108'),
('IS119', 'C110', 'Brave New World', '2024-03-23', '978-0-452-28240-7', 'E108'),
('IS120', 'C110', 'The Road', '2024-03-24', '978-0-670-81302-4', 'E108'),
('IS121', 'C102', 'The Shining', '2024-03-25', '978-0-385-33312-0', 'E109'),
('IS122', 'C102', 'Fahrenheit 451', '2024-03-26', '978-0-451-52993-5', 'E109'),
('IS123', 'C103', 'Dune', '2024-03-27', '978-0-345-39180-3', 'E109'),
('IS124', 'C104', 'Where the Wild Things Are', '2024-03-28', '978-0-06-025492-6', 'E110'),
('IS125', 'C105', 'The Kite Runner', '2024-03-29', '978-0-06-112241-5', 'E110'),
('IS126', 'C105', 'Charlotte''s Web', '2024-03-30', '978-0-06-440055-8', 'E110'),
('IS127', 'C105', 'Beloved', '2024-03-31', '978-0-679-77644-3', 'E110'),
('IS128', 'C105', 'A Tale of Two Cities', '2024-04-01', '978-0-14-027526-3', 'E110'),
('IS129', 'C105', 'The Stand', '2024-04-02', '978-0-7434-7679-3', 'E110'),
('IS130', 'C108', 'Moby Dick', '2024-04-03', '978-0-451-52994-2', 'E101'),
('IS131', 'C108', 'To Kill a Mockingbird', '2024-04-04', '978-0-06-112008-4', 'E101'),
('IS132', 'C108', 'The Hobbit', '2024-04-05', '978-0-7432-7356-4', 'E106'),
('IS133', 'C108', 'Angels & Demons', '2024-04-06', '978-0-7432-4722-5', 'E106'),
('IS134', 'C108', 'The Diary of a Young Girl', '2024-04-07', '978-0-375-41398-8', 'E106'),
('IS135', 'C108', 'Sapiens: A Brief History of Humankind', '2024-04-08', '978-0-307-58837-1', 'E108'),
('IS136', 'C108', '1491: New Revelations of the Americas Before Columbus', '2024-04-09', '978-0-7432-7357-1', 'E102'),
('IS137', 'C108', 'The Catcher in the Rye', '2024-04-10', '978-0-553-29698-2', 'E103'),
('IS138', 'C108', 'The Great Gatsby', '2024-04-11', '978-0-525-47535-5', 'E104'),
('IS139', 'C109', 'Harry Potter and the Sorcerers Stone', '2024-04-12', '978-0-679-76489-8', 'E105'),
('IS140', 'C110', 'Animal Farm', '2024-04-13', '978-0-330-25864-8', 'E102');



INSERT INTO members(member_id, member_name, member_address, reg_date) 
VALUES
('C101', 'Alice Johnson', '123 Main St', '2021-05-15'),
('C102', 'Bob Smith', '456 Elm St', '2021-06-20'),
('C103', 'Carol Davis', '789 Oak St', '2021-07-10'),
('C104', 'Dave Wilson', '567 Pine St', '2021-08-05'),
('C105', 'Eve Brown', '890 Maple St', '2021-09-25'),
('C106', 'Frank Thomas', '234 Cedar St', '2021-10-15'),
('C107', 'Grace Taylor', '345 Walnut St', '2021-11-20'),
('C108', 'Henry Anderson', '456 Birch St', '2021-12-10'),
('C109', 'Ivy Martinez', '567 Oak St', '2022-01-05'),
('C110', 'Jack Wilson', '678 Pine St', '2022-02-25'),
('C118', 'Sam', '133 Pine St', '2024-06-01'),    
('C119', 'John', '143 Main St', '2024-05-01');


INSERT INTO return_status(return_id, issued_id, return_date) 
VALUES
('RS101', 'IS106', '2023-06-06'),
('RS102', 'IS106', '2023-06-07'),
('RS103', 'IS106', '2023-08-07'),
('RS104', 'IS106', '2024-05-01'),
('RS105', 'IS107', '2024-05-03'),
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS109', 'IS111', '2024-05-11'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');

--

--Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

Insert Into books (isbn, book_title, category, rental_price, status, author, publisher)
Values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

Select * From books

--Task 2: Update an Existing Member's Address

Select * From members

Update members
Set member_address ='135 Oak St'
Where member_id = 'C103';

--Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table

Delete From issued_status
Where issued_id = 'IS121'

Select * From issued_status

--Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

Select * From issued_status
Where issued_emp_id='E101'

--List Members Who Have Issued More Than One Book 

Select 
 issued_member_id,
 Count(issued_id)
From issued_status
Group by issued_member_id
Having Count(*)>1

--Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

Drop Table If Exists total_book_issued_cnt;
Create Table total_book_issued_cnt
As
Select 
 b.book_title,
 b.isbn,
 Count(ist.issued_id) as issue_count
From issued_status AS ist
Inner Join books as b
on
ist.issued_book_isbn=b.isbn
Group By b.book_title, b.isbn;

Select * from total_book_issued_cnt;


--Task 7. Retrieve All Books in a Specific Category:

Select book_title From books
Where category='Classic';

--Task 8: Find Total Rental Income by Category:

Select 
 b.category,
 SUM(b.rental_price) as total_rental_income,
 Count(ist.issued_id) as total_issued_books
From issued_status as ist
Inner join books as b
on
ist.issued_book_isbn=b.isbn
Group By b.category;

--List Members Who Registered in the Last 180 Days:

Select * From members
Where reg_date >= Current_Date - Interval '180';

--List Employees with Their Branch Manager's Name and their branch details:

Select 
 e1.*,
 e2.emp_name as manager_name,
 b.branch_address
From employees as e1
inner Join branch as b
on
b.branch_id=e1.branch_id
Inner join employees as e2
on
b.manager_id=e2.emp_id;

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

Drop Table If Exists expensive_books;
Create Table expensive_books as
Select * from books
Where rental_price>'7';

Select * From expensive_books;

--Task 12: Retrieve the List of Books Not Yet Returned


Select i.issued_book_name
From 
issued_status as i
Left join return_status as r
on
i.issued_id=r.issued_id
Where r.return_id Is Null;


--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). 
--Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1


--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');






















