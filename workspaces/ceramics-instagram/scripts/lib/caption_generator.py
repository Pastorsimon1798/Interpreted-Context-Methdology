"""
Caption generator module for Instagram posts.

Analyzes photos and generates captions in the user's voice using:
- Photo content analysis (piece type, colors, mood)
- Voice rules from brand-vault/voice-rules.md
- Hashtags from shared/hashtag-library.md
"""

import os
import base64
from pathlib import Path
from typing import Optional
from dataclasses import dataclass
from enum import Enum


class ContentType(Enum):
    """Type of ceramic content in the media."""
    FINISHED_PIECE = "finished"
    PROCESS = "process"
    KILN_REVEAL = "kiln_reveal"
    STUDIO = "studio"
    DETAIL = "detail"
    # Video-specific types
    PROCESS_VIDEO = "process_video"      # Throwing, trimming, glazing videos
    KILN_REVEAL_VIDEO = "kiln_reveal_video"  # Kiln opening videos
    STUDIO_TOUR = "studio_tour"          # Studio walkthrough
    TIME_LAPSE = "time_lapse"            # Time-lapse pottery making


@dataclass
class PhotoAnalysis:
    """Analysis of a photo's content."""
    content_type: ContentType
    piece_type: str  # vase, bowl, mug, planter, sculpture, etc.
    primary_colors: list[str]
    secondary_colors: list[str]
    glaze_type: Optional[str]
    technique: Optional[str]  # wheel-thrown, handbuilt, etc.
    mood: str  # warm, cool, earthy, modern, organic
    is_process: bool
    dimensions_visible: bool
    suggested_hook: str


@dataclass
class GeneratedCaption:
    """Generated caption with all components."""
    hook: str
    body: str
    cta: str
    hashtags: str
    full_caption: str


@dataclass
class VideoAnalysis:
    """Analysis of a video's content."""
    content_type: ContentType
    video_type: str  # process, reveal, tour, timelapse
    duration_seconds: float
    primary_colors: list[str]
    activity: str  # throwing, trimming, glazing, etc.
    mood: str
    has_audio: bool
    suggested_hook: str
    is_reel_suitable: bool  # True if < 90s and vertical/square
    aspect_ratio_category: str = "horizontal"
    duration_warning: Optional[str] = None


@dataclass
class CarouselAnalysis:
    """Analysis for carousel posts."""
    content_types: list[ContentType]  # One per item
    primary_theme: str
    narrative_flow: str  # How items connect
    hooks: list[str]
    cta: str


def is_video_file(filepath: str) -> bool:
    """Check if a file is a video based on extension."""
    video_extensions = {".mp4", ".mov", ".m4v", ".avi", ".mkv", ".wmv"}
    return Path(filepath).suffix.lower() in video_extensions


def get_workspace_root() -> Path:
    """Get the workspace root directory."""
    return Path(__file__).parent.parent.parent


def get_voice_rules_path() -> Path:
    """Get the voice rules file path."""
    return get_workspace_root() / "brand-vault" / "voice-rules.md"


def get_hashtag_library_path() -> Path:
    """Get the hashtag library file path."""
    return get_workspace_root() / "shared" / "hashtag-library.md"


def load_voice_rules() -> str:
    """Load the voice rules markdown file."""
    path = get_voice_rules_path()
    if path.exists():
        return path.read_text(encoding="utf-8")
    return ""


def load_hashtag_library() -> str:
    """Load the hashtag library markdown file."""
    path = get_hashtag_library_path()
    if path.exists():
        return path.read_text(encoding="utf-8")
    return ""


# Piece type keywords for detection
PIECE_KEYWORDS = {
    "vase": ["vase", "vessel", "tall", "slim"],
    "bowl": ["bowl", "round", "curved", "dish"],
    "mug": ["mug", "cup", "handle", "tumbler"],
    "planter": ["planter", "pot", "plant", "drainage"],
    "plate": ["plate", "platter", "dish", "flat"],
    "sculpture": ["sculpture", "sculptural", "abstract", "form"],
    "jar": ["jar", "container", "lidded", "canister"],
}

# Glaze type keywords
GLAZE_KEYWORDS = {
    "shino": ["shino", "carbon trap"],
    "celadon": ["celadon", "green", "blue-green"],
    "tenmoku": ["tenmoku", "dark", "brown", "black"],
    "crystalline": ["crystal", "crystalline", "zinc"],
    "matte": ["matte", "flat", "soft"],
    "glossy": ["glossy", "shiny", "bright"],
    "speckled": ["speckle", "speckled", "dots", "spots"],
    "rutile": ["rutile", "blue", "pools"],
}

