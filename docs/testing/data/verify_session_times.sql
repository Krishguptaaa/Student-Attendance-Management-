-- Verify that MySQL rejects sessions whose end time is not after start time.
USE attendance_db;

DROP PROCEDURE IF EXISTS assert_session_time_order;

DELIMITER //
CREATE PROCEDURE assert_session_time_order()
BEGIN
    DECLARE constraint_rejected BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 3819 SET constraint_rejected = TRUE;

    START TRANSACTION;
    INSERT INTO attendance_sessions (
        section_id, session_date, start_time, end_time, topic, created_by
    )
    VALUES (12, '2027-01-01', '10:00:00', '09:00:00', 'Invalid time test', 13);
    ROLLBACK;

    IF NOT constraint_rejected THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'session with end time before start time was accepted';
    END IF;
END//
DELIMITER ;

CALL assert_session_time_order();
DROP PROCEDURE assert_session_time_order;
