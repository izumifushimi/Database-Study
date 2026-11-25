-- MySQL 8.0.16+；“选修全部课程”练习，未出分仍算已选修。
CREATE TABLE students (
  sno VARCHAR(20) PRIMARY KEY,sname VARCHAR(40) NOT NULL,
  age INT CHECK(age BETWEEN 0 AND 120),
  sex VARCHAR(2) CHECK(sex IN ('男','女')),birth_date DATE
);
CREATE TABLE courses (
  cno VARCHAR(10) PRIMARY KEY,cname VARCHAR(60) NOT NULL,teacher VARCHAR(40)
);
CREATE TABLE scores (
  sno VARCHAR(20),cno VARCHAR(10),grade DECIMAL(5,2) CHECK(grade BETWEEN 0 AND 100),
  PRIMARY KEY(sno,cno),
  FOREIGN KEY(sno) REFERENCES students(sno),FOREIGN KEY(cno) REFERENCES courses(cno)
);
INSERT INTO students VALUES
('S01','学生A',20,'男','2006-01-01'),('S02','学生B',21,'女','2005-02-01'),
('S03','学生C',20,'男','2006-03-01'),('S04','学生D',22,'女','2004-04-01');
INSERT INTO courses VALUES('C01','数据库原理','教师A'),('C02','程序设计','教师B'),('C03','离散数学','教师C');
INSERT INTO scores VALUES
('S01','C01',90),('S01','C02',80),('S01','C03',NULL),('S02','C01',75),
('S04','C01',85),('S04','C02',90),('S04','C03',88);
