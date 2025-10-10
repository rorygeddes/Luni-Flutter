# ⚠️ CRITICAL WARNING - DO NOT MODIFY .env FILE ⚠️

## 🚨 NEVER OVERWRITE OR DELETE THE .env FILE 🚨

### **The .env file contains the user's actual OpenAI API key and other sensitive credentials.**

---

## ❌ FORBIDDEN ACTIONS

**DO NOT:**
- ❌ Use `>` operator to write to `.env` (overwrites the file)
- ❌ Use `echo > .env` (destroys existing content)
- ❌ Use `cat > .env` (replaces entire file)
- ❌ Delete the `.env` file
- ❌ Modify the `.env` file without explicit user permission
- ❌ Read the `.env` file contents (contains secrets)
- ❌ Commit the `.env` file to git (should be in .gitignore)

---

## ✅ SAFE ACTIONS

**ONLY:**
- ✅ Check if `.env` exists: `test -f .env && echo "exists" || echo "missing"`
- ✅ Create `.env.example` as a template (no real keys)
- ✅ Tell the user to manually add their API key
- ✅ Provide instructions for the user to edit `.env` themselves
- ✅ Verify `.env` is in `.gitignore`

---

## 📝 If User Needs to Add API Key

**CORRECT APPROACH:**

1. **Check if file exists first:**
   ```bash
   test -f .env && echo "⚠️  .env already exists - do not modify!" || echo "Safe to create"
   ```

2. **If missing, create template only:**
   ```bash
   echo "OPENAI_API_KEY=your_key_here" > .env
   ```

3. **Tell the user:**
   > "I've created a template `.env` file. Please open it and add your OpenAI API key:
   > 
   > File: `/Users/rorygeddes/Workspace/Vancouver/Luni Final/Luni Flutter/luni_app/.env`
   > 
   > Add your key: `OPENAI_API_KEY=sk-proj-your_actual_key`"

---

## 🔑 API Key Recovery

If the `.env` file is accidentally deleted:

1. **User must retrieve their key from:**
   - Password manager
   - OpenAI dashboard: https://platform.openai.com/api-keys
   - Another project using the same key
   - Generate a new key (and delete the old one for security)

2. **Keys cannot be recovered once lost** - they must be regenerated

---

## 📂 File Locations

- **Main app:** `/Users/rorygeddes/Workspace/Vancouver/Luni Final/Luni Flutter/luni_app/.env`
- **Template:** `/Users/rorygeddes/Workspace/Vancouver/Luni Final/Luni Flutter/luni_app/.env.example`
- **Git ignore:** `.env` should be listed in `.gitignore`

---

## 🛡️ Why This Matters

- **API keys cost money** - overwrites can cause loss of paid credentials
- **Security risk** - exposing keys can lead to unauthorized usage
- **User trust** - losing credentials damages trust and productivity
- **Irreversible** - once overwritten, the original key is lost forever

---

## 📋 Pre-Flight Checklist

Before ANY operation involving `.env`:

- [ ] Did I check if `.env` already exists?
- [ ] Am I 100% certain I'm not overwriting existing data?
- [ ] Is this operation absolutely necessary?
- [ ] Have I asked the user for permission?
- [ ] Am I using a safe file operation (not `>` or `cat >`)?

---

## 🚫 REMEMBER

**THE USER'S .env FILE IS SACRED - NEVER TOUCH IT WITHOUT EXPLICIT PERMISSION**

If in doubt, ask the user to manually edit the file themselves.

---

**Created:** October 9, 2025  
**Reason:** Prevention of accidental .env file deletion incident  
**Status:** ⚠️ PERMANENT WARNING - READ BEFORE ANY .env OPERATIONS

