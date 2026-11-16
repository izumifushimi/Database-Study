-- 上机 6 · 图书借阅与游标：MySQL 8.0.16+
-- 按题块执行；先载入对应数据集，不同数据集使用各自数据库。

-- 1. 1 · 图书借阅建模与约束
-- 数据集：library
-- MySQL 8.0.16+；一次借阅可含多个种类，因此分开借阅事件和明细。
CREATE TABLE books(b_category VARCHAR(30) PRIMARY KEY,b_count INT NOT NULL CHECK(b_count>=0),b_position VARCHAR(60));
CREATE TABLE people(
 p_number VARCHAR(10) PRIMARY KEY,p_name VARCHAR(40) NOT NULL,
 p_sex VARCHAR(2) NOT NULL CHECK(p_sex IN ('男','女')),
 CHECK(CHAR_LENGTH(p_number)=10 AND BINARY LEFT(p_number,4)=BINARY '1901')
);
CREATE TABLE borrow(
 borrow_id INT PRIMARY KEY,p_number VARCHAR(10) NOT NULL,
 borrowed_at DATETIME NOT NULL,due_at DATETIME NOT NULL,returned_at DATETIME,
 borrow_state VARCHAR(6) NOT NULL CHECK(borrow_state IN ('已完成','进行中','未借阅')),
 FOREIGN KEY(p_number) REFERENCES people(p_number),
 CHECK(due_at>=borrowed_at)
);
CREATE TABLE borrow_items(
 borrow_id INT,b_category VARCHAR(30),quantity INT NOT NULL CHECK(quantity>0),
 PRIMARY KEY(borrow_id,b_category),
 FOREIGN KEY(borrow_id) REFERENCES borrow(borrow_id),
 FOREIGN KEY(b_category) REFERENCES books(b_category)
);
INSERT INTO books VALUES('哲学类',20,'位置1'),('社会科学',10,'位置2'),('财经管理',30,'位置3'),('历史地理',5,'位置4'),('文化教育',16,'位置5'),('自然科学',7,'位置6');
INSERT INTO people VALUES('1901000001','学习者','男'),('1901000002','借阅人B','女'),('1901000003','借阅人C','男');
INSERT INTO borrow VALUES(1,'1901000001','2026-11-01 09:00:00','2026-11-17 09:00:00',NULL,'进行中'),(2,'1901000001','2026-10-14 09:00:00','2026-11-05 09:00:00','2026-11-01 10:00:00','已完成'),(3,'1901000002','2026-09-14 09:00:00','2026-09-30 09:00:00','2026-09-28 10:00:00','已完成');
INSERT INTO borrow_items VALUES(1,'哲学类',2),(1,'历史地理',1),(2,'历史地理',1),(3,'历史地理',3),(3,'自然科学',2);


-- 2. 2 · 各种类图书库存
-- 数据集：library
SELECT b_category,b_count,b_position FROM books;

-- 3. 3 · 总借阅次数最多的图书种类
-- 数据集：library
CREATE VIEW top_category_visits AS
SELECT b_category,n
FROM (
  SELECT b.*, DENSE_RANK() OVER(ORDER BY n DESC) AS rnk
  FROM (
    SELECT i.b_category,COUNT(DISTINCT b.borrow_id) AS n
    FROM borrow b JOIN borrow_items i ON i.borrow_id=b.borrow_id
    WHERE b.borrow_state IN ('已完成','进行中') GROUP BY i.b_category
  ) b
) ranked
WHERE rnk = 1;

-- 4. 4 · 总借阅次数最多的借阅人
-- 数据集：library
CREATE VIEW top_reader_visits AS
SELECT p_number,p_name,n
FROM (
  SELECT b.*, DENSE_RANK() OVER(ORDER BY n DESC) AS rnk
  FROM (
    SELECT p.p_number,p.p_name,COUNT(b.borrow_id) AS n
    FROM people p JOIN borrow b ON b.p_number=p.p_number
    WHERE b.borrow_state IN ('已完成','进行中') GROUP BY p.p_number,p.p_name
  ) b
) ranked
WHERE rnk = 1;

-- 5. 5 · 总借阅本数最多的图书种类
-- 数据集：library
CREATE VIEW top_category_books AS
SELECT b_category,n
FROM (
  SELECT b.*, DENSE_RANK() OVER(ORDER BY n DESC) AS rnk
  FROM (
    SELECT i.b_category,SUM(i.quantity) AS n
    FROM borrow b JOIN borrow_items i ON i.borrow_id=b.borrow_id
    WHERE b.borrow_state IN ('已完成','进行中') GROUP BY i.b_category
  ) b
) ranked
WHERE rnk = 1;

-- 6. 6 · 总借阅本数最多的借阅人
-- 数据集：library
CREATE VIEW top_reader_books AS
SELECT p_number,p_name,n
FROM (
  SELECT b.*, DENSE_RANK() OVER(ORDER BY n DESC) AS rnk
  FROM (
    SELECT p.p_number,p.p_name,SUM(i.quantity) AS n
    FROM people p JOIN borrow b ON b.p_number=p.p_number
    JOIN borrow_items i ON i.borrow_id=b.borrow_id
    WHERE b.borrow_state IN ('已完成','进行中') GROUP BY p.p_number,p.p_name
  ) b
) ranked
WHERE rnk = 1;

-- 7. 7 · 单次借阅本数最多的借阅人
-- 数据集：library
CREATE VIEW top_single_reader_books AS
SELECT p_number,p_name,borrow_id,n
FROM (
  SELECT b.*, DENSE_RANK() OVER(ORDER BY n DESC) AS rnk
  FROM (
    SELECT p.p_number,p.p_name,b.borrow_id,SUM(i.quantity) AS n
    FROM people p JOIN borrow b ON b.p_number=p.p_number
    JOIN borrow_items i ON i.borrow_id=b.borrow_id
    WHERE b.borrow_state IN ('已完成','进行中') GROUP BY p.p_number,p.p_name,b.borrow_id
  ) b
) ranked
WHERE rnk = 1;

