SELECT * FROM branch;
SELECT * FROM books;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;
SELECT * FROM employees;
GO
--PROJECT TASKS

--TASK 1.
--Create New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES( '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
SELECT * FROM books;
GO
--TASK 2.
--Update an Existing Member's Address
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103'
SELECT * FROM members;

UPDATE members
SET member_address = '245 Jordan St'
WHERE member_name ='John'
SELECT * FROM members;

--TASK 3.
--Delete a Record from the Issued Status Table 
--Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

 DELETE FROM issued_status
 WHERE issued_id = 'IS121'
 SELECT * FROM issued_status;

--Obejective: Delete the record with issued_book_name = 'Dune'

 DELETE FROM issued_status
 WHERE issued_book_name = 'Dune'
 SELECT * FROM issued_status;

--TASK 4: 
--Retrieve All Books Issued by a Specific Employee 
--Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

--Objective: Select all issued_book_isbn by the employees with issued_emp_id = 'E105'

SELECT issued_book_isbn FROM issued_status
WHERE issued_emp_id = 'E105';

--TASK 5: 
--List Members Who Have Issued More Than One Book 
--Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id, COUNT(*) AS issued_books
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;

/*CTAS (Create Table As Select)
Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt***/

SELECT 
    b.isbn, 
    b.book_title, 
    COUNT(ist.issued_id) AS no_of_issued
INTO book_cnts
FROM books b
JOIN issued_status ist
    ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;


/*Data Analysis & Findings
--The following SQL queries were used to address specific questions:
--Task 7. Retrieve All Books in a Specific Category:*/

SELECT * 
FROM books
WHERE category = 'Classic';

--Task 8: Find Total Rental Income by Category:

SELECT b.category,SUM(b.rental_price) AS total_income, COUNT(*) 
FROM books b
JOIN issued_status ist
ON b.isbn = ist.issued_book_isbn
GROUP BY category;

--TASK 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >=  GETDATE() - 180;

--TASK 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT e1.emp_id, e1.emp_name, e1.position, e1.salary, b.*, e2.emp_name as manager
FROM employees as e1
JOIN branch as b
ON e1.branch_id = b.branch_id    
JOIN employees as e2
ON e2.emp_id = b.manager_id


-- TASK 11: Create a Table of Books with Rental Price Above a Certain Threshold:

SELECT * 
INTO expensive_books 
FROM books
WHERE rental_price > 7;

--TASL 12: Retrieve the List of Books Not Yet Returned:
SELECT * 
FROM issued_status i
LEFT JOIN return_status r
ON i.issued_id = r.issued_id 
WHERE r.return_id IS NULL;

--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period).
--Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT * FROM books
SELECT * FROM members

SELECT  ist.issued_member_id, m.member_name, bk.book_title, ist.issued_date,
    DATEDIFF(DAY, ist.issued_date, GETDATE()) AS over_due_days
FROM  issued_status  ist
JOIN members  m 
ON m.member_id = ist.issued_member_id
JOIN books  bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status  rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30
ORDER BY 
    ist.issued_member_id;

/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table)*/
GO

CREATE PROCEDURE add_return_records
    @return_id VARCHAR(10),
    @issued_id VARCHAR(10),
    @book_quality VARCHAR(10)
AS
BEGIN
    DECLARE @isbn VARCHAR(50);
    DECLARE @book_name VARCHAR(80);

    -- Insert return record
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (@return_id, @issued_id, GETDATE(),@book_quality);

    -- Get ISBN and Book Name from issued_status
    SELECT 
        @isbn = issued_book_isbn,
        @book_name = issued_book_name
    FROM issued_status
    WHERE issued_id = @issued_id;

    -- Update books table to mark as available
    UPDATE books
    SET status = 'yes'
    WHERE isbn = @isbn;

    -- Show confirmation message
   SELECT 'Thank you for returning the book:' + @book_name ;
   END;
   
-- Check the book before return
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

-- Check issued status
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

-- Check return records before insert
SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- Call the procedure (T-SQL syntax uses EXEC, not CALL)
EXEC add_return_records 'RS138', 'IS135', 'Good';

-- Call again with a different return_id and issued_id
EXEC add_return_records 'RS148', 'IS140', 'Good';

-- Check return records after insert
SELECT * FROM return_status
WHERE issued_id IN ('IS135', 'IS140');

-- Check book status after update
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued,
the number of books returned, and the total revenue generated from book rentals*/

SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
INTO branch_reports
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;

SELECT * FROM branch_reports;

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 2 months*/

SELECT * 
INTO active_members 
FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE issued_date >= DATEADD(MONTH, -2, GETDATE())
                    );
SELECT * FROM active_members;

/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/

SELECT 
    e.emp_name,
    b.branch_id,
    b.manager_id,
    b.branch_address,
	b.contact_no,
    COUNT(ist.issued_id) AS no_book_issued
FROM issued_status ist
JOIN employees e
    ON e.emp_id = ist.issued_emp_id
JOIN branch b
    ON e.branch_id = b.branch_id
GROUP BY 
    e.emp_name,
    b.branch_id,
    b.manager_id,
    b.branch_address,
	b.contact_no;
	
/*Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.*/

-- Create or Replace Procedure equivalent in SQL Server
IF OBJECT_ID('issue_book', 'P') IS NOT NULL
    DROP PROCEDURE issue_book;
GO

CREATE PROCEDURE issue_book
    @issued_id VARCHAR(10),
    @issued_member_id VARCHAR(30),
    @issued_book_isbn VARCHAR(30),
    @issued_emp_id VARCHAR(10)
AS
BEGIN
    DECLARE @status VARCHAR(10);

    -- Check if the book is available
    SELECT @status = status
    FROM books
    WHERE isbn = @issued_book_isbn;

    IF @status = 'yes'
    BEGIN
        INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn,  issued_emp_id
        )
        VALUES (
			@issued_id, @issued_member_id, GETDATE(), @issued_book_isbn, @issued_emp_id);

        UPDATE books
        SET status = 'no'
        WHERE isbn = @issued_book_isbn;

        PRINT 'Book records added successfully for book ISBN: ' + @issued_book_isbn;
    END
    ELSE
    BEGIN
        PRINT 'Sorry to inform you the book you have requested is unavailable. Book ISBN: ' + @issued_book_isbn;
    END
END;
GO
-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

EXEC issue_book 'IS155', 'C108', '978-0-553-29698-2', 'E104';
EXEC issue_book 'IS156', 'C108', '978-0-375-41398-8', 'E104';

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

