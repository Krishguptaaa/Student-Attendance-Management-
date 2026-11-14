-- Verify the seeded baseline row counts in MySQL 8.
USE attendance_db;

DROP PROCEDURE IF EXISTS assert_seed_row_counts;

DELIMITER //
CREATE PROCEDURE assert_seed_row_counts()
BEGIN
    DECLARE actual_rows BIGINT;

    SELECT COUNT(*) INTO actual_rows FROM users;
    IF actual_rows <> 217 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'users row count mismatch (expected 217)';
    END IF;

    SELECT COUNT(*) INTO actual_rows FROM courses;
    IF actual_rows <> 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'courses row count mismatch (expected 8)';
    END IF;

    SELECT COUNT(*) INTO actual_rows FROM sections;
    IF actual_rows <> 12 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'sections row count mismatch (expected 12)';
    END IF;

    SELECT COUNT(*) INTO actual_rows FROM enrollments;
    IF actual_rows <> 604 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'enrollments row count mismatch (expected 604)';
    END IF;

    SELECT COUNT(*) INTO actual_rows FROM attendance_sessions;
    IF actual_rows <> 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'attendance_sessions row count mismatch (expected 100)';
    END IF;

    SELECT COUNT(*) INTO actual_rows FROM attendance_records;
    IF actual_rows <> 300 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'attendance_records row count mismatch (expected 300)';
    END IF;
END//
DELIMITER ;

CALL assert_seed_row_counts();
DROP PROCEDURE assert_seed_row_counts;

SELECT 'users' AS table_name, COUNT(*) AS actual_rows, 217 AS expected_rows FROM users
UNION ALL
SELECT 'courses', COUNT(*), 8 FROM courses
UNION ALL
SELECT 'sections', COUNT(*), 12 FROM sections
UNION ALL
SELECT 'enrollments', COUNT(*), 604 FROM enrollments
UNION ALL
SELECT 'attendance_sessions', COUNT(*), 100 FROM attendance_sessions
UNION ALL
SELECT 'attendance_records', COUNT(*), 300 FROM attendance_records;