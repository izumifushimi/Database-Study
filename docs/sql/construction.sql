-- MySQL 8.0.16+；请在新建的学习数据库中执行。
CREATE TABLE projects (
 p_number VARCHAR(20) PRIMARY KEY, p_name VARCHAR(60) NOT NULL,
 p_address VARCHAR(100), p_start_time DATE, p_state VARCHAR(20)
);
CREATE TABLE materials (
 m_number VARCHAR(10) PRIMARY KEY, m_name VARCHAR(60) NOT NULL,
 m_category VARCHAR(30), m_price DECIMAL(10,2) NOT NULL CHECK(m_price>=0),
 m_put_place VARCHAR(100), m_put_count INT NOT NULL CHECK(m_put_count>=0)
);
CREATE TABLE suppliers (
 s_number VARCHAR(10) PRIMARY KEY, s_name VARCHAR(60) NOT NULL,
 s_material VARCHAR(10) NOT NULL,
 FOREIGN KEY(s_material) REFERENCES materials(m_number),
 UNIQUE(s_number,s_material)
);
CREATE TABLE provides (
 pr_p_number VARCHAR(20), pr_s_number VARCHAR(10),
 pr_m_number VARCHAR(10), pr_count INT NOT NULL CHECK(pr_count>0),
 PRIMARY KEY(pr_p_number,pr_s_number,pr_m_number),
 FOREIGN KEY(pr_p_number) REFERENCES projects(p_number),
 FOREIGN KEY(pr_s_number,pr_m_number) REFERENCES suppliers(s_number,s_material)
);
INSERT INTO projects VALUES
 ('PJ01','南京甲','南京','2024-01-01','施工中'),
 ('PJ02','南京乙','南京','2024-02-01','未开始'),
 ('PJ03','常州项目','常州','2024-03-01','已交付');
INSERT INTO materials VALUES
 ('M001','材料1','类别1',20,'地点1',100),
 ('M002','材料2','类别2',10,'地点2',200),
 ('M003','原材料A','类别3',30,'地点3',2),
 ('M004','材料4','类别4',5,'地点4',1);
INSERT INTO suppliers VALUES ('S001','供应商1','M001'),('S002','供应商2','M002'),('S003','供应商3','M003'),('S004','供应商4','M004');
INSERT INTO provides VALUES ('PJ01','S001','M001',20),('PJ01','S002','M002',15),('PJ01','S003','M003',10),('PJ02','S001','M001',30),('PJ03','S003','M003',5);
