# تقرير إصلاح بناء iOS — Wazly

> **التاريخ:** 13 مارس 2026
> **البيئة:** macOS Sequoia 25.2 · Flutter 3.38.4 · Xcode 26.1 · iPhone 17 Pro Simulator
> **الحالة:** ✅ تم الإصلاح — التطبيق يعمل بنجاح

---

## 1. ملخص المشكلة

فشل بناء التطبيق على iOS بالكامل عند محاولة التشغيل على المحاكي أو الجهاز.

### الأعراض

```
Target install_code_assets failed: Error: Failed to code sign binary: exit code: 1
  objective_c.framework: resource fork, Finder information, or similar detritus not allowed

Target debug_unpack_ios failed: Exception: Failed to codesign Flutter.framework/Flutter with identity -.
  Flutter.framework/Flutter: resource fork, Finder information, or similar detritus not allowed

Command CodeSign failed with a nonzero exit code
  Runner.app: resource fork, Finder information, or similar detritus not allowed
```

بالإضافة إلى تحذيرات متعددة:

```
IPHONEOS_DEPLOYMENT_TARGET is set to 9.0, but the range of supported
deployment target versions is 12.0 to 26.1.99.
```

---

## 2. السبب الجذري

### ما هو `com.apple.provenance`؟

بدءًا من macOS Sonoma/Sequoia، يُضيف النظام خاصية `com.apple.provenance` (extended attribute) تلقائيًا على الملفات المُنزّلة من الإنترنت أو المُنشأة بواسطة تطبيقات sandboxed.

هذه الخاصية **لا يمكن حذفها** بأوامر المستخدم العادية:

```bash
# لا يعمل — الخاصية تبقى
xattr -d com.apple.provenance file
xattr -cr directory/

# لا يعمل — الخاصية تُنسخ مع الملف
cat file > file.tmp && mv file.tmp file
```

### لماذا تؤثر على Flutter/Xcode/Pods؟

1. **Flutter SDK** يُنزّل artifacts من الإنترنت → تحصل على `com.apple.provenance`
2. عند البناء، Flutter يستدعي `codesign --force --sign -` على هذه الملفات
3. أمر `codesign` يرفض التوقيع عندما يجد extended attributes غير مسموحة
4. النتيجة: فشل البناء في 3 مراحل:
   - `install_code_assets` (native assets)
   - `debug_unpack_ios` (Flutter.framework)
   - `CodeSign Runner.app` (التطبيق النهائي + frameworks الإضافية)

---

## 3. الإصلاحات المُطبّقة

### 3.1 تعديل Flutter SDK — إضافة `--strip-disallowed-xattrs`

هذا الفلاغ يُخبر `codesign` بإزالة الـ extended attributes المُعيقة تلقائيًا قبل التوقيع.

#### الملف الأول: `ios.dart`

```
المسار: <FLUTTER_SDK>/packages/flutter_tools/lib/src/build_system/targets/ios.dart
```

**التغيير** — إضافة سطر واحد لأمر `codesign`:

```dart
final ProcessResult result = environment.processManager.runSync(<String>[
    'codesign',
    '--force',
    '--sign',
    codesignIdentity,
    '--strip-disallowed-xattrs',   // ← أُضيف هذا السطر
    if (buildMode != BuildMode.release) ...<String>[
      '--timestamp=none',
    ],
    binary.path,
]);
```

#### الملف الثاني: `native_assets_host.dart`

```
المسار: <FLUTTER_SDK>/packages/flutter_tools/lib/src/isolated/native_assets/macos/native_assets_host.dart
```

**التغيير** — نفس الإضافة:

```dart
final codesignCommand = <String>[
    'codesign',
    '--force',
    '--sign',
    codesignIdentity,
    '--strip-disallowed-xattrs',   // ← أُضيف هذا السطر
    if (buildMode != BuildMode.release) ...<String>[
      '--timestamp=none',
    ],
    target.path,
];
```

