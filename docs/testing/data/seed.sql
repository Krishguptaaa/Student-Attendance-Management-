-- =============================================================
-- SAMS synthetic test data (MySQL 8) - run AFTER schema.sql
-- Re-running this file always returns the database to the same
-- baseline (it starts by emptying all tables).
--
-- ALL DATA IS SYNTHETIC. Never load real student data.
--
-- Login passwords (bcrypt-hashed below):
--   admins   -> Admin@1234
--   teachers -> Teacher@1234
--   students -> Student@1234
--
-- ID scheme:  admins 1-3 | teachers 4-13 | students 101-304
--             (student id = 100 + roll number, e.g. STU001 = 101)
-- =============================================================
USE attendance_db;

-- ---- reset to empty -------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE attendance_records;
TRUNCATE TABLE attendance_sessions;
TRUNCATE TABLE enrollments;
TRUNCATE TABLE sections;
TRUNCATE TABLE courses;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

SET @admin_pw   = '$2b$10$grhdVdCITNy2UvBHJc68Ru71sn9JABUOW/eb278TsD2UF27Jgc8Pi';
SET @teacher_pw = '$2b$10$dD2PPkeQLQ5wIWZAe7zDJ.mxneXFvUtq2JB2oP4utvvfysIdyNhdu';
SET @student_pw = '$2b$10$A6tn16hqzCxhopDCdyS40OwZwvDnZr.5nB5EaJXRy6oEJQSZl0Cim';

-- ---- users: 3 admins ------------------------------------------------
INSERT INTO users (id, email, password_hash, full_name, role, roll_number, is_active)
WITH RECURSIVE a AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM a WHERE i < 3)
SELECT i, CONCAT('admin', i, '@sams.test'), @admin_pw,
       CONCAT('Admin ', i), 'ADMIN', NULL, TRUE
FROM a;

-- ---- users: 10 teachers (ids 4-13) ----------------------------------
INSERT INTO users (id, email, password_hash, full_name, role, roll_number, is_active)
WITH RECURSIVE t AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM t WHERE i < 10)
SELECT 3 + i, CONCAT('teacher', LPAD(i, 2, '0'), '@sams.test'), @teacher_pw,
       CONCAT('Teacher ', LPAD(i, 2, '0')), 'TEACHER', NULL, TRUE
FROM t;

-- ---- users: students -------------------------------------------------
-- STU001-STU200 : active, all enrolled
-- STU201-STU203 : DEACTIVATED (login must be refused, F-003)
-- STU204        : active but enrolled nowhere (roster/attendance rejection, F-007)
INSERT INTO users (id, email, password_hash, full_name, role, roll_number, is_active)
WITH RECURSIVE s AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM s WHERE i < 204)
SELECT 100 + i, CONCAT('stu', LPAD(i, 3, '0'), '@sams.test'), @student_pw,
       CONCAT('Student ', LPAD(i, 3, '0')), 'STUDENT', CONCAT('STU', LPAD(i, 3, '0')),
       (i <= 200 OR i = 204)
FROM s;

-- ---- courses: 8 ------------------------------------------------------
INSERT INTO courses (id, code, name, description, credits) VALUES
(1, 'CS101', 'Programming Fundamentals', 'Synthetic test course', 4),
(2, 'CS102', 'Data Structures',          'Synthetic test course', 4),
(3, 'CS201', 'Database Systems',         'Synthetic test course', 4),
(4, 'CS202', 'Operating Systems',        'Synthetic test course', 4),
(5, 'CS203', 'Computer Networks',        'Synthetic test course', 3),
(6, 'CS301', 'Software Engineering',     'Synthetic test course', 3),
(7, 'MA101', 'Discrete Mathematics',     'Synthetic test course', 3),
(8, 'MA102', 'Probability and Statistics','Synthetic test course', 3);

-- ---- sections: 12 over 8 courses -------------------------------------
-- Sections 1-11 are the regular sections. Section 12 is the dedicated
-- boundary section (exactly 3 students, 100 sessions).
INSERT INTO sections (id, course_id, teacher_id, section_name, term, room, capacity) VALUES
(1,  1,  4, 'A', '2026-ODD', 'R101', 60),
(2,  1,  5, 'B', '2026-ODD', 'R102', 60),
(3,  2,  6, 'A', '2026-ODD', 'R103', 60),
(4,  2,  7, 'B', '2026-ODD', 'R104', 60),
(5,  3,  8, 'A', '2026-ODD', 'R105', 60),
(6,  3,  9, 'B', '2026-ODD', 'R106', 60),
(7,  4, 10, 'A', '2026-ODD', 'R107', 60),
(8,  4, 11, 'B', '2026-ODD', 'R108', 60),
(9,  5, 12, 'A', '2026-ODD', 'R109', 60),
(10, 6, 13, 'A', '2026-ODD', 'R110', 60),
(11, 7,  4, 'A', '2026-ODD', 'R111', 60),
(12, 8, 13, 'A', '2026-ODD', 'LAB1', 10);

-- ---- enrollments -----------------------------------------------------
-- STU001-STU200 each join 3 distinct regular sections (1-11): 600 rows.
INSERT INTO enrollments (student_id, section_id, status)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM n WHERE i < 200),
               k AS (SELECT 0 AS off UNION ALL SELECT 3 UNION ALL SELECT 7)
SELECT 100 + n.i, ((n.i - 1 + k.off) % 11) + 1, 'ACTIVE'
FROM n CROSS JOIN k;

-- Boundary section 12: three active students + one DROPPED (must not appear on roster)
INSERT INTO enrollments (student_id, section_id, status) VALUES
(298, 12, 'ACTIVE'),    -- STU198
(299, 12, 'ACTIVE'),    -- STU199
(300, 12, 'ACTIVE'),    -- STU200
(101, 12, 'DROPPED');   -- STU001

-- ---- boundary data: section 12, 100 sessions -------------------------
INSERT INTO attendance_sessions (id, section_id, session_date, start_time, end_time, topic, created_by)
WITH RECURSIVE s AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM s WHERE i < 100)
SELECT i, 12, DATE_ADD('2026-07-01', INTERVAL i - 1 DAY), '09:00:00', '10:00:00',
       CONCAT('Boundary session ', i), 13
FROM s;

-- STU198 = 74/100, STU199 = 75/100, STU200 = 76/100 (PRESENT / ABSENT only)
INSERT INTO attendance_records (session_id, student_id, status, marked_by)
WITH RECURSIVE s AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM s WHERE i < 100),
               st AS (SELECT 298 AS sid, 74 AS target
                      UNION ALL SELECT 299, 75
                      UNION ALL SELECT 300, 76)
SELECT s.i, st.sid, IF(s.i <= st.target, 'PRESENT', 'ABSENT'), 13
FROM s CROSS JOIN st;
