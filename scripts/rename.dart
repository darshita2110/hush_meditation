// Run this from your project root:  dart scripts/rename.dart
//
// What it does:
//   1. Replaces every  package:arvyax_flutter_app/  import with  package:hush/
//   2. Replaces class name ArvyaXApp → HushApp in all .dart files
//   3. Updates pubspec.yaml  name: arvyax_flutter_app  →  name: hush
//   4. Updates AndroidManifest.xml  android:label  →  "Hush"
//   5. Updates android/app/build.gradle  applicationId  →  com.yourname.hush
//   6. Updates iOS Info.plist  CFBundleDisplayName  →  Hush

import 'dart:io';

void main() {
  final projectRoot = Directory.current.path;

  // ── 1. Replace imports in all .dart files ─────────────────────────────────
  _replaceInDir(
    Directory('$projectRoot/lib'),
    from: 'package:arvyax_flutter_app/',
    to: 'package:hush/',
    ext: '.dart',
  );

  // ── 2. Replace class name ─────────────────────────────────────────────────
  _replaceInDir(
    Directory('$projectRoot/lib'),
    from: 'ArvyaXApp',
    to: 'HushApp',
    ext: '.dart',
  );
  _replaceInDir(
    Directory('$projectRoot/lib'),
    from: "'ArvyaX'",
    to: "'Hush'",
    ext: '.dart',
  );

  // ── 3. pubspec.yaml ───────────────────────────────────────────────────────
  _replaceInFile(
    '$projectRoot/pubspec.yaml',
    from: 'name: arvyax_flutter_app',
    to: 'name: hush',
  );
  _replaceInFile(
    '$projectRoot/pubspec.yaml',
    from: 'description: ArvyaX',
    to: 'description: Hush — A minimal meditation app',
  );

  // ── 4. AndroidManifest.xml ────────────────────────────────────────────────
  _replaceInFile(
    '$projectRoot/android/app/src/main/AndroidManifest.xml',
    from: 'android:label="arvyax_flutter_app"',
    to: 'android:label="Hush"',
  );
  // also try the display name variant
  _replaceInFile(
    '$projectRoot/android/app/src/main/AndroidManifest.xml',
    from: 'android:label="ArvyaX"',
    to: 'android:label="Hush"',
  );

  // ── 5. build.gradle applicationId ────────────────────────────────────────
  _replaceInFile(
    '$projectRoot/android/app/build.gradle',
    from: 'com.example.arvyax_flutter_app',
    to: 'com.yourname.hush',
  );

  // ── 6. iOS Info.plist ─────────────────────────────────────────────────────
  final plist = '$projectRoot/ios/Runner/Info.plist';
  if (File(plist).existsSync()) {
    _replaceInFile(plist, from: 'ArvyaX', to: 'Hush');
    _replaceInFile(plist, from: 'arvyax_flutter_app', to: 'hush');
  }

  print('✅  Renamed to Hush successfully.');
  print('');
  print('Next steps:');
  print('  1. Run:  flutter clean && flutter pub get');
  print('  2. Run:  dart run build_runner build --delete-conflicting-outputs');
  print('  3. Update applicationId in build.gradle to your own package name');
  print('  4. Replace android/app/src/main/res/mipmap-*/ic_launcher.png');
  print('     with your icon (use the hush_icon.svg as source)');
}

void _replaceInDir(Directory dir, {
  required String from,
  required String to,
  required String ext,
}) {
  if (!dir.existsSync()) return;
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith(ext)) {
      _replaceInFile(entity.path, from: from, to: to);
    }
  }
}

void _replaceInFile(String path, {required String from, required String to}) {
  final file = File(path);
  if (!file.existsSync()) return;
  final original = file.readAsStringSync();
  if (!original.contains(from)) return;
  file.writeAsStringSync(original.replaceAll(from, to));
  print('  updated  $path');
}