-- MySQL 8.0.16+；使用新的学习数据库。
SET NAMES utf8mb4;
CREATE TABLE Student (sno VARCHAR(8) PRIMARY KEY NOT NULL, sname VARCHAR(40) NOT NULL, dept VARCHAR(30), age INT CHECK(age BETWEEN 0 AND 120));
CREATE TABLE Course (cno VARCHAR(4) PRIMARY KEY NOT NULL, cname VARCHAR(60) NOT NULL, credit DECIMAL(3,1) NOT NULL CHECK(credit>0), pcno VARCHAR(4), FOREIGN KEY(pcno) REFERENCES Course(cno));
CREATE TABLE SC (sno VARCHAR(8) NOT NULL, cno VARCHAR(4) NOT NULL, grade DECIMAL(5,2) CHECK(grade BETWEEN 0 AND 100), PRIMARY KEY(sno,cno), FOREIGN KEY(sno) REFERENCES Student(sno), FOREIGN KEY(cno) REFERENCES Course(cno));
INSERT INTO Student VALUES ('S01','林晓','计算机',20),('S02','陈宇','计算机',19),('S03','王宁','数学',21),('S04','周悦','信息管理',20),('S05','许安','数学',18),('S06','沈青','计算机',22);
INSERT INTO Course VALUES ('C01','数据库原理',4,NULL),('C02','程序设计',3,NULL),('C03','离散数学',3,NULL),('C04','数据库应用',2,'C01');
INSERT INTO SC VALUES ('S01','C01',92),('S01','C02',88),('S01','C03',80),('S01','C04',90),('S02','C01',92),('S02','C02',76),('S03','C01',58),('S03','C03',85),('S04','C01',NULL),('S04','C02',82),('S06','C02',95);

-- 01 · 单表筛选
-- 查询计算机系且年龄小于 21 岁的学生，输出 sno、sname、age。
SELECT sno,sname,age FROM Student WHERE dept='计算机' AND age<21;

-- 02 · 三表连接
-- 查询所有已有选课记录的学生姓名、课程名、成绩，输出 sname、cname、grade。
SELECT s.sname,c.cname,sc.grade FROM Student s JOIN SC sc ON sc.sno=s.sno JOIN Course c ON c.cno=sc.cno;

-- 03 · 分组与 HAVING
-- 查询已出分人数至少为 2 的课程，输出 cno、graded_count（非空成绩人数）。
SELECT cno,COUNT(grade) AS graded_count FROM SC GROUP BY cno HAVING COUNT(grade)>=2;

-- 04 · 并列最高分
-- 查询数据库原理（C01）的所有最高分学生，输出 sno、grade。
SELECT sno,grade FROM SC WHERE cno='C01' AND grade=(SELECT MAX(grade) FROM SC WHERE cno='C01');

-- 05 · 没有选课的学生
-- 查询一门课也没选的学生，输出 sno、sname。
SELECT s.sno,s.sname FROM Student s WHERE NOT EXISTS(SELECT 1 FROM SC sc WHERE sc.sno=s.sno);

-- 06 · 选修全部课程
-- 查询选齐 Course 中全部课程的学生，输出 sno、sname。
SELECT s.sno,s.sname FROM Student s WHERE NOT EXISTS(SELECT 1 FROM Course c WHERE NOT EXISTS(SELECT 1 FROM SC sc WHERE sc.sno=s.sno AND sc.cno=c.cno));

-- 07 · 左连接与空值
-- 查询所有学生及其 C01 成绩，输出 sno、sname、grade，未选 C01 的学生也必须出现。
SELECT s.sno,s.sname,sc.grade FROM Student s LEFT JOIN SC sc ON sc.sno=s.sno AND sc.cno='C01';

-- 08 · 高于本课程均分
-- 查询成绩高于所选课程平均分的选课记录，输出 sno、cno、grade。
SELECT sc.sno,sc.cno,sc.grade FROM SC sc WHERE sc.grade>(SELECT AVG(t.grade) FROM SC t WHERE t.cno=sc.cno);

-- 09 · 学分汇总
-- 查询所有学生已经获得的总学分，60 分及以上获得课程学分，未获得学分的学生计 0。输出 sno、earned_credit。
SELECT s.sno,COALESCE(SUM(CASE WHEN sc.grade>=60 THEN c.credit ELSE 0 END),0) AS earned_credit FROM Student s LEFT JOIN SC sc ON sc.sno=s.sno LEFT JOIN Course c ON c.cno=sc.cno GROUP BY s.sno;

-- 10 · 多字段排序
-- 查询已出分的 C01 成绩，输出 sno、grade，按成绩降序，再按学号升序。
SELECT sno,grade FROM SC WHERE cno='C01' AND grade IS NOT NULL ORDER BY grade DESC,sno ASC;
