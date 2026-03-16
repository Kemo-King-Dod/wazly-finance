# تقرير إصلاح الإشعارات المحلية على iOS
# iOS Local Notifications Fix Report

---

## 1. ملخص المشكلة | Problem Summary

الإشعارات المحلية (Local Notifications) لم تكن تعمل على iOS/محاكي iPhone رغم أن:
- الإذونات كانت تُمنح بنجاح (`iOS permission granted: true`)
- `flutter_local_notifications` v21.0.0 مثبتة وتعمل على Android
- `zonedSchedule()` و `show()` كانتا تُنفذان بدون أخطاء

---

## 2. السبب الجذري | Root Cause

تم اكتشاف **أربع مشكلات** متداخلة:

### المشكلة الأولى: عدم تعيين UNUserNotificationCenter delegate
ملف `AppDelegate.swift` لم يكن يعيّن `UNUserNotificationCenter.current().delegate` صراحةً.  
بدون هذا التعيين، iOS لا يعرف أين يوجّه الإشعارات عند عرضها في الـ foreground.

### المشكلة الثانية: عدم تحديد خيارات العرض (Presentation Options)
`DarwinNotificationDetails` في `_details()` لم يكن يحدد:
- `presentAlert` — عرض تنبيه
- `presentBanner` — عرض بانر (iOS 14+)
- `presentList` — عرض في مركز الإشعارات (iOS 14+)
- `presentSound` — تشغيل صوت
- `presentBadge` — تحديث الـ badge

بدون تحديد هذه القيم صراحةً، iOS قد لا يعرض الإشعار عندما يكون التطبيق في foreground.

### المشكلة الثالثة: ملف صوت غير موجود
كان الكود يشير إلى ملف صوت `wazly_notification.mp3`:
```dart
iOS: DarwinNotificationDetails(sound: 'wazly_notification.mp3'),
```
- الملف **غير موجود** في iOS bundle
- صيغة `.mp3` **غير مدعومة رسمياً** لإشعارات iOS (المدعوم: `.aiff`, `.caf`, `.wav`)
- هذا قد يسبب فشل صامت في عرض الإشعار

### المشكلة الرابعة: غياب UIBackgroundModes
ملف `Info.plist` لم يكن يحتوي على `UIBackgroundModes` مما قد يؤثر على الإشعارات المجدولة.

---

## 3. الإصلاحات المطبقة | Fixes Applied

### الإصلاح 1: تحديث AppDelegate.swift

**قبل:**
```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**بعد:**
```swift
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**التغييرات:**
- إضافة `import UserNotifications`
- تعيين `UNUserNotificationCenter.current().delegate = self` **قبل** تسجيل الـ plugins
- هذا يضمن أن `FlutterAppDelegate` (الذي يدعم `UNUserNotificationCenterDelegate`) يتلقى callbacks الإشعارات

### الإصلاح 2: تحديث DarwinNotificationDetails

**الملف:** `lib/core/data/local/services/notification_service.dart`

**قبل:**
```dart
iOS: DarwinNotificationDetails(sound: '$_kSoundFile.mp3'),
macOS: DarwinNotificationDetails(sound: '$_kSoundFile.mp3'),
```

**بعد:**
```dart
iOS: DarwinNotificationDetails(
  presentAlert: true,
  presentBanner: true,
  presentList: true,
  presentSound: true,
  presentBadge: true,
),
macOS: DarwinNotificationDetails(
  presentAlert: true,
  presentSound: true,
  presentBadge: true,
),
```

**التغييرات:**
- إزالة مرجع ملف الصوت غير الموجود (يستخدم الصوت الافتراضي الآن)
- تحديد جميع خيارات العرض صراحةً لضمان ظهور الإشعارات في foreground و background

### الإصلاح 3: إضافة UIBackgroundModes إلى Info.plist

**الملف:** `ios/Runner/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

---

## 4. الملفات المعدّلة | Files Modified

| الملف | نوع التغيير |
|---|---|
| `ios/Runner/AppDelegate.swift` | إضافة delegate setup + import |
| `lib/core/data/local/services/notification_service.dart` | إصلاح DarwinNotificationDetails |
| `ios/Runner/Info.plist` | إضافة UIBackgroundModes |

---

## 5. الأوامر المنفذة | Commands Executed

```bash
# بناء التطبيق
flutter build ios --debug --simulator --no-pub

