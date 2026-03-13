#!/usr/bin/env python3
"""
Instagram Auto-Post Script

Main orchestration script that runs weekly to:
1. Get photos from "To Post" album in Photos app
2. Export photos to temp folder
3. Generate captions using AI
4. Schedule posts via Meta Business Suite
5. Move photos to "Posted" album
6. Generate report

Usage:
    python auto-post.py           # Run normal workflow
    python auto-post.py --test    # Run in test mode (dry run)
    python auto-post.py --status  # Show pipeline status
    python auto-post.py --cron-test  # Verify cron setup
"""

import os
import sys
import json
import argparse
from pathlib import Path
from datetime import datetime
from typing import Optional

# Add lib to path
sys.path.insert(0, str(Path(__file__).parent / "lib"))

from lib.photo_export import (
    create_albums,
    get_photos_from_album,
    export_photo_by_index,
    move_photo_by_index,
    get_photo_count,
    get_temp_export_dir,
    clear_temp_exports,
    ensure_photos_app_running,
)

from lib.caption_generator import (
    analyze_photo,
    generate_caption,
    PhotoAnalysis,
    ContentType,
)

from lib.instagram_scheduler import (
    ScheduledPost,
    InstagramScheduler,
    get_posting_schedule,
)


def get_workspace_root() -> Path:
    """Get the workspace root directory."""
    return Path(__file__).parent.parent


def get_logs_dir() -> Path:
    """Get the logs directory."""
    logs_dir = get_workspace_root() / "logs"
    logs_dir.mkdir(parents=True, exist_ok=True)
    return logs_dir


def get_output_dir() -> Path:
    """Get the output directory."""
    output_dir = get_workspace_root() / "output"
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir


