# Supabase Environment Variables Configuration

## Overview
This document explains where and how to configure Supabase environment variables for the Storeffice Flutter application.

## Environment Variable Storage Options

### 1. Development (.env file) ✅ RECOMMENDED
A `.env` file has been created at the root of the project:

```
# Supabase Configuration
SUPABASE_URL=YOUR_SUPABASE_URL_HERE
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY_HERE
```

**Location:** `C:\Users\victo\Desktop\Gemini Projects\storeffice\storeffice\storeffice-app-v1\storeffice-app-v1\.env`

**Usage:** The application loads these variables at startup using the `flutter_dotenv` package.

### 2. Build-Time Environment Variables
You can also pass variables during build:
```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### 3. Platform Deployment Settings
When deploying to various platforms, use their respective environment variable configuration:

- **Firebase Hosting:** Use firebase.json environment variables
- **Netlify:** Deployment settings environment variables
- **Vercel:** Project environment variables
- **AWS Amplify:** App settings environment variables

## Configuration File
The application uses `lib/config.dart` to manage the Supabase configuration:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String? _supabaseUrl;
  static String? _supabaseAnonKey;

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    _supabaseUrl = dotenv.env['SUPABASE_URL'];
    _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  }

  static String get supabaseUrl {
    return _supabaseUrl ?? 'https://your-project.supabase.co';
  }

  static String get supabaseAnonKey {
    return _supabaseAnonKey ?? 'your-anon-key';
  }
}
```

## How It Works

1. **Initialization:** The config is initialized in `main()` before Supabase is set up
2. **Loading:** The .env file is loaded using `flutter_dotenv`
3. **Fallback:** If environment variables are not set, default values are used
4. **Access:** Other parts of the app access the variables through `Config.supabaseUrl` and `Config.supabaseAnonKey`

## Security Considerations

⚠️ **IMPORTANT**:
- The `.env` file is automatically ignored by git (if in .gitignore) to prevent exposing credentials
- Never commit the .env file with actual credentials to version control
- Always use placeholder values in example files
- For production, use platform-specific environment variable management

## Setup Instructions

### For Development:
1. Update the `.env` file with your actual Supabase credentials
2. Run `flutter pub get` to ensure dependencies are loaded
3. Run the app normally with `flutter run`

### For Production:
1. Remove the example .env file from the production build
2. Configure environment variables in your deployment platform
3. The app will use build-time variables or default fallbacks

## Required Variables

You need to obtain these from your Supabase dashboard:
- **SUPABASE_URL**: Your Supabase project URL (e.g., https://xxxxx.supabase.co)
- **SUPABASE_ANON_KEY**: Your Supabase anon key (public key that can be exposed to clients)

## Troubleshooting

If the app fails to connect:
1. Check that the .env file is properly formatted
2. Verify the `.env` file is in the project root (same level as pubspec.yaml)
3. Ensure the variables in .env match exactly: `SUPABASE_URL` and `SUPABASE_ANON_KEY`
4. Confirm your Supabase project is set up correctly with the unified schema
5. Check that your Supabase project allows connections from your development environment