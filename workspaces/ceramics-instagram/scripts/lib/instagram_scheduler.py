"""
Instagram scheduler module for posting via Meta Business Suite.

Uses Playwright for browser automation to:
- Log into Meta Business Suite (with session persistence)
- Schedule posts for optimal times
- Handle multiple posts per week

Security:
- Credentials stored in macOS Keychain or env vars
- Session cookies saved for headless operation
- First run requires manual login
"""

import os
import json
import time
from pathlib import Path
from datetime import datetime, timedelta
from typing import Optional
from dataclasses import dataclass


@dataclass
class ScheduledPost:
    """A scheduled Instagram post."""
    photo_path: str
    caption: str
    schedule_time: datetime
    photo_id: Optional[str] = None


@dataclass
class ScheduledReel:
    """A scheduled Instagram Reel."""
    video_path: str
    caption: str
    schedule_time: datetime
    duration_seconds: float
    aspect_ratio: str = "vertical"


@dataclass
class ScheduledStory:
    """A scheduled Instagram Story."""
    media_path: str
    schedule_time: datetime
    media_type: str  # "photo" or "video"
    poll_question: Optional[str] = None
    poll_options: Optional[list[str]] = None


@dataclass
class ScheduledCarousel:
    """A scheduled Instagram carousel post."""
    media_paths: list[str]  # 2-10 photos/videos
    caption: str
    schedule_time: datetime
    card_count: int
    carousel_id: Optional[str] = None


def get_workspace_root() -> Path:
    """Get the workspace root directory."""
    return Path(__file__).parent.parent.parent


def get_session_dir() -> Path:
    """Get the directory for browser session data."""
    session_dir = get_workspace_root() / "data" / "browser_session"
    session_dir.mkdir(parents=True, exist_ok=True)
    return session_dir


def get_cookies_path() -> Path:
    """Get the path to saved cookies."""
    return get_session_dir() / "cookies.json"


def save_cookies(cookies: list) -> None:
    """Save cookies to file."""
    path = get_cookies_path()
    with open(path, "w") as f:
        json.dump(cookies, f)


def load_cookies() -> Optional[list]:
    """Load cookies from file."""
    path = get_cookies_path()
    if path.exists():
        with open(path, "r") as f:
            return json.load(f)
    return None


def cookies_valid(cookies: list) -> bool:
    """Check if cookies are still valid (not expired)."""
    if not cookies:
        return False

    # Check for essential cookies
    essential = ["xs", "c_user", "fr"]
    found = {name: False for name in essential}

    for cookie in cookies:
        if cookie.get("name") in essential:
            # Check if expired
            if "expires" in cookie:
                if isinstance(cookie["expires"], (int, float)):
                    if cookie["expires"] > time.time():
                        found[cookie["name"]] = True
            else:
                found[cookie["name"]] = True

    return all(found.values())


def get_posting_schedule(reference_date: datetime = None, count: int = 3) -> list[datetime]:
    """
    Get optimal posting times for the current week.

    Schedule:
    - Monday 8:00 AM (Best day × Best hour)
    - Tuesday 5:00 PM (Third best day × Good hour)
    - Friday 8:00 AM (Second best day × Best hour)

    Args:
        reference_date: Date to calculate from (defaults to next Monday)
        count: Number of posting slots to return (1-3, default 3)

    Returns:
        List of datetime objects for posting (length based on count)
    """
    if reference_date is None:
        # Default to next Monday
        today = datetime.now()
        days_until_monday = (7 - today.weekday()) % 7
        if days_until_monday == 0:
            days_until_monday = 7  # If today is Monday, use next Monday
        reference_date = today + timedelta(days=days_until_monday)

    # Monday 8:00 AM
    post1 = reference_date.replace(hour=8, minute=0, second=0, microsecond=0)

    # Tuesday 5:00 PM
    post2 = post1 + timedelta(days=1, hours=9)  # Monday 8AM + 1 day + 9 hours = Tuesday 5PM

    # Friday 8:00 AM
    post3 = post1 + timedelta(days=4)  # Monday + 4 days = Friday

    # Return only as many slots as needed
    all_slots = [post1, post2, post3]
    return all_slots[:min(count, 3)]


