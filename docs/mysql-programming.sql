-- MySQL 8.0.16+：先执行 mysql-course.sql 建表并插入数据。

-- MySQL 程序块、变量与赋值 / 存储过程中的程序块
DROP PROCEDURE IF EXISTS show_student;
DELIMITER //
CREATE PROCEDURE show_student(IN p_sno VARCHAR(8))
BEGIN
DECLARE v_name VARCHAR(40);
  DECLARE v_found BOOLEAN DEFAULT TRUE;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_found = FALSE;
  SELECT sname INTO v_name FROM Student WHERE sno = p_sno;
  IF v_found THEN
    SELECT v_name AS student_name;
  ELSE
    SELECT '学生不存在' AS message;
  END IF;
END //
DELIMITER ;
CALL show_student('S01');

-- SELECT INTO 与条件处理 / 接收单行结果
DROP PROCEDURE IF EXISTS find_student;
DELIMITER //
CREATE PROCEDURE find_student(IN p_sno VARCHAR(8))
BEGIN
DECLARE v_name VARCHAR(40);
  DECLARE v_age INT;
  DECLARE v_found BOOLEAN DEFAULT TRUE;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_found = FALSE;
  DECLARE EXIT HANDLER FOR 1172
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '查询返回多行';
  SELECT sname, age INTO v_name, v_age FROM Student WHERE sno = p_sno;
  IF v_found THEN
    SELECT v_name AS student_name, v_age AS age;
  ELSE
    SELECT '无此学生' AS message;
  END IF;
END //
DELIMITER ;
CALL find_student('S01');

-- SELECT INTO 与条件处理 / 用 SIGNAL 抛出业务错误
DROP PROCEDURE IF EXISTS validate_grade;
DELIMITER //
CREATE PROCEDURE validate_grade(IN p_grade DECIMAL(5,2))
BEGIN
IF p_grade IS NULL OR p_grade < 0 OR p_grade > 100 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '成绩必须非空且在 0 到 100 之间';
  END IF;
  SELECT '成绩有效' AS message;
END //
DELIMITER ;
CALL validate_grade(85);

-- 分支与 LOOP / WHILE / REPEAT / 成绩分段
DROP PROCEDURE IF EXISTS classify_grade;
DELIMITER //
CREATE PROCEDURE classify_grade(IN p_grade DECIMAL(5,2))
BEGIN
DECLARE v_label VARCHAR(10);
  IF p_grade IS NULL THEN SET v_label = '未出分';
  ELSEIF p_grade >= 90 THEN SET v_label = '优秀';
  ELSEIF p_grade >= 60 THEN SET v_label = '及格';
  ELSE SET v_label = '不及格';
  END IF;
  SELECT v_label AS grade_label;
END //
DELIMITER ;
CALL classify_grade(92);

-- 分支与 LOOP / WHILE / REPEAT / 三种循环的完整示例
DROP PROCEDURE IF EXISTS loop_demo;
DELIMITER //
CREATE PROCEDURE loop_demo()
BEGIN
DECLARE v_i INT DEFAULT 0;
  count_loop: LOOP
    SET v_i = v_i + 1;
    IF v_i >= 10 THEN LEAVE count_loop; END IF;
  END LOOP count_loop;
  SELECT v_i AS loop_result;
  SET v_i = 0;
  WHILE v_i < 10 DO
    SET v_i = v_i + 1;
  END WHILE;
  SELECT v_i AS while_result;
  SET v_i = 0;
  REPEAT
    SET v_i = v_i + 1;
  UNTIL v_i >= 10 END REPEAT;
  SELECT v_i AS repeat_result;
END //
DELIMITER ;
CALL loop_demo();

-- MySQL 游标与结束条件 / 游标的完整生命周期
DROP PROCEDURE IF EXISTS print_course_scores;
DELIMITER //
CREATE PROCEDURE print_course_scores(IN p_cno VARCHAR(4))
BEGIN
DECLARE done BOOLEAN DEFAULT FALSE;
  DECLARE v_sno VARCHAR(8);
  DECLARE v_grade DECIMAL(5,2);
  DECLARE c_scores CURSOR FOR
    SELECT sno, grade FROM SC WHERE cno = p_cno ORDER BY sno;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN c_scores;
  read_loop: LOOP
    FETCH c_scores INTO v_sno, v_grade;
    IF done THEN LEAVE read_loop; END IF;
    SELECT v_sno AS sno, v_grade AS grade;
  END LOOP read_loop;
  CLOSE c_scores;
END //
DELIMITER ;
CALL print_course_scores('C01');

-- 存储过程与 IN / OUT 参数 / 通过 OUT 参数返回数量
DROP PROCEDURE IF EXISTS get_course_count;
DELIMITER //
CREATE PROCEDURE get_course_count(IN p_sno VARCHAR(8), OUT p_count INT)
BEGIN
SELECT COUNT(*) INTO p_count FROM SC WHERE sno = p_sno;
END //
DELIMITER ;
CALL get_course_count('S01', @course_count);
SELECT @course_count AS course_count;

-- 存储函数与返回值 / 返回课程平均成绩
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
SELECT course_average('C01') AS avg_grade;

-- MySQL 触发器、OLD / NEW 与审计 / 记录成绩变化
DROP TRIGGER IF EXISTS trg_grade_audit;
DROP TABLE IF EXISTS GradeAudit;
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
