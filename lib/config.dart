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