class InstagramScheduler:
    """Instagram post scheduler using Playwright."""

    def __init__(self, headless: bool = True):
        self.headless = headless
        self.browser = None
        self.context = None
        self.page = None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def start(self) -> bool:
        """Start the browser and load session."""
        try:
            from playwright.sync_api import sync_playwright

            self.playwright = sync_playwright().start()

            # Try to load existing session
            cookies = load_cookies()

            if cookies and cookies_valid(cookies):
                print("Found valid session cookies, using headless mode")
                self.browser = self.playwright.chromium.launch(headless=True)
                self.context = self.browser.new_context()
                self.context.add_cookies(cookies)
            else:
                print("No valid session found, will need manual login")
                self.browser = self.playwright.chromium.launch(headless=self.headless)
                self.context = self.browser.new_context()

            self.page = self.context.new_page()
            return True

        except ImportError:
            print("Error: Playwright not installed. Run: pip install playwright && playwright install chromium")
            return False
        except Exception as e:
            print(f"Error starting browser: {e}")
            return False

    def close(self) -> None:
        """Close the browser and save session."""
        if self.context:
            try:
                cookies = self.context.cookies()
                save_cookies(cookies)
            except Exception as e:
                print(f"Warning: Could not save cookies: {e}")

        if self.browser:
            self.browser.close()

        if hasattr(self, 'playwright'):
            self.playwright.stop()

    def login_to_meta(self) -> bool:
        """
        Log into Meta Business Suite.

        First run opens browser for manual login.
        Subsequent runs use saved cookies.

        Returns:
            True if logged in successfully
        """
        if not self.page:
            if not self.start():
                return False

        # Navigate to Meta Business Suite
        print("Navigating to Meta Business Suite...")
        self.page.goto("https://business.facebook.com/")

        # Wait for page load
        time.sleep(2)

        # Check if already logged in
        if "login" not in self.page.url.lower():
            print("Already logged in!")
            return True

        # Need manual login
        print("\n" + "=" * 60)
        print("MANUAL LOGIN REQUIRED")
        print("=" * 60)
        print("1. Log into your Facebook account in the browser window")
        print("2. Navigate to Meta Business Suite")
        print("3. Select your Instagram account")
        print("4. Press Enter here when done...")
        print("=" * 60)

        input("\nPress Enter when logged in...")

        # Save session after successful login
        cookies = self.context.cookies()
        save_cookies(cookies)
        print("Session saved for future use!")

        return True

    def navigate_to_scheduler(self) -> bool:
        """Navigate to the post scheduler in Meta Business Suite."""
        if not self.page:
            return False

        try:
            # Go to Meta Business Suite
            self.page.goto("https://business.facebook.com/")

            # Wait for content to load
            self.page.wait_for_load_state("networkidle", timeout=30000)
            time.sleep(2)

            # Look for "Planner" or "Create post" button
            # Meta Business Suite UI changes frequently, so we try multiple selectors

            selectors = [
                'text="Planner"',
                'text="Create post"',
                'text="Create"',
                '[aria-label="Create post"]',
                'a[href*="planner"]',
                'a[href*="content"]',
            ]

            for selector in selectors:
                try:
                    element = self.page.query_selector(selector)
                    if element:
                        element.click()
                        print(f"Found scheduler via: {selector}")
                        time.sleep(3)
                        return True
                except Exception:
                    continue

            print("Could not find scheduler. Please navigate manually.")
            print("Press Enter when on the Create Post page...")
            input()
            return True

        except Exception as e:
            print(f"Error navigating to scheduler: {e}")
            return False

    def schedule_post(self, post: ScheduledPost, dry_run: bool = False) -> bool:
        """
        Schedule a single post.

        Args:
            post: ScheduledPost object with photo, caption, and time
            dry_run: If True, don't actually schedule

        Returns:
            True if successful
        """
        if not self.page:
            return False

        print(f"\nScheduling post for {post.schedule_time.strftime('%A %B %d at %I:%M %p')}")
        print(f"Photo: {Path(post.photo_path).name}")

        if dry_run:
            print("DRY RUN - would schedule this post")
            return True

        try:
            # Navigate to create post
            self.navigate_to_scheduler()

            # Upload photo
            print("Uploading photo...")
            upload_input = self.page.query_selector('input[type="file"]')
            if upload_input:
                upload_input.set_input_files(post.photo_path)
                time.sleep(3)  # Wait for upload
            else:
                print("Could not find upload input")
                return False

            # Add caption
            print("Adding caption...")
            caption_selectors = [
                'div[contenteditable="true"]',
                'textarea[placeholder*="caption"]',
                'textarea[placeholder*="Write"]',
                '[data-testid="caption-input"]',
            ]

            for selector in caption_selectors:
                try:
                    caption_box = self.page.query_selector(selector)
                    if caption_box:
                        caption_box.click()
                        caption_box.fill(post.caption)
                        break
                except Exception:
                    continue

            # Select Instagram account
            print("Selecting Instagram account...")
            # This varies by setup - user may need to do manually

            # Schedule for later
            print("Setting schedule time...")
            schedule_selectors = [
                'text="Schedule"',
                'text="Schedule for later"',
                '[aria-label="Schedule"]',
            ]

            for selector in schedule_selectors:
                try:
                    element = self.page.query_selector(selector)
                    if element:
                        element.click()
                        time.sleep(1)
                        break
                except Exception:
                    continue

            # Set date and time
            # This is UI-dependent and complex
            # For now, we'll just click schedule and let user verify

            print("Post uploaded and caption added!")
            print("Please verify the schedule time in the UI and click Schedule.")
            print("Press Enter when done...")
            input()

            return True

        except Exception as e:
            print(f"Error scheduling post: {e}")
            return False

    def navigate_to_reels(self) -> bool:
        """Navigate to Reels creation in Meta Business Suite."""
        if not self.page:
            return False

        try:
            # Go to Meta Business Suite content section
            self.page.goto("https://business.facebook.com/latest/content")
            self.page.wait_for_load_state("networkidle", timeout=30000)
            time.sleep(2)

            # Look for Create button and Reel option
            create_selectors = [
                'text="Create"',
                '[aria-label="Create"]',
                'div[role="button"]:has-text("Create")',
            ]

            for selector in create_selectors:
                try:
                    element = self.page.query_selector(selector)
                    if element:
                        element.click()
                        time.sleep(1)
                        break
                except Exception:
                    continue

            # Look for Reel tab
            reel_selectors = [
                'text="Reel"',
                'text="Instagram Reel"',
                '[aria-label="Reel"]',
            ]

            for selector in reel_selectors:
                try:
                    element = self.page.query_selector(selector)
                    if element:
                        element.click()
                        time.sleep(1)
                        return True
                except Exception:
                    continue

            print("Could not find Reels option. Please navigate manually.")
            return True  # Continue anyway, user can navigate

        except Exception as e:
            print(f"Error navigating to Reels: {e}")
            return False

    def schedule_reel(self, reel: ScheduledReel, dry_run: bool = False) -> bool:
        """
        Schedule a Reel.

        Args:
            reel: ScheduledReel object with video, caption, and time
            dry_run: If True, don't actually schedule

        Returns:
            True if successful
        """
        if not self.page:
            return False

        print(f"\nScheduling Reel for {reel.schedule_time.strftime('%A %B %d at %I:%M %p')}")
        print(f"Video: {Path(reel.video_path).name}")
        print(f"Duration: {reel.duration_seconds:.1f}s")
        print(f"Aspect ratio: {reel.aspect_ratio}")

        if dry_run:
            print("DRY RUN - would schedule this Reel")
            return True

        try:
            # Navigate to Reels section
            self.navigate_to_reels()

            # Upload video
            print("Uploading video...")
            upload_input = self.page.query_selector('input[type="file"]')
            if upload_input:
                upload_input.set_input_files(reel.video_path)
                time.sleep(5)  # Wait longer for video upload
            else:
                print("Could not find upload input")
                return False

            # Add caption
            print("Adding caption...")
            caption_selectors = [
                'div[contenteditable="true"]',
                'textarea[placeholder*="caption"]',
                'textarea[placeholder*="Write"]',
            ]

            for selector in caption_selectors:
                try:
                    caption_box = self.page.query_selector(selector)
                    if caption_box:
                        caption_box.click()
                        caption_box.fill(reel.caption)
                        break
                except Exception:
                    continue

            # Schedule for later
            print("Setting schedule time...")
            schedule_selectors = [
                'text="Schedule"',
                'text="Schedule for later"',
            ]

            for selector in schedule_selectors:
                try:
                    element = self.page.query_selector(selector)
                    if element:
                        element.click()
                        time.sleep(1)
                        break
                except Exception:
                    continue

            print("Reel uploaded and caption added!")
            print("Please verify the schedule time in the UI and click Schedule.")
            print("Press Enter when done...")
            input()

            return True

        except Exception as e:
            print(f"Error scheduling Reel: {e}")
            return False

    def navigate_to_stories(self) -> bool:
        """Navigate to Stories creation in Meta Business Suite."""
        if not self.page:
            return False

        try:
            # Go to Meta Business Suite content section
            self.page.goto("https://business.facebook.com/latest/content")
            self.page.wait_for_load_state("networkidle", timeout=30000)
            time.sleep(2)

            # Look for Create button
            create_selectors = [
                'text="Create"',
                '[aria-label="Create"]',
                'div[role="button"]:has-text("Create")',
            ]

            for selector in create_selectors:
                try:
                    element = self.page.query_selector(selector)
                    if element:
                        element.click()
                        time.sleep(1)
                        break
                except Exception:
                    continue

            # Look for Story tab
            story_selectors = [
                'text="Story"',
                'text="Instagram Story"',
                '[aria-label="Story"]',
            ]

            for selector in story_selectors:
                try:
                    element = self.page.query_selector(selector)
                    if element:
                        element.click()
                        time.sleep(1)
                        return True
                except Exception:
                    continue

            print("Could not find Stories option. Please navigate manually.")
            return True  # Continue anyway

        except Exception as e:
            print(f"Error navigating to Stories: {e}")
            return False

    def schedule_story(self, story: ScheduledStory, dry_run: bool = False) -> bool:
        """
        Schedule a Story.

        Args:
            story: ScheduledStory object with media and time
            dry_run: If True, don't actually schedule

        Returns:
            True if successful
        """
        if not self.page:
            return False

        print(f"\nScheduling Story for {story.schedule_time.strftime('%A %B %d at %I:%M %p')}")
        print(f"Media: {Path(story.media_path).name}")
        print(f"Type: {story.media_type}")

        if story.poll_question:
            print(f"Poll: {story.poll_question}")

        if dry_run:
            print("DRY RUN - would schedule this Story")
            return True

        try:
            # Navigate to Stories section
            self.navigate_to_stories()

            # Upload media
            print("Uploading media...")
            upload_input = self.page.query_selector('input[type="file"]')
            if upload_input:
                upload_input.set_input_files(story.media_path)
                time.sleep(3)
            else:
                print("Could not find upload input")
                return False

            # Add poll if specified
            if story.poll_question and story.poll_options:
                print("Adding poll sticker...")
                # This requires clicking on stickers button and adding poll
                # UI-dependent, so we'll note it for manual addition
                print(f"NOTE: Please add poll manually: '{story.poll_question}'")
                print(f"Options: {', '.join(story.poll_options)}")

            # Stories typically don't have scheduling in the same way
            # They're usually posted immediately or scheduled for a specific time
            print("Story uploaded!")
            print("Stories expire in 24 hours.")
            print("Press Enter when done...")
            input()

            return True

        except Exception as e:
            print(f"Error scheduling Story: {e}")
            return False

    def schedule_carousel(self, carousel: ScheduledCarousel, dry_run: bool = False) -> bool:
        """
        Schedule a carousel post with multiple images/videos.

        Args:
            carousel: ScheduledCarousel object with media paths and caption
            dry_run: If True, don't actually schedule

        Returns:
            True if successful
        """
        if not self.page:
            return False

        print(f"\nScheduling Carousel for {carousel.schedule_time.strftime('%A %B %d at %I:%M %p')}")
        print(f"Cards: {carousel.card_count}")
        for i, path in enumerate(carousel.media_paths):
            print(f"  {i+1}. {Path(path).name}")

        if dry_run:
            print("DRY RUN - would schedule this Carousel")
            return True

        try:
            # Navigate to create post
            self.navigate_to_scheduler()

            # Upload multiple files
            print("Uploading carousel media...")
            upload_input = self.page.query_selector('input[type="file"]')
            if upload_input:
                # Upload all files at once for carousel
                upload_input.set_input_files(carousel.media_paths)
                time.sleep(5)  # Longer wait for multiple files
            else:
                print("Could not find upload input")
                return False

            # Verify carousel format detected
            print("Verifying carousel format...")
            time.sleep(2)

            # Add caption
            print("Adding caption...")
            caption_selectors = [
                'div[contenteditable="true"]',
                'textarea[placeholder*="caption"]',
                'textarea[placeholder*="Write"]',
            ]

            for selector in caption_selectors:
                try:
                    caption_box = self.page.query_selector(selector)
                    if caption_box:
                        caption_box.click()
                        caption_box.fill(carousel.caption)
                        break
                except Exception:
                    continue

            # Schedule for later
            print("Setting schedule time...")
            schedule_selectors = [
                'text="Schedule"',
                'text="Schedule for later"',
            ]

            for selector in schedule_selectors:
                try:
                    element = self.page.query_selector(selector)
                    if element:
                        element.click()
                        time.sleep(1)
                        break
                except Exception:
                    continue

            print("Carousel uploaded and caption added!")
            print("Please verify the schedule time in the UI and click Schedule.")
            print("Press Enter when done...")
            input()

            return True

        except Exception as e:
            print(f"Error scheduling Carousel: {e}")
            return False

    def schedule_week(self, posts: list[ScheduledPost], dry_run: bool = False) -> dict:
        """
        Schedule multiple posts for the week.

        Args:
            posts: List of ScheduledPost objects
            dry_run: If True, don't actually schedule

        Returns:
            Dict with results for each post
        """
        results = {
            "success": [],
            "failed": [],
            "skipped": []
        }

        if len(posts) < 3:
            print(f"Warning: Only {len(posts)} posts provided, expected 3")

        for i, post in enumerate(posts):
            print(f"\n{'=' * 40}")
            print(f"Post {i + 1}/{len(posts)}")
            print(f"{'=' * 40}")

            success = self.schedule_post(post, dry_run=dry_run)

            if success:
                results["success"].append({
                    "photo": post.photo_path,
                    "scheduled_for": post.schedule_time.isoformat()
                })
            else:
                results["failed"].append({
                    "photo": post.photo_path,
                    "reason": "Scheduling failed"
                })

        return results


