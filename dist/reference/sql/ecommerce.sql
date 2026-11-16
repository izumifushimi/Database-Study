-- MySQL 8.0.16+；密码列为散列值的占位示例，不保存明文密码。
CREATE TABLE users(u_id INT PRIMARY KEY,u_name VARCHAR(50),password_hash VARCHAR(255),phone VARCHAR(20));
CREATE TABLE suppliers(s_id INT PRIMARY KEY,s_name VARCHAR(60),contact VARCHAR(50),phone VARCHAR(20),license_no VARCHAR(100));
CREATE TABLE products(p_id INT PRIMARY KEY,p_name VARCHAR(60),description VARCHAR(200),category VARCHAR(30),price DECIMAL(10,2) CHECK(price>=0),stock INT CHECK(stock>=0),s_id INT NOT NULL,FOREIGN KEY(s_id) REFERENCES suppliers(s_id));
CREATE TABLE orders(o_id INT PRIMARY KEY,u_id INT NOT NULL,phone VARCHAR(20),address VARCHAR(100),order_state VARCHAR(20),ordered_at DATETIME DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(u_id) REFERENCES users(u_id));
CREATE TABLE order_items(o_id INT,p_id INT,quantity INT NOT NULL CHECK(quantity>0),unit_price DECIMAL(10,2) NOT NULL,PRIMARY KEY(o_id,p_id),FOREIGN KEY(o_id) REFERENCES orders(o_id),FOREIGN KEY(p_id) REFERENCES products(p_id));
CREATE TABLE cart(u_id INT,p_id INT,quantity INT NOT NULL CHECK(quantity>0),added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY(u_id,p_id),FOREIGN KEY(u_id) REFERENCES users(u_id),FOREIGN KEY(p_id) REFERENCES products(p_id));
INSERT INTO users VALUES(1,'学习者','demo-hash','13800000001');
INSERT INTO suppliers VALUES(1,'供应商A','联系人A','13800000002','LIC001'),(2,'供应商B','联系人B','13800000003','LIC002');
INSERT INTO products VALUES(1,'智能手机A','示例商品','数码',2000,50,1),(2,'智能手机B','示例商品','数码',2500,30,2),(3,'手机壳','示例配件','配件',30,100,1);
INSERT INTO cart VALUES(1,1,1,'2026-11-16 10:00:00'),(1,3,2,'2026-11-16 11:00:00');