# Technique keywords
TECHNIQUE_KEYWORDS = {
    "wheel-thrown": ["wheel", "thrown", "spinning", "turning"],
    "handbuilt": ["handbuilt", "slab", "coil", "pinch"],
    "slip-cast": ["slip", "cast", "mold"],
}


def analyze_photo_basic(photo_path: str) -> PhotoAnalysis:
    """
    Basic photo analysis without AI (uses filename and metadata).

    For full AI-powered analysis, use analyze_photo() which calls
    Claude API for image understanding.
    """
    filename = Path(photo_path).stem.lower()

    # Detect content type from filename
    is_process = any(kw in filename for kw in ["process", "wip", "making", "wheel", "throwing", "trimming"])
    is_kiln = any(kw in filename for kw in ["kiln", "reveal", "unload", "firing"])

    if is_kiln:
        content_type = ContentType.KILN_REVEAL
    elif is_process:
        content_type = ContentType.PROCESS
    else:
        content_type = ContentType.FINISHED_PIECE

    # Detect piece type from filename
    piece_type = "piece"
    for ptype, keywords in PIECE_KEYWORDS.items():
        if any(kw in filename for kw in keywords):
            piece_type = ptype
            break

    # Detect glaze from filename
    glaze_type = None
    for gtype, keywords in GLAZE_KEYWORDS.items():
        if any(kw in filename for kw in keywords):
            glaze_type = gtype
            break

    # Detect technique from filename
    technique = None
    for ttype, keywords in TECHNIQUE_KEYWORDS.items():
        if any(kw in filename for kw in keywords):
            technique = ttype
            break

    # Default colors based on common ceramics
    primary_colors = ["earth tones"]
    secondary_colors = []

    return PhotoAnalysis(
        content_type=content_type,
        piece_type=piece_type,
        primary_colors=primary_colors,
        secondary_colors=secondary_colors,
        glaze_type=glaze_type,
        technique=technique,
        mood="warm" if "warm" in filename else "modern",
        is_process=is_process,
        dimensions_visible=False,
        suggested_hook=f"Handmade ceramic {piece_type}"
    )


def analyze_photo(photo_path: str, use_ai: bool = True) -> PhotoAnalysis:
    """
    Analyze a photo to understand its content.

    Uses AI for rich analysis, falls back to basic filename analysis.

    Args:
        photo_path: Path to the photo file
        use_ai: Whether to use AI for analysis (default True)

    Returns:
        PhotoAnalysis object with detected content
    """
    if not use_ai:
        return analyze_photo_basic(photo_path)

    # Try to use AI analysis
    try:
        return analyze_photo_with_ai(photo_path)
    except Exception as e:
        print(f"AI analysis failed, using basic: {e}")
        return analyze_photo_basic(photo_path)


