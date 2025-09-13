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
