# ⚠️ SECURITY INCIDENT - EXPOSED CREDENTIALS

## What Happened
Supabase credentials were accidentally committed to the public GitHub repository in the file `luni_app/lib/config/app_config.template.dart`.

## Exposed Information
- **Supabase URL:** `https://cpsjbwtezrnajaiolsim.supabase.co`
- **Supabase Anon Key:** JWT token (full key was exposed)
- **Exposure Duration:** From initial commit until this fix
- **Repository:** https://github.com/rorygeddes/Luni-Flutter

## Immediate Actions Taken ✅
1. Replaced exposed credentials with placeholders in template file
2. Committed fix to remove credentials from latest version
3. Created this incident response document

## URGENT Actions Required 🚨

### 1. Rotate Supabase Keys (DO THIS NOW)
1. Go to Supabase Dashboard: https://supabase.com/dashboard/project/cpsjbwtezrnajaiolsim/settings/api
2. Click "Reset anon key" or create a new project
3. Update your local `.env` file with new credentials
4. **DO NOT** put credentials in code files again

### 2. Clean Git History (Recommended)
The credentials are still in git history. You have two options:

#### Option A: Force Push with Cleaned History
```bash
# WARNING: This will rewrite git history
cd "/Users/rorygeddes/Workspace/Vancouver/Luni Flutter"

# Create a new branch without the exposed credentials
git checkout --orphan temp-branch

# Add all files
git add .

# Commit
git commit -m "Initial commit with security fixes"

# Delete the old main branch
git branch -D main

# Rename temp branch to main
git branch -m main

# Force push
git push -f origin main
```

#### Option B: Use BFG Repo-Cleaner
```bash
# Install BFG
brew install bfg

# Clean the file
bfg --replace-text <(echo 'cpsjbwtezrnajaiolsim=REDACTED') --no-blob-protection .

# Clean git history
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push
git push --force
```

### 3. Check Supabase Logs
1. Review Supabase logs for any unauthorized access
2. Check for suspicious activity or data access
3. Monitor for the next 24-48 hours

### 4. Update Security Practices
- ✅ Always use `.env` files for credentials (already implemented)
- ✅ Never commit template files with real credentials
- ✅ Use git-secrets or similar tools to prevent credential commits
- ✅ Review all commits before pushing to public repos

## What Was NOT Exposed ✅
- `.env` file (properly git-ignored)
- Plaid credentials (only in `.env`)
- OpenAI API key (only in `.env`)
- User passwords or sensitive user data

## Timeline
1. **Initial Commit:** Credentials exposed in `app_config.template.dart`
2. **Discovery:** Security review identified exposed credentials
3. **Fix Applied:** Credentials replaced with placeholders
4. **Pushed:** Security fix committed and pushed
5. **Next Steps:** Rotate keys and clean git history

## Lessons Learned
1. Template files should NEVER contain real credentials
2. All credentials should only be in `.env` files
3. Review all files before initial commit to public repos
4. Consider using GitHub secret scanning

## Contact
If you notice any suspicious activity:
1. Immediately disable the exposed keys in Supabase
2. Create new credentials
3. Review access logs

---

**Created:** $(date)
**Status:** INCIDENT RESPONSE IN PROGRESS
**Priority:** CRITICAL