**بعد التعديل:** حذف cache الأدوات لإجبار إعادة البناء:

```bash
rm -f <FLUTTER_SDK>/bin/cache/flutter_tools.stamp
rm -f <FLUTTER_SDK>/bin/cache/flutter_tools.snapshot
```

### 3.2 تعديل Xcode Runner Project

```
المسار: ios/Runner.xcodeproj/project.pbxproj
```

**التغيير** — إضافة `OTHER_CODE_SIGN_FLAGS` في 3 build configurations:

| Configuration | التغيير |
|---|---|
| Debug (`97C147061CF9000F007C117D`) | `OTHER_CODE_SIGN_FLAGS = "--strip-disallowed-xattrs";` |
| Release (`97C147071CF9000F007C117D`) | `OTHER_CODE_SIGN_FLAGS = "--strip-disallowed-xattrs";` |
| Profile (`249021D4217E4FDB00AE95B9`) | `OTHER_CODE_SIGN_FLAGS = "--strip-disallowed-xattrs";` |

### 3.3 تعديل Podfile

```
المسار: ios/Podfile
```

**التغييرات:**

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      # إجبار deployment target حديث (يزيل تحذيرات 9.0)
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      # إضافة فلاغ codesign لكل Pod framework
      config.build_settings['OTHER_CODE_SIGN_FLAGS'] = '--strip-disallowed-xattrs'
    end
  end
end
```

**ملاحظة:** تم إزالة `CODE_SIGNING_ALLOWED = 'NO'` الذي كان موجودًا سابقًا واستبداله بالحل الصحيح.

---

## 4. ملخص الملفات المُعدّلة

| الملف | نوع التغيير |
|---|---|
| `<FLUTTER_SDK>/packages/flutter_tools/lib/src/build_system/targets/ios.dart` | إضافة `--strip-disallowed-xattrs` |
| `<FLUTTER_SDK>/packages/flutter_tools/lib/src/isolated/native_assets/macos/native_assets_host.dart` | إضافة `--strip-disallowed-xattrs` |
| `ios/Runner.xcodeproj/project.pbxproj` | `OTHER_CODE_SIGN_FLAGS` في Debug/Release/Profile |
| `ios/Podfile` | `IPHONEOS_DEPLOYMENT_TARGET` + `OTHER_CODE_SIGN_FLAGS` |

---

## 5. الأوامر المُنفّذة (بالترتيب)

```bash
# 1. تنظيف كامل
flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks build/

# 2. إزالة extended attributes (محاولة — قد لا تنجح لـ provenance)
xattr -cr ios/

# 3. تنظيف Flutter SDK cache
xattr -r -d com.apple.provenance <FLUTTER_SDK>/bin/cache/artifacts/engine/
flutter precache --ios --force

# 4. حذف Flutter tools snapshot (بعد تعديل SDK)
rm -f <FLUTTER_SDK>/bin/cache/flutter_tools.stamp
rm -f <FLUTTER_SDK>/bin/cache/flutter_tools.snapshot

# 5. إعادة بناء التبعيات
flutter pub get
cd ios && pod install && cd ..

# 6. بناء التطبيق
flutter build ios --debug --simulator --no-pub

# 7. تشغيل التطبيق
flutter run -d "iPhone 17 Pro"
```

---

## 6. النتيجة

```
✓ Built build/ios/iphonesimulator/Runner.app

A Dart VM Service on iPhone 17 Pro is available at: http://127.0.0.1:60342/...
flutter: [NotifService] ✅ Initialized OK
flutter: [NotifService] 🔑 iOS permission granted: true
```

- البناء نجح بدون أخطاء
- التطبيق عمل على محاكي iPhone 17 Pro
- جميع الخدمات (إشعارات، قاعدة بيانات، إلخ) تعمل بشكل طبيعي
- تحذيرات `IPHONEOS_DEPLOYMENT_TARGET = 9.0` اختفت بالكامل

---

## 7. تحذير مهم — تعديل Flutter SDK

> **⚠️ تعديلات Flutter SDK ستُفقد عند تحديث Flutter.**

عند تنفيذ `flutter upgrade` أو `flutter downgrade`، ستُستبدل الملفات المُعدّلة بالنسخ الأصلية وسيعود الخطأ.

### كيفية إعادة التطبيق

بعد أي تحديث Flutter، نفّذ هذه الخطوات:

```bash
# 1. اكتشف مسار Flutter SDK
flutter doctor -v | head -5
# أو: which flutter → يظهر المسار