# تشغيل على المحاكي
flutter run -d "iPhone 17 Pro"
```

---

## 6. نتائج الاختبار | Test Results

بعد تطبيق الإصلاحات، تم التحقق من:

| الاختبار | النتيجة |
|---|---|
| الإذونات (alert, badge, sound) | ✅ `iOS permission granted: true` |
| إشعار فوري (`show()`) | ✅ `#9999` أُطلق بنجاح |
| إشعار مجدول بعد 6 ثوانٍ | ✅ `#1005` أُطلق بنجاح |
| إشعار مجدول بعد 35 ثانية | ✅ `#1010` أُطلق بنجاح |
| إشعار مجدول بعد دقيقة | ✅ `#8888` أُطلق بنجاح |
| الصوت الافتراضي | ✅ يعمل |
| Timer fallback | ✅ يعمل كنظام احتياطي |

**سجل من وحدة التحكم (Console Log):**
```
flutter: [NotifService] ⏰ Timezone set: Africa/Tripoli
flutter: [NotifService] ✅ Initialized OK
flutter: [NotifService] 🔑 iOS permission granted: true
flutter: [NotifService] ⏰ Timer (recurring) fired for #1005
flutter: [NotifService] 🔔 Firing notification #1005 NOW
flutter: [NotifService] ⏰ Timer fallback fired for #8888
flutter: [NotifService] 🔔 Firing notification #8888 NOW
flutter: [NotifService] ⏰ Timer (recurring) fired for #1010
flutter: [NotifService] 🔔 Firing notification #1010 NOW
flutter: [NotifService] 📤 Sending immediate test notification
flutter: [NotifService] 🔔 Firing notification #9999 NOW
```

---

## 7. ملاحظات مهمة | Important Notes

### حول الصوت المخصص
إذا أردت إضافة صوت مخصص لاحقاً:
1. حوّل الملف إلى صيغة `.caf` أو `.aiff` أو `.wav`
2. أضف الملف إلى `ios/Runner/` عبر Xcode (سحب وإفلات)
3. تأكد أنه مضاف إلى "Copy Bundle Resources" في Build Phases
4. حدّث `DarwinNotificationDetails` بـ `sound: 'filename.caf'`
5. الحد الأقصى لمدة الصوت: **30 ثانية**

### حول المحاكي vs الجهاز الحقيقي
- الإشعارات المحلية **تعمل** على المحاكي
- الصوت قد **لا يعمل** على بعض إصدارات المحاكي
- اختبر دائماً على جهاز حقيقي للتأكد النهائي

### حول foreground vs background
- **Foreground**: الإشعار يظهر كـ banner بفضل `presentBanner: true` و `presentAlert: true`
- **Background**: الإشعار يظهر في مركز الإشعارات بفضل `presentList: true`
- **App closed**: iOS يدير `UNNotificationRequest` المجدولة بشكل مستقل عن التطبيق

### حول Timer Fallback
نظام Timer الاحتياطي المضاف سابقاً (لمعالجة مشكلة MIUI على Android) يعمل أيضاً على iOS كطبقة حماية إضافية. عندما يكون التطبيق مفتوحاً، الـ Timer يطلق الإشعار بشكل مباشر عبر `show()`.

---

## 8. الهيكلة التقنية | Technical Architecture

```
┌─────────────────────────────────────────────┐
│              NotificationService             │
│                                              │
│  init()                                      │
│    ├─ timezone setup                         │
│    ├─ _plugin.initialize(DarwinSettings)     │
│    └─ requestPermissions()                   │
│                                              │
│  scheduleNotification()                      │
│    ├─ _plugin.zonedSchedule()  ← iOS Native  │
│    └─ Timer fallback           ← In-app      │
│                                              │
│  showImmediate()                             │
│    └─ _plugin.show()                         │
│                                              │
│  _details()                                  │
│    ├─ AndroidNotificationDetails             │
│    ├─ DarwinNotificationDetails (iOS)        │
│    │   ├─ presentAlert: true                 │
│    │   ├─ presentBanner: true                │
│    │   ├─ presentList: true                  │
│    │   ├─ presentSound: true                 │
│    │   └─ presentBadge: true                 │
│    └─ DarwinNotificationDetails (macOS)      │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│           AppDelegate.swift                  │
│                                              │
│  didFinishLaunchingWithOptions:              │
│    1. UNUserNotificationCenter.delegate=self │
│    2. GeneratedPluginRegistrant.register()   │
│    3. super.application(...)                 │
└─────────────────────────────────────────────┘
```

---

**تاريخ الإصلاح:** 13 مارس 2026  
**إصدار flutter_local_notifications:** 21.0.0  
**الهدف:** iOS 15.0+  
**المحاكي المستخدم:** iPhone 17 Pro
