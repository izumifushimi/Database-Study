-- 上机 3 · 查询、基建统计与选课；MySQL 8.0.16+。
-- 按题块执行；不同数据集使用独立数据库。

-- 教学 1 · 创建五字段教学表
-- 数据集：teaching
-- MySQL 8.0.16+；学号与班级采用字符型以保留编码格式。
CREATE TABLE teaching_students (
  sno VARCHAR(20) PRIMARY KEY,
  sname VARCHAR(40) NOT NULL,
  class_name VARCHAR(30) NOT NULL,
  age INT CHECK(age BETWEEN 0 AND 120),
  dept VARCHAR(40)
);

-- 教学 2 · 插入六条数据
-- 数据集：teaching
INSERT INTO teaching_students(sname,sno,class_name,age,dept) VALUES
('张三','1001','2401',21,'智能系'),
('张46','1002','2401',21,'智能系'),
('张五','1003','2401',21,'智能系'),
('张66','1004','2401',21,'智能系'),
('张2七','1005','2401',21,'智能系'),
('张6','1006','2401',21,'智能系');

-- 教学 3 · 查询含数字姓名
-- 数据集：teaching
SELECT sname,class_name FROM teaching_students WHERE sname REGEXP '[0-9]' ORDER BY sno;

-- 教学 4 · 查询不含数字姓名
-- 数据集：teaching
SELECT * FROM teaching_students WHERE sname NOT REGEXP '[0-9]' ORDER BY sno;

-- 教学 5 · 查询以 6 结尾的姓名
-- 数据集：teaching
SELECT * FROM teaching_students WHERE sname LIKE '%6' ORDER BY sno;

-- 教学 6 · UPDATE 为自己的信息
-- 数据集：teaching
SET @my_student_no='202500000001';
SET @my_name='学习者';
UPDATE teaching_students
SET sname=@my_name,sno=@my_student_no,class_name='智能2501',age=20,dept='智能系'
WHERE sno='1004' AND sname='张66';
SELECT * FROM teaching_students ORDER BY sno;

-- 基建 1 · 建立四表并插入数据
-- 数据集：construction-intro
-- MySQL 8.0.16+；上机 3 的项目、供应商、原材料和供需样例。
CREATE TABLE projects (
  p_number VARCHAR(20) PRIMARY KEY,p_name VARCHAR(60) NOT NULL,
  p_address VARCHAR(100),p_start_time DATE,
  p_state VARCHAR(20) NOT NULL CHECK(p_state IN ('未开始','施工中','已交付'))
);
CREATE TABLE materials (
  m_number VARCHAR(10) PRIMARY KEY,m_name VARCHAR(60) NOT NULL,
  m_category VARCHAR(30),m_price DECIMAL(10,2) NOT NULL CHECK(m_price>=0),
  m_put_place VARCHAR(100),m_put_count INT NOT NULL CHECK(m_put_count>=0)
);
CREATE TABLE suppliers (
  s_number VARCHAR(10) PRIMARY KEY,s_name VARCHAR(60) NOT NULL,
  s_material VARCHAR(10) NOT NULL,
  FOREIGN KEY(s_material) REFERENCES materials(m_number),
  UNIQUE(s_number,s_material)
);
CREATE TABLE provides (
  pr_p_number VARCHAR(20),pr_s_number VARCHAR(10),pr_m_number VARCHAR(10),
  pr_count INT NOT NULL CHECK(pr_count>0),
  PRIMARY KEY(pr_p_number,pr_s_number,pr_m_number),
  FOREIGN KEY(pr_p_number) REFERENCES projects(p_number),
  FOREIGN KEY(pr_s_number,pr_m_number) REFERENCES suppliers(s_number,s_material)
);
INSERT INTO projects VALUES
('PJNO000000001','项目1','南京','2024-01-01','未开始'),
('PJNO000000002','项目2','无锡','2024-02-01','施工中'),
('PJNO000000003','项目3','常州','2024-03-01','已交付');
INSERT INTO materials VALUES
('M001','材料1','类别1',20,'地点1',100),
('M002','材料2','类别2',10,'地点2',200),
('M003','材料3','类别3',30,'地点3',300);
INSERT INTO suppliers VALUES('S001','供应商1','M001'),('S002','供应商2','M002'),('S003','供应商3','M003');
INSERT INTO provides VALUES
('PJNO000000001','S001','M001',50),
('PJNO000000002','S002','M002',40),
('PJNO000000003','S003','M003',30);

-- 基建 2 · 统计各种项目状态数量
-- 数据集：construction-intro
SELECT status_list.project_state,COUNT(p.p_number) AS project_count
FROM (
  SELECT '未开始' AS project_state
  UNION ALL SELECT '施工中'
  UNION ALL SELECT '已交付'
) status_list
LEFT JOIN projects p ON p.p_state=status_list.project_state
GROUP BY status_list.project_state
ORDER BY CASE status_list.project_state
  WHEN '未开始' THEN 1 WHEN '施工中' THEN 2 ELSE 3 END;

-- 基建 3 · 供应数量最多的原材料视图
-- 数据集：construction-intro
CREATE VIEW top_supplied_material_intro AS
SELECT m.*,q.supplied_quantity
FROM materials m
JOIN (
  SELECT pr_m_number,SUM(pr_count) AS supplied_quantity
  FROM provides GROUP BY pr_m_number
) q ON q.pr_m_number=m.m_number
WHERE q.supplied_quantity=(
  SELECT MAX(total_quantity) FROM (
    SELECT SUM(pr_count) AS total_quantity
    FROM provides GROUP BY pr_m_number
  ) totals
);

-- 选课 1 · 内连接与分组
-- 数据集：student-selection
SELECT s.sno,s.sname
FROM students s
INNER JOIN scores sc ON sc.sno=s.sno
INNER JOIN courses c ON c.cno=sc.cno
GROUP BY s.sno,s.sname
HAVING COUNT(DISTINCT c.cno)=(SELECT COUNT(*) FROM courses)
UNION
SELECT s.sno,s.sname FROM students s
WHERE NOT EXISTS (SELECT 1 FROM courses);

-- 选课 2 · 左连接查询全部课程
-- 数据集：student-selection
SELECT s.sno,s.sname
FROM students s
LEFT JOIN scores sc ON sc.sno=s.sno
LEFT JOIN courses c ON c.cno=sc.cno
GROUP BY s.sno,s.sname
HAVING COUNT(DISTINCT c.cno)=(SELECT COUNT(*) FROM courses);
