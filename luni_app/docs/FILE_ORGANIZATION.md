# File Organization Rules

## 📋 Where to Save New Files

### SQL Scripts → `docs/sql/`
**All SQL scripts** for database management, fixes, setup, etc.

Examples:
- `RESET_*.sql`
- `FIX_*.sql`
- `DEBUG_*.sql`
- `CHECK_*.sql`
- `setup_*.sql`
- `COMPLETE_*.sql`

### Setup Guides & Documentation → `docs/setup/`
**All markdown documentation** for setup, guides, system explanations, etc.

Examples:
- `*_SETUP.md`
- `*_GUIDE.md`
- `*_SYSTEM_COMPLETE.md`
- `*_INTEGRATION.md`
- `*_FIX.md`
- `*_MIGRATION.md`
- Any other `.md` files (except README.md in root)

## 🚫 Root Directory Rules

**DO NOT** save these in the root `luni_app/` directory:
- ❌ SQL files (`.sql`)
- ❌ Setup guides (`.md` files)
- ❌ Documentation files

**ONLY** these should be in root:
- ✅ `README.md` (main app readme)
- ✅ `pubspec.yaml`
- ✅ `analysis_options.yaml`
- ✅ `.env` (environment variables, gitignored)
- ✅ Source code directories (`lib/`, `test/`, etc.)
- ✅ Platform-specific directories (`ios/`, `android/`, etc.)

## 📁 Directory Structure

```
luni_app/
├── README.md                      ✅ Main readme only
├── docs/
│   ├── README.md                  ✅ Documentation index
│   ├── FILE_ORGANIZATION.md       ✅ This file
│   ├── sql/                       ✅ All SQL scripts here
│   │   ├── README.md
│   │   ├── RESET_*.sql
│   │   ├── FIX_*.sql
│   │   ├── setup_*.sql
│   │   └── ...
│   └── setup/                     ✅ All guides/docs here
│       ├── README.md
│       ├── *_SETUP.md
│       ├── *_GUIDE.md
│       └── ...
├── lib/                           ✅ Source code
├── test/                          ✅ Tests
└── ...                            ✅ Other app files
```

## 🔄 Workflow

When creating new files:

1. **New SQL script?**
   - Save to: `docs/sql/FILENAME.sql`
   - Update: `docs/sql/README.md` if major

2. **New setup guide?**
   - Save to: `docs/setup/FILENAME.md`
   - Update: `docs/setup/README.md` if major

3. **New feature documentation?**
   - Save to: `docs/setup/FEATURE_SYSTEM_COMPLETE.md`

4. **Database migration guide?**
   - Save to: `docs/setup/MIGRATION_GUIDE.md`

## 🧹 Cleanup

If you find files in the wrong place:

```bash
# Move SQL files
mv *.sql docs/sql/

# Move MD files (except README.md)
mv *_SETUP.md *_GUIDE.md *_COMPLETE.md docs/setup/
```

## 📝 Notes

- This organization was established to keep the root directory clean
- All documentation is now centralized in `docs/`
- Makes it easier to find and maintain files
- Follows best practices for project structure

