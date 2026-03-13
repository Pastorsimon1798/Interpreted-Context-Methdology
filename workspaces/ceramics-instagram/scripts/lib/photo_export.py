"""
Photo export module for macOS Photos app integration.

Uses AppleScript to interact with the Photos app for:
- Creating albums ("To Post", "Posted")
- Listing photos in albums
- Exporting photos to file system
- Moving photos between albums
"""

import subprocess
import json
import os
import tempfile
import shutil
from pathlib import Path
from datetime import datetime
from typing import Optional
from dataclasses import dataclass


@dataclass
class PhotoInfo:
    """Photo metadata from Photos app."""
    id: str
    filename: str
    date: str
    width: int
    height: int
    album: str


def run_applescript(script: str) -> tuple[bool, str]:
    """
    Run an AppleScript and return (success, output).

    Args:
        script: AppleScript code to execute

    Returns:
        Tuple of (success: bool, output: str)
    """
    try:
        result = subprocess.run(
            ["osascript", "-e", script],
            capture_output=True,
            text=True,
            timeout=60
        )
        if result.returncode == 0:
            return True, result.stdout.strip()
        else:
            return False, result.stderr.strip()
    except subprocess.TimeoutExpired:
        return False, "AppleScript timed out"
    except Exception as e:
        return False, str(e)


def ensure_photos_app_running() -> bool:
    """Ensure Photos app is running, launch if needed."""
    script = '''
    tell application "Photos"
        activate
        delay 2
        return "ready"
    end tell
    '''
    success, output = run_applescript(script)
    return success and "ready" in output


def create_albums(albums: list[str] = None) -> dict[str, bool]:
    """
    Create albums if they don't exist.

    Args:
        albums: List of album names to create. Defaults to ["To Post", "Posted"]

    Returns:
        Dict mapping album name to success status
    """
    if albums is None:
        albums = ["To Post", "Posted"]

    results = {}

    for album_name in albums:
        # Check if album exists, create if not
        script = f'''
        tell application "Photos"
            set albumName to "{album_name}"
            set albumExists to false

            repeat with a in albums
                if name of a is albumName then
                    set albumExists to true
                    exit repeat
                end if
            end repeat

            if not albumExists then
                make new album named albumName
                return "created"
            else
                return "exists"
            end if
        end tell
        '''
        success, output = run_applescript(script)
        results[album_name] = success

    return results


def get_photos_from_album(album_name: str) -> list[PhotoInfo]:
    """
    Get list of photos from an album.

    Args:
        album_name: Name of the album to get photos from

    Returns:
        List of PhotoInfo objects with photo metadata
    """
    script = f'''
    tell application "Photos"
        set targetAlbum to missing value

        repeat with a in albums
            if name of a is "{album_name}" then
                set targetAlbum to a
                exit repeat
            end if
        end repeat

        if targetAlbum is missing value then
            return "ALBUM_NOT_FOUND"
        end if

        set photoList to {{}}
        repeat with p in media items of targetAlbum
            set photoId to id of p
            set photoFilename to filename of p
            set photoDate to date of p as string
            set photoWidth to width of p
            set photoHeight to height of p

            set end of photoList to photoId & "|||" & photoFilename & "|||" & photoDate & "|||" & photoWidth & "|||" & photoHeight
        end repeat

        return photoList as string
    end tell
    '''

    success, output = run_applescript(script)

    if not success:
        print(f"Error getting photos: {output}")
        return []

    if output == "ALBUM_NOT_FOUND":
        print(f"Album '{album_name}' not found")
        return []

    photos = []
    if output:
        for line in output.split(", "):
            if "|||" in line:
                parts = line.split("|||")
                if len(parts) >= 5:
                    photos.append(PhotoInfo(
                        id=parts[0].strip(),
                        filename=parts[1].strip(),
                        date=parts[2].strip(),
                        width=int(parts[3].strip()) if parts[3].strip().isdigit() else 0,
                        height=int(parts[4].strip()) if parts[4].strip().isdigit() else 0,
                        album=album_name
                    ))

    return photos


