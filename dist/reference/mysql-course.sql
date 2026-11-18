-- MySQL 8.0.16+：在新的学习数据库中执行。
SET NAMES utf8mb4;
CREATE TABLE Dept (
  dept VARCHAR(30) PRIMARY KEY, head VARCHAR(40) NOT NULL
);
CREATE TABLE Student (
  sno VARCHAR(8) PRIMARY KEY, sname VARCHAR(40) NOT NULL,
  dept VARCHAR(30) NOT NULL, age INT CHECK(age BETWEEN 0 AND 120),
  FOREIGN KEY(dept) REFERENCES Dept(dept)
);
CREATE TABLE Course (
  cno VARCHAR(4) PRIMARY KEY, cname VARCHAR(60) NOT NULL,
  credit DECIMAL(3,1) NOT NULL CHECK(credit > 0)
);
CREATE TABLE SC (
  sno VARCHAR(8), cno VARCHAR(4), grade DECIMAL(5,2) CHECK(grade BETWEEN 0 AND 100),
  PRIMARY KEY(sno,cno),
  FOREIGN KEY(sno) REFERENCES Student(sno),
  FOREIGN KEY(cno) REFERENCES Course(cno)
);
INSERT INTO Dept VALUES('计算机','系主任A'),('数学','系主任B'),('信息管理','系主任C');
INSERT INTO Student VALUES('S01','林晓','计算机',20),('S02','陈宇','计算机',19),('S03','王宁','数学',21),('S04','周悦','信息管理',20),('S05','许安','数学',18),('S06','沈青','计算机',22);
INSERT INTO Course VALUES('C01','数据库原理',4),('C02','程序设计',3),('C03','离散数学',3),('C04','数据库应用',2);
INSERT INTO SC VALUES('S01','C01',92),('S01','C02',88),('S01','C03',80),('S01','C04',90),('S02','C01',92),('S02','C02',76),('S03','C01',58),('S03','C03',85),('S04','C01',NULL),('S04','C02',82),('S06','C02',95);
SELECT s.sno, s.sname,
       SUM(CASE WHEN sc.grade >= 60 THEN c.credit ELSE 0 END) AS earned_credit
FROM Student s
LEFT JOIN SC sc ON sc.sno = s.sno
LEFT JOIN Course c ON c.cno = sc.cno
GROUP BY s.sno, s.sname;

CREATE VIEW CourseStats AS
SELECT c.cno, c.cname, COUNT(sc.grade) AS graded_count,
       AVG(sc.grade) AS avg_grade
FROM Course c LEFT JOIN SC sc ON sc.cno = c.cno
GROUP BY c.cno, c.cname;

DROP PROCEDURE IF EXISTS print_scores;
DELIMITER //
CREATE PROCEDURE print_scores(IN p_sno VARCHAR(8))
BEGIN
DECLARE done BOOLEAN DEFAULT FALSE;
  DECLARE v_cno VARCHAR(4);
  DECLARE v_grade DECIMAL(5,2);
  DECLARE c_scores CURSOR FOR SELECT cno,grade FROM SC WHERE sno=p_sno ORDER BY cno;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;
  OPEN c_scores;
  read_loop: LOOP
    FETCH c_scores INTO v_cno,v_grade;
    IF done THEN LEAVE read_loop; END IF;
    SELECT v_cno AS cno,COALESCE(CAST(v_grade AS CHAR),'未出分') AS grade;
  END LOOP read_loop;
  CLOSE c_scores;
END //
DELIMITER ;
CALL print_scores('S01');

DROP FUNCTION IF EXISTS course_average;
DELIMITER //
CREATE FUNCTION course_average(p_cno VARCHAR(4))
RETURNS DECIMAL(6,2) READS SQL DATA
BEGIN
DECLARE v_avg DECIMAL(6,2);
  SELECT AVG(grade) INTO v_avg FROM SC WHERE cno = p_cno;
  RETURN v_avg;
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS enroll;
DELIMITER //
CREATE PROCEDURE enroll(IN p_sno VARCHAR(8), IN p_cno VARCHAR(4))
BEGIN
DECLARE EXIT HANDLER FOR 1062
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='该学生已选此课程';
  INSERT INTO SC(sno,cno,grade) VALUES(p_sno,p_cno,NULL);
END //
DELIMITER ;
CREATE TABLE GradeAudit (
  sno VARCHAR(8), cno VARCHAR(4),
  old_grade DECIMAL(5,2), new_grade DECIMAL(5,2), changed_at DATETIME
);
DELIMITER //
CREATE TRIGGER trg_grade_audit
AFTER UPDATE ON SC
FOR EACH ROW
BEGIN
  IF NOT (OLD.grade <=> NEW.grade) THEN
    INSERT INTO GradeAudit(sno,cno,old_grade,new_grade,changed_at)
    VALUES(OLD.sno,OLD.cno,OLD.grade,NEW.grade,NOW());
  END IF;
END //
DELIMITER ;
