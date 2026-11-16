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