def export_photo(photo_id: str, output_dir: str, filename: Optional[str] = None) -> Optional[str]:
    """
    Export a single photo to the output directory.

    Args:
        photo_id: The Photos app ID of the photo
        output_dir: Directory to export to
        filename: Optional custom filename (will use original if not provided)

    Returns:
        Path to exported file, or None if export failed
    """
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    script = f'''
    tell application "Photos"
        set targetPhoto to missing value

        repeat with p in media items
            if id of p is "{photo_id}" then
                set targetPhoto to p
                exit repeat
            end if
        end repeat

        if targetPhoto is missing value then
            return "PHOTO_NOT_FOUND"
        end if

        -- Export the photo
        set exportPath to POSIX path of "{output_dir}"
        export {{targetPhoto}} to exportPath with using originals

        return "EXPORTED"
    end tell
    '''

    success, output = run_applescript(script)

    if not success:
        print(f"Error exporting photo: {output}")
        return None

    if output == "PHOTO_NOT_FOUND":
        print(f"Photo with ID {photo_id} not found")
        return None

    # Find the exported file (Photos app uses original filename)
    # Wait a moment for file system to catch up
    import time
    time.sleep(1)

    exported_files = list(Path(output_dir).glob("*"))
    if exported_files:
        # Return the most recently modified file
        latest = max(exported_files, key=lambda f: f.stat().st_mtime)
        return str(latest)

    return None


def export_photo_by_index(album_name: str, index: int, output_dir: str) -> Optional[str]:
    """
    Export a photo by its index in an album.

    This is more reliable than using photo IDs for export.

    Args:
        album_name: Name of the album
        index: Zero-based index of photo in album
        output_dir: Directory to export to

    Returns:
        Path to exported file, or None if export failed
    """
    os.makedirs(output_dir, exist_ok=True)

    script = f'''
    tell application "Photos"
        set targetAlbum to missing value

        repeat with a in albums
            if name of a is "{album_name}" then
                set targetAlbum to a
                exit repeat
            end if
        end repeat

        if targetAlbum is missing value then
            return "ALBUM_NOT_FOUND"
        end if

        set albumPhotos to media items of targetAlbum
        set photoCount to count of albumPhotos

        if photoCount is 0 then
            return "NO_PHOTOS"
        end if

        if {index} >= photoCount then
            return "INDEX_OUT_OF_RANGE"
        end if

        set targetPhoto to item ({index} + 1) of albumPhotos
        set exportPath to POSIX path of "{output_dir}"
        set photoFilename to filename of targetPhoto

        export {{targetPhoto}} to exportPath with using originals

        return photoFilename
    end tell
    '''

    success, output = run_applescript(script)

    if not success:
        print(f"Error exporting photo: {output}")
        return None

    if output in ["ALBUM_NOT_FOUND", "NO_PHOTOS", "INDEX_OUT_OF_RANGE"]:
        print(f"Export failed: {output}")
        return None

    # The file should be in output_dir with the original filename
    exported_path = Path(output_dir) / output
    if exported_path.exists():
        return str(exported_path)

    # Try to find any recent file
    import time
    time.sleep(1)
    exported_files = list(Path(output_dir).glob("*"))
    if exported_files:
        latest = max(exported_files, key=lambda f: f.stat().st_mtime)
        return str(latest)

    return None


def move_to_album(photo_id: str, from_album: str, to_album: str) -> bool:
    """
    Move a photo from one album to another.

    Note: This adds the photo to the destination album but doesn't remove
    it from the source album (Photos app limitation via AppleScript).

    Args:
        photo_id: The Photos app ID of the photo
        from_album: Source album name (for logging)
        to_album: Destination album name

    Returns:
        True if successful, False otherwise
    """
    script = f'''
    tell application "Photos"
        set targetPhoto to missing value
        set destAlbum to missing value

        -- Find the photo
        repeat with p in media items
            if id of p is "{photo_id}" then
                set targetPhoto to p
                exit repeat
            end if
        end repeat

        if targetPhoto is missing value then
            return "PHOTO_NOT_FOUND"
        end if

        -- Find the destination album
        repeat with a in albums
            if name of a is "{to_album}" then
                set destAlbum to a
                exit repeat
            end if
        end repeat

        if destAlbum is missing value then
            return "ALBUM_NOT_FOUND"
        end if

        -- Add photo to destination album
        add {{targetPhoto}} to destAlbum

        return "MOVED"
    end tell
    '''

    success, output = run_applescript(script)

    if not success:
        print(f"Error moving photo: {output}")
        return False

    return output == "MOVED"


