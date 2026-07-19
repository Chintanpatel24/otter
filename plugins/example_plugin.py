# Example Plugin for Otter Engine
# Register python script as a model handler or preprocessing extension

VERSION = "1.0.0"
DESCRIPTION = "Example preprocessing extension for custom text sanitization"

def pre_process(text):
    """Clean or sanitize prompt input before sending to model."""
    return text.strip()

def post_process(text):
    """Adjust or format completion output before returning."""
    return text.strip()
