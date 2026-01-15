---
name: Agent Coordination Templates
description: Report templates for agent coordination workflow
---

# Report Templates

Standard templates for all report categories. Copy and fill in when generating reports.

---

## Execution Report Template (exec/)

Use for implementation tasks by engineer agents.

```markdown
# Execution Report: {Task Title}

**Date**: {YYYY-MM-DD}
**Agent**: {agent-name}
**Work ID**: {W###}
**Status**: {complete|partial|failed}

## Summary

{Brief description of what was implemented - 2-3 sentences}

## Deliverables

| File | Action | Description |
|------|--------|-------------|
| path/to/file | created | Description of file purpose |
| path/to/file | modified | What was changed and why |

## Implementation Details

{Key implementation decisions and rationale. Include:
- Architecture choices made
- Dependencies added
- Configuration decisions
- Any deviations from original plan}

## Commands Executed

{List of significant commands run during implementation}

```bash
# Example
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Dependencies

{External dependencies, prerequisites, or blockers encountered}

- Dependency 1: Description
- Dependency 2: Description

## Next Steps

{Recommended follow-up actions}

1. Next step 1
2. Next step 2

## Verification Status

- [ ] Files exist and are non-empty
- [ ] Syntax validation passed
- [ ] Tests pass (if applicable)
- [ ] Ready for review
```

---

## Review Report Template (review/)

Use for review tasks by reviewer agents.

```markdown
# Review Report: {Scope Description}

**Date**: {YYYY-MM-DD}
**Agent**: {agent-name}
**Reviewing**: {W### reference}
**Files Reviewed**: {count}

## Executive Summary

{High-level assessment - 2-3 sentences covering overall quality and main concerns}

## Findings

### Critical Issues (Must Fix Before Deployment)

| ID | Location | Issue | Impact | Recommendation |
|----|----------|-------|--------|----------------|
| C1 | file:line | Description | Security/Performance/Reliability | Specific fix |

### Warnings (Should Address Soon)

| ID | Location | Issue | Impact | Recommendation |
|----|----------|-------|--------|----------------|
| W1 | file:line | Description | Impact description | Specific fix |

### Suggestions (Nice to Have)

| ID | Location | Issue | Impact | Recommendation |
|----|----------|-------|--------|----------------|
| S1 | file:line | Description | Impact description | Suggested improvement |

## Strengths

{What was done well - acknowledge good practices}

- Strength 1
- Strength 2

## Tech Debt Items

Items to add to _tech-debt.md:

- [ ] TD-###: {description} - {Critical|High|Medium|Low}
- [ ] TD-###: {description} - {Critical|High|Medium|Low}

## Verdict

Select one:

- [ ] **Approved** - Ready for deployment
- [ ] **Approved with conditions** - Minor fixes required, can proceed
- [ ] **Requires fixes** - Must address critical issues before deployment
- [ ] **Major rework needed** - Significant changes required
```

---

## Commit Summary Template (commits/)

Use for documenting commit batches or changelog entries.

```markdown
# Commit Summary: {Branch Name}

**Date**: {YYYY-MM-DD}
**Commits**: {count}
**Work IDs**: {W###, W###}

## Overview

{Brief description of the overall change set}

## Commits

| Hash | Author | Message |
|------|--------|---------|
| abc1234 | name | Commit message |
| def5678 | name | Commit message |

## Files Changed

| File | Insertions | Deletions | Type |
|------|------------|-----------|------|
| path/to/file | +50 | -10 | Modified |

## Change Categories

- **Features**: {list of new features}
- **Fixes**: {list of bug fixes}
- **Refactoring**: {list of refactoring changes}
- **Documentation**: {list of doc changes}

## Impact Assessment

{Assessment of change impact on the system}

- Breaking changes: {Yes/No - details if yes}
- Migration required: {Yes/No - details if yes}
- Dependencies updated: {Yes/No - details if yes}
```

---

## CI Report Template (ci/)

Use for documenting CI/CD pipeline results.

```markdown
# CI Report: {Pipeline Name}

**Date**: {YYYY-MM-DD}
**Run ID**: {id or link}
**Trigger**: {push|pull_request|manual|schedule}
**Branch**: {branch-name}
**Status**: {success|failure|cancelled}

## Pipeline Summary

| Stage | Status | Duration | Notes |
|-------|--------|----------|-------|
| checkout | passed | 5s | - |
| build | passed | 2m30s | - |
| test | failed | 1m15s | 3 tests failed |
| deploy | skipped | - | Blocked by test failure |

## Test Results

| Suite | Passed | Failed | Skipped | Duration |
|-------|--------|--------|---------|----------|
| unit | 150 | 0 | 2 | 45s |
| integration | 42 | 3 | 0 | 2m |

## Failures

### Test Failures

{Details of test failures}

```
Test: test_user_authentication
Error: AssertionError: Expected 200, got 401
File: tests/test_auth.py:42
```

### Build Failures

{Details of build failures if any}

## Artifacts

| Name | Size | Link |
|------|------|------|
| coverage-report | 2.5MB | {link} |
| build-logs | 500KB | {link} |

## Recommendations

{Actions based on CI results}

1. Recommendation 1
2. Recommendation 2
```

---

## Registry Entry Templates

### _registry.md Entry

Add to the Active Items table:

```markdown
| {W###} | {task-description} | {agent-name} | {pending|in-progress|complete|failed} | {report-path or -} | {YYYY-MM-DD} |
```

**Status values:**
- `pending` - Queued but not started
- `in-progress` - Currently being worked on
- `complete` - Successfully finished
- `failed` - Could not complete

**Work ID format:** Sequential W### starting from W001

### _tech-debt.md Entry

Add to appropriate severity section:

```markdown
- [ ] TD-###: {Brief description of the issue} ({W### source}) - {Severity}
```

**Severity levels:**
- `Critical` - Security vulnerability or data loss risk
- `High` - Significant performance or reliability issue
- `Medium` - Best practice violation or moderate concern
- `Low` - Minor improvement or cosmetic issue

**Tech Debt ID format:** Sequential TD-### starting from TD-001

---

## Quick Reference

### Report Naming Convention

```
{category}-{topic}-{YYYYMMDD}.md
```

Examples:
- `exec-eks-cluster-20250110.md`
- `review-iam-policies-20250110.md`
- `commits-feature-auth-20250110.md`
- `ci-main-pipeline-20250110.md`

### Required Fields by Report Type

| Field | exec | review | commits | ci |
|-------|------|--------|---------|-----|
| Date | Yes | Yes | Yes | Yes |
| Agent | Yes | Yes | - | - |
| Work ID | Yes | Yes | Yes | - |
| Status | Yes | - | - | Yes |
| Summary | Yes | Yes | Yes | Yes |
| Deliverables | Yes | - | - | - |
| Findings | - | Yes | - | - |
| Verdict | - | Yes | - | - |
