---
name: Agent Coordination Reference
description: Detailed verification logic, retry handling, and edge cases for agent coordination
---

# Agent Coordination Reference

Detailed documentation for verification, error handling, and edge cases.

---

## Verification Logic

### Deliverable Verification

The `scripts/verify.sh` script checks:

1. **File Existence**
   - Report file exists at specified path
   - File is non-empty
   - File has appropriate permissions

2. **Markdown Structure**
   - Starts with a markdown header (`#`)
   - Contains expected sections for report type

3. **Required Fields**
   - Date field present
   - Agent field present (for exec/review)
   - Work ID present (for exec/review)
   - Status field present (for exec/ci)

4. **Content Validation**
   - Tables have correct column count
   - Links are properly formatted
   - No placeholder text remaining

### Verification Exit Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | All checks passed | Proceed to registry update |
| 1 | Non-critical warnings | Proceed with notes in registry |
| 2 | Critical failures | Do not update registry, report to user |
| 3 | Missing deliverables | Agent retry required |

### Required Sections by Report Type

**exec (Execution Report):**
- Summary
- Deliverables
- Verification Status

**review (Review Report):**
- Executive Summary
- Findings
- Verdict

**commits (Commit Summary):**
- Overview or Summary
- Commits
- Files Changed

**ci (CI Report):**
- Pipeline Summary
- Status (in header)

---

## Retry Logic

### When to Retry

Retry agent execution when:
- Exit code 3 (missing deliverables)
- Agent timeout without output
- Partial completion with recoverable state
- Network/API errors (transient failures)

**Do NOT retry when:**
- Exit code 2 (critical content failures) - fix the issue first
- User explicitly cancelled
- Invalid task specification (need clarification)

### Retry Strategy

```
Attempt 1: Standard execution
           - Full task scope
           - Normal context injection

Attempt 2: Reduced scope + explicit guidance
           - Break task into smaller pieces
           - Add step-by-step instructions
           - Include previous attempt output

Attempt 3: Minimal scope + verbose instructions
           - Single deliverable at a time
           - Extremely explicit instructions
           - Full error context from previous attempts
```

After 3 failures: **Escalate to user** with diagnostic information including:
- All attempt outputs
- Specific failure points
- Suggested manual intervention

### Retry Context Injection

On retry, inject additional context:

```
Task: [Original task]

RETRY ATTEMPT {N}

Previous attempt output:
{output from last attempt, if any}

Failure reason:
{specific error or missing deliverable}

Adjusted scope:
{reduced scope for this attempt}

Explicit instructions:
1. First, do X
2. Then, do Y
3. Finally, produce Z

Expected output:
{explicit description of what success looks like}
```

---

## Edge Cases

### Empty Registry

**Condition:** `_registry.md` doesn't exist or is empty

**Handling:**
1. Create the file with header template
2. Initialize with `## Active Items` section and empty table
3. Add `## Session Context` section
4. Proceed with first entry as W001

**Template:**
```markdown
# Work Registry

## Active Items

| ID | Task | Agent | Status | Report | Updated |
|----|------|-------|--------|--------|---------|

## Session Context

- Last session: {current timestamp}
- Active scope: {from user request}
- Pending reviews: none
```

### Registry Too Large

**Condition:** Registry has >50 entries in Active Items table

**Handling:**
1. Alert user: "Registry has {N} entries - consider archiving"
2. Optionally run `scripts/archive_reports.py`
3. Archive moves completed items older than 30 days
4. Keep all active/in-progress items
5. Keep last 20 completed items

**Archive naming:** `_registry-archive-{YYYYMMDD}.md`

### Concurrent Sessions

**Condition:** Multiple Claude sessions working on same project

**Handling:**
1. Read registry at session start
2. Add session marker to Session Context:
   ```
   - Active session: {session-id} started {timestamp}
   ```
3. Before updating, check for conflicts:
   - If another session modified since our read, re-read and merge
4. Remove session marker on completion

**Conflict resolution:**
- Different work IDs: Merge both entries
- Same work ID: Keep the one with later timestamp
- Status conflicts: Prefer more advanced status (complete > in-progress > pending)

### Tech Debt Overflow

**Condition:** Tech debt registry has >50 items

**Handling:**
1. Alert user about backlog size
2. Group summary by severity:
   ```
   Tech Debt Summary:
   - Critical: {N} items (immediate attention needed)
   - High: {N} items
   - Medium: {N} items
   - Low: {N} items
   ```
3. Suggest prioritized review sprint
4. Optionally archive resolved items

### Missing Report Directory

**Condition:** `[project]/.claude/reports/{category}/` doesn't exist

**Handling:**
1. Create the directory: `mkdir -p [project]/.claude/reports/{category}/`
2. Proceed with report creation
3. No special logging needed (normal first-time setup)

### Invalid Work ID Sequence

**Condition:** Work IDs have gaps or duplicates

