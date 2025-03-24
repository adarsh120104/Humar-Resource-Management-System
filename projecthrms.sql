CREATE DATABASE HRMS;
USE HRMS;

-- Table creation

-- jobs
CREATE TABLE jobs (
    job_id INT PRIMARY KEY AUTO_INCREMENT,
    job_title VARCHAR(100) NOT NULL,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2)
);

-- employees (Created first to avoid circular dependency)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    department_id INT NULL,
    job_id INT NULL,
    manager_id INT NULL, -- Null if top-level employee
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active'
);

-- departments (Created after employees to avoid FK issue)
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    manager_id INT UNIQUE NULL, -- Each department has one manager
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

-- Updating employees table to reference departments
ALTER TABLE employees ADD FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL;
ALTER TABLE employees ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE SET NULL;
ALTER TABLE employees ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON DELETE SET NULL;

-- attendance
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    login DATETIME NULL,
    logout DATETIME NULL,
    status ENUM('present', 'absent', 'leave') DEFAULT 'present',
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- payroll
CREATE TABLE payroll (
    payroll_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    salary DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) DEFAULT 0.00,
    deductions DECIMAL(10,2) DEFAULT 0.00,
    net_salary DECIMAL(10,2) GENERATED ALWAYS AS (salary + bonus - deductions) STORED,
    payment_date DATE NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- leave requests
