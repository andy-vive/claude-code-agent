#!/bin/bash
# Deliverable Verification Script
# Validates agent outputs before registry updates
#
# Usage: verify.sh <report-type> <report-path> [--strict]
#
# Exit codes:
#   0 - All checks passed
#   1 - Warnings only (non-blocking)
#   2 - Critical failures (blocking)
#   3 - Missing deliverables (retry needed)

set -euo pipefail

# Colors for output (disabled if not terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
else
    RED=''
    YELLOW=''
    GREEN=''
    NC=''
fi

# Verbose mode
VERBOSE="${VERBOSE:-0}"

log_verbose() {
    if [ "$VERBOSE" = "1" ]; then
        echo "[DEBUG] $1"
    fi
}

log_ok() {
    echo -e "${GREEN}OK${NC}: $1"
}

log_warn() {
    echo -e "${YELLOW}WARN${NC}: $1"
}

log_error() {
    echo -e "${RED}ERROR${NC}: $1"
}

# Usage
usage() {
    cat << EOF
Usage: $0 <report-type> <report-path> [--strict]

Report types:
  exec     - Execution reports (implementation tasks)
  review   - Review reports (code/infra reviews)
  commits  - Commit summaries
  ci       - CI/CD pipeline reports

Options:
  --strict    Treat warnings as errors (exit 2 instead of 1)

Exit codes:
  0 - All checks passed
  1 - Warnings only (proceed with caution)
  2 - Critical failures (do not proceed)
  3 - Missing deliverables (retry agent)

Examples:
  $0 exec .claude/reports/exec/exec-eks-20250110.md
  $0 review .claude/reports/review/review-iam-20250110.md --strict
  VERBOSE=1 $0 ci .claude/reports/ci/ci-main-20250110.md
EOF
    exit 1
}

# Parse arguments
if [ $# -lt 2 ]; then
    usage
fi

REPORT_TYPE="$1"
REPORT_PATH="$2"
STRICT_MODE=false

if [ "${3:-}" = "--strict" ]; then
    STRICT_MODE=true
fi

# Validate report type
case "$REPORT_TYPE" in
    exec|review|commits|ci)
        log_verbose "Report type: $REPORT_TYPE"
        ;;
    *)
        log_error "Unknown report type: $REPORT_TYPE"
        echo "Valid types: exec, review, commits, ci"
        exit 2
        ;;
esac

echo "========================================"
echo "Verifying $REPORT_TYPE report"
echo "File: $REPORT_PATH"
echo "========================================"
echo ""

error_count=0
warning_count=0

# Check 1: File exists
log_verbose "Checking file existence..."
if [ ! -f "$REPORT_PATH" ]; then
    log_error "Report file not found: $REPORT_PATH"
    exit 3
fi
log_ok "Report file exists"

# Check 2: File is not empty
log_verbose "Checking file is not empty..."
if [ ! -s "$REPORT_PATH" ]; then
    log_error "Report file is empty"
    exit 3
fi
file_lines=$(wc -l < "$REPORT_PATH")
log_ok "Report file has content ($file_lines lines)"

# Check 3: Markdown structure (starts with header)
log_verbose "Checking markdown structure..."
first_line=$(head -1 "$REPORT_PATH")
if ! echo "$first_line" | grep -q '^#'; then
    log_warn "Report doesn't start with markdown header"
    ((warning_count++))
else
    log_ok "Valid markdown structure"
fi

# Check 4: Required sections by type
log_verbose "Checking required sections for $REPORT_TYPE..."
declare -a required_sections

case "$REPORT_TYPE" in
    exec)
        required_sections=("Summary" "Deliverables" "Verification Status")
        ;;
    review)
        required_sections=("Executive Summary" "Findings" "Verdict")
        ;;
    commits)
        required_sections=("Commits" "Files Changed")
        ;;
    ci)
        required_sections=("Pipeline Summary")
        ;;
esac

for section in "${required_sections[@]}"; do
    log_verbose "Looking for section: $section"
    if grep -qE "^##?\s+$section|^###?\s+$section" "$REPORT_PATH"; then
        log_ok "Found section '$section'"
    else
        log_warn "Missing section '$section'"
        ((warning_count++))
    fi
done

# Check 5: Date field present
log_verbose "Checking for date field..."
if grep -q '^\*\*Date\*\*:' "$REPORT_PATH"; then
    date_value=$(grep '^\*\*Date\*\*:' "$REPORT_PATH" | head -1 | sed 's/\*\*Date\*\*:\s*//')
    log_ok "Date field present: $date_value"
else
    log_warn "Missing date field"
    ((warning_count++))
fi

