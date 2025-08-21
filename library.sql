-- ================================================================
-- Library Management System Schema
-- At most 9 tables with PK, FK, NOT NULL, UNIQUE constraints
-- ================================================================

-- 1. Members
CREATE TABLE members (
    member_id      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    full_name      VARCHAR(150) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    phone          VARCHAR(30) UNIQUE,
    join_date      DATE NOT NULL DEFAULT (CURRENT_DATE),
    status         ENUM('Active','Inactive') NOT NULL DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Staff
CREATE TABLE staff (
    staff_id       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    full_name      VARCHAR(150) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    role           ENUM('Librarian','Assistant','Admin') NOT NULL,
    hire_date      DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Authors
CREATE TABLE authors (
    author_id      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name           VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Publishers
CREATE TABLE publishers (
    publisher_id   BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name           VARCHAR(150) NOT NULL UNIQUE,
    country        VARCHAR(100) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Books
CREATE TABLE books (
    book_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    title          VARCHAR(200) NOT NULL,
    isbn           VARCHAR(20) NOT NULL UNIQUE,
    publisher_id   BIGINT UNSIGNED NULL,
    year_published YEAR NULL,
    category       VARCHAR(100) NULL,
    total_copies   INT UNSIGNED NOT NULL CHECK (total_copies > 0),
    available_copies INT UNSIGNED NOT NULL,
    CONSTRAINT fk_books_publisher
        FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Book ↔ Authors (Many-to-Many)
CREATE TABLE book_authors (
    book_id        BIGINT UNSIGNED NOT NULL,
    author_id      BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book
        FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ba_author
        FOREIGN KEY (author_id) REFERENCES authors(author_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Loans
CREATE TABLE loans (
    loan_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    member_id      BIGINT UNSIGNED NOT NULL,
    book_id        BIGINT UNSIGNED NOT NULL,
    staff_id       BIGINT UNSIGNED NOT NULL, -- issued by
    loan_date      DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date       DATE NOT NULL,
    return_date    DATE NULL,
    status         ENUM('OnLoan','Returned','Overdue') NOT NULL DEFAULT 'OnLoan',
    CONSTRAINT fk_loans_member
        FOREIGN KEY (member_id) REFERENCES members(member_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_loans_book
        FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_loans_staff
        FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Reservations
CREATE TABLE reservations (
    reservation_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    member_id      BIGINT UNSIGNED NOT NULL,
    book_id        BIGINT UNSIGNED NOT NULL,
    reserved_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status         ENUM('Active','Cancelled','Fulfilled') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_res_member
        FOREIGN KEY (member_id) REFERENCES members(member_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_res_book
        FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Fines
CREATE TABLE fines (
    fine_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    loan_id        BIGINT UNSIGNED NOT NULL,
    amount         DECIMAL(8,2) NOT NULL CHECK (amount > 0),
    paid           BOOLEAN NOT NULL DEFAULT FALSE,
    issued_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at        DATETIME NULL,
    CONSTRAINT fk_fines_loan
        FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

