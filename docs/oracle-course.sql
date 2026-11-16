-- Oracle 综合案例，使用新的学习模式。先建表，再按需执行程序。


CREATE TABLE Dept (
  dept VARCHAR2(30) PRIMARY KEY,
  head VARCHAR2(40) NOT NULL
);
CREATE TABLE Student (
  sno VARCHAR2(8) PRIMARY KEY,
  sname VARCHAR2(40) NOT NULL,
  dept VARCHAR2(30) NOT NULL REFERENCES Dept(dept),
  age NUMBER(3) CHECK(age BETWEEN 0 AND 120)
);
CREATE TABLE Course (
  cno VARCHAR2(4) PRIMARY KEY,
  cname VARCHAR2(60) NOT NULL,
  credit NUMBER(3,1) NOT NULL CHECK(credit > 0)
);
CREATE TABLE SC (
  sno VARCHAR2(8) REFERENCES Student(sno),
  cno VARCHAR2(4) REFERENCES Course(cno),
  grade NUMBER(5,2) CHECK(grade BETWEEN 0 AND 100),
  PRIMARY KEY(sno,cno)
);

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

CREATE OR REPLACE PROCEDURE print_scores (
  p_sno IN Student.sno%TYPE
) AS
  CURSOR c_scores(v_sno Student.sno%TYPE) IS
    SELECT cno, grade FROM SC WHERE sno = v_sno ORDER BY cno;
BEGIN
  FOR r IN c_scores(p_sno) LOOP
    DBMS_OUTPUT.PUT_LINE(r.cno || ':' ||
      NVL(TO_CHAR(r.grade), '未出分'));
  END LOOP;
END;
/

CREATE OR REPLACE FUNCTION course_average (
  p_cno IN Course.cno%TYPE
) RETURN NUMBER AS
  v_avg NUMBER;
BEGIN
  SELECT AVG(grade) INTO v_avg FROM SC WHERE cno = p_cno;
  RETURN v_avg;
END;
/
CREATE OR REPLACE PROCEDURE enroll (
  p_sno IN Student.sno%TYPE,
  p_cno IN Course.cno%TYPE
) AS
BEGIN
  INSERT INTO SC(sno,cno,grade) VALUES(p_sno,p_cno,NULL);
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20002,'该学生已选此课程');
END;
/