CREATE TABLE leave_requests (
    leave_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    leave_type ENUM('sick', 'casual', 'annual') NOT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- training
CREATE TABLE training (
    training_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    training_name VARCHAR(100) NOT NULL,
    provider VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('completed', 'ongoing', 'pending') DEFAULT 'pending',
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- performance review
CREATE TABLE performance_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    reviewer_id INT,
    review_date DATE NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT UNIQUE,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'hr','manager', 'employee') NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- Insert jobs
INSERT INTO jobs (job_title, min_salary, max_salary) VALUES
('Software Engineer', 40000.00, 80000.00),
('Data Analyst', 35000.00, 70000.00),
('HR Manager', 50000.00, 90000.00),
('Marketing Executive', 30000.00, 60000.00),
('Network Administrator', 45000.00, 85000.00),
('System Analyst', 48000.00, 88000.00),
('Business Analyst', 47000.00, 87000.00);

-- Insert employees
INSERT INTO employees (first_name, last_name, email, phone, hire_date, salary, status) VALUES
('James', 'Mathew', 'jmathew@example.com', '9876523210', '2022-01-15', 120000.00, 'active'); -- Superior (1)

-- Insert departments
INSERT INTO departments (department_name, location) VALUES
('Software', 'New York'),
('HR', 'San Francisco'),
('Marketing', 'Chicago'),
('IT Support', 'Los Angeles'),
('Business Analytics', 'Houston');

-- Insert employees with department references
INSERT INTO employees (first_name, last_name, email, phone, department_id, job_id, manager_id, hire_date, salary, status) VALUES
('Arun', 'Kumar', 'arun.kumar@example.com', '9876543210', 1, 1, 1, '2022-01-15', 75000.00, 'active'), 
('Mohan', 'Raj', 'mohan.raj@example.com', '9876543211', 2, 3, 1, '2022-02-10', 85000.00, 'active'),
('Prakash', 'V', 'prakash.v@example.com', '9876543212', 3, 4, 1, '2022-03-05', 70000.00, 'active'),
('Suresh', 'G', 'suresh.g@example.com', '9876543213', 4, 5, 1, '2022-04-01', 80000.00, 'active'),
('Vignesh', 'T', 'vignesh.t@example.com', '9876543214', 5, 6, 1, '2022-05-20', 90000.00, 'active');

insert into employees (first_name, last_name, email, phone, department_id, job_id, manager_id, hire_date, salary, status) values
('bharath', 's', 'bharath.s@example.com', '9876543215', 1, 1, 1, '2023-06-15', 50000.00, 'active'),
('karthik', 'm', 'karthik.m@example.com', '9876543216', 2, 2, 2, '2023-07-10', 52000.00, 'active'),
('dinesh', 'r', 'dinesh.r@example.com', '9876543217', 3, 3, 3, '2023-08-12', 54000.00, 'active'),
('saravanan', 'p', 'saravanan.p@example.com', '9876543218', 4, 4, 4, '2023-09-05', 56000.00, 'active'),
('rajkumar', 'l', 'rajkumar.l@example.com', '9876543219', 5, 5, 5, '2023-10-01', 58000.00, 'active'),
('gokul', 'b', 'gokul.b@example.com', '9876543220', 2, 6, 4, '2023-11-15', 60000.00, 'active'),
('santhosh', 'k', 'santhosh.k@example.com', '9876543221', 3, 7, 5, '2023-12-20', 62000.00, 'active'),
('yuvaraj', 'a', 'yuvaraj.a@example.com', '9876543222', 1, 2, 3, '2024-01-05', 64000.00, 'active'),
('sathish', 'j', 'sathish.j@example.com', '9876543223', 2, 3, 3, '2024-02-10', 66000.00, 'active'),
('praveen', 'v', 'praveen.v@example.com', '9876543224', 3, 4, 1, '2024-03-15', 68000.00, 'active');

-- Assign department managers
UPDATE departments SET manager_id = 2 WHERE department_id = 1;
UPDATE departments SET manager_id = 3 WHERE department_id = 2;
UPDATE departments SET manager_id = 4 WHERE department_id = 3;
UPDATE departments SET manager_id = 5 WHERE department_id = 4;
UPDATE departments SET manager_id = 6 WHERE department_id = 5;

-- remaing insertion attenddace  payroll peroformance reviuew
-- attendance
-- Insert attendance for each employee for 3 weeks (21 days)
INSERT INTO attendance (employee_id, login, logout, status)
VALUES
-- Employee 1
(1, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(1, '2024-03-12 09:15:00', '2024-03-12 18:00:00', 'present'),
(1, '2024-03-13 00:00:00', NULL, 'absent'),
(1, '2024-03-14 09:05:00', '2024-03-14 17:45:00', 'leave'),
(1, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(1, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(1, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(1, '2024-03-20 00:00:00', NULL, 'absent'),
(1, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(1, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(1, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(1, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(1, '2024-03-27 00:00:00', NULL, 'absent'),
(1, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(1, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(1, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(1, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(1, '2024-04-03 00:00:00', NULL, 'absent'),
(1, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(1, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(1, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(1, '2024-04-09 00:00:00', NULL, 'leave'),
(1, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

-- Employee 2
(2, '2024-03-11 09:10:00', '2024-03-11 18:00:00', 'present'),
(2, '2024-03-12 00:00:00', NULL, 'absent'),
(2, '2024-03-13 09:00:00', '2024-03-13 18:00:00', 'present'),
(2, '2024-03-14 09:20:00', '2024-03-14 18:00:00', 'present'),
(2, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(2, '2024-03-18 09:05:00', '2024-03-18 18:00:00', 'present'),
(2, '2024-03-19 09:20:00', '2024-03-19 18:00:00', 'present'),
(2, '2024-03-20 00:00:00', NULL, 'absent'),
(2, '2024-03-21 09:10:00', '2024-03-21 17:50:00', 'leave'),
(2, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(2, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(2, '2024-03-26 09:10:00', '2024-03-26 18:00:00', 'present'),
(2, '2024-03-27 00:00:00', NULL, 'absent'),
(2, '2024-03-28 09:10:00', '2024-03-28 17:50:00', 'leave'),
(2, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(2, '2024-04-01 09:05:00', '2024-04-01 18:00:00', 'present'),
(2, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(2, '2024-04-03 00:00:00', NULL, 'absent'),
(2, '2024-04-04 09:20:00', '2024-04-04 18:00:00', 'present'),
(2, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(2, '2024-04-08 09:15:00', '2024-04-08 18:00:00', 'present'),
(2, '2024-04-09 00:00:00', NULL, 'leave'),
(2, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

-- Employee 3
(3, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(3, '2024-03-12 09:00:00', '2024-03-12 17:30:00', 'present'),
(3, '2024-03-13 09:15:00', '2024-03-13 18:00:00', 'present'),
(3, '2024-03-14 00:00:00', NULL, 'leave'),
(3, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(3, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(3, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(3, '2024-03-20 00:00:00', NULL, 'absent'),
(3, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(3, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(3, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(3, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(3, '2024-03-27 00:00:00', NULL, 'absent'),
(3, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(3, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(3, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(3, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(3, '2024-04-03 00:00:00', NULL, 'absent'),
(3, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(3, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(3, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(3, '2024-04-09 00:00:00', NULL, 'leave'),
(3, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

-- Employee 4
(4, '2024-03-11 00:00:00', NULL, 'leave'),
(4, '2024-03-12 09:00:00', '2024-03-12 18:00:00', 'present'),
(4, '2024-03-13 09:05:00', '2024-03-13 18:00:00', 'present'),
(4, '2024-03-14 09:00:00', '2024-03-14 18:00:00', 'present'),
(4, '2024-03-15 00:00:00', NULL, 'absent'),
(4, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(4, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(4, '2024-03-20 00:00:00', NULL, 'absent'),
(4, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(4, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(4, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(4, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(4, '2024-03-27 00:00:00', NULL, 'absent'),
(4, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(4, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(4, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(4, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(4, '2024-04-03 00:00:00', NULL, 'absent'),
(4, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(4, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(4, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(4, '2024-04-09 00:00:00', NULL, 'leave'),
(4, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

-- Employee 5
(5, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(5, '2024-03-12 09:30:00', '2024-03-12 18:00:00', 'present'),
(5, '2024-03-13 00:00:00', NULL, 'absent'),
(5, '2024-03-14 09:00:00', '2024-03-14 18:00:00', 'present'),
(5, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(5, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(5, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(5, '2024-03-20 00:00:00', NULL, 'absent'),
(5, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(5, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(5, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(5, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(5, '2024-03-27 00:00:00', NULL, 'absent'),
(5, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(5, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(5, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(5, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(5, '2024-04-03 00:00:00', NULL, 'absent'),
(5, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(5, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(5, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(5, '2024-04-09 00:00:00', NULL, 'leave'),
(5, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

(6, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(6, '2024-03-12 09:20:00', '2024-03-12 18:00:00', 'present'),
(6, '2024-03-13 09:00:00', '2024-03-13 18:00:00', 'present'),
(6, '2024-03-14 09:10:00', '2024-03-14 17:30:00', 'present'),
(6, '2024-03-15 00:00:00', NULL, 'absent'),
(6, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(6, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(6, '2024-03-20 00:00:00', NULL, 'absent'),
(6, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(6, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(6, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(6, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(6, '2024-03-27 00:00:00', NULL, 'absent'),
(6, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(6, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(6, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(6, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(6, '2024-04-03 00:00:00', NULL, 'absent'),
(6, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(6, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(6, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(6, '2024-04-09 00:00:00', NULL, 'leave'),
(6, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

(7, '2024-03-11 00:00:00', NULL, 'leave'),
(7, '2024-03-12 09:00:00', '2024-03-12 18:00:00', 'present'),
(7, '2024-03-13 09:00:00', '2024-03-13 18:00:00', 'present'),
(7, '2024-03-14 09:00:00', '2024-03-14 17:30:00', 'present'),
(7, '2024-03-15 09:15:00', '2024-03-15 18:00:00', 'present'),
(7, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(7, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(7, '2024-03-20 00:00:00', NULL, 'absent'),
(7, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(7, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(7, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(7, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(7, '2024-03-27 00:00:00', NULL, 'absent'),
(7, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(7, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(7, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(7, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(7, '2024-04-03 00:00:00', NULL, 'absent'),
(7, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(7, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(7, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(7, '2024-04-09 00:00:00', NULL, 'leave'),
(7, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

(8, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(8, '2024-03-12 00:00:00', NULL, 'absent'),
(8, '2024-03-13 09:00:00', '2024-03-13 18:00:00', 'present'),
(8, '2024-03-14 09:10:00', '2024-03-14 17:45:00', 'present'),
(8, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(8, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(8, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(8, '2024-03-20 00:00:00', NULL, 'absent'),
(8, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(8, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(8, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(8, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(8, '2024-03-27 00:00:00', NULL, 'absent'),
(8, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(8, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(8, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(8, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(8, '2024-04-03 00:00:00', NULL, 'absent'),
(8, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(8, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(8, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(8, '2024-04-09 00:00:00', NULL, 'leave'),
(8, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

(9, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(9, '2024-03-12 09:20:00', '2024-03-12 18:00:00', 'present'),
(9, '2024-03-13 00:00:00', NULL, 'leave'),
(9, '2024-03-14 09:00:00', '2024-03-14 18:00:00', 'present'),
(9, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(9, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(9, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(9, '2024-03-20 00:00:00', NULL, 'absent'),
(9, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(9, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(9, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(9, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(9, '2024-03-27 00:00:00', NULL, 'absent'),
(9, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(9, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(9, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(9, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(9, '2024-04-03 00:00:00', NULL, 'absent'),
(9, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(9, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(9, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(9, '2024-04-09 00:00:00', NULL, 'leave'),
(9, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

(10, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(10, '2024-03-12 00:00:00', NULL, 'absent'),
(10, '2024-03-13 09:00:00', '2024-03-13 18:00:00', 'present'),
(10, '2024-03-14 09:00:00', '2024-03-14 17:45:00', 'present'),
(10, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(10, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(10, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(10, '2024-03-20 00:00:00', NULL, 'absent'),
(10, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(10, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(10, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(10, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(10, '2024-03-27 00:00:00', NULL, 'absent'),
(10, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(10, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(10, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(10, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(10, '2024-04-03 00:00:00', NULL, 'absent'),
(10, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(10, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(10, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(10, '2024-04-09 00:00:00', NULL, 'leave'),
(10, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

(11, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(11, '2024-03-12 09:15:00', '2024-03-12 18:00:00', 'present'),
(11, '2024-03-13 00:00:00', NULL, 'absent'),
(11, '2024-03-14 09:00:00', '2024-03-14 18:00:00', 'present'),
(11, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(11, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(11, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(11, '2024-03-20 00:00:00', NULL, 'absent'),
(11, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(11, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(11, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(11, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(11, '2024-03-27 00:00:00', NULL, 'absent'),
(11, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(11, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(11, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(11, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(11, '2024-04-03 00:00:00', NULL, 'absent'),
(11, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(11, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(11, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(11, '2024-04-09 00:00:00', NULL, 'leave'),
(11, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),


(12, '2024-03-11 00:00:00', NULL, 'leave'),
(12, '2024-03-12 09:00:00', '2024-03-12 18:00:00', 'present'),
(12, '2024-03-13 09:00:00', '2024-03-13 18:00:00', 'present'),
(12, '2024-03-14 09:10:00', '2024-03-14 17:30:00', 'present'),
(12, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(12, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(12, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(12, '2024-03-20 00:00:00', NULL, 'absent'),
(12, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(12, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(12, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(12, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(12, '2024-03-27 00:00:00', NULL, 'absent'),
(12, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(12, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(12, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(12, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(12, '2024-04-03 00:00:00', NULL, 'absent'),
(12, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(12, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(12, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(12, '2024-04-09 00:00:00', NULL, 'leave'),
(12, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

(13, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(13, '2024-03-12 09:20:00', '2024-03-12 18:00:00', 'present'),
(13,  NULL, NULL, 'leave'),
(13, '2024-03-14 09:00:00', '2024-03-14 18:00:00', 'present'),
(13, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(13, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(13, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(13, '2024-03-20 00:00:00', NULL, 'absent'),
(13, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(13, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(13, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(13, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(13, '2024-03-27 00:00:00', NULL, 'absent'),
(13, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(13, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(13, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(13, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(13, '2024-04-03 00:00:00', NULL, 'absent'),
(13, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(13, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(13, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(13, '2024-04-09 00:00:00', NULL, 'leave'),
(13, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

-- Employee 14
(14, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(14,  NULL, NULL, 'absent'),
(14, '2024-03-13 09:00:00', '2024-03-13 18:00:00', 'present'),
(14, '2024-03-14 09:00:00', '2024-03-14 17:45:00', 'present'),
(14, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(14, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(14, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(14, '2024-03-20 00:00:00', NULL, 'absent'),
(14, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(14, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(14, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(14, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(14, '2024-03-27 00:00:00', NULL, 'absent'),
(14, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(14, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(14, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(14, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(14, '2024-04-03 00:00:00', NULL, 'absent'),
(14, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(14, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(14, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(14, '2024-04-09 00:00:00', NULL, 'leave'),
(14, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

-- Employee 15
(15, '2024-03-11 09:00:00', '2024-03-11 18:00:00', 'present'),
(15, '2024-03-12 09:15:00', '2024-03-12 18:00:00', 'present'),
(15, NULL, NULL, 'absent'),
(15, '2024-03-14 09:00:00', '2024-03-14 18:00:00', 'present'),
(15, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(15, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(15, '2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(15, '2024-03-20 00:00:00', NULL, 'absent'),
(15, '2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(15, '2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(15, '2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(15, '2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(15, '2024-03-27 00:00:00', NULL, 'absent'),
(15, '2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(15, '2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(15, '2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(15, '2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(15, '2024-04-03 00:00:00', NULL, 'absent'),
(15, '2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(15, '2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(15, '2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(15, '2024-04-09 00:00:00', NULL, 'leave'),
(15, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present'),

-- Employee 16
(16,  NULL, NULL, 'leave'),
(16, '2024-03-12 09:00:00', '2024-03-12 18:00:00', 'present'),
(16, '2024-03-13 09:00:00', '2024-03-13 18:00:00', 'present'),
(16, '2024-03-14 09:10:00', '2024-03-14 17:30:00', 'present'),
(16, '2024-03-15 09:00:00', '2024-03-15 18:00:00', 'present'),
(16, '2024-03-18 09:00:00', '2024-03-18 18:00:00', 'present'),
(16,'2024-03-19 09:15:00', '2024-03-19 18:00:00', 'present'),
(16,'2024-03-20 00:00:00', NULL, 'absent'),
(16,'2024-03-21 09:05:00', '2024-03-21 17:45:00', 'leave'),
(16,'2024-03-22 09:00:00', '2024-03-22 18:00:00', 'present'),
(16,'2024-03-25 09:00:00', '2024-03-25 18:00:00', 'present'),
(16,'2024-03-26 09:15:00', '2024-03-26 18:00:00', 'present'),
(16,'2024-03-27 00:00:00', NULL, 'absent'),
(16,'2024-03-28 09:05:00', '2024-03-28 17:45:00', 'leave'),
(16,'2024-03-29 09:00:00', '2024-03-29 18:00:00', 'present'),
(16,'2024-04-01 09:10:00', '2024-04-01 18:00:00', 'present'),
(16,'2024-04-02 09:00:00', '2024-04-02 18:00:00', 'present'),
(16,'2024-04-03 00:00:00', NULL, 'absent'),
(16,'2024-04-04 09:15:00', '2024-04-04 18:00:00', 'present'),
(16,'2024-04-05 09:00:00', '2024-04-05 18:00:00', 'present'),
(16,'2024-04-08 09:10:00', '2024-04-08 18:00:00', 'present'),
(16,'2024-04-09 00:00:00', NULL, 'leave'),
(16, '2024-04-10 09:00:00', '2024-04-10 18:00:00', 'present');

-- leave requests
INSERT INTO leave_requests (employee_id, start_date, end_date, leave_type, status)
VALUES
-- Employee 1
(1, '2024-03-13', '2024-03-13', 'sick', 'pending'),
(1, '2024-03-14', '2024-03-14', 'casual', 'pending'),
(1, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(1, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(1, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(1, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(1, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(1, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 2
(2, '2024-03-12', '2024-03-12', 'sick', 'pending'),
(2, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(2, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(2, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(2, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(2, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(2, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 3
(3, '2024-03-14', '2024-03-14', 'casual', 'pending'),
(3, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(3, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(3, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(3, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(3, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(3, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 4
(4, '2024-03-11', '2024-03-11', 'casual', 'pending'),
(4, '2024-03-15', '2024-03-15', 'sick', 'pending'),
(4, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(4, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(4, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(4, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(4, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(4, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 5
(5, '2024-03-13', '2024-03-13', 'sick', 'pending'),
(5, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(5, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(5, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(5, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(5, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(5, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 6
(6, '2024-03-15', '2024-03-15', 'sick', 'pending'),
(6, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(6, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(6, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(6, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(6, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(6, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 7
(7, '2024-03-11', '2024-03-11', 'casual', 'pending'),
(7, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(7, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(7, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(7, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(7, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(7, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 8
(8, '2024-03-12', '2024-03-12', 'sick', 'pending'),
(8, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(8, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(8, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(8, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(8, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(8, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 9
(9, '2024-03-13', '2024-03-13', 'casual', 'pending'),
(9, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(9, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(9, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(9, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(9, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(9, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 10
(10, '2024-03-12', '2024-03-12', 'sick', 'pending'),
(10, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(10, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(10, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(10, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(10, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(10, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 11
(11, '2024-03-13', '2024-03-13', 'sick', 'pending'),
(11, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(11, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(11, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(11, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(11, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(11, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 12
(12, '2024-03-11', '2024-03-11', 'casual', 'pending'),
(12, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(12, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(12, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(12, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(12, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(12, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 13
(13, '2024-03-12', '2024-03-12', 'sick', 'pending'),
(13, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(13, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(13, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(13, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(13, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(13, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 14
(14, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(14, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(14, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(14, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(14, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(14, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 15
(15, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(15, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(15, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(15, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(15, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(15, '2024-04-09', '2024-04-09', 'casual', 'pending'),

-- Employee 16
(16, '2024-03-20', '2024-03-20', 'sick', 'pending'),
(16, '2024-03-21', '2024-03-21', 'casual', 'pending'),
(16, '2024-03-27', '2024-03-27', 'sick', 'pending'),
(16, '2024-03-28', '2024-03-28', 'casual', 'pending'),
(16, '2024-04-03', '2024-04-03', 'sick', 'pending'),
(16, '2024-04-09', '2024-04-09', 'casual', 'pending');

-- Payroll
INSERT INTO payroll (employee_id, salary, bonus, deductions, payment_date)
VALUES
(1, 50000.00, 5000.00, 2000.00, '2024-03-29'),
(2, 48000.00, 4500.00, 1800.00, '2024-03-29'),
(3, 47000.00, 4000.00, 1700.00, '2024-03-29'),
(4, 55000.00, 6000.00, 2500.00, '2024-03-29'),
(5, 52000.00, 5500.00, 2200.00, '2024-03-29'),
(6, 51000.00, 5200.00, 2100.00, '2024-03-29'),
(7, 49000.00, 5000.00, 2000.00, '2024-03-29'),
(8, 53000.00, 5700.00, 2300.00, '2024-03-29'),
(9, 50000.00, 5000.00, 2000.00, '2024-03-29'),
(10, 48000.00, 4500.00, 1800.00, '2024-03-29'),
(11, 47000.00, 4000.00, 1700.00, '2024-03-29'),
(12, 55000.00, 6000.00, 2500.00, '2024-03-29'),
(13, 52000.00, 5500.00, 2200.00, '2024-03-29'),
(14, 51000.00, 5200.00, 2100.00, '2024-03-29'),
(15, 49000.00, 5000.00, 2000.00, '2024-03-29'),
(16, 53000.00, 5700.00, 2300.00, '2024-03-29');

INSERT INTO performance_reviews (employee_id, reviewer_id, review_date, rating, comments)
VALUES
-- Employees 2 to 6 (Managers) reviewed by Employee 1
(2, 1, '2024-03-29', 5, 'Demonstrates excellent leadership and decision-making.'),
(3, 1, '2024-03-29', 4, 'Manages team well, but can improve delegation.'),
(4, 1, '2024-03-29', 5, 'Strong technical knowledge and mentoring skills.'),
(5, 1, '2024-03-29', 4, 'Maintains a balanced team, but needs better conflict resolution.'),
(6, 1, '2024-03-29', 5, 'Highly strategic and great at motivating employees.'),

-- Employees 7 to 16 reviewed by their respective managers
(7, 5, '2024-03-29', 3, 'Works well under pressure but needs to improve communication.'),
(8, 3, '2024-03-29', 2, 'Requires better time management skills.'),
(9, 3, '2024-03-29', 5, 'Excellent team player with leadership potential.'),
(10, 1, '2024-03-29', 4, 'Demonstrates great analytical skills.'),
(11, 2, '2024-03-29', 1, 'Struggles with deadlines, needs improvement.'),
(12, 3, '2024-03-29', 5, 'Great problem-solving skills and leadership qualities.'),
(13, 4, '2024-03-29', 3, 'Meets expectations but should enhance efficiency.'),
(14, 4, '2024-03-29', 2, 'Inconsistent performance, needs guidance.'),
(15, 5, '2024-03-29', 4, 'Shows potential and is willing to learn.'),
(16, 3, '2024-03-29', 5, 'Highly productive and a valuable asset to the team.');

-- Training
INSERT INTO training (employee_id, training_name, provider, start_date, end_date, status)
VALUES
-- Employee 2
(2, 'Leadership Development', 'Harvard Business School', '2023-12-27', '2024-01-27', 'completed'),
(2, 'Project Management Certification', 'PMI Institute', '2023-12-27', '2024-01-30', 'completed'),
(2, 'Strategic Decision Making', 'MIT Sloan', '2023-12-27', '2024-01-29', 'completed'),

-- Employee 3
(3, 'Leadership Development', 'Harvard Business School', '2023-12-27', '2024-01-27', 'completed'),
(3, 'Project Management Certification', 'PMI Institute', '2023-12-27', '2024-01-30', 'completed'),
(3, 'Strategic Decision Making', 'MIT Sloan', '2023-12-27', '2024-01-29', 'completed'),

-- Employee 4
(4, 'Leadership Development', 'Harvard Business School', '2023-12-27', '2024-01-27', 'completed'),
(4, 'Project Management Certification', 'PMI Institute', '2023-12-27', '2024-01-30', 'completed'),
(4, 'Strategic Decision Making', 'MIT Sloan', '2023-12-27', '2024-01-29', 'completed'),

-- Employee 5
(5, 'Leadership Development', 'Harvard Business School', '2023-12-27', '2024-01-27', 'completed'),
(5, 'Project Management Certification', 'PMI Institute', '2023-12-27', '2024-01-30', 'completed'),
(5, 'Strategic Decision Making', 'MIT Sloan', '2023-12-27', '2024-01-29', 'completed'),

-- Employee 6
(6, 'Leadership Development', 'Harvard Business School', '2023-12-27', '2024-01-27', 'completed'),
(6, 'Project Management Certification', 'PMI Institute', '2023-12-27', '2024-01-30', 'completed'),
(6, 'Strategic Decision Making', 'MIT Sloan', '2023-12-27', '2024-01-29', 'completed'),

-- Employee 7
(7, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'completed'),
(7, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'ongoing'),
(7, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'pending'),
(7, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'completed'),
(7, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'ongoing'),

-- Employee 8
(8, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'pending'),
(8, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'completed'),
(8, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'ongoing'),
(8, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'pending'),
(8, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'completed'),

-- Employee 9
(9, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'ongoing'),
(9, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'pending'),
(9, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'completed'),
(9, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'ongoing'),
(9, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'completed'),

-- Employee 10
(10, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'completed'),
(10, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'pending'),
(10, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'ongoing'),
(10, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'completed'),
(10, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'pending'),

-- Employee 11
(11, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'pending'),
(11, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'completed'),
(11, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'ongoing'),
(11, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'completed'),
(11, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'ongoing'),

-- Employee 12
(12, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'completed'),
(12, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'pending'),
(12, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'ongoing'),
(12, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'completed'),
(12, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'pending'),

-- Employee 13
(13, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'ongoing'),
(13, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'pending'),
(13, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'completed'),
(13, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'ongoing'),
(13, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'completed'),

-- Employee 14
(14, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'completed'),
(14, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'pending'),
(14, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'ongoing'),
(14, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'completed'),
(14, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'pending'),

-- Employee 15
(15, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'pending'),
(15, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'completed'),
(15, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'ongoing'),
(15, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'completed'),
(15, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'ongoing'),

-- Employee 16
(16, 'Time Management & Productivity', 'Coursera', '2023-12-27', '2024-01-27', 'completed'),
(16, 'Communication Skills', 'Udemy', '2023-12-27', '2024-01-30', 'pending'),
(16, 'Technical Skill Development', 'Pluralsight', '2023-12-27', '2024-02-10', 'ongoing'),
(16, 'Problem Solving & Critical Thinking', 'HarvardX', '2023-12-27', '2024-02-15', 'completed'),
(16, 'Workplace Ethics & Professionalism', 'LinkedIn Learning', '2023-12-27', '2024-02-20', 'pending');

-- users
INSERT INTO users (employee_id, username, password_hash, role) VALUES
(1, 'jmathew', 'hashed_password_1', 'admin'),
(2, 'arunkumar', 'hashed_password_2', 'manager'),
(3, 'mohanraj', 'hashed_password_3', 'manager'),
(4, 'prakashv', 'hashed_password_4', 'manager'),
(5, 'sureshg', 'hashed_password_5', 'manager'),
(6, 'vignesht', 'hashed_password_6', 'manager'),
(7, 'bharaths', 'hashed_password_7', 'employee'),
(8, 'karthikm', 'hashed_password_8', 'employee'),
(9, 'dineshr', 'hashed_password_9', 'employee'),
(10, 'saravananp', 'hashed_password_10', 'employee'),
(11, 'rajkumarl', 'hashed_password_11', 'employee'),
(12, 'gokulb', 'hashed_password_12', 'employee'),
(13, 'santhoshk', 'hashed_password_13', 'employee'),
(14, 'yuvaraja', 'hashed_password_14', 'employee'),
(15, 'sathishj', 'hashed_password_15', 'employee'),
(16, 'praveenv', 'hashed_password_16', 'employee');

-- 1. View: Active Employees
CREATE VIEW ActiveEmployees AS
SELECT employee_id, first_name, last_name, email, job_id, department_id, salary
FROM employees
WHERE status = 'active';

-- 2. View: Department-wise Salary
CREATE VIEW DepartmentSalary AS
SELECT d.department_id, d.department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- 3. View: Employee Details
CREATE VIEW EmployeeDetails AS
SELECT e.employee_id, e.first_name, e.last_name, e.email, e.phone, j.job_title, d.department_name, e.salary, e.status
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
JOIN departments d ON e.department_id = d.department_id;

-- 4. Stored Procedure: Add Employee
DELIMITER //
CREATE PROCEDURE AddEmployee(
    IN fname VARCHAR(50),
    IN lname VARCHAR(50),
    IN email VARCHAR(100),
    IN phone VARCHAR(15),
    IN dept_id INT,
    IN job_id INT,
    IN manager INT,
    IN hire DATE,
    IN sal DECIMAL(10,2)
)
BEGIN
    INSERT INTO employees (first_name, last_name, email, phone, department_id, job_id, manager_id, hire_date, salary, status)
    VALUES (fname, lname, email, phone, dept_id, job_id, manager, hire, sal, 'active');
END //
DELIMITER ;

-- 5. Stored Procedure: Update Employee Salary
DELIMITER //
CREATE PROCEDURE UpdateSalary(
    IN emp_id INT,
    IN new_salary DECIMAL(10,2)
)
BEGIN
    UPDATE employees SET salary = new_salary WHERE employee_id = emp_id;
END //
DELIMITER ;

-- 6. Stored Procedure: Delete Employee
DELIMITER //
CREATE PROCEDURE DeleteEmployee(
    IN emp_id INT
)
BEGIN
    DELETE FROM employees WHERE employee_id = emp_id;
END //
DELIMITER ;

-- 7. Stored Procedure: Get Employees in a Department
DELIMITER //
CREATE PROCEDURE GetEmployeesByDepartment(
    IN dept_id INT
)
BEGIN
    SELECT * FROM employees WHERE department_id = dept_id;
END //
DELIMITER ;

-- 8. Stored Procedure: Get Department Budget
DELIMITER //
CREATE PROCEDURE GetDepartmentBudget(
    IN dept_id INT
)
BEGIN
    SELECT SUM(salary) AS total_budget FROM employees WHERE department_id = dept_id;
END //
DELIMITER ;

-- 9. Stored Procedure: Promote Employee
DELIMITER //
CREATE PROCEDURE PromoteEmployee(
    IN emp_id INT,
    IN new_job_id INT,
    IN new_salary DECIMAL(10,2)
)
BEGIN
    UPDATE employees SET job_id = new_job_id, salary = new_salary WHERE employee_id = emp_id;
END //
DELIMITER ;

-- 10. Stored Procedure: Employee Count by Department
DELIMITER //
CREATE PROCEDURE EmployeeCountByDepartment()
BEGIN
    SELECT department_id, COUNT(*) AS employee_count FROM employees GROUP BY department_id;
END //
DELIMITER ;

CALL AddEmployee('Suresh', 'Kumar', 'skumar@email.com', '1234567890', 2, 5, 1, '2024-01-01', 60000.00);
CALL UpdateSalary(101, 75000.00);
CALL DeleteEmployee(105);
CALL GetEmployeesByDepartment(3);
CALL GetDepartmentBudget(4);
CALL EmployeeCountByDepartment();


