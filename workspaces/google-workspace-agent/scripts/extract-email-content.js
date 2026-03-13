const fs = require('fs');

// Get email data from stdin
let data = '';
process.stdin.on('data', chunk => data += chunk);
process.stdin.on('end', () => {
  try {
    const email = JSON.parse(data);

    // Extract headers
    const headers = {};
    email.payload.headers.forEach(h => headers[h.name] = h.value);

    // Extract body - decode from base64 if needed
    let body = '';
    if (email.payload.body && email.payload.body.data) {
      body = Buffer.from(email.payload.body.data, 'base64').toString('utf-8');
    }

    // Handle multipart messages
    if (email.payload.parts) {
      function extractParts(parts) {
        parts.forEach(part => {
          if (part.mimeType === 'text/plain' && part.body && part.body.data) {
            body += Buffer.from(part.body.data, 'base64').toString('utf-8');
          } else if (part.mimeType === 'text/html' && !body && part.body && part.body.data) {
            body += Buffer.from(part.body.data, 'base64').toString('utf-8');
          } else if (part.parts) {
            extractParts(part.parts);
          }
        });
      }
      extractParts(email.payload.parts);
    }

    console.log('=== HEADERS ===');
    console.log(`Subject: ${headers.Subject || 'N/A'}`);
    console.log(`From: ${headers.From || 'N/A'}`);
    console.log(`Date: ${headers.Date || 'N/A'}`);
    console.log('\n=== BODY ===');
    console.log(body);
  } catch (e) {
    console.error('Error parsing email:', e.message);
  }
});
