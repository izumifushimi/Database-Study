-- MySQL 8.0.16+；学号与班级采用字符型以保留编码格式。
CREATE TABLE teaching_students (
  sno VARCHAR(20) PRIMARY KEY,
  sname VARCHAR(40) NOT NULL,
  class_name VARCHAR(30) NOT NULL,
  age INT CHECK(age BETWEEN 0 AND 120),
  dept VARCHAR(40)
);
INSERT INTO teaching_students(sname,sno,class_name,age,dept) VALUES
('张三','1001','2401',21,'智能系'),
('张46','1002','2401',21,'智能系'),
('张五','1003','2401',21,'智能系'),
('张66','1004','2401',21,'智能系'),
('张2七','1005','2401',21,'智能系'),
('张6','1006','2401',21,'智能系');
