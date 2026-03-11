# Google Workspace CLI Setup Guide

This guide walks you through installing and configuring the `@googleworkspace/cli` to enable the Google Workspace Agent to interact with Gmail, Calendar, and Drive.

---

## 1. Prerequisites

Before starting, ensure you have:

- **Node.js 18+** installed
  ```bash
  node --version  # Should show v18.x.x or higher
  ```
  If not installed, download from [nodejs.org](https://nodejs.org/) or use nvm:
  ```bash
  nvm install 18
  nvm use 18
  ```

- **A Google Cloud account** with billing enabled (free tier works for development)
  - Sign up at [console.cloud.google.com](https://console.cloud.google.com/)

- **A Google Workspace or personal Gmail account** to connect

---

## 2. Install the gws CLI

Install the Google Workspace CLI globally:

```bash
npm install -g @googleworkspace/cli
```

Verify installation:

```bash
gws --version
```

---

## 3. Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **"Select a project"** > **"New Project"**
3. Name it (e.g., `gws-agent`) and click **"Create"**
4. Select your new project from the dropdown

---

## 4. Enable Required APIs

In your Google Cloud project:

1. Navigate to **"APIs & Services"** > **"Library"**
2. Search for and enable each of these APIs:
   - **Gmail API**
   - **Google Calendar API**
   - **Google Drive API**
   - **Google Docs API** (optional, for document creation)
   - **Google Tasks API** (optional)

You can also enable via command line:

```bash
gcloud services enable gmail.googleapis.com calendar-json.googleapis.com drive.googleapis.com
```

---

## 5. Configure OAuth Consent Screen

1. Go to **"APIs & Services"** > **"OAuth consent screen"**
2. Choose **"External"** user type (unless you have a Google Workspace org)
3. Click **"Create"**
4. Fill in required fields:
   - **App name**: `GWS Agent` (or your preferred name)
   - **User support email**: your email
   - **Developer contact email**: your email
5. Click **"Save and Continue"**
6. On **Scopes**, click **"Add or Remove Scopes"** and add:
   - `https://www.googleapis.com/auth/gmail.readonly`
   - `https://www.googleapis.com/auth/gmail.send`
   - `https://www.googleapis.com/auth/gmail.modify`
   - `https://www.googleapis.com/auth/calendar`
   - `https://www.googleapis.com/auth/calendar.events`
   - `https://www.googleapis.com/auth/drive.readonly`
   - `https://www.googleapis.com/auth/drive.file`
7. Click **"Save and Continue"**
8. Add yourself as a **test user** if in testing mode
9. Click **"Save and Continue"** to finish

---

## 6. Create OAuth Credentials

1. Go to **"APIs & Services"** > **"Credentials"**
2. Click **"Create Credentials"** > **"OAuth client ID"**
3. Application type: **"Desktop app"**
4. Name: `GWS Agent CLI`
5. Click **"Create"**
6. **Download the JSON** file (keep it secure!)
7. Save it as `~/.config/gws/credentials.json`:

```bash
mkdir -p ~/.config/gws
mv ~/Downloads/client_secret_*.json ~/.config/gws/credentials.json
```

---

## 7. Authenticate the CLI

Run the initial setup:

```bash
gws auth setup
```

Then log in with your Google account:

```bash
gws auth login
```

This will:
1. Open a browser window
2. Ask you to sign in to Google
3. Request permission for the scopes you configured
4. Save tokens locally for future use

---

## 8. Verify Installation

Test that everything works:

**Gmail:**
```bash
gws gmail list --max-results 5
```

**Calendar:**
```bash
gws calendar list
gws calendar events list --calendar primary --max-results 10
```

**Drive:**
```bash
gws drive list --max-results 10
```

If these commands return data, you're ready to use the agent.

---

## 9. Install Skills Bundle (Optional)

The gws CLI includes pre-built skills for common workflows:

```bash
npx skills add https://github.com/googleworkspace/cli
```

This adds skills for:
- Email summarization
- Meeting scheduling
- File organization
- Task management

---

## 10. Troubleshooting

### "Access blocked: This app's request is invalid"

**Cause:** Your app is in testing mode and you're not added as a test user.

**Fix:**
1. Go to OAuth consent screen > Test users
2. Add your email address
3. Wait a few minutes and try again

### "API not enabled" error

**Cause:** Required APIs aren't enabled.

**Fix:**
```bash
gcloud services enable gmail.googleapis.com calendar-json.googleapis.com drive.googleapis.com
```

### "Insufficient Permission" or "Request had insufficient authentication scopes"

**Cause:** OAuth token was created before scopes were added.

**Fix:** Revoke and re-authenticate:
```bash
gws auth logout
gws auth login
```

### Rate limiting errors

**Cause:** Too many API calls in short time.

**Fix:** The agent implements exponential backoff. For development, reduce request frequency.

### "Token has been expired or revoked"

**Cause:** Access token expired or manually revoked.

**Fix:** Re-authenticate:
```bash
gws auth login
```

### Credentials file not found

**Cause:** `credentials.json` is in wrong location.

**Fix:**
```bash
mkdir -p ~/.config/gws
# Move your downloaded credentials file:
mv ~/Downloads/client_secret_*.json ~/.config/gws/credentials.json
```

---

## Security Notes

- **Never commit** `credentials.json` or token files to version control
- Add `~/.config/gws/` to your `.gitignore`
- Consider using a dedicated Google account for agent testing
- Review OAuth permissions periodically at [myaccount.google.com/permissions](https://myaccount.google.com/permissions)

---

## Next Steps

After setup is complete, return to the workspace and run `setup` to configure your agent preferences.