def log(message: str, level: str = "INFO") -> None:
    """Log a message with timestamp."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] [{level}] {message}")

    # Also write to log file
    log_file = get_logs_dir() / "auto-post.log"
    with open(log_file, "a") as f:
        f.write(f"[{timestamp}] [{level}] {message}\n")


def generate_report(posts: list[dict], output_dir: Path) -> Path:
    """Generate a report of scheduled posts."""
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    report_path = output_dir / f"report_{timestamp}.md"

    lines = [
        "# Instagram Auto-Post Report",
        "",
        f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        "## Scheduled Posts",
        "",
    ]

    for i, post in enumerate(posts, 1):
        lines.append(f"### Post {i}")
        lines.append(f"- **Photo:** {post.get('photo_path', 'N/A')}")
        lines.append(f"- **Scheduled:** {post.get('schedule_time', 'N/A')}")
        lines.append(f"- **Status:** {post.get('status', 'pending')}")
        lines.append("")
        lines.append("**Caption:**")
        lines.append("```")
        lines.append(post.get('caption', 'N/A'))
        lines.append("```")
        lines.append("")

    report_content = "\n".join(lines)
    report_path.write_text(report_content)

    return report_path


def run_workflow(dry_run: bool = False, use_ai: bool = True) -> dict:
    """
    Run the complete auto-post workflow.

    Args:
        dry_run: If True, don't actually schedule posts
        use_ai: If True, use AI for photo analysis

    Returns:
        Dict with workflow results
    """
    results = {
        "started_at": datetime.now().isoformat(),
        "status": "pending",
        "posts": [],
        "errors": [],
    }

    log("Starting auto-post workflow")

    try:
        # Step 1: Ensure Photos app is running
        log("Ensuring Photos app is running...")
        if not ensure_photos_app_running():
            raise Exception("Could not start Photos app")
        log("Photos app ready")

        # Step 2: Create albums if needed
        log("Creating albums if needed...")
        album_results = create_albums()
        log(f"Albums status: {album_results}")

        # Step 3: Get photos from "To Post" album
        log("Getting photos from 'To Post' album...")
        photos = get_photos_from_album("To Post")

        if len(photos) < 3:
            msg = f"Not enough photos in 'To Post' album (found {len(photos)}, need 3)"
            log(msg, level="WARNING")
            results["status"] = "skipped"
            results["message"] = msg
            return results

        log(f"Found {len(photos)} photos in 'To Post' album")

        # Step 4: Get posting schedule
        schedule = get_posting_schedule()
        log(f"Posting schedule: {[s.strftime('%A %I:%M %p') for s in schedule]}")

        # Step 5: Process first 3 photos
        temp_dir = get_temp_export_dir()
        clear_temp_exports()

        posts_to_schedule = []

        for i in range(3):
            photo = photos[i]
            log(f"Processing photo {i+1}: {photo.filename}")

            # Export photo
            log(f"  Exporting photo...")
            photo_path = export_photo_by_index("To Post", i, temp_dir)

            if not photo_path:
                error_msg = f"Failed to export photo {i+1}"
                log(error_msg, level="ERROR")
                results["errors"].append(error_msg)
                continue

            log(f"  Exported to: {photo_path}")

            # Analyze photo
            log(f"  Analyzing photo...")
            try:
                analysis = analyze_photo(photo_path, use_ai=use_ai)
                log(f"  Detected: {analysis.piece_type}, {analysis.content_type.value}")
            except Exception as e:
                log(f"  Analysis failed, using defaults: {e}", level="WARNING")
                analysis = PhotoAnalysis(
                    content_type=ContentType.FINISHED_PIECE,
                    piece_type="piece",
                    primary_colors=["earth tones"],
                    secondary_colors=[],
                    glaze_type=None,
                    technique=None,
                    mood="warm",
                    is_process=False,
                    dimensions_visible=False,
                    suggested_hook="Handmade ceramic piece"
                )

            # Generate caption
            log(f"  Generating caption...")
            caption = generate_caption(analysis)
            log(f"  Caption length: {len(caption.full_caption)} chars")

            posts_to_schedule.append({
                "photo_path": photo_path,
                "caption": caption.full_caption,
                "schedule_time": schedule[i],
                "photo_id": photo.id,
                "photo_index": i,
                "analysis": {
                    "piece_type": analysis.piece_type,
                    "content_type": analysis.content_type.value,
                    "glaze_type": analysis.glaze_type,
                    "technique": analysis.technique,
                }
            })

        if len(posts_to_schedule) < 3:
            error_msg = f"Only {len(posts_to_schedule)} posts ready, need 3"
            log(error_msg, level="ERROR")
            results["status"] = "partial"
            results["errors"].append(error_msg)

        # Step 6: Schedule posts
        if dry_run:
            log("DRY RUN - skipping actual scheduling", level="INFO")
            for post in posts_to_schedule:
                post["status"] = "dry_run"
                results["posts"].append(post)
        else:
            log("Connecting to Meta Business Suite...")
            scheduler = InstagramScheduler(headless=True)

            try:
                if not scheduler.start():
                    raise Exception("Failed to start browser")

                if not scheduler.login_to_meta():
                    raise Exception("Failed to login to Meta")

                schedule_results = scheduler.schedule_week(
                    [ScheduledPost(
                        photo_path=p["photo_path"],
                        caption=p["caption"],
                        schedule_time=p["schedule_time"]
                    ) for p in posts_to_schedule],
                    dry_run=False
                )

                # Update post statuses
                for i, post in enumerate(posts_to_schedule):
                    if i < len(schedule_results.get("success", [])):
                        post["status"] = "scheduled"
                    else:
                        post["status"] = "failed"
                    results["posts"].append(post)

            finally:
                scheduler.close()

        # Step 7: Move photos to "Posted" album
        log("Moving photos to 'Posted' album...")
        for post in posts_to_schedule:
            if post.get("status") in ["scheduled", "dry_run"]:
                if dry_run:
                    log(f"  Would move photo {post['photo_index'] + 1} to 'Posted'")
                else:
                    success = move_photo_by_index("To Post", "Posted", post["photo_index"])
                    if success:
                        log(f"  Moved photo {post['photo_index'] + 1} to 'Posted'")
                    else:
                        log(f"  Failed to move photo {post['photo_index'] + 1}", level="WARNING")

        # Step 8: Generate report
        log("Generating report...")
        report_path = generate_report(results["posts"], get_output_dir())
        log(f"Report saved to: {report_path}")

        # Clean up temp files
        clear_temp_exports()

        # Set final status
        if len(results["errors"]) == 0:
            results["status"] = "success"
        else:
            results["status"] = "partial"

        log(f"Workflow completed with status: {results['status']}")

    except Exception as e:
        log(f"Workflow failed: {e}", level="ERROR")
        results["status"] = "failed"
        results["errors"].append(str(e))

    results["completed_at"] = datetime.now().isoformat()

    # Save results JSON
    results_path = get_output_dir() / f"results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(results_path, "w") as f:
        json.dump(results, f, indent=2, default=str)

    return results


def show_status() -> None:
    """Show the current pipeline status."""
    print("=" * 60)
    print("Instagram Auto-Post Pipeline Status")
    print("=" * 60)

    # Check albums
    print("\n📷 Albums:")
    to_post_count = get_photo_count("To Post")
    posted_count = get_photo_count("Posted")

    print(f"   'To Post' album: {to_post_count} photos")
    print(f"   'Posted' album: {posted_count} photos")

    # Check next schedule
    print("\n📅 Next Schedule:")
    schedule = get_posting_schedule()
    for i, dt in enumerate(schedule, 1):
        print(f"   Post {i}: {dt.strftime('%A %B %d at %I:%M %p')}")

    # Check recent reports
    print("\n📊 Recent Reports:")
    output_dir = get_output_dir()
    reports = sorted(output_dir.glob("report_*.md"), reverse=True)[:3]

    if reports:
        for report in reports:
            print(f"   {report.name}")
    else:
        print("   No reports yet")

    # Check logs
    print("\n📝 Recent Log Entries:")
    log_file = get_logs_dir() / "auto-post.log"
    if log_file.exists():
        with open(log_file) as f:
            lines = f.readlines()[-5:]
            for line in lines:
                print(f"   {line.strip()}")
    else:
        print("   No logs yet")

    print("\n" + "=" * 60)

    # Recommendation
    if to_post_count >= 3:
        print("✅ Ready to post! Run: python auto-post.py")
    else:
        print(f"⚠️  Add {3 - to_post_count} more photos to 'To Post' album")

    print("=" * 60)


def test_cron() -> bool:
    """Test if cron job is set up correctly."""
    import subprocess

    print("=" * 60)
    print("Cron Job Test")
    print("=" * 60)

    # Check if crontab has our entry
    try:
        result = subprocess.run(
            ["crontab", "-l"],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            print("\n❌ No crontab configured")
            print("\nTo set up cron, run:")
            print("   crontab -e")
            print("\nThen add this line:")
            print("   0 6 * * 1 cd /Users/simongonzalezdecruz/Desktop/Interpreted-Context-Methdology/workspaces/ceramics-instagram && /usr/bin/python3 scripts/auto-post.py >> logs/cron.log 2>&1")
            return False

        crontab = result.stdout

        # Look for our job
        workspace_path = str(get_workspace_root())
        if "auto-post.py" in crontab:
            print("\n✅ Cron job found!")
            for line in crontab.split("\n"):
                if "auto-post" in line:
                    print(f"   {line}")
        else:
            print("\n⚠️  Cron job not found")
            print("\nTo add, run: crontab -e")
            print("Then add:")
            print(f"   0 6 * * 1 cd {workspace_path} && /usr/bin/python3 scripts/auto-post.py >> logs/cron.log 2>&1")

        # Check script is executable
        script_path = Path(__file__)
        print(f"\n📄 Script: {script_path}")
        print(f"   Exists: {'✅' if script_path.exists() else '❌'}")

        # Check logs directory
        logs_dir = get_logs_dir()
        print(f"\n📁 Logs directory: {logs_dir}")
        print(f"   Exists: {'✅' if logs_dir.exists() else '❌'}")

    except Exception as e:
        print(f"\n❌ Error checking cron: {e}")
        return False

    print("\n" + "=" * 60)
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Instagram Auto-Post Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python auto-post.py           Run normal workflow
    python auto-post.py --test    Run in test mode (dry run)
    python auto-post.py --status  Show pipeline status
    python auto-post.py --cron-test  Verify cron setup
    python auto-post.py --no-ai   Run without AI analysis
        """
    )

    parser.add_argument(
        "--test", "-t",
        action="store_true",
        help="Run in test mode (dry run, no actual posting)"
    )

    parser.add_argument(
        "--status", "-s",
        action="store_true",
        help="Show pipeline status"
    )

    parser.add_argument(
        "--cron-test",
        action="store_true",
        help="Test cron job setup"
    )

    parser.add_argument(
        "--no-ai",
        action="store_true",
        help="Disable AI photo analysis (use basic analysis)"
    )

    args = parser.parse_args()

    if args.status:
        show_status()

    elif args.cron_test:
        test_cron()

    else:
        dry_run = args.test
        use_ai = not args.no_ai

        print("=" * 60)
        print("Instagram Auto-Post")
        print("=" * 60)
        print(f"Mode: {'TEST (dry run)' if dry_run else 'LIVE'}")
        print(f"AI Analysis: {'Enabled' if use_ai else 'Disabled'}")
        print("=" * 60)

        results = run_workflow(dry_run=dry_run, use_ai=use_ai)

        print("\n" + "=" * 60)
        print("Results")
        print("=" * 60)
        print(f"Status: {results['status']}")
        print(f"Posts processed: {len(results['posts'])}")

        if results['errors']:
            print(f"\nErrors:")
            for error in results['errors']:
                print(f"  - {error}")

        print("\n" + "=" * 60)


if __name__ == "__main__":
    main()
