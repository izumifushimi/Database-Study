-- MySQL 8.0.16+；使用新的学习数据库。
CREATE TABLE Book(isbn VARCHAR(20) PRIMARY KEY,title VARCHAR(100) NOT NULL,publisher VARCHAR(60));
CREATE TABLE Copy(copy_id INT PRIMARY KEY,isbn VARCHAR(20) NOT NULL,FOREIGN KEY(isbn) REFERENCES Book(isbn));
CREATE TABLE Reader(reader_id INT PRIMARY KEY,name VARCHAR(40) NOT NULL);
CREATE TABLE Loan(loan_id INT PRIMARY KEY,reader_id INT NOT NULL,copy_id INT NOT NULL,borrowed_at DATETIME NOT NULL,due_at DATETIME NOT NULL,returned_at DATETIME,FOREIGN KEY(reader_id) REFERENCES Reader(reader_id),FOREIGN KEY(copy_id) REFERENCES Copy(copy_id));
INSERT INTO Book VALUES('B001','数据库原理','学习出版社');
INSERT INTO Copy VALUES(1,'B001');
INSERT INTO Reader VALUES(1,'读者A'),(2,'读者B');
INSERT INTO Loan VALUES(1,1,1,'2026-11-01','2026-11-10',NULL);
SELECT r.name, b.title, l.due_at
FROM Loan l
JOIN Reader r ON r.reader_id = l.reader_id
JOIN Copy cp ON cp.copy_id = l.copy_id
JOIN Book b ON b.isbn = cp.isbn
WHERE l.returned_at IS NULL
  AND l.due_at < '2026-11-16';

SELECT r.reader_id, r.name, COUNT(l.loan_id) AS active_count
FROM Reader r
LEFT JOIN Loan l ON l.reader_id = r.reader_id
 AND l.returned_at IS NULL
GROUP BY r.reader_id, r.name;

DROP PROCEDURE IF EXISTS return_copy;
DELIMITER //
CREATE PROCEDURE return_copy(IN p_loan_id INT)
BEGIN
UPDATE Loan SET returned_at=NOW()
  WHERE loan_id=p_loan_id AND returned_at IS NULL;
  IF ROW_COUNT()=0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='借阅记录不存在或已经归还';
  END IF;
END //
DELIMITER ;
