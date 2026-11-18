# MySQL 语法速查

本站的课程、综合案例、上机题和下载脚本统一使用 MySQL 8.0.16+，存储程序以 MySQL 8.4 进行原生验证。

| 任务 | MySQL 写法 |
| --- | --- |
| 字符串与精确小数 | VARCHAR(n)、DECIMAL(p,s) |
| 自动编号 | 整数主键 AUTO_INCREMENT |
| 局部变量 | BEGIN ... END 开头 DECLARE，随后 SET 赋值 |
| 会话变量与输出参数 | CALL get_course_count('S01', @n); SELECT @n; |
| 过程参数 | IN / OUT / INOUT 写在参数名前面 |
| 函数结果 | RETURNS 声明类型，RETURN 表达式返回值 |
| 程序输出 | 过程中 SELECT 结果集；函数 RETURN 一个值 |
| 分支与循环 | IF / ELSEIF / ELSE、LOOP / LEAVE、WHILE、REPEAT |
| 游标结束 | DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE |
| 业务错误 | SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='错误说明' |
| 更新时间 | NOW()，需要同时保存时分秒时使用 DATETIME |
| 触发器新旧值 | OLD.grade、NEW.grade |
| 判断真实变化 | NOT (OLD.grade <=> NEW.grade) |
| 字符串拼接与空值 | CONCAT(...)、COALESCE(...) / IFNULL(...) |
| 删除索引 | DROP INDEX 索引名 ON 表名 |

声明顺序是变量／条件、游标、HANDLER。普通 SELECT ... INTO 返回零行时产生 1329 条件且变量保持原样，返回多行时产生 1172 错误。单独的 COUNT(*) 聚合没有匹配行时仍返回一行 0。

DELIMITER 是 mysql 客户端命令，不是服务器 SQL 语句；通过程序驱动提交 CREATE PROCEDURE 时，应把完整的定义作为一条语句提交。网页代码块按 mysql 客户端可复制执行的形式编写。

MySQL 8.0.16+ 才执行 CHECK 约束；DATE 的当前日期默认值写为 DEFAULT (CURRENT_DATE)。需要保留并列最高值的视图使用 DENSE_RANK。

GitHub Pages 站点本身不运行 MySQL 服务器。浏览器只用 SQLite 内核演示本页通用 SELECT / WITH 查询，不执行 MySQL 存储程序、DDL 或数据修改。完整代码请在 MySQL 客户端或 Workbench 执行。

参考：[MySQL SELECT INTO](https://dev.mysql.com/doc/refman/8.4/en/select-into.html)、[变量与声明](https://dev.mysql.com/doc/refman/8.4/en/declare.html)、[存储程序](https://dev.mysql.com/doc/refman/8.4/en/create-procedure.html)、[游标](https://dev.mysql.com/doc/refman/8.4/en/cursors.html)、[触发器](https://dev.mysql.com/doc/refman/8.4/en/trigger-syntax.html)。
