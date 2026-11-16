# 数据库方言速查

课程 PL/SQL 与综合案例采用 Oracle；上机 4–8 的参考解法采用 MySQL 8.0.16+；网页实验采用 sql.js / SQLite。

| 功能 | Oracle | MySQL 8 | SQLite 实验区 |
| --- | --- | --- | --- |
| 可变长文本 | VARCHAR2(n) | VARCHAR(n) | TEXT |
| 数值 | NUMBER(p,s) | DECIMAL(p,s) | INTEGER / REAL |
| 自增标识 | 标识列或序列，取决于版本 | AUTO_INCREMENT | INTEGER PRIMARY KEY |
| 空值替换 | NVL / COALESCE | IFNULL / COALESCE | IFNULL / COALESCE |
| 字符串连接 | a \|\| b | CONCAT(a,b) | a \|\| b |
| 集合差 | 传统课程用 MINUS | 版本支持有差异 | EXCEPT |
| 存储程序 | PL/SQL，IS/AS、EXCEPTION | BEGIN/END、DECLARE HANDLER | 不运行 Oracle / MySQL 存储程序 |
| 日期字面量 | DATE '2026-11-16' | '2026-11-16' | 日期通常以 ISO 文本表示 |
| 分隔符 | / 为部分客户端提交块的命令 | DELIMITER 为客户端命令 | 不使用 |

上机脚本要求 MySQL 8.0.16+：CHECK 约束在该版本及以后才真正执行；DATE 的表达式默认值写为 DEFAULT (CURRENT_DATE)。需要窗口函数的最高值视图采用 DENSE_RANK，保留所有并列第一。

函数返回多条信息时要明确返回机制。MySQL 函数不能直接返回普通多行 SELECT 结果集，本网站示例返回 JSON 数组。MySQL 服务器的权限、二进制日志策略可能对创建存储函数有额外要求，应按所在实验环境配置。

参考：[MySQL 变量与声明](https://dev.mysql.com/doc/refman/8.4/en/declare.html)、[MySQL 存储程序](https://dev.mysql.com/doc/refman/8.4/en/create-procedure.html)、[MySQL 默认值](https://dev.mysql.com/doc/refman/8.4/en/data-type-defaults.html)、[Oracle 查询结果](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/processing-query-result-sets.html)、[SQLite SELECT](https://www.sqlite.org/lang_select.html)。