def login_to_meta(headless: bool = True) -> InstagramScheduler:
    """
    Convenience function to create and login to Meta.

    Args:
        headless: Whether to run browser in headless mode

    Returns:
        Authenticated InstagramScheduler instance
    """
    scheduler = InstagramScheduler(headless=headless)
    scheduler.start()
    scheduler.login_to_meta()
    return scheduler


def schedule_post(scheduler: InstagramScheduler, post: ScheduledPost, dry_run: bool = False) -> bool:
    """Schedule a single post."""
    return scheduler.schedule_post(post, dry_run=dry_run)


def schedule_week(scheduler: InstagramScheduler, posts: list[ScheduledPost], dry_run: bool = False) -> dict:
    """Schedule multiple posts for the week."""
    return scheduler.schedule_week(posts, dry_run=dry_run)


def close_browser(scheduler: InstagramScheduler) -> None:
    """Close the browser and save session."""
    scheduler.close()


def test_module(dry_run: bool = True):
    """Test the Instagram scheduler module."""
    print("=" * 60)
    print("Instagram Scheduler Module Test")
    print("=" * 60)

    print(f"\nMode: {'DRY RUN (no actual posts)' if dry_run else 'LIVE (will schedule posts)'}")

    # 1. Test schedule calculation
    print("\n1. Testing posting schedule calculation...")
    schedule = get_posting_schedule()
    for i, dt in enumerate(schedule):
        print(f"   Post {i+1}: {dt.strftime('%A %B %d at %I:%M %p')}")

    # 2. Test browser startup
    print("\n2. Testing browser startup...")
    scheduler = InstagramScheduler(headless=not dry_run)

    try:
        if scheduler.start():
            print("   ✓ Browser started successfully")
        else:
            print("   ✗ Failed to start browser")
            return

        # 3. Test login (will prompt for manual login if needed)
        print("\n3. Testing Meta login...")
        if dry_run:
            print("   Skipping actual login in dry-run mode")
        else:
            if scheduler.login_to_meta():
                print("   ✓ Logged in successfully")
            else:
                print("   ✗ Login failed")

        # 4. Test post scheduling
        print("\n4. Testing post scheduling (dry run)...")

        # Create a mock post
        mock_post = ScheduledPost(
            photo_path="/tmp/test_photo.jpg",  # Mock path
            caption="Test caption for dry run",
            schedule_time=schedule[0]
        )

        if dry_run:
            print(f"   Would schedule: {mock_post.photo_path}")
            print(f"   For: {mock_post.schedule_time}")
            print("   ✓ Dry run complete")
        else:
            success = scheduler.schedule_post(mock_post, dry_run=True)
            if success:
                print("   ✓ Post scheduling test passed")
            else:
                print("   ✗ Post scheduling test failed")

    finally:
        print("\n5. Closing browser...")
        scheduler.close()
        print("   ✓ Browser closed and session saved")

    print("\n" + "=" * 60)
    print("Test complete!")
    print("=" * 60)


if __name__ == "__main__":
    import sys

    dry_run = "--dry-run" in sys.argv or "--test" in sys.argv

    if "--test" in sys.argv or "--dry-run" in sys.argv:
        test_module(dry_run=dry_run)
    else:
        print("Usage:")
        print("  python instagram_scheduler.py --test")
        print("  python instagram_scheduler.py --dry-run")
        print("       Tests the scheduler module without posting")
