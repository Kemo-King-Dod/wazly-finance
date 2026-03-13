# Wazly - دليل المشروع الشامل

## نظرة عامة على المشروع

**Wazly** هو تطبيق إدارة مالية شخصية متقدم مبني باستخدام إطار العمل Flutter. يهدف التطبيق إلى تمكين المستخدمين من تتبع دخلهم ومصاريفهم، إدارة حساباتهم المالية، تتبع الديون (المستحقة لهم أو عليهم)، وتحليل وضعهم المالي من خلال رسوم بيانية تفاعلية.

### الأهداف الرئيسية
- **تتبع المعاملات المالية**: تسجيل جميع الدخل والمصاريف بشكل منظم
- **إدارة الديون**: متابعة الديون المستحقة للمستخدم أو عليه مع إمكانية التسديد الجزئي
- **تحليل مالي**: عرض إحصائيات ورسوم بيانية لفهم الأنماط المالية
- **دعم متعدد اللغات**: واجهة كاملة بالعربية والإنجليزية
- **الأمان**: حماية البيانات بنظام قفل التطبيق

---

## الهيكلية المعمارية (Architecture)

يتبع المشروع نمط **Clean Architecture** الذي يفصل المسؤوليات إلى ثلاث طبقات رئيسية:

### 1. طبقة البيانات (Data Layer)
تحتوي على:
- **Models**: نماذج البيانات التي تتوافق مع قاعدة البيانات المحلية (Hive)
- **DataSources**: مصادر البيانات المحلية (Local DataSources)
- **Repository Implementation**: تنفيذ واجهات المستودعات

**مثال**: `TransactionLocalDataSource` يتعامل مع قاعدة بيانات Hive لحفظ واسترجاع المعاملات.

### 2. طبقة المنطق (Domain Layer)
تحتوي على:
- **Entities**: الكيانات الأساسية (مثل `TransactionEntity`, `AccountEntity`)
- **Repositories**: واجهات المستودعات (Interfaces)
- **Use Cases**: حالات الاستخدام التي تحتوي على المنطق التجاري

**مثال**: `CalculateNetWorthUseCase` يحسب صافي الثروة بناءً على الرصيد والديون.

### 3. طبقة العرض (Presentation Layer)
تحتوي على:
- **Pages**: صفحات التطبيق (UI)
- **Widgets**: مكونات واجهة المستخدم القابلة لإعادة الاستخدام
- **BLoC**: إدارة الحالة باستخدام نمط BLoC/Cubit

**مثال**: `TransactionBloc` يدير حالة المعاملات ويتفاعل مع Use Cases.

---

## الميزات الرئيسية (Features)

### 1. المعاملات (Transactions)

#### الوصف
نظام شامل لتسجيل وإدارة جميع المعاملات المالية (دخل ومصاريف).

#### المكونات الأساسية

**Entity: TransactionEntity**
```dart
class TransactionEntity {
  final String id;              // معرف فريد
  final double amount;          // المبلغ
  final String category;        // الفئة (طعام، نقل، راتب، إلخ)
  final DateTime date;          // تاريخ المعاملة
  final String description;     // وصف
  final bool isIncome;          // هل هو دخل؟
  final bool isDebt;            // هل هو دين؟
  final String accountId;       // الحساب المرتبط
  final String? linkedAccountId; // حساب الشخص (للديون)
  final DebtStatus? debtStatus; // حالة الدين (مفتوح، جزئي، مسدد)
  final DateTime? dueDate;      // تاريخ الاستحقاق
  final bool hasNotification;   // تفعيل التنبيهات
  final bool isSettled;         // هل تم التسديد الكامل؟
}
```

**Use Cases الرئيسية**:
- `AddTransactionUseCase`: إضافة معاملة جديدة
- `GetTransactionsUseCase`: استرجاع جميع المعاملات
- `UpdateTransactionWithAuditUseCase`: تحديث معاملة مع تسجيل التغييرات
- `BalanceCalculator`: حساب الرصيد الإجمالي

**الصفحات**:
- `DashboardPage`: الصفحة الرئيسية تعرض الرصيد والمعاملات الأخيرة
- `AddTransactionPage`: صفحة إضافة معاملة جديدة
- `TransactionHistoryPage`: سجل كامل للمعاملات

