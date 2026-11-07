USE LibraryManagement;
GO
-- QUERY 1: Display all books
SELECT *
FROM Books;

SELECT *
FROM Members;

-- QUERY 3: Find all books that have not been returned
SELECT
    loan_id,
    member_id,
    book_id,
    loan_date,
    due_date,
    return_date
FROM Loans
WHERE return_date IS NULL;

-- QUERY 4: Find overdue books
SELECT
    loan_id,
    member_id,
    book_id,
    loan_date,
    due_date
FROM Loans
WHERE due_date < CAST(GETDATE() AS DATE)
AND return_date IS NULL;

-- QUERY 5: Display loan details with member names and book titles

SELECT
    Loans.loan_id,
    Members.first_name,
    Members.last_name,
    Books.title,
    Loans.loan_date,
    Loans.due_date,
    Loans.return_date
FROM Loans

INNER JOIN Members
ON Loans.member_id = Members.member_id

INNER JOIN Books
ON Loans.book_id = Books.book_id;

-- QUERY 6: Count the number of loans per member

SELECT
    Members.member_id,
    Members.first_name,
    Members.last_name,
    COUNT(Loans.loan_id) AS Total_Books_Borrowed

FROM Members

LEFT JOIN Loans
ON Members.member_id = Loans.member_id

GROUP BY
    Members.member_id,
    Members.first_name,
    Members.last_name

ORDER BY Total_Books_Borrowed DESC;

-- QUERY 7: Find the most borrowed books
SELECT
    Books.book_id,
    Books.title,
    COUNT(Loans.loan_id) AS Total_Times_Borrowed

FROM Books

LEFT JOIN Loans
ON Books.book_id = Loans.book_id

GROUP BY
    Books.book_id,
    Books.title

ORDER BY Total_Times_Borrowed DESC;

