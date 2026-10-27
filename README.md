# ProcessPK

Simple, verified guides for common processes in Pakistan, made for students
and young people. English and Urdu, works offline, no login.

## What is in this version (MVP demo)

- Intro screen with English / اردو choice (switch any time in About)
- Home: search (English, Urdu, Roman Urdu), 4 categories, popular guides,
  "Continue where you left off"
- Guide detail: what it is, who needs it, documents, fees, time, steps,
  common mistakes, problems people face and how to fix them, official
  contacts (tap to call, email, website), official sources, last verified
  date, share, report an error
- My Progress: tick documents and steps, keep notes (tracking number,
  appointment date), all saved on the phone
- About: disclaimer (not affiliated with the government), all helplines,
  privacy, sources
- 9 student guides in both languages (`assets/guides.json`)
- Ask ProcessPK: AI answers about the open guide, grounded only in that
  guide, with sources and a daily limit (see `worker/README.md` to switch it on)
- AdMob test banners on Home and guide lists (never on checklists)
- Firebase ready: guides load from Firestore once you connect a project

## Build the APK without installing anything (GitHub)

1. Create an empty GitHub repository and push this folder to its `main` branch.
2. GitHub runs `.github/workflows/build-apk.yml` automatically (about 10 minutes).
3. Open the repository's Actions tab, click the latest "Build APK" run and
   download `processpk-apk` from Artifacts. Unzip it to get the APK.

## Build the Android APK (on your laptop)

1. Install Flutter (stable) and Android Studio. Run `flutter doctor` and fix
   anything it lists (accept Android licences with
   `flutter doctor --android-licenses`).
2. In this folder run:
   ```
   flutter pub get
   flutter test
   flutter build apk --release
   ```
3. The APK is at `build/app/outputs/flutter-apk/app-release.apk`. Copy it to
   an Android phone and install it (allow "install unknown apps").

To run on a connected phone or emulator instead: `flutter run`.

## Connect Firebase (optional, about 15 minutes)

The app works without Firebase using the bundled guides.

1. Create a project at https://console.firebase.google.com and enable
   Cloud Firestore.
2. Install the CLIs: `npm install -g firebase-tools` then
   `dart pub global activate flutterfire_cli`.
3. In this folder run `firebase login` then `flutterfire configure` and pick
   Android. This replaces `lib/firebase_options.dart`.
4. Add guides to a `guides` collection in Firestore. Each document uses the
   same fields as one entry in `assets/guides.json` (document ID = guide id).
   When the collection has documents, the app uses them and caches them for
   offline use. "Report an error" writes to a `reports` collection.

## Before publishing on Google Play

- Helplines and emails were taken from official pages (DGIP, HEC, PM&DC, FBR)
  and a NADRA office guide on 27 Oct 2026. Re-check them before release.
- Fill in every `lastVerified` date in the guides after checking each fact
  on the official website.
- Replace the AdMob test IDs: app ID in
  `android/app/src/main/AndroidManifest.xml`, banner ID in `lib/ads.dart`.
- Set your support email and privacy policy URL in `lib/config.dart`.
- Create an upload key and release signing config
  (https://docs.flutter.dev/deployment/android), then
  `flutter build appbundle`.
- New personal developer accounts must run a closed test with at least
  12 testers for 14 days before production.

## Project layout

```
assets/guides.json        guide content (English + Urdu)
lib/main.dart             start-up, Firebase and ads init
lib/app_state.dart        language, guides, checklist progress
lib/guide_repository.dart bundled guides + Firestore sync
lib/strings.dart          all interface text in English and Urdu
lib/screens/              intro, home, list, detail, checklist, progress, about
test/app_test.dart        content, search, progress and UI tests
```
