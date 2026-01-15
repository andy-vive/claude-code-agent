---
name: agent-coordination
description: Coordination protocol for main Claude Code agent. Provides agent orchestration, registry management, and handoff protocols for implement-then-review workflows. This protocol should be followed when coordinating multiple specialized agents, managing work registries, or performing multi-agent tasks like "implement and review", "coordinate devops workflow", or "use engineer and reviewer together".
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, TodoWrite
version: 1.0.0
---

# Agent Coordination Protocol

Structured workflow for coordinating specialized agents in an implement-then-review pattern.

## Core Principle

**Build on existing work. Never recreate.**

---

## Two Registries

Each project maintains two registries in `[PROJECT_ROOT]/.claude/reports/`:

| Registry | Purpose | Updated When |
|----------|---------|--------------|
| `_registry.md` | Index of completed work (reports) | After each agent produces a report |
| `_tech-debt.md` | Tracked improvements to address later | When issues are deferred or found in reviews |

**Decision rule:**
- **Registry** = "What work has been done?" (past/present state)
- **Tech Debt** = "What do we need to fix later?" (future work)

---

## 4-Step Workflow

### Step 1: Check Prior Work

Before invoking any agent, check what already exists:

```bash
# Check registry for recent reports
cat [PROJECT_ROOT]/.claude/reports/_registry.md | head -50

# Check if archiving needed (>50 entries)
ENTRIES=$(grep -c "^| W" [PROJECT_ROOT]/.claude/reports/_registry.md 2>/dev/null || echo 0)
[ "$ENTRIES" -gt 50 ] && echo "Registry has $ENTRIES entries - consider archiving"

# Check relevant tech debt (if working on that area)
grep -i "[area-keyword]" [PROJECT_ROOT]/.claude/reports/_tech-debt.md
```

**Read relevant reports** before proceeding to understand current state.

### Step 2: Context Injection

**Critical:** Subagents NEVER read registry or reports directly. Main agent provides ALL context.

Prepare the subagent prompt with injected context:

```
Task: [User's request]

Prior Context:
- [Relevant registry entries]
- [Related tech debt items]
- [Previous review findings if applicable]

Scope: [Specific files/modules/areas]

Output location:
- Report: [PROJECT_ROOT]/.claude/reports/[category]/[name]-YYYYMMDD.md
```

### Step 3: Sequencing (Implement-then-Review)

**Rule:** Will Agent B need Agent A's output? YES = Sequential, NO = Parallel

For implementation workflows:

1. **Engineer Agent First**
   - Receives task with injected context
   - Creates deliverables (code, configs, docs)
   - Generates execution report in `exec/`

2. **Verification Gate** (after engineer completes)
   - Run `~/.claude/skills/agent-coordination/scripts/verify.sh exec [report-path]`
   - Check for expected outputs
   - Ensure no critical errors

3. **Reviewer Agent Second**
   - Receives engineer's output as context
   - Reviews against best practices
   - Generates review report in `review/`
   - Identifies tech debt items

4. **Verification Gate** (after reviewer completes)
   - Run `~/.claude/skills/agent-coordination/scripts/verify.sh review [report-path]`
   - Validate review report completeness

### Step 4: Verify and Update

After each agent completes:

1. **Run verification script**
2. **Update `_registry.md`** with new entry:
   ```
   | W### | task-name | agent-name | status | report-link | YYYY-MM-DD |
   ```
3. **Update `_tech-debt.md`** if issues found:
   ```
   - [ ] TD-###: Description (W### source) - Severity
   ```

---

## Report Categories

All reports go to `[PROJECT_ROOT]/.claude/reports/[category]/`:

| Category | Purpose | Naming Convention |
|----------|---------|-------------------|
| `exec/` | Implementation execution reports | `exec-{task}-{YYYYMMDD}.md` |
| `review/` | Review findings and recommendations | `review-{scope}-{YYYYMMDD}.md` |
| `commits/` | Commit summaries, changelog entries | `commits-{branch}-{YYYYMMDD}.md` |
| `ci/` | CI/CD run results and analysis | `ci-{pipeline}-{YYYYMMDD}.md` |
| `archive/` | Old reports (moved, not deleted) | (auto-generated names) |

---

## Agent Configuration

### DevOps Agents

