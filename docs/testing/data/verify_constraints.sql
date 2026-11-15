-- Verify that duplicate attendance records are rejected by the schema.
USE attendance_db;

DROP PROCEDURE IF EXISTS assert_duplicate_attendance_rejected;

DELIMITER //
CREATE PROCEDURE assert_duplicate_attendance_rejected()
BEGIN
    DECLARE duplicate_rejected BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_rejected = TRUE;

    IF NOT EXISTS (
        SELECT 1
        FROM attendance_records
        WHERE session_id = 1 AND student_id = 298
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate attendance test requires seeded STU198 record for session 1';
    END IF;

    START TRANSACTION;
    INSERT INTO attendance_records (session_id, student_id, status, marked_by)
    VALUES (1, 298, 'PRESENT', 13);
    ROLLBACK;

    IF NOT duplicate_rejected THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate attendance record was accepted';
    END IF;
END//
DELIMITER ;

CALL assert_duplicate_attendance_rejected();
DROP PROCEDURE assert_duplicate_attendance_rejected;

DROP PROCEDURE IF EXISTS assert_duplicate_session_slot_rejected;

DELIMITER //
CREATE PROCEDURE assert_duplicate_session_slot_rejected()
BEGIN
    DECLARE duplicate_rejected BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_rejected = TRUE;

    IF NOT EXISTS (
        SELECT 1
        FROM attendance_sessions
        WHERE id = 1
          AND section_id = 12
          AND session_date = '2026-07-01'
          AND start_time = '09:00:00'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate session-slot test requires seeded section 12 session 1';
    END IF;

    START TRANSACTION;
    INSERT INTO attendance_sessions (
        section_id, session_date, start_time, end_time, topic, created_by
    )
    VALUES (12, '2026-07-01', '09:00:00', '10:00:00', 'Duplicate slot test', 13);
    ROLLBACK;

    IF NOT duplicate_rejected THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate session slot was accepted';
    END IF;
END//
DELIMITER ;

CALL assert_duplicate_session_slot_rejected();
DROP PROCEDURE assert_duplicate_session_slot_rejected;

DROP PROCEDURE IF EXISTS assert_course_delete_restricted;

DELIMITER //
CREATE PROCEDURE assert_course_delete_restricted()
BEGIN
    DECLARE delete_rejected BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 1451 SET delete_rejected = TRUE;

    IF NOT EXISTS (SELECT 1 FROM sections WHERE course_id = 1) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'course delete test requires a course referenced by a section';
    END IF;

    START TRANSACTION;
    DELETE FROM courses WHERE id = 1;
    ROLLBACK;

    IF NOT delete_rejected THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'deleting a course referenced by a section was accepted';
    END IF;
END//
DELIMITER ;

CALL assert_course_delete_restricted();
DROP PROCEDURE assert_course_delete_restricted;

DROP PROCEDURE IF EXISTS assert_zero_course_credits_rejected;

DELIMITER //
CREATE PROCEDURE assert_zero_course_credits_rejected()
BEGIN
    DECLARE constraint_rejected BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 3819 SET constraint_rejected = TRUE;

    START TRANSACTION;
    INSERT INTO courses (code, name, credits)
    VALUES ('VERIFY0', 'Zero Credit Constraint Test', 0);
    ROLLBACK;

    IF NOT constraint_rejected THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'course with credits = 0 was accepted';
    END IF;
END//
DELIMITER ;

CALL assert_zero_course_credits_rejected();
DROP PROCEDURE assert_zero_course_credits_rejected;

DROP PROCEDURE IF EXISTS assert_zero_capacity_rejected;

DELIMITER //
CREATE PROCEDURE assert_zero_capacity_rejected()
BEGIN
    DECLARE constraint_rejected BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 3819 SET constraint_rejected = TRUE;

    START TRANSACTION;
    INSERT INTO sections (
        course_id, teacher_id, section_name, term, capacity
    )
    VALUES (8, 13, 'VERIFY-CAP', 'VERIFY', 0);
    ROLLBACK;

    IF NOT constraint_rejected THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'section with capacity = 0 was accepted';
    END IF;
END//
DELIMITER ;

CALL assert_zero_capacity_rejected();
DROP PROCEDURE assert_zero_capacity_rejected;