-- 8. 8 · 单次借阅本数最多的图书种类
-- 数据集：library
CREATE VIEW top_single_category_books AS
SELECT borrow_id,b_category,n
FROM (
  SELECT b.*, DENSE_RANK() OVER(ORDER BY n DESC) AS rnk
  FROM (
    SELECT i.borrow_id,i.b_category,i.quantity AS n
    FROM borrow_items i JOIN borrow b ON b.borrow_id=i.borrow_id
    WHERE b.borrow_state IN ('已完成','进行中')
  ) b
) ranked
WHERE rnk = 1;

-- 9. 9 · 单次借阅种类最多的借阅人
-- 数据集：library
CREATE VIEW top_single_reader_categories AS
SELECT p_number,p_name,borrow_id,n
FROM (
  SELECT b.*, DENSE_RANK() OVER(ORDER BY n DESC) AS rnk
  FROM (
    SELECT p.p_number,p.p_name,b.borrow_id,COUNT(DISTINCT i.b_category) AS n
    FROM people p JOIN borrow b ON b.p_number=p.p_number
    JOIN borrow_items i ON i.borrow_id=b.borrow_id
    WHERE b.borrow_state IN ('已完成','进行中') GROUP BY p.p_number,p.p_name,b.borrow_id
  ) b
) ranked
WHERE rnk = 1;

-- 10. 10 · 自己已完成的借阅
-- 数据集：library
SET @reader_name='学习者';
SELECT p.p_number,p.p_name,b.*,i.b_category,i.quantity
FROM people p JOIN borrow b ON b.p_number=p.p_number
JOIN borrow_items i ON i.borrow_id=b.borrow_id
WHERE p.p_name=@reader_name AND b.borrow_state='已完成';

-- 11. 11 · 包含没有借书的借阅人
-- 数据集：library
SELECT p.*,b.borrow_id,b.borrow_state,i.b_category,i.quantity
FROM people p LEFT JOIN borrow b ON b.p_number=p.p_number
LEFT JOIN borrow_items i ON i.borrow_id=b.borrow_id;

-- 12. 12 · 时间段内借阅记录
-- 数据集：library
SELECT b.*,i.b_category,i.quantity
FROM borrow b JOIN borrow_items i ON i.borrow_id=b.borrow_id
WHERE b.borrowed_at >= '2026-10-01' AND b.borrowed_at < '2026-12-01'
  AND b.borrow_state IN ('已完成','进行中');

-- 13. 13 · 游标检查图书库存
-- 数据集：library
DELIMITER //
CREATE PROCEDURE check_book_stock()
BEGIN
  DECLARE done BOOLEAN DEFAULT FALSE;
  DECLARE v_category VARCHAR(30);
  DECLARE v_count INT;
  DECLARE cur CURSOR FOR SELECT b_category,b_count FROM books;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_category,v_count;
    IF done THEN LEAVE read_loop; END IF;
    IF v_count<3 THEN
      SELECT CONCAT(v_category,'此图书需要补充库存！') AS message;
    END IF;
  END LOOP;
  CLOSE cur;
END //
DELIMITER ;
CALL check_book_stock();

-- 14. 14 · 游标提醒未归还
-- 数据集：library
DELIMITER //
CREATE PROCEDURE check_unreturned()
BEGIN
  DECLARE done BOOLEAN DEFAULT FALSE;
  DECLARE v_category VARCHAR(30);
  DECLARE cur CURSOR FOR SELECT i.b_category FROM borrow b JOIN borrow_items i ON i.borrow_id=b.borrow_id WHERE b.borrow_state='进行中' AND b.returned_at IS NULL;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_category;
    IF done THEN LEAVE read_loop; END IF;
    SELECT CONCAT(v_category,'此图书需要归还！') AS message;
  END LOOP;
  CLOSE cur;
END //
DELIMITER ;
CALL check_unreturned();

-- 15. 15 · 游标提醒距离到期不足一天
-- 数据集：library
DELIMITER //
CREATE PROCEDURE check_due_soon()
BEGIN
  DECLARE done BOOLEAN DEFAULT FALSE;
  DECLARE v_category VARCHAR(30);
  DECLARE cur CURSOR FOR SELECT i.b_category FROM borrow b JOIN borrow_items i ON i.borrow_id=b.borrow_id WHERE b.borrow_state='进行中' AND b.returned_at IS NULL AND b.due_at>NOW() AND b.due_at<NOW()+INTERVAL 1 DAY;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_category;
    IF done THEN LEAVE read_loop; END IF;
    SELECT CONCAT(v_category,'此图书距离归还不到1天！') AS message;
  END LOOP;
  CLOSE cur;
END //
DELIMITER ;
CALL check_due_soon();

-- 16. 16 · 游标检查原材料库存
-- 数据集：construction
DELIMITER //
CREATE PROCEDURE check_material_stock()
BEGIN
  DECLARE done BOOLEAN DEFAULT FALSE;
  DECLARE v_name VARCHAR(60);
  DECLARE v_count INT;
  DECLARE cur CURSOR FOR SELECT m_name,m_put_count FROM materials;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_name,v_count;
    IF done THEN LEAVE read_loop; END IF;
    IF v_count<=2 THEN
      SELECT CONCAT(v_name,'需要补充库存！') AS message;
    END IF;
  END LOOP;
  CLOSE cur;
END //
DELIMITER ;
CALL check_material_stock();
