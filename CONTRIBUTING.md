# Contributing

## Branch naming

Create a short-lived branch from the current integration branch. Use a lowercase type prefix and a concise kebab-case description:

- `feat/shortage-report`
- `fix/duplicate-attendance`
- `test/mysql-constraints`
- `docs/qa-templates`
- `ci/mysql-service`

When an issue exists, include its number after the prefix, for example `fix/123-duplicate-attendance`. Avoid spaces, personal data, and vague names such as `updates`.

## Commit messages

Use the Conventional Commits format:

```text
<type>(optional-scope): imperative summary
```

Common types are `feat`, `fix`, `test`, `docs`, `refactor`, `ci`, and `chore`. Keep each commit focused on one task and its directly related files. Write a concise, imperative subject.

Examples:

```text
test(sql): reject duplicate session slots
docs(qa): add defect report template
ci: upload Maven test reports
```

Do not include secrets, generated build output, or real student information in branches or commits.
