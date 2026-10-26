-- ========================================================================
-- Doctor Appointment & Patient Medical Record Schedule
-- =========================================================================
--  Contents:
--    PART 1  : Database & Table Creation (schema)
--    PART 2  : Sample Data (INSERT statements)
--    PART 3  : Indexes
--    PART 4  : Views
--    PART 5  : Stored Procedures
--    PART 6  : Triggers (+ supporting stock_log table)
--    PART 7  : Query Bank - Level 1 (Original Q1-Q4)   
--    PART 8  : Query Bank - Level 2 (Original Q5-Q8)   
--    PART 9  : Query Bank - Level 3 (Original Q9-Q11)  
--    PART 10 : Query Bank - New Queries (Q12-Q21)      
--
--  RDBMS   : MySQL 8.0+ (also compatible with MariaDB 10.x)
--  Notes   : Every ANSWER below each query is a comment showing what
--            that query returns when run against the sample data in
--            PART 2. Run the SELECT yourself to confirm.
-- =====================================================================

-- ============================================================
-- PART 1: CREATE DATABASE AND USE IT
-- ============================================================
CREATE DATABASE CLINIC_MANAGEMENT_DA7;
USE CLINIC_MANAGEMENT_DA7; 
SHOW TABLES;
-- ============================================================
-- PART 2: CREATE TABLES (DDL)
-- ============================================================
-- 2.1 Create Doctors table (Strong Entity)
CREATE TABLE DOCTORS (
doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_name VARCHAR(100) NOT NULL,
    specialization ENUM(
        'General Medicine',
        'Pediatrics',
        'Cardiology',
        'Neurology',
        'Orthopedics'
    ),
    consultation_fee DECIMAL(10,2) NOT NULL,
    experience_years INT NOT NULL );
    
