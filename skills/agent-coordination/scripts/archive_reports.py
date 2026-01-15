#!/usr/bin/env python3
"""
Registry Archiving Utility

Archives old registry entries to prevent bloat.
Maintains active items and recent completed work.

Usage:
    archive_reports.py <project_dir> [--keep-recent N] [--dry-run]

Examples:
    archive_reports.py /path/to/project
    archive_reports.py /path/to/project --keep-recent 30
    archive_reports.py /path/to/project --dry-run
"""

import argparse
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import List, Tuple, Dict


def parse_registry_table(content: str) -> Tuple[List[str], List[Dict], List[str]]:
    """
    Parse registry markdown content into header, entries, and footer.

    Args:
        content: Raw markdown content of registry file

    Returns:
        Tuple of (header_lines, entries, footer_lines)
    """
    lines = content.split("\n")
    header_lines = []
    footer_lines = []
    entries = []

    in_table = False
    table_ended = False
    header_row_seen = False

    for i, line in enumerate(lines):
        # Detect table start
        if "| ID |" in line or "| ID|" in line:
            in_table = True
            header_row_seen = True
            header_lines.append(line)
            continue

        # Detect separator row
        if in_table and re.match(r"^\|[-|:\s]+\|$", line):
            header_lines.append(line)
            continue

        # Parse table rows
        if in_table and line.startswith("|") and not table_ended:
            parts = [p.strip() for p in line.split("|")]
            # Remove empty strings from split
            parts = [p for p in parts if p]

            if len(parts) >= 6:
                entries.append(
                    {
                        "id": parts[0],
                        "task": parts[1],
                        "agent": parts[2],
                        "status": parts[3],
                        "report": parts[4],
                        "updated": parts[5],
                        "raw": line,
                    }
                )
            elif len(parts) > 0:
                # Malformed row, keep as-is
                entries.append(
                    {
                        "id": parts[0] if parts else "unknown",
                        "task": "",
                        "agent": "",
                        "status": "unknown",
                        "report": "",
                        "updated": "",
                        "raw": line,
                    }
                )
            continue

        # Detect table end
        if in_table and header_row_seen and not line.startswith("|") and line.strip():
            table_ended = True
            in_table = False

        # Collect header or footer
        if not in_table and not table_ended:
            header_lines.append(line)
        elif table_ended:
            footer_lines.append(line)

    return header_lines, entries, footer_lines


def filter_entries(
    entries: List[Dict], keep_active: bool = True, keep_recent: int = 20
) -> Tuple[List[Dict], List[Dict]]:
    """
    Filter entries into keep and archive lists.

    Args:
        entries: List of parsed registry entries
        keep_active: Keep all non-complete entries
        keep_recent: Number of recent completed entries to keep

    Returns:
        Tuple of (entries_to_keep, entries_to_archive)
    """
    keep = []
    archive = []

    # Separate active and completed
    active = [e for e in entries if e["status"] not in ("complete", "completed")]
    completed = [e for e in entries if e["status"] in ("complete", "completed")]

    # Sort completed by date (newest first)
    def parse_date(entry: Dict) -> str:
        """Extract sortable date string."""
        date_str = entry.get("updated", "")
        # Handle various date formats
        if not date_str:
            return "0000-00-00"
        return date_str

    completed.sort(key=parse_date, reverse=True)

    # Keep active entries
    if keep_active:
        keep.extend(active)

    # Keep recent completed, archive the rest
    keep.extend(completed[:keep_recent])
    archive.extend(completed[keep_recent:])

    return keep, archive


def write_registry(
    path: Path, header_lines: List[str], entries: List[Dict], footer_lines: List[str]
) -> None:
    """
    Write registry file with given entries.

    Args:
        path: Path to write registry file
        header_lines: Lines before the table
        entries: Entries to include in table
        footer_lines: Lines after the table
    """
    with open(path, "w") as f:
        # Write header
        for line in header_lines:
            f.write(line + "\n")

        # Write entries
        for entry in entries:
            f.write(entry["raw"] + "\n")

        # Write footer
        if footer_lines:
            f.write("\n")
            for line in footer_lines:
                f.write(line + "\n")


def write_archive(path: Path, entries: List[Dict], timestamp: str) -> None:
    """
    Write archive file with archived entries.

    Args:
        path: Path to write archive file
        entries: Entries to archive
        timestamp: Timestamp for archive header
    """
    with open(path, "w") as f:
        f.write(f"# Registry Archive - {timestamp}\n\n")
        f.write("Archived entries from _registry.md\n\n")
        f.write("| ID | Task | Agent | Status | Report | Updated |\n")
        f.write("|----|------|-------|--------|--------|--------|\n")
        for entry in entries:
            f.write(entry["raw"] + "\n")