def analyze_video_basic(video_path: str, duration: float = 0.0, width: int = 0, height: int = 0) -> VideoAnalysis:
    """
    Basic video analysis without AI (uses filename and metadata).

    Args:
        video_path: Path to the video file
        duration: Video duration in seconds (if known)
        width: Video width (if known)
        height: Video height (if known)

    Returns:
        VideoAnalysis object with detected content
    """
    filename = Path(video_path).stem.lower()

    # Detect video type from filename
    is_throwing = any(kw in filename for kw in ["throw", "wheel", "spinning"])
    is_trimming = any(kw in filename for kw in ["trim", "trimming"])
    is_glazing = any(kw in filename for kw in ["glaze", "glazing", "dip"])
    is_kiln = any(kw in filename for kw in ["kiln", "reveal", "unload", "opening"])
    is_tour = any(kw in filename for kw in ["tour", "studio", "walkthrough", "space"])
    is_timelapse = any(kw in filename for kw in ["timelapse", "time-lapse", "time lapse"])

    # Determine activity and content type
    if is_kiln:
        video_type = "reveal"
        activity = "kiln reveal"
        content_type = ContentType.KILN_REVEAL_VIDEO
    elif is_tour:
        video_type = "tour"
        activity = "studio tour"
        content_type = ContentType.STUDIO_TOUR
    elif is_timelapse:
        video_type = "timelapse"
        activity = "pottery making"
        content_type = ContentType.TIME_LAPSE
    elif is_throwing:
        video_type = "process"
        activity = "wheel throwing"
        content_type = ContentType.PROCESS_VIDEO
    elif is_trimming:
        video_type = "process"
        activity = "trimming"
        content_type = ContentType.PROCESS_VIDEO
    elif is_glazing:
        video_type = "process"
        activity = "glazing"
        content_type = ContentType.PROCESS_VIDEO
    else:
        video_type = "process"
        activity = "pottery process"
        content_type = ContentType.PROCESS_VIDEO

    # Calculate aspect ratio category
    aspect_ratio_category = "horizontal"
    if width > 0 and height > 0:
        if height > width:
            ratio = height / width
            if 1.7 <= ratio <= 1.9:
                aspect_ratio_category = "vertical_9_16"
            else:
                aspect_ratio_category = "vertical"
        elif abs(height - width) / max(height, width) < 0.1:
            aspect_ratio_category = "square"

    # Check if suitable for Reels (< 90 seconds, vertical or square)
    is_reel_suitable = 0 < duration <= 90 and aspect_ratio_category in ["vertical", "vertical_9_16", "square"]

    # Duration warning for videos that don't meet Reels criteria
    duration_warning = None
    if duration > 90:
        duration_warning = f"Video is {duration:.1f}s, exceeds 90s Reels limit"
    elif duration > 0 and aspect_ratio_category == "horizontal":
        duration_warning = f"Video is horizontal, not suitable for Reels"

    return VideoAnalysis(
        content_type=content_type,
        video_type=video_type,
        duration_seconds=duration,
        primary_colors=["earth tones"],
        activity=activity,
        mood="warm",
        has_audio=False,  # Unknown without processing
        suggested_hook=f"{activity.capitalize()} video",
        is_reel_suitable=is_reel_suitable,
        aspect_ratio_category=aspect_ratio_category,
        duration_warning=duration_warning
    )


def analyze_video(video_path: str, use_ai: bool = True, duration: float = 0.0, width: int = 0, height: int = 0) -> VideoAnalysis:
    """
    Analyze a video to understand its content.

    Uses AI for rich analysis, falls back to basic filename analysis.

    Args:
        video_path: Path to the video file
        use_ai: Whether to use AI for analysis (default True)
        duration: Video duration in seconds (if known)
        width: Video width (if known)
        height: Video height (if known)

    Returns:
        VideoAnalysis object with detected content
    """
    # For now, use basic analysis (AI video analysis requires frame extraction)
    # TODO: Add AI video analysis with frame extraction
    return analyze_video_basic(video_path, duration, width, height)


def analyze_carousel(media_paths: list[str], use_ai: bool = True) -> CarouselAnalysis:
    """
    Analyze multiple images for carousel caption.

    Args:
        media_paths: List of paths to media files
        use_ai: Whether to use AI for analysis (default True)

    Returns:
        CarouselAnalysis object with narrative flow and unified caption info
    """
    # Analyze each item
    analyses = []
    for path in media_paths:
        if is_video_file(path):
            analyses.append(analyze_video(path, use_ai=use_ai))
        else:
            analyses.append(analyze_photo(path, use_ai=use_ai))

    # Determine primary theme
    piece_types = set()
    content_types = []
    for a in analyses:
        if hasattr(a, 'piece_type'):
            piece_types.add(a.piece_type)
        content_types.append(a.content_type)

    # Determine narrative flow
    if len(set(content_types)) == 1:
        narrative_flow = "collection"  # Same type of content
    elif ContentType.PROCESS in content_types and ContentType.FINISHED_PIECE in content_types:
        narrative_flow = "story"  # Process to result
    elif ContentType.DETAIL in content_types:
        narrative_flow = "details"  # Close-ups
    else:
        narrative_flow = "mixed"

    # Generate hooks for each item
    hooks = []
    for i, a in enumerate(analyses):
        if hasattr(a, 'suggested_hook'):
            hooks.append(f"Slide {i+1}: {a.suggested_hook}")
        else:
            hooks.append(f"Slide {i+1}")

    # Generate CTA based on flow
    cta_templates = {
        "collection": "Which one's your favorite? Let me know below!",
        "story": "From start to finish - the full journey of this piece.",
        "details": "Swipe to see all the details of this piece.",
        "mixed": "Swipe through to see more!",
    }
    cta = cta_templates.get(narrative_flow, "Swipe for more!")

    # Primary theme
    if piece_types:
        primary_theme = " and ".join(sorted(piece_types)[:2])
    else:
        primary_theme = "ceramic pieces"

    return CarouselAnalysis(
        content_types=content_types,
        primary_theme=primary_theme,
        narrative_flow=narrative_flow,
        hooks=hooks,
        cta=cta
    )


