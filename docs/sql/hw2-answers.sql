-- 上机 2 · 教学表填充与查询；MySQL 8.0.16+。
-- 按题块执行；不同数据集使用独立数据库。

-- 1 · 创建教学表
-- 数据集：teaching
-- MySQL 8.0.16+；学号与班级采用字符型以保留编码格式。
CREATE TABLE teaching_students (
  sno VARCHAR(20) PRIMARY KEY,
  sname VARCHAR(40) NOT NULL,
  class_name VARCHAR(30) NOT NULL,
  age INT CHECK(age BETWEEN 0 AND 120),
  dept VARCHAR(40)
);

-- 2 · 填入六条样例数据
-- 数据集：teaching
INSERT INTO teaching_students(sname,sno,class_name,age,dept) VALUES
('张三','1001','2401',21,'智能系'),
('张46','1002','2401',21,'智能系'),
('张五','1003','2401',21,'智能系'),
('张66','1004','2401',21,'智能系'),
('张2七','1005','2401',21,'智能系'),
('张6','1006','2401',21,'智能系');

-- 3 · 显示表结构和数据
-- 数据集：teaching
DESCRIBE teaching_students;
SELECT * FROM teaching_students ORDER BY sno;

-- 4 · 删除年龄列
-- 数据集：teaching
ALTER TABLE teaching_students DROP COLUMN age;
DESCRIBE teaching_students;

-- 5 · 插入自己的信息
-- 数据集：teaching
SET @my_student_no='202500000001';
SET @my_name='学习者';
INSERT INTO teaching_students(sname,sno,class_name,dept)
VALUES(@my_name,@my_student_no,'智能2501','智能系');
SELECT * FROM teaching_students WHERE sno=@my_student_no;

-- 6 · 姓名中存在数字
-- 数据集：teaching
SELECT sname,class_name FROM teaching_students
WHERE sname REGEXP '[0-9]'
ORDER BY sno;

-- 7 · 姓名中不存在数字
-- 数据集：teaching
SELECT * FROM teaching_students
WHERE sname NOT REGEXP '[0-9]'
ORDER BY sno;

-- 8 · 姓名以 6 结尾
-- 数据集：teaching
SELECT * FROM teaching_students
WHERE sname LIKE '%6'
ORDER BY sno;
