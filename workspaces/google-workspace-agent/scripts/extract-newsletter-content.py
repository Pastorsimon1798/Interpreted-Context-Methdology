#!/usr/bin/env python3
import json
import sys
import base64
import re
import html

def extract_text_from_html(html_content):
    """Strip HTML tags and decode entities"""
    # Remove script and style blocks
    text = re.sub(r'<script[^>]*>.*?</script>', '', html_content, flags=re.DOTALL | re.IGNORECASE)
    text = re.sub(r'<style[^>]*>.*?</style>', '', text, flags=re.DOTALL | re.IGNORECASE)
    # Remove tags
    text = re.sub(r'<[^>]+>', '\n', text)
    # Decode HTML entities
    text = html.unescape(text)
    # Clean whitespace
    text = re.sub(r'\n\s*\n+', '\n\n', text)
    text = re.sub(r' +', ' ', text)
    return text.strip()

def get_email_body(payload):
    """Recursively extract body text from email payload"""
    body = ""
    
    # Check direct body
    if payload.get('body', {}).get('data'):
        try:
            decoded = base64.urlsafe_b64decode(payload['body']['data'] + '===').decode('utf-8', errors='ignore')
            if payload.get('mimeType') == 'text/plain':
                return decoded
            elif payload.get('mimeType') == 'text/html':
                return extract_text_from_html(decoded)
        except Exception as e:
            pass
    
    # Check multipart
    if payload.get('parts'):
        # Prefer text/plain over text/html
        for part in payload['parts']:
            if part.get('mimeType') == 'text/plain' and part.get('body', {}).get('data'):
                try:
                    decoded = base64.urlsafe_b64decode(part['body']['data'] + '===').decode('utf-8', errors='ignore')
                    body = decoded
                    break
                except:
                    pass
        
        # Fall back to HTML if no plain text
        if not body:
            for part in payload['parts']:
                if part.get('mimeType') == 'text/html' and part.get('body', {}).get('data'):
                    try:
                        decoded = base64.urlsafe_b64decode(part['body']['data'] + '===').decode('utf-8', errors='ignore')
                        body = extract_text_from_html(decoded)
                        break
                    except:
                        pass
        
        # Recursively check nested parts
        if not body:
            for part in payload['parts']:
                if part.get('parts'):
                    body = get_email_body(part)
                    if body:
                        break
    
    return body

# Process file
email_id = sys.argv[1]
with open(f'output/newsletter-analysis/raw-{email_id}.json', 'r') as f:
    data = json.load(f)

headers = {h['name']: h['value'] for h in data['payload']['headers']}
body = get_email_body(data['payload'])

# Output formatted content
print(f"# {headers.get('Subject', 'No Subject')}")
print(f"**From:** {headers.get('From', 'Unknown')}")
print(f"**Date:** {headers.get('Date', 'Unknown')}")
print(f"**ID:** {email_id}")
print("\n---\n")
print(body[:25000])  # Limit to 25K chars
