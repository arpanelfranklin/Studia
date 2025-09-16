-- Create database
CREATE DATABASE IF NOT EXISTS studia;
USE studia;

-- =========================
-- Branch Table
-- =========================
CREATE TABLE branch (
    branchID INT PRIMARY KEY AUTO_INCREMENT,
    branchName VARCHAR(100) NOT NULL,
    branchCode VARCHAR(15) NOT NULL UNIQUE
);

-- =========================
-- Batch Table
-- =========================
CREATE TABLE batch (
    batch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT,
    year INT,
    semester INT,
    branch_code VARCHAR(15),
    FOREIGN KEY (branch_id) REFERENCES branch(branchID)
);

-- =========================
-- Student Dashboard Table
-- =========================
CREATE TABLE studentdashboard (
    student_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    branch_id INT,
    batch_id INT,
    cgpa DECIMAL(4,2),
    attendance_percentage DECIMAL(5,2),
    contact_no VARCHAR(15),
    college VARCHAR(100),
    program_validity_date DATE,
    date_of_birth DATE,
    age INT,
    gender VARCHAR(10),
    fathers_name VARCHAR(100),
    mothers_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    blood_group VARCHAR(5),
    student_email_id VARCHAR(100),
    admission_year YEAR,
    fathers_occupation VARCHAR(100),
    mothers_occupation VARCHAR(100),
    guardian_phone_number VARCHAR(15),
    permanent_address VARCHAR(255),
    current_address VARCHAR(255),
    emergency_contact_number VARCHAR(15),
    credits SMALLINT,
    totalCredits SMALLINT,
    FOREIGN KEY (branch_id) REFERENCES branch(branchID),
    FOREIGN KEY (batch_id) REFERENCES batch(batch_id)
);

-- =========================
-- Registered User Table
-- =========================
CREATE TABLE registeredUser (
    studentID VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    passwords VARCHAR(255),
    PRIMARY KEY (studentID),
    FOREIGN KEY (studentID) REFERENCES studentdashboard(student_id)
);

-- =========================
-- Timetable Table
-- =========================
CREATE TABLE timetable (
    timetable_id INT PRIMARY KEY AUTO_INCREMENT,
    batch_id INT,
    day_of_week ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
    subject_name VARCHAR(100),
    start_time TIME,
    end_time TIME,
    classroom VARCHAR(20),
    faculty_name VARCHAR(100),
    type CHAR(1),
    FOREIGN KEY (batch_id) REFERENCES batch(batch_id)
);

-- =========================
-- Insert Sample Data
-- =========================

-- Branch
INSERT INTO branch (branchName, branchCode)
VALUES ('Computer Science', 'CSE');

-- Batch
INSERT INTO batch (branch_id, year, semester, branch_code)
VALUES (1, 2025, 1, 'CSE');

-- Student Dashboard
INSERT INTO studentdashboard (
    student_id, name, branch_id, batch_id, cgpa, attendance_percentage,
    contact_no, college, program_validity_date, date_of_birth, age, gender,
    fathers_name, mothers_name, city, state, blood_group, student_email_id,
    admission_year, fathers_occupation, mothers_occupation,
    guardian_phone_number, permanent_address, current_address,
    emergency_contact_number, credits, totalCredits
) VALUES (
    'STU001', 'Arpanel Franklin', 1, 1, 9.10, 95.00,
    '9876543210', 'Bennett University', '2029-05-01', '2007-07-21', 18, 'Male',
    'John Franklin', 'Mary Franklin', 'Durg', 'Chhattisgarh', 'O+', 'arpanel@example.com',
    2025, 'Engineer', 'Teacher',
    '9876500000', 'Durg, Chhattisgarh', 'Greater Noida, UP',
    '9876511111', 20, 160
);

-- Registered User
INSERT INTO registeredUser (studentID, email, passwords)
VALUES ('STU001', 'arpanel@example.com', 'arpanelisbest');