def analyze_photo_with_ai(photo_path: str) -> PhotoAnalysis:
    """
    Use AI to analyze photo content via OpenRouter.

    Requires OPENROUTER_API_KEY environment variable.
    Falls back to basic analysis if not available.
    """
    import os
    from openai import OpenAI

    # Check for API key
    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key:
        print("OPENROUTER_API_KEY not set, using basic analysis")
        return analyze_photo_basic(photo_path)

    # Read and encode image
    with open(photo_path, "rb") as f:
        image_data = f.read()

    # Determine media type
    ext = Path(photo_path).suffix.lower()
    media_type = "image/jpeg"
    if ext == ".png":
        media_type = "image/png"
    elif ext == ".heic":
        media_type = "image/heic"

    base64_image = base64.standard_b64encode(image_data).decode("utf-8")

    # Use OpenRouter with OpenAI SDK
    client = OpenAI(
        api_key=api_key,
        base_url="https://openrouter.ai/api/v1"
    )

    prompt = """Analyze this ceramic pottery photo and provide a structured analysis.

Respond with ONLY a JSON object with these fields:
- piece_type: One of (vase, bowl, mug, planter, plate, sculpture, jar, or "piece" if unclear)
- content_type: One of (finished, process, kiln_reveal, studio, detail)
- primary_colors: Array of 1-2 main colors (e.g., ["orange", "grey"])
- secondary_colors: Array of accent colors
- glaze_type: The glaze name or style if identifiable (e.g., "shino", "celadon", "matte", or null)
- technique: One of (wheel-thrown, handbuilt, slip-cast, or null)
- mood: One of (warm, cool, earthy, modern, organic)
- dimensions_visible: Boolean - can you estimate size?
- brief_description: 5-10 word description for the hook

Example response:
{"piece_type": "vase", "content_type": "finished", "primary_colors": ["orange", "grey"], "secondary_colors": ["brown"], "glaze_type": "shino", "technique": "wheel-thrown", "mood": "earthy", "dimensions_visible": true, "brief_description": "Carbon trap shino vase with orange and grey tones"}"""

    # Use GPT-4o via OpenRouter (good vision capabilities)
    response = client.chat.completions.create(
        model="openai/gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:{media_type};base64,{base64_image}"
                        }
                    },
                    {
                        "type": "text",
                        "text": prompt
                    }
                ]
            }
        ],
        max_tokens=500
    )

    # Parse response
    import json
    response_text = response.choices[0].message.content

    # Extract JSON from response
    try:
        # Try direct parse
        result = json.loads(response_text)
    except json.JSONDecodeError:
        # Try to extract JSON from response
        import re
        json_match = re.search(r'\{[^}]+\}', response_text, re.DOTALL)
        if json_match:
            result = json.loads(json_match.group())
        else:
            raise ValueError("Could not parse AI response as JSON")

    return PhotoAnalysis(
        content_type=ContentType(result.get("content_type", "finished")),
        piece_type=result.get("piece_type", "piece"),
        primary_colors=result.get("primary_colors", ["earth tones"]),
        secondary_colors=result.get("secondary_colors", []),
        glaze_type=result.get("glaze_type"),
        technique=result.get("technique"),
        mood=result.get("mood", "warm"),
        is_process=result.get("content_type") in ["process", "kiln_reveal"],
        dimensions_visible=result.get("dimensions_visible", False),
        suggested_hook=result.get("brief_description", "Handmade ceramic piece")
    )


def generate_hook(analysis: PhotoAnalysis) -> str:
    """Generate the first line hook based on analysis."""
    parts = []

    # Add technique if known
    if analysis.technique:
        parts.append(analysis.technique.replace("-", " "))

    # Add piece type
    parts.append(analysis.piece_type)

    # Add glaze if known
    if analysis.glaze_type:
        parts.append(f"with {analysis.glaze_type} glaze")

    # Add color if distinctive
    if analysis.primary_colors and analysis.primary_colors[0] != "earth tones":
        parts.append(f"in {analysis.primary_colors[0]} tones")

    hook = " ".join(parts)
    return hook.capitalize()


