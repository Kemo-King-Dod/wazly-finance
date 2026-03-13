import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wazly'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts & Debts'**
  String get accounts;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @totalNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Total Net Worth'**
  String get totalNetWorth;

  /// No description provided for @vaultBalance.
  ///
  /// In en, this message translates to:
  /// **'Vault Balance'**
  String get vaultBalance;

  /// No description provided for @debtAssets.
  ///
  /// In en, this message translates to:
  /// **'Owed to Me'**
  String get debtAssets;

  /// No description provided for @debtLiabilities.
  ///
  /// In en, this message translates to:
  /// **'I Owe'**
  String get debtLiabilities;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @recordDebt.
  ///
  /// In en, this message translates to:
  /// **'Record Debt'**
  String get recordDebt;

  /// No description provided for @settlePay.
  ///
  /// In en, this message translates to:
  /// **'Settle / Pay'**
  String get settlePay;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description (optional)'**
  String get enterDescription;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get amountRequired;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @transactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully!'**
  String get transactionAdded;

  /// No description provided for @accountAdded.
  ///
  /// In en, this message translates to:
  /// **'Account added successfully'**
  String get accountAdded;

  /// No description provided for @addFirstAccount.
  ///
  /// In en, this message translates to:
  /// **'Add First Account'**
  String get addFirstAccount;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @noAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccounts;

  /// No description provided for @noAccountsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No accounts match this filter'**
  String get noAccountsMatchFilter;

  /// No description provided for @tryDifferentFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter or search term'**
  String get tryDifferentFilter;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @preparingAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Preparing Analytics...'**
  String get preparingAnalytics;

  /// No description provided for @initializingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Initializing Accounts...'**
  String get initializingAccounts;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get categoryDebt;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @debtSummary.
  ///
  /// In en, this message translates to:
  /// **'Debt Summary'**
  String get debtSummary;

  /// No description provided for @netPosition.
  ///
  /// In en, this message translates to:
  /// **'Net Position'**
  String get netPosition;

  /// No description provided for @activeDebts.
  ///
  /// In en, this message translates to:
  /// **'Active Debts'**
  String get activeDebts;

  /// No description provided for @dueThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Due This Week'**
  String get dueThisWeek;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebt;

  /// No description provided for @searchAccounts.
  ///
  /// In en, this message translates to:
  /// **'Search accounts...'**
  String get searchAccounts;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// No description provided for @debtType.
  ///
  /// In en, this message translates to:
  /// **'Debt Type'**
  String get debtType;

  /// No description provided for @theyOweMe.
  ///
  /// In en, this message translates to:
  /// **'They Owe Me (Give)'**
  String get theyOweMe;

  /// No description provided for @iOweThem.
  ///
  /// In en, this message translates to:
  /// **'I Owe Them (Receive)'**
  String get iOweThem;

  /// No description provided for @settlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get settlement;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind Me'**
  String get remindMe;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @enterNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter notes (optional)'**
  String get enterNotes;

  /// No description provided for @debtAdded.
  ///
  /// In en, this message translates to:
  /// **'Debt added successfully!'**
  String get debtAdded;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterOwedToMe.
  ///
  /// In en, this message translates to:
  /// **'Owed to Me'**
  String get filterOwedToMe;

  /// No description provided for @filterIOwe.
  ///
  /// In en, this message translates to:
  /// **'I Owe'**
  String get filterIOwe;

  /// No description provided for @filterSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get filterSettled;

  /// No description provided for @sortByAmount.
  ///
  /// In en, this message translates to:
  /// **'By Amount'**
  String get sortByAmount;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get sortByDate;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'By Name'**
  String get sortByName;

  /// No description provided for @sortByDueDate.
  ///
  /// In en, this message translates to:
  /// **'By Due Date'**
  String get sortByDueDate;

  /// No description provided for @sortByBalance.
  ///
  /// In en, this message translates to:
  /// **'By Balance'**
  String get sortByBalance;

  /// No description provided for @sortByRecent.
  ///
  /// In en, this message translates to:
  /// **'By Recent Activity'**
  String get sortByRecent;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @settleDebt.
  ///
  /// In en, this message translates to:
  /// **'Settle Debt'**
  String get settleDebt;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @owedToMe.
  ///
  /// In en, this message translates to:
  /// **'Owed to me'**
  String get owedToMe;

  /// No description provided for @iOwe.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get iOwe;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your finances with ease'**
  String get welcomeTagline;

  /// No description provided for @continueWithoutSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue without sign-in'**
  String get continueWithoutSignIn;

  /// No description provided for @dueIn.
  ///
  /// In en, this message translates to:
  /// **'Due in'**
  String get dueIn;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account and all its transactions?'**
  String get deleteConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @systemReset.
  ///
  /// In en, this message translates to:
  /// **'System Reset'**
  String get systemReset;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @biometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get biometric;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @formatConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to format the system? All data will be lost.'**
  String get formatConfirmation;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @setupPassword.
  ///
  /// In en, this message translates to:
  /// **'Setup Password'**
  String get setupPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @authenticateToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to unlock Wazly'**
  String get authenticateToUnlock;

  /// No description provided for @securityEnabled.
  ///
  /// In en, this message translates to:
  /// **'Security enabled successfully'**
  String get securityEnabled;

  /// No description provided for @securityDisabled.
  ///
  /// In en, this message translates to:
  /// **'Security disabled successfully'**
  String get securityDisabled;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully'**
  String get backupExported;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully'**
  String get backupRestored;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup operation failed'**
  String get backupFailed;

  /// No description provided for @theyPaidMe.
  ///
  /// In en, this message translates to:
  /// **'They Paid Me (Receive)'**
  String get theyPaidMe;

  /// No description provided for @iPaidThem.
  ///
  /// In en, this message translates to:
  /// **'I Paid Them (Give)'**
  String get iPaidThem;

  /// No description provided for @miniSidebar.
  ///
  /// In en, this message translates to:
  /// **'Mini-Sidebar'**
  String get miniSidebar;

  /// No description provided for @miniSidebarDesc.
  ///
  /// In en, this message translates to:
  /// **'Show navigation icons on the side for quick access'**
  String get miniSidebarDesc;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Wazly'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your region to configure date formatting, text direction, and currency.'**
  String get welcomeSubtitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageLabel;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'COUNTRY'**
  String get countryLabel;

  /// No description provided for @selectLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectLanguageHint;

  /// No description provided for @selectCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get selectCountryHint;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track Income & Expenses'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Easily log what you earn and what you spend to stay on top of your wallet.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Master Debt Management'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Keep track of who owes you and who you owe with clear histories and partial payments.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Insights & Reports'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Visualize your spending habits and quickly export transactions to PDF reports.'**
  String get onboardingSubtitle3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal finance, debts, and cash tracking'**
  String get aboutSubtitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @authenticateToEnableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to enable biometrics'**
  String get authenticateToEnableBiometrics;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed or is not available. Ensure you have Face ID/Fingerprint enrolled.'**
  String get biometricFailed;

  /// No description provided for @autoLockDelayTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock delay'**
  String get autoLockDelayTitle;

  /// No description provided for @delayImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get delayImmediately;

  /// No description provided for @delayOneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 Minute'**
  String get delayOneMinute;

  /// No description provided for @delayFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 Minutes'**
  String get delayFiveMinutes;

  /// No description provided for @delayFifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'15 Minutes'**
  String get delayFifteenMinutes;

  /// No description provided for @pinChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully'**
  String get pinChangedSuccessfully;

  /// No description provided for @requirePinToOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Require PIN to open app'**
  String get requirePinToOpenApp;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get biometricUnlock;

  /// No description provided for @useFingerprintOrFaceId.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID'**
  String get useFingerprintOrFaceId;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'ADVANCED'**
  String get advancedSettings;

  /// No description provided for @afterXMinutes.
  ///
  /// In en, this message translates to:
  /// **'After {minutes} minutes'**
  String afterXMinutes(int minutes);

  /// No description provided for @changePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinTitle;

  /// No description provided for @enterYourPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterYourPin;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get pinsDoNotMatch;

  /// No description provided for @createPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN'**
  String get createPinTitle;

  /// No description provided for @verifyNewPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your new PIN'**
  String get verifyNewPinTitle;

  /// No description provided for @verifyPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify your PIN to continue'**
  String get verifyPinToContinue;

  /// No description provided for @incorrectPinTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Try again.'**
  String get incorrectPinTryAgain;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @emptyAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'No analytics yet'**
  String get emptyAnalyticsTitle;

  /// No description provided for @emptyAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add some transactions to see your financial insights and trends here.'**
  String get emptyAnalyticsSubtitle;

  /// No description provided for @emptyDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get emptyDashboardTitle;

  /// No description provided for @emptyDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your wallet is clean! Start tracking your cash flow by adding a transaction.'**
  String get emptyDashboardSubtitle;

  /// No description provided for @addFirstTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add First Transaction'**
  String get addFirstTransaction;

  /// No description provided for @emptyActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get emptyActivityTitle;

  /// No description provided for @emptyActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or add a new transaction.'**
  String get emptyActivitySubtitle;

  /// No description provided for @emptyPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'No people found'**
  String get emptyPeopleTitle;

  /// No description provided for @emptyPeopleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add someone to start tracking debts and payments'**
  String get emptyPeopleSubtitle;

  /// No description provided for @addNewPerson.
  ///
  /// In en, this message translates to:
  /// **'Add New Person'**
  String get addNewPerson;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @owesYou.
  ///
  /// In en, this message translates to:
  /// **'Owes You'**
  String get owesYou;

  /// No description provided for @youOwe.
  ///
  /// In en, this message translates to:
  /// **'You Owe'**
  String get youOwe;

  /// No description provided for @wazlyReport.
  ///
  /// In en, this message translates to:
  /// **'Wazly Report'**
  String get wazlyReport;

  /// No description provided for @dateText.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateText;

  /// No description provided for @phoneText.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneText;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @totalDebt.
  ///
  /// In en, this message translates to:
  /// **'Total Debt'**
  String get totalDebt;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @remainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get remainingBalance;

  /// No description provided for @transactionsHistory.
  ///
  /// In en, this message translates to:
  /// **'Transactions History'**
  String get transactionsHistory;

  /// No description provided for @typeText.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeText;

  /// No description provided for @descriptionText.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionText;

  /// No description provided for @amountText.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountText;

  /// No description provided for @debtDashboard.
  ///
  /// In en, this message translates to:
  /// **'Debt Dashboard'**
  String get debtDashboard;

  /// No description provided for @deletePerson.
  ///
  /// In en, this message translates to:
  /// **'Delete Person'**
  String get deletePerson;

  /// No description provided for @deletePersonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this person? All their transactions will be permanently deleted.'**
  String get deletePersonConfirm;

  /// No description provided for @noPhoneNumberAvailable.
  ///
  /// In en, this message translates to:
  /// **'No phone number available'**
  String get noPhoneNumberAvailable;

  /// No description provided for @generatingReport.
  ///
  /// In en, this message translates to:
  /// **'Generating Report...'**
  String get generatingReport;

  /// No description provided for @failedToGenerateReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate report'**
  String get failedToGenerateReport;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @installmentPlans.
  ///
  /// In en, this message translates to:
  /// **'Installment Plans'**
  String get installmentPlans;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareReport;

  /// No description provided for @lastTransaction.
  ///
  /// In en, this message translates to:
  /// **'Last Transaction'**
  String get lastTransaction;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// No description provided for @averagePayment.
  ///
  /// In en, this message translates to:
  /// **'Average Payment'**
  String get averagePayment;

  /// No description provided for @noneText.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneText;

  /// No description provided for @resetAllData.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetAllData;

  /// No description provided for @resetAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all data? This action cannot be undone.'**
  String get resetAllDataConfirm;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// No description provided for @validationFailed.
  ///
  /// In en, this message translates to:
  /// **'Warning: Validation Failed'**
  String get validationFailed;

  /// No description provided for @forceImport.
  ///
  /// In en, this message translates to:
  /// **'Force Import'**
  String get forceImport;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @appVersionText.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersionText;

  /// No description provided for @buildNumberText.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumberText;

  /// No description provided for @developerText.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developerText;

  /// No description provided for @lastText.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get lastText;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// No description provided for @backupExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully!'**
  String get backupExportedSuccessfully;

  /// No description provided for @exportCancelledOrFailed.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled or failed.'**
  String get exportCancelledOrFailed;

  /// No description provided for @schemaMismatch.
  ///
  /// In en, this message translates to:
  /// **'This backup was created with a different schema version.'**
  String get schemaMismatch;

  /// No description provided for @corruptedBackup.
  ///
  /// In en, this message translates to:
  /// **'The backup file seems corrupted. Checksum mismatch.'**
  String get corruptedBackup;

  /// No description provided for @wazlyTeam.
  ///
  /// In en, this message translates to:
  /// **'Wazly Team'**
  String get wazlyTeam;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @remind.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get remind;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get noTransactionsYet;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @dataResetTemporarilyDisabled.
  ///
  /// In en, this message translates to:
  /// **'Data reset temporarily disabled in minimal UI'**
  String get dataResetTemporarilyDisabled;

  /// No description provided for @appAndPreferences.
  ///
  /// In en, this message translates to:
  /// **'App & Preferences'**
  String get appAndPreferences;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @enableInstallments.
  ///
  /// In en, this message translates to:
  /// **'Enable Installments'**
  String get enableInstallments;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @dataAndBackup.
  ///
  /// In en, this message translates to:
  /// **'Data & Backup'**
  String get dataAndBackup;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last Backup'**
  String get lastBackup;

  /// No description provided for @warningValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Warning: Validation Failed'**
  String get warningValidationFailed;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @currencyNotice.
  ///
  /// In en, this message translates to:
  /// **'Your default currency will be set to {currency}. You can change this later in Settings.'**
  String currencyNotice(String currency);

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction?'**
  String get deleteTransactionTitle;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @addToTreasury.
  ///
  /// In en, this message translates to:
  /// **'Add to Treasury (In)'**
  String get addToTreasury;

  /// No description provided for @removeFromTreasury.
  ///
  /// In en, this message translates to:
  /// **'Remove From Treasury (Out)'**
  String get removeFromTreasury;

  /// No description provided for @theyOweMeGive.
  ///
  /// In en, this message translates to:
  /// **'They Owe Me (Give)'**
  String get theyOweMeGive;

  /// No description provided for @iOweThemReceive.
  ///
  /// In en, this message translates to:
  /// **'I Owe Them (Receive)'**
  String get iOweThemReceive;

  /// No description provided for @contactPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Contact permission denied'**
  String get contactPermissionDenied;

  /// No description provided for @contactHasNoName.
  ///
  /// In en, this message translates to:
  /// **'Contact has no name'**
  String get contactHasNoName;

  /// No description provided for @failedToAddContact.
  ///
  /// In en, this message translates to:
  /// **'Failed to add contact'**
  String get failedToAddContact;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @homeNav.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNav;

  /// No description provided for @insightsAndReports.
  ///
  /// In en, this message translates to:
  /// **'Insights and reports'**
  String get insightsAndReports;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @netText.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netText;

  /// No description provided for @incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get incomeVsExpense;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @topSpendingCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Spending Category'**
  String get topSpendingCategory;

  /// No description provided for @mostActivePerson.
  ///
  /// In en, this message translates to:
  /// **'Most Active Person'**
  String get mostActivePerson;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @totalBalanceText.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalanceText;

  /// No description provided for @availableFunds.
  ///
  /// In en, this message translates to:
  /// **'Available funds'**
  String get availableFunds;

  /// No description provided for @income7d.
  ///
  /// In en, this message translates to:
  /// **'Income (7d)'**
  String get income7d;

  /// No description provided for @expense7d.
  ///
  /// In en, this message translates to:
  /// **'Expense (7d)'**
  String get expense7d;

  /// No description provided for @netToday.
  ///
  /// In en, this message translates to:
  /// **'Net Today'**
  String get netToday;

  /// No description provided for @topActiveDebts.
  ///
  /// In en, this message translates to:
  /// **'Top Active Debts'**
  String get topActiveDebts;

  /// No description provided for @noActiveDebtsYet.
  ///
  /// In en, this message translates to:
  /// **'No active debts yet'**
  String get noActiveDebtsYet;

  /// No description provided for @netBalanceText.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalanceText;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @debtsText.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debtsText;

  /// No description provided for @paymentsText.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsText;

  /// No description provided for @treasuryText.
  ///
  /// In en, this message translates to:
  /// **'Treasury'**
  String get treasuryText;

  /// No description provided for @backText.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backText;

  /// No description provided for @peopleTitle.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleTitle;

  /// No description provided for @trackDebtsAndPayments.
  ///
  /// In en, this message translates to:
  /// **'Track debts & payments'**
  String get trackDebtsAndPayments;

  /// No description provided for @owedToYouCard.
  ///
  /// In en, this message translates to:
  /// **'Owed to You'**
  String get owedToYouCard;

  /// No description provided for @youOweCard.
  ///
  /// In en, this message translates to:
  /// **'You Owe'**
  String get youOweCard;

  /// No description provided for @importContacts.
  ///
  /// In en, this message translates to:
  /// **'Import Contacts'**
  String get importContacts;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people...'**
  String get searchPeople;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @peopleCountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'{count} {entity}'**
  String peopleCountPlaceholder(int count, String entity);

  /// No description provided for @personEntity.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get personEntity;

  /// No description provided for @peopleEntity.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleEntity;

  /// No description provided for @highestExposure.
  ///
  /// In en, this message translates to:
  /// **'Highest Exposure'**
  String get highestExposure;

  /// No description provided for @peopleOverdue.
  ///
  /// In en, this message translates to:
  /// **'People Overdue'**
  String get peopleOverdue;

  /// No description provided for @addedFunds.
  ///
  /// In en, this message translates to:
  /// **'Added Funds'**
  String get addedFunds;

  /// No description provided for @removedFunds.
  ///
  /// In en, this message translates to:
  /// **'Removed Funds'**
  String get removedFunds;

  /// No description provided for @dueDateAndReminder.
  ///
  /// In en, this message translates to:
  /// **'Due Date & Reminder'**
  String get dueDateAndReminder;

  /// No description provided for @dueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional — pick a due date'**
  String get dueDateOptional;

  /// No description provided for @clearDueDate.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearDueDate;

  /// No description provided for @enableReminder.
  ///
  /// In en, this message translates to:
  /// **'Enable reminder'**
  String get enableReminder;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @manageDebtsAndPayments.
  ///
  /// In en, this message translates to:
  /// **'Manage debts & payments'**
  String get manageDebtsAndPayments;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)...'**
  String get descriptionOptional;

  /// No description provided for @debtLabel.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debtLabel;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentLabel;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @testNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send an immediate test alert'**
  String get testNotificationSubtitle;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get testNotificationSent;

  /// No description provided for @dailyActivitySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Activity Summary'**
  String get dailyActivitySummary;

  /// No description provided for @dailyActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me to check my debts every day'**
  String get dailyActivitySubtitle;

  /// No description provided for @weeklyReview.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review'**
  String get weeklyReview;

  /// No description provided for @weeklyReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A weekly prompt to review my finances'**
  String get weeklyReviewSubtitle;

  /// No description provided for @setAReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a Reminder?'**
  String get setAReminderTitle;

  /// No description provided for @setAReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When should we remind you about {name}?'**
  String setAReminderSubtitle(String name);

  /// No description provided for @in3Days.
  ///
  /// In en, this message translates to:
  /// **'In 3 Days'**
  String get in3Days;

  /// No description provided for @in1Week.
  ///
  /// In en, this message translates to:
  /// **'In 1 Week'**
  String get in1Week;

  /// No description provided for @in2Weeks.
  ///
  /// In en, this message translates to:
  /// **'In 2 Weeks'**
  String get in2Weeks;

  /// No description provided for @noReminderSkip.
  ///
  /// In en, this message translates to:
  /// **'No Reminder, Skip'**
  String get noReminderSkip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @debtReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Debt Reminder'**
  String get debtReminderTitle;

  /// No description provided for @debtReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Time to check in on the debt with {name}.'**
  String debtReminderBody(String name);

  /// No description provided for @chooseDays.
  ///
  /// In en, this message translates to:
  /// **'Choose days'**
  String get chooseDays;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose time'**
  String get chooseTime;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @reminderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Reminder cancelled!'**
  String get reminderCancelled;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @personAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} added successfully!'**
  String personAddedSuccess(String name);

  /// No description provided for @settingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsButton;

  /// No description provided for @backupRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully!'**
  String get backupRestoredSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {status}'**
  String restoreFailed(String status);

  /// No description provided for @dataResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data has been successfully reset'**
  String get dataResetSuccess;

  /// No description provided for @dataResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset data: {error}'**
  String dataResetFailed(String error);

  /// No description provided for @selectYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectYourLanguage;

  /// No description provided for @selectYourCountry.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get selectYourCountry;

  /// No description provided for @countryLibya.
  ///
  /// In en, this message translates to:
  /// **'Libya'**
  String get countryLibya;

  /// No description provided for @countryEgypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get countryEgypt;

  /// No description provided for @countryUAE.
  ///
  /// In en, this message translates to:
  /// **'UAE'**
  String get countryUAE;

  /// No description provided for @countrySaudiArabia.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get countrySaudiArabia;

  /// No description provided for @countryUS.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUS;

  /// No description provided for @countryUK.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get countryUK;

  /// No description provided for @countryEurozone.
  ///
  /// In en, this message translates to:
  /// **'Eurozone'**
  String get countryEurozone;

  /// No description provided for @countryIndia.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get countryIndia;

  /// No description provided for @scheduleDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Details'**
  String get scheduleDebugTitle;

  /// No description provided for @scheduledTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Test (1 min)'**
  String get scheduledTestTitle;

  /// No description provided for @scheduledTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Schedules a notification 60 seconds from now and shows debug info'**
  String get scheduledTestSubtitle;

  /// No description provided for @miuiSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'MIUI Notification Settings'**
  String get miuiSettingsTitle;

  /// No description provided for @miuiSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fix notification issues on Xiaomi'**
  String get miuiSettingsSubtitle;

  /// No description provided for @miuiInstructions.
  ///
  /// In en, this message translates to:
  /// **'If scheduled notifications do not arrive on Xiaomi / MIUI, follow these steps:'**
  String get miuiInstructions;

  /// No description provided for @debtReminderNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Wazly — Debt Reminder'**
  String get debtReminderNotifTitle;

  /// No description provided for @debtReminderNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Debt payment is due today. Check account details.'**
  String get debtReminderNotifBody;

  /// No description provided for @selectPerson.
  ///
  /// In en, this message translates to:
  /// **'Select Person'**
  String get selectPerson;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @descriptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptionalLabel;

  /// No description provided for @directionLabel.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get directionLabel;

  /// No description provided for @personLabel.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get personLabel;

  /// No description provided for @dateAndTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTimeLabel;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Optional note...'**
  String get optionalNote;

  /// No description provided for @exampleCategory.
  ///
  /// In en, this message translates to:
  /// **'e.g. Subscriptions'**
  String get exampleCategory;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @expenseTab.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseTab;

  /// No description provided for @incomeTab.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeTab;

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get failedToLoadCategories;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @tapToAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first category'**
  String get tapToAddCategory;

  /// No description provided for @systemBadge.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemBadge;

  /// No description provided for @themeRoyalPurple.
  ///
  /// In en, this message translates to:
  /// **'Royal Purple'**
  String get themeRoyalPurple;

  /// No description provided for @themeIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get themeIndigo;

  /// No description provided for @themeEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get themeEmerald;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeSunset;

  /// No description provided for @themeMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get themeMidnight;

  /// No description provided for @themeCrimson.
  ///
  /// In en, this message translates to:
  /// **'Crimson'**
  String get themeCrimson;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themeAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get themeAmber;

  /// No description provided for @themeTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get themeTeal;

  /// No description provided for @themeRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get themeRose;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeForest;

  /// No description provided for @dailyReminderNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Wazly — Daily Reminder'**
  String get dailyReminderNotifTitle;

  /// No description provided for @dailyReminderNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Check your debts and transactions today.'**
  String get dailyReminderNotifBody;

  /// No description provided for @weeklyReminderNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Wazly — Weekly Review'**
  String get weeklyReminderNotifTitle;

  /// No description provided for @weeklyReminderNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Time to review your weekly financial status.'**
  String get weeklyReminderNotifBody;

  /// No description provided for @testNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Wazly — Test Notification 🔔'**
  String get testNotifTitle;

  /// No description provided for @testNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are working correctly! You can now set reminders.'**
  String get testNotifBody;

  /// No description provided for @scheduledTestNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Wazly — Scheduled Test ⏰'**
  String get scheduledTestNotifTitle;

  /// No description provided for @activeReminder.
  ///
  /// In en, this message translates to:
  /// **'Active Reminder'**
  String get activeReminder;

  /// No description provided for @noReminderSet.
  ///
  /// In en, this message translates to:
  /// **'No Reminder Set'**
  String get noReminderSet;

  /// No description provided for @nextReminder.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String nextReminder(String date);

  /// No description provided for @tapToScheduleReminder.
  ///
  /// In en, this message translates to:
  /// **'Tap to schedule a reminder'**
  String get tapToScheduleReminder;

  /// No description provided for @remindersSection.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersSection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
