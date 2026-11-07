CREATE DATABASE LibraryManagement;
USE LibraryManagement;
GO
CREATE TABLE Members
(
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    registration_date DATE NOT NULL
);
SELECT *
FROM Members;

CREATE TABLE Books
(
    book_id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publication_year SMALLINT NULL,
    category VARCHAR(50) NULL,
    available_copies INT NOT NULL
        CONSTRAINT DF_Books_AvailableCopies DEFAULT 1,

    CONSTRAINT CK_Books_AvailableCopies
        CHECK (available_copies >= 0)
);

CREATE TABLE Loans
(
    loan_id INT IDENTITY(1,1) PRIMARY KEY,

    member_id INT NOT NULL,
    book_id INT NOT NULL,

    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,

    CONSTRAINT FK_Loans_Members
        FOREIGN KEY (member_id)
        REFERENCES Members(member_id),

    CONSTRAINT FK_Loans_Books
        FOREIGN KEY (book_id)
        REFERENCES Books(book_id),

    CONSTRAINT CK_Loans_DueDate
        CHECK (due_date >= loan_date),

    CONSTRAINT CK_Loans_ReturnDate
        CHECK (
            return_date IS NULL
            OR return_date >= loan_date
        )
);
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


INSERT INTO Members
    (first_name, last_name, email, registration_date)
VALUES
    ('Ada', 'Okafor', 'ada@example.com', '2026-09-01'),
    ('Tunde', 'Bello', 'tunde@example.com', '2026-09-02'),
    ('Mary', 'James', 'mary@example.com', '2026-09-03'),
    ('David', 'Cole', 'david@example.com', '2026-09-04'),
    ('Grace', 'Obi', 'grace@example.com', '2026-09-05');

SELECT *
FROM Members;

INSERT INTO Books
    (title, author, publication_year, category, available_copies)
VALUES
    ('Database Systems', 'Thomas Connolly', 2020, 'Technology', 3),
    ('Learning Mathematics', 'Alan Beaulieu', 2020, 'Calculus', 2),
    ('Clean Code', 'Robert Martin', 2008, 'Programming', 4),
    ('The Pragmatic Programmer', 'David Thomas', 2019, 'Programming', 2),
    ('Introduction to Physiotherapy', 'Eunice Okunola', 2022, 'Medicine', 3);
SELECT *
FROM Books;
INSERT INTO Loans
    (member_id, book_id, loan_date, due_date, return_date)
VALUES
    (1, 1, '2026-09-10', '2026-09-24', NULL),
    (2, 2, '2026-09-11', '2026-09-25', NULL),
    (3, 3, '2026-09-12', '2026-09-26', '2026-09-20'),
    (1, 4, '2026-09-13', '2026-09-27', NULL),
    (4, 5, '2026-09-14', '2026-09-28', '2026-09-22'),
    (5, 1, '2026-09-15', '2026-09-29', NULL);
SELECT *
FROM Loans;

SELECT
    L.loan_id,
    M.first_name,
    M.last_name,
    B.title,
    L.loan_date,
    L.due_date,
    L.return_date
FROM Loans AS L
INNER JOIN Members AS M
    ON L.member_id = M.member_id
INNER JOIN Books AS B
    ON L.book_id = B.book_id
ORDER BY L.loan_id;

SELECT
    M.first_name,
    M.last_name,
    B.title,
    L.loan_date,
    L.due_date
FROM Loans AS L
INNER JOIN Members AS M
    ON L.member_id = M.member_id
INNER JOIN Books AS B
    ON L.book_id = B.book_id
WHERE L.return_date IS NULL;