def generate_body(analysis: PhotoAnalysis) -> str:
    """Generate the caption body based on content type."""
    templates = {
        ContentType.FINISHED_PIECE: [
            "This piece came out of the kiln with such beautiful {colors}. {glaze_note}",
            "Love how the {glaze} glaze interacts with the clay on this {piece}.",
            "The {colors} on this {piece} are exactly what I was hoping for.",
        ],
        ContentType.PROCESS: [
            "Working on some new {piece}s at the studio today. {technique_note}",
            "Here's a peek at the process behind these {piece}s.",
            "Always love the feeling of clay in my hands, especially when making {piece}s.",
        ],
        ContentType.KILN_REVEAL: [
            "Kiln reveal day! These {piece}s came out even better than expected.",
            "The moment of truth - opening the kiln to see these {piece}s.",
            "Nothing beats the surprise of a kiln opening. {glaze_note}",
        ],
        ContentType.STUDIO: [
            "A day at Clay on First studio. Working on some new pieces.",
            "Studio vibes today - surrounded by clay and creativity.",
            "Behind the scenes at my Long Beach pottery studio.",
        ],
        ContentType.DETAIL: [
            "A closer look at the {glaze} on this {piece}.",
            "The details on this {piece} make it special.",
            "Zooming in on the texture of this {piece}.",
        ],
        # Video-specific templates
        ContentType.PROCESS_VIDEO: [
            "Watch me {activity} in today's studio session. There's something so meditative about the process.",
            "A glimpse into my {activity} process. Each piece tells a story from start to finish.",
            "POV: You're watching me {activity}. The best part is seeing the form come to life.",
        ],
        ContentType.KILN_REVEAL_VIDEO: [
            "The moment you've been waiting for - kiln reveal! The anticipation never gets old.",
            "Watch me open the kiln and see how these pieces turned out. Spoiler: I'm obsessed!",
            "Kiln reveal day is always full of surprises. Watch until the end to see my favorite piece!",
        ],
        ContentType.STUDIO_TOUR: [
            "Come take a tour of my pottery studio in Long Beach. This is where the magic happens!",
            "A look around my creative space. Every corner has a story.",
            "Welcome to my studio! This is where I spend most of my days making ceramics.",
        ],
        ContentType.TIME_LAPSE: [
            "Hours of work condensed into seconds. Watch this {activity} from start to finish!",
            "From lump of clay to finished form in under a minute. The process is so satisfying.",
            "Time-lapse of my latest pottery session. Can you spot the transformation?",
        ],
    }

    # Get template for content type
    options = templates.get(analysis.content_type, templates[ContentType.FINISHED_PIECE])

    # Pick first option (could randomize later)
    template = options[0]

    # Build replacements
    colors = " and ".join(analysis.primary_colors[:2]) if analysis.primary_colors else "colors"
    glaze_note = f"The {analysis.glaze_type} glaze creates such unique patterns." if analysis.glaze_type else "The glaze created some beautiful surprises."
    technique_note = f"Using {analysis.technique} technique." if analysis.technique else "Handmade with care."

    # Handle VideoAnalysis
    activity = getattr(analysis, 'activity', 'pottery making') if hasattr(analysis, 'activity') else 'pottery making'

    body = template.format(
        piece=getattr(analysis, 'piece_type', 'piece'),
        colors=colors,
        glaze=getattr(analysis, 'glaze_type', None) or "glaze",
        glaze_note=glaze_note,
        technique_note=technique_note,
        activity=activity,
    )

    return body


