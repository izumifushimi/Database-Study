-- 上机 4 · 基建与快递管理；MySQL 8.0.16+；按题块在对应数据集中执行。

-- 1. 基建 1 · 项目名称模糊查询
-- 数据集：construction
SELECT p.*, s.s_number, s.s_name, m.*, pr.pr_count
FROM projects p
JOIN provides pr ON pr.pr_p_number = p.p_number
JOIN suppliers s ON s.s_number = pr.pr_s_number
JOIN materials m ON m.m_number = pr.pr_m_number
WHERE p.p_name LIKE '%南京%';

-- 2. 基建 2 · 至少三种且每种数量达标
-- 数据集：construction
SELECT p.p_number, p.p_name
FROM projects p
JOIN (
  SELECT pr_p_number, pr_m_number, SUM(pr_count) AS material_qty
  FROM provides GROUP BY pr_p_number, pr_m_number
) x ON x.pr_p_number = p.p_number
GROUP BY p.p_number, p.p_name
HAVING COUNT(*) >= 3 AND MIN(x.material_qty) >= 10;

-- 3. 基建 3 · 使用 A 但没有使用 B
-- 数据集：construction
SELECT p.p_number,p.p_name FROM projects p
WHERE EXISTS (
  SELECT 1 FROM provides pr JOIN materials m ON m.m_number=pr.pr_m_number
  WHERE pr.pr_p_number=p.p_number AND m.m_name='材料1'
) AND NOT EXISTS (
  SELECT 1 FROM provides pr JOIN materials m ON m.m_number=pr.pr_m_number
  WHERE pr.pr_p_number=p.p_number AND m.m_name='材料2'
);

-- 4. 基建 4 · 供应商信息
-- 数据集：construction
SELECT * FROM suppliers;

-- 5. 快递 1 · 主外键与单号约束
-- 数据集：parcel
-- MySQL 8.0.16+
CREATE TABLE people (
 person_id INT PRIMARY KEY, person_name VARCHAR(50) NOT NULL,
 phone VARCHAR(20), address VARCHAR(100), postcode VARCHAR(10)
);
CREATE TABLE companies (company_id INT PRIMARY KEY, company_name VARCHAR(30) NOT NULL);
CREATE TABLE parcels (
 parcel_no VARCHAR(10) PRIMARY KEY,
 company_id INT NOT NULL,
 sender_id INT NOT NULL, receiver_id INT NOT NULL,
 pickup_code VARCHAR(20), logistics VARCHAR(200),
 collected BOOLEAN NOT NULL DEFAULT FALSE,
 sent_date DATE NOT NULL DEFAULT (CURRENT_DATE),
 CHECK(CHAR_LENGTH(parcel_no)=10 AND BINARY LEFT(parcel_no,4)=BINARY '2301'),
 FOREIGN KEY(company_id) REFERENCES companies(company_id),
 FOREIGN KEY(sender_id) REFERENCES people(person_id),
 FOREIGN KEY(receiver_id) REFERENCES people(person_id)
);
INSERT INTO people VALUES(1,'学习者A','13800000001','南京东苑','210000'),(2,'学习者B','13800000002','南京西苑','210001'),(3,'学习者C','13800000003','常州','213000');
INSERT INTO companies VALUES(1,'顺丰'),(2,'中通'),(3,'圆通'),(4,'韵达');
INSERT INTO parcels(parcel_no,company_id,sender_id,receiver_id,pickup_code,logistics) VALUES('2301000001',1,1,2,'1-001','已到代收点'),('2301000002',2,2,1,'2-001','运输中');


-- 6. 快递 2 · 各公司快件数量
-- 数据集：parcel
SELECT c.company_name,COUNT(p.parcel_no) AS parcel_count
FROM companies c LEFT JOIN parcels p ON p.company_id=c.company_id
GROUP BY c.company_id,c.company_name;

-- 7. 快递 3 · 包含尚未寄件的人员
-- 数据集：parcel
SELECT pe.*,p.parcel_no,p.sent_date
FROM people pe LEFT JOIN parcels p ON p.sender_id=pe.person_id;
