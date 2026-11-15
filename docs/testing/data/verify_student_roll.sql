-- Verify that MySQL rejects student users without a roll number.
USE attendance_db;

DROP PROCEDURE IF EXISTS assert_student_roll_number_required;

DELIMITER //
CREATE PROCEDURE assert_student_roll_number_required()
BEGIN
    DECLARE constraint_rejected BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 3819 SET constraint_rejected = TRUE;

    START TRANSACTION;
    INSERT INTO users (email, password_hash, full_name, role, roll_number, is_active)
    VALUES ('verify-no-roll@sams.test', 'not-used', 'Missing Roll Test', 'STUDENT', NULL, TRUE);
    ROLLBACK;

    IF NOT constraint_rejected THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'student without a roll number was accepted';
    END IF;
END//
DELIMITER ;

CALL assert_student_roll_number_required();
DROP PROCEDURE assert_student_roll_number_required;
-- Verify that MySQL rejects student users without a roll number.
USE attendance_db;

DROP PROCEDURE IF EXISTS assert_student_roll_number_required;

DELIMITER //
CREATE PROCEDURE assert_student_roll_number_required()
BEGIN
    DECLARE constraint_rejected BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 3819 SET constraint_rejected = TRUE;

    START TRANSACTION;
    INSERT INTO users (email, password_hash, full_name, role, roll_number, is_active)
    VALUES ('verify-no-roll@sams.test', 'not-used', 'Missing Roll Test', 'STUDENT', NULL, TRUE);
    ROLLBACK;

    IF NOT constraint_rejected THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'student without a roll number was accepted';
    END IF;
END//
DELIMITER ;

CALL assert_student_roll_number_required();
DROP PROCEDURE assert_student_roll_number_required;
