# b2b_souq

## Supabase setup

1. In the Supabase dashboard, open **SQL Editor**, paste and run
   [`supabase/schema.sql`](supabase/schema.sql). It creates the profile,
   marketplace, chat, and message tables, row-level security policies, storage
   buckets, cleanup functions, and the messages Realtime publication.
2. In **Authentication > Providers > Email**, disable email confirmations if
   accounts should be able to sign in immediately. If confirmations remain
   enabled, signup will explain that a confirmation/session is required.
3. The Flutter app uses the project's public `sb_publishable` key. Never put a
   Supabase `service_role` key in the app. RLS must remain enabled.
4. Run `flutter pub get`, then `flutter run`.

New accounts use Supabase Auth and sign in with their email address. Usernames
are unique profile names, not login credentials. Previously stored local
passwords cannot be migrated to Supabase Auth. Existing sample listings remain
available in the app; newly created listings, profiles, and chats are stored
in Supabase.

## Google Play release

- Android application ID: `com.b2b.souq.b2b_souq`. Keep this ID unchanged after
  creating the Play Console app.
- The release upload key is stored outside the project at
  `~/b2b-souq-upload-key.jks`; its local Gradle credentials are in the ignored
  `android/key.properties`. Back up both securely. Never commit or share them.
- Install **Android SDK Command-line Tools (latest)** from Android Studio's SDK
  Manager, then run `flutter doctor --android-licenses`.
- Build the signed Play upload bundle with `flutter build appbundle --release`.
  The output is `build/app/outputs/bundle/release/app-release.aab`.
- Increase the build number in `pubspec.yaml` for every Play upload. Flutter
  currently targets API 36, the required target for new apps from August 31,
  2026.
- For personal Play Console accounts created after November 13, 2023, Google
  requires a closed test with at least 12 opted-in testers for 14 continuous
  days before requesting production access.