#### سجل المراجعة (Audit Log)
يحتفظ التطبيق بسجل تفصيلي لكل التعديلات على المعاملات:
```dart
class AuditLogEntity {
  final String id;
  final String transactionId;
  final DateTime timestamp;
  final String changeType;      // created, updated, deleted
  final String? reason;         // سبب التعديل
  final Map<String, dynamic> oldValues;
  final Map<String, dynamic> newValues;
}
```

---

### 2. الحسابات (Accounts)

#### الوصف
إدارة الأشخاص/جهات الاتصال المرتبطة بالديون.

#### Entity: AccountEntity
```dart
class AccountEntity {
  final String id;
  final String name;    // اسم الشخص
  final String phone;   // رقم الهاتف
}
```

**Use Cases**:
- `GetAccountsUseCase`: استرجاع جميع الحسابات
- `AddAccountUseCase`: إضافة حساب جديد
- `DeleteAccountUseCase`: حذف حساب
- `GetAccountBalanceUseCase`: حساب رصيد كل حساب (الديون المستحقة له أو عليه)

**الصفحة**:
- `AccountsPage`: عرض قائمة الحسابات مع أرصدتها

---

### 3. الديون (Debts)

#### الوصف
نظام متقدم لتتبع الديون المستحقة للمستخدم أو عليه.

#### حالات الدين (DebtStatus)
```dart
enum DebtStatus {
  open,      // دين مفتوح (لم يُسدد)
  partial,   // تم التسديد الجزئي
  settled,   // تم التسديد الكامل
}
```

#### الآلية
- عند إضافة دين، يتم إنشاء معاملة بـ `isDebt = true`
- يمكن ربط الدين بشخص معين عبر `linkedAccountId`
- يتم حساب الديون تلقائياً:
  - **Debt Assets** (ديون لي): الديون المستحقة للمستخدم
  - **Debt Liabilities** (ديون عليّ): الديون المستحقة على المستخدم

**الصفحة**:
- `AddDebtPage`: إضافة دين جديد مع تحديد الشخص والتاريخ

---

### 4. التحليلات (Analytics)

#### الوصف
عرض رسوم بيانية وإحصائيات تفصيلية عن الوضع المالي.

#### المكونات
- **رسم بياني دائري**: توزيع المصاريف حسب الفئات
- **رسم بياني خطي**: تطور الرصيد عبر الزمن
- **إحصائيات**: إجمالي الدخل، المصاريف، صافي الثروة

**Use Case**:
- `GetCategoryWiseExpensesUseCase`: حساب المصاريف لكل فئة
- `CalculateNetWorthUseCase`: حساب صافي الثروة = (الرصيد + الديون المستحقة لي - الديون المستحقة عليّ)

**الصفحة**:
- `AnalyticsPage`: لوحة تحكم تحليلية شاملة

---

### 5. المصادقة (Authentication)

#### الوصف
نظام بسيط لإدارة أول استخدام للتطبيق وعرض شاشة الترحيب.

#### الآلية
- يتتبع عدد مرات فتح التطبيق (`launchCount`)
- يعرض شاشة الترحيب في المرة الأولى وكل 5 مرات
- يسمح بالمتابعة بدون تسجيل أو التسجيل عبر Google (قيد التطوير)

**المكونات**:
- `AuthBloc`: إدارة حالة المصادقة
- `GetAuthStatusUseCase`: التحقق من حالة المصادقة
- `IncrementLaunchCountUseCase`: زيادة عداد التشغيل
- `WelcomePage`: شاشة الترحيب

---

### 6. الملف الشخصي (Profile)

#### الوصف
إدارة معلومات المستخدم الشخصية.

#### Entity: ProfileModel
```dart
class ProfileModel {
  final String name;
  final String? profilePicture;  // مسار الصورة الشخصية
}
```

**Use Cases**:
- `GetProfileUseCase`: استرجاع بيانات الملف الشخصي
- `UpdateProfileUseCase`: تحديث الملف الشخصي

**الصفحة**:
- `ProfilePage`: عرض وتعديل الملف الشخصي

---

### 7. الإعدادات (Settings)

#### الوصف
إعدادات التطبيق مثل اللغة والسمة.

#### المكونات
- `SettingsBloc`: إدارة حالة الإعدادات
- تخزين الإعدادات في `SharedPreferences`
- دعم تبديل اللغة (عربي/إنجليزي)
- تفعيل/تعطيل شريط التنقل الجانبي

**الصفحات**:
- `SettingsPage`: صفحة الإعدادات
- `SecurityLockPage`: صفحة قفل التطبيق (PIN/Biometrics)

---

## إدارة الحالة (State Management)

