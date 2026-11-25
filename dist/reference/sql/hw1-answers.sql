-- 上机 1 · 科研管理建表；MySQL 8.0.16+。
-- 按题块执行；不同数据集使用独立数据库。

-- 1 · 创建科研管理表
-- 数据集：research
-- MySQL 8.0.16+；在独立学习数据库中执行。
-- 每名科研人员和每个项目归属一个研究所；参与项目通过关联表记录工作量。
CREATE TABLE institutes (
  institute_id VARCHAR(10) PRIMARY KEY,
  institute_name VARCHAR(60) NOT NULL,
  address VARCHAR(100)
);
CREATE TABLE research_staff (
  staff_id VARCHAR(20) PRIMARY KEY,
  staff_name VARCHAR(40) NOT NULL,
  sex VARCHAR(2) CHECK(sex IN ('男','女')),
  age INT CHECK(age BETWEEN 0 AND 120),
  title VARCHAR(30),
  institute_id VARCHAR(10) NOT NULL,
  FOREIGN KEY(institute_id) REFERENCES institutes(institute_id)
);
CREATE TABLE research_projects (
  project_id VARCHAR(10) PRIMARY KEY,
  project_name VARCHAR(80) NOT NULL,
  funding DECIMAL(12,2) NOT NULL CHECK(funding>=0),
  institute_id VARCHAR(10) NOT NULL,
  FOREIGN KEY(institute_id) REFERENCES institutes(institute_id)
);
CREATE TABLE research_participation (
  staff_id VARCHAR(20),
  project_id VARCHAR(10),
  workload DECIMAL(8,2) NOT NULL CHECK(workload>=0),
  PRIMARY KEY(staff_id,project_id),
  FOREIGN KEY(staff_id) REFERENCES research_staff(staff_id),
  FOREIGN KEY(project_id) REFERENCES research_projects(project_id)
);
INSERT INTO institutes VALUES('I01','研究所一','南京'),('I02','研究所二','苏州');
INSERT INTO research_staff VALUES('R001','研究员A','男',30,'助理研究员','I01'),('R002','研究员B','女',35,'研究员','I02');
INSERT INTO research_projects VALUES('P001','课题一',100000,'I01'),('P002','课题二',200000,'I02');
INSERT INTO research_participation VALUES('R001','P001',20),('R001','P002',10),('R002','P002',30);

-- 2 · 插入自己的科研人员信息
-- 数据集：research
SET @my_student_no='202500000001';
SET @my_name='学习者';
INSERT INTO research_staff(staff_id,staff_name,sex,age,title,institute_id)
VALUES(@my_student_no,@my_name,'男',20,'学生','I01');
SELECT * FROM research_staff WHERE staff_id=@my_student_no;

-- 3 · 删除年龄属性
-- 数据集：research
ALTER TABLE research_staff DROP COLUMN age;
DESCRIBE research_staff;
