# 🏥 Doctor Appointment & Patient Medical Record Schedule

## 📖 Project Overview

The **Doctor Appointment & Patient Medical Record Schedule** is a relational database management project developed using MySQL. The main objective of this project is to manage patient details, doctor information, appointments, and patient medical records efficiently.

In a manual system, maintaining patient information, doctor schedules, appointment details, and medical histories can be difficult. Records may be duplicated or misplaced, and retrieving information can take time.

To solve these problems, this project uses a relational database that stores information in separate but connected tables. Primary keys, foreign keys, constraints, and SQL queries help maintain data accuracy, consistency, and easy retrieval.

## 🎯 Project Objectives

- Store and manage patient information.
- Maintain doctor details and specializations.
- Schedule and track doctor appointments.
- Maintain patient medical records and treatment details.
- Establish relationships between database tables.
- Retrieve information efficiently using SQL queries.
- Generate useful reports about appointments and medical histories.
- Demonstrate SQL concepts learned during training.

## ✨ Features

- Relational database design.
- Table creation with appropriate data types.
- Primary keys and foreign keys.
- Constraints such as `NOT NULL`, `UNIQUE`, `DEFAULT`, and `CHECK`, where applicable.
- Insertion, updating, deletion, and retrieval of records.
- Appointment scheduling and status tracking.
- Patient medical record management.
- SQL queries using filtering, sorting, and aggregate functions.
- Joins and subqueries for retrieving related information.
- Views, indexes, triggers, and stored procedures, where implemented.
- Reports for doctors, patients, and appointments.

## 🛠️ Technologies Used

- **Database:** MySQL
- **Query Language:** SQL
- **Database Tool:** MySQL Workbench / MySQL Command Line Client

## 🗄️ Database Name

 CLINIC_MANAGEMENT_DA7

## 📋 Main Modules

1. **Patient Management:** Stores patient details such as name, age or date of birth, contact information, and gender, as applicable.
2. **Doctor Management:** Stores doctor information, specialization, contact details, and consultation fees.
3. **Appointment Management:** Maintains appointment dates, times, patient details, assigned doctors, and appointment status.
4. **Medical Record Management:** Stores diagnosis, treatment details, prescriptions, and medical history.
5. **Reporting and Analysis:** Retrieves appointment information, doctor schedules, patient histories, and other useful statistics using SQL queries.

## 🔗 Database Relationships

The database uses relationships between tables to avoid unnecessary duplication and maintain data consistency.

- One patient can have multiple appointments.
- One doctor can attend multiple appointments.
- Each appointment connects a patient with a doctor.
- A patient can have multiple medical records.
- Medical records can be linked to the relevant patient and appointment, depending on the database design.

These relationships are implemented using primary keys and foreign keys.

## ⚙️ SQL Concepts Implemented

### 🟢 Basic SQL Concepts
- `CREATE DATABASE` and `CREATE TABLE`
- `INSERT`, `SELECT`, `UPDATE`, and `DELETE`
- `WHERE` clause
- `DISTINCT`
- `ORDER BY` and `LIMIT`
- Operators such as `AND`, `OR`, and `NOT`
- `BETWEEN`, `IN`, `LIKE`, and `IS NULL`

### 🟡 Intermediate SQL Concepts
- Aggregate functions: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, and `MAX()`
- `GROUP BY` and `HAVING`
- Primary and foreign key constraints
- `ALTER TABLE`
- `UNIQUE`, `NOT NULL`, `DEFAULT`, and `CHECK` constraints
- Date and string functions

### 🔴 Advanced SQL Concepts
- `INNER JOIN`, `LEFT JOIN`, and `RIGHT JOIN`
- Multiple-table joins
- Subqueries
- Views
- Indexes
- Triggers
- Stored procedures
- Transaction handling using `COMMIT` and `ROLLBACK`

*The advanced concepts listed above should be marked as implemented only when their SQL objects or statements are included in the final project.*

## ▶️ How to Run the Project

1. Install MySQL Server and MySQL Workbench, or open the MySQL Command Line Client.
2. Open the SQL script for this project.
3. Select the project database:

   ```sql
   USE doctor_appointment_db;
   ```

4. Execute the table creation statements in the correct order, starting with parent tables and then creating dependent tables.
5. Insert sample data into the tables while following primary key and foreign key rules.
6. Execute the SQL queries to test the database.
7. Verify the results using `SELECT` statements.
8. If included, test the views, triggers, and stored procedures.

## 📊 Sample Queries

### 1. Display all patients

```sql
SELECT * FROM patients;
```

### 2. Display all doctors

```sql
SELECT * FROM doctors;
```

### 3. View appointment details

```sql
SELECT * FROM appointments;
```

### 4. Count appointments

```sql
SELECT COUNT(*) AS total_appointments
FROM appointments;
```

### 5. Display appointments with patient and doctor names

```sql
SELECT
    a.appointment_id,
    p.patient_name,
    d.doctor_name,
    a.appointment_date,
    a.status
FROM appointments a
INNER JOIN patients p
    ON a.patient_id = p.patient_id
INNER JOIN doctors d
    ON a.doctor_id = d.doctor_id;
```

*Note: Adjust table and column names in these examples to match your actual database schema.*

## 🎓 Learning Outcomes

Through this project, the following concepts can be practised and demonstrated:

- Designing a relational database.
- Understanding primary keys and foreign keys.
- Creating and managing related tables.
- Applying database constraints.
- Writing basic, intermediate, and advanced SQL queries.
- Using joins and subqueries to retrieve information.
- Analysing appointment data using aggregate functions.
- Understanding database normalization and data integrity.
- Implementing database objects such as views, triggers, and stored procedures when required.

## 🔮 Future Scope

- Develop a web application for patients and doctors.
- Add online appointment booking.
- Implement appointment reminders through email or SMS.
- Add doctor availability management.
- Generate prescriptions and medical reports.
- Introduce role-based access for administrators, doctors, and receptionists.
- Integrate a dashboard for appointment statistics.

## 👩‍💻 Author

**Saranya Reddy**

MySQL Data Analytics Trainee

## 📝 Conclusion

The Doctor Appointment & Patient Medical Record Schedule project provides a structured way to manage patient details, doctor information, appointments, and medical records using MySQL. It demonstrates how relational database concepts and SQL queries can improve data organization, consistency, and retrieval compared with manual record management."# Doctor_Appointment_Patient_Medical_Record_Schedule" 