-- Timetable
INSERT INTO timetable (
    batch_id, day_of_week, subject_name, start_time, end_time, classroom, faculty_name, type
) VALUES (
    1, 'Monday', 'Database Systems', '09:00:00', '10:00:00', 'A101', 'Prof. Sharma', 'L'
);


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
-- Step 1: Add new columns
ALTER TABLE studentdashboard
ADD COLUMN blood_group VARCHAR(5),
ADD COLUMN student_email_id VARCHAR(100),
ADD COLUMN admission_year YEAR,
ADD COLUMN fathers_occupation VARCHAR(100),
ADD COLUMN mothers_occupation VARCHAR(100),
ADD COLUMN guardian_phone_number VARCHAR(15),
ADD COLUMN permanent_address VARCHAR(255),
ADD COLUMN current_address VARCHAR(255),
ADD COLUMN emergency_contact_number VARCHAR(15);

-- Step 2: Drop old column 'address'
ALTER TABLE studentdashboard
DROP COLUMN address;
use studia;

select * from studentdashboard;
UPDATE studentdashboard
SET 
    blood_group = 'AB+',
    student_email_id = 's25cseu0144@benneett.edu.in',
    admission_year = 2025,
    fathers_occupation = 'Teacher',
    mothers_occupation = 'Housewife',
    guardian_phone_number = '8965088591',
    permanent_address = '123, Old Colony, Durg, Chhattisgarh',
    current_address = 'Bennett University Hostel, Greater Noida',
    emergency_contact_number = '9285526717'
WHERE student_id = "S25cseu0144";


alter table studentdashboard add column totalCredits int2;
update studentdashboard set credits = 12, totalCredits = 14 where student_id = 's25cseu0144';
alter table batch add column mentor varchar(50);
use studia;
Update batch set mentor = "Elara Voss" where batch_id = 5;
select * from batch;
alter table studentdashboard add column specilization varchar(100);
update studentdashboard set specilization = "Devops" where student_id= "S25CSEU0144";
CREATE TABLE facultylogin (
    faculty_id VARCHAR(10) PRIMARY KEY, 
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);
INSERT INTO facultylogin (faculty_id, email, password) 
VALUES 
('FAC0150', 'emily.johnson@university.edu', 'emily@123');
select * from facultylogin;
update facultylogin set email = "FAC0150@studia.edu.in" where faculty_id="FAC0150";
CREATE TABLE facultydashboard (
    faculty_id VARCHAR(10) PRIMARY KEY,     -- Same ID as in faculty_login
    total_students INT NOT NULL,
    subjects_assigned INT NOT NULL,
    ongoing_semester VARCHAR(20) NOT NULL,
    upcoming_class VARCHAR(100),
    pending_assignments VARCHAR(255),
    notifications TEXT,
    CONSTRAINT fk_faculty
        FOREIGN KEY (faculty_id) 
        REFERENCES facultylogin(faculty_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

INSERT INTO facultydashboard (
    faculty_id, 
    total_students, 
    subjects_assigned, 
    ongoing_semester, 
    upcoming_class, 
    pending_assignments, 
    notifications
) VALUES (
    'FAC0150', 
    50, 
    2, 
    'Semester 1', 
    '10 PM | Room: ALH010', 
    'No assignments to review', 
    'Welcome back Emily! Faculty orientation scheduled tomorrow at 9 AM.'
);

select * from facultydashboard;
select * from timetable;
drop table timetable;

select * from facultylogin;

CREATE TABLE timetable (
    timetable_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id VARCHAR(20),
    subject_name VARCHAR(100) NOT NULL,
    day_of_week ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_no VARCHAR(20),
    semester VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- 🔗 Link with faculty_dashboard
    CONSTRAINT fk_timetable_faculty
      FOREIGN KEY (faculty_id) REFERENCES facultydashboard(faculty_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);
alter table timetable add type char(1);
select * from timetable;
select * from batch;
select * from facultylogin;
select * from studentdashboard;
desc timetable;
INSERT INTO timetable 
(batch_id, day_of_week, subject_name, start_time, end_time, classroom, faculty_name, faculty_id, type) 
VALUES 
(5, 'Thursday', 'Physics', '08:30:00', '09:30:00', 'A-TR-121', 'Mrs. Emily', 'FAC0150', 'P');