-- 2.2 Create Patients table (Strong Entity)    
    CREATE TABLE PATIENTS (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL,
    birth_date DATE,
 email VARCHAR(100) UNIQUE,
 phone_number BIGINT,
 city VARCHAR(50) DEFAULT 'Hyderabad'
 );
 
 -- 2.3 Create Appointments table (Strong Entity)
 CREATE TABLE  appointments (
 appointment_id INT PRIMARY KEY AUTO_INCREMENT,
 patient_id INT,
 doctor_id INT,
 appointment_date DATE,
 appointment_time TIME,
 status VARCHAR(20) DEFAULT 'Scheduled'
);
 
 -- 2.4 Create Medical records table
 CREATE TABLE  medical_records (
 record_id INT PRIMARY KEY AUTO_INCREMENT,
 patient_id INT,
 diagnosis_notes TEXT NOT NULL,
 prescribed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2.5 Create Billing Ledger table(with generated GST column)
CREATE TABLE  billing_ledger (
 bill_id INT PRIMARY KEY AUTO_INCREMENT,
 appointment_id INT,
 base_amount DECIMAL(10,2),
 total_with_gst DECIMAL(10,2),
 payment_status ENUM('Paid','Unpaid') DEFAULT 'Unpaid'
);

-- 2.6 Create Doctor Audit table
 CREATE TABLE  doctor_audit (
 audit_id INT PRIMARY KEY AUTO_INCREMENT,
 doctor_id INT,
 action_type VARCHAR(50),
 old_fee DECIMAL(10,2),
 new_fee DECIMAL(10,2),
 action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2.7 Verify structure
SHOW TABLES;
DESC doctors;
DESC patients;
DESC appointments;
DESC medical_records;
DESC billing_ledger;
DESC doctor_audit;
-- ============================================================
-- PART 3: INSERT SAMPLE DATA (DML)
-- ============================================================
-- 3.1 Doctors
INSERT INTO doctors (doctor_name, specialization, consultation_fee, experience_years) VALUES
('Dr Ravi Kumar',    'Cardiology',       1500.00, 12),
('Dr Anjali Sharma', 'Pediatrics',        800.00,  6),
('Dr Amit Patel',    'General Medicine',  500.00,  4);

-- 3.2 Patients
INSERT INTO patients (first_name, last_name, gender, birth_date, email, phone_number, city) VALUES
('Rahul', 'Verma', 'M', '1995-04-12', 'rahul.verma@example.com', 9876500001, 'Hyderabad'),
('Sneha', 'Reddy', 'F', '2000-08-21', 'sneha.reddy@example.com', 9876500002, 'Visakhapatnam'),
('Kiran', 'Rao',   'M', '1988-01-05', 'kiran.rao@example.com',   9876500003, 'Bengaluru');

-- 3.3 Appointments
INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, status) VALUES
(1, 1, '2026-11-20', '10:00:00', 'Completed'),
(2, 2, '2026-11-21', '11:30:00', 'Scheduled'),
(3, 3, '2026-11-22', '09:15:00', 'Scheduled');

-- 3.4 Medical Records
INSERT INTO medical_records (patient_id, diagnosis_notes) VALUES
(1, 'Follow-up consultation for blood pressure monitoring.'),
(2, 'General pediatric assessment: follow-up as advised.'),
(3, 'Routine consultation: lifestyle guidance provided.');

-- 3.5 Billing
INSERT INTO billing_ledger (appointment_id, base_amount, payment_status) VALUES
(1, 1500.00, 'Paid'),
(2,  800.00, 'Unpaid');

-- 3.6 Verify data
SELECT * FROM doctors;
SELECT * FROM patients;
SELECT * FROM appointments;
SELECT * FROM medical_records;
SELECT * FROM billing_ledger;
SELECT * FROM doctor_audit;
 -- ============================================================
-- PART 4: INDEXES
-- ============================================================
-- 4.1 Create Indexs

CREATE INDEX idx_appointments_date          ON appointments(appointment_date);
CREATE INDEX idx_appointments_doctor_date   ON appointments(doctor_id, appointment_date);
CREATE INDEX idx_patients_city              ON patients(city);
CREATE INDEX idx_medical_records_patient    ON medical_records(patient_id);
CREATE INDEX idx_billing_appointment        ON billing_ledger(appointment_id);
CREATE INDEX idx_appointments_status        ON appointments(status);
CREATE INDEX idx_doctors_specialization     ON doctors(specialization);
-- Verify 
-- SHOW INDEX FROM appointments;
-- SHOW INDEX FROM patients;
-- SHOW INDEX FROM doctors;
-- ============================================================
-- PART 5: VIEWS
-- ============================================================
-- 5.1 View for Complete Appointment Details 

CREATE OR REPLACE VIEW view_appointment_details AS
SELECT a.appointment_id,
       CONCAT(p.first_name,' ',p.last_name) AS patient_name,
       p.city AS patient_city,
       d.doctor_name, d.specialization,
       a.appointment_date, a.appointment_time, a.status,
       IFNULL(b.payment_status,'No Bill') AS payment_status,
       b.total_with_gst
FROM appointments a
JOIN patients p ON p.patient_id = a.patient_id
JOIN doctors  d ON d.doctor_id  = a.doctor_id
LEFT JOIN billing_ledger b ON b.appointment_id = a.appointment_id;

-- 5.2 View for Unpaid Bills Follow-up

CREATE OR REPLACE VIEW view_unpaid_bills AS
SELECT b.bill_id, b.appointment_id,
       CONCAT(p.first_name,' ',p.last_name) AS patient_name,
       d.doctor_name, b.base_amount, b.total_with_gst, b.payment_status
FROM billing_ledger b
JOIN appointments a ON a.appointment_id = b.appointment_id
JOIN patients p     ON p.patient_id = a.patient_id
JOIN doctors  d     ON d.doctor_id  = a.doctor_id
WHERE b.payment_status = 'Unpaid';

-- 5.3 View for Lifetime Spend per Patient

CREATE OR REPLACE VIEW view_patient_spend AS
SELECT p.patient_id,
       CONCAT(p.first_name,' ',p.last_name) AS patient_name,
       COUNT(b.bill_id) AS total_bills,
       COALESCE(SUM(b.base_amount), 0) AS total_spent
FROM patients p
LEFT JOIN appointments a ON a.patient_id = p.patient_id
LEFT JOIN billing_ledger b ON b.appointment_id = a.appointment_id
GROUP BY p.patient_id, p.first_name, p.last_name;

-- 5.4 View for Doctor Workload Ranking

CREATE OR REPLACE VIEW view_doctor_workload AS
SELECT d.doctor_id, d.doctor_name,
       COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.doctor_name;

-- ============================================================
-- PART 6: Stored Procedures
-- ============================================================
-- 6.1 Procedure to Get Patient Appointments

DROP PROCEDURE IF EXISTS sp_get_patient_appointments;

DELIMITER //
CREATE PROCEDURE sp_get_patient_appointments(IN p_patient_id INT)
BEGIN
    SELECT a.appointment_id, a.appointment_date, a.appointment_time,
           d.doctor_name, d.specialization, a.status
    FROM appointments a
    JOIN doctors d ON d.doctor_id = a.doctor_id
    WHERE a.patient_id = p_patient_id
    ORDER BY a.appointment_date, a.appointment_time;
END //
DELIMITER ;

-- 6.2 Procedure to Process New Appointment (Transactional)

DROP PROCEDURE IF EXISTS sp_process_new_appointment;
DELIMITER //
CREATE PROCEDURE sp_process_new_appointment(
    IN  p_patient_id INT,
    IN  p_doctor_id  INT,
    IN  p_appointment_date DATE,
    IN  p_appointment_time TIME,
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE v_fee DECIMAL(10,2);
    DECLARE v_appointment_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Booking failed: transaction rolled back';
    END;
    START TRANSACTION;
    SELECT consultation_fee INTO v_fee
    FROM doctors WHERE doctor_id = p_doctor_id;
    IF v_fee IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor does not exist';
    END IF;
    INSERT INTO appointments
        (patient_id, doctor_id, appointment_date, appointment_time, status)
    VALUES
        (p_patient_id, p_doctor_id, p_appointment_date, p_appointment_time, 'Scheduled');
    SET v_appointment_id = LAST_INSERT_ID();
    INSERT INTO billing_ledger (appointment_id, base_amount, payment_status)
    VALUES (v_appointment_id, v_fee, 'Unpaid');
    COMMIT;
    SET p_result = 'Appointment and bill created successfully';
END //
DELIMITER ;

-- 6.3 Procedure for Revenue Report by Specialization

DROP PROCEDURE IF EXISTS sp_revenue_by_specialization;
DELIMITER //
CREATE PROCEDURE sp_revenue_by_specialization()
BEGIN
    SELECT d.specialization,
           COUNT(b.bill_id)      AS bills_count,
           SUM(b.base_amount)    AS total_base_amount,
           SUM(b.total_with_gst) AS total_with_gst
    FROM doctors d
    JOIN appointments a   ON a.doctor_id = d.doctor_id
    JOIN billing_ledger b ON b.appointment_id = a.appointment_id
    GROUP BY d.specialization
    ORDER BY total_with_gst DESC;
END //
DELIMITER ;

-- 6.4 Procedure to Update Doctor Fee

DROP PROCEDURE IF EXISTS sp_update_doctor_fee;
DELIMITER //
CREATE PROCEDURE sp_update_doctor_fee(
    IN p_doctor_id INT,
    IN p_new_fee DECIMAL(10,2)
)
BEGIN
    UPDATE doctors SET consultation_fee = p_new_fee
    WHERE doctor_id = p_doctor_id;
END //
DELIMITER ;
-- ============================================================
-- PART 7: Triggers
-- ============================================================
-- 7.1 Create Audit Table for Doctor Fee Changes

CREATE TABLE doctor_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT,
    action_type VARCHAR(50),
    old_fee DECIMAL(10,2),
    new_fee DECIMAL(10,2),
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7.2 Trigger to Prevent Schedule Conflicts

DROP TRIGGER IF EXISTS trg_validate_schedule_conflict;
DELIMITER $$
CREATE TRIGGER trg_validate_schedule_conflict
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
    IF NEW.status <> 'Cancelled' AND EXISTS (
        SELECT 1 FROM appointments a
        WHERE a.doctor_id = NEW.doctor_id
          AND a.appointment_date = NEW.appointment_date
          AND a.appointment_time = NEW.appointment_time
          AND a.status <> 'Cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor already has an appointment at this time';
    END IF;
END $$
DELIMITER ;


-- 7.3 Trigger to Audit Doctor Fee Shifts

DROP TRIGGER IF EXISTS trg_audit_doctor_fee_shift;
DELIMITER $$
CREATE TRIGGER trg_audit_doctor_fee_shift
AFTER UPDATE ON doctors
FOR EACH ROW
BEGIN
    IF OLD.consultation_fee <> NEW.consultation_fee THEN
        INSERT INTO doctor_audit
            (doctor_id, action_type, old_fee, new_fee)
        VALUES
            (NEW.doctor_id, 'CONSULTATION_FEE_UPDATE',
             OLD.consultation_fee, NEW.consultation_fee);
    END IF;
END $$
DELIMITER ;

-- 7.4 Trigger to Block Deleting a Doctor with Appointments

DROP TRIGGER IF EXISTS trg_block_doctor_delete;
DELIMITER $$
CREATE TRIGGER trg_block_doctor_delete
BEFORE DELETE ON doctors
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM appointments WHERE doctor_id = OLD.doctor_id;
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete doctor: appointments still reference this doctor';
    END IF;
END $$
DELIMITER ;

-- 7.5 Trigger to Auto-Fill Bill Amount

DROP TRIGGER IF EXISTS trg_autofill_bill_amount;
DELIMITER //

CREATE TRIGGER trg_autofill_bill_amount
BEFORE INSERT ON billing_ledger
FOR EACH ROW
BEGIN
    IF NEW.base_amount IS NULL THEN
        SET NEW.base_amount = (
            SELECT d.consultation_fee
            FROM appointments a
            JOIN doctors d
                ON d.doctor_id = a.doctor_id
            WHERE a.appointment_id = NEW.appointment_id
        );
    END IF;
END //

DELIMITER ;
-- ============================================================
-- PART 8: basic Queries
-- ============================================================

-- Retrieve the name and specialization of all doctors.
SELECT doctor_name, specialization FROM doctors;

-- Find appointment IDs whose status is 'Scheduled' or 'Completed'.
SELECT appointment_id, status FROM appointments
WHERE status IN ('Scheduled','Completed');

-- List all bills where base_amount is greater than 800.
SELECT * FROM billing_ledger WHERE base_amount > 800;

-- Find the phone numbers of all patients living in 'Hyderabad'.
SELECT first_name, last_name, phone_number FROM patients WHERE city = 'Hyderabad';

-- How many bills are 'Unpaid'?
SELECT COUNT(*) AS unpaid_bills FROM billing_ledger WHERE payment_status = 'Unpaid';

-- Count how many appointments Dr Anjali Sharma has.
SELECT COUNT(*) AS appointment_count
FROM appointments
WHERE doctor_id = (SELECT doctor_id FROM doctors WHERE doctor_name = 'Dr Anjali Sharma');

-- List the Patient Name, Appointment Date, and Doctor Name for every appointment.
SELECT CONCAT(p.first_name,' ',p.last_name) AS patient_name,
       a.appointment_date,
       d.doctor_name
FROM appointments a
JOIN patients p ON p.patient_id = a.patient_id
JOIN doctors  d ON d.doctor_id  = a.doctor_id
ORDER BY a.appointment_date;

-- Total money earned through each specialization.
SELECT d.specialization, SUM(b.base_amount) AS revenue
FROM doctors d
JOIN appointments a   ON a.doctor_id = d.doctor_id
JOIN billing_ledger b ON b.appointment_id = a.appointment_id
GROUP BY d.specialization;

-- which doctor has the most appointments?
SELECT d.doctor_name, COUNT(a.appointment_id) AS total_appointments
FROM doctors d
JOIN appointments a ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_name
ORDER BY total_appointments DESC
LIMIT 1;

-- patients who were billed more than 1000 in total.
SELECT CONCAT(p.first_name,' ',p.last_name) AS patient_name,
       SUM(b.base_amount) AS total_spent
FROM patients p
JOIN appointments a   ON a.patient_id = p.patient_id
JOIN billing_ledger b ON b.appointment_id = a.appointment_id
GROUP BY p.patient_id, p.first_name, p.last_name
HAVING SUM(b.base_amount) > 1000;

-- patient_name, base_amount, doctor_name for bills where payment is 'Unpaid'.
SELECT CONCAT(p.first_name,' ',p.last_name) AS patient_name,
       b.base_amount,
       d.doctor_name
FROM billing_ledger b
JOIN appointments a ON a.appointment_id = b.appointment_id
JOIN patients p     ON p.patient_id = a.patient_id
JOIN doctors  d     ON d.doctor_id  = a.doctor_id
WHERE b.payment_status = 'Unpaid';

-- Appointments scheduled after 1 Jan 2026.
SELECT appointment_id, appointment_date, status
FROM appointments
WHERE appointment_date > '2026-01-01'
ORDER BY appointment_date;

-- Which doctor is treating 'Kiran Rao'?
SELECT d.doctor_name, d.specialization, d.consultation_fee
FROM doctors d
JOIN appointments a ON a.doctor_id = d.doctor_id
JOIN patients p     ON p.patient_id = a.patient_id
WHERE p.first_name = 'Kiran' AND p.last_name = 'Rao';

-- Average consultation fee (overall).
SELECT ROUND(AVG(consultation_fee), 2) AS avg_fee FROM doctors;

-- Patients who have never had an appointment.
SELECT CONCAT(p.first_name,' ',p.last_name) AS patient_name
FROM patients p
LEFT JOIN appointments a ON a.patient_id = p.patient_id
WHERE a.appointment_id IS NULL;

-- Total billed amount per patient (including patients with 0 bills).
SELECT CONCAT(p.first_name,' ',p.last_name) AS patient_name,
       COALESCE(SUM(b.base_amount), 0) AS total_billed
FROM patients p
LEFT JOIN appointments a   ON a.patient_id = p.patient_id
LEFT JOIN billing_ledger b ON b.appointment_id = a.appointment_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY total_billed DESC;

-- Second-highest bill amount.
SELECT DISTINCT base_amount
FROM billing_ledger
ORDER BY base_amount DESC
LIMIT 1 OFFSET 1;

-- Number of medical records per patient.
SELECT patient_id, COUNT(*) AS record_count
FROM medical_records
GROUP BY patient_id
ORDER BY patient_id;

-- Patients with no medical record.
SELECT CONCAT(p.first_name,' ',p.last_name) AS patient_name
FROM patients p
LEFT JOIN medical_records mr ON mr.patient_id = p.patient_id
WHERE mr.record_id IS NULL;

--  City-wise total revenue.
SELECT p.city, SUM(b.base_amount) AS city_revenue
FROM patients p
JOIN appointments a   ON a.patient_id = p.patient_id
JOIN billing_ledger b ON b.appointment_id = a.appointment_id
GROUP BY p.city
ORDER BY city_revenue DESC;

-- Number of appointments per doctor (including doctors with 0 appointments).
SELECT d.doctor_name, COUNT(a.appointment_id) AS appointment_count
FROM doctors d
LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_name
ORDER BY appointment_count DESC;

-- ==================================================================================
-- END of the Project
-- =====================================================================================

















































































    
    
    
    
    