def archive_registry(
    project_dir: str, keep_recent: int = 20, dry_run: bool = False
) -> Dict:
    """
    Archive old registry entries.

    Args:
        project_dir: Project root directory
        keep_recent: Number of recent completed entries to keep
        dry_run: If True, don't write changes

    Returns:
        Summary dict with operation results
    """
    reports_dir = Path(project_dir) / ".claude" / "reports"
    registry_path = reports_dir / "_registry.md"

    # Check if registry exists
    if not registry_path.exists():
        return {
            "success": False,
            "error": f"Registry not found at {registry_path}",
            "archived": 0,
        }

    # Read current registry
    with open(registry_path, "r") as f:
        content = f.read()

    # Parse registry
    header_lines, entries, footer_lines = parse_registry_table(content)

    total_entries = len(entries)
    print(f"Found {total_entries} entries in registry")

    # Check if archiving is needed
    if total_entries <= keep_recent + 10:
        return {
            "success": True,
            "message": f"Registry has {total_entries} entries, within limits (threshold: {keep_recent + 10})",
            "archived": 0,
            "kept": total_entries,
        }

    # Filter entries
    keep, archive = filter_entries(entries, keep_recent=keep_recent)

    if not archive:
        return {
            "success": True,
            "message": "No entries to archive",
            "archived": 0,
            "kept": len(keep),
        }

    # Create archive file
    timestamp = datetime.now().strftime("%Y%m%d")
    archive_filename = f"_registry-archive-{timestamp}.md"
    archive_path = reports_dir / archive_filename

    # Handle existing archive for same day
    counter = 1
    while archive_path.exists() and not dry_run:
        archive_filename = f"_registry-archive-{timestamp}-{counter}.md"
        archive_path = reports_dir / archive_filename
        counter += 1

    print(f"\nArchiving {len(archive)} entries")
    print(f"Keeping {len(keep)} entries")
    print(f"Archive file: {archive_path}")

    if dry_run:
        print("\n[DRY RUN] No changes made")
        return {
            "success": True,
            "archived": len(archive),
            "kept": len(keep),
            "archive_file": str(archive_path),
            "dry_run": True,
        }

    # Write archive
    write_archive(archive_path, archive, timestamp)
    print(f"Created archive: {archive_path}")

    # Update main registry
    write_registry(registry_path, header_lines, keep, footer_lines)
    print(f"Updated registry: {registry_path}")

    return {
        "success": True,
        "archived": len(archive),
        "kept": len(keep),
        "archive_file": str(archive_path),
        "dry_run": False,
    }


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Archive old registry entries to prevent bloat",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s /path/to/project
  %(prog)s /path/to/project --keep-recent 30
  %(prog)s /path/to/project --dry-run
        """,
    )
    parser.add_argument(
        "project_dir", help="Project root directory containing .claude/reports/"
    )
    parser.add_argument(
        "--keep-recent",
        "-k",
        type=int,
        default=20,
        help="Number of recent completed entries to keep (default: 20)",
    )
    parser.add_argument(
        "--dry-run",
        "-n",
        action="store_true",
        help="Show what would be archived without making changes",
    )

    args = parser.parse_args()

    # Validate project directory
    project_path = Path(args.project_dir)
    if not project_path.exists():
        print(f"Error: Project directory not found: {args.project_dir}")
        return 1

    reports_path = project_path / ".claude" / "reports"
    if not reports_path.exists():
        print(f"Error: Reports directory not found: {reports_path}")
        print('Hint: Run "mkdir -p .claude/reports" in your project directory')
        return 1

    # Run archiving
    print(f"Project: {args.project_dir}")
    print(f"Keep recent: {args.keep_recent}")
    print(f"Dry run: {args.dry_run}")
    print("")

    result = archive_registry(
        args.project_dir, keep_recent=args.keep_recent, dry_run=args.dry_run
    )

    # Print result
    print("")
    print("=" * 40)
    if not result.get("success", False):
        print(f"Error: {result.get('error', 'Unknown error')}")
        return 1

    if result["archived"] == 0:
        print(result.get("message", "Nothing to archive"))
    else:
        print(f"Archived: {result['archived']} entries")
        print(f"Kept: {result['kept']} entries")
        if result.get("dry_run"):
            print("(Dry run - no changes made)")
        else:
            print(f"Archive file: {result['archive_file']}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
