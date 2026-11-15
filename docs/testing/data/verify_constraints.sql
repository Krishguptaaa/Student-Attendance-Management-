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
