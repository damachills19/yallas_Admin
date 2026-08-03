import 'package:supabase_flutter/supabase_flutter.dart';

/// Points at the same Supabase project as the main Yalla Fit app — this
/// admin portal is a separate Flutter project/deployment but shares the
/// exact same backend (tables, RLS, storage buckets).
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://ekwrxtrswecnskojphfc.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrd3J4dHJzd2VjbnNrb2pwaGZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU2ODQ4OTksImV4cCI6MjEwMTI2MDg5OX0.8w_p5NOnRpPYUMDAPfC1fOIcHYaPW8jqRqJFaQMU3XM';

  static Future<void> init() async {
    // ignore: deprecated_member_use
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
