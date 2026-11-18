CREATE TABLE Student (sno VARCHAR(8) PRIMARY KEY NOT NULL, sname VARCHAR(40) NOT NULL, dept VARCHAR(30), age INT CHECK(age BETWEEN 0 AND 120));
CREATE TABLE Course (cno VARCHAR(4) PRIMARY KEY NOT NULL, cname VARCHAR(60) NOT NULL, credit DECIMAL(3,1) NOT NULL CHECK(credit>0), pcno VARCHAR(4), FOREIGN KEY(pcno) REFERENCES Course(cno));
CREATE TABLE SC (sno VARCHAR(8) NOT NULL, cno VARCHAR(4) NOT NULL, grade DECIMAL(5,2) CHECK(grade BETWEEN 0 AND 100), PRIMARY KEY(sno,cno), FOREIGN KEY(sno) REFERENCES Student(sno), FOREIGN KEY(cno) REFERENCES Course(cno));
INSERT INTO Student VALUES ('S01','林晓','计算机',20),('S02','陈宇','计算机',19),('S03','王宁','数学',21),('S04','周悦','信息管理',20),('S05','许安','数学',18),('S06','沈青','计算机',22);
INSERT INTO Course VALUES ('C01','数据库原理',4,NULL),('C02','程序设计',3,NULL),('C03','离散数学',3,NULL),('C04','数据库应用',2,'C01');
INSERT INTO SC VALUES ('S01','C01',92),('S01','C02',88),('S01','C03',80),('S01','C04',90),('S02','C01',92),('S02','C02',76),('S03','C01',58),('S03','C03',85),('S04','C01',NULL),('S04','C02',82),('S06','C02',95);
