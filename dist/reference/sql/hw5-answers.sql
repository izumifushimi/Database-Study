-- 上机 5 · 销售管理系统：MySQL 8.0.16+
-- 按题块执行；先载入对应数据集，不同数据集使用各自数据库。

-- 1. 1 · 建表并插入样例数据
-- 数据集：sales
-- MySQL 8.0.16+
CREATE TABLE customers(c_num VARCHAR(20) PRIMARY KEY,c_name VARCHAR(60) NOT NULL,c_add VARCHAR(100),c_duty VARCHAR(30));
CREATE TABLE products(
 p_num VARCHAR(10) PRIMARY KEY,p_name VARCHAR(60) NOT NULL,
 p_model VARCHAR(30),p_price DECIMAL(10,2) NOT NULL CHECK(p_price>=0),
 CHECK(CHAR_LENGTH(p_num)=10 AND BINARY LEFT(p_num,4)=BINARY 'DYKJ')
);
CREATE TABLE stocks(p_num VARCHAR(10) PRIMARY KEY,stock_count INT NOT NULL CHECK(stock_count>=0),place VARCHAR(50),FOREIGN KEY(p_num) REFERENCES products(p_num));
CREATE TABLE sales_orders(
 o_num VARCHAR(20) PRIMARY KEY,o_time DATE NOT NULL DEFAULT (CURRENT_DATE),
 c_num VARCHAR(20) NOT NULL,p_num VARCHAR(10) NOT NULL,
 quantity INT NOT NULL CHECK(quantity>0),
 FOREIGN KEY(c_num) REFERENCES customers(c_num),FOREIGN KEY(p_num) REFERENCES products(p_num)
);
INSERT INTO customers VALUES('k001','学习者','东苑','001001001'),('k002','张三','东苑','002002002'),('k003','客户A','西苑','003003003');
INSERT INTO products VALUES('DYKJ000001','材料1','重型',20),('DYKJ000002','材料2','轻型',10),('DYKJ000003','材料3','中型',5);
INSERT INTO stocks VALUES('DYKJ000001',100,'x1'),('DYKJ000002',200,'x2'),('DYKJ000003',100,'x3');
INSERT INTO sales_orders VALUES('D001','2024-11-01','k001','DYKJ000001',30),('D002','2024-11-02','k001','DYKJ000002',40),('D003','2024-11-05','k002','DYKJ000001',50),('D004','2024-11-01','k003','DYKJ000002',20);


-- 2. 2 · 所有客户相关信息
-- 数据集：sales
SELECT c.*,o.o_num,o.o_time,o.quantity,p.p_num,p.p_name,p.p_price,
       s.stock_count,s.place
FROM customers c
LEFT JOIN sales_orders o ON o.c_num=c.c_num
LEFT JOIN products p ON p.p_num=o.p_num
LEFT JOIN stocks s ON s.p_num=p.p_num;

-- 3. 3 · 客户A已购产品价格
-- 数据集：sales
SELECT AVG(p.p_price) AS avg_price,MAX(p.p_price) AS max_price,
       MIN(p.p_price) AS min_price
FROM products p
WHERE EXISTS (
 SELECT 1 FROM sales_orders o JOIN customers c ON c.c_num=o.c_num
 WHERE o.p_num=p.p_num AND c.c_name='客户A'
);

-- 4. 4 · 时间段订单
-- 数据集：sales
SELECT * FROM sales_orders
WHERE o_time >= '2024-11-01' AND o_time < '2024-11-05';

-- 5. 5 · 总销量最高的产品视图
-- 数据集：sales
CREATE VIEW top_selling_products AS
SELECT p_num,p_name,p_model,p_price,stock_count,sold_qty
FROM (
  SELECT b.*, DENSE_RANK() OVER(ORDER BY sold_qty DESC) AS rnk
  FROM (
    SELECT p.p_num,p.p_name,p.p_model,p.p_price,
      COALESCE(s.stock_count,0) AS stock_count,SUM(o.quantity) AS sold_qty
    FROM products p JOIN sales_orders o ON o.p_num=p.p_num
    LEFT JOIN stocks s ON s.p_num=p.p_num
    GROUP BY p.p_num,p.p_name,p.p_model,p.p_price,s.stock_count
  ) b
) ranked
WHERE rnk = 1;
