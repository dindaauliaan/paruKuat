import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://vtpivcozhlfvixqdjtxf.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0cGl2Y296aGxmdml4cWRqdHhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyOTk2MjksImV4cCI6MjA5Mjg3NTYyOX0'
      '.XbriEMe-3hXZWPQpincCWrWxqo6zPzWdBgmIb0ORzh8';

  static Future<void> init() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