| Agent | Role | Primary Output |
|-------|------|----------------|
| `devops-engineer` | Implements CI/CD, containers, monitoring, deployment | `exec/` reports |
| `devops-reviewer` | Reviews infrastructure code for security, scalability, cost | `review/` reports |

### Specification Agents

| Agent | Role | Primary Output |
|-------|------|----------------|
| `spec-creator` | Creates clear, structured specification documents from requirements | `exec/` reports |
| `spec-reviewer` | Reviews specification documents for clarity, completeness, and actionability | `review/` reports |  

### Future Agent Types

The protocol supports additional pairs (no SKILL.md changes needed):

| Domain | Engineer | Reviewer |
|--------|----------|----------|
| Backend | backend-engineer | backend-reviewer |
| Frontend | frontend-engineer | frontend-reviewer |
| Security | security-engineer | security-reviewer |

---

## Registry Formats

### _registry.md Structure

```markdown
# Work Registry

## Active Items

| ID | Task | Agent | Status | Report | Updated |
|----|------|-------|--------|--------|---------|
| W001 | EKS cluster setup | devops-engineer | complete | exec/exec-eks-20250110.md | 2025-01-10 |
| W002 | EKS review | devops-reviewer | in-progress | - | 2025-01-10 |

## Session Context

- Last session: 2025-01-10T14:30:00
- Active scope: terraform/modules/eks/
- Pending reviews: W001
```

### _tech-debt.md Structure

```markdown
# Tech Debt Registry

## Critical

- [ ] TD-001: Missing encryption on S3 bucket (W001) - Critical

## High

- [ ] TD-002: IAM policy uses wildcard permissions (W001) - High

## Medium

- [ ] TD-003: Consider Aurora Serverless v2 for cost optimization (W001) - Medium

## Low

- [ ] TD-004: Add resource tagging for better cost allocation (W001) - Low
```

---

## Initializing Registries

When `_registry.md` doesn't exist, create with:

```markdown
# Work Registry

## Active Items

| ID | Task | Agent | Status | Report | Updated |
|----|------|-------|--------|--------|---------|

## Session Context

- Last session: [timestamp]
- Active scope: [description]
- Pending reviews: none
```

When `_tech-debt.md` doesn't exist, create with:

```markdown
# Tech Debt Registry

## Critical

## High

## Medium

## Low
```

---

## Verification Requirements

After each agent completes, verify:

1. **Deliverable exists**: Expected files created/modified
2. **Report generated**: Category-appropriate report created
3. **No critical errors**: Agent completed without failures
4. **Registry ready**: Entry can be added to _registry.md

See `reference.md` for detailed verification logic and retry handling.

---

## Example Workflow

**User request:** "Set up EKS cluster with proper security"

1. **Check Prior Work**
   ```
   Read [project]/.claude/reports/_registry.md
   Found: No prior EKS work
   ```

2. **Spawn devops-engineer**
   ```
   Task: Set up EKS cluster with proper security

   Prior Context: No prior EKS work in this project

   Scope: terraform/modules/eks/

   Output: .claude/reports/exec/exec-eks-20250110.md
   ```

3. **Verify engineer output**
   ```bash
   ~/.claude/skills/agent-coordination/scripts/verify.sh exec .claude/reports/exec/exec-eks-20250110.md
   ```

4. **Spawn devops-reviewer**
   ```
   Task: Review EKS cluster implementation

   Prior Context:
   - W001: EKS cluster implemented in terraform/modules/eks/
   - See exec/exec-eks-20250110.md for implementation details

   Scope: terraform/modules/eks/

   Output: .claude/reports/review/review-eks-20250110.md
   ```

5. **Verify reviewer output**
   ```bash
   ~/.claude/skills/agent-coordination/scripts/verify.sh review .claude/reports/review/review-eks-20250110.md
   ```

6. **Update registries**
   - Add W001 and W002 entries to `_registry.md`
   - Add any tech debt items to `_tech-debt.md`

---

## Additional Resources

- **`templates.md`** - Report templates for all categories
- **`reference.md`** - Verification details, retry logic, edge cases
- **`scripts/verify.sh`** - Deliverable verification script
- **`scripts/archive_reports.py`** - Registry archiving utility

---

**Version:** 1.0.0