**Handling:**
1. Gaps are OK - don't renumber
2. On duplicate detection:
   - Log warning
   - Append suffix: W001 becomes W001a, W001b
3. Next new ID: max(existing IDs) + 1

### Agent Produces No Output

**Condition:** Agent completes but report file is empty or missing

**Handling:**
1. Check agent's stdout/stderr for errors
2. If task was simple: Retry once with explicit output requirement
3. If task was complex: Break into smaller tasks
4. After 2 retries: Escalate to user with diagnostic info

### Reviewer Finds No Issues

**Condition:** Review report has no findings

**Handling:**
1. This is valid - not an error
2. Ensure "Strengths" section is populated
3. Verdict should be "Approved"
4. No tech debt items needed
5. Still create registry entry as complete

---

## Domain-Specific Verification

### DevOps Verification

For `devops-engineer` deliverables:

| File Type | Verification Command | Success Criteria |
|-----------|---------------------|------------------|
| Terraform (*.tf) | `terraform validate` | Exit code 0 |
| Terraform format | `terraform fmt -check` | No diff output |
| Docker (Dockerfile) | `docker build --check` (if available) | Valid syntax |
| Kubernetes (*.yaml) | `kubectl --dry-run=client -f file.yaml` | Valid manifest |
| GitHub Actions | YAML syntax check | Valid YAML |
| Shell scripts | `shellcheck script.sh` | No errors |

For `devops-reviewer` reports:

| Check | Requirement |
|-------|-------------|
| Critical issues | Must have code location (file:line) |
| Recommendations | Must be actionable (specific fix, not vague) |
| File references | Must be valid paths in the project |
| Severity ratings | Must use standard levels (Critical/High/Medium/Low) |

### Future Domain Verification

**Backend (when implemented):**

| Check | Verification |
|-------|--------------|
| Unit tests | Test files exist for new code |
| API contracts | OpenAPI/Swagger spec validates |
| Database migrations | Migration syntax is valid |
| Type safety | TypeScript/type annotations present |

**Frontend (when implemented):**

| Check | Verification |
|-------|--------------|
| Component exports | All components properly exported |
| Style consistency | CSS/styling follows project conventions |
| Accessibility | Basic a11y attributes present |
| Build | `npm run build` succeeds |

---

## Protocol Extensions

### Adding New Agent Types

To add a new engineer/reviewer pair:

1. **Create agent files** in `~/.claude/agents/`:
   ```
   {domain}-engineer.md
   {domain}-reviewer.md
   ```

2. **Define agent capabilities** in each file:
   - Tools allowed
   - Focus areas
   - Output formats

3. **Add templates** to `templates.md`:
   - Domain-specific report sections
   - Relevant verification criteria
   - Example outputs

4. **Update verification** in `reference.md`:
   - Domain-specific verification commands
   - Success criteria
   - Edge cases for the domain

5. **No changes to SKILL.md** - the core workflow is domain-agnostic

### Adding New Report Categories

To add a new category (e.g., `perf/` for performance reports):

1. **Add to category table** in SKILL.md:
   ```markdown
   | `perf/` | Performance analysis and benchmarks | `perf-{topic}-{YYYYMMDD}.md` |
   ```

2. **Create template** in `templates.md`:
   - Required sections for this category
   - Field definitions
   - Example report

3. **Add verification rules** in `reference.md`:
   - Required sections
   - Field validation
   - Domain-specific checks

4. **Update `verify.sh`**:
   - Add case for new category
   - Define required_sections array
   - Add any special validation

### Customizing for Project

Projects can override defaults by creating:

```
[PROJECT_ROOT]/.claude/coordination-config.md
```

With content:
```markdown
# Project Coordination Config

## Custom Report Categories
- perf/: Performance reports

## Custom Verification
- Require test coverage >80% for exec reports
- Require security review for all infrastructure changes

## Team Conventions
- Work ID prefix: PROJ-W### instead of W###
- Tech debt severity: Use P0-P3 instead of Critical-Low
```

---

## Troubleshooting

### Common Issues

**Issue:** "Registry not found" error
**Solution:** Run `mkdir -p [project]/.claude/reports` and initialize registries

**Issue:** Work ID conflicts
**Solution:** Check for concurrent sessions, use conflict resolution rules

**Issue:** Verification always fails
**Solution:** Check that agent is producing reports in correct format, review templates

**Issue:** Tech debt items accumulating
**Solution:** Schedule regular tech debt review, archive resolved items

**Issue:** Agent outputs don't match expected format
**Solution:** Include explicit template in context injection, reference templates.md

### Debug Mode

For troubleshooting, run verify.sh with verbose output:

```bash
VERBOSE=1 ~/.claude/skills/agent-coordination/scripts/verify.sh exec report.md
```

This will show:
- Each check being performed
- Actual values found
- Expected values
- Detailed failure reasons