def generate_cta(analysis: PhotoAnalysis) -> str:
    """Generate a call-to-action based on content type."""
    cta_options = {
        ContentType.FINISHED_PIECE: [
            "DM for pricing and shipping details",
            "Available at Clay on First Long Beach or DM to purchase",
            "Send me a message if you'd like to bring this home",
        ],
        ContentType.PROCESS: [
            "What type of ceramics content do you enjoy seeing most?",
            "Drop a comment if you love behind-the-scenes content",
            "Save this for inspiration",
        ],
        ContentType.KILN_REVEAL: [
            "What's your favorite part of the pottery process?",
            "Do you love kiln reveal surprises as much as I do?",
            "Save this if you're a pottery lover",
        ],
        ContentType.STUDIO: [
            "Do you have a creative space that inspires you?",
            "Tag a friend who would love this studio",
            "Where do you create?",
        ],
        ContentType.DETAIL: [
            "Do you prefer matte or glossy finishes?",
            "What draws you to a piece - the form or the glaze?",
            "Save this for glaze inspiration",
        ],
        # Video-specific CTAs
        ContentType.PROCESS_VIDEO: [
            "Save this for when you need pottery ASMR",
            "What's your favorite part of the pottery process?",
            "Drop a 🎨 if you love watching pottery being made",
        ],
        ContentType.KILN_REVEAL_VIDEO: [
            "What was your favorite piece from this kiln load?",
            "Do you love kiln reveal videos as much as I do?",
            "Watch until the end to see my favorite piece!",
        ],
        ContentType.STUDIO_TOUR: [
            "Do you have a creative space? Tell me about it!",
            "Tag someone who would love this studio setup",
            "What would you add to your dream pottery studio?",
        ],
        ContentType.TIME_LAPSE: [
            "Save this for satisfying pottery content",
            "What should I make next? Drop your ideas below!",
            "From clay to form in seconds. What do you think?",
        ],
    }

    options = cta_options.get(analysis.content_type, cta_options[ContentType.FINISHED_PIECE])
    return options[0]


def select_hashtags(analysis: PhotoAnalysis, hashtag_library: str = None, is_reel: bool = False, is_carousel: bool = False) -> str:
    """
    Select appropriate hashtags based on content type.

    Uses the 5+3+3 formula:
    - 5 Core Tags (always use)
    - 3 Topic Tags (based on content)
    - 3 Local/Discovery Tags

    Args:
        analysis: PhotoAnalysis or VideoAnalysis object
        hashtag_library: Optional hashtag library content
        is_reel: Whether this is a Reel (adds Reels-specific tags)
        is_carousel: Whether this is a carousel (adds carousel tags)

    Returns:
        String of hashtags
    """
    # Core 5 (always include)
    core_tags = ["#instaart", "#handbuilding", "#clay", "#handmade", "#behindthescenes"]

    # Topic tags based on content type
    topic_sets = {
        ContentType.FINISHED_PIECE: ["#ceramicvase", "#ceramicart", "#modernceramics"],
        ContentType.PROCESS: ["#potterylife", "#wheelthrown", "#howitsmade"],
        ContentType.KILN_REVEAL: ["#stonewarepottery", "#potterylife", "#glaze"],
        ContentType.STUDIO: ["#ceramicstudio", "#potterylife", "#longbeachartist"],
        ContentType.DETAIL: ["#ceramicvase", "#modernceramics", "#design"],
        # Video-specific hashtags
        ContentType.PROCESS_VIDEO: ["#potteryvideo", "#wheelthrown", "#satisfying"],
        ContentType.KILN_REVEAL_VIDEO: ["#kilnreveal", "#potteryvideo", "#satisfying"],
        ContentType.STUDIO_TOUR: ["#studiovibes", "#potterystudio", "#artistlife"],
        ContentType.TIME_LAPSE: ["#potterytimelapse", "#satisfyingvideo", "#asmr"],
    }

    # Adjust based on technique
    if hasattr(analysis, 'technique') and analysis.technique == "wheel-thrown":
        topic_sets[ContentType.FINISHED_PIECE] = ["#wheelthrown", "#ceramicart", "#modernceramics"]

    topic_tags = topic_sets.get(analysis.content_type, topic_sets[ContentType.FINISHED_PIECE])

    # Local/Discovery tags
    if is_reel:
        # Reels-specific discovery tags
        local_tags = ["#potteryreels", "#satisfying", "#asmrpottery"]
    elif is_carousel:
        # Carousel-specific tags
        local_tags = ["#potterycarousel", "#longbeachartist", "#socalartist"]
    elif analysis.content_type in [ContentType.PROCESS_VIDEO, ContentType.KILN_REVEAL_VIDEO,
                                  ContentType.STUDIO_TOUR, ContentType.TIME_LAPSE]:
        local_tags = ["#longbeachartist", "#socalartist", "#potteryreels"]
    else:
        local_tags = ["#longbeachartist", "#socalartist", "#reels"]

    # Combine all
    all_tags = core_tags + topic_tags + local_tags

    return " ".join(all_tags)


