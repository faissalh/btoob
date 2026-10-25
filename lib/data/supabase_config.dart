import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const url = 'https://rfmvdvtdafwwaogbfmdu.supabase.co';
  static const publishableKey =
      'sb_publishable_HcsMgxUdJS0MzHAYAgaliA_NIqvvD7a';

  static bool isInitialized = false;

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, publishableKey: publishableKey);
    isInitialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
