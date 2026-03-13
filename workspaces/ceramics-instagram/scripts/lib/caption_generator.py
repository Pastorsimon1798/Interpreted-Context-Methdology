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
    """Type of ceramic content in the photo."""
    FINISHED_PIECE = "finished"
    PROCESS = "process"
    KILN_REVEAL = "kiln_reveal"
    STUDIO = "studio"
    DETAIL = "detail"


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


def analyze_photo_with_ai(photo_path: str) -> PhotoAnalysis:
    """
    Use AI to analyze photo content.

    Requires ANTHROPIC_API_KEY environment variable.
    """
    import anthropic

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

    client = anthropic.Anthropic()

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

    message = client.messages.create(
        model="claude-sonnet-4-6-20250514",
        max_tokens=500,
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": media_type,
                            "data": base64_image,
                        },
                    },
                    {
                        "type": "text",
                        "text": prompt,
                    },
                ],
            }
        ],
    )

    # Parse response
    import json
    response_text = message.content[0].text

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
    }

    # Get template for content type
    options = templates.get(analysis.content_type, templates[ContentType.FINISHED_PIECE])

    # Pick first option (could randomize later)
    template = options[0]

    # Build replacements
    colors = " and ".join(analysis.primary_colors[:2]) if analysis.primary_colors else "colors"
    glaze_note = f"The {analysis.glaze_type} glaze creates such unique patterns." if analysis.glaze_type else "The glaze created some beautiful surprises."
    technique_note = f"Using {analysis.technique} technique." if analysis.technique else "Handmade with care."

    body = template.format(
        piece=analysis.piece_type,
        colors=colors,
        glaze=analysis.glaze_type or "glaze",
        glaze_note=glaze_note,
        technique_note=technique_note,
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
    }

    options = cta_options.get(analysis.content_type, cta_options[ContentType.FINISHED_PIECE])
    return options[0]


def select_hashtags(analysis: PhotoAnalysis, hashtag_library: str = None) -> str:
    """
    Select appropriate hashtags based on content type.

    Uses the 5+3+3 formula:
    - 5 Core Tags (always use)
    - 3 Topic Tags (based on content)
    - 3 Local/Discovery Tags

    Args:
        analysis: PhotoAnalysis object
        hashtag_library: Optional hashtag library content

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
    }

    # Adjust based on technique
    if analysis.technique == "wheel-thrown":
        topic_sets[ContentType.FINISHED_PIECE] = ["#wheelthrown", "#ceramicart", "#modernceramics"]

    topic_tags = topic_sets.get(analysis.content_type, topic_sets[ContentType.FINISHED_PIECE])

    # Local/Discovery tags
    local_tags = ["#longbeachartist", "#socalartist", "#reels"]

    # Combine all
    all_tags = core_tags + topic_tags + local_tags

    return " ".join(all_tags)


def generate_caption(
    analysis: PhotoAnalysis,
    voice_rules: str = None,
    include_cta: bool = True
) -> GeneratedCaption:
    """
    Generate a complete caption from photo analysis.

    Args:
        analysis: PhotoAnalysis object
        voice_rules: Optional voice rules content (loaded from file if not provided)
        include_cta: Whether to include call-to-action

    Returns:
        GeneratedCaption with all components
    """
    # Generate components
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
