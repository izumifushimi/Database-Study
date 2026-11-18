-- MySQL 8.0.16+；使用新的学习数据库。
CREATE TABLE Department(dno VARCHAR(8) PRIMARY KEY,dname VARCHAR(60));
CREATE TABLE Employee(eno VARCHAR(8) PRIMARY KEY,ename VARCHAR(40),dno VARCHAR(8) NOT NULL,salary DECIMAL(12,2) NOT NULL CHECK(salary>=0),FOREIGN KEY(dno) REFERENCES Department(dno));
INSERT INTO Department VALUES('D01','技术部'),('D02','行政部');
INSERT INTO Employee VALUES('E01','员工A','D01',1000),('E02','员工B','D01',2000);
DROP PROCEDURE IF EXISTS raise_salary;
DELIMITER //
CREATE PROCEDURE raise_salary(IN p_dno VARCHAR(8), IN p_rate DECIMAL(6,4))
BEGIN
DECLARE v_changed INT;
  IF p_rate IS NULL OR p_rate<0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='加薪比例必须非空且非负';
  END IF;
  UPDATE Employee SET salary=ROUND(salary*(1+p_rate),2) WHERE dno=p_dno;
  SET v_changed=ROW_COUNT();
  SELECT v_changed AS changed_rows;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS avg_salary;
DELIMITER //
CREATE FUNCTION avg_salary(p_dno VARCHAR(8))
RETURNS DECIMAL(12,2) READS SQL DATA
BEGIN
DECLARE v_avg DECIMAL(12,2);
  SELECT AVG(salary) INTO v_avg FROM Employee WHERE dno=p_dno;
  RETURN v_avg;
END //
DELIMITER ;

CREATE TABLE SalaryAudit (
  eno VARCHAR(8), old_salary DECIMAL(12,2),
  new_salary DECIMAL(12,2), changed_at DATETIME
);
DELIMITER //
CREATE TRIGGER trg_salary_audit
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
  IF NOT (OLD.salary <=> NEW.salary) THEN
    INSERT INTO SalaryAudit(eno,old_salary,new_salary,changed_at)
    VALUES(NEW.eno,OLD.salary,NEW.salary,NOW());
  END IF;
END //
DELIMITER ;
