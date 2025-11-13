# Supabase Connection Troubleshooting

## Common Issues and Solutions

### 1. 404 Error - Project Not Found
**Error:** `Failed to load resource: the server responded with a status of 404 ()`
**Cause:** The Supabase URL or API key in your .env file is incorrect or the project doesn't exist

**Solution:**
1. Go to your Supabase dashboard: https://app.supabase.com/
2. Create a new project or select an existing one
3. Navigate to Project Settings > API
4. Copy the "Project URL" and "anon key" (Public)
5. Update your .env file with these values:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
```

### 2. Authentication Error
**Error:** Auth-related errors in console
**Cause:** RLS policies not set up or auth configuration issues

**Solution:**
1. Ensure your Supabase project has email authentication enabled:
   - Go to Authentication > Settings
   - Enable "Email" provider
2. Check that the `on_auth_user_created` trigger is working

### 3. Database Connection Error
**Error:** Database-related errors in console
**Cause:** Schema not deployed to your Supabase project

**Solution:**
1. Go to your Supabase dashboard
2. Navigate to SQL Editor
3. Run the schema from `SCHEMA_SUPABASE_SAFE.sql` to set up all tables
4. Verify all functions, triggers, and RLS policies are deployed

### 4. Environment Variables Not Loading
**Error:** App uses fallback default values instead of .env values
**Cause:** The .env file is not in the correct location or has incorrect format

**Solution:**
1. Ensure .env file is in the project root (same directory as pubspec.yaml)
2. Verify the format is exactly:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```
3. No quotes around the values
4. No spaces around the equals sign

## Testing with Valid Credentials

### Step 1: Create Supabase Project
1. Go to https://app.supabase.com/
2. Sign up or sign in
3. Create a new project
4. Wait for the project to be initialized

### Step 2: Deploy Schema
1. In your Supabase dashboard, go to SQL Editor
2. Paste the content from `SCHEMA_SUPABASE_SAFE.sql`
3. Click "Run" to execute the schema

### Step 3: Update Environment Variables
1. Copy your Project URL and anon key from Project Settings > API
2. Update your `.env` file with these values

### Step 4: Test Authentication Settings
1. Go to Authentication > Settings in your Supabase dashboard
2. Enable email authentication
3. Add "http://localhost:3000" to redirect URLs (for local testing)
4. Add your domain to "Site URL" and "Additional URLs"

### Step 5: Run the Application
```bash
flutter run -d chrome
```

## Verification Steps

### After Updating Credentials:
1. Check that the app shows the splash screen without Supabase connection errors
2. Try creating an account - it should work if auth is configured properly
3. Check your Supabase dashboard > Authentication > Users to see if users are created
4. Verify that the profile is created in the profiles table

## Security Notes
- Never commit your .env file to version control
- Always use different credentials for development vs production
- Regularly rotate your API keys for security

## Development Workflow
1. Use dummy/fake credentials during development for UI testing
2. Use your actual Supabase project for functional testing
3. Deploy your schema once to your Supabase project
4. Test authentication flows
5. Verify all CRUD operations work properly

## Fallback Configuration
If you're just testing the UI and don't have a Supabase project:
- The app will use fallback default values
- UI will still render but database operations won't work
- This is fine for UI/UX development