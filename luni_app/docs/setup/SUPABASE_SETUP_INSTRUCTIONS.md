# 🚀 New Supabase Setup Instructions

## Step 1: Clean Up Old Database
1. Go to your Supabase dashboard
2. Navigate to **SQL Editor**
3. **Delete all existing tables** in your database (profiles, institutions, accounts, transactions, etc.)
4. This ensures a clean start

## Step 2: Run the New Setup
1. In the **SQL Editor**, copy and paste the entire contents of `new_supabase_setup.sql`
2. Click **Run** to execute the script
3. You should see "Database setup complete!" message

## Step 3: Verify Setup
The script will create:
- ✅ **10 tables** with proper relationships
- ✅ **Row Level Security (RLS)** policies for data protection
- ✅ **Indexes** for optimal performance
- ✅ **Triggers** for automatic profile creation
- ✅ **Functions** for timestamp updates

## Step 4: Test the App
1. Run your Flutter app: `flutter run -d chrome`
2. The app should now work without database errors
3. Try the "Connect Bank Account" button

## What's Fixed
- ✅ **Authentication errors** - Proper user handling
- ✅ **Database schema** - Clean, organized structure
- ✅ **RLS policies** - Secure data access
- ✅ **Auto profile creation** - Triggers handle user signup
- ✅ **Plaid integration** - Ready for real bank connections

## Files Organized
- 📁 **old_supabase/** - Contains all previous database files
- 📄 **new_supabase_setup.sql** - Complete new database schema
- 📄 **SUPABASE_SETUP_INSTRUCTIONS.md** - This guide

## Need Help?
If you encounter any issues:
1. Check the Supabase logs in your dashboard
2. Verify RLS policies are enabled
3. Ensure the trigger function is created
4. Test with a simple query in the SQL editor

---

**Ready to go!** 🎉 Your Luni app database is now properly set up and ready for production use.