def generate_caption_for_carousel(
    analysis: CarouselAnalysis,
    voice_rules: str = None,
    include_cta: bool = True
) -> GeneratedCaption:
    """
    Generate a complete caption for a carousel post.

    Args:
        analysis: CarouselAnalysis object
        voice_rules: Optional voice rules content
        include_cta: Whether to include call-to-action

    Returns:
        GeneratedCaption with all components
    """
    # Carousel hooks based on narrative flow
    hook_templates = {
        "collection": f"Fresh from the kiln! {analysis.primary_theme.capitalize()} - swipe to see them all",
        "story": f"From lump of clay to finished {analysis.primary_theme} - the full journey",
        "details": f"The little details make this {analysis.primary_theme} special",
        "mixed": f"{analysis.primary_theme.capitalize()} - {len(analysis.content_types)} slides of pottery goodness",
    }

    hook = hook_templates.get(analysis.narrative_flow, f"Swipe to see more {analysis.primary_theme}")

    # Body based on narrative flow
    body_templates = {
        "collection": "Each piece has its own personality. Which one speaks to you?",
        "story": "Every piece tells a story from start to finish. This is the journey of creation.",
        "details": "Sometimes you need to zoom in to really appreciate the glaze and texture.",
        "mixed": "A mix of process and finished pieces from the studio.",
    }

    body = body_templates.get(analysis.narrative_flow, "Swipe through for more!")

    # CTA
    cta = analysis.cta if include_cta else ""

    # Hashtags for carousel
    hashtags = select_hashtags(
        PhotoAnalysis(
            content_type=ContentType.FINISHED_PIECE,
            piece_type=analysis.primary_theme,
            primary_colors=["earth tones"],
            secondary_colors=[],
            glaze_type=None,
            technique=None,
            mood="warm",
            is_process=False,
            dimensions_visible=False,
            suggested_hook=hook
        ),
        is_carousel=True
    )

    # Assemble
    parts = [hook, "", body]
    if cta:
        parts.extend(["", cta])
    parts.extend(["", ".", hashtags])

    full_caption = "\n".join(parts)

    return GeneratedCaption(
        hook=hook,
        body=body,
        cta=cta,
        hashtags=hashtags,
        full_caption=full_caption
    )


def generate_caption(
    analysis: PhotoAnalysis,
    voice_rules: str = None,
    include_cta: bool = True,
    is_reel: bool = False
) -> GeneratedCaption:
    """
    Generate a complete caption from photo/video analysis.

    Args:
        analysis: PhotoAnalysis or VideoAnalysis object
        voice_rules: Optional voice rules content (loaded from file if not provided)
        include_cta: Whether to include call-to-action
        is_reel: Whether this is a Reel (shorter, punchier style)

    Returns:
        GeneratedCaption with all components
    """
    # Check if it's a video analysis
    is_video = isinstance(analysis, VideoAnalysis)

    if is_video:
        return generate_caption_for_video(analysis, voice_rules, include_cta, is_reel)

    # Generate components for photo
    hook = generate_hook(analysis)
    body = generate_body(analysis)
    cta = generate_cta(analysis) if include_cta else ""
    hashtags = select_hashtags(analysis)

    # Assemble full caption
    parts = [hook]

    if body:
        parts.append("")
        parts.append(body)

    if cta:
        parts.append("")
        parts.append(cta)

    # Hashtags at the end with separator
    parts.append("")
    parts.append(".")
    parts.append(hashtags)

    full_caption = "\n".join(parts)

    return GeneratedCaption(
        hook=hook,
        body=body,
        cta=cta,
        hashtags=hashtags,
        full_caption=full_caption
    )


