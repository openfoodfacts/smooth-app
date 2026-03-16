---
timeout-minutes: 5

on:
  issue:
    types: [opened, reopened]

permissions:
  issues: read

tools:
  github:
    toolsets: [issues, labels]

safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement, documentation, question, help-wanted, good-first-issue]
  add-comment: {}
---

# Issue Triage Agent

List open issues in ${{ github.repository }} that have no labels. For each
unlabeled issue, analyze the title and body, then add one of the allowed
labels: `bug`, `feature`, `enhancement`, `documentation`, `question`,
`help-wanted`, or `good-first-issue`.

Skip issues that:
- Already have any of these labels
- Have been assigned to any user (especially non-bot users)

Do research on the issue in the context of the codebase and, after
adding the label to an issue, mention the issue author in a comment, explain
why the label was added and give a brief summary of how the issue may be
addressed.
