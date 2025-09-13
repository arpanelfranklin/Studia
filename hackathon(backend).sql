CREATE DATABASE IF NOT EXISTS studia;
USE studia;

-- 2️⃣ Create tables
CREATE TABLE RegisteredUser (
    student_id VARCHAR(20) PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE Branch (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branchName VARCHAR(100) UNIQUE NOT NULL,
    branchCode CHAR(3)
);

CREATE TABLE Batch (
    batch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id INT NOT NULL,
    year INT NOT NULL,
    semester INT NOT NULL,
    branch_code VARCHAR(15) UNIQUE,
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
    college VARCHAR(100),
    program_validity_date DATE,
    date_of_birth DATE,
    age INT,
    gender VARCHAR(10),
    fathers_name VARCHAR(100),
    mothers_name VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
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
    classroom VARCHAR(20) NOT NULL,
    faculty_name VARCHAR(100),
    type CHAR(1),
    FOREIGN KEY (batch_id) REFERENCES Batch(batch_id)
);

CREATE TABLE Faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    subject_specialization VARCHAR(100),
    phone VARCHAR(15)
);

CREATE TABLE Subject (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(100) NOT NULL,
    branch_id INT NOT NULL,
    semester INT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);

CREATE TABLE Classroom (
    classroom_id INT PRIMARY KEY AUTO_INCREMENT,
    classroom_code VARCHAR(20) UNIQUE NOT NULL,
    capacity INT
);

INSERT IGNORE INTO Branch (branchName, branchCode) VALUES
("Computer Science and Engineer", "CSE"),
("B.Tech Artificial Intelligence", "BTAI"),
("B.Tech Engineering Physics", "BTEP"),
("B.Tech Electronics & Communication Engineering", "ECE"),
("B.Tech Electronics and Computer Engineering", "ECEC"),
("B.Tech Mechanical Engineering", "ME"),
("B.Tech Biotechnology", "BT"),
("B.Tech M.Tech Biotech Integrated", "BTBI"),
("BCA - Bachelor of Computer Application", "BCA"),
("B.A. Mass Communication", "BAMC"),
("B.A. (Hons.)", "BAH"),
("B.A. Film, TV & Web Series", "BAFTV"),
("BBA - Bachelor of Business Administration", "BBA"),
("MBA Integrated", "MBAINT"),
("Integ. B.A. LL.B. (Hons.)", "BALLB"),
("Integ. BBA LL.B. (Hons.)", "BBALLB"),
("B. Des", "BDES"),
("M.A. Mass Communication", "MAMC"),
("LL.M.", "LLM"),
("MBA", "MBA"),
("MCA", "MCA"),
("M.Tech", "MTECH"),
("M.Tech Artificial Intelligence", "MTAI"),
("M.Tech + Ph.D. (Computer Science Engineering - Integrated)", "MTPCSE"),
("PG Diploma AI in Healthcare in collaboration with MAX", "PGAIH"),
("PG Diploma in TV & Digital Journalism", "PGDJ"),
("PG Diploma in Computer Science Engineering", "PGCSE"),
("PG Diploma in Computer Application", "PGCA"),
("Certificate Course Computer Science Engineering", "CCCSE"),
("Certificate Course Computer Application", "CCCA"),
("Ph.D", "PHD");

-- 3️⃣ Insert Initial Data
INSERT IGNORE INTO RegisteredUser (student_id, email, password_hash)
VALUES ("S25CSEU0144", "s25cseu0144@bennett.edu.in", "Access@#5627");

INSERT INTO Batch (branch_id, year, semester, branch_code)
VALUES (1, 2025, 1, "CSE");

INSERT INTO StudentDashboard (
    student_id, name, branch_id, batch_id, cgpa, attendance_percentage, contact_no,
    college, program_validity_date, date_of_birth, age, gender, fathers_name, mothers_name, address, city, state
)
VALUES (
    "S25CSEU0144", "Arpanel Franklin", 1, 1, 9.52, 96.25, "7247707837",
    "Bennett University", "2029-05-30", "2007-07-21", 18, "Male", "Mahendra Franklin",
    "Smita Franklin", "Ward no 01 - New Mannam Nagar Dhanora", "Durg", "Chhattisgarh"
);