يستخدم التطبيق نمط **BLoC** (Business Logic Component) لإدارة الحالة:

### مثال: TransactionBloc

```dart
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  // Use Cases
  final GetTransactionsUseCase getTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final BalanceCalculator balanceCalculator;
  
  // Events
  on<FetchTransactionData>(_onFetchTransactionData);
  on<AddTransaction>(_onAddTransaction);
  
  // States
  // - TransactionInitial
  // - TransactionLoading
  // - TransactionLoaded
  // - TransactionError
}
```

### تدفق البيانات
1. **UI** يرسل **Event** للـ BLoC
2. **BLoC** يستدعي **Use Case** المناسب
3. **Use Case** يتفاعل مع **Repository**
4. **Repository** يتعامل مع **DataSource** (Hive)
5. البيانات ترجع عبر نفس المسار
6. **BLoC** يصدر **State** جديد
7. **UI** يعيد البناء بناءً على الحالة الجديدة

---

## قاعدة البيانات المحلية (Hive)

يستخدم التطبيق **Hive** كقاعدة بيانات محلية سريعة وفعالة.

### الصناديق (Boxes)
```dart
await Hive.openBox<TransactionModel>('transactions');
await Hive.openBox<AccountModel>('accounts');
await Hive.openBox<AuditLogModel>('audit_logs');
await Hive.openBox<ProfileModel>('profile');
await Hive.openBox('settings');
```

### المحولات (Adapters)
يتم تسجيل محولات مخصصة لكل نموذج:
```dart
Hive.registerAdapter(TransactionModelAdapter());
Hive.registerAdapter(AccountModelAdapter());
Hive.registerAdapter(AuditLogModelAdapter());
Hive.registerAdapter(ProfileModelAdapter());
```

---

## حقن التبعيات (Dependency Injection)

يستخدم التطبيق مكتبة **GetIt** لحقن التبعيات.

### التهيئة (في `injection_container.dart`)
```dart
final sl = GetIt.instance;

// تسجيل DataSources
sl.registerLazySingleton<TransactionLocalDataSource>(() => ...);

// تسجيل Repositories
sl.registerLazySingleton<TransactionRepository>(() => ...);

// تسجيل Use Cases
sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));

// تسجيل BLoCs
sl.registerFactory(() => TransactionBloc(...));
```

---

## السمة والتصميم (Theme & Design)

### نظام الألوان
```dart
static const Color primaryColor = Color(0xFF001220);    // أزرق داكن
static const Color backgroundColor = Color(0xFF010B13); // أسود غني
static const Color incomeColor = Color(0xFF50C878);     // أخضر زمردي
static const Color debtColor = Color(0xFFFF4E50);       // برتقالي
static const Color cardColor = Color(0xFF0A1929);       // أزرق داكن للبطاقات
```

### الخطوط
يستخدم التطبيق خط **Poppins** من Google Fonts لجميع النصوص.

### المكونات المخصصة
- **WazlyDrawerPremium**: قائمة جانبية بتأثير Glassmorphism
- **WazlyNavigationRail**: شريط تنقل جانبي (اختياري)
- **VaultCard**: بطاقة عرض الرصيد الرئيسية
- **TransactionListItem**: عنصر قائمة المعاملات

---

## التنقل (Navigation)

### المسارات الرئيسية
```dart
routes: {
  '/welcome': (context) => const WelcomePage(),
  '/dashboard': (context) => const DashboardPage(),
  '/history': (context) => const TransactionHistoryPage(),
  '/accounts': (context) => const AccountsPage(),
  '/analytics': (context) => const AnalyticsPage(),
  '/profile': (context) => const ProfilePage(),
  '/settings': (context) => const SettingsPage(),
}
```

### بوابة المصادقة (_AuthGate)
- تتحقق من حالة المصادقة عند بدء التطبيق
- توجه المستخدم إلى `WelcomePage` أو `DashboardPage` حسب الحالة

---

## الخدمات الأساسية (Core Services)

### 1. BackupService
خدمة النسخ الاحتياطي واستعادة البيانات.

### 2. SecurityService
خدمة الأمان لقفل التطبيق بالبصمة أو PIN.

### 3. NotificationService
خدمة التنبيهات للتذكير بالديون المستحقة.

---

## تعدد اللغات (Internationalization)

### الإعداد
```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### الملفات
- `app_en.arb`: النصوص الإنجليزية
- `app_ar.arb`: النصوص العربية

### الاستخدام
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.dashboard);  // "Dashboard" أو "لوحة التحكم"
```

