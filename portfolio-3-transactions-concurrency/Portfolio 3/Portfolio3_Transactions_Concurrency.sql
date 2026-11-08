USE LibraryManagement;
GO

--------------------------------------------------
-- TRANSACTION 1: COMMIT
-- BORROW A BOOK
--------------------------------------------------

BEGIN TRANSACTION;

UPDATE Books
SET available_copies = available_copies - 1
WHERE book_id = 1
AND available_copies > 0;

IF @@ROWCOUNT = 1
BEGIN

    INSERT INTO Loans
    (
        member_id,
        book_id,
        loan_date,
        due_date,
        return_date
    )
    VALUES
    (
        1,
        1,
        CAST(GETDATE() AS DATE),
        DATEADD(DAY, 14, CAST(GETDATE() AS DATE)),
        NULL
    );

    COMMIT TRANSACTION;

    PRINT 'Book borrowed successfully. Transaction committed.';

END
ELSE
BEGIN

    ROLLBACK TRANSACTION;

    PRINT 'Book unavailable. Transaction rolled back.';

END;
GO


--------------------------------------------------
-- TRANSACTION 2: ROLLBACK
--------------------------------------------------

BEGIN TRANSACTION;

UPDATE Books
SET available_copies = 99
WHERE book_id = 2;

SELECT *
FROM Books
WHERE book_id = 2;

ROLLBACK TRANSACTION;

SELECT *
FROM Books
WHERE book_id = 2;
GO


--------------------------------------------------
-- TRANSACTION 3: ISOLATION
-- RUN SESSION A AND SESSION B SEPARATELY
--------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

UPDATE Books
SET available_copies = available_copies
WHERE book_id = 5;

WAITFOR DELAY '00:00:20';

COMMIT TRANSACTION;
GO


--------------------------------------------------
-- CONCURRENCY TEST TABLE
--------------------------------------------------

IF OBJECT_ID('dbo.ConcurrencyTest', 'U') IS NOT NULL
    DROP TABLE dbo.ConcurrencyTest;
GO

CREATE TABLE ConcurrencyTest
(
    book_id INT PRIMARY KEY,
    available_copies INT
);

INSERT INTO ConcurrencyTest
VALUES (1, 3);
GO


--------------------------------------------------
-- CONCURRENCY PROBLEM
-- LOST UPDATE: SESSION A
--------------------------------------------------

BEGIN TRANSACTION;

DECLARE @copiesA INT;

SELECT @copiesA = available_copies
FROM ConcurrencyTest
WHERE book_id = 1;

WAITFOR DELAY '00:00:15';

UPDATE ConcurrencyTest
SET available_copies = @copiesA - 1
WHERE book_id = 1;

COMMIT TRANSACTION;
GO


--------------------------------------------------
-- CONCURRENCY PROBLEM
-- LOST UPDATE: SESSION B
--------------------------------------------------

BEGIN TRANSACTION;

DECLARE @copiesB INT;

SELECT @copiesB = available_copies
FROM ConcurrencyTest
WHERE book_id = 1;

WAITFOR DELAY '00:00:05';

UPDATE ConcurrencyTest
SET available_copies = @copiesB - 1
WHERE book_id = 1;

COMMIT TRANSACTION;
GO


--------------------------------------------------
-- SOLUTION: ATOMIC UPDATE
--------------------------------------------------

UPDATE ConcurrencyTest
SET available_copies = 3
WHERE book_id = 1;

BEGIN TRANSACTION;

UPDATE ConcurrencyTest
SET available_copies = available_copies - 1
WHERE book_id = 1
AND available_copies > 0;

IF @@ROWCOUNT = 1
    COMMIT TRANSACTION;
ELSE
    ROLLBACK TRANSACTION;
GO


--------------------------------------------------
-- FINAL VERIFICATION
--------------------------------------------------

SELECT *
FROM ConcurrencyTest;
GO