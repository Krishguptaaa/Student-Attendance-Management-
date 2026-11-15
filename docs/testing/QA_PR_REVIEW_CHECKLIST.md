# QA pull request review checklist

## Scope and requirements

- [ ] The change addresses the linked task or requirement.
- [ ] The pull request description explains the behavior and scope.
- [ ] Unrelated files and generated artifacts are excluded.

## Implementation review

- [ ] Input validation and boundary conditions are covered.
- [ ] Authorization and role-specific behavior are correct.
- [ ] Error handling is clear and does not hide failures.
- [ ] Database changes preserve constraints and referential integrity.
- [ ] No secrets or real student information are included.
- [ ] Directly related documentation is updated.

## Verification

- [ ] Relevant automated tests pass.
- [ ] SQL verification passes against MySQL 8 when database behavior changes.
- [ ] Manual QA steps and results are recorded when automation is unavailable.
- [ ] CI is passing; test reports are reviewed when available.

## Review outcome

- Reviewer:
- Review date:
- Decision: Approve / Request changes
- Follow-up issues:
