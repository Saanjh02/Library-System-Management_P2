# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql

--Creating branch table
DROP TABLE IF EXISTS branch
CREATE TABLE branch
				(
                                 	branch_id VARCHAR(10) PRIMARY KEY,
					manager_id VARCHAR(10),
					branch_address VARCHAR(55),
					contact_no VARCHAR(15) 
				);

DROP TABLE IF EXISTS employees
CREATE TABLE employees
				(
					emp_id VARCHAR(10) PRIMARY KEY,                                                       
					emp_name VARCHAR(30),
					position VARCHAR(25),
					salary INT,
					branch_id VARCHAR(10) --FK	
				 );

DROP TABLE IF EXISTS books
CREATE TABLE books 
				(
					isbn VARCHAR(20) PRIMARY KEY,
					book_title VARCHAR(75),
					category VARCHAR(25), 
					rental_price FLOAT,
					status VARCHAR(15),
					author VARCHAR(35), 
					publisher VARCHAR(55)
				);

DROP TABLE IF EXISTS members
CREATE TABLE members 
				(
					member_id VARCHAR(15) PRIMARY KEY,
					member_name VARCHAR(25),
					member_address VARCHAR(75),
					reg_date DATE
				);

DROP TABLE IF EXISTS issued_status
CREATE TABLE issued_status
				(
					issued_id VARCHAR(10) PRIMARY KEY,
					issued_member_id VARCHAR(15), --FK
					issued_book_name VARCHAR(75), 
					issued_date DATE,
					issued_book_isbn VARCHAR(20), --FK
					issued_emp_id VARCHAR(10) --FK
				);


DROP TABLE IF EXISTS return_status
CREATE TABLE return_status
				(
					return_id VARCHAR(10) PRIMARY KEY,
					issued_id VARCHAR(10), --FK
					return_book_name VARCHAR(75),
					return_date DATE,
					return_book_isbn VARCHAR(20) --FK
				);			

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);


ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);


ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103'
SELECT * FROM members;

UPDATE members
SET member_address = '245 Jordan St'
WHERE member_name ='John'
SELECT * FROM members;

```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
--Objective: Delete the record with issued_book_name = 'Dune'

```sql
 DELETE FROM issued_status
 WHERE   issued_id =   'IS121';

 DELETE FROM issued_status
 WHERE issued_book_name = 'Dune'
 SELECT * FROM issued_status;
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT issued_emp_id, COUNT(*) AS issued_books
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
SELECT 
    b.isbn, 
    b.book_title, 
    COUNT(ist.issued_id) AS no_of_issued
INTO book_cnts
FROM books b
JOIN issued_status ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT b.category,SUM(b.rental_price) AS total_income, COUNT(*) 
FROM books b
JOIN issued_status ist
ON b.isbn = ist.issued_book_isbn
GROUP BY category;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >=  GETDATE() - 180;
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT e1.emp_id, e1.emp_name, e1.position, e1.salary,
       b.*, e2.emp_name as manager
FROM employees as e1
JOIN branch as b
ON e1.branch_id = b.branch_id    
JOIN employees as e2
ON e2.emp_id = b.manager_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT *
FROM issued_status i
LEFT JOIN return_status  r
ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT * FROM books
SELECT * FROM members

SELECT  ist.issued_member_id, m.member_name, bk.book_title, ist.issued_date,
    DATEDIFF(DAY, ist.issued_date, GETDATE()) AS over_due_days
FROM  issued_status  ist
JOIN members  m 
ON m.member_id = ist.issued_member_id
JOIN books  bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status  r
ON r.issued_id = ist.issued_id
WHERE 
    r.return_date IS NULL
    AND DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30
ORDER BY 
    ist.issued_member_id;
   
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

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

```

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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

```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
SELECT * 
INTO active_members 
FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE issued_date >= DATEADD(MONTH, -2, GETDATE())
                    );
SELECT * FROM active_members;

```

**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql

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

```

**Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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

```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/najirh/Library-System-Management---P2.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Zero Analyst

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:

- **YouTube**: [Subscribe to my channel for tutorials and insights](https://www.youtube.com/@zero_analyst)
- **Instagram**: [Follow me for daily tips and updates](https://www.instagram.com/zero_analyst/)
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/najirr)
- **Discord**: [Join our community for learning and collaboration](https://discord.gg/36h5f2Z5PK)

Thank you for your interest in this project!
