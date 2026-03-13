#!/usr/bin/env python3
import json
import sys
import base64
import re

def extract_text_from_html(html):
    """Strip HTML tags for basic text extraction"""
    text = re.sub(r'<script[^>]*>.*?</script>', '', html, flags=re.DOTALL | re.IGNORECASE)
    text = re.sub(r'<style[^>]*>.*?</style>', '', text, flags=re.DOTALL | re.IGNORECASE)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    text = re.sub(r'&nbsp;', ' ', text)
    text = re.sub(r'&amp;', '&', text)
    text = re.sub(r'&lt;', '<', text)
    text = re.sub(r'&gt;', '>', text)
    return text.strip()

def get_email_body(payload):
    """Recursively extract body from payload"""
    body = ""

    if payload.get('body', {}).get('data'):
        try:
            decoded = base64.urlsafe_b64decode(payload['body']['data'] + '==').decode('utf-8', errors='ignore')
            if payload.get('mimeType') == 'text/plain':
                return decoded
            elif payload.get('mimeType') == 'text/html':
                return extract_text_from_html(decoded)
        except:
            pass

    if payload.get('parts'):
        for part in payload['parts']:
            body += get_email_body(part)

    return body

# Parse input
email_id = sys.argv[1] if len(sys.argv) > 1 else None

if email_id:
    # Read from file
    with open(f'output/newsletter-analysis/raw-{email_id}.json', 'r') as f:
        data = json.load(f)
else:
    # Read from stdin
    data = json.load(sys.stdin)

# Extract headers
headers = {h['name']: h['value'] for h in data['payload']['headers']}

# Extract body
body = get_email_body(data['payload'])

# Output
print(f"ID: {data['id']}")
print(f"Subject: {headers.get('Subject', 'N/A')}")
print(f"From: {headers.get('From', 'N/A')}")
print(f"Date: {headers.get('Date', 'N/A')}")
print("\n---BODY---\n")
print(body[:15000])  # Limit to first 15K chars