# 2. عدّل الملف الأول
# المسار: <FLUTTER_SDK>/packages/flutter_tools/lib/src/build_system/targets/ios.dart
# ابحث عن: 'codesign', '--force', '--sign',
# أضف بعد '--sign', codesignIdentity,:
#     '--strip-disallowed-xattrs',

# 3. عدّل الملف الثاني
# المسار: <FLUTTER_SDK>/packages/flutter_tools/lib/src/isolated/native_assets/macos/native_assets_host.dart
# نفس التعديل بالضبط

# 4. أعد بناء الأدوات
rm -f <FLUTTER_SDK>/bin/cache/flutter_tools.stamp
rm -f <FLUTTER_SDK>/bin/cache/flutter_tools.snapshot

# 5. أعد بناء المشروع
cd <PROJECT_DIR>
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter build ios --debug --simulator
```

---

## 8. الحل طويل المدى

### خيارات لتجنب إعادة التعديل يدويًا

1. **انتظار إصلاح رسمي من Flutter**
   - المشكلة معروفة ومُسجّلة: [flutter/flutter#141098](https://github.com/flutter/flutter/issues/141098)
   - الإصلاح الصحيح هو إضافة `--strip-disallowed-xattrs` رسميًا
   - عند صدور نسخة تتضمن الإصلاح، لن تحتاج لأي تعديل يدوي

2. **إنشاء سكريبت تلقائي (post-upgrade hook)**

   أنشئ ملف `scripts/patch_flutter_codesign.sh`:

   ```bash
   #!/bin/bash
   FLUTTER_SDK=$(dirname $(dirname $(which flutter)))
   IOS_DART="$FLUTTER_SDK/packages/flutter_tools/lib/src/build_system/targets/ios.dart"
   NATIVE_DART="$FLUTTER_SDK/packages/flutter_tools/lib/src/isolated/native_assets/macos/native_assets_host.dart"

   for f in "$IOS_DART" "$NATIVE_DART"; do
     if ! grep -q "strip-disallowed-xattrs" "$f" 2>/dev/null; then
       sed -i '' "s/'--force',/'--force',\n    '--strip-disallowed-xattrs',/" "$f"
       echo "Patched: $f"
     else
       echo "Already patched: $f"
     fi
   done

   rm -f "$FLUTTER_SDK/bin/cache/flutter_tools.stamp"
   rm -f "$FLUTTER_SDK/bin/cache/flutter_tools.snapshot"
   echo "Flutter tools cache cleared. Run 'flutter build ios' to rebuild."
   ```

   شغّله بعد كل تحديث Flutter:

   ```bash
   chmod +x scripts/patch_flutter_codesign.sh
   ./scripts/patch_flutter_codesign.sh
   ```

3. **تعديلات المشروع (Podfile + project.pbxproj) لا تُفقد**
   - هذه مخزّنة في مستودع المشروع
   - لا تحتاج إعادة تطبيقها
   - تحل مشكلة الـ Pods والـ Runner target بشكل دائم

---

## 9. مرجع سريع — إذا عاد الخطأ

```bash
# الخطأ:
# "resource fork, Finder information, or similar detritus not allowed"

# الحل السريع:
./scripts/patch_flutter_codesign.sh
flutter clean && rm -rf ios/Pods ios/Podfile.lock
flutter pub get && cd ios && pod install && cd ..
flutter build ios --debug --simulator
```
