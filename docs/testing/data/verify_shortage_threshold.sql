-- Verify the attendance shortage query at the 75% threshold (F-014).
USE attendance_db;

DROP PROCEDURE IF EXISTS assert_shortage_threshold;

DELIMITER //
CREATE PROCEDURE assert_shortage_threshold(IN p_threshold DECIMAL(5, 2))
BEGIN
    DECLARE shortage_count BIGINT;
    DECLARE only_shortage VARCHAR(30);

    SELECT COUNT(*), MAX(shortages.roll_number)
    INTO shortage_count, only_shortage
    FROM (
        SELECT u.roll_number,
               100.0 * SUM(CASE WHEN ar.status IN ('PRESENT', 'LATE') THEN 1 ELSE 0 END)
               / COUNT(DISTINCT s.id) AS attendance_percentage
        FROM enrollments e
        JOIN users u ON u.id = e.student_id
        JOIN attendance_sessions s ON s.section_id = e.section_id
        LEFT JOIN attendance_records ar
               ON ar.session_id = s.id AND ar.student_id = u.id
        WHERE e.section_id = 12
          AND e.status = 'ACTIVE'
        GROUP BY u.id, u.roll_number
        HAVING attendance_percentage < p_threshold
    ) AS shortages;

    IF shortage_count <> 1 OR only_shortage <> 'STU198' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '75% shortage list must include only STU198; students at 75% are not short';
    END IF;
END//
DELIMITER ;

CALL assert_shortage_threshold(75.00);
DROP PROCEDURE assert_shortage_threshold;

SET @shortage_threshold = 75.00;

SELECT u.roll_number,
       COUNT(DISTINCT s.id) AS total_sessions,
       SUM(CASE WHEN ar.status IN ('PRESENT', 'LATE') THEN 1 ELSE 0 END) AS attended_sessions,
       ROUND(
           100.0 * SUM(CASE WHEN ar.status IN ('PRESENT', 'LATE') THEN 1 ELSE 0 END)
           / COUNT(DISTINCT s.id),
           2
       ) AS attendance_percentage
FROM enrollments e
JOIN users u ON u.id = e.student_id
JOIN attendance_sessions s ON s.section_id = e.section_id
LEFT JOIN attendance_records ar
       ON ar.session_id = s.id AND ar.student_id = u.id
WHERE e.section_id = 12
  AND e.status = 'ACTIVE'
GROUP BY u.id, u.roll_number
HAVING attendance_percentage < @shortage_threshold
ORDER BY attendance_percentage, u.roll_number;
