---my project on library management system
---1.Creating Tables

CREATE TABLE Authors (
    author_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    birthdate DATE
);

CREATE TABLE Genres (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(100)
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR(255),
    genre_id INT,
    author_id INT,
    published_year INT,
    total_copies INT,
    available_copies INT,
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id),
    FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

CREATE TABLE Members (
    member_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    membership_date DATE
);

CREATE TABLE Borrowing (
    borrow_id INT PRIMARY KEY,
    book_id INT,
    member_id INT,
    borrow_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);
--2.Inserting Data
-- Inserting authors
INSERT INTO Authors (author_id, first_name, last_name, birthdate) VALUES
(1, 'J.K.', 'Rowling', '1965-07-31'),
(2, 'George', 'Orwell', '1903-06-25');

-- Inserting genres
INSERT INTO Genres (genre_id, genre_name) VALUES
(1, 'Fantasy'),
(2, 'Dystopian');

-- Inserting books
INSERT INTO Books (book_id, title, genre_id, author_id, published_year, total_copies, available_copies) VALUES
(1, 'Harry Potter and the Philosopher''s Stone', 1, 1, 1997, 10, 10),
(2, '1984', 2, 2, 1949, 5, 5);

-- Inserting members
INSERT INTO Members (member_id, first_name, last_name, email, phone, membership_date) VALUES
(1, 'John', 'Doe', 'john.doe@example.com', '123-456-7890', '2020-01-15'),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '098-765-4321', '2021-03-22');

-- Inserting borrowing records
INSERT INTO Borrowing (borrow_id, book_id, member_id, borrow_date, return_date) VALUES
(1, 1, 1, '2024-05-01', '2024-05-15'),
(2, 2, 2, '2024-05-10', '2024-05-24');

---3.retrieving data

SELECT Books.title, Genres.genre_name, Authors.first_name + ' ' + Authors.last_name AS author
FROM Books
JOIN Genres ON Books.genre_id = Genres.genre_id
JOIN Authors ON Books.author_id = Authors.author_id;

SELECT Books.title, Borrowing.borrow_date, Borrowing.return_date
FROM Borrowing
JOIN Books ON Borrowing.book_id = Books.book_id
WHERE Borrowing.member_id = 1;

SELECT Members.first_name, Members.last_name, Borrowing.borrow_date, Borrowing.return_date
FROM Borrowing
JOIN Members ON Borrowing.member_id = Members.member_id
WHERE Borrowing.book_id = 1;

SELECT Genres.genre_name, COUNT(Books.book_id) AS book_count
FROM Books
JOIN Genres ON Books.genre_id = Genres.genre_id
GROUP BY Genres.genre_name;

SELECT Members.first_name, Members.last_name, Books.title, Borrowing.borrow_date, Borrowing.return_date
FROM Borrowing
JOIN Books ON Borrowing.book_id = Books.book_id
JOIN Members ON Borrowing.member_id = Members.member_id
WHERE Borrowing.return_date < CAST(GETDATE() AS DATE);

---Advanced features
---triggers
CREATE TRIGGER update_available_copies_on_borrow
ON Borrowing
AFTER INSERT
AS
BEGIN
    UPDATE Books
    SET available_copies = available_copies - 1
    FROM Books
    INNER JOIN inserted ON Books.book_id = inserted.book_id;
END;

CREATE TRIGGER update_available_copies_on_return
ON Borrowing
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE return_date IS NOT NULL)
    BEGIN
        UPDATE Books
        SET available_copies = available_copies + 1
        FROM Books
        INNER JOIN inserted ON Books.book_id = inserted.book_id;
    END
END;

----views
CREATE VIEW book_details AS
SELECT Books.book_id, Books.title, Genres.genre_name, 
       Authors.first_name + ' ' + Authors.last_name AS author, 
       Books.published_year, Books.total_copies, Books.available_copies
FROM Books
JOIN Genres ON Books.genre_id = Genres.genre_id
JOIN Authors ON Books.author_id = Authors.author_id;

CREATE VIEW borrowing_details AS
SELECT Borrowing.borrow_id, Books.title, 
       Members.first_name + ' ' +  Members.last_name AS member_name, 
       Borrowing.borrow_date, Borrowing.return_date
FROM Borrowing
JOIN Books ON Borrowing.book_id = Books.book_id
JOIN Members ON Borrowing.member_id = Members.member_id;

----stored procedures
---Procedure to add a new book
CREATE PROCEDURE add_new_book(
    @p_title VARCHAR(255),
    @p_genre_id INT,
    @p_author_id INT,
    @p_published_year INT, -- Changed to INT
    @p_total_copies INT
)
AS
BEGIN
    INSERT INTO Books (title, genre_id, author_id, published_year, total_copies, available_copies)
    VALUES (@p_title, @p_genre_id, @p_author_id, @p_published_year, @p_total_copies, @p_total_copies);
END;
----Procedure to borrow a book
CREATE PROCEDURE borrow_book(
    @p_book_id INT,
    @p_member_id INT,
    @p_borrow_date DATE
)

AS
BEGIN
    INSERT INTO Borrowing (book_id, member_id, borrow_date, return_date)
    VALUES (@p_book_id, @p_member_id, @p_borrow_date, NULL);
END;

---User-Defined Functions
----Function to get the full name of an author

CREATE FUNCTION get_author_full_name(@p_author_id INT)
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @full_name VARCHAR(255);
    SELECT @full_name = first_name + ' ' + last_name
    FROM Authors
    WHERE author_id = @p_author_id;
    RETURN @full_name;
END;











