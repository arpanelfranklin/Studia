CREATE TABLE RegisteredUser (
    student_id VARCHAR(20) PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE Branch (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Batch (
    batch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    year INT NOT NULL,  -- e.g., 2025
    semester INT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);

CREATE TABLE StudentDashboard (
    student_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    branch_id INT NOT NULL,
    batch_id INT NOT NULL,
    cgpa DECIMAL(4,2),
    attendance_percentage DECIMAL(5,2),
    contact_no VARCHAR(15),
    FOREIGN KEY (student_id) REFERENCES RegisteredUser(student_id),
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    FOREIGN KEY (batch_id) REFERENCES Batch(batch_id)
);

CREATE TABLE Timetable (
    timetable_id INT PRIMARY KEY AUTO_INCREMENT,
    batch_id INT NOT NULL,
    day_of_week ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    classroom VARCHAR(20) NOT NULL,  -- e.g., A-LH202
    faculty_name VARCHAR(100),
    FOREIGN KEY (batch_id) REFERENCES Batch(batch_id)
);
alter table batch add branch_code char(3) unique;

insert into registereduser  (student_id,email,password_hash) values ("S25CSEU0144","s25cseu0144@bennett.edu.in","Access@#5627");
INSERT INTO StudentDashboard (college,program_validaty_date,date_of_birth,age,gender,fathers_name,mothers_name,address,city,state)
VALUES ("Bennett University","");

select * from registereduser;
select * from studentdashboard;
select * from batch;
select * from branch;

select * from timetable;

use studia;
alter table branch rename column branch_name to branchName;
INSERT INTO Batch (batch_id, branch_id, year, semester, branch_code)
VALUES (5, 1, 2025, 1,"CSE");
ALTER TABLE branch
ADD branchCode CHAR(3);
INSERT INTO Branch(branchID, branchName, branchCode)
VALUES (1, "Computer Science and Engineer", "CSE");
desc branch;
INSERT INTO Branch(branchID, branchName, branchCode) VALUES

(2, "B.Tech Artificial Intelligence", "BTAI"),
(3, "B.Tech Engineering Physics", "BTEP"),
(4, "B.Tech Electronics & Communication Engineering", "ECE"),
(5, "B.Tech Electronics and Computer Engineering", "ECEC"),
(6, "B.Tech Mechanical Engineering", "ME"),
(7, "B.Tech Biotechnology", "BT"),
(8, "B.Tech M.Tech Biotech Integrated", "BTBI"),
(9, "BCA - Bachelor of Computer Application", "BCA"),
(10, "B.A. Mass Communication", "BAMC"),
(11, "B.A. (Hons.)", "BAH"),
(12, "B.A. Film, TV & Web Series", "BAFTV"),
(13, "BBA - Bachelor of Business Administration", "BBA"),
(14, "MBA Integrated", "MBAINT"),
(15, "Integ. B.A. LL.B. (Hons.)", "BALLB"),
(16, "Integ. BBA LL.B. (Hons.)", "BBALLB"),
(17, "B. Des", "BDES"),
(18, "M.A. Mass Communication", "MAMC"),
(19, "LL.M.", "LLM"),
(20, "MBA", "MBA"),
(21, "MCA", "MCA"),
(22, "M.Tech", "MTECH"),
(23, "M.Tech Artificial Intelligence", "MTAI"),
(24, "M.Tech + Ph.D. (Computer Science Engineering - Integrated)", "MTPCSE"),
(25, "PG Diploma AI in Healthcare in collaboration with MAX", "PGAIH"),
(26, "PG Diploma in TV & Digital Journalism", "PGDJ"),
(27, "PG Diploma in Computer Science Engineering", "PGCSE"),
(28, "PG Diploma in Computer Application", "PGCA"),
(29, "Certificate Course Computer Science Engineering", "CCCSE"),
(30, "Certificate Course Computer Application", "CCCA"),
(31, "Ph.D", "PHD");

desc batch;

ALTER TABLE Branch
MODIFY COLUMN branchName VARCHAR(100);
ALTER TABLE batch 
MODIFY branch_code VARCHAR(15);


ALTER TABLE studentdashboard 
DROP FOREIGN KEY studentdashboard_ibfk_3;


ALTER TABLE batch 
MODIFY batch_id INT NOT NULL
MODIFY branch_code VARCHAR(15);

-- 3. Recreate the foreign key
ALTER TABLE studentdashboard 
ADD CONSTRAINT studentdashboard_ibfk_3 
FOREIGN KEY (batch_id) REFERENCES batch(batch_id);
desc studentdashboard;
insert into studentdashboard (student_id,name,branch_id,batch_id,cgpa,attendance_percentage,contact_no) values ("S25CSEU0144","Arpanel Franklin",1,5,9.52,96.25,"7247707837");
select * from batch where batch.batch_id = studentdashboard.batch_id;

SELECT s.*, b.*
FROM studentdashboard s
JOIN batch b ON s.batch_id = b.batch_id;

SELECT b.*
FROM batch b
JOIN studentdashboard s ON b.batch_id = s.batch_id
WHERE s.student_id = "S25CSEU0144";

alter table batch;
SELECT b.*, br.*
FROM batch b
JOIN studentdashboard s ON b.batch_id = s.batch_id
JOIN Branch br ON b.branch_id = br.branchID
WHERE s.student_id = "S25CSEU0144";

select * from studentdashboard;
ALTER TABLE studentdashboard
ADD COLUMN college VARCHAR(100),
ADD COLUMN program_validity_date DATE,
ADD COLUMN date_of_birth DATE,
ADD COLUMN age INT,
ADD COLUMN gender VARCHAR(10),
ADD COLUMN fathers_name VARCHAR(100),
ADD COLUMN mothers_name VARCHAR(100),
ADD COLUMN address VARCHAR(255),
ADD COLUMN city VARCHAR(100),
ADD COLUMN state VARCHAR(100);

UPDATE studentdashboard
SET college = 'Bennett University',
    program_validity_date = '2029-05-30',
    date_of_birth = '2007-07-21',
    age = 18,
    gender = 'Male',
    fathers_name = 'Mahendra Franklin',
    mothers_name = 'Smita Franklin',
    address = 'Ward no 01 - New Mannam Nagar Dhanora ',
    city = 'Durg',
    state = 'Chhattisgarh'
WHERE student_id = 'S25CSEU0144';
UPDATE studentdashboard
SET college = 'Bennett University',
    program_validity_date = '2029-05-30',
    date_of_birth = '2007-07-21',
    age = 18,
    gender = 'Male',
    fathers_name = 'Mahendra Franklin',
    mothers_name = 'Smita. Franklin',
    address = 'Ward no 01 - New mannam nagar Durg Chhattisgarh 491228 ',
    city = 'Durg',
    state = 'Chhattisgarh'
WHERE student_id = 'S25CSEU0144';

select * from timetable;
DELETE FROM timetable
WHERE timetable_id = 2;

desc timetable;
alter table timetable add type char(1);