---

## المكتبات الرئيسية (Dependencies)

| المكتبة | الغرض |
|---------|-------|
| `flutter_bloc` | إدارة الحالة |
| `hive` & `hive_flutter` | قاعدة البيانات المحلية |
| `get_it` | حقن التبعيات |
| `equatable` | مقارنة الكائنات |
| `dartz` | البرمجة الوظيفية (Either) |
| `google_fonts` | الخطوط |
| `fl_chart` | الرسوم البيانية |
| `intl` | التنسيق والترجمة |
| `uuid` | توليد معرفات فريدة |
| `shared_preferences` | تخزين الإعدادات |
| `local_auth` | المصادقة البيومترية |
| `flutter_secure_storage` | تخزين آمن |
| `image_picker` | اختيار الصور |
| `flutter_contacts` | الوصول لجهات الاتصال |
| `permission_handler` | إدارة الأذونات |
| `file_picker` | اختيار الملفات |
| `share_plus` | مشاركة البيانات |

---

## سير العمل النموذجي (Typical Workflow)

### إضافة معاملة جديدة
1. المستخدم يفتح `AddTransactionPage`
2. يدخل البيانات (المبلغ، الفئة، التاريخ، إلخ)
3. يضغط على "حفظ"
4. يتم إرسال `AddTransaction` event إلى `TransactionBloc`
5. الـ BLoC يستدعي `AddTransactionUseCase`
6. الـ Use Case يحفظ البيانات عبر `TransactionRepository`
7. الـ Repository يكتب في Hive
8. يتم إصدار `TransactionLoaded` state جديد
9. الـ UI يتحدث ويعرض المعاملة الجديدة

### حساب صافي الثروة
1. يتم استدعاء `CalculateNetWorthUseCase`
2. يسترجع جميع المعاملات
3. يحسب:
   - الرصيد الكلي = مجموع الدخل - مجموع المصاريف
   - الديون المستحقة لي = مجموع الديون التي `isIncome = true`
   - الديون المستحقة عليّ = مجموع الديون التي `isIncome = false`
4. صافي الثروة = الرصيد + الديون لي - الديون عليّ

---

## الملاحظات الفنية المهمة

### 1. نظام الديون
- الديون يتم تخزينها كمعاملات عادية مع `isDebt = true`
- يمكن تسديد الدين جزئياً عن طريق إضافة معاملة جديدة مرتبطة بنفس `linkedAccountId`
- حالة الدين (`DebtStatus`) تُحدث تلقائياً بناءً على المبلغ المتبقي

### 2. سجل المراجعة
- كل تعديل على معاملة يتم تسجيله في `AuditLog`
- يحفظ القيم القديمة والجديدة
- يسمح بتتبع من قام بالتعديل ولماذا

### 3. الأداء
- استخدام `Hive` يضمن سرعة عالية في القراءة والكتابة
- الـ BLoC يمنع إعادة البناء غير الضرورية
- استخدام `Lazy Singleton` في GetIt لتحسين استهلاك الذاكرة

### 4. الأمان
- `SecurityLockPage` يغلف التطبيق بالكامل
- يمكن استخدام البصمة أو PIN للدخول
- البيانات الحساسة تُخزن في `flutter_secure_storage`

---

## خطط التطوير المستقبلية

بناءً على ملفات `notes.txt` و `bugs.txt`:

### ميزات مطلوبة
1. خيار لحساب الدين من الخزينة عند الإضافة
2. تسهيل إضافة دين من صفحة الحسابات
3. إضافة حقل "تاريخ الخلاص" بدلاً من "موعد التسديد"

### أخطاء معروفة
1. خطأ في حساب مجموع الديون عند التسديد الجزئي (يجب إصلاح منطق `GetAccountBalanceUseCase`)

---

## الخلاصة

**Wazly** هو تطبيق مالي متكامل يجمع بين البساطة في الاستخدام والقوة في الميزات. يعتمد على معمارية نظيفة تسهل الصيانة والتوسع، ويستخدم أحدث التقنيات في Flutter لتقديم تجربة مستخدم سلسة وجميلة.

التطبيق مصمم ليكون:
- **سريع**: باستخدام Hive للتخزين المحلي
- **آمن**: مع نظام قفل وتشفير
- **مرن**: يدعم لغات متعددة وسمات قابلة للتخصيص
- **قابل للتوسع**: معمارية نظيفة تسهل إضافة ميزات جديدة