def generate_caption_for_video(
    analysis: VideoAnalysis,
    voice_rules: str = None,
    include_cta: bool = True,
    is_reel: bool = False
) -> GeneratedCaption:
    """
    Generate a complete caption from video analysis.

    Args:
        analysis: VideoAnalysis object
        voice_rules: Optional voice rules content
        include_cta: Whether to include call-to-action
        is_reel: Whether this is a Reel (shorter, punchier style)

    Returns:
        GeneratedCaption with all components
    """
    # Reels get shorter, punchier hooks
    if is_reel or analysis.is_reel_suitable:
        reel_hooks = [
            f"Wait for it... {analysis.activity}",
            f"POV: {analysis.activity}",
            f"{analysis.activity.capitalize()} in real time",
            f"The most satisfying part of pottery",
            f"Pottery ASMR: {analysis.activity}",
        ]
        hook = reel_hooks[0]  # Could randomize later
    else:
        hook = f"{analysis.activity.capitalize()} - {analysis.suggested_hook}"

    # Generate body using shared function
    body = generate_body(analysis)

    # Generate CTA (Reels get different CTAs)
    if is_reel or analysis.is_reel_suitable:
        reel_ctas = [
            "Save this for later",
            "Drop a 🎨 if this was satisfying",
            "Follow for more pottery content",
            "What should I make next?",
        ]
        cta = reel_ctas[0] if include_cta else ""
    else:
        cta = generate_cta(analysis) if include_cta else ""

    # Select hashtags (Reels get Reels-specific tags)
    hashtags = select_hashtags(analysis, is_reel=(is_reel or analysis.is_reel_suitable))

    # Assemble full caption
    parts = [hook]

    # Add duration note for longer videos
    if analysis.duration_seconds > 60:
        mins = int(analysis.duration_seconds // 60)
        secs = int(analysis.duration_seconds % 60)
        parts.append(f"({mins}:{secs:02d})")

    if body:
        parts.append("")
        parts.append(body)

    if cta:
        parts.append("")
        parts.append(cta)

    # Hashtags at the end with separator
    parts.append("")
    parts.append(".")
    parts.append(hashtags)

    full_caption = "\n".join(parts)

    return GeneratedCaption(
        hook=hook,
        body=body,
        cta=cta,
        hashtags=hashtags,
        full_caption=full_caption
    )


def caption_length_ok(caption: str) -> bool:
    """Check if caption length is in optimal range (300-500 chars)."""
    length = len(caption)
    return 300 <= length <= 800  # Allow up to 800 for hashtags


def test_module(photo_path: str = None):
    """Test the caption generator module."""
    print("=" * 60)
    print("Caption Generator Module Test")
    print("=" * 60)

    # 1. Test basic analysis
    print("\n1. Testing basic photo analysis...")
    if photo_path and Path(photo_path).exists():
        analysis = analyze_photo(photo_path, use_ai=False)
        print(f"   Piece type: {analysis.piece_type}")
        print(f"   Content type: {analysis.content_type.value}")
        print(f"   Technique: {analysis.technique or 'not detected'}")
        print(f"   Glaze: {analysis.glaze_type or 'not detected'}")
    else:
        # Use mock analysis
        analysis = PhotoAnalysis(
            content_type=ContentType.FINISHED_PIECE,
            piece_type="vase",
            primary_colors=["orange", "grey"],
            secondary_colors=["brown"],
            glaze_type="shino",
            technique="wheel-thrown",
            mood="earthy",
            is_process=False,
            dimensions_visible=True,
            suggested_hook="Carbon trap shino vase"
        )
        print("   Using mock analysis (no photo provided)")
        print(f"   Piece type: {analysis.piece_type}")
        print(f"   Glaze: {analysis.glaze_type}")

    # 2. Test caption generation
    print("\n2. Testing caption generation...")
    caption = generate_caption(analysis)

    print(f"\n   Hook: {caption.hook}")
    print(f"\n   Body: {caption.body}")
    print(f"\n   CTA: {caption.cta}")
    print(f"\n   Hashtags: {caption.hashtags[:50]}...")

    print("\n3. Full caption:")
    print("-" * 40)
    print(caption.full_caption)
    print("-" * 40)

    print(f"\n   Caption length: {len(caption.full_caption)} chars")
    print(f"   Length OK: {'✓' if caption_length_ok(caption.full_caption) else '✗'}")

    # 4. Test with AI if photo provided
    if photo_path and Path(photo_path).exists():
        print("\n4. Testing AI-powered analysis...")
        try:
            ai_analysis = analyze_photo(photo_path, use_ai=True)
            print(f"   AI detected piece type: {ai_analysis.piece_type}")
            print(f"   AI detected glaze: {ai_analysis.glaze_type or 'none'}")
            print(f"   AI detected technique: {ai_analysis.technique or 'none'}")
        except Exception as e:
            print(f"   AI analysis skipped: {e}")

    print("\n" + "=" * 60)
    print("Test complete!")
    print("=" * 60)


if __name__ == "__main__":
    import sys

    photo_path = None

    if "--test" in sys.argv:
        # Check for --photo argument
        try:
            photo_idx = sys.argv.index("--photo")
            if photo_idx + 1 < len(sys.argv):
                photo_path = sys.argv[photo_idx + 1]
        except ValueError:
            pass

        test_module(photo_path)
    else:
        print("Usage: python caption_generator.py --test [--photo /path/to/photo.jpg]")
        print("       Tests the caption generator module")