# Check 6: Agent field present (for exec and review)
if [ "$REPORT_TYPE" = "exec" ] || [ "$REPORT_TYPE" = "review" ]; then
    log_verbose "Checking for agent field..."
    if grep -q '^\*\*Agent\*\*:' "$REPORT_PATH"; then
        agent_value=$(grep '^\*\*Agent\*\*:' "$REPORT_PATH" | head -1 | sed 's/\*\*Agent\*\*:\s*//')
        log_ok "Agent field present: $agent_value"
    else
        log_warn "Missing agent field"
        ((warning_count++))
    fi
fi

# Check 7: Work ID present (for exec and review)
if [ "$REPORT_TYPE" = "exec" ] || [ "$REPORT_TYPE" = "review" ]; then
    log_verbose "Checking for work ID..."
    if grep -qE 'W[0-9]{3}' "$REPORT_PATH"; then
        work_id=$(grep -oE 'W[0-9]{3}' "$REPORT_PATH" | head -1)
        log_ok "Work ID present: $work_id"
    else
        log_warn "No Work ID found (expected W### format)"
        ((warning_count++))
    fi
fi

# Check 8: Status field (for exec and ci)
if [ "$REPORT_TYPE" = "exec" ] || [ "$REPORT_TYPE" = "ci" ]; then
    log_verbose "Checking for status field..."
    if grep -q '^\*\*Status\*\*:' "$REPORT_PATH"; then
        status_value=$(grep '^\*\*Status\*\*:' "$REPORT_PATH" | head -1 | sed 's/\*\*Status\*\*:\s*//')
        log_ok "Status field present: $status_value"
    else
        log_warn "Missing status field"
        ((warning_count++))
    fi
fi

# Check 9: No placeholder text
log_verbose "Checking for placeholder text..."
placeholder_patterns=(
    '{Task Title}'
    '{YYYY-MM-DD}'
    '{agent-name}'
    '{W###}'
    '{description}'
    'TODO'
    'FIXME'
    'XXX'
)

placeholder_found=false
for pattern in "${placeholder_patterns[@]}"; do
    if grep -q "$pattern" "$REPORT_PATH"; then
        if [ "$placeholder_found" = false ]; then
            log_warn "Placeholder text found:"
            placeholder_found=true
        fi
        echo "  - '$pattern'"
        ((warning_count++))
    fi
done

if [ "$placeholder_found" = false ]; then
    log_ok "No placeholder text found"
fi

# Check 10: Review-specific checks
if [ "$REPORT_TYPE" = "review" ]; then
    log_verbose "Running review-specific checks..."

    # Check for verdict checkbox
    if grep -qE '^\s*-\s*\[[ x]\].*Approved|Requires|Major' "$REPORT_PATH"; then
        log_ok "Verdict checkbox found"
    else
        log_warn "Verdict checkbox not found"
        ((warning_count++))
    fi

    # Check for findings table
    if grep -qE '^\|.*Location.*Issue.*\|' "$REPORT_PATH" || grep -qE '^\|.*ID.*Location.*\|' "$REPORT_PATH"; then
        log_ok "Findings table structure present"
    else
        log_warn "Findings table structure not found"
        ((warning_count++))
    fi
fi

# Check 11: Exec-specific checks
if [ "$REPORT_TYPE" = "exec" ]; then
    log_verbose "Running exec-specific checks..."

    # Check for deliverables table
    if grep -qE '^\|.*File.*Action.*\|' "$REPORT_PATH"; then
        log_ok "Deliverables table structure present"
    else
        log_warn "Deliverables table structure not found"
        ((warning_count++))
    fi

    # Check for verification checklist
    if grep -qE '^\s*-\s*\[[ x]\]' "$REPORT_PATH"; then
        log_ok "Verification checklist found"
    else
        log_warn "Verification checklist not found"
        ((warning_count++))
    fi
fi

# Summary
echo ""
echo "========================================"
echo "VERIFICATION SUMMARY"
echo "========================================"
echo "Errors: $error_count"
echo "Warnings: $warning_count"
echo ""

if [ $error_count -eq 0 ] && [ $warning_count -eq 0 ]; then
    echo -e "${GREEN}PASSED${NC}: All verification checks passed"
    exit 0
elif [ $error_count -eq 0 ]; then
    if [ "$STRICT_MODE" = true ]; then
        echo -e "${RED}FAILED${NC}: $warning_count warning(s) in strict mode"
        exit 2
    else
        echo -e "${YELLOW}PASSED WITH WARNINGS${NC}: $warning_count warning(s)"
        echo "Proceeding is allowed but review warnings above"
        exit 1
    fi
else
    echo -e "${RED}FAILED${NC}: $error_count error(s), $warning_count warning(s)"
    exit 2
fi
