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
