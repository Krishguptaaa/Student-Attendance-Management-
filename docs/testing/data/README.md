# MySQL test data guide

The fixture targets MySQL 8 and the `attendance_db` database created by the root `schema.sql`.
All names, email addresses, and records are synthetic; do not load real student data.

## Load the baseline

Run these commands from the repository root against a disposable test database:

```bash
mysql --host=127.0.0.1 --user=root --password < schema.sql
mysql --host=127.0.0.1 --user=root --password < docs/testing/data/seed.sql
```

`seed.sql` truncates and repopulates the application tables, so it destroys existing rows in `attendance_db`. `reset.sql` empties the tables without reseeding.

## Seed contents

| Table | Rows | Details |
|---|---:|---|
| `users` | 217 | 3 admins, 10 teachers, 204 students |
| `courses` | 8 | Synthetic catalogue entries |
| `sections` | 12 | Section 12 is dedicated to boundary checks |
| `enrollments` | 604 | 600 regular plus 4 boundary-section rows |
| `attendance_sessions` | 100 | All in section 12 |
| `attendance_records` | 300 | STU198/199/200 have 74%, 75%, and 76% attendance |

Student ids are 100 plus the roll-number suffix (for example, STU001 has id 101). STU201–STU203 are deactivated; STU204 is active but has no enrollments. Section 12 has active boundary students STU198, STU199, and STU200, plus a dropped STU001 enrollment.

Demo credentials for local testing:

| Role | Email | Password |
|---|---|---|
| Admin | `admin1@sams.test` | `Admin@1234` |
| Teacher | `teacher01@sams.test` | `Teacher@1234` |
| Student | `stu001@sams.test` | `Student@1234` |

These are shared synthetic fixture credentials, not production credentials.

## Verify the fixture

After loading the baseline, run the SQL verification scripts:

```bash
mysql --host=127.0.0.1 --user=root --password < docs/testing/data/verify_seed.sql
mysql --host=127.0.0.1 --user=root --password < docs/testing/data/verify_constraints.sql
mysql --host=127.0.0.1 --user=root --password < docs/testing/data/verify_student_roll.sql
mysql --host=127.0.0.1 --user=root --password < docs/testing/data/verify_session_times.sql
mysql --host=127.0.0.1 --user=root --password < docs/testing/data/verify_shortage_threshold.sql
```

The scripts assert row counts, boundary percentages, rejected duplicates and invalid values, and the F-014 shortage list at a 75% threshold. Use them only against a disposable test database.