def move_photo_by_index(from_album: str, to_album: str, index: int) -> bool:
    """
    Move a photo by its index from one album to another.

    Args:
        from_album: Source album name
        to_album: Destination album name
        index: Zero-based index of photo in source album

    Returns:
        True if successful, False otherwise
    """
    script = f'''
    tell application "Photos"
        set sourceAlbum to missing value
        set destAlbum to missing value

        -- Find source album
        repeat with a in albums
            if name of a is "{from_album}" then
                set sourceAlbum to a
                exit repeat
            end if
        end repeat

        -- Find destination album
        repeat with a in albums
            if name of a is "{to_album}" then
                set destAlbum to a
                exit repeat
            end if
        end repeat

        if sourceAlbum is missing value or destAlbum is missing value then
            return "ALBUM_NOT_FOUND"
        end if

        set albumPhotos to media items of sourceAlbum
        set photoCount to count of albumPhotos

        if photoCount is 0 then
            return "NO_PHOTOS"
        end if

        if {index} >= photoCount then
            return "INDEX_OUT_OF_RANGE"
        end if

        set targetPhoto to item ({index} + 1) of albumPhotos
        add {{targetPhoto}} to destAlbum

        return "MOVED"
    end tell
    '''

    success, output = run_applescript(script)

    if not success:
        print(f"Error moving photo: {output}")
        return False

    return output == "MOVED"


def get_photo_count(album_name: str) -> int:
    """Get the number of photos in an album."""
    script = f'''
    tell application "Photos"
        set targetAlbum to missing value

        repeat with a in albums
            if name of a is "{album_name}" then
                set targetAlbum to a
                exit repeat
            end if
        end repeat

        if targetAlbum is missing value then
            return "-1"
        end if

        return (count of media items of targetAlbum) as string
    end tell
    '''

    success, output = run_applescript(script)

    if not success:
        return -1

    try:
        return int(output)
    except ValueError:
        return -1


def get_temp_export_dir() -> str:
    """Get a temporary directory for photo exports."""
    temp_dir = Path(tempfile.gettempdir()) / "ceramics_instagram_exports"
    temp_dir.mkdir(parents=True, exist_ok=True)
    return str(temp_dir)


def clear_temp_exports() -> None:
    """Clear the temporary export directory."""
    temp_dir = get_temp_export_dir()
    if Path(temp_dir).exists():
        shutil.rmtree(temp_dir)
        Path(temp_dir).mkdir(parents=True, exist_ok=True)


def test_module():
    """Test the photo export module."""
    print("=" * 60)
    print("Photo Export Module Test")
    print("=" * 60)

    # 1. Ensure Photos app is running
    print("\n1. Ensuring Photos app is running...")
    if ensure_photos_app_running():
        print("   ✓ Photos app is ready")
    else:
        print("   ✗ Failed to launch Photos app")
        return

    # 2. Create albums
    print("\n2. Creating albums...")
    results = create_albums()
    for album, success in results.items():
        status = "✓" if success else "✗"
        print(f"   {status} {album}")

    # 3. Get photo count
    print("\n3. Checking 'To Post' album...")
    count = get_photo_count("To Post")
    if count >= 0:
        print(f"   ✓ Found {count} photos in 'To Post' album")
    else:
        print("   ✗ Could not get photo count")
        return

    if count == 0:
        print("\n   Note: Add some photos to 'To Post' album to test export")
        print("   Skipping export test")
        return

    # 4. List photos
    print("\n4. Listing photos in 'To Post' album...")
    photos = get_photos_from_album("To Post")
    if photos:
        print(f"   ✓ Found {len(photos)} photos:")
        for i, photo in enumerate(photos[:5]):  # Show first 5
            print(f"      {i+1}. {photo.filename} ({photo.width}x{photo.height})")
        if len(photos) > 5:
            print(f"      ... and {len(photos) - 5} more")
    else:
        print("   ✗ No photos found or error occurred")

    # 5. Test export (if photos available)
    if photos:
        print("\n5. Testing photo export...")
        temp_dir = get_temp_export_dir()
        print(f"   Export directory: {temp_dir}")

        exported = export_photo_by_index("To Post", 0, temp_dir)
        if exported:
            print(f"   ✓ Exported to: {exported}")
            file_size = Path(exported).stat().st_size
            print(f"   File size: {file_size / 1024:.1f} KB")
        else:
            print("   ✗ Export failed")

        # Clean up
        clear_temp_exports()

    print("\n" + "=" * 60)
    print("Test complete!")
    print("=" * 60)


if __name__ == "__main__":
    import sys

    if "--test" in sys.argv:
        test_module()
    else:
        print("Usage: python photo_export.py --test")
        print("       Tests the photo export module")
