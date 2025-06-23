import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_aa.dart';
import 'app_localizations_af.dart';
import 'app_localizations_ak.dart';
import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_as.dart';
import 'app_localizations_az.dart';
import 'app_localizations_be.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_bm.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_bo.dart';
import 'app_localizations_br.dart';
import 'app_localizations_bs.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_ce.dart';
import 'app_localizations_co.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_cv.dart';
import 'app_localizations_cy.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_eo.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_eu.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fo.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_gd.dart';
import 'app_localizations_gl.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_ha.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_ht.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_hy.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ii.dart';
import 'app_localizations_is.dart';
import 'app_localizations_it.dart';
import 'app_localizations_iu.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_jv.dart';
import 'app_localizations_ka.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_km.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ku.dart';
import 'app_localizations_kw.dart';
import 'app_localizations_ky.dart';
import 'app_localizations_la.dart';
import 'app_localizations_lb.dart';
import 'app_localizations_lo.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_lv.dart';
import 'app_localizations_mg.dart';
import 'app_localizations_mi.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mn.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_mt.dart';
import 'app_localizations_my.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_nn.dart';
import 'app_localizations_no.dart';
import 'app_localizations_nr.dart';
import 'app_localizations_oc.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_qu.dart';
import 'app_localizations_rm.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sa.dart';
import 'app_localizations_sc.dart';
import 'app_localizations_sd.dart';
import 'app_localizations_sg.dart';
import 'app_localizations_si.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sn.dart';
import 'app_localizations_so.dart';
import 'app_localizations_sq.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_ss.dart';
import 'app_localizations_st.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_tg.dart';
import 'app_localizations_th.dart';
import 'app_localizations_ti.dart';
import 'app_localizations_tl.dart';
import 'app_localizations_tn.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ts.dart';
import 'app_localizations_tt.dart';
import 'app_localizations_tw.dart';
import 'app_localizations_ty.dart';
import 'app_localizations_ug.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_uz.dart';
import 'app_localizations_ve.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_wa.dart';
import 'app_localizations_wo.dart';
import 'app_localizations_xh.dart';
import 'app_localizations_yi.dart';
import 'app_localizations_yo.dart';
import 'app_localizations_zh.dart';
import 'app_localizations_zu.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('aa'),
    Locale('af'),
    Locale('ak'),
    Locale('am'),
    Locale('ar'),
    Locale('as'),
    Locale('az'),
    Locale('be'),
    Locale('bg'),
    Locale('bm'),
    Locale('bn'),
    Locale('bo'),
    Locale('br'),
    Locale('bs'),
    Locale('ca'),
    Locale('ce'),
    Locale('co'),
    Locale('cs'),
    Locale('cv'),
    Locale('cy'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('eo'),
    Locale('es'),
    Locale('et'),
    Locale('eu'),
    Locale('fa'),
    Locale('fi'),
    Locale('fo'),
    Locale('fr'),
    Locale('ga'),
    Locale('gd'),
    Locale('gl'),
    Locale('gu'),
    Locale('ha'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('ht'),
    Locale('hu'),
    Locale('hy'),
    Locale('id'),
    Locale('ii'),
    Locale('is'),
    Locale('it'),
    Locale('iu'),
    Locale('ja'),
    Locale('jv'),
    Locale('ka'),
    Locale('kk'),
    Locale('km'),
    Locale('kn'),
    Locale('ko'),
    Locale('ku'),
    Locale('kw'),
    Locale('ky'),
    Locale('la'),
    Locale('lb'),
    Locale('lo'),
    Locale('lt'),
    Locale('lv'),
    Locale('mg'),
    Locale('mi'),
    Locale('ml'),
    Locale('mn'),
    Locale('mr'),
    Locale('ms'),
    Locale('mt'),
    Locale('my'),
    Locale('nb'),
    Locale('ne'),
    Locale('nl'),
    Locale('nn'),
    Locale('no'),
    Locale('nr'),
    Locale('oc'),
    Locale('or'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('qu'),
    Locale('rm'),
    Locale('ro'),
    Locale('ru'),
    Locale('sa'),
    Locale('sc'),
    Locale('sd'),
    Locale('sg'),
    Locale('si'),
    Locale('sk'),
    Locale('sl'),
    Locale('sn'),
    Locale('so'),
    Locale('sq'),
    Locale('sr'),
    Locale('ss'),
    Locale('st'),
    Locale('sv'),
    Locale('sw'),
    Locale('ta'),
    Locale('te'),
    Locale('tg'),
    Locale('th'),
    Locale('ti'),
    Locale('tl'),
    Locale('tn'),
    Locale('tr'),
    Locale('ts'),
    Locale('tt'),
    Locale('tw'),
    Locale('ty'),
    Locale('ug'),
    Locale('uk'),
    Locale('ur'),
    Locale('uz'),
    Locale('ve'),
    Locale('vi'),
    Locale('wa'),
    Locale('wo'),
    Locale('xh'),
    Locale('yi'),
    Locale('yo'),
    Locale('zh'),
    Locale('zu'),
  ];

  /// Separator just before a colon (':'). Probably only populated in French and empty in other languages.
  ///
  /// In en, this message translates to:
  /// **''**
  String get sep;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @account_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?\nIf there is a specific reason, please share below'**
  String get account_delete_message;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// Button label: Validate the input
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// An action to create
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @applyButtonText.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButtonText;

  /// A label on a button that says 'Next', pressing the button takes the user to the next screen.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next_label;

  /// A label on a button that says 'Continue', pressing the button takes the user to the next screen.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_label;

  /// A label on a button that says 'Exit', pressing the button takes the user to the next screen.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit_label;

  /// A label on a button that says 'Previous', pressing the button takes the user to the previous screen.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous_label;

  /// No description provided for @go_back_to_top.
  ///
  /// In en, this message translates to:
  /// **'Go back to top'**
  String get go_back_to_top;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @save_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save?'**
  String get save_confirmation;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// 'Ignore' button. Typical use case in combination with 'OK' and 'Cancel' buttons.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// 'Calculate' button. Typical use case: the user inputs data then clicks on the 'calculate' button.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @reset_food_prefs.
  ///
  /// In en, this message translates to:
  /// **'Reset food preferences'**
  String get reset_food_prefs;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_occurred;

  /// No description provided for @featureInProgress.
  ///
  /// In en, this message translates to:
  /// **'We\'re still working on this feature, stay tuned'**
  String get featureInProgress;

  /// No description provided for @label_web.
  ///
  /// In en, this message translates to:
  /// **'View on the web'**
  String get label_web;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// Short label for product list view: the compatibility of that product with your preferences is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Label for product page regarding product compatibility with the user preferences: very good match
  ///
  /// In en, this message translates to:
  /// **'Very good match'**
  String get match_very_good;

  /// Label for product page regarding product compatibility with the user preferences: good match
  ///
  /// In en, this message translates to:
  /// **'Good match'**
  String get match_good;

  /// Label for product page regarding product compatibility with the user preferences: poor match
  ///
  /// In en, this message translates to:
  /// **'Poor match'**
  String get match_poor;

  /// Label for product page regarding product compatibility with the user preferences: may not match
  ///
  /// In en, this message translates to:
  /// **'May not match'**
  String get match_may_not;

  /// Label for product page regarding product compatibility with the user preferences: does not match
  ///
  /// In en, this message translates to:
  /// **'Does not match'**
  String get match_does_not;

  /// Label for product page regarding product compatibility with the user preferences: unknown match
  ///
  /// In en, this message translates to:
  /// **'Unknown match'**
  String get match_unknown;

  /// Short label for product list view regarding product compatibility with the user preferences: very good match
  ///
  /// In en, this message translates to:
  /// **'Very good match'**
  String get match_short_very_good;

  /// Short label for product list view regarding product compatibility with the user preferences: good match
  ///
  /// In en, this message translates to:
  /// **'Good match'**
  String get match_short_good;

  /// Short label for product list view regarding product compatibility with the user preferences: poor match
  ///
  /// In en, this message translates to:
  /// **'Poor match'**
  String get match_short_poor;

  /// Short label for product list view regarding product compatibility with the user preferences: may not match
  ///
  /// In en, this message translates to:
  /// **'May not match'**
  String get match_short_may_not;

  /// Short label for product list view regarding product compatibility with the user preferences: does not match
  ///
  /// In en, this message translates to:
  /// **'Does not match'**
  String get match_short_does_not;

  /// Short label for product list view regarding product compatibility with the user preferences: unknown match
  ///
  /// In en, this message translates to:
  /// **'Unknown match'**
  String get match_short_unknown;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get licenses;

  /// Looking for: BARCODE
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get looking_for;

  /// No description provided for @welcomeToOpenFoodFacts.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Open Food Facts'**
  String get welcomeToOpenFoodFacts;

  /// Description of Open Food Facts organization.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts is a global non-profit powered by local communities.'**
  String get whatIsOff;

  /// Description of what a user can use the product data for.
  ///
  /// In en, this message translates to:
  /// **'See the food data relevant to your preferences.'**
  String get productDataUtility;

  /// Description of what a user can use the health data in a product for.
  ///
  /// In en, this message translates to:
  /// **'Choose foods that are good for you.'**
  String get healthCardUtility;

  /// Description of what a user can use the Eco data in a product for.
  ///
  /// In en, this message translates to:
  /// **'Choose foods that are good for the planet.'**
  String get ecoCardUtility;

  /// No description provided for @server_error_open_new_issue.
  ///
  /// In en, this message translates to:
  /// **'No server response! You may open an issue with the following link.'**
  String get server_error_open_new_issue;

  /// No description provided for @sign_in_text.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Open Food Facts account to save your contributions'**
  String get sign_in_text;

  /// No description provided for @incorrect_credentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password.'**
  String get incorrect_credentials;

  /// No description provided for @password_lost_incorrect_credentials.
  ///
  /// In en, this message translates to:
  /// **'This email or username doesn\'t exist. Please check your credentials.'**
  String get password_lost_incorrect_credentials;

  /// No description provided for @password_lost_server_unavailable.
  ///
  /// In en, this message translates to:
  /// **'We are currently experiencing slowdowns on our servers and we apologise for it. Please try again later.'**
  String get password_lost_server_unavailable;

  /// Text field hint: unified name for either username or e-mail address
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Error message when trying to log in without network
  ///
  /// In en, this message translates to:
  /// **'Network is unreachable'**
  String get login_result_type_server_unreachable;

  /// Error message when trying to log in and the server does not answer correctly
  ///
  /// In en, this message translates to:
  /// **'Problem on the server. Please try later.'**
  String get login_result_type_server_issue;

  /// No description provided for @login_page_username_or_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter username or e-mail'**
  String get login_page_username_or_email;

  /// No description provided for @login_page_password_error_empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get login_page_password_error_empty;

  /// Button label: Opens a page where a new user can register
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get create_account;

  /// Button label: For sign in
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sign_in;

  /// Error message: for some features like product edits you need to be signed in
  ///
  /// In en, this message translates to:
  /// **'For that feature we need you to sign in.'**
  String get sign_in_mandatory;

  /// label for a tile that is on the contribute tile
  ///
  /// In en, this message translates to:
  /// **'Help improve Open Food Facts in your country'**
  String get help_improve_country;

  /// Button label: For sign out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get sign_out;

  /// Pop up title: Reassuring if the user really want to sign out
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get sign_out_confirmation;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Button label: Opens a page where a password reset e-mail can be requested
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgot_password;

  /// Button label: For to show your account
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get view_profile;

  /// Forgot password page title
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get reset_password;

  /// No description provided for @reset_password_explanation_text.
  ///
  /// In en, this message translates to:
  /// **'In case of a forgotten password, enter your username or e-mail address to receive instructions for a password reset. Also, remember to check the Spam folder.'**
  String get reset_password_explanation_text;

  /// Text field hint for password reset
  ///
  /// In en, this message translates to:
  /// **'Username or e-mail'**
  String get username_or_email;

  /// No description provided for @reset_password_done.
  ///
  /// In en, this message translates to:
  /// **'An e-mail with a link to reset your password has been sent to the e-mail address associated with your account. Also check your spam'**
  String get reset_password_done;

  /// Button label: Submit the password reset e-mail request
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get send_reset_password_mail;

  /// Error when a required text field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter some text'**
  String get enter_some_text;

  /// Header
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up_page_title;

  /// Button for signing up
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up_page_action_button;

  /// Progress indicator dialog during the actual signing up process
  ///
  /// In en, this message translates to:
  /// **'Signing up…'**
  String get sign_up_page_action_doing_it;

  /// No description provided for @sign_up_page_action_ok.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your account has just been created.'**
  String get sign_up_page_action_ok;

  /// No description provided for @sign_up_page_display_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sign_up_page_display_name_hint;

  /// No description provided for @sign_up_page_display_name_error_empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter the display name you want to use'**
  String get sign_up_page_display_name_error_empty;

  /// No description provided for @sign_up_page_email_hint.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get sign_up_page_email_hint;

  /// No description provided for @sign_up_page_email_error_empty.
  ///
  /// In en, this message translates to:
  /// **'E-mail is required'**
  String get sign_up_page_email_error_empty;

  /// No description provided for @sign_up_page_email_error_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid e-mail'**
  String get sign_up_page_email_error_invalid;

  /// No description provided for @sign_up_page_username_hint.
  ///
  /// In en, this message translates to:
  /// **'Username: Publicly visible'**
  String get sign_up_page_username_hint;

  /// No description provided for @sign_up_page_username_error_empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get sign_up_page_username_error_empty;

  /// No description provided for @sign_up_page_username_error_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid username'**
  String get sign_up_page_username_error_invalid;

  /// No description provided for @sign_up_page_username_description.
  ///
  /// In en, this message translates to:
  /// **'Username cannot contains spaces, caps or special characters.'**
  String get sign_up_page_username_description;

  /// No description provided for @sign_up_page_username_length_invalid.
  ///
  /// In en, this message translates to:
  /// **'Username cannot exceed {value} characters'**
  String sign_up_page_username_length_invalid(int value);

  /// No description provided for @sign_up_page_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get sign_up_page_password_hint;

  /// No description provided for @sign_up_page_password_error_empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get sign_up_page_password_error_empty;

  /// No description provided for @sign_up_page_password_error_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid password (at least 6 characters)'**
  String get sign_up_page_password_error_invalid;

  /// No description provided for @sign_up_page_confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get sign_up_page_confirm_password_hint;

  /// No description provided for @sign_up_page_confirm_password_error_empty.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the password'**
  String get sign_up_page_confirm_password_error_empty;

  /// No description provided for @sign_up_page_confirm_password_error_invalid.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get sign_up_page_confirm_password_error_invalid;

  /// I agree to the Open Food Facts is followed by sign_up_page_terms_text
  ///
  /// In en, this message translates to:
  /// **'I agree to the Open Food Facts'**
  String get sign_up_page_agree_text;

  /// terms of use and contribution is preceded by sign_up_page_agree_text
  ///
  /// In en, this message translates to:
  /// **'terms of use and contribution'**
  String get sign_up_page_terms_text;

  /// Please insert the right url here. Go to the Open Food Facts homepage, switch to your country and then on the bottom left footer is Terms of use from which the url should be taken
  ///
  /// In en, this message translates to:
  /// **'https://world-en.openfoodfacts.org/terms-of-use'**
  String get sign_up_page_agree_url;

  /// Please insert the right url from the website here.
  ///
  /// In en, this message translates to:
  /// **'https://donate.openfoodfacts.org/'**
  String get donate_url;

  /// Error message: You have to agree to the terms-of-use (A checkbox to do so is above this error message)
  ///
  /// In en, this message translates to:
  /// **'When creating an account, agreeing to the Terms of Use is mandatory, however, anonymous contributions can still be made through the app'**
  String get sign_up_page_agree_error_invalid;

  /// No description provided for @sign_up_page_producer_checkbox.
  ///
  /// In en, this message translates to:
  /// **'I am a food producer'**
  String get sign_up_page_producer_checkbox;

  /// No description provided for @sign_up_page_producer_hint.
  ///
  /// In en, this message translates to:
  /// **'Producer/brand'**
  String get sign_up_page_producer_hint;

  /// No description provided for @sign_up_page_producer_error_empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a producer or a brand name'**
  String get sign_up_page_producer_error_empty;

  /// No description provided for @sign_up_page_subscribe_checkbox.
  ///
  /// In en, this message translates to:
  /// **'I\'d like to subscribe to the Open Food Facts newsletter (You can unsubscribe from it at any time)'**
  String get sign_up_page_subscribe_checkbox;

  /// No description provided for @sign_up_page_user_name_already_used.
  ///
  /// In en, this message translates to:
  /// **'The user name already exists, please choose another username.'**
  String get sign_up_page_user_name_already_used;

  /// No description provided for @sign_up_page_email_already_exists.
  ///
  /// In en, this message translates to:
  /// **'already exists, login to the account or try with another email.'**
  String get sign_up_page_email_already_exists;

  /// No description provided for @sign_up_page_provide_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid email address.'**
  String get sign_up_page_provide_valid_email;

  /// No description provided for @sign_up_page_server_busy.
  ///
  /// In en, this message translates to:
  /// **'We are deeply sorry, we have some technical difficulties to create your account. Please try again later.'**
  String get sign_up_page_server_busy;

  /// The title of the Settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// The name of the darkmode on off switch
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get darkmode;

  /// Indicator inside the darkmode switch (dark)
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkmode_dark;

  /// Indicator inside the darkmode switch (light)
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get darkmode_light;

  /// Indicator inside the darkmode switch (system default)
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get darkmode_system_default;

  /// No description provided for @thanks_for_contributing.
  ///
  /// In en, this message translates to:
  /// **'Thanks for contributing!'**
  String get thanks_for_contributing;

  /// Button label: Opens a pop up window where all contributors of this app are shown
  ///
  /// In en, this message translates to:
  /// **'They are building the app'**
  String get contributors_label;

  /// Dialog title: A list of all contributors of this app
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get contributors_dialog_title;

  /// The user id of the contributor.
  ///
  /// In en, this message translates to:
  /// **'Contributor: {name}'**
  String contributors_dialog_entry_description(Object name);

  /// Button description for accessibility purposes to explain what the Contributors button do
  ///
  /// In en, this message translates to:
  /// **'A list of all contributors of this app'**
  String get contributors_description;

  /// Button label: Opens a pop up window where all ways to get support are shown
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @support_join_slack.
  ///
  /// In en, this message translates to:
  /// **'Ask for help in our Slack channel'**
  String get support_join_slack;

  /// No description provided for @support_via_forum.
  ///
  /// In en, this message translates to:
  /// **'Ask for help on our forum'**
  String get support_via_forum;

  /// No description provided for @support_via_email.
  ///
  /// In en, this message translates to:
  /// **'Send us an e-mail'**
  String get support_via_email;

  /// No description provided for @support_via_email_include_logs_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Send app logs?'**
  String get support_via_email_include_logs_dialog_title;

  /// No description provided for @support_via_email_include_logs_dialog_body.
  ///
  /// In en, this message translates to:
  /// **'Do you wish to include application logs in attachment to your email?'**
  String get support_via_email_include_logs_dialog_body;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// A link to open the legal notices on the website
  ///
  /// In en, this message translates to:
  /// **'Legal notices'**
  String get legalNotices;

  /// A link to open the privacy policy on the website
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy_policy;

  /// Button label: Opens a pop up window which shows information about the app
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get about_this_app;

  /// Button label: Shows multiple ways how users can contribute to OFF
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// Button label + page title: Ways to help
  ///
  /// In en, this message translates to:
  /// **'Software development'**
  String get contribute_sw_development;

  /// No description provided for @contribute_develop_text.
  ///
  /// In en, this message translates to:
  /// **'The code for every Open Food Facts product is available on GitHub. You are welcome to reuse the code (it\'s open source) and help us improve it, for everyone, on all the planet.'**
  String get contribute_develop_text;

  /// No description provided for @contribute_develop_text_2.
  ///
  /// In en, this message translates to:
  /// **'You can join the Open Food Facts Slack chatroom which is the preferred way to ask questions.'**
  String get contribute_develop_text_2;

  /// No description provided for @contribute_develop_dev_mode_title.
  ///
  /// In en, this message translates to:
  /// **'DEV Mode?'**
  String get contribute_develop_dev_mode_title;

  /// No description provided for @contribute_develop_dev_mode_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Activate the DEV Mode'**
  String get contribute_develop_dev_mode_subtitle;

  /// No description provided for @contribute_donate_title.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get contribute_donate_title;

  /// No description provided for @contribute_donate_header.
  ///
  /// In en, this message translates to:
  /// **'Donate to Open Food Facts'**
  String get contribute_donate_header;

  /// No description provided for @contribute_enroll_alpha.
  ///
  /// In en, this message translates to:
  /// **'Enroll in internal alpha version'**
  String get contribute_enroll_alpha;

  /// No description provided for @contribute_enroll_alpha_warning.
  ///
  /// In en, this message translates to:
  /// **'Please acknowledge that with the internal alpha version, complete loss of data is possible, and the app may become unusable at any time !'**
  String get contribute_enroll_alpha_warning;

  /// Button label: Shows a list of products which aren't completed
  ///
  /// In en, this message translates to:
  /// **'Products to be completed'**
  String get contribute_improve_ProductsToBeCompleted;

  /// Button label + page title: Ways to improve the database
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get contribute_improve_header;

  /// No description provided for @contribute_improve_text.
  ///
  /// In en, this message translates to:
  /// **'The database is the core of the project. It\'s easy and very quick to help. You can download the mobile app for your phone, and start adding or improving products.\n\nOn the other hand, Open Food Facts website offers many ways to contribute: '**
  String get contribute_improve_text;

  /// Button label + pop up window title: Shows information about helping by translating
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get contribute_translate_header;

  /// label for a tile that is on the contribute page linking to the Data Quality wiki page
  ///
  /// In en, this message translates to:
  /// **'Data Quality'**
  String get contribute_data_quality;

  /// Button label: Opens the Crowdin translation portal
  ///
  /// In en, this message translates to:
  /// **'Start Translating'**
  String get contribute_translate_link_text;

  /// No description provided for @contribute_translate_text.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts is a global project, containing products from more than 160 countries. Open Food Facts is translated into dozens of languages, with constantly evolving content.'**
  String get contribute_translate_text;

  /// No description provided for @contribute_translate_text_2.
  ///
  /// In en, this message translates to:
  /// **'Translations is one of the key tasks of the project'**
  String get contribute_translate_text_2;

  /// No description provided for @contribute_join_skill_pool.
  ///
  /// In en, this message translates to:
  /// **'Contribute your skills to Open Food Facts. Join the skill pool!'**
  String get contribute_join_skill_pool;

  /// No description provided for @contribute_share_header.
  ///
  /// In en, this message translates to:
  /// **'Share Open Food Facts with your friends'**
  String get contribute_share_header;

  /// Content that will be shared, don't forget to include the URL
  ///
  /// In en, this message translates to:
  /// **'I wanted to let you know about the app I\'ve been using, Open Food Facts, which allows you to get the health and environmental impacts of your food, in a personalized way. It works by scanning the barcodes on the packaging. Finally it\'s free, does not require registration, and you can even help increase the number of products decyphered. Here\'s the link to get it for your phone: https://openfoodfacts.app'**
  String get contribute_share_content;

  /// Label for option to contribute prices using GDPR export from loyalty cards
  ///
  /// In en, this message translates to:
  /// **'Contribute prices by requesting a GDPR export of your loyalty cards data'**
  String get contribute_prices_gdpr;

  /// Button label shown on a product, clicking the button opens a card with unanswered product questions, users can answer these to contribute to Open Food Facts and gain rewards.
  ///
  /// In en, this message translates to:
  /// **'Tap here to answer questions'**
  String get tap_to_answer;

  /// Hint for accessibility readers to answer Robotoff questions.
  ///
  /// In en, this message translates to:
  /// **'Tap here to answer questions about this product'**
  String get tap_to_answer_hint;

  /// Hint for accessibility readers while Robotoff questions are loaded
  ///
  /// In en, this message translates to:
  /// **'Please wait while questions about this product are loaded'**
  String get robotoff_questions_loading_hint;

  /// Dialog shown to users after they have answered a question, while the answer is being saved in the BE.
  ///
  /// In en, this message translates to:
  /// **'Saving your answer'**
  String get saving_answer;

  /// Button description shown on a product, clicking the button opens a card with unanswered product questions, users can answer these to contribute to Open Food Facts.
  ///
  /// In en, this message translates to:
  /// **'Become an actor of food transparency'**
  String get contribute_to_get_rewards;

  /// No description provided for @question_sign_in_text.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Open Food Facts account to get credit for your contributions'**
  String get question_sign_in_text;

  /// No description provided for @question_yes_button_accessibility_value.
  ///
  /// In en, this message translates to:
  /// **'Answer with yes'**
  String get question_yes_button_accessibility_value;

  /// No description provided for @question_no_button_accessibility_value.
  ///
  /// In en, this message translates to:
  /// **'Answer with no'**
  String get question_no_button_accessibility_value;

  /// No description provided for @question_skip_button_accessibility_value.
  ///
  /// In en, this message translates to:
  /// **'Skip this question'**
  String get question_skip_button_accessibility_value;

  /// No description provided for @tap_to_edit_search.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit search'**
  String get tap_to_edit_search;

  /// Page title: Page where the ranking preferences can be changed
  ///
  /// In en, this message translates to:
  /// **'My preferences'**
  String get myPreferences;

  /// The Message to be displayed if the user does not have an account and wants to contribute
  ///
  /// In en, this message translates to:
  /// **'Create your account and join the Open Food Facts community to help build food knowledge all over the world!'**
  String get account_create_message;

  /// Join which is actually Signup
  ///
  /// In en, this message translates to:
  /// **'Join us'**
  String get join_us;

  /// No description provided for @myPreferences_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get myPreferences_profile_title;

  /// No description provided for @myPreferences_profile_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your Open Food Facts contributor account.'**
  String get myPreferences_profile_subtitle;

  /// No description provided for @myPreferences_settings_title.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get myPreferences_settings_title;

  /// No description provided for @myPreferences_settings_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark mode, Languages…'**
  String get myPreferences_settings_subtitle;

  /// No description provided for @myPreferences_food_title.
  ///
  /// In en, this message translates to:
  /// **'Food Preferences'**
  String get myPreferences_food_title;

  /// No description provided for @myPreferences_food_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what information about food matters most to you.'**
  String get myPreferences_food_subtitle;

  /// No description provided for @myPreferences_food_comment.
  ///
  /// In en, this message translates to:
  /// **'Choose what information about food matters most to you, in order to rank food according to your preferences, see the information you care about first, and get a compatibility summary. Those food preferences stay on your device, and are not associated with your Open Food Facts contributor account if you have one.'**
  String get myPreferences_food_comment;

  /// Pop up title: Reassuring if the food preferences should really be reset
  ///
  /// In en, this message translates to:
  /// **'Reset your food preferences?'**
  String get confirmResetPreferences;

  /// When you press this button, all products (in list or category) are sorted according to your preferences.
  ///
  /// In en, this message translates to:
  /// **'My personalized ranking'**
  String get myPersonalizedRanking;

  /// No description provided for @ranking_tab_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ranking_tab_all;

  /// No description provided for @ranking_subtitle_match_yes.
  ///
  /// In en, this message translates to:
  /// **'A great match for you'**
  String get ranking_subtitle_match_yes;

  /// No description provided for @ranking_subtitle_match_no.
  ///
  /// In en, this message translates to:
  /// **'Very poor match'**
  String get ranking_subtitle_match_no;

  /// No description provided for @ranking_subtitle_match_maybe.
  ///
  /// In en, this message translates to:
  /// **'Unknown match'**
  String get ranking_subtitle_match_maybe;

  /// Action button label: Refresh the list with your new preferences
  ///
  /// In en, this message translates to:
  /// **'Refresh the list with your new preferences'**
  String get refresh_with_new_preferences;

  /// Snackbar title: Shows that the modified settings have been applied
  ///
  /// In en, this message translates to:
  /// **'Reloaded with your new preferences'**
  String get reloaded_with_new_preferences;

  /// BottomNavigationBarLabel: For the profile and personal preferences page
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_navbar_label;

  /// BottomNavigationBarLabel: For the scanning of products
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan_navbar_label;

  /// BottomNavigationBarLabel: For the history and compare mode
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history_navbar_label;

  /// BottomNavigationBarLabel: For the lists
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get list_navbar_label;

  /// From a product list, there's a category filter: this is its title
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get category;

  /// No description provided for @category_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get category_all;

  /// No description provided for @category_search.
  ///
  /// In en, this message translates to:
  /// **'(category search)'**
  String get category_search;

  /// A button that opens a menu where you can filter within categories. Juices => Apple juices/Orange juices
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Page title: List type: Products in the scan session
  ///
  /// In en, this message translates to:
  /// **'Products from the Scan screen'**
  String get scan;

  /// Page title: List type: Products in the whole scan history
  ///
  /// In en, this message translates to:
  /// **'Scan history'**
  String get scan_history;

  /// Hint text of a search text input field
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Hint text of a search store text input field
  ///
  /// In en, this message translates to:
  /// **'Search for a store'**
  String get search_store;

  /// No description provided for @tap_for_more.
  ///
  /// In en, this message translates to:
  /// **'Tap to see more info…'**
  String get tap_for_more;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @unknownBrand.
  ///
  /// In en, this message translates to:
  /// **'Unknown brand'**
  String get unknownBrand;

  /// No description provided for @unknownProductName.
  ///
  /// In en, this message translates to:
  /// **'Unknown product name'**
  String get unknownProductName;

  /// Refresh the cached product
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get label_refresh;

  /// Reload a page
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get label_reload;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// Button label: For adding a picture of the front of a product
  ///
  /// In en, this message translates to:
  /// **'Front photo'**
  String get front_photo;

  /// Accessibility label for images that are outdated (image type may be front/ingredients/nutrition…)
  ///
  /// In en, this message translates to:
  /// **'{imageType} (this image may be outdated)'**
  String outdated_image_accessibility_label(Object imageType);

  /// A label for outdated images
  ///
  /// In en, this message translates to:
  /// **'may be outdated'**
  String get outdated_image_short_label;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @ingredients_editing_instructions.
  ///
  /// In en, this message translates to:
  /// **'Keep the original order. Indicate the percentage when specified. Separate with a comma or hyphen and use parentheses for ingredients of an ingredient.'**
  String get ingredients_editing_instructions;

  /// No description provided for @ingredients_editing_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to save the ingredients.'**
  String get ingredients_editing_error;

  /// No description provided for @ingredients_editing_image_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to get a new ingredients image.'**
  String get ingredients_editing_image_error;

  /// No description provided for @ingredients_editing_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredients'**
  String get ingredients_editing_title;

  /// Button label: For adding a picture of the Ingredients of a product
  ///
  /// In en, this message translates to:
  /// **'Ingredients photo'**
  String get ingredients_photo;

  /// No description provided for @packaging_editing_instructions.
  ///
  /// In en, this message translates to:
  /// **'List all packaging parts separated by a comma or line feed, with their amount (e.g. 1 or 6) type (e.g. bottle, box, can), material (e.g. plastic, metal, aluminium) and if available their size (e.g. 33cl) and recycling instructions.\nExample: 1 glass bottle to recycle, 1 plastic cork to throw away'**
  String get packaging_editing_instructions;

  /// No description provided for @packaging_editing_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to save the packaging.'**
  String get packaging_editing_error;

  /// No description provided for @packaging_editing_image_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to get a new packaging image.'**
  String get packaging_editing_image_error;

  /// No description provided for @packaging_editing_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Packaging'**
  String get packaging_editing_title;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// Button label: For adding a picture of the nutrition facts of a product
  ///
  /// In en, this message translates to:
  /// **'Nutrition facts photo'**
  String get nutrition_facts_photo;

  /// Title of the button where users can edit the nutrition facts of a product
  ///
  /// In en, this message translates to:
  /// **'Edit Nutrition Facts'**
  String get nutrition_facts_editing_title;

  /// Button label: For adding a picture of the packaging of a product
  ///
  /// In en, this message translates to:
  /// **'Packaging information'**
  String get packaging_information;

  /// No description provided for @packaging_information_photo.
  ///
  /// In en, this message translates to:
  /// **'Packaging information photo'**
  String get packaging_information_photo;

  /// No description provided for @missing_product.
  ///
  /// In en, this message translates to:
  /// **'You found a new product!'**
  String get missing_product;

  /// No description provided for @add_product_take_photos.
  ///
  /// In en, this message translates to:
  /// **'Take photos of the packaging to add this product to Open Food Facts'**
  String get add_product_take_photos;

  /// No description provided for @add_product_take_photos_descriptive.
  ///
  /// In en, this message translates to:
  /// **'Please take some photos first. You may always complete the product at a later time.'**
  String get add_product_take_photos_descriptive;

  /// No description provided for @add_product_information_button_label.
  ///
  /// In en, this message translates to:
  /// **'Add product information'**
  String get add_product_information_button_label;

  /// No description provided for @new_product.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get new_product;

  /// Title of a dialog that informs the user that a barcode doesn't exist in the database
  ///
  /// In en, this message translates to:
  /// **'New product found!'**
  String get new_product_found_title;

  /// Please keep the ** syntax to make the text bold
  ///
  /// In en, this message translates to:
  /// **'Our collaborative database contains more than **3 million products**, but this barcode doesn\'t exist: '**
  String get new_product_found_text;

  /// No description provided for @new_product_found_button.
  ///
  /// In en, this message translates to:
  /// **'Add this product'**
  String get new_product_found_button;

  /// Alert dialog title when a user landed on the 'add new product' page, didn't input anything and tried to leave the page.
  ///
  /// In en, this message translates to:
  /// **'Leave this page?'**
  String get new_product_leave_title;

  /// Alert dialog message when a user landed on the 'add new product' page, didn't input anything and tried to leave the page.
  ///
  /// In en, this message translates to:
  /// **'It looks like you didn\'t input anything. Do you really want to leave this page?'**
  String get new_product_leave_message;

  /// Please keep it short, like less than 100 characters. Explanatory text of the dialog when the user searched for an unknown barcode.
  ///
  /// In en, this message translates to:
  /// **'Please take photos of the packaging to add this product to our common database'**
  String get new_product_dialog_description;

  /// A description for accessibility of two images side by side: a Nutri-Score and an Green Score.
  ///
  /// In en, this message translates to:
  /// **'An illustration with unknown Nutri-Score and Green Score'**
  String get new_product_dialog_illustration_description;

  /// No description provided for @front_packaging_photo_button_label.
  ///
  /// In en, this message translates to:
  /// **'Front packaging photo'**
  String get front_packaging_photo_button_label;

  /// Button clicking on which confirms the picture of the front of product that user just took.
  ///
  /// In en, this message translates to:
  /// **'Confirm upload of Front packaging photo'**
  String get confirm_front_packaging_photo_button_label;

  /// No description provided for @confirm_button_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm_button_label;

  /// No description provided for @send_image_button_label.
  ///
  /// In en, this message translates to:
  /// **'Send image'**
  String get send_image_button_label;

  /// Action being performed on the crop page
  ///
  /// In en, this message translates to:
  /// **'Saving the image…'**
  String get crop_page_action_saving;

  /// Action being performed on the crop page
  ///
  /// In en, this message translates to:
  /// **'Cropping the image…'**
  String get crop_page_action_cropping;

  /// Action being performed on the crop page
  ///
  /// In en, this message translates to:
  /// **'Saving a local version…'**
  String get crop_page_action_local;

  /// No description provided for @crop_page_action_local_failed_title.
  ///
  /// In en, this message translates to:
  /// **'Oops… there\'s something with your photo!'**
  String get crop_page_action_local_failed_title;

  /// No description provided for @crop_page_action_local_failed_message.
  ///
  /// In en, this message translates to:
  /// **'We are unable to process the image locally, before sending it to our server. Please try again later or contact-us if the issue persists.'**
  String get crop_page_action_local_failed_message;

  /// Button which allows users to retake a photo.
  ///
  /// In en, this message translates to:
  /// **'Retake a photo'**
  String get crop_page_action_retake;

  /// Title of a dialog warning the user that the image is too small for upload
  ///
  /// In en, this message translates to:
  /// **'The image is too small!'**
  String get crop_page_too_small_image_title;

  /// Message of a dialog warning the user that the image is too small for upload
  ///
  /// In en, this message translates to:
  /// **'The minimum size in pixels for picture upload is {expectedMinWidth}x{expectedMinHeight}. The current picture is {actualWidth}x{actualHeight}.'**
  String crop_page_too_small_image_message(
    int expectedMinWidth,
    int expectedMinHeight,
    int actualWidth,
    int actualHeight,
  );

  /// Action being performed on the crop page
  ///
  /// In en, this message translates to:
  /// **'Preparing a call to the server…'**
  String get crop_page_action_server;

  /// No description provided for @front_packaging_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Front Packaging Photo'**
  String get front_packaging_photo_title;

  /// No description provided for @ingredients_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Ingredients Photo'**
  String get ingredients_photo_title;

  /// No description provided for @nutritional_facts_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts Photo'**
  String get nutritional_facts_photo_title;

  /// No description provided for @recycling_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Recycling Photo'**
  String get recycling_photo_title;

  /// No description provided for @take_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get take_photo_title;

  /// No description provided for @take_more_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Take more pictures'**
  String get take_more_photo_title;

  /// No description provided for @front_photo_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Front photo uploaded'**
  String get front_photo_uploaded;

  /// No description provided for @ingredients_photo_button_label.
  ///
  /// In en, this message translates to:
  /// **'Ingredients photo'**
  String get ingredients_photo_button_label;

  /// No description provided for @ingredients_photo_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Ingredients photo uploaded'**
  String get ingredients_photo_uploaded;

  /// No description provided for @nutrition_cache_loading_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to load nutrients from cache'**
  String get nutrition_cache_loading_error;

  /// No description provided for @nutritional_facts_photo_button_label.
  ///
  /// In en, this message translates to:
  /// **'Nutrition facts photo'**
  String get nutritional_facts_photo_button_label;

  /// No description provided for @nutritional_facts_input_button_label.
  ///
  /// In en, this message translates to:
  /// **'Fill nutrition facts'**
  String get nutritional_facts_input_button_label;

  /// No description provided for @nutritional_facts_added.
  ///
  /// In en, this message translates to:
  /// **'Nutrition facts added'**
  String get nutritional_facts_added;

  /// No description provided for @categories_added.
  ///
  /// In en, this message translates to:
  /// **'Categories added'**
  String get categories_added;

  /// No description provided for @new_product_title_nutriscore.
  ///
  /// In en, this message translates to:
  /// **'Compute the Nutri-Score'**
  String get new_product_title_nutriscore;

  /// No description provided for @new_product_subtitle_nutriscore.
  ///
  /// In en, this message translates to:
  /// **'Help us by filling at least a category and nutritional values'**
  String get new_product_subtitle_nutriscore;

  /// No description provided for @new_product_title_environmental_score.
  ///
  /// In en, this message translates to:
  /// **'Compute the Green Score'**
  String get new_product_title_environmental_score;

  /// No description provided for @new_product_subtitle_environmental_score.
  ///
  /// In en, this message translates to:
  /// **'Get it by filling at least a category'**
  String get new_product_subtitle_environmental_score;

  /// No description provided for @new_product_additional_environmental_score.
  ///
  /// In en, this message translates to:
  /// **'Make Green Score computation more precise with origins, packaging & more'**
  String get new_product_additional_environmental_score;

  /// No description provided for @new_product_title_nova.
  ///
  /// In en, this message translates to:
  /// **'Compute the food processing level (NOVA)'**
  String get new_product_title_nova;

  /// No description provided for @new_product_subtitle_nova.
  ///
  /// In en, this message translates to:
  /// **'Get it by filling the food category and ingredients'**
  String get new_product_subtitle_nova;

  /// No description provided for @new_product_desc_nova_unknown.
  ///
  /// In en, this message translates to:
  /// **'Food processing level unknown'**
  String get new_product_desc_nova_unknown;

  /// No description provided for @new_product_title_pictures.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get new_product_title_pictures;

  /// No description provided for @new_product_title_pictures_details.
  ///
  /// In en, this message translates to:
  /// **'Please take the following photos and the Open Food Facts engine can work out the rest!'**
  String get new_product_title_pictures_details;

  /// No description provided for @new_product_title_misc.
  ///
  /// In en, this message translates to:
  /// **'And some basic data…'**
  String get new_product_title_misc;

  /// Thank you message on the end of new product page, after finish adding a new product.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your contribution “{username}”!'**
  String new_product_done_msg(String username);

  /// No description provided for @new_product_done_msg_no_user.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your contribution!'**
  String get new_product_done_msg_no_user;

  /// Button at the end of new product page, that takes you to completed product
  ///
  /// In en, this message translates to:
  /// **'Discover the completed product'**
  String get new_product_done_button_label;

  /// No description provided for @hey_incomplete_product_message.
  ///
  /// In en, this message translates to:
  /// **'Tap to answer 3 questions NOW to compute Nutri-Score, Green Score & Ultra-processing (NOVA)!'**
  String get hey_incomplete_product_message;

  /// No description provided for @hey_incomplete_product_message_beauty.
  ///
  /// In en, this message translates to:
  /// **'Tap now to answer 2 questions to help analyze this cosmetic!'**
  String get hey_incomplete_product_message_beauty;

  /// No description provided for @hey_incomplete_product_message_pet_food.
  ///
  /// In en, this message translates to:
  /// **'Tap now to answer 3 questions to help analyze this pet food product!'**
  String get hey_incomplete_product_message_pet_food;

  /// No description provided for @hey_incomplete_product_message_product.
  ///
  /// In en, this message translates to:
  /// **'Tap now to help complete this product!'**
  String get hey_incomplete_product_message_product;

  /// No description provided for @nutritional_facts_photo_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Nutrition facts photo uploaded'**
  String get nutritional_facts_photo_uploaded;

  /// No description provided for @recycling_photo_button_label.
  ///
  /// In en, this message translates to:
  /// **'Recycling photo'**
  String get recycling_photo_button_label;

  /// No description provided for @recycling_photo_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Recycling photo uploaded'**
  String get recycling_photo_uploaded;

  /// No description provided for @take_more_photo_button_label.
  ///
  /// In en, this message translates to:
  /// **'Take more pictures'**
  String get take_more_photo_button_label;

  /// No description provided for @other_photo_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous photo uploaded'**
  String get other_photo_uploaded;

  /// Button clicking on which allows users to retake the last photo they took.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake_photo_button_label;

  /// Progress indicator when the users takes a photo
  ///
  /// In en, this message translates to:
  /// **'Selecting photo'**
  String get selecting_photo;

  /// Message when a new picture is uploading to the server
  ///
  /// In en, this message translates to:
  /// **'Uploading photo to the server'**
  String get uploading_image;

  /// Message when a new front picture is being uploaded to the server
  ///
  /// In en, this message translates to:
  /// **'Uploading front image to Open Food Facts'**
  String get uploading_image_type_front;

  /// Message when a new ingredients picture is being uploaded to the server
  ///
  /// In en, this message translates to:
  /// **'Uploading ingredients image to Open Food Facts'**
  String get uploading_image_type_ingredients;

  /// Message when a new nutrition picture is being uploaded to the server
  ///
  /// In en, this message translates to:
  /// **'Uploading nutrition image to Open Food Facts'**
  String get uploading_image_type_nutrition;

  /// Message when a new packaging picture is being uploaded to the server
  ///
  /// In en, this message translates to:
  /// **'Uploading packaging image to Open Food Facts'**
  String get uploading_image_type_packaging;

  /// Message when a new other picture is being uploaded to the server
  ///
  /// In en, this message translates to:
  /// **'Uploading other image to Open Food Facts'**
  String get uploading_image_type_other;

  /// Message when a new picture is being uploaded to the server
  ///
  /// In en, this message translates to:
  /// **'Uploading image to Open Food Facts'**
  String get uploading_image_type_generic;

  /// No description provided for @score_add_missing_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Add missing ingredients'**
  String get score_add_missing_ingredients;

  /// No description provided for @score_add_missing_packaging_image.
  ///
  /// In en, this message translates to:
  /// **'Add missing packaging image'**
  String get score_add_missing_packaging_image;

  /// No description provided for @score_add_missing_nutrition_facts.
  ///
  /// In en, this message translates to:
  /// **'Add missing nutrition facts'**
  String get score_add_missing_nutrition_facts;

  /// No description provided for @score_add_missing_product_traces.
  ///
  /// In en, this message translates to:
  /// **'Add missing product traces'**
  String get score_add_missing_product_traces;

  /// No description provided for @score_add_missing_product_category.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get score_add_missing_product_category;

  /// No description provided for @score_add_missing_product_countries.
  ///
  /// In en, this message translates to:
  /// **'Add missing product countries'**
  String get score_add_missing_product_countries;

  /// No description provided for @score_add_missing_product_emb.
  ///
  /// In en, this message translates to:
  /// **'Add missing product traceability codes'**
  String get score_add_missing_product_emb;

  /// No description provided for @score_add_missing_product_labels.
  ///
  /// In en, this message translates to:
  /// **'Add missing product labels'**
  String get score_add_missing_product_labels;

  /// No description provided for @score_add_missing_product_origins.
  ///
  /// In en, this message translates to:
  /// **'Add missing product origins'**
  String get score_add_missing_product_origins;

  /// No description provided for @score_add_missing_product_stores.
  ///
  /// In en, this message translates to:
  /// **'Add missing product stores'**
  String get score_add_missing_product_stores;

  /// No description provided for @score_add_missing_product_brands.
  ///
  /// In en, this message translates to:
  /// **'Add missing product brands'**
  String get score_add_missing_product_brands;

  /// No description provided for @score_update_nutrition_facts.
  ///
  /// In en, this message translates to:
  /// **'Update nutrition facts'**
  String get score_update_nutrition_facts;

  /// No description provided for @nutrition_page_title.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts'**
  String get nutrition_page_title;

  /// No description provided for @nutrition_page_nutritional_info_title.
  ///
  /// In en, this message translates to:
  /// **'Nutritional information'**
  String get nutrition_page_nutritional_info_title;

  /// No description provided for @nutrition_page_nutritional_info_label.
  ///
  /// In en, this message translates to:
  /// **'Values specified on the product:'**
  String get nutrition_page_nutritional_info_label;

  /// No description provided for @nutrition_page_nutritional_info_value_positive.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get nutrition_page_nutritional_info_value_positive;

  /// No description provided for @nutrition_page_nutritional_info_value_negative.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get nutrition_page_nutritional_info_value_negative;

  /// No description provided for @nutrition_page_nutritional_info_open_photo.
  ///
  /// In en, this message translates to:
  /// **'Open photo'**
  String get nutrition_page_nutritional_info_open_photo;

  /// Title for the help section about Nutritional information
  ///
  /// In en, this message translates to:
  /// **'Good practices: Nutritional information'**
  String get nutrition_page_nutritional_info_explanation_title;

  /// Text explaining when to set the nutritional information to NO
  ///
  /// In en, this message translates to:
  /// **'Sometimes nutrition facts are **not specified on the packaging** or on a document given with the product. In this case, and only in this case, you can set the value to **NO**.'**
  String get nutrition_page_nutritional_info_explanation_info1;

  /// Label to let the user choose between per 100g or per serving
  ///
  /// In en, this message translates to:
  /// **'Nutritional values:'**
  String get nutrition_page_serving_type_label;

  /// No description provided for @nutrition_page_per_100g.
  ///
  /// In en, this message translates to:
  /// **'per 100g'**
  String get nutrition_page_per_100g;

  /// No description provided for @nutrition_page_per_100g_100ml.
  ///
  /// In en, this message translates to:
  /// **'per 100g/ml'**
  String get nutrition_page_per_100g_100ml;

  /// No description provided for @nutrition_page_per_serving.
  ///
  /// In en, this message translates to:
  /// **'per serving'**
  String get nutrition_page_per_serving;

  /// No description provided for @nutrition_page_add_nutrient.
  ///
  /// In en, this message translates to:
  /// **'Add a nutrient'**
  String get nutrition_page_add_nutrient;

  /// No description provided for @nutrition_page_serving_size.
  ///
  /// In en, this message translates to:
  /// **'Serving size'**
  String get nutrition_page_serving_size;

  /// No description provided for @nutrition_page_serving_size_hint.
  ///
  /// In en, this message translates to:
  /// **'Input a serving size (eg: 100g)'**
  String get nutrition_page_serving_size_hint;

  /// Title for the help section about Nutritional information
  ///
  /// In en, this message translates to:
  /// **'Good practices: Serving size'**
  String get nutrition_page_serving_size_explanation_title;

  /// Text explaining why the serving size is important
  ///
  /// In en, this message translates to:
  /// **'This value helps to **make a proportional calculation of each nutrient per serving size**.'**
  String get nutrition_page_serving_size_explanation_info1;

  /// Text explaining why the serving size is important
  ///
  /// In en, this message translates to:
  /// **'**Allowed units** are: kg, g, mg, µg, oz, l, dl, cl, ml, fl.oz, fl oz, г, мг, кг, л, дл, кл, мл, 毫克, 公斤, 毫升, 公升, 吨.'**
  String get nutrition_page_serving_size_explanation_info2;

  /// Example of a correct serving size
  ///
  /// In en, this message translates to:
  /// **'**60 g**, **60g** or **60 G** (prefer the first one)'**
  String get nutrition_page_serving_size_explanation_good_example1;

  /// Example of a correct serving size
  ///
  /// In en, this message translates to:
  /// **'**1000 ml** or **1L**'**
  String get nutrition_page_serving_size_explanation_good_example2;

  /// Example of an incorrect serving size
  ///
  /// In en, this message translates to:
  /// **'Invalid unit'**
  String get nutrition_page_serving_size_explanation_bad_example1_explanation;

  /// Example of an incorrect serving size
  ///
  /// In en, this message translates to:
  /// **'30 **gr**'**
  String get nutrition_page_serving_size_explanation_bad_example1_example;

  /// Example of an incorrect serving size
  ///
  /// In en, this message translates to:
  /// **'Invalid units'**
  String get nutrition_page_serving_size_explanation_bad_example2_explanation;

  /// Example of an incorrect serving size
  ///
  /// In en, this message translates to:
  /// **'9 **candies** and 2 **biscuits**'**
  String get nutrition_page_serving_size_explanation_bad_example2_example;

  /// Example of an incorrect serving size
  ///
  /// In en, this message translates to:
  /// **'Missing unit'**
  String get nutrition_page_serving_size_explanation_bad_example3_explanation;

  /// Example of an incorrect serving size
  ///
  /// In en, this message translates to:
  /// **'**30**'**
  String get nutrition_page_serving_size_explanation_bad_example3_example;

  /// No description provided for @nutrition_page_invalid_number.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get nutrition_page_invalid_number;

  /// No description provided for @nutrition_page_update_running.
  ///
  /// In en, this message translates to:
  /// **'Updating the product on the server…'**
  String get nutrition_page_update_running;

  /// No description provided for @nutrition_page_update_done.
  ///
  /// In en, this message translates to:
  /// **'Product updated!'**
  String get nutrition_page_update_done;

  /// Button label: Use the product quantity as serving size (nutrition page)
  ///
  /// In en, this message translates to:
  /// **'Use the product quantity as serving size'**
  String get nutrition_page_take_serving_size_from_product_quantity;

  /// Error message when the nutrition facts photo can't be loaded
  ///
  /// In en, this message translates to:
  /// **'Unable to load the photo'**
  String get nutrition_page_photo_error;

  /// No description provided for @more_photos.
  ///
  /// In en, this message translates to:
  /// **'More interesting photos'**
  String get more_photos;

  /// No description provided for @view_more_photo_button.
  ///
  /// In en, this message translates to:
  /// **'View all existing photos for this product'**
  String get view_more_photo_button;

  /// No description provided for @no_product_found.
  ///
  /// In en, this message translates to:
  /// **'No product found'**
  String get no_product_found;

  /// No description provided for @no_location_found.
  ///
  /// In en, this message translates to:
  /// **'No location found'**
  String get no_location_found;

  /// No description provided for @not_found.
  ///
  /// In en, this message translates to:
  /// **'not found:'**
  String get not_found;

  /// Confirmation, that the product data of a cached product is queried again
  ///
  /// In en, this message translates to:
  /// **'Refreshing product'**
  String get refreshing_product;

  /// Confirmation, that the product data refresh is done
  ///
  /// In en, this message translates to:
  /// **'Product refreshed'**
  String get product_refreshed;

  /// No description provided for @product_image_accessibility_label.
  ///
  /// In en, this message translates to:
  /// **'Image taken on {date}'**
  String product_image_accessibility_label(String date);

  /// No description provided for @product_image_outdated_accessibility_label.
  ///
  /// In en, this message translates to:
  /// **'Image taken on {date}. This image may be outdated'**
  String product_image_outdated_accessibility_label(String date);

  /// No description provided for @product_image_outdated.
  ///
  /// In en, this message translates to:
  /// **'This image may be outdated'**
  String get product_image_outdated;

  /// No description provided for @product_image_outdated_explanations_title.
  ///
  /// In en, this message translates to:
  /// **'This image may be outdated'**
  String get product_image_outdated_explanations_title;

  /// Please keep the ** syntax to make the text bold
  ///
  /// In en, this message translates to:
  /// **'This image was taken more than a year ago.\n**Please check that\'s it\'s still up-to-date**.\n\nThis is **just a warning**. If the content is still the same, you can ignore this message.'**
  String get product_image_outdated_explanations_content;

  /// Action on the photo gallery to replace an existing picture
  ///
  /// In en, this message translates to:
  /// **'Replace photo ({type})'**
  String product_image_action_replace_photo(String type);

  /// Action on the photo gallery to add a photo (eg: ingredients)
  ///
  /// In en, this message translates to:
  /// **'Add a photo ({type})'**
  String product_image_action_add_photo(String type);

  /// Replace the existing picture with a new one
  ///
  /// In en, this message translates to:
  /// **'Take a new picture'**
  String get product_image_action_take_new_picture;

  /// Take a picture (eg: for ingredients) when there is no one
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get product_image_action_take_picture;

  /// Replace the existing picture with one from the device's gallery
  ///
  /// In en, this message translates to:
  /// **'Select from your phone\'s gallery'**
  String get product_image_action_from_gallery;

  /// Replace the existing picture with one from the product's photos
  ///
  /// In en, this message translates to:
  /// **'Select from the product photos'**
  String get product_image_action_choose_existing_photo;

  /// Label for the photo details
  ///
  /// In en, this message translates to:
  /// **'Information about the photo'**
  String get product_image_details_label;

  /// Text to indicate that the image was taken by the producer
  ///
  /// In en, this message translates to:
  /// **'From the producer'**
  String get product_image_details_from_producer;

  /// The name of the contributor who uploaded the image
  ///
  /// In en, this message translates to:
  /// **'Contributor'**
  String get product_image_details_contributor;

  /// The name of the contributor (and also the owner field) who uploaded the image
  ///
  /// In en, this message translates to:
  /// **'Contributor (producer)'**
  String get product_image_details_contributor_producer;

  /// Text to indicate the date of the image
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get product_image_details_date;

  /// Text to indicate the date of the image is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get product_image_details_date_unknown;

  /// Description for accessibility of the Open Food Facts logo on the homepage
  ///
  /// In en, this message translates to:
  /// **'Welcome to Open Food Facts'**
  String get homepage_main_card_logo_description;

  /// Text between asterisks (eg: **My Text**) means text in bold. Please keep it.
  ///
  /// In en, this message translates to:
  /// **'**Scan** a barcode or\n**search** for a product'**
  String get homepage_main_card_subheading;

  /// No description provided for @homepage_main_card_search_field_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for a product'**
  String get homepage_main_card_search_field_hint;

  /// Description for accessibility of the search field on the homepage
  ///
  /// In en, this message translates to:
  /// **'Start search'**
  String get homepage_main_card_search_field_tooltip;

  /// Accessibility label for the title of a news
  ///
  /// In en, this message translates to:
  /// **'Latest news: {news_title}'**
  String scan_tagline_news_item_accessibility(String news_title);

  /// No description provided for @tagline_app_review.
  ///
  /// In en, this message translates to:
  /// **'Do you like the app?'**
  String get tagline_app_review;

  /// No description provided for @tagline_app_review_button_positive.
  ///
  /// In en, this message translates to:
  /// **'I love it! 😍'**
  String get tagline_app_review_button_positive;

  /// No description provided for @tagline_app_review_button_negative.
  ///
  /// In en, this message translates to:
  /// **'Not really…'**
  String get tagline_app_review_button_negative;

  /// No description provided for @tagline_app_review_button_later.
  ///
  /// In en, this message translates to:
  /// **'Ask me later'**
  String get tagline_app_review_button_later;

  /// No description provided for @tagline_feed_news_button.
  ///
  /// In en, this message translates to:
  /// **'Know more'**
  String get tagline_feed_news_button;

  /// No description provided for @app_review_negative_modal_title.
  ///
  /// In en, this message translates to:
  /// **'You don\'t like our app?'**
  String get app_review_negative_modal_title;

  /// No description provided for @app_review_negative_modal_text.
  ///
  /// In en, this message translates to:
  /// **'Could you take a few seconds to tell us why?'**
  String get app_review_negative_modal_text;

  /// No description provided for @app_review_negative_modal_positive_button.
  ///
  /// In en, this message translates to:
  /// **'Yes, absolutely!'**
  String get app_review_negative_modal_positive_button;

  /// No description provided for @app_review_negative_modal_negative_button.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get app_review_negative_modal_negative_button;

  /// The product data couldn't be refreshed
  ///
  /// In en, this message translates to:
  /// **'Could not refresh product'**
  String get could_not_refresh;

  /// No description provided for @product_internet_error_modal_title.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred!'**
  String get product_internet_error_modal_title;

  /// No description provided for @product_internet_error_modal_message.
  ///
  /// In en, this message translates to:
  /// **'We are unable to fetch information about this product due to a network error. Please check your internet connection and try again.\n\nInternal error:\n{error}'**
  String product_internet_error_modal_message(String error);

  /// The title for showing product properties, aka folksonomy data
  ///
  /// In en, this message translates to:
  /// **'Product properties'**
  String get product_tags_title;

  /// Message to show if there are no product properties found
  ///
  /// In en, this message translates to:
  /// **'No product properties found. Properties can be used to describe products in more details, in a flexible way.'**
  String get no_product_tags_found_message;

  /// No description provided for @add_tag.
  ///
  /// In en, this message translates to:
  /// **'Add a property'**
  String get add_tag;

  /// No description provided for @add_tags.
  ///
  /// In en, this message translates to:
  /// **'Add properties'**
  String get add_tags;

  /// No description provided for @add_edit_tags.
  ///
  /// In en, this message translates to:
  /// **'Add or edit properties'**
  String get add_edit_tags;

  /// No description provided for @edit_tag.
  ///
  /// In en, this message translates to:
  /// **'Edit property'**
  String get edit_tag;

  /// No description provided for @remove_tag.
  ///
  /// In en, this message translates to:
  /// **'Remove property'**
  String get remove_tag;

  /// No description provided for @tag_key.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get tag_key;

  /// No description provided for @tag_key_uneditable.
  ///
  /// In en, this message translates to:
  /// **'Property (uneditable)'**
  String get tag_key_uneditable;

  /// No description provided for @tag_key_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Input a property'**
  String get tag_key_input_hint;

  /// No description provided for @tag_value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get tag_value;

  /// No description provided for @tag_value_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Input a value'**
  String get tag_value_input_hint;

  /// No description provided for @tag_key_item.
  ///
  /// In en, this message translates to:
  /// **'Property:'**
  String get tag_key_item;

  /// No description provided for @tag_value_item.
  ///
  /// In en, this message translates to:
  /// **'Value:'**
  String get tag_value_item;

  /// No description provided for @tag_key_explanations.
  ///
  /// In en, this message translates to:
  /// **'A key must be lowercase and without any spaces.'**
  String get tag_key_explanations;

  /// No description provided for @tag_key_already_exists.
  ///
  /// In en, this message translates to:
  /// **'A tag with a property {property} already exists!'**
  String tag_key_already_exists(String property);

  /// No description provided for @product_internet_error.
  ///
  /// In en, this message translates to:
  /// **'Impossible to fetch information about this product due to a network error.'**
  String get product_internet_error;

  /// Cached results from: x time ago (time ago should not be added to the string)
  ///
  /// In en, this message translates to:
  /// **'Show results from:'**
  String get cached_results_from;

  /// Button looking for the other products within the same category. Less than 30 characters
  ///
  /// In en, this message translates to:
  /// **'Compare to Category'**
  String get product_search_same_category;

  /// Button looking for the other products within the same category. Just the verb compare
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get product_search_same_category_short;

  /// Button looking for the other products within the same category. Just the verb compare
  ///
  /// In en, this message translates to:
  /// **'This feature can only be used for products with a category.\n\nPlease edit the product to add a category.'**
  String get product_search_same_category_error;

  /// Message for ProductImprovement.ADD_CATEGORY
  ///
  /// In en, this message translates to:
  /// **'Add a category to calculate the Nutri-Score.'**
  String get product_improvement_add_category;

  /// Message for ProductImprovement.ADD_NUTRITION_FACTS
  ///
  /// In en, this message translates to:
  /// **'Add nutrition facts to calculate the Nutri-Score.'**
  String get product_improvement_add_nutrition_facts;

  /// Message for ProductImprovement.ADD_NUTRITION_FACTS_AND_CATEGORY
  ///
  /// In en, this message translates to:
  /// **'Add nutrition facts and a category to calculate the Nutri-Score.'**
  String get product_improvement_add_nutrition_facts_and_category;

  /// Message for ProductImprovement.CATEGORIES_BUT_NO_NUTRISCORE
  ///
  /// In en, this message translates to:
  /// **'The Nutri-Score for this product can\'t be calculated, which may be due to e.g. a non-standard category. If this is considered an error, please contact us.'**
  String get product_improvement_categories_but_no_nutriscore;

  /// Message for ProductImprovement.OBSOLETE_NUTRITION_IMAGE
  ///
  /// In en, this message translates to:
  /// **'The nutrition image is obsolete: please refresh it.'**
  String get product_improvement_obsolete_nutrition_image;

  /// Message for ProductImprovement.ORIGINS_TO_BE_COMPLETED
  ///
  /// In en, this message translates to:
  /// **'The Green Score takes into account the origins of the ingredients. Please take a photo of the ingredient list and/or any geographic claim or edit the product, so they can be taken into account.'**
  String get product_improvement_origins_to_be_completed;

  /// Label shown above a selector where the user can select their country (in the preferences)
  ///
  /// In en, this message translates to:
  /// **'Please choose a country'**
  String get country_chooser_label;

  /// Label shown above a selector where the user can select their currency (in the preferences)
  ///
  /// In en, this message translates to:
  /// **'Please choose a currency'**
  String get currency_chooser_label;

  /// Message stating the change of countries
  ///
  /// In en, this message translates to:
  /// **'You have just changed countries.'**
  String get country_change_message;

  /// Message asking to confirm the change of currencies
  ///
  /// In en, this message translates to:
  /// **'Do you want to change the currency from {previousCurrency} to {possibleCurrency}?'**
  String currency_auto_change_message(
    String previousCurrency,
    String possibleCurrency,
  );

  /// The label shown above a selector where the user can select their country (in the onboarding)
  ///
  /// In en, this message translates to:
  /// **'Please choose a country:'**
  String get onboarding_country_chooser_label;

  /// Label to use in the settings to change the user country
  ///
  /// In en, this message translates to:
  /// **'Your country'**
  String get country_chooser_label_from_settings;

  /// No description provided for @country_selection_explanation.
  ///
  /// In en, this message translates to:
  /// **'Some environmental features are location-specific'**
  String get country_selection_explanation;

  /// Product got removed from comparison list
  ///
  /// In en, this message translates to:
  /// **'Product removed from comparison'**
  String get product_removed_comparison;

  /// Native App Settings in app settings
  ///
  /// In en, this message translates to:
  /// **'Native App Settings'**
  String get native_app_settings;

  /// Native App description in app settings
  ///
  /// In en, this message translates to:
  /// **'Open systems settings for Open Food Facts'**
  String get native_app_description;

  /// Product got removed from history
  ///
  /// In en, this message translates to:
  /// **'Product removed from history'**
  String get product_removed_history;

  /// Product got removed from list
  ///
  /// In en, this message translates to:
  /// **'Product removed from list'**
  String get product_removed_list;

  /// Could not remove product from a list
  ///
  /// In en, this message translates to:
  /// **'Could not remove product'**
  String get product_could_not_remove;

  /// No description provided for @no_prodcut_in_list.
  ///
  /// In en, this message translates to:
  /// **'There is no product in this list'**
  String get no_prodcut_in_list;

  /// No description provided for @no_product_in_section.
  ///
  /// In en, this message translates to:
  /// **'There is no product in this section'**
  String get no_product_in_section;

  /// No description provided for @recently_seen_products.
  ///
  /// In en, this message translates to:
  /// **'All viewed products'**
  String get recently_seen_products;

  /// Clears a product list (short label)
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Clears a product list (long label)
  ///
  /// In en, this message translates to:
  /// **'Empty the list'**
  String get clear_long;

  /// No description provided for @really_clear.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this list?'**
  String get really_clear;

  /// This product has a x percent match with your preferences
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String pct_match(Object percent);

  /// Cached results from: x days ago
  ///
  /// In en, this message translates to:
  /// **'{count,plural,  =1{one day ago} other{{count} days ago}}'**
  String plural_ago_days(num count);

  /// Cached results from: x hours ago
  ///
  /// In en, this message translates to:
  /// **'{count,plural,  =1{one hour ago} other{{count} hours ago}}'**
  String plural_ago_hours(num count);

  /// Cached results from: x minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count,plural,  =0{less than a minute ago} =1{one minute ago} other{{count} minutes ago}}'**
  String plural_ago_minutes(num count);

  /// Cached results from: x months ago
  ///
  /// In en, this message translates to:
  /// **'{count,plural,  =1{one month ago} other{{count} months ago}}'**
  String plural_ago_months(num count);

  /// Cached results from: x weeks ago
  ///
  /// In en, this message translates to:
  /// **'{count,plural,  =1{one week ago} other{{count} weeks ago}}'**
  String plural_ago_weeks(num count);

  /// Button label to open a page to compare all selected products to each other
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{Compare one Product} other{Compare {count} Products}}'**
  String plural_compare_x_products(num count);

  /// Page title with the number of selected items
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No selected product} =1{One selected product} other{{count} selected products}}'**
  String multiselect_title(num count);

  /// Button to switch to 'compare products mode'
  ///
  /// In en, this message translates to:
  /// **'Compare selected products'**
  String get compare_products_mode;

  /// Button to switch to 'delete products'
  ///
  /// In en, this message translates to:
  /// **'Delete selected products'**
  String get delete_products_mode;

  /// Button to switch to 'select all products'
  ///
  /// In en, this message translates to:
  /// **'Select all products'**
  String get select_all_products_mode;

  /// Button to switch to 'select no products'
  ///
  /// In en, this message translates to:
  /// **'Select none'**
  String get select_none_products_mode;

  /// AppBar title when in comparison mode
  ///
  /// In en, this message translates to:
  /// **'Compare products'**
  String get compare_products_appbar_title;

  /// AppBar subtitle when in comparison mode
  ///
  /// In en, this message translates to:
  /// **'Please select at least two products'**
  String get compare_products_appbar_subtitle;

  /// No description provided for @retry_button_label.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry_button_label;

  /// No description provided for @connect_with_us.
  ///
  /// In en, this message translates to:
  /// **'Connect with us'**
  String get connect_with_us;

  /// No description provided for @tiktok.
  ///
  /// In en, this message translates to:
  /// **'Follow us on TikTok'**
  String get tiktok;

  /// No description provided for @tiktok_link.
  ///
  /// In en, this message translates to:
  /// **'https://www.tiktok.com/@openfoodfacts'**
  String get tiktok_link;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Instagram'**
  String get instagram;

  /// No description provided for @instagram_link.
  ///
  /// In en, this message translates to:
  /// **'https://instagram.com/open.food.facts'**
  String get instagram_link;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Follow us on X (formerly Twitter)'**
  String get twitter;

  /// No description provided for @twitter_link.
  ///
  /// In en, this message translates to:
  /// **'https://www.twitter.com/openfoodfacts'**
  String get twitter_link;

  /// No description provided for @mastodon.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Mastodon'**
  String get mastodon;

  /// No description provided for @mastodon_link.
  ///
  /// In en, this message translates to:
  /// **'https://mastodon.social/@openfoodfacts'**
  String get mastodon_link;

  /// No description provided for @bsky.
  ///
  /// In en, this message translates to:
  /// **'Follow us on BlueSky'**
  String get bsky;

  /// No description provided for @bsky_link.
  ///
  /// In en, this message translates to:
  /// **'https://bsky.app/profile/openfoodfacts.bsky.social'**
  String get bsky_link;

  /// No description provided for @blog.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get blog;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @how_to_contribute.
  ///
  /// In en, this message translates to:
  /// **'How to Contribute'**
  String get how_to_contribute;

  /// Hint popup indicating the card is clickable during onboarding
  ///
  /// In en, this message translates to:
  /// **'Your can tap on any part of the card to get more details about what you see. Try it now!'**
  String get hint_knowledge_panel_message;

  /// Title for the camera permission's page (onboarding)
  ///
  /// In en, this message translates to:
  /// **'Camera access'**
  String get permissions_page_title;

  /// first paragraph for the camera permission's page (onboarding)
  ///
  /// In en, this message translates to:
  /// **'To scan barcodes with your phone\'s camera, please Authorize the access.'**
  String get permissions_page_body1;

  /// second paragraph for the camera permission's page (onboarding)
  ///
  /// In en, this message translates to:
  /// **'If you change your mind, this option can be enabled and disabled at any time from the settings.'**
  String get permissions_page_body2;

  /// Contact form content for Android devices
  ///
  /// In en, this message translates to:
  /// **'OS: Android (SDK Int: {sdkInt} / Release: {release})\nModel: {model}\nProduct: {product}\nDevice: {device}\nBrand:{brand}'**
  String contact_form_body_android(
    int? sdkInt,
    String? release,
    String? model,
    String? product,
    String? device,
    String? brand,
  );

  /// Contact form content for iOS devices
  ///
  /// In en, this message translates to:
  /// **'OS: iOS ({version})\nModel: {model}\nLocalized model: {localizedModel}'**
  String contact_form_body_ios(
    String? version,
    String? model,
    String? localizedModel,
  );

  /// Contact form content
  ///
  /// In en, this message translates to:
  /// **'{osContent}\nApp version:{appVersion}\nApp build number:{appBuildNumber}\nApp package name:{appPackageName}'**
  String contact_form_body(
    String osContent,
    String appVersion,
    String appBuildNumber,
    String appPackageName,
  );

  /// No description provided for @authorize_button_label.
  ///
  /// In en, this message translates to:
  /// **'Authorize'**
  String get authorize_button_label;

  /// No description provided for @refuse_button_label.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get refuse_button_label;

  /// No description provided for @ask_me_later_button_label.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get ask_me_later_button_label;

  /// Are you sure?
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get are_you_sure;

  /// When we show information from for example Wikipedia or health authorities, this is the button label to open the source website
  ///
  /// In en, this message translates to:
  /// **'Go further on {sourceName}'**
  String knowledge_panel_text_source(String sourceName);

  /// No description provided for @onboarding_home_welcome_text1.
  ///
  /// In en, this message translates to:
  /// **'Welcome !'**
  String get onboarding_home_welcome_text1;

  /// Onboarding home screen welcome text, text surrounded by * will be bold
  ///
  /// In en, this message translates to:
  /// **'The app that helps you choose food that is good for **you** and the **planet**!'**
  String get onboarding_home_welcome_text2;

  /// No description provided for @onboarding_continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboarding_continue_button;

  /// Title for the onboarding loading dialog
  ///
  /// In en, this message translates to:
  /// **'Loading your first example product'**
  String get onboarding_welcome_loading_dialog_title;

  /// Your ranking screen title
  ///
  /// In en, this message translates to:
  /// **'Your ranking'**
  String get product_list_your_ranking;

  /// No description provided for @product_list_empty_icon_desc.
  ///
  /// In en, this message translates to:
  /// **'History not available'**
  String get product_list_empty_icon_desc;

  /// When the history list is empty, title of the message explaining to start scanning
  ///
  /// In en, this message translates to:
  /// **'Start scanning'**
  String get product_list_empty_title;

  /// When the history list is empty, body of the message explaining to start scanning
  ///
  /// In en, this message translates to:
  /// **'Scanned products will appear here and you can check detailed information about them'**
  String get product_list_empty_message;

  /// Message to show while loading previous scanned items
  ///
  /// In en, this message translates to:
  /// **'Refreshing {count,plural,  =0{product} =1{product} other{products}} in your history'**
  String product_list_reloading_in_progress_multiple(num count);

  /// Message to show once previous scanned items are loaded
  ///
  /// In en, this message translates to:
  /// **'{count,plural,  =0{Product} =1{Product} other{Products}} refresh complete'**
  String product_list_reloading_success_multiple(num count);

  /// Default loading dialog title
  ///
  /// In en, this message translates to:
  /// **'Downloading data'**
  String get loading_dialog_default_title;

  /// Default loading dialog error message
  ///
  /// In en, this message translates to:
  /// **'Could not download data'**
  String get loading_dialog_default_error_message;

  /// Delete account button (user profile)
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get account_delete;

  /// Subject of the webview open when the user wants to delete his account
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get account_deletion_subject;

  /// User account (if connected)
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get user_profile;

  /// When the user is not connected
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get user_profile_title_guest;

  /// No description provided for @user_profile_subtitle_guest.
  ///
  /// In en, this message translates to:
  /// **'Sign-in or sign-up to join the Open Food Facts community'**
  String get user_profile_subtitle_guest;

  /// User login (when it's an email)
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts login: {email}'**
  String user_profile_title_id_email(String email);

  /// User login (when it's an id)
  ///
  /// In en, this message translates to:
  /// **'Welcome {id}!'**
  String user_profile_title_id_default(String id);

  /// Email subject for an account deletion
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get email_subject_account_deletion;

  /// Email body for an account deletion
  ///
  /// In en, this message translates to:
  /// **'Hi there, please delete my Open Food Facts account: {userId}'**
  String email_body_account_deletion(String userId);

  /// No description provided for @settings_app_app.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get settings_app_app;

  /// No description provided for @settings_app_data.
  ///
  /// In en, this message translates to:
  /// **'Features & Crash monitoring'**
  String get settings_app_data;

  /// No description provided for @settings_app_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get settings_app_camera;

  /// No description provided for @settings_app_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get settings_app_products;

  /// No description provided for @settings_app_miscellaneous.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get settings_app_miscellaneous;

  /// Title for the Camera play sound toggle
  ///
  /// In en, this message translates to:
  /// **'Play a sound on scan'**
  String get camera_play_sound_title;

  /// SubTitle for the Camera play sound toggle
  ///
  /// In en, this message translates to:
  /// **'Will beep on each successful scan'**
  String get camera_play_sound_subtitle;

  /// Accessibility label for the camera window
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode with your camera'**
  String get camera_window_accessibility_label;

  /// Title for the Haptic feedback toggle
  ///
  /// In en, this message translates to:
  /// **'Vibration & Haptics'**
  String get app_haptic_feedback_title;

  /// SubTitle for the Haptic feedback toggle
  ///
  /// In en, this message translates to:
  /// **'Vibrations after executing some actions (barcode decoded, product removed…).'**
  String get app_haptic_feedback_subtitle;

  /// Title for the Crash reporting toggle
  ///
  /// In en, this message translates to:
  /// **'Report us bugs and crashes'**
  String get crash_reporting_toggle_title;

  /// SubTitle for the Crash reporting toggle
  ///
  /// In en, this message translates to:
  /// **'When enabled, crash reports are automatically submitted to Open Food Facts\' error tracking system, so that bugs can be fixed and thus improve the app.'**
  String get crash_reporting_toggle_subtitle;

  /// No description provided for @send_anonymous_data_toggle_title.
  ///
  /// In en, this message translates to:
  /// **'Report us feature usage'**
  String get send_anonymous_data_toggle_title;

  /// No description provided for @send_anonymous_data_toggle_subtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, strictly anonymous information regarding feature usage will be sent to the Open Food Facts servers, so that we can understand how features are used in order to improve them. Otherwise, a 0 id will be sent.'**
  String get send_anonymous_data_toggle_subtitle;

  /// Toolbar Title while editing a photo (Android only)
  ///
  /// In en, this message translates to:
  /// **'Edit Photo'**
  String get product_edit_photo_title;

  /// When the camera/photo permission failed to be acquired (!= denied)
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get permission_photo_error;

  /// No description provided for @permission_photo_denied_title.
  ///
  /// In en, this message translates to:
  /// **'Allow camera use to scan barcodes'**
  String get permission_photo_denied_title;

  /// When the camera/photo permission is denied by user
  ///
  /// In en, this message translates to:
  /// **'For an enhanced experience, please allow {appName} to access your camera. You will be able to directly scan barcodes.'**
  String permission_photo_denied_message(String appName);

  /// When the camera/photo permission is denied by user
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permission_photo_denied_button;

  /// No description provided for @permission_photo_denied_dialog_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permission_photo_denied_dialog_settings_title;

  /// No description provided for @permission_photo_denied_dialog_settings_message.
  ///
  /// In en, this message translates to:
  /// **'As you\'ve previously denied the camera permission, you must allow it manually from the Settings.'**
  String get permission_photo_denied_dialog_settings_message;

  /// No description provided for @permission_photo_denied_dialog_settings_button_open.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permission_photo_denied_dialog_settings_button_open;

  /// No description provided for @permission_photo_denied_dialog_settings_button_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get permission_photo_denied_dialog_settings_button_cancel;

  /// Message for the user when no camera was detected, replacing the barcode scanner
  ///
  /// In en, this message translates to:
  /// **'No camera detected'**
  String get permission_photo_none_found;

  /// When the camera/photo permission is denied by user
  ///
  /// In en, this message translates to:
  /// **'No camera access granted'**
  String get permission_photo_denied;

  /// Button to show a list of product pictures
  ///
  /// In en, this message translates to:
  /// **'Show product pictures'**
  String get show_product_pictures;

  /// Edit product button label
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get edit_product_label;

  /// When a product has pending edits (being sent to the server), there is a message on the edit page (here is the title of the message).
  ///
  /// In en, this message translates to:
  /// **'Uploading your edits…'**
  String get edit_product_pending_operations_banner_title;

  /// When a product has pending edits (being sent to the server), there is a message on the edit page. Please keep the ** syntax to make the text bold.
  ///
  /// In en, this message translates to:
  /// **'Your edits are being **sent in the background** (or later in case of error).\nYou can continue editing other product fields.'**
  String get edit_product_pending_operations_banner_message;

  /// When a product has pending edits (being sent to the server), there is a message on the edit page. Please keep the ** syntax to make the text bold.
  ///
  /// In en, this message translates to:
  /// **'Your edits are being **sent in the background** (or later in case of error).'**
  String get edit_product_pending_operations_banner_short_message;

  /// Edit product button short label (only the verb)
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit_product_label_short;

  /// Help text for the input field. Eg 'How to enter stores?'
  ///
  /// In en, this message translates to:
  /// **'How to enter \"{value}\"?'**
  String edit_product_form_item_help(String value);

  /// Error message when the user tries to submit an empty value
  ///
  /// In en, this message translates to:
  /// **'Please enter a non-empty value!'**
  String get edit_product_form_item_error_empty;

  /// Error message when the user tries to re-submit an existing value
  ///
  /// In en, this message translates to:
  /// **'This value is already there!'**
  String get edit_product_form_item_error_existing;

  /// Tooltip to show when the user long presses the (+) button on a brand
  ///
  /// In en, this message translates to:
  /// **'Add a new brand'**
  String get edit_product_form_item_add_action_brand;

  /// Tooltip to show when the user long presses the (+) button on a label
  ///
  /// In en, this message translates to:
  /// **'Add a new label'**
  String get edit_product_form_item_add_action_label;

  /// Tooltip to show when the user long presses the (+) button on a store
  ///
  /// In en, this message translates to:
  /// **'Add a new store'**
  String get edit_product_form_item_add_action_store;

  /// Tooltip to show when the user long presses the (+) button on an origin
  ///
  /// In en, this message translates to:
  /// **'Add a new origin'**
  String get edit_product_form_item_add_action_origin;

  /// Tooltip to show when the user long presses the (+) button on a traceability code
  ///
  /// In en, this message translates to:
  /// **'Add a new traceability code'**
  String get edit_product_form_item_add_action_emb_code;

  /// Tooltip to show when the user long presses the (+) button on a country
  ///
  /// In en, this message translates to:
  /// **'Add a new country'**
  String get edit_product_form_item_add_action_country;

  /// Tooltip to show when the user long presses the (+) button on a category
  ///
  /// In en, this message translates to:
  /// **'Add a new category'**
  String get edit_product_form_item_add_action_category;

  /// Tooltip to show when the user long presses the (+) button on a trace
  ///
  /// In en, this message translates to:
  /// **'Add a new trace'**
  String get edit_product_form_item_add_action_trace;

  /// Tooltip to show when the user long presses the (+) button on a suggestion
  ///
  /// In en, this message translates to:
  /// **'Add suggestion'**
  String get edit_product_form_item_add_suggestion;

  /// Tooltip to show when the user long presses the (-) button on a suggestion
  ///
  /// In en, this message translates to:
  /// **'Deny suggestion'**
  String get edit_product_form_item_deny_suggestion;

  /// Product edition - Basic Details - Title
  ///
  /// In en, this message translates to:
  /// **'Basic details'**
  String get edit_product_form_item_details_title;

  /// Product edition - Basic Details - Subtitle
  ///
  /// In en, this message translates to:
  /// **'Product name, brand, quantity'**
  String get edit_product_form_item_details_subtitle;

  /// Product edition - Other Details - Title
  ///
  /// In en, this message translates to:
  /// **'Additional details'**
  String get edit_product_form_item_other_details_title;

  /// Product edition - Other Details - Subtitle
  ///
  /// In en, this message translates to:
  /// **'Website…'**
  String get edit_product_form_item_other_details_subtitle;

  /// Product edition - Photos - Title
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get edit_product_form_item_photos_title;

  /// Product edition - Photos - SubTitle
  ///
  /// In en, this message translates to:
  /// **'Add or refresh photos'**
  String get edit_product_form_item_photos_subtitle;

  /// Product edition - Labels - Title
  ///
  /// In en, this message translates to:
  /// **'Labels & Certifications'**
  String get edit_product_form_item_labels_title;

  /// Product edition - Labels - SubTitle
  ///
  /// In en, this message translates to:
  /// **'Environmental, Quality labels…'**
  String get edit_product_form_item_labels_subtitle;

  /// Product edition - Labels - input textfield hint
  ///
  /// In en, this message translates to:
  /// **'Input a label (eg: NutriScore)'**
  String get edit_product_form_item_labels_hint;

  /// Product edition - Labels - input textfield label
  ///
  /// In en, this message translates to:
  /// **'label'**
  String get edit_product_form_item_labels_type;

  /// Product edition - Labels - explanation
  ///
  /// In en, this message translates to:
  /// **'Good practices: Labels'**
  String get edit_product_form_item_labels_explanation_title;

  /// Product edition - Labels - explanation
  ///
  /// In en, this message translates to:
  /// **'Any characteristic of the product **which is factual** and different from the other fields.'**
  String get edit_product_form_item_labels_explanation_info1;

  /// Product edition - Labels - explanation
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score, NOVA…'**
  String get edit_product_form_item_labels_explanation_good_examples_1;

  /// Product edition - Labels - explanation
  ///
  /// In en, this message translates to:
  /// **'Made in Belgium, produced in Brittany…'**
  String get edit_product_form_item_labels_explanation_good_examples_2;

  /// Product edition - Labels - explanation
  ///
  /// In en, this message translates to:
  /// **'ISO 9001, ISO 22000…'**
  String get edit_product_form_item_labels_explanation_good_examples_3;

  /// Product edition - Labels - explanation
  ///
  /// In en, this message translates to:
  /// **'Rich in fiber, source of iron…'**
  String get edit_product_form_item_labels_explanation_good_examples_4;

  /// Product edition - Labels - explanation
  ///
  /// In en, this message translates to:
  /// **'Fair trade, Max Havelaar…'**
  String get edit_product_form_item_labels_explanation_good_examples_5;

  /// Product edition - Stores - Title
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get edit_product_form_item_stores_title;

  /// Product edition - Stores - input textfield hint
  ///
  /// In en, this message translates to:
  /// **'Input a store'**
  String get edit_product_form_item_stores_hint;

  /// Product edition - Stores - input textfield type
  ///
  /// In en, this message translates to:
  /// **'store'**
  String get edit_product_form_item_stores_type;

  /// Product edition - Stores - Explanation
  ///
  /// In en, this message translates to:
  /// **'Good practices: Stores'**
  String get edit_product_form_item_stores_explanation_title;

  /// Product edition - Stores - Explanation
  ///
  /// In en, this message translates to:
  /// **'Input the store where you bought the product.'**
  String get edit_product_form_item_stores_explanation_info1;

  /// An example of store (you can change it with a more accurate one)
  ///
  /// In en, this message translates to:
  /// **'Walmart'**
  String get edit_product_form_item_stores_explanation_good_examples_1;

  /// An example of store (you can change it with a more accurate one)
  ///
  /// In en, this message translates to:
  /// **'Carrefour'**
  String get edit_product_form_item_stores_explanation_good_examples_2;

  /// An example of store (you can change it with a more accurate one)
  ///
  /// In en, this message translates to:
  /// **'Lidl'**
  String get edit_product_form_item_stores_explanation_good_examples_3;

  /// Product edition - Origins - Title
  ///
  /// In en, this message translates to:
  /// **'Origins'**
  String get edit_product_form_item_origins_title;

  /// Product edition - Origins - input textfield hint
  ///
  /// In en, this message translates to:
  /// **'Input an origin (eg: Germany)'**
  String get edit_product_form_item_origins_hint;

  /// Product edition - Origins - input textfield type
  ///
  /// In en, this message translates to:
  /// **'country'**
  String get edit_product_form_item_origins_type;

  /// Product edition - Origins - input explainer, part 1
  ///
  /// In en, this message translates to:
  /// **'Good practices: Origins'**
  String get edit_product_form_item_origins_explanation_title;

  /// Product edition - Origins - input explainer, part 1
  ///
  /// In en, this message translates to:
  /// **'Add **any indications of origins you can find on the packaging**.\nYou need not worry about origins indicated directly in the ingredient list.'**
  String get edit_product_form_item_origins_explanation_info1;

  /// Product edition - Origins - input explainer, part 2
  ///
  /// In en, this message translates to:
  /// **'Beef from Argentina'**
  String get edit_product_form_item_origins_explanation_good_examples_1;

  /// Product edition - Origins - input explainer, part 2
  ///
  /// In en, this message translates to:
  /// **'The soy does not come from the European Union'**
  String get edit_product_form_item_origins_explanation_good_examples_2;

  /// Product edition - Countries - Title
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get edit_product_form_item_countries_title;

  /// Product edition - Countries - input textfield hint
  ///
  /// In en, this message translates to:
  /// **'Input a country (eg: Germany)'**
  String get edit_product_form_item_countries_hint;

  /// Product edition - Countries - input textfield type
  ///
  /// In en, this message translates to:
  /// **'country'**
  String get edit_product_form_item_countries_type;

  /// Product edition - Countries - explanations
  ///
  /// In en, this message translates to:
  /// **'Good practices: Countries'**
  String get edit_product_form_item_countries_explanations_title;

  /// Product edition - Countries - explanations
  ///
  /// In en, this message translates to:
  /// **'**Countries where the product is widely available** (not including stores specialising in foreign products).'**
  String get edit_product_form_item_countries_explanations_info1;

  /// Product edition - Traceability codes - Title
  ///
  /// In en, this message translates to:
  /// **'Traceability codes'**
  String get edit_product_form_item_emb_codes_title;

  /// Product edition - Traceability Codes - input textfield hint
  ///
  /// In en, this message translates to:
  /// **'Input a code (eg: EMB 53062, FR 62.448.034 CE, 84 R 20, 33 RECOLTANT 522…)'**
  String get edit_product_form_item_emb_codes_hint;

  /// Product edition - Traceability Codes - input textfield type
  ///
  /// In en, this message translates to:
  /// **'traceability code'**
  String get edit_product_form_item_emb_codes_type;

  /// Title for the help section about traceability codes
  ///
  /// In en, this message translates to:
  /// **'Good practices: Traceability codes'**
  String get edit_product_form_item_emb_help_title;

  /// Text explaining how to write a traceability code
  ///
  /// In en, this message translates to:
  /// **'In this section, you can input codes related to **packaging marks**, **identification marks** or **health marks**.'**
  String get edit_product_form_item_emb_help_info1;

  /// Explanation about EMB/EC… codes
  ///
  /// In en, this message translates to:
  /// **'Examples of traceability codes'**
  String get edit_product_form_item_emb_help_info2_title;

  /// Explanation about EC codes
  ///
  /// In en, this message translates to:
  /// **'**EC codes** used in the European Community to identify food producers or packagers:'**
  String get edit_product_form_item_emb_help_info2_item1_text;

  /// Example of an EC code (you can change with a valid code in another european country)
  ///
  /// In en, this message translates to:
  /// **'FR\n72.264.002\nCE'**
  String get edit_product_form_item_emb_help_info2_item1_example;

  /// Example of an EC code (shouldn't be translated)
  ///
  /// In en, this message translates to:
  /// **'**FR**: country code of **France**\n**72.264.002**: geographic data\n**CE**: European Community'**
  String get edit_product_form_item_emb_help_info2_item1_explanation;

  /// Explanation about EMB codes
  ///
  /// In en, this message translates to:
  /// **'**EMB codes** used in France:'**
  String get edit_product_form_item_emb_help_info2_item2_text;

  /// Example of an EMB code
  ///
  /// In en, this message translates to:
  /// **'EMB 72264'**
  String get edit_product_form_item_emb_help_info2_item2_explanation;

  /// Product edition - Traces - Title
  ///
  /// In en, this message translates to:
  /// **'Traces'**
  String get edit_product_form_item_traces_title;

  /// Product edition - Traces - input textfield hint
  ///
  /// In en, this message translates to:
  /// **'trace'**
  String get edit_product_form_item_traces_hint;

  /// Product edition - Traces - input textfield type
  ///
  /// In en, this message translates to:
  /// **'Input a trace (eg: Soy beans)'**
  String get edit_product_form_item_traces_type;

  /// Product edition - Categories - Title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get edit_product_form_item_categories_title;

  /// Product edition - Categories - input textfield hint
  ///
  /// In en, this message translates to:
  /// **'category'**
  String get edit_product_form_item_categories_hint;

  /// Product edition - Categories - input textfield type
  ///
  /// In en, this message translates to:
  /// **'Input a category (eg: Orange juice)'**
  String get edit_product_form_item_categories_type;

  /// Product edition - Categories - input explainer, title
  ///
  /// In en, this message translates to:
  /// **'Good practices: Categories'**
  String get edit_product_form_item_categories_explanation_title;

  /// Product edition - Categories - input explainer, part 1
  ///
  /// In en, this message translates to:
  /// **'Indicate **only the most specific category**.\nParent categories will be automatically added.'**
  String get edit_product_form_item_categories_explanation_info1;

  /// Product edition - Categories - input explainer, part 2
  ///
  /// In en, this message translates to:
  /// **'Missing category?'**
  String get edit_product_form_item_categories_explanation_info2_title;

  /// Product edition - Categories - input explainer, part 2
  ///
  /// In en, this message translates to:
  /// **'In case a category is **not available in autocomplete**, feel free to add it anyway.\nThis will help us improve Open Food Facts in your country.'**
  String get edit_product_form_item_categories_explanation_info2_content;

  /// Product edition - Categories - input explainer, part 3
  ///
  /// In en, this message translates to:
  /// **'Sardines in olive oil'**
  String get edit_product_form_item_categories_explanation_good_examples_1;

  /// Product edition - Categories - input explainer, part 3
  ///
  /// In en, this message translates to:
  /// **'Orange juice from concentrate'**
  String get edit_product_form_item_categories_explanation_good_examples_2;

  /// No description provided for @edit_product_form_item_exit_title.
  ///
  /// In en, this message translates to:
  /// **'Quit without saving?'**
  String get edit_product_form_item_exit_title;

  /// No description provided for @edit_product_form_item_exit_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save your changes before leaving this page?'**
  String get edit_product_form_item_exit_confirmation;

  /// No description provided for @edit_product_form_item_exit_confirmation_positive_button.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get edit_product_form_item_exit_confirmation_positive_button;

  /// No description provided for @edit_product_form_item_exit_confirmation_negative_button.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get edit_product_form_item_exit_confirmation_negative_button;

  /// Product edition - Ingredients - Title (note: this section was previously called Ingredients & Origins)
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get edit_product_form_item_ingredients_title;

  /// Product edition - Ingredients - Pinch to zoom icon explanation
  ///
  /// In en, this message translates to:
  /// **'Zoom in and out by pinching the screen'**
  String get edit_product_form_item_ingredients_pinch_to_zoom_tooltip;

  /// Product edition - Ingredients - Pinch to zoom explanation title
  ///
  /// In en, this message translates to:
  /// **'Zoom in and out the photo'**
  String get edit_product_form_item_ingredients_pinch_to_zoom_title;

  /// Product edition - Ingredients - Pinch to zoom explanation message
  ///
  /// In en, this message translates to:
  /// **'Using the **Pinch-to-zoom gesture**, you can zoom in or out the photo:'**
  String get edit_product_form_item_ingredients_pinch_to_zoom_message;

  /// No description provided for @edit_product_form_item_add_valid_item_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get edit_product_form_item_add_valid_item_tooltip;

  /// No description provided for @edit_product_form_item_add_invalid_item_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Please enter a text first'**
  String get edit_product_form_item_add_invalid_item_tooltip;

  /// No description provided for @edit_product_form_item_remove_item_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get edit_product_form_item_remove_item_tooltip;

  /// The user can edit an existing item. This action will save the change.
  ///
  /// In en, this message translates to:
  /// **'Save your edit'**
  String get edit_product_form_item_save_edit_item_tooltip;

  /// The user can edit an existing item. This action will cancel the change (and return to the initial value).
  ///
  /// In en, this message translates to:
  /// **'Cancel your edit'**
  String get edit_product_form_item_cancel_edit_item_tooltip;

  /// Product edition - Packaging - Title
  ///
  /// In en, this message translates to:
  /// **'Recycling instructions photo'**
  String get edit_product_form_item_packaging_title;

  /// Product edition - Nutrition facts - Title
  ///
  /// In en, this message translates to:
  /// **'Nutrition facts'**
  String get edit_product_form_item_nutrition_facts_title;

  /// Product edition - Nutrition facts - SubTitle
  ///
  /// In en, this message translates to:
  /// **'Nutrition, alcohol content…'**
  String get edit_product_form_item_nutrition_facts_subtitle;

  /// Title for the help section about Nutritional facts
  ///
  /// In en, this message translates to:
  /// **'Good practices: Nutrition facts'**
  String get edit_product_form_item_nutrition_facts_explanation_title;

  /// Text explaining the selector of nutritional values.
  ///
  /// In en, this message translates to:
  /// **'Nutritional values'**
  String get edit_product_form_item_nutrition_facts_explanation_info1_title;

  /// Text explaining the selector of nutritional values.
  ///
  /// In en, this message translates to:
  /// **'First, select if the **values are provided**:'**
  String get edit_product_form_item_nutrition_facts_explanation_info1_content;

  /// Text explaining how to input nutritional values.
  ///
  /// In en, this message translates to:
  /// **'Nutrition facts'**
  String get edit_product_form_item_nutrition_facts_explanation_info2_title;

  /// Text explaining how to input nutritional values.
  ///
  /// In en, this message translates to:
  /// **'Then, input the nutritional values **as indicated on the packaging**. If there is no value, you can click on the \"Eye\" icon.'**
  String get edit_product_form_item_nutrition_facts_explanation_info2_content;

  /// Text explaining what to input when a nutritional value is missing.
  ///
  /// In en, this message translates to:
  /// **'Missing field?'**
  String get edit_product_form_item_nutrition_facts_explanation_info3_title;

  /// Text explaining what to input when a nutritional value is missing.
  ///
  /// In en, this message translates to:
  /// **'If an entry is missing, you can **click on the \"Plus\" icon** to add it (eg: vitamin D, magnesium…).'**
  String get edit_product_form_item_nutrition_facts_explanation_info3_content;

  /// Product edition - Nutrition facts - Save button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit_product_form_save;

  /// Product edition - Ingredients - Title
  ///
  /// In en, this message translates to:
  /// **'Ingredients photo'**
  String get edit_product_ingredients_photo_title;

  /// Product edition - Ingredients - Title
  ///
  /// In en, this message translates to:
  /// **'List of ingredients'**
  String get edit_product_ingredients_list_title;

  /// Product edition - Packaging - Title
  ///
  /// In en, this message translates to:
  /// **'Packaging photo'**
  String get edit_product_packaging_photo_title;

  /// Product edition - Packaging - Title
  ///
  /// In en, this message translates to:
  /// **'Packaging list'**
  String get edit_product_packaging_list_title;

  /// When there are no data to display
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data_available;

  /// Title of a product field: website
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get product_field_website_title;

  /// Title of the button where users can edit the origins of a product
  ///
  /// In en, this message translates to:
  /// **'Edit Origins'**
  String get origins_editing_title;

  /// No description provided for @completed_basic_details_btn_text.
  ///
  /// In en, this message translates to:
  /// **'Complete basic details'**
  String get completed_basic_details_btn_text;

  /// No description provided for @not_implemented_snackbar_text.
  ///
  /// In en, this message translates to:
  /// **'Not implemented yet'**
  String get not_implemented_snackbar_text;

  /// No description provided for @category_picker_page_appbar_text.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get category_picker_page_appbar_text;

  /// Ingredients edition - Extract ingredients
  ///
  /// In en, this message translates to:
  /// **'Extract ingredients from the photo'**
  String get edit_ingredients_extract_ingredients_btn_text;

  /// Ingredients edition - Extract ingredients (short label)
  ///
  /// In en, this message translates to:
  /// **'Extract ingredients'**
  String get edit_ingredients_extract_ingredients_btn_text_short;

  /// Ingredients edition - Extracting ingredients
  ///
  /// In en, this message translates to:
  /// **'Extracting ingredients\nfrom the photo'**
  String get edit_ingredients_extracting_ingredients_btn_text;

  /// Ingredients edition - Loading photo from the server
  ///
  /// In en, this message translates to:
  /// **'Loading photo…'**
  String get edit_ingredients_loading_photo_btn_text;

  /// Ingredients edition - Dialog explaining why the photo is loading - Title
  ///
  /// In en, this message translates to:
  /// **'Why do I see this message?'**
  String get edit_ingredients_loading_photo_help_dialog_title;

  /// Ingredients edition - Dialog explaining why the photo is loading - Content
  ///
  /// In en, this message translates to:
  /// **'To use the \"Extract ingredients\" feature, the photo needs to be uploaded first.\n\nPlease wait a few seconds or enter them manually.'**
  String get edit_ingredients_loading_photo_help_dialog_body;

  /// Ingredients edition - Refresh photo
  ///
  /// In en, this message translates to:
  /// **'Refresh photo'**
  String get edit_ingredients_refresh_photo_btn_text;

  /// Packaging edition - OCR-Extract packaging
  ///
  /// In en, this message translates to:
  /// **'Extract packaging\nfrom the photo'**
  String get edit_packaging_extract_btn_text;

  /// Packaging edition - OCR-Extract packaging (short label)
  ///
  /// In en, this message translates to:
  /// **'Extract packaging'**
  String get edit_packaging_extract_btn_text_short;

  /// Packaging edition - OCR-Extracting packaging
  ///
  /// In en, this message translates to:
  /// **'Extracting packaging from the photo'**
  String get edit_packaging_extracting_btn_text;

  /// Packaging edition - Loading photo from the server
  ///
  /// In en, this message translates to:
  /// **'Loading photo…'**
  String get edit_packaging_loading_photo_btn_text;

  /// Packaging edition - Dialog explaining why the photo is loading - Title
  ///
  /// In en, this message translates to:
  /// **'Why do I see this message?'**
  String get edit_packaging_loading_photo_help_dialog_title;

  /// Packaging edition - Dialog explaining why the photo is loading - Content
  ///
  /// In en, this message translates to:
  /// **'To use the \"Extract packaging\" feature, the photo needs to be uploaded first.\n\nPlease wait a few seconds or enter them manually.'**
  String get edit_packaging_loading_photo_help_dialog_body;

  /// Packaging edition - Refresh photo
  ///
  /// In en, this message translates to:
  /// **'Refresh photo'**
  String get edit_packaging_refresh_photo_btn_text;

  /// OCR extraction - message for failed
  ///
  /// In en, this message translates to:
  /// **'Failed to detect text in image.'**
  String get edit_ocr_extract_failed;

  /// OCR extraction - title for disabled
  ///
  /// In en, this message translates to:
  /// **'No picture!'**
  String get edit_ocr_extract_disabled_title;

  /// OCR extraction - message for disabled
  ///
  /// In en, this message translates to:
  /// **'In order to use the text extraction feature, you must first take a photo.'**
  String get edit_ocr_extract_disabled_message;

  /// Title of the 'new user list' dialog
  ///
  /// In en, this message translates to:
  /// **'New list of products'**
  String get user_list_dialog_new_title;

  /// Title of the 'rename user list' dialog
  ///
  /// In en, this message translates to:
  /// **'Rename list'**
  String get user_list_dialog_rename_title;

  /// Subtitle of a paragraph about user lists in a product context
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get user_list_subtitle_product;

  /// Label for the user lists (when the user wants to add a product to a list)
  ///
  /// In en, this message translates to:
  /// **'Your lists'**
  String get user_list_title;

  /// Label for the dialog to add a product to a list
  ///
  /// In en, this message translates to:
  /// **'Add the product to your lists'**
  String get user_list_add_product;

  /// Short label of a 'create a new list' button
  ///
  /// In en, this message translates to:
  /// **'Create a new list'**
  String get user_list_button_new;

  /// Content displayed when there is no list
  ///
  /// In en, this message translates to:
  /// **'No list available yet!\nPlease start by creating one.'**
  String get user_list_empty_label;

  /// Short label of an 'add to list' button from a product context
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get user_list_button_add_product;

  /// Message when products have been successfully added to a list
  ///
  /// In en, this message translates to:
  /// **'Added to list'**
  String get added_to_list_msg;

  /// Short label of a 'clear your history list' popup
  ///
  /// In en, this message translates to:
  /// **'Clear your history'**
  String get user_list_popup_clear;

  /// Short label of a 'rename list' popup
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get user_list_popup_rename;

  /// Hint of a user list name text-field in a 'user list' dialog
  ///
  /// In en, this message translates to:
  /// **'My list'**
  String get user_list_name_hint;

  /// Validation error about the name that cannot be empty
  ///
  /// In en, this message translates to:
  /// **'Name is mandatory'**
  String get user_list_name_error_empty;

  /// Validation error about the name that is already used for another list
  ///
  /// In en, this message translates to:
  /// **'That name is already used'**
  String get user_list_name_error_already;

  /// Validation error about the renamed name that is the same as the initial list name
  ///
  /// In en, this message translates to:
  /// **'That is the same name'**
  String get user_list_name_error_same;

  /// A hint to indicate that the user should input a name of a list
  ///
  /// In en, this message translates to:
  /// **'Name of the list'**
  String get user_list_name_input_hint;

  /// Label for buttons that try to repeat a failed action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// Label that presents a error
  ///
  /// In en, this message translates to:
  /// **'There was an error'**
  String get there_was_an_error;

  /// Label when no category is available
  ///
  /// In en, this message translates to:
  /// **'No category found for {items}'**
  String category_picker_no_category_found_message(String items);

  /// Explanation for the icon to switch between cameras
  ///
  /// In en, this message translates to:
  /// **'Switch between back and front camera'**
  String get camera_toggle_camera;

  /// Explanation for the icon to turn on/off the flash
  ///
  /// In en, this message translates to:
  /// **'Turn ON or OFF the flash of the camera'**
  String get camera_toggle_flash;

  /// Enable flash (tooltip)
  ///
  /// In en, this message translates to:
  /// **'Enable flash'**
  String get camera_enable_flash;

  /// Disable flash (tooltip)
  ///
  /// In en, this message translates to:
  /// **'Disable flash'**
  String get camera_disable_flash;

  /// Title of the dialog explaining that an error happened while enabling/disabling the flash of the camera
  ///
  /// In en, this message translates to:
  /// **'An error occurred!'**
  String get camera_flash_error_dialog_title;

  /// Content of the dialog explaining that an error happened while enabling/disabling the flash of the camera
  ///
  /// In en, this message translates to:
  /// **'An error occurred while changing the state of your flash. Please ensure your smartphone has not the torch already enabled.'**
  String get camera_flash_error_dialog_message;

  /// Button label when no category is available
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get category_picker_no_category_found_button;

  /// A hint for screen readers to explain how external links work
  ///
  /// In en, this message translates to:
  /// **'Click to open in your browser or in the application (if installed)'**
  String get user_preferences_item_accessibility_hint;

  /// User dev preferences - Title
  ///
  /// In en, this message translates to:
  /// **'DEV Mode'**
  String get dev_preferences_screen_title;

  /// User dev preferences - Reset onboarding - Title
  ///
  /// In en, this message translates to:
  /// **'Restart onboarding'**
  String get dev_preferences_reset_onboarding_title;

  /// User dev preferences - Reset onboarding - Subtitle
  ///
  /// In en, this message translates to:
  /// **'You then have to restart the App to see it again.'**
  String get dev_preferences_reset_onboarding_subtitle;

  /// User dev preferences - Environment (prod/test) switcher - Title
  ///
  /// In en, this message translates to:
  /// **'Switch between openfoodfacts.org (PROD) and test env'**
  String get dev_preferences_environment_switch_title;

  /// User dev preferences - Info about test environment - Title
  ///
  /// In en, this message translates to:
  /// **'Test environment parameters'**
  String get dev_preferences_test_environment_title;

  /// User dev preferences - Info about test environment - Value
  ///
  /// In en, this message translates to:
  /// **'Base URL for current test env: {url}'**
  String dev_preferences_test_environment_subtitle(String url);

  /// User dev preferences - Info about test environment - Dialog title
  ///
  /// In en, this message translates to:
  /// **'Test environment host'**
  String get dev_preferences_test_environment_dialog_title;

  /// User dev preferences - Enable ML Kit - Title
  ///
  /// In en, this message translates to:
  /// **'Use ML Kit'**
  String get dev_preferences_ml_kit_title;

  /// User dev preferences - Enable ML Kit - Subtitle
  ///
  /// In en, this message translates to:
  /// **'then you have to restart this app'**
  String get dev_preferences_ml_kit_subtitle;

  /// User dev preferences - Additional buttons on product page - Title
  ///
  /// In en, this message translates to:
  /// **'Additional button on product page'**
  String get dev_preferences_product_additional_features_title;

  /// User dev preferences - Additional buttons on product page - Subtitle
  ///
  /// In en, this message translates to:
  /// **'Edit ingredients via a knowledge panel button'**
  String get dev_preferences_edit_ingredients_title;

  /// User dev preferences - Export history - Title
  ///
  /// In en, this message translates to:
  /// **'Export History'**
  String get dev_preferences_export_history_title;

  /// User dev preferences - Export history - Item - Error
  ///
  /// In en, this message translates to:
  /// **'exception'**
  String get dev_preferences_export_history_progress_error;

  /// User dev preferences - Export history - Item - Found
  ///
  /// In en, this message translates to:
  /// **'product found'**
  String get dev_preferences_export_history_progress_found;

  /// User dev preferences - Export history - Item - Not found
  ///
  /// In en, this message translates to:
  /// **'product NOT found'**
  String get dev_preferences_export_history_progress_not_found;

  /// User dev preferences - Export history - Dialog title
  ///
  /// In en, this message translates to:
  /// **'Export history'**
  String get dev_preferences_export_history_dialog_title;

  /// User dev preferences - Positive button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dev_preferences_button_positive;

  /// User dev preferences - Negative button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dev_preferences_button_negative;

  /// No description provided for @dev_preferences_migration_title.
  ///
  /// In en, this message translates to:
  /// **'Data migration from V1'**
  String get dev_preferences_migration_title;

  /// No description provided for @dev_preferences_migration_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String dev_preferences_migration_subtitle(String status);

  /// No description provided for @dev_preferences_migration_status_already_done.
  ///
  /// In en, this message translates to:
  /// **'success or fresh install'**
  String get dev_preferences_migration_status_already_done;

  /// No description provided for @dev_preferences_migration_status_success.
  ///
  /// In en, this message translates to:
  /// **'success'**
  String get dev_preferences_migration_status_success;

  /// No description provided for @dev_preferences_migration_status_error.
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get dev_preferences_migration_status_error;

  /// No description provided for @dev_preferences_migration_status_in_progress.
  ///
  /// In en, this message translates to:
  /// **'in progress'**
  String get dev_preferences_migration_status_in_progress;

  /// No description provided for @dev_preferences_migration_status_required.
  ///
  /// In en, this message translates to:
  /// **'required (click to start)'**
  String get dev_preferences_migration_status_required;

  /// No description provided for @dev_preferences_migration_status_not_started.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get dev_preferences_migration_status_not_started;

  /// User dev preferences - Import history - Subtitle
  ///
  /// In en, this message translates to:
  /// **'Will clear history and put 3 products in there'**
  String get dev_preferences_import_history_subtitle;

  /// News dev preferences - Custom URL for news - Title
  ///
  /// In en, this message translates to:
  /// **'Custom URL for news'**
  String get dev_preferences_news_custom_url_title;

  /// News dev preferences - Custom URL for news - Title
  ///
  /// In en, this message translates to:
  /// **'URL of the JSON file:'**
  String get dev_preferences_news_custom_url_subtitle;

  /// Message to show when the custom news URL is not set
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get dev_preferences_news_custom_url_empty_value;

  /// News dev preferences - Status - Title
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get dev_preferences_news_provider_status_title;

  /// News dev preferences - Custom URL for news - Subtitle
  ///
  /// In en, this message translates to:
  /// **'Last refresh: {date}'**
  String dev_preferences_news_provider_status_subtitle(String date);

  /// No description provided for @product_type_label_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get product_type_label_food;

  /// No description provided for @product_type_label_beauty.
  ///
  /// In en, this message translates to:
  /// **'Personal care'**
  String get product_type_label_beauty;

  /// No description provided for @product_type_label_pet_food.
  ///
  /// In en, this message translates to:
  /// **'Pet food'**
  String get product_type_label_pet_food;

  /// No description provided for @product_type_label_product.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get product_type_label_product;

  /// No description provided for @product_type_selection_title.
  ///
  /// In en, this message translates to:
  /// **'Product type'**
  String get product_type_selection_title;

  /// No description provided for @product_type_selection_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the type of this product'**
  String get product_type_selection_subtitle;

  /// Error message about product type that needs to be set
  ///
  /// In en, this message translates to:
  /// **'You need to select a product type first!'**
  String get product_type_selection_empty;

  /// Error message about product type that cannot be set again
  ///
  /// In en, this message translates to:
  /// **'You cannot change the product type ({productType})!'**
  String product_type_selection_already(String productType);

  /// No description provided for @prices_app_dev_mode_flag.
  ///
  /// In en, this message translates to:
  /// **'Shortcut to Prices app on product page'**
  String get prices_app_dev_mode_flag;

  /// No description provided for @prices_app_button.
  ///
  /// In en, this message translates to:
  /// **'Go to Prices app'**
  String get prices_app_button;

  /// No description provided for @prices_bulk_proof_upload_select.
  ///
  /// In en, this message translates to:
  /// **'Add price tags directly from gallery'**
  String get prices_bulk_proof_upload_select;

  /// No description provided for @prices_bulk_proof_upload_warning.
  ///
  /// In en, this message translates to:
  /// **'Once you\'ve selected images, you won\'t be able to edit them!'**
  String get prices_bulk_proof_upload_warning;

  /// No description provided for @prices_bulk_proof_upload_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Multiple Price Tags'**
  String get prices_bulk_proof_upload_subtitle;

  /// No description provided for @prices_bulk_proof_upload_title.
  ///
  /// In en, this message translates to:
  /// **'Bulk Proof Upload'**
  String get prices_bulk_proof_upload_title;

  /// No description provided for @prices_generic_title.
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get prices_generic_title;

  /// No description provided for @prices_add_n_prices.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{Add a price} other{Add {count} prices}}'**
  String prices_add_n_prices(num count);

  /// No description provided for @prices_send_n_prices.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{Send the price} other{Send {count} prices}}'**
  String prices_send_n_prices(num count);

  /// No description provided for @prices_add_an_item.
  ///
  /// In en, this message translates to:
  /// **'Add an item'**
  String get prices_add_an_item;

  /// No description provided for @prices_add_a_price.
  ///
  /// In en, this message translates to:
  /// **'Add a price'**
  String get prices_add_a_price;

  /// No description provided for @prices_add_a_receipt.
  ///
  /// In en, this message translates to:
  /// **'Add a receipt'**
  String get prices_add_a_receipt;

  /// No description provided for @prices_add_price_tags.
  ///
  /// In en, this message translates to:
  /// **'Add price tags'**
  String get prices_add_price_tags;

  /// Error message about barcode being already there
  ///
  /// In en, this message translates to:
  /// **'This barcode ({barcode}) is already in the list!'**
  String prices_barcode_already(String barcode);

  /// No description provided for @prices_barcode_search_not_found.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get prices_barcode_search_not_found;

  /// No description provided for @prices_barcode_search_none_yet.
  ///
  /// In en, this message translates to:
  /// **'No product yet'**
  String get prices_barcode_search_none_yet;

  /// Dialog title about barcode look-up
  ///
  /// In en, this message translates to:
  /// **'Looking for {barcode}'**
  String prices_barcode_search_running(String barcode);

  /// No description provided for @prices_barcode_enter.
  ///
  /// In en, this message translates to:
  /// **'Enter the Barcode'**
  String get prices_barcode_enter;

  /// No description provided for @prices_category_enter.
  ///
  /// In en, this message translates to:
  /// **'Item without barcode'**
  String get prices_category_enter;

  /// Title for PricePer.kilogram
  ///
  /// In en, this message translates to:
  /// **'Price per kilogram'**
  String get prices_per_kilogram;

  /// Title for PricePer.unit
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get prices_per_unit;

  /// Short title for PricePer.kilogram
  ///
  /// In en, this message translates to:
  /// **' / kg'**
  String get prices_per_kilogram_short;

  /// Short title for PricePer.unit
  ///
  /// In en, this message translates to:
  /// **' / unit'**
  String get prices_per_unit_short;

  /// No description provided for @prices_category_mandatory.
  ///
  /// In en, this message translates to:
  /// **'Mandatory'**
  String get prices_category_mandatory;

  /// No description provided for @prices_category_optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get prices_category_optional;

  /// No description provided for @prices_category_error_mandatory.
  ///
  /// In en, this message translates to:
  /// **'The category is mandatory'**
  String get prices_category_error_mandatory;

  /// No description provided for @prices_barcode_reader_action.
  ///
  /// In en, this message translates to:
  /// **'Barcode reader'**
  String get prices_barcode_reader_action;

  /// No description provided for @prices_view_prices.
  ///
  /// In en, this message translates to:
  /// **'View the prices'**
  String get prices_view_prices;

  /// A card summarizing the number of prices for a product
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 price} other{{count} prices}} for {product}'**
  String prices_product_accessibility_summary(int count, String product);

  /// Number of prices for one-page result
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No price yet} =1{Only one price} other{All {count} prices}}'**
  String prices_list_length_one_page(int count);

  /// Number of prices for one-page result
  ///
  /// In en, this message translates to:
  /// **'Latest {pageSize} prices (total: {total})'**
  String prices_list_length_many_pages(int pageSize, int total);

  /// Accessibility label for a price entry
  ///
  /// In en, this message translates to:
  /// **'Price: {price} / Store: \"{location}\" / Published on {date} by \"{user}\"'**
  String prices_entry_accessibility_label(
    String price,
    String location,
    String date,
    String user,
  );

  /// Button to open the proofs of a user
  ///
  /// In en, this message translates to:
  /// **'Open proofs of \"{user}\"'**
  String prices_open_user_proofs(String user);

  /// Button to open a proof
  ///
  /// In en, this message translates to:
  /// **'Open price proof'**
  String get prices_open_proof;

  /// Number of proofs for one-page result
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No proof yet} =1{Only one proof} other{All {count} proofs}}'**
  String prices_proofs_list_length_one_page(int count);

  /// Number of proofs for one-page result
  ///
  /// In en, this message translates to:
  /// **'Latest {pageSize} proofs (total: {total})'**
  String prices_proofs_list_length_many_pages(int pageSize, int total);

  /// Number of users for one-page result
  ///
  /// In en, this message translates to:
  /// **'Top {pageSize} contributors (total: {total})'**
  String prices_users_list_length_many_pages(int pageSize, int total);

  /// Number of locations for one-page result
  ///
  /// In en, this message translates to:
  /// **'Top {pageSize} locations (total: {total})'**
  String prices_locations_list_length_many_pages(int pageSize, int total);

  /// Number of proofs, for a button
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No proof} =1{One proof} other{{count} proofs}}'**
  String prices_button_count_proof(int count);

  /// Number of products, for a button
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No product} =1{One product} other{{count} products}}'**
  String prices_button_count_product(int count);

  /// Number of users, for a button
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No user} =1{One user} other{{count} users}}'**
  String prices_button_count_user(int count);

  /// Number of prices, for a button
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No price} =1{One price} other{{count} prices}}'**
  String prices_button_count_price(int count);

  /// No description provided for @prices_amount_existing_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Price previously added'**
  String get prices_amount_existing_subtitle;

  /// No description provided for @prices_amount_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get prices_amount_subtitle;

  /// No description provided for @prices_amount_is_discounted.
  ///
  /// In en, this message translates to:
  /// **'Is discounted?'**
  String get prices_amount_is_discounted;

  /// No description provided for @prices_amount_price_normal.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get prices_amount_price_normal;

  /// No description provided for @prices_amount_price_discounted.
  ///
  /// In en, this message translates to:
  /// **'Discounted price'**
  String get prices_amount_price_discounted;

  /// No description provided for @prices_amount_price_not_discounted.
  ///
  /// In en, this message translates to:
  /// **'Original price'**
  String get prices_amount_price_not_discounted;

  /// No description provided for @prices_amount_no_product.
  ///
  /// In en, this message translates to:
  /// **'One product is missing!'**
  String get prices_amount_no_product;

  /// No description provided for @prices_amount_price_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect value'**
  String get prices_amount_price_incorrect;

  /// No description provided for @prices_amount_price_mandatory.
  ///
  /// In en, this message translates to:
  /// **'Mandatory value'**
  String get prices_amount_price_mandatory;

  /// No description provided for @prices_currency_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get prices_currency_subtitle;

  /// No description provided for @prices_date_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get prices_date_subtitle;

  /// No description provided for @prices_location_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get prices_location_subtitle;

  /// No description provided for @prices_location_find.
  ///
  /// In en, this message translates to:
  /// **'Find a shop'**
  String get prices_location_find;

  /// No description provided for @prices_location_mandatory.
  ///
  /// In en, this message translates to:
  /// **'You need to select a shop!'**
  String get prices_location_mandatory;

  /// No description provided for @prices_location_search_broader.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find what you were looking for? Let\'s try a broader search!'**
  String get prices_location_search_broader;

  /// No description provided for @prices_proof_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Proof'**
  String get prices_proof_subtitle;

  /// No description provided for @prices_proof_find.
  ///
  /// In en, this message translates to:
  /// **'Select a proof'**
  String get prices_proof_find;

  /// No description provided for @prices_proof_receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get prices_proof_receipt;

  /// No description provided for @prices_proof_price_tag.
  ///
  /// In en, this message translates to:
  /// **'Price tag'**
  String get prices_proof_price_tag;

  /// No description provided for @prices_proof_mandatory.
  ///
  /// In en, this message translates to:
  /// **'You need to select a proof!'**
  String get prices_proof_mandatory;

  /// No description provided for @prices_add_validation_error.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get prices_add_validation_error;

  /// No description provided for @prices_privacy_warning_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy warning'**
  String get prices_privacy_warning_title;

  /// Very small text, in the context of prices, to say that the product is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown product'**
  String get prices_unknown_product;

  /// No description provided for @prices_privacy_warning_main_message.
  ///
  /// In en, this message translates to:
  /// **'Prices **will be public**, along with the store they refer to.\n\nThat might allow people who know about your Open Food Facts pseudonym to:\n'**
  String get prices_privacy_warning_main_message;

  /// No description provided for @prices_privacy_warning_message_bullet_1.
  ///
  /// In en, this message translates to:
  /// **'Infer in which area you live'**
  String get prices_privacy_warning_message_bullet_1;

  /// No description provided for @prices_privacy_warning_message_bullet_2.
  ///
  /// In en, this message translates to:
  /// **'Know what you are buying'**
  String get prices_privacy_warning_message_bullet_2;

  /// No description provided for @prices_privacy_warning_sub_message.
  ///
  /// In en, this message translates to:
  /// **'If you are uneasy with that, please change your pseudonym, or create a new Open Food Facts account and log into the app with it.'**
  String get prices_privacy_warning_sub_message;

  /// No description provided for @i_refuse.
  ///
  /// In en, this message translates to:
  /// **'I refuse'**
  String get i_refuse;

  /// No description provided for @i_accept.
  ///
  /// In en, this message translates to:
  /// **'I accept'**
  String get i_accept;

  /// No description provided for @prices_currency_change_proposal_title.
  ///
  /// In en, this message translates to:
  /// **'Change the currency?'**
  String get prices_currency_change_proposal_title;

  /// Message to ask the user if they want to change the currency
  ///
  /// In en, this message translates to:
  /// **'Your current currency is **{currency}**. Would you like to change it to **{newCurrency}**?'**
  String prices_currency_change_proposal_message(
    String currency,
    String newCurrency,
  );

  /// Button to approve the currency change
  ///
  /// In en, this message translates to:
  /// **'Yes, use {newCurrency}'**
  String prices_currency_change_proposal_action_approve(String newCurrency);

  /// Button to cancel the currency change
  ///
  /// In en, this message translates to:
  /// **'No, keep {currency}'**
  String prices_currency_change_proposal_action_cancel(String currency);

  /// User dev preferences - Import history - Result successful
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dev_preferences_import_history_result_success;

  /// No description provided for @dev_mode_section_server.
  ///
  /// In en, this message translates to:
  /// **'Server configuration'**
  String get dev_mode_section_server;

  /// No description provided for @dev_mode_section_news.
  ///
  /// In en, this message translates to:
  /// **'News provider configuration'**
  String get dev_mode_section_news;

  /// No description provided for @dev_mode_section_product_page.
  ///
  /// In en, this message translates to:
  /// **'Product page'**
  String get dev_mode_section_product_page;

  /// No description provided for @dev_mode_section_ui.
  ///
  /// In en, this message translates to:
  /// **'User Interface'**
  String get dev_mode_section_ui;

  /// No description provided for @dev_mode_section_data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dev_mode_section_data;

  /// No description provided for @dev_mode_section_experimental_features.
  ///
  /// In en, this message translates to:
  /// **'Experimental features'**
  String get dev_mode_section_experimental_features;

  /// Title for switch toggle to show or hide folksonomy, product tags on product details page
  ///
  /// In en, this message translates to:
  /// **'Exclude Folksonomy'**
  String get dev_preferences_show_folksonomy_title;

  /// User dev preferences - Disable Green Score - Title
  ///
  /// In en, this message translates to:
  /// **'Exclude Green Score'**
  String get dev_mode_hide_environmental_score_title;

  /// User dev preferences - Enable Spellchecker on OCR screens - Title
  ///
  /// In en, this message translates to:
  /// **'Use a spellchecker for OCR screens'**
  String get dev_mode_spellchecker_for_ocr_title;

  /// User dev preferences - Enable Spellchecker on OCR screens - Subtitle
  ///
  /// In en, this message translates to:
  /// **'(Ingredients and packaging)'**
  String get dev_mode_spellchecker_for_ocr_subtitle;

  /// A tooltip to explain the Pen button near a search term -> it allows to reuse the item
  ///
  /// In en, this message translates to:
  /// **'Reuse and edit this search'**
  String get search_history_item_edit_tooltip;

  /// Product search list - No more results available
  ///
  /// In en, this message translates to:
  /// **'You\'ve downloaded all the {totalSize} products.'**
  String product_search_no_more_results(int totalSize);

  /// Product search list - Button to download more results
  ///
  /// In en, this message translates to:
  /// **'Download {count} more products\nAlready downloaded {downloaded} out of {totalSize}.'**
  String product_search_button_download_more(
    int count,
    int downloaded,
    int totalSize,
  );

  /// This message will be displayed when a search is in progress.
  ///
  /// In en, this message translates to:
  /// **'Your search of {search} is in progress.\n\nPlease wait a few seconds…'**
  String product_search_loading_message(Object search);

  /// User search (contributor): list tile title
  ///
  /// In en, this message translates to:
  /// **'Products I added'**
  String get user_search_contributor_title;

  /// User search (informer): list tile title
  ///
  /// In en, this message translates to:
  /// **'Products I edited'**
  String get user_search_informer_title;

  /// User search (photographer): list tile title
  ///
  /// In en, this message translates to:
  /// **'Products I photographed'**
  String get user_search_photographer_title;

  /// User search (to be completed): list tile title
  ///
  /// In en, this message translates to:
  /// **'My to-be-completed products'**
  String get user_search_to_be_completed_title;

  /// User prices: list tile title
  ///
  /// In en, this message translates to:
  /// **'My prices'**
  String get user_search_prices_title;

  /// User proofs: list tile title
  ///
  /// In en, this message translates to:
  /// **'My proofs'**
  String get user_search_proofs_title;

  /// User proof: page title
  ///
  /// In en, this message translates to:
  /// **'My proof'**
  String get user_search_proof_title;

  /// User prices (everybody except me): list tile title
  ///
  /// In en, this message translates to:
  /// **'Contributor prices'**
  String get user_any_search_prices_title;

  /// Latest prices: list tile title
  ///
  /// In en, this message translates to:
  /// **'Latest Prices added'**
  String get all_search_prices_latest_title;

  /// Top price users: list tile title
  ///
  /// In en, this message translates to:
  /// **'Top price contributors'**
  String get all_search_prices_top_user_title;

  /// Top price locations: list tile title
  ///
  /// In en, this message translates to:
  /// **'Stores with the most prices'**
  String get all_search_prices_top_location_title;

  /// No description provided for @prices_contribution_assistant.
  ///
  /// In en, this message translates to:
  /// **'Price Contribution Assistant'**
  String get prices_contribution_assistant;

  /// List of prices to validate
  ///
  /// In en, this message translates to:
  /// **'Price Validation Assistant'**
  String get prices_validation_assistant;

  /// Community challenges of open prices
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get prices_challenges_page;

  /// Upload multiple proofs
  ///
  /// In en, this message translates to:
  /// **'Add Multiple Proofs'**
  String get prices_multiple_proof_addition_system;

  /// Top price locations: list tile title
  ///
  /// In en, this message translates to:
  /// **'Prices in a store'**
  String get all_search_prices_top_location_single_title;

  /// Top price products: list tile title
  ///
  /// In en, this message translates to:
  /// **'Products with the most prices'**
  String get all_search_prices_top_product_title;

  /// All products to be completed: list tile title
  ///
  /// In en, this message translates to:
  /// **'All to-be-completed products'**
  String get all_search_to_be_completed_title;

  /// Help categorize products in your country: list tile title
  ///
  /// In en, this message translates to:
  /// **'Help categorize products in your country'**
  String get categorize_products_country_title;

  /// Product edition - FAB actions - retake a picture
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get edit_product_action_retake_picture;

  /// Product edition - FAB actions - take a picture
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get edit_product_action_take_picture;

  /// Product edition - FAB actions - confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get edit_product_action_confirm;

  /// User consent for terms of use (line 1)
  ///
  /// In en, this message translates to:
  /// **'I agree to the Open Food Facts '**
  String get signup_page_terms_of_use_line1;

  /// User consent for terms of use (line 2)
  ///
  /// In en, this message translates to:
  /// **'terms of use and contribution'**
  String get signup_page_terms_of_use_line2;

  /// Consent Analytics icon semantics label
  ///
  /// In en, this message translates to:
  /// **'Analytics icon'**
  String get analytics_consent_image_semantic_label;

  /// Knowledge panel page template - Error while loading future
  ///
  /// In en, this message translates to:
  /// **'Fatal Error: {error}'**
  String knowledge_panel_page_loading_error(Object? error);

  /// Preferences page - Error while loading future
  ///
  /// In en, this message translates to:
  /// **'Fatal Error: {error}'**
  String preferences_page_loading_error(Object? error);

  /// Summary card - Button to add details about the product
  ///
  /// In en, this message translates to:
  /// **'Complete basic details'**
  String get summary_card_button_add_basic_details;

  /// Edit photo button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit_photo_button_label;

  /// Edit 'unselect photo' button label
  ///
  /// In en, this message translates to:
  /// **'Unselect photo'**
  String get edit_photo_unselect_button_label;

  /// Edit 'select existing image' button label
  ///
  /// In en, this message translates to:
  /// **'Select an existing image'**
  String get edit_photo_select_existing_button_label;

  /// Page title
  ///
  /// In en, this message translates to:
  /// **'Existing images'**
  String get edit_photo_select_existing_all_label;

  /// Page title
  ///
  /// In en, this message translates to:
  /// **'Select an image by clicking on it'**
  String get edit_photo_select_existing_all_subtitle;

  /// Dialog label
  ///
  /// In en, this message translates to:
  /// **'Retrieving existing images…'**
  String get edit_photo_select_existing_download_label;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'There are no images previously uploaded related to this product.'**
  String get edit_photo_select_existing_downloaded_none;

  /// Warning message: for this product and this field, there are 'translated' images, but not in that language
  ///
  /// In en, this message translates to:
  /// **'No image in that language yet'**
  String get edit_photo_language_not_this_one;

  /// Warning message: for this product and this field, there are no images at all, in any language
  ///
  /// In en, this message translates to:
  /// **'No image yet'**
  String get edit_photo_language_none;

  /// Categories picker screen title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get category_picker_screen_title;

  /// No description provided for @basic_details.
  ///
  /// In en, this message translates to:
  /// **'Basic Details'**
  String get basic_details;

  /// No description provided for @product_name.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get product_name;

  /// Title for the section to edit the product name (in multiple languages)
  ///
  /// In en, this message translates to:
  /// **'Product Names'**
  String get product_names;

  /// Button to add a new translation for the product name
  ///
  /// In en, this message translates to:
  /// **'Add a new translation'**
  String get add_basic_details_product_name_add_translation;

  /// Warning message displayed on top of new translations for the product name
  ///
  /// In en, this message translates to:
  /// **'Before validating, please ensure you only add a translation **if the language is present on the packaging**'**
  String get add_basic_details_product_name_warning_translations;

  /// Button to view the front photo of the product (on top of the screen)
  ///
  /// In en, this message translates to:
  /// **'View front photo'**
  String get add_basic_details_product_name_open_photo;

  /// Button to take a photo of the front of the product (when there is no photo yet)
  ///
  /// In en, this message translates to:
  /// **'Take front photo'**
  String get add_basic_details_product_name_take_photo;

  /// Placeholder when the product name text-field is empty
  ///
  /// In en, this message translates to:
  /// **'Input the name of the product (eg: Nutella)'**
  String get add_basic_details_product_name_hint;

  /// Title for the section with good examples
  ///
  /// In en, this message translates to:
  /// **'Good examples'**
  String get explanation_section_good_examples;

  /// Title for the section with bad examples
  ///
  /// In en, this message translates to:
  /// **'Bad examples'**
  String get explanation_section_bad_examples;

  /// Title for the help section about the product name
  ///
  /// In en, this message translates to:
  /// **'Good practices: Product name'**
  String get add_basic_details_product_name_help_title;

  /// Text explaining how to write the product name
  ///
  /// In en, this message translates to:
  /// **'The product name is the **main name printed on the packaging**. It can be a registered trademark.'**
  String get add_basic_details_product_name_help_info1;

  /// Text explaining how to write the product name
  ///
  /// In en, this message translates to:
  /// **'**Note:** Please don\'t add a translation **if the language is not present on the packaging**.'**
  String get add_basic_details_product_name_help_info2;

  /// A 1st good example for the product name (you can change it if necessary)
  ///
  /// In en, this message translates to:
  /// **'Nesquik'**
  String get add_basic_details_product_name_help_good_examples_1;

  /// A 2nd good example for the product name (you can change it if necessary)
  ///
  /// In en, this message translates to:
  /// **'Tomato Ketchup'**
  String get add_basic_details_product_name_help_good_examples_2;

  /// Explanation for the first bad example
  ///
  /// In en, this message translates to:
  /// **'Don\'t include the brand in the name'**
  String get add_basic_details_product_name_help_bad_examples_1_explanation;

  /// First bad example for the product name
  ///
  /// In en, this message translates to:
  /// **'Tomato Ketchup **by Heinz**'**
  String get add_basic_details_product_name_help_bad_examples_1_example;

  /// Explanation for the second bad example
  ///
  /// In en, this message translates to:
  /// **'Don\'t use symbols ®, ™, © or similar'**
  String get add_basic_details_product_name_help_bad_examples_2_explanation;

  /// Second bad example for the product name
  ///
  /// In en, this message translates to:
  /// **'Nesquik**®**'**
  String get add_basic_details_product_name_help_bad_examples_2_example;

  /// The number of other translations for a product name (count is always >= 1)
  ///
  /// In en, this message translates to:
  /// **'{count,plural, one{{count} other translation} other{{count} other translations}}'**
  String add_basic_details_product_name_other_translations(int count);

  /// No description provided for @brand_name.
  ///
  /// In en, this message translates to:
  /// **'Brand name'**
  String get brand_name;

  /// No description provided for @brand_names.
  ///
  /// In en, this message translates to:
  /// **'Brand names'**
  String get brand_names;

  /// No description provided for @add_basic_details_brand_name_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter the brand name'**
  String get add_basic_details_brand_name_error;

  /// No description provided for @add_basic_details_brand_names_hint.
  ///
  /// In en, this message translates to:
  /// **'Input brands (eg: Ferrero)'**
  String get add_basic_details_brand_names_hint;

  /// Title for the help section about the product brands
  ///
  /// In en, this message translates to:
  /// **'Good practices: Brands'**
  String get add_basic_details_product_brand_help_title;

  /// Text explaining how to write brands
  ///
  /// In en, this message translates to:
  /// **'Input **all the brands of the product**.'**
  String get add_basic_details_product_brand_help_info1;

  /// Text explaining how to write brands
  ///
  /// In en, this message translates to:
  /// **'Main brand'**
  String get add_basic_details_product_brand_help_info2_title;

  /// Text explaining how to write brands
  ///
  /// In en, this message translates to:
  /// **'The **main brand**, generally clearly displayed on the front pack, should be **entered first**.'**
  String get add_basic_details_product_brand_help_info2_content;

  /// Text explaining how to write brands
  ///
  /// In en, this message translates to:
  /// **'Other brands'**
  String get add_basic_details_product_brand_help_info3_title;

  /// Text explaining how to write brands
  ///
  /// In en, this message translates to:
  /// **'When sold **by a big company**:'**
  String get add_basic_details_product_brand_help_info3_item1_text;

  /// Text explaining how to write brands
  ///
  /// In en, this message translates to:
  /// **'**Actimel** is sold by **Danone**'**
  String get add_basic_details_product_brand_help_info3_item1_explanation;

  /// Text explaining how to write brands
  ///
  /// In en, this message translates to:
  /// **'When sold with its brand **translated in multiple languages**:'**
  String get add_basic_details_product_brand_help_info3_item2_text;

  /// Text explaining how to write brands
  ///
  /// In en, this message translates to:
  /// **'**Nature Valley** is sometimes written **Val Nature**'**
  String get add_basic_details_product_brand_help_info3_item2_explanation;

  /// A 1st good example for the brand name (you can change it if necessary)
  ///
  /// In en, this message translates to:
  /// **'Nutella'**
  String get add_basic_details_product_brand_help_good_examples_1;

  /// A 2nd good example for the brand name (you can change it if necessary)
  ///
  /// In en, this message translates to:
  /// **'Oreo, Mondelez'**
  String get add_basic_details_product_brand_help_good_examples_2;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity and weight'**
  String get quantity;

  /// No description provided for @add_basic_details_quantity_hint.
  ///
  /// In en, this message translates to:
  /// **'Input the weight and if needed the quantity (eg : 4x100g)'**
  String get add_basic_details_quantity_hint;

  /// Title for the help section about the product quantity
  ///
  /// In en, this message translates to:
  /// **'Good practices: Quantity'**
  String get add_basic_details_product_quantity_help_title;

  /// Text explaining how to write quantity
  ///
  /// In en, this message translates to:
  /// **'Copy the value indicated on the product and **don\'t forget the units**.'**
  String get add_basic_details_product_quantity_help_info1;

  /// A 1st good example for the quantity (you can change it if necessary)
  ///
  /// In en, this message translates to:
  /// **'**230g** or **230 g**'**
  String get add_basic_details_product_quantity_help_good_examples_1;

  /// A 2nd good example for the quantity (you can change it if necessary)
  ///
  /// In en, this message translates to:
  /// **'**6** (for 6 eggs)'**
  String get add_basic_details_product_quantity_help_good_examples_2;

  /// A 2nd good example for the quantity (you can change it if necessary)
  ///
  /// In en, this message translates to:
  /// **'**3 x 150g**\n(for a product with 3 boxes, each of 150g)'**
  String get add_basic_details_product_quantity_help_good_examples_3;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// Displaying the raw barcode with label
  ///
  /// In en, this message translates to:
  /// **'Barcode: {barcode}'**
  String barcode_barcode(String barcode);

  /// No description provided for @barcode_invalid_error.
  ///
  /// In en, this message translates to:
  /// **'Invalid barcode'**
  String get barcode_invalid_error;

  /// No description provided for @basic_details_add_success.
  ///
  /// In en, this message translates to:
  /// **'Basic details added successfully'**
  String get basic_details_add_success;

  /// Error message when error occurs while submitting basic details
  ///
  /// In en, this message translates to:
  /// **'Unable to add basic details. Please try again after some time'**
  String get basic_details_add_error;

  /// No description provided for @clear_search.
  ///
  /// In en, this message translates to:
  /// **'Clear your search'**
  String get clear_search;

  /// Asking about whether to clear the history list or not
  ///
  /// In en, this message translates to:
  /// **'You\'re about to clear your entire history: are you sure you want to continue?'**
  String get confirm_clear;

  /// No description provided for @alert_clear_selected_user_list.
  ///
  /// In en, this message translates to:
  /// **'You\'re about to clear selected items in your history'**
  String get alert_clear_selected_user_list;

  /// No description provided for @confirm_clear_selected_user_list.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to continue?'**
  String get confirm_clear_selected_user_list;

  /// No description provided for @alert_select_items_to_clear.
  ///
  /// In en, this message translates to:
  /// **'Please select one or more items to clear'**
  String get alert_select_items_to_clear;

  /// Asking about whether to clear the list or not
  ///
  /// In en, this message translates to:
  /// **'You\'re about to clear this list ({name}): are you sure you want to continue?'**
  String confirm_clear_user_list(String name);

  /// Title when asking about whether to delete the list or not
  ///
  /// In en, this message translates to:
  /// **'Delete the list?'**
  String get confirm_delete_user_list_title;

  /// Message when asking about whether to delete the list or not
  ///
  /// In en, this message translates to:
  /// **'You\'re about to delete the list \"{name}\".\nAre you sure you want to continue?'**
  String confirm_delete_user_list_message(String name);

  /// Button to delete a list
  ///
  /// In en, this message translates to:
  /// **'Yes, I confirm'**
  String get confirm_delete_user_list_button;

  /// Used when user selects a food preference. example: Vegan importance; mandatory
  ///
  /// In en, this message translates to:
  /// **'{name} importance: {id}'**
  String importance_label(String name, String id);

  /// Title about the user lists in the user preferences
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get user_list_all_title;

  /// Small message when there are no user lists
  ///
  /// In en, this message translates to:
  /// **'Create your first list'**
  String get user_list_all_empty;

  /// Top title for the selection of a list
  ///
  /// In en, this message translates to:
  /// **'Select a list'**
  String get product_list_select;

  /// Length of a user product list
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{Empty list} =1{One product} other{{count} products}}'**
  String user_list_length(num count);

  /// Label for the add list button
  ///
  /// In en, this message translates to:
  /// **'Add list'**
  String get add_list_label;

  /// Tooltip (message displayed on long press) to open the user food preferences
  ///
  /// In en, this message translates to:
  /// **'Edit your food preferences'**
  String get open_food_preferences_tooltip;

  /// Label for the add photo button
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get add_photo_button_label;

  /// Label for the add PACKAGING photo button
  ///
  /// In en, this message translates to:
  /// **'Take photos of any packaging/recycling information'**
  String get add_packaging_photo_button_label;

  /// Label for the add ORIGIN photo button
  ///
  /// In en, this message translates to:
  /// **'Take photos of any origin information'**
  String get add_origin_photo_button_label;

  /// Label for the add EMB photo button
  ///
  /// In en, this message translates to:
  /// **'Take photos of any traceability code information'**
  String get add_emb_photo_button_label;

  /// Label for the add LABELS photo button
  ///
  /// In en, this message translates to:
  /// **'Take photos of any labels & certifications information'**
  String get add_label_photo_button_label;

  /// Title for the image source chooser
  ///
  /// In en, this message translates to:
  /// **'Choose image source'**
  String get choose_image_source_title;

  /// Body for the image source chooser
  ///
  /// In en, this message translates to:
  /// **'Please choose a image source'**
  String get choose_image_source_body;

  /// Label for the gallery image source
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery_source_label;

  /// On iOS, the user has refused to give the permission (title of the dialog)
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get gallery_source_access_denied_dialog_title;

  /// On iOS, the user has refused to give the permission
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, the application can\'t access your gallery, as you have previously denied the permission.\n\nPlease go to the app settings in your phone Settings -> Photos'**
  String get gallery_source_access_denied_dialog_message_ios;

  /// Button to open the app settings
  ///
  /// In en, this message translates to:
  /// **'Open the Settings'**
  String get gallery_source_access_denied_dialog_button;

  /// Button label for sharing something on another app. For example sharing the link to a product via Email
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// The content which is send, when sharing a 'food' product
  ///
  /// In en, this message translates to:
  /// **'Have a look at this product on Open Food Facts: {url}'**
  String share_product_text(String url);

  /// The content which is send, when sharing a 'beauty' product
  ///
  /// In en, this message translates to:
  /// **'Have a look at this product on Open Beauty Facts: {url}'**
  String share_product_text_beauty(String url);

  /// The content which is send, when sharing a 'pet food' product
  ///
  /// In en, this message translates to:
  /// **'Have a look at this product on Open PetFood Facts: {url}'**
  String share_product_text_pet_food(String url);

  /// The content which is send, when sharing a 'products' product
  ///
  /// In en, this message translates to:
  /// **'Have a look at this product on Open Products Facts: {url}'**
  String share_product_text_product(String url);

  /// The content which is send, when sharing a product list
  ///
  /// In en, this message translates to:
  /// **'Have a look at my list of products on Open Food Facts: {url}'**
  String share_product_list_text(String url);

  /// Button label for taking a new photo (= there's already one)
  ///
  /// In en, this message translates to:
  /// **'Take a new picture'**
  String get capture;

  /// Button label for taking a new photo (= the first one)
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get capture_new_picture;

  /// Button label for choosing a photo from gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get choose_from_gallery;

  /// Message when a photo is queued for upload
  ///
  /// In en, this message translates to:
  /// **'The image will be uploaded in the background as soon as possible.'**
  String get image_upload_queued;

  /// Message when an added price is queued for the server
  ///
  /// In en, this message translates to:
  /// **'The price will be sent to the server as soon as possible.'**
  String get add_price_queued;

  /// Snackbar message when a full refresh is started
  ///
  /// In en, this message translates to:
  /// **'Starting the refresh of all the products locally stored'**
  String get background_task_title_full_refresh;

  /// Snackbar message when a download of the most popular products is started
  ///
  /// In en, this message translates to:
  /// **'Starting the download of the most popular products'**
  String get background_task_title_top_n;

  /// Label for expanding nutrition facts table in application setting
  ///
  /// In en, this message translates to:
  /// **'Expand nutrition facts table'**
  String get expand_nutrition_facts;

  /// No description provided for @expand_nutrition_facts_body.
  ///
  /// In en, this message translates to:
  /// **'Keep the nutrition facts table expanded'**
  String get expand_nutrition_facts_body;

  /// Label for expanding nutrition facts table in application setting
  ///
  /// In en, this message translates to:
  /// **'Expand ingredients'**
  String get expand_ingredients;

  /// No description provided for @expand_ingredients_body.
  ///
  /// In en, this message translates to:
  /// **'Keep the ingredients panel expanded'**
  String get expand_ingredients_body;

  /// No description provided for @search_product_filter_visibility_title.
  ///
  /// In en, this message translates to:
  /// **'Show a filter in the search'**
  String get search_product_filter_visibility_title;

  /// Label for showing the product type filter in the search bar
  ///
  /// In en, this message translates to:
  /// **'Select search site: Open Food Facts, Open Beauty Facts, Open Pet Food Facts or Open Products Facts'**
  String get search_product_filter_visibility_subtitle;

  /// Message when there is no internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get no_internet_connection;

  /// Label describing the current source of the results: the entire world. Keep it short
  ///
  /// In en, this message translates to:
  /// **'Entire world'**
  String get world_results_label;

  /// Label for the action button that displays the results from the entire world
  ///
  /// In en, this message translates to:
  /// **'Extend your search to the world'**
  String get world_results_action;

  /// Copy to clipboard button description
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy_to_clipboard;

  /// Paste the content of the clipboard
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get paste_from_clipboard;

  /// No data available in your clipboard
  ///
  /// In en, this message translates to:
  /// **'No data available in your clipboard'**
  String get no_data_available_in_clipboard;

  /// No description provided for @clipboard_barcode_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy barcode to clipboard'**
  String get clipboard_barcode_copy;

  /// Snackbar label after clipboard copy
  ///
  /// In en, this message translates to:
  /// **'Barcode {barcode} copied to the clipboard!'**
  String clipboard_barcode_copied(Object barcode);

  /// No description provided for @open_product_website.
  ///
  /// In en, this message translates to:
  /// **'Open this product on the website'**
  String get open_product_website;

  /// Choose Application Language
  ///
  /// In en, this message translates to:
  /// **'Your language'**
  String get language_picker_label;

  /// Choose Application Country
  ///
  /// In en, this message translates to:
  /// **'Your country'**
  String get country_picker_label;

  /// Choose Application Country
  ///
  /// In en, this message translates to:
  /// **'Your currency'**
  String get currency_picker_label;

  /// Label for the email title
  ///
  /// In en, this message translates to:
  /// **'Help with OpenFoodFacts'**
  String get help_with_openfoodfacts;

  /// Message when a product is scheduled for background update
  ///
  /// In en, this message translates to:
  /// **'The product will be updated in the background as soon as possible.'**
  String get product_task_background_schedule;

  /// Title for the dialog when no email client is installed on the device
  ///
  /// In en, this message translates to:
  /// **'No email apps!'**
  String get no_email_client_available_dialog_title;

  /// Content for the dialog when no email client is installed on the device
  ///
  /// In en, this message translates to:
  /// **'Please send us manually an email to mobile@openfoodfacts.org'**
  String get no_email_client_available_dialog_content;

  /// No description provided for @all_images.
  ///
  /// In en, this message translates to:
  /// **'All Images'**
  String get all_images;

  /// No description provided for @selected_images.
  ///
  /// In en, this message translates to:
  /// **'Selected Images'**
  String get selected_images;

  /// Tooltip (message visible with a long-press) on a product item in the carousel
  ///
  /// In en, this message translates to:
  /// **'Remove product'**
  String get product_card_remove_product_tooltip;

  /// Text to pronounce by the Accessibility tool when a new barcode is decoded
  ///
  /// In en, this message translates to:
  /// **'New barcode scanned: {barcode}'**
  String scan_announce_new_barcode(String barcode);

  /// Tooltip (message visible with a long-press) on the Clear button on top of the scanner
  ///
  /// In en, this message translates to:
  /// **'Remove all products from the carousel'**
  String get scan_header_clear_button_tooltip;

  /// Tooltip (message visible with a long-press) on the Compare button on top of the scanner, when there is just one product scanned
  ///
  /// In en, this message translates to:
  /// **'Please scan at least two products to compare them'**
  String get scan_header_compare_button_invalid_state_tooltip;

  /// Tooltip (message visible with a long-press) on the Compare button on top of the scanner, when there is at least two products
  ///
  /// In en, this message translates to:
  /// **'Click to compare the products you have scanned'**
  String get scan_header_compare_button_valid_state_tooltip;

  /// Title when a product is loading (carousel card). Please ensure to keep the line break.
  ///
  /// In en, this message translates to:
  /// **'You have scanned\nthe barcode:'**
  String get scan_product_loading;

  /// Message when a product is loading (carousel card). Please ensure to keep the line break.
  ///
  /// In en, this message translates to:
  /// **'We\'re looking for this product!\nPlease wait a few seconds…'**
  String get scan_product_loading_initial;

  /// Message when a product is long to load (carousel card). Please ensure to keep the line break.
  ///
  /// In en, this message translates to:
  /// **'We\'re still looking for this product!\nDo you find it takes a long time to load? So are we…'**
  String get scan_product_loading_long_request;

  /// Message when a product is too long to load (carousel card). Please ensure to keep the line break.
  ///
  /// In en, this message translates to:
  /// **'We\'re still looking for this product.\nWould you like to restart the search?'**
  String get scan_product_loading_unresponsive;

  /// Button to force restart a product search
  ///
  /// In en, this message translates to:
  /// **'Restart search'**
  String get scan_product_loading_restart_button;

  /// Sort of title that describes the portion calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculate nutrition facts for a specific quantity'**
  String get portion_calculator_description;

  /// Hint to show when a quantity is empty in the portion calculator.
  ///
  /// In en, this message translates to:
  /// **'Quantity in'**
  String get portion_calculator_hint;

  /// Hint for the acessibility to explain to enter a quantity.
  ///
  /// In en, this message translates to:
  /// **'Input a quantity to calculate nutrition facts'**
  String get portion_calculator_accessibility;

  /// Error message to explain that the quantity is invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity between {min} and {max} g'**
  String portion_calculator_error(int min, int max);

  /// Error message to explain that the computation of the portion calculator failed.
  ///
  /// In en, this message translates to:
  /// **'Missing data. Calculation could not be performed.'**
  String get portion_calculator_computation_error;

  /// Title of the results of the portion calculator.
  ///
  /// In en, this message translates to:
  /// **'Nutrition facts for {grams} g (or ml)'**
  String portion_calculator_result_title(int grams);

  /// App bar title for the offline data page
  ///
  /// In en, this message translates to:
  /// **'Offline Data'**
  String get offline_data;

  /// Message shown when there is no image on the OCR extraction page for ingredients or recycling instructions
  ///
  /// In en, this message translates to:
  /// **'Upload an image to automatically extract the information it contains.'**
  String get ocr_image_upload_instruction;

  /// Message shown on asking to upload image
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get upload_image;

  /// Word separator character. In English language, this is a comma: ','
  ///
  /// In en, this message translates to:
  /// **','**
  String get word_separator_char;

  /// Word separator string. In English, this is a comma followed by a space: ', '
  ///
  /// In en, this message translates to:
  /// **', '**
  String get word_separator;

  /// Error message, when image download fails
  ///
  /// In en, this message translates to:
  /// **'Failed to download image'**
  String get image_download_error;

  /// Error message, when editing image fails, due to missing url.
  ///
  /// In en, this message translates to:
  /// **'Failed to edit image because the image URL was not set.'**
  String get image_edit_url_error;

  /// Checkbox label when select a picture source
  ///
  /// In en, this message translates to:
  /// **'Remember my choice'**
  String get user_picture_source_remember;

  /// Choice of asking the picture source every time
  ///
  /// In en, this message translates to:
  /// **'Ask each time'**
  String get user_picture_source_ask;

  /// Shown when robotoff question are all answered and user wants to continue answering
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get robotoff_continue;

  /// Shown when robotoff question are all answered and user wants to continue answering
  ///
  /// In en, this message translates to:
  /// **'Next {count,plural,  =1{question} other{{count} questions}}'**
  String robotoff_next_n_questions(num count);

  /// Show hidden password in password field
  ///
  /// In en, this message translates to:
  /// **'Show Password'**
  String get show_password;

  /// Title of the 'producer provided' info list-tile
  ///
  /// In en, this message translates to:
  /// **'Producer provided values'**
  String get owner_field_info_title;

  /// Title of the 'producer provided' info list-tile
  ///
  /// In en, this message translates to:
  /// **'With that logo we highlight data provided by the producer, and that may not be editable.'**
  String get owner_field_info_message;

  /// The owner info may be shown in a closeable dialog. This is the label of the button (used on a long press event and for the accessibility label).
  ///
  /// In en, this message translates to:
  /// **'Close this info'**
  String get owner_field_info_close_button;

  /// An image is directly provided by the producer. It may be locked and not be editable.
  ///
  /// In en, this message translates to:
  /// **'This image is provided by the producer. It may not be editable.'**
  String get owner_field_image;

  /// Title of the structured packagings page
  ///
  /// In en, this message translates to:
  /// **'Packaging components'**
  String get edit_packagings_title;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Add a packaging component'**
  String get edit_packagings_element_add;

  /// No description provided for @edit_packagings_completed.
  ///
  /// In en, this message translates to:
  /// **'The packaging is complete'**
  String get edit_packagings_completed;

  /// Element title. Please do not change the index placeholder
  ///
  /// In en, this message translates to:
  /// **'Packaging component #{index}'**
  String edit_packagings_element_title(int index);

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Number of units'**
  String get edit_packagings_element_field_units;

  /// Field verbose hint, more like an info than a text field hint
  ///
  /// In en, this message translates to:
  /// **'Enter the number of packaging units of the same shape and material contained in the product.'**
  String get edit_packagings_element_hint_units;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get edit_packagings_element_field_shape;

  /// Field verbose hint, more like an info than a text field hint
  ///
  /// In en, this message translates to:
  /// **'Enter the shape name listed in the recycling instructions if they are available, or select a shape.'**
  String get edit_packagings_element_hint_shape;

  /// Text field hint
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get edit_packagings_element_example_shape;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get edit_packagings_element_field_material;

  /// Field verbose hint, more like an info than a text field hint
  ///
  /// In en, this message translates to:
  /// **'Enter the specific material if it can be determined (a material code inside a triangle can often be found on packaging parts), or a generic material (for instance plastic or metal) if you are unsure.'**
  String get edit_packagings_element_hint_material;

  /// Text field hint
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get edit_packagings_element_example_material;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Recycling instruction'**
  String get edit_packagings_element_field_recycling;

  /// Field verbose hint, more like an info than a text field hint
  ///
  /// In en, this message translates to:
  /// **'Enter recycling instructions only if they are listed on the product.'**
  String get edit_packagings_element_hint_recycling;

  /// Text field hint
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get edit_packagings_element_example_recycling;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Net quantity of product per unit'**
  String get edit_packagings_element_field_quantity;

  /// Field verbose hint, more like an info than a text field hint
  ///
  /// In en, this message translates to:
  /// **'Enter the net weight or net volume and indicate the unit (for example g or ml).'**
  String get edit_packagings_element_hint_quantity;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Weight of one empty unit (g)'**
  String get edit_packagings_element_field_weight;

  /// Field verbose hint, more like an info than a text field hint
  ///
  /// In en, this message translates to:
  /// **'Remove any remaining food and wash and dry the packaging part before weighing. If possible, use a scale with 0.1g or 0.01g precision.'**
  String get edit_packagings_element_hint_weight;

  /// No description provided for @background_task_title.
  ///
  /// In en, this message translates to:
  /// **'Pending contributions'**
  String get background_task_title;

  /// No description provided for @background_task_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your contributions are automatically saved to our server, but not always in real-time.'**
  String get background_task_subtitle;

  /// No description provided for @background_task_list_empty.
  ///
  /// In en, this message translates to:
  /// **'No Pending Background Tasks'**
  String get background_task_list_empty;

  /// No description provided for @background_task_error_server_time_out.
  ///
  /// In en, this message translates to:
  /// **'Server timeout'**
  String get background_task_error_server_time_out;

  /// No description provided for @background_task_error_no_internet.
  ///
  /// In en, this message translates to:
  /// **'Internet connection error. Try later.'**
  String get background_task_error_no_internet;

  /// No description provided for @background_task_operation_unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown operation type'**
  String get background_task_operation_unknown;

  /// No description provided for @background_task_operation_details.
  ///
  /// In en, this message translates to:
  /// **'detailed changes'**
  String get background_task_operation_details;

  /// No description provided for @background_task_operation_image.
  ///
  /// In en, this message translates to:
  /// **'photo upload'**
  String get background_task_operation_image;

  /// No description provided for @background_task_operation_refresh.
  ///
  /// In en, this message translates to:
  /// **'refresh delayed after photo upload'**
  String get background_task_operation_refresh;

  /// No description provided for @background_task_run_started.
  ///
  /// In en, this message translates to:
  /// **'started'**
  String get background_task_run_started;

  /// No description provided for @background_task_run_not_started.
  ///
  /// In en, this message translates to:
  /// **'not started yet'**
  String get background_task_run_not_started;

  /// No description provided for @background_task_run_to_be_deleted.
  ///
  /// In en, this message translates to:
  /// **'to be deleted'**
  String get background_task_run_to_be_deleted;

  /// No description provided for @background_task_question_stop.
  ///
  /// In en, this message translates to:
  /// **'Do you want to stop that task ASAP?'**
  String get background_task_question_stop;

  /// No description provided for @feed_back.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feed_back;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Button: Copy the email adress to the clipboard. Shown when an automatic opening of an email application is not possible
  ///
  /// In en, this message translates to:
  /// **'Copy email to clipboard'**
  String get copy_email_to_clip_board;

  /// No description provided for @please_send_us_an_email_to.
  ///
  /// In en, this message translates to:
  /// **'Please send us manually an email to'**
  String get please_send_us_an_email_to;

  /// No description provided for @email_copied_to_clip_board.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard!'**
  String get email_copied_to_clip_board;

  /// Accent Color for the application in AMOLED mode.
  ///
  /// In en, this message translates to:
  /// **'Select Accent Color'**
  String get select_accent_color;

  /// AMOLED theme mode.
  ///
  /// In en, this message translates to:
  /// **'AMOLED'**
  String get theme_amoled;

  /// Color Blue
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get color_blue;

  /// Color Cyan
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get color_cyan;

  /// Color Green
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get color_green;

  /// Color Light Brown, Default Open Food Facts Color
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get color_light_brown;

  /// Color Magenta
  ///
  /// In en, this message translates to:
  /// **'Magenta'**
  String get color_magenta;

  /// Color Orange
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get color_orange;

  /// Color Pink
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get color_pink;

  /// Color Red
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get color_red;

  /// Color Rust
  ///
  /// In en, this message translates to:
  /// **'Rust'**
  String get color_rust;

  /// Color Teal
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get color_teal;

  /// Text Contrast Color Mode
  ///
  /// In en, this message translates to:
  /// **'Text Contrast'**
  String get text_contrast_mode;

  /// High Contrast Text Color
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get contrast_high;

  /// Medium Contrast Text Color
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get contrast_medium;

  /// Low Contrast Text Color
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get contrast_low;

  /// When refreshing a product that does not exist on the server. Label is the body of a dialog.
  ///
  /// In en, this message translates to:
  /// **'Product not found!'**
  String get product_refresher_internet_not_found;

  /// When refreshing a product and you're not even connected to internet. Label is the body of a dialog.
  ///
  /// In en, this message translates to:
  /// **'You are not connected to internet!'**
  String get product_refresher_internet_not_connected;

  /// When refreshing a product and you cannot even ping the server. Label is the body of a dialog.
  ///
  /// In en, this message translates to:
  /// **'Server down ({host})'**
  String product_refresher_internet_no_ping(String? host);

  /// When refreshing a product and the server returned an exception. Label is the body of a dialog.
  ///
  /// In en, this message translates to:
  /// **'Server error ({exception})'**
  String product_refresher_internet_error(String? exception);

  /// When fetching a product opened via a link and it doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Product not found!'**
  String get product_loader_not_found_title;

  /// When fetching a product opened via a link, it doesn't exist
  ///
  /// In en, this message translates to:
  /// **'A product with the following barcode doesn\'t exist in our database: {barcode}'**
  String product_loader_not_found_message(String barcode);

  /// When fetching a product opened via a link and there is no connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection!'**
  String get product_loader_network_error_title;

  /// When fetching a product opened via a link and there is no connection
  ///
  /// In en, this message translates to:
  /// **'Please check that your smartphone is on a WiFi network or has mobile data enabled'**
  String get product_loader_network_error_message;

  /// Title for a page not found (when an URL is not recognized)
  ///
  /// In en, this message translates to:
  /// **'Page not found!'**
  String get page_not_found_title;

  /// Button to go back to the homepage
  ///
  /// In en, this message translates to:
  /// **'Go back to the homepage'**
  String get page_not_found_button;

  /// App bar title for the download data page
  ///
  /// In en, this message translates to:
  /// **'Download data'**
  String get download_data;

  /// Download the top 1000 products in your country for instant scanning
  ///
  /// In en, this message translates to:
  /// **'Download the top 1000 products in your country for instant scanning'**
  String get download_top_products;

  /// No description provided for @download_top_n_products.
  ///
  /// In en, this message translates to:
  /// **'Download the top {count,plural,  other{{count} products}} in your country for instant scanning'**
  String download_top_n_products(int count);

  /// Download in progress
  ///
  /// In en, this message translates to:
  /// **'Downloading data\nThis may take a while'**
  String get download_in_progress;

  /// text to show when products added
  ///
  /// In en, this message translates to:
  /// **'{num} products added'**
  String downloaded_products(int num);

  /// List tile title for the update offline data page
  ///
  /// In en, this message translates to:
  /// **'Update offline product data'**
  String get update_offline_data;

  /// Update the local product database with the latest data from server
  ///
  /// In en, this message translates to:
  /// **'Update the local product database with the latest data from Open Food Facts'**
  String get update_local_database_sub;

  /// List tile title for the clear local database page
  ///
  /// In en, this message translates to:
  /// **'Clear offline product data'**
  String get clear_local_database;

  /// Clear all local product data from your app to free up space
  ///
  /// In en, this message translates to:
  /// **'Clear all local product data from your app to free up space'**
  String get clear_local_database_sub;

  /// text to show when products are deleted from local databse
  ///
  /// In en, this message translates to:
  /// **'{num} products deleted'**
  String deleted_products(int num);

  /// Loading…
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Know More
  ///
  /// In en, this message translates to:
  /// **'Know More'**
  String get know_more;

  /// Click to know more about offline data
  ///
  /// In en, this message translates to:
  /// **'Click to know more about offline data'**
  String get offline_data_desc;

  /// Offline Product Data
  ///
  /// In en, this message translates to:
  /// **'Offline product data'**
  String get offline_product_data_title;

  /// text to show details of products available for download
  ///
  /// In en, this message translates to:
  /// **'{num} products available for immediate scaning'**
  String available_for_download(int num);

  /// Label written as the title of the dialog to select the user country
  ///
  /// In en, this message translates to:
  /// **'Select your country:'**
  String get country_selector_title;

  /// Label written as the title of the dialog to select the user currency
  ///
  /// In en, this message translates to:
  /// **'Select your currency:'**
  String get currency_selector_title;

  /// Label written as the title of the dialog to select the user language
  ///
  /// In en, this message translates to:
  /// **'Select your language:'**
  String get language_selector_title;

  /// Label to highlight the selected languages
  ///
  /// In en, this message translates to:
  /// **'Selected languages'**
  String get language_selector_section_selected;

  /// Label to highlight the frequently used languages
  ///
  /// In en, this message translates to:
  /// **'Frequently used'**
  String get language_selector_section_frequently_used;

  /// Delete a list action in a menu
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get action_delete_list;

  /// Action to change the current visible list
  ///
  /// In en, this message translates to:
  /// **'Change the current list'**
  String get action_change_list;

  /// Button label to create a new list (short word)
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get product_list_create;

  /// Button description to create a new list (long sentence)
  ///
  /// In en, this message translates to:
  /// **'Create a new list'**
  String get product_list_create_tooltip;

  /// No description provided for @nutriscore_generic.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score'**
  String get nutriscore_generic;

  /// No description provided for @nutriscore_a.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score A'**
  String get nutriscore_a;

  /// No description provided for @nutriscore_b.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score B'**
  String get nutriscore_b;

  /// No description provided for @nutriscore_c.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score C'**
  String get nutriscore_c;

  /// No description provided for @nutriscore_d.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score D'**
  String get nutriscore_d;

  /// No description provided for @nutriscore_e.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score E'**
  String get nutriscore_e;

  /// A generic string to define a Nutri-Score V2 with a letter [eg: "Nutri-Score A (New calculation)"]
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score {letter} (New calculation)'**
  String nutriscore_new_formula(String letter);

  /// No description provided for @nutriscore_new_formula_title.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score (New calculation)'**
  String get nutriscore_new_formula_title;

  /// No description provided for @nutriscore_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Nutri-Score'**
  String get nutriscore_unknown;

  /// No description provided for @nutriscore_unknown_new_formula.
  ///
  /// In en, this message translates to:
  /// **'Unknown Nutri-Score (New calculation)'**
  String get nutriscore_unknown_new_formula;

  /// No description provided for @nutriscore_not_applicable.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score is not applicable'**
  String get nutriscore_not_applicable;

  /// No description provided for @nutriscore_not_applicable_new_formula.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score is not applicable (New calculation)'**
  String get nutriscore_not_applicable_new_formula;

  /// No description provided for @environmental_score_generic.
  ///
  /// In en, this message translates to:
  /// **'Green Score'**
  String get environmental_score_generic;

  /// No description provided for @environmental_score_a.
  ///
  /// In en, this message translates to:
  /// **'Green Score A'**
  String get environmental_score_a;

  /// No description provided for @environmental_score_b.
  ///
  /// In en, this message translates to:
  /// **'Green Score B'**
  String get environmental_score_b;

  /// No description provided for @environmental_score_c.
  ///
  /// In en, this message translates to:
  /// **'Green Score C'**
  String get environmental_score_c;

  /// No description provided for @environmental_score_d.
  ///
  /// In en, this message translates to:
  /// **'Green Score D'**
  String get environmental_score_d;

  /// No description provided for @environmental_score_e.
  ///
  /// In en, this message translates to:
  /// **'Green Score E'**
  String get environmental_score_e;

  /// No description provided for @environmental_score_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Green Score'**
  String get environmental_score_unknown;

  /// No description provided for @environmental_score_not_applicable.
  ///
  /// In en, this message translates to:
  /// **'Green Score is not applicable'**
  String get environmental_score_not_applicable;

  /// No description provided for @nova_group_generic.
  ///
  /// In en, this message translates to:
  /// **'Ultra-processing - NOVA groups'**
  String get nova_group_generic;

  /// No description provided for @nova_group_1.
  ///
  /// In en, this message translates to:
  /// **'NOVA Group 1'**
  String get nova_group_1;

  /// No description provided for @nova_group_2.
  ///
  /// In en, this message translates to:
  /// **'NOVA Group 2'**
  String get nova_group_2;

  /// No description provided for @nova_group_3.
  ///
  /// In en, this message translates to:
  /// **'NOVA Group 3'**
  String get nova_group_3;

  /// No description provided for @nova_group_4.
  ///
  /// In en, this message translates to:
  /// **'NOVA Group 4'**
  String get nova_group_4;

  /// No description provided for @nova_group_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown NOVA Group'**
  String get nova_group_unknown;

  /// No description provided for @nutrition_facts.
  ///
  /// In en, this message translates to:
  /// **'Nutrient Levels'**
  String get nutrition_facts;

  /// No description provided for @faq_title_partners.
  ///
  /// In en, this message translates to:
  /// **'Partners & Patrons of the NGO'**
  String get faq_title_partners;

  /// No description provided for @faq_title_vision.
  ///
  /// In en, this message translates to:
  /// **'The Open Food Facts Vision, Mission, Values and Programs'**
  String get faq_title_vision;

  /// No description provided for @faq_title_install_beauty.
  ///
  /// In en, this message translates to:
  /// **'Install Open Beauty Facts to create a cosmetic database'**
  String get faq_title_install_beauty;

  /// No description provided for @faq_title_install_pet.
  ///
  /// In en, this message translates to:
  /// **'Install Open Pet Food Facts to create a pet food database'**
  String get faq_title_install_pet;

  /// No description provided for @faq_title_install_product.
  ///
  /// In en, this message translates to:
  /// **'Install Open Products Facts to create a products database to extend the life of objects'**
  String get faq_title_install_product;

  /// No description provided for @faq_nutriscore_nutriscore.
  ///
  /// In en, this message translates to:
  /// **'New calculation of the Nutri-Score: what\'s new?'**
  String get faq_nutriscore_nutriscore;

  /// No description provided for @contact_title_pro_page.
  ///
  /// In en, this message translates to:
  /// **'Pro? Import your products in Open Food Facts'**
  String get contact_title_pro_page;

  /// No description provided for @contact_title_pro_email.
  ///
  /// In en, this message translates to:
  /// **'Producer Contact'**
  String get contact_title_pro_email;

  /// No description provided for @contact_title_press_page.
  ///
  /// In en, this message translates to:
  /// **'Press Page'**
  String get contact_title_press_page;

  /// No description provided for @contact_title_press_email.
  ///
  /// In en, this message translates to:
  /// **'Press Contact'**
  String get contact_title_press_email;

  /// No description provided for @contact_title_newsletter.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to our newsletter'**
  String get contact_title_newsletter;

  /// No description provided for @contact_title_calendar.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to our community calendar'**
  String get contact_title_calendar;

  /// No description provided for @hunger_games_loading_line1.
  ///
  /// In en, this message translates to:
  /// **'Please give us a few seconds…'**
  String get hunger_games_loading_line1;

  /// No description provided for @hunger_games_loading_line2.
  ///
  /// In en, this message translates to:
  /// **'We\'re downloading the questions!'**
  String get hunger_games_loading_line2;

  /// No description provided for @hunger_games_error_label.
  ///
  /// In en, this message translates to:
  /// **'Argh! Something went wrong… and we couldn\'t load the questions.'**
  String get hunger_games_error_label;

  /// No description provided for @hunger_games_error_retry_button.
  ///
  /// In en, this message translates to:
  /// **'Let\'s retry!'**
  String get hunger_games_error_retry_button;

  /// An action button or a page title about reordering the attributes (e.g. 'is vegan?', 'nutrition facts', ...)
  ///
  /// In en, this message translates to:
  /// **'Reorder the attributes'**
  String get reorder_attribute_action;

  /// An error may happen if the device doesn't have a browser installed.
  ///
  /// In en, this message translates to:
  /// **'This link can\'t be opened on your device. Please check that you have a browser installed.'**
  String get link_cant_be_opened;

  /// The title of the page when we click on an item in the product page and this page is unnamed
  ///
  /// In en, this message translates to:
  /// **'Details for {productName}'**
  String knowledge_panel_page_title_no_title(String productName);

  /// The title of the page when we click on an item in the product page
  ///
  /// In en, this message translates to:
  /// **'Details for {pageName} with {productName}'**
  String knowledge_panel_page_title(String pageName, String productName);

  /// A title for a guide
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide_title;

  /// No description provided for @guide_share_label.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get guide_share_label;

  /// Please NEVER touch this value and let the OFF team change it!
  ///
  /// In en, this message translates to:
  /// **'true'**
  String get guide_nutriscore_v2_enabled;

  /// The title of the guide (please don't forget the use of non-breaking spaces)
  ///
  /// In en, this message translates to:
  /// **'The Nutri-Score is evolving: explanations!'**
  String get guide_nutriscore_v2_title;

  /// No description provided for @guide_nutriscore_v2_what_is_nutriscore_title.
  ///
  /// In en, this message translates to:
  /// **'What is the Nutri-Score?'**
  String get guide_nutriscore_v2_what_is_nutriscore_title;

  /// Text between asterisks (eg: **My Text**) means text in bold. Please try to keep it.
  ///
  /// In en, this message translates to:
  /// **'The Nutri-Score is a logo which aims to inform you about the **nutritional quality of foods**.'**
  String get guide_nutriscore_v2_what_is_nutriscore_paragraph1;

  /// Text between asterisks (eg: **My Text**) means text in bold. Please try to keep it.
  ///
  /// In en, this message translates to:
  /// **'The color code varies from dark green (**A**) for the **healthiest** products to dark red (**E**) for the **less healthy** ones.'**
  String get guide_nutriscore_v2_what_is_nutriscore_paragraph2;

  /// No description provided for @guide_nutriscore_v2_nutriscore_a_caption.
  ///
  /// In en, this message translates to:
  /// **'The Nutri-Score A logo'**
  String get guide_nutriscore_v2_nutriscore_a_caption;

  /// No description provided for @guide_nutriscore_v2_why_v2_title.
  ///
  /// In en, this message translates to:
  /// **'Why is Nutri-Score evolving?'**
  String get guide_nutriscore_v2_why_v2_title;

  /// No description provided for @guide_nutriscore_v2_why_v2_intro.
  ///
  /// In en, this message translates to:
  /// **'The Nutri-Score formula **is evolving** to provide better recommendations:'**
  String get guide_nutriscore_v2_why_v2_intro;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg1_title.
  ///
  /// In en, this message translates to:
  /// **'Better evaluate all drinks'**
  String get guide_nutriscore_v2_why_v2_arg1_title;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg1_text.
  ///
  /// In en, this message translates to:
  /// **'The comparative notes of **milk**, **dairy drinks** with added sugar and **vegetable** drinks were better differentiated in the new algorithm.'**
  String get guide_nutriscore_v2_why_v2_arg1_text;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg2_title.
  ///
  /// In en, this message translates to:
  /// **'Better ranking of drinks'**
  String get guide_nutriscore_v2_why_v2_arg2_title;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg2_text.
  ///
  /// In en, this message translates to:
  /// **'The **sugar content** is better taken into account and favors **lowly sweetened** drinks.\\n**Sweeteners will also be penalized**: diet sodas will be downgraded from a B rating to between C and E. Water remains the recommended drink.'**
  String get guide_nutriscore_v2_why_v2_arg2_text;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg3_title.
  ///
  /// In en, this message translates to:
  /// **'Salt and sugar penalized'**
  String get guide_nutriscore_v2_why_v2_arg3_title;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg3_text.
  ///
  /// In en, this message translates to:
  /// **'Products **too sweet** or **too salty** will see their **rating further downgraded**.'**
  String get guide_nutriscore_v2_why_v2_arg3_text;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg4_title.
  ///
  /// In en, this message translates to:
  /// **'Hierarchy within oils and fishes'**
  String get guide_nutriscore_v2_why_v2_arg4_title;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg4_text.
  ///
  /// In en, this message translates to:
  /// **'The rating of certain **fatty fish** and **oils rich in good fats** will improve.'**
  String get guide_nutriscore_v2_why_v2_arg4_text;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg5_title.
  ///
  /// In en, this message translates to:
  /// **'Limit red meat'**
  String get guide_nutriscore_v2_why_v2_arg5_title;

  /// No description provided for @guide_nutriscore_v2_why_v2_arg5_text.
  ///
  /// In en, this message translates to:
  /// **'Consumption of **red meat should be limited**. This is why **poultry will be comparatively better ranked**.'**
  String get guide_nutriscore_v2_why_v2_arg5_text;

  /// No description provided for @guide_nutriscore_v2_new_logo_title.
  ///
  /// In en, this message translates to:
  /// **'How to differentiate old Nutri-Score and new calculation?'**
  String get guide_nutriscore_v2_new_logo_title;

  /// No description provided for @guide_nutriscore_v2_new_logo_text.
  ///
  /// In en, this message translates to:
  /// **'From now on, the logo can display a mention \"**New calculation**\" to clarify that this is indeed the new calculation.'**
  String get guide_nutriscore_v2_new_logo_text;

  /// No description provided for @guide_nutriscore_v2_new_logo_image_caption.
  ///
  /// In en, this message translates to:
  /// **'The logo of the new Nutri-Score'**
  String get guide_nutriscore_v2_new_logo_image_caption;

  /// No description provided for @guide_nutriscore_v2_where_title.
  ///
  /// In en, this message translates to:
  /// **'Where to find the new Nutri-Score calculation?'**
  String get guide_nutriscore_v2_where_title;

  /// No description provided for @guide_nutriscore_v2_where_paragraph1.
  ///
  /// In en, this message translates to:
  /// **'The Nutri-Score is applied in 7 countries: France, Germany, Belgium, Spain, Luxembourg, the Netherlands and Switzerland.'**
  String get guide_nutriscore_v2_where_paragraph1;

  /// No description provided for @guide_nutriscore_v2_where_paragraph2.
  ///
  /// In en, this message translates to:
  /// **'Manufacturers have at most **2 years** at the latest after the signature of the decree **to replace** the old calculation with the new one.'**
  String get guide_nutriscore_v2_where_paragraph2;

  /// No description provided for @guide_nutriscore_v2_where_paragraph3.
  ///
  /// In en, this message translates to:
  /// **'Without waiting, you **will already find in the OpenFoodFacts application**, the new calculation, including if the manufacturers have not updated the score.'**
  String get guide_nutriscore_v2_where_paragraph3;

  /// No description provided for @guide_nutriscore_v2_unchanged_title.
  ///
  /// In en, this message translates to:
  /// **'What doesn\'t change'**
  String get guide_nutriscore_v2_unchanged_title;

  /// No description provided for @guide_nutriscore_v2_unchanged_paragraph1.
  ///
  /// In en, this message translates to:
  /// **'The Nutri-Score is a score designed to **measure nutritional quality**. It is **complementary to the NOVA group** on **ultra-processed foods** (also present in the application).'**
  String get guide_nutriscore_v2_unchanged_paragraph1;

  /// No description provided for @guide_nutriscore_v2_unchanged_paragraph2.
  ///
  /// In en, this message translates to:
  /// **'For manufacturers, the display of the Nutri-Score **remains optional**.'**
  String get guide_nutriscore_v2_unchanged_paragraph2;

  /// No description provided for @guide_nutriscore_v2_share_link.
  ///
  /// In en, this message translates to:
  /// **'https://world.openfoodfacts.org/nutriscore-v2'**
  String get guide_nutriscore_v2_share_link;

  /// Please let empty for now (maybe use in the future)
  ///
  /// In en, this message translates to:
  /// **''**
  String get guide_nutriscore_v2_share_message;

  /// Badge to indicate that the product is in preview mode (Be careful with this translation)
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview_badge;

  /// A button to send feedback about the prices feature
  ///
  /// In en, this message translates to:
  /// **'Click here to send us your feedback about this new feature!'**
  String get prices_feedback_form;

  /// Button to select an action in a list (eg: Share, Delete, …)
  ///
  /// In en, this message translates to:
  /// **'Select an action'**
  String get menu_button_list_actions;

  /// Error message when loading a photo fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading photo'**
  String get error_loading_photo;

  /// An action to use the current picture to be used as front/ingredients…
  ///
  /// In en, this message translates to:
  /// **'Use as…'**
  String get photo_viewer_action_use_picture_as;

  /// Message explaining what the three dots (…) button on "More interesting photos" does
  ///
  /// In en, this message translates to:
  /// **'Use this picture as…'**
  String get photo_viewer_use_picture_as_tooltip;

  /// The title of a dialog to use the current picture as front/ingredients…
  ///
  /// In en, this message translates to:
  /// **'Use this picture as… ({language})'**
  String photo_viewer_use_picture_as_title(String language);

  /// Button to show details of the photo
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get photo_viewer_details_button;

  /// Accessibility label for the Details button on a photo
  ///
  /// In en, this message translates to:
  /// **'Details of this photo'**
  String get photo_viewer_details_button_accessibility_label;

  /// Title of the photo details dialog
  ///
  /// In en, this message translates to:
  /// **'Details of the photo'**
  String get photo_viewer_details_title;

  /// Label for the author of a photo
  ///
  /// In en, this message translates to:
  /// **'Contributor'**
  String get photo_viewer_details_contributor_title;

  /// Label for the size of a photo
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get photo_viewer_details_size_title;

  /// Value for the size of a photo
  ///
  /// In en, this message translates to:
  /// **'{width} x {height} pixels'**
  String photo_viewer_details_size_value(int width, int height);

  /// Label for the uploaded date of a photo
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get photo_viewer_details_date_title;

  /// Label for the link of a photo
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get photo_viewer_details_url_title;

  /// Compatibility score on top of the product page. The sentence is "100%" Compatible
  ///
  /// In en, this message translates to:
  /// **'Compatible'**
  String get product_page_compatibility_score;

  /// The button label for multi-selecting products in a user list
  ///
  /// In en, this message translates to:
  /// **'Multi-select'**
  String get user_lists_action_multi_select;

  /// Message explaining that the score is the compatibility score
  ///
  /// In en, this message translates to:
  /// **'Your compatibility score: {score}%'**
  String product_page_compatibility_score_tooltip(String score);

  /// Accessibility label for the image on the product page
  ///
  /// In en, this message translates to:
  /// **'Front picture'**
  String get product_image_front_accessibility_label;

  /// Accessibility label for the image of ingredients
  ///
  /// In en, this message translates to:
  /// **'Ingredients picture'**
  String get product_image_ingredients_accessibility_label;

  /// Accessibility label for the image of the nutrition
  ///
  /// In en, this message translates to:
  /// **'Nutrition picture'**
  String get product_image_nutrition_accessibility_label;

  /// Accessibility label for the image of the packaging
  ///
  /// In en, this message translates to:
  /// **'Packaging picture'**
  String get product_image_packaging_accessibility_label;

  /// Accessibility label for an image
  ///
  /// In en, this message translates to:
  /// **'Other picture'**
  String get product_image_other_accessibility_label;

  /// Small message to indicate that the image may be outdated
  ///
  /// In en, this message translates to:
  /// **'This picture may be outdated'**
  String get product_image_outdated_message;

  /// Accessibility label for the image on the product page when it may be outdated
  ///
  /// In en, this message translates to:
  /// **'{type} (this image may be outdated)'**
  String product_image_outdated_message_accessibility_label(String type);

  /// Accessibility label for the image on the product page when it may be locked (producer provided)
  ///
  /// In en, this message translates to:
  /// **'{type} (this image may be locked by the producer)'**
  String product_image_locked_message_accessibility_label(String type);

  /// Small message that will be displayed above the picture (please keep it short)
  ///
  /// In en, this message translates to:
  /// **'Unable to load the image!'**
  String get product_image_error;

  /// Accessibility label for the image on the product page when it fails to load
  ///
  /// In en, this message translates to:
  /// **'Unable to load the {type} (network error?)'**
  String product_image_error_accessibility_label(String type);

  /// Small message that will be displayed above the picture (please keep it short) when there is no image available on the database. A line break is not mandatory.
  ///
  /// In en, this message translates to:
  /// **'No\nimage!'**
  String get product_page_image_no_image_available;

  /// Accessibility label for the image on the product page when there is no image available on the database
  ///
  /// In en, this message translates to:
  /// **'No picture available for this product'**
  String get product_page_image_no_image_available_accessibility_label;

  /// Accessibility label for the Settings icon in the action bar (= bottom bar) on the product page
  ///
  /// In en, this message translates to:
  /// **'Reorder or hide actions'**
  String get product_page_action_bar_settings_accessibility_label;

  /// Title for the modal allowing to show and reorder actions
  ///
  /// In en, this message translates to:
  /// **'Edit actions'**
  String get product_page_action_bar_setting_modal_title;

  /// Accessibility label to move up an action
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get product_page_action_bar_item_move_up;

  /// Accessibility label to move down an action
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get product_page_action_bar_item_move_down;

  /// Accessibility label to enable action (= make it visible)
  ///
  /// In en, this message translates to:
  /// **'Enable action'**
  String get product_page_action_bar_item_enable;

  /// Accessibility label to disable action (= make it invisible)
  ///
  /// In en, this message translates to:
  /// **'Disable action'**
  String get product_page_action_bar_item_disable;

  /// When a product has pending edits (being sent to the server), there is a message on the product page (here is the title of the message).
  ///
  /// In en, this message translates to:
  /// **'Uploading your edits…'**
  String get product_page_pending_operations_banner_title;

  /// When a product has pending edits (being sent to the server), there is a message on the product page. Please keep the ** syntax to make the text bold.
  ///
  /// In en, this message translates to:
  /// **'The data displayed on this page **does not yet reflect your modifications**.\nPlease wait a few seconds…'**
  String get product_page_pending_operations_banner_message;

  /// Button to add a language (eg: for photos) to a product
  ///
  /// In en, this message translates to:
  /// **'Add a language'**
  String get product_add_a_language;

  /// Accessibility label for a barcode image
  ///
  /// In en, this message translates to:
  /// **'Barcode {barcode}'**
  String barcode_accessibility_label(String barcode);

  /// A message explaining the goal of the Close button on a card of the carousel
  ///
  /// In en, this message translates to:
  /// **'Remove this product from the carousel'**
  String get carousel_close_tooltip;

  /// A label on top of the carousel card when the barcode is not supported by the app
  ///
  /// In en, this message translates to:
  /// **'Unsupported barcode!'**
  String get carousel_unsupported_header;

  /// No description provided for @carousel_unsupported_title.
  ///
  /// In en, this message translates to:
  /// **'Ooops!'**
  String get carousel_unsupported_title;

  /// No description provided for @carousel_unsupported_text.
  ///
  /// In en, this message translates to:
  /// **'The barcode scanned is not supported by Open Food Facts!'**
  String get carousel_unsupported_text;

  /// A label on top of the carousel card when there is an error (mainly network issues)
  ///
  /// In en, this message translates to:
  /// **'Error!'**
  String get carousel_error_header;

  /// No description provided for @carousel_error_title.
  ///
  /// In en, this message translates to:
  /// **'It\'s a bummer!'**
  String get carousel_error_title;

  /// No description provided for @carousel_error_text_1.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t download information on this barcode:'**
  String get carousel_error_text_1;

  /// Please keep the ** syntax to make the text bold
  ///
  /// In en, this message translates to:
  /// **'Please check your Internet connection or click this button:'**
  String get carousel_error_text_2;

  /// No description provided for @carousel_error_button.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get carousel_error_button;

  /// A label on top of the carousel card when the product is not in the database (= it needs to be created)
  ///
  /// In en, this message translates to:
  /// **'Unknown product'**
  String get carousel_unknown_product_header;

  /// Please keep the __ syntax to underline the text
  ///
  /// In en, this message translates to:
  /// **'Congratulations!\nYou\'ve found __the rare gem!__'**
  String get carousel_unknown_product_title;

  /// Please keep the ** syntax to make the text bold
  ///
  /// In en, this message translates to:
  /// **'Our collaborative database contains more than **3 million products**, but this barcode doesn\'t exist: '**
  String get carousel_unknown_product_text;

  /// No description provided for @carousel_unknown_product_button.
  ///
  /// In en, this message translates to:
  /// **'Add this product'**
  String get carousel_unknown_product_button;

  /// A label on top of the carousel card when data about the product is loading
  ///
  /// In en, this message translates to:
  /// **'Loading information...'**
  String get carousel_loading_header;

  /// No description provided for @carousel_loading_title.
  ///
  /// In en, this message translates to:
  /// **'You\'ve just scanned a product with the following barcode:'**
  String get carousel_loading_title;

  /// Please keep the ** syntax to make the text bold
  ///
  /// In en, this message translates to:
  /// **'We are searching for it in our database of more than **3 million products!**'**
  String get carousel_loading_text;

  /// Example of products for food category
  ///
  /// In en, this message translates to:
  /// **'Vegetables, fruits, frozen food…'**
  String get product_type_subtitle_food;

  /// Example of products for beauty category
  ///
  /// In en, this message translates to:
  /// **'Makeup, soaps, toothpastes…'**
  String get product_type_subtitle_beauty;

  /// Example of products for pet food category
  ///
  /// In en, this message translates to:
  /// **'Food for dogs, cats…'**
  String get product_type_subtitle_pet_food;

  /// Example of products for other categories
  ///
  /// In en, this message translates to:
  /// **'Smartphones, furniture…'**
  String get product_type_subtitle_product;

  /// No description provided for @photo_field_front.
  ///
  /// In en, this message translates to:
  /// **'Product photo'**
  String get photo_field_front;

  /// No description provided for @photo_field_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients photo'**
  String get photo_field_ingredients;

  /// No description provided for @photo_field_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition photo'**
  String get photo_field_nutrition;

  /// No description provided for @photo_field_packaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging information photo'**
  String get photo_field_packaging;

  /// No description provided for @photo_already_exists.
  ///
  /// In en, this message translates to:
  /// **'This photo already exists'**
  String get photo_already_exists;

  /// No description provided for @photo_missing.
  ///
  /// In en, this message translates to:
  /// **'This photo is missing'**
  String get photo_missing;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Button to rotate a photo to the left
  ///
  /// In en, this message translates to:
  /// **'Rotate left'**
  String get photo_rotate_left;

  /// Button to rotate a photo to the right
  ///
  /// In en, this message translates to:
  /// **'Rotate right'**
  String get photo_rotate_right;

  /// Button to undo the previous action on a photo
  ///
  /// In en, this message translates to:
  /// **'Undo the previous action'**
  String get photo_undo_action;

  /// Accessibility label for the world map in the knowledge panel
  ///
  /// In en, this message translates to:
  /// **'A world map of {location}'**
  String knowledge_panel_world_map_accessibility_label(String location);

  /// Attribution for OpenStreetMap contributors
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap contributors'**
  String get open_street_map_contributor_attribution;

  /// Acronym for Not Applicable
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get not_applicable_short;

  /// Warning text at the beginning of a sentence in the knowledge panel (you can find this word on the NutriScore KP of 3033491279300)
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get knowledge_panel_warning_text;

  /// No description provided for @knowledge_panel_nutriscore_banner_incorrect_score_title.
  ///
  /// In en, this message translates to:
  /// **'Why is this Nutri-Score different from the one on the package?'**
  String get knowledge_panel_nutriscore_banner_incorrect_score_title;

  /// No description provided for @knowledge_panel_nutriscore_banner_incorrect_score_message.
  ///
  /// In en, this message translates to:
  /// **'There are two possible explanations:\nThe list of ingredients and/or nutrition facts are not up-to-date.\n\nWe provide the \"New calculation\" of the Nutri-Score (or V2). Please check that you have the banner \"New calculation\" on the package.'**
  String get knowledge_panel_nutriscore_banner_incorrect_score_message;

  /// No description provided for @knowledge_panel_nutriscore_banner_incorrect_score_button1.
  ///
  /// In en, this message translates to:
  /// **'Check ingredients'**
  String get knowledge_panel_nutriscore_banner_incorrect_score_button1;

  /// No description provided for @knowledge_panel_nutriscore_banner_incorrect_score_button2.
  ///
  /// In en, this message translates to:
  /// **'Check nutrition facts'**
  String get knowledge_panel_nutriscore_banner_incorrect_score_button2;

  /// Error message when the app can't open a URL
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, we can\'t open the URL:\n{url}'**
  String url_not_supported(String url);

  /// Product list popup menu item to export the list
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get product_list_export;

  /// Product list popup menu item to import a list
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get product_list_import;

  /// Action to see the barcode of a product
  ///
  /// In en, this message translates to:
  /// **'View barcode'**
  String get product_footer_action_barcode;

  /// Action to see the barcode of a product (short text)
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get product_footer_action_barcode_short;

  /// Action to see to open the OxF website of the given product
  ///
  /// In en, this message translates to:
  /// **'Open website'**
  String get product_footer_action_open_website;

  /// Action to see to report a product
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get product_footer_action_report;

  /// Action to open the contributor's guide. If you are in a non-English language, please translate this sentence instead: "Help (EN)"
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get product_footer_action_contributor_guide;

  /// Action to view data quality warnings
  ///
  /// In en, this message translates to:
  /// **'Data quality'**
  String get product_footer_action_data_quality_tags;

  /// Label of the for me tab on the product page
  ///
  /// In en, this message translates to:
  /// **'For me'**
  String get product_page_tab_for_me;

  /// Label of the website tab on the product page
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get product_page_tab_website;

  /// Label of the prices tab on the product page
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get product_page_tab_prices;

  /// Label of the folksonomy tab on the product page
  ///
  /// In en, this message translates to:
  /// **'Folksonomy'**
  String get product_page_tab_folksonomy;

  /// Number of products for one-page result
  ///
  /// In en, this message translates to:
  /// **'Top {pageSize} products (total: {total})'**
  String prices_products_list_length_many_pages(int pageSize, int total);

  /// Title for the app review card in the tagline
  ///
  /// In en, this message translates to:
  /// **'Are you enjoying this app?'**
  String get app_review_title;

  /// Item in the app review card with the lowest rating
  ///
  /// In en, this message translates to:
  /// **'Could do better'**
  String get app_review_low;

  /// Item in the app review card with an average rating
  ///
  /// In en, this message translates to:
  /// **'Not bad'**
  String get app_review_medium;

  /// Item in the app review card with the highest rating
  ///
  /// In en, this message translates to:
  /// **'I love it!'**
  String get app_review_high;

  /// Title of the modal sheet displayed when the user has not selected the highest value
  ///
  /// In en, this message translates to:
  /// **'Help us improve our application'**
  String get app_review_feedback_modal_title;

  /// Content of the modal sheet displayed when the user has not selected the highest value
  ///
  /// In en, this message translates to:
  /// **'If you have a few minutes, could you answer this form so that **we can improve in future updates**:'**
  String get app_review_feedback_modal_content;

  /// Answer the form button
  ///
  /// In en, this message translates to:
  /// **'Answer the form'**
  String get app_review_feedback_modal_open_form;

  /// Ask me later button
  ///
  /// In en, this message translates to:
  /// **'Ask me later'**
  String get app_review_feedback_modal_later;

  /// Message to indicate that user can now extract of nutrients from a picture
  ///
  /// In en, this message translates to:
  /// **'NEW: You can automatically extract the nutrients from the picture!'**
  String get nutrition_facts_extract_new;

  /// Button to extraction of nutrients from a picture
  ///
  /// In en, this message translates to:
  /// **'Extract now'**
  String get nutrition_facts_extract_button_text;

  /// Message to indicate that the extraction of nutrients from a picture was succesful
  ///
  /// In en, this message translates to:
  /// **'Extraction succesful'**
  String get nutrition_facts_extract_succesful;

  /// Message to indicate that the extraction of nutrients from a picture failed
  ///
  /// In en, this message translates to:
  /// **'Failed to extract nutrients from picture'**
  String get nutrition_facts_extract_failed;

  /// Label for the discount on prices
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get prices_discount;

  /// Label for statistics section
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get prices_stats_statistics;

  /// Title for the prices statistics page
  ///
  /// In en, this message translates to:
  /// **'Prices Statistics'**
  String get prices_stats_title;

  /// Title for the prices section
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get prices_stats_prices_section;

  /// Title for the products section
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get prices_stats_products_section;

  /// Title for the locations section
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get prices_stats_locations_section;

  /// Title for the proofs section
  ///
  /// In en, this message translates to:
  /// **'Proofs'**
  String get prices_stats_proofs_section;

  /// Title for the contributors section
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get prices_stats_contributors_section;

  /// Title for the experiments section
  ///
  /// In en, this message translates to:
  /// **'Experiments'**
  String get prices_stats_experiments_section;

  /// Title for the miscellaneous section
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get prices_stats_misc_section;

  /// Label for total count
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get prices_stats_total;

  /// Label for count with barcode
  ///
  /// In en, this message translates to:
  /// **'With a barcode'**
  String get prices_stats_with_barcode;

  /// Label for count with category
  ///
  /// In en, this message translates to:
  /// **'With a category'**
  String get prices_stats_with_category;

  /// Label for count with discount
  ///
  /// In en, this message translates to:
  /// **'With a discount'**
  String get prices_stats_with_discount;

  /// Label for community count
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get prices_stats_community;

  /// Label for consumption count
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get prices_stats_consumption;

  /// Label for count with price
  ///
  /// In en, this message translates to:
  /// **'With a price'**
  String get prices_stats_with_price;

  /// Label for food count
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get prices_stats_food;

  /// Label for beauty count
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get prices_stats_beauty;

  /// Label for products count
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get prices_stats_products;

  /// Label for pet food count
  ///
  /// In en, this message translates to:
  /// **'Pet food'**
  String get prices_stats_pet_food;

  /// Label for OpenStreetMap count
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap'**
  String get prices_stats_osm;

  /// Label for online count
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get prices_stats_online;

  /// Label for countries count
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get prices_stats_countries;

  /// Label for price tag count
  ///
  /// In en, this message translates to:
  /// **'Price tag'**
  String get prices_stats_price_tag;

  /// Label for receipt count
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get prices_stats_receipt;

  /// Label for GDPR request count
  ///
  /// In en, this message translates to:
  /// **'GDPR request'**
  String get prices_stats_gdpr_request;

  /// Label for shop import count
  ///
  /// In en, this message translates to:
  /// **'Shop import'**
  String get prices_stats_shop_import;

  /// Label for challenges count
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get prices_stats_challenges;

  /// Label for prices linked to a price tag count
  ///
  /// In en, this message translates to:
  /// **'Prices linked to a price tag'**
  String get prices_stats_linked_to_price_tag;

  /// Label for currencies count
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get prices_stats_currencies;

  /// Label for years count
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get prices_stats_years;

  /// Title for prices and proofs per source section
  ///
  /// In en, this message translates to:
  /// **'Prices and proofs per source'**
  String get prices_stats_by_source_title;

  /// Label for website source
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get prices_stats_website;

  /// Label for mobile app source
  ///
  /// In en, this message translates to:
  /// **'Mobile app'**
  String get prices_stats_mobile_app;

  /// Label for API source
  ///
  /// In en, this message translates to:
  /// **'API'**
  String get prices_stats_api;

  /// Label for other sources
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get prices_stats_other;

  /// Label for last updated timestamp
  ///
  /// In en, this message translates to:
  /// **'Last updated on'**
  String get prices_stats_last_updated;

  /// Error message shown when price statistics fail to load
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading statistics.'**
  String get prices_stats_error;

  /// Message displayed when a question from the Robotoff is answered
  ///
  /// In en, this message translates to:
  /// **'Question answered!'**
  String get product_edit_robotoff_question_answered;

  /// Title of the image section of the Robotoff question
  ///
  /// In en, this message translates to:
  /// **'Proof'**
  String get product_edit_robotoff_proof;

  /// Tooltip for the button to accept the suggestion of the Robotoff question
  ///
  /// In en, this message translates to:
  /// **'Accept suggestion'**
  String get product_edit_robotoff_positive_button;

  /// Tooltip for the button to reject the suggestion of the Robotoff question
  ///
  /// In en, this message translates to:
  /// **'Reject suggestion'**
  String get product_edit_robotoff_negative_button;

  /// Button to show the proof related to a suggestion
  ///
  /// In en, this message translates to:
  /// **'Show proof'**
  String get product_edit_robotoff_show_proof;

  /// Button to open in fullscreen the proof
  ///
  /// In en, this message translates to:
  /// **'Expand proof'**
  String get product_edit_robotoff_expand_proof;

  /// Label of the raw data tab on the product page
  ///
  /// In en, this message translates to:
  /// **'Raw data'**
  String get product_page_tab_raw_data;

  /// Page indicator showing current page and total pages
  ///
  /// In en, this message translates to:
  /// **'Page {current} / {total}'**
  String page_indicator_with_total(int current, int total);

  /// Page indicator showing only current page when total is unknown
  ///
  /// In en, this message translates to:
  /// **'Page {current}'**
  String page_indicator(int current);

  /// Item count showing current number of items and total items
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} items'**
  String item_count_with_total(int count, int total);

  /// Item count showing only current number of items when total is unknown
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String item_count(int count);

  /// Message shown when there are no price statistics available to display
  ///
  /// In en, this message translates to:
  /// **'No price statistics found.'**
  String get prices_no_result;

  /// Error message shown when additional items fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading more items'**
  String get prices_error_loading_more_items;

  /// Error message shown when unable to fetch proofs
  ///
  /// In en, this message translates to:
  /// **'Authentication failed, unable to fetch proofs'**
  String get prices_proof_error;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'aa',
    'af',
    'ak',
    'am',
    'ar',
    'as',
    'az',
    'be',
    'bg',
    'bm',
    'bn',
    'bo',
    'br',
    'bs',
    'ca',
    'ce',
    'co',
    'cs',
    'cv',
    'cy',
    'da',
    'de',
    'el',
    'en',
    'eo',
    'es',
    'et',
    'eu',
    'fa',
    'fi',
    'fo',
    'fr',
    'ga',
    'gd',
    'gl',
    'gu',
    'ha',
    'he',
    'hi',
    'hr',
    'ht',
    'hu',
    'hy',
    'id',
    'ii',
    'is',
    'it',
    'iu',
    'ja',
    'jv',
    'ka',
    'kk',
    'km',
    'kn',
    'ko',
    'ku',
    'kw',
    'ky',
    'la',
    'lb',
    'lo',
    'lt',
    'lv',
    'mg',
    'mi',
    'ml',
    'mn',
    'mr',
    'ms',
    'mt',
    'my',
    'nb',
    'ne',
    'nl',
    'nn',
    'no',
    'nr',
    'oc',
    'or',
    'pa',
    'pl',
    'pt',
    'qu',
    'rm',
    'ro',
    'ru',
    'sa',
    'sc',
    'sd',
    'sg',
    'si',
    'sk',
    'sl',
    'sn',
    'so',
    'sq',
    'sr',
    'ss',
    'st',
    'sv',
    'sw',
    'ta',
    'te',
    'tg',
    'th',
    'ti',
    'tl',
    'tn',
    'tr',
    'ts',
    'tt',
    'tw',
    'ty',
    'ug',
    'uk',
    'ur',
    'uz',
    've',
    'vi',
    'wa',
    'wo',
    'xh',
    'yi',
    'yo',
    'zh',
    'zu',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'aa':
      return AppLocalizationsAa();
    case 'af':
      return AppLocalizationsAf();
    case 'ak':
      return AppLocalizationsAk();
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'as':
      return AppLocalizationsAs();
    case 'az':
      return AppLocalizationsAz();
    case 'be':
      return AppLocalizationsBe();
    case 'bg':
      return AppLocalizationsBg();
    case 'bm':
      return AppLocalizationsBm();
    case 'bn':
      return AppLocalizationsBn();
    case 'bo':
      return AppLocalizationsBo();
    case 'br':
      return AppLocalizationsBr();
    case 'bs':
      return AppLocalizationsBs();
    case 'ca':
      return AppLocalizationsCa();
    case 'ce':
      return AppLocalizationsCe();
    case 'co':
      return AppLocalizationsCo();
    case 'cs':
      return AppLocalizationsCs();
    case 'cv':
      return AppLocalizationsCv();
    case 'cy':
      return AppLocalizationsCy();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'eo':
      return AppLocalizationsEo();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'eu':
      return AppLocalizationsEu();
    case 'fa':
      return AppLocalizationsFa();
    case 'fi':
      return AppLocalizationsFi();
    case 'fo':
      return AppLocalizationsFo();
    case 'fr':
      return AppLocalizationsFr();
    case 'ga':
      return AppLocalizationsGa();
    case 'gd':
      return AppLocalizationsGd();
    case 'gl':
      return AppLocalizationsGl();
    case 'gu':
      return AppLocalizationsGu();
    case 'ha':
      return AppLocalizationsHa();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'ht':
      return AppLocalizationsHt();
    case 'hu':
      return AppLocalizationsHu();
    case 'hy':
      return AppLocalizationsHy();
    case 'id':
      return AppLocalizationsId();
    case 'ii':
      return AppLocalizationsIi();
    case 'is':
      return AppLocalizationsIs();
    case 'it':
      return AppLocalizationsIt();
    case 'iu':
      return AppLocalizationsIu();
    case 'ja':
      return AppLocalizationsJa();
    case 'jv':
      return AppLocalizationsJv();
    case 'ka':
      return AppLocalizationsKa();
    case 'kk':
      return AppLocalizationsKk();
    case 'km':
      return AppLocalizationsKm();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ku':
      return AppLocalizationsKu();
    case 'kw':
      return AppLocalizationsKw();
    case 'ky':
      return AppLocalizationsKy();
    case 'la':
      return AppLocalizationsLa();
    case 'lb':
      return AppLocalizationsLb();
    case 'lo':
      return AppLocalizationsLo();
    case 'lt':
      return AppLocalizationsLt();
    case 'lv':
      return AppLocalizationsLv();
    case 'mg':
      return AppLocalizationsMg();
    case 'mi':
      return AppLocalizationsMi();
    case 'ml':
      return AppLocalizationsMl();
    case 'mn':
      return AppLocalizationsMn();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'mt':
      return AppLocalizationsMt();
    case 'my':
      return AppLocalizationsMy();
    case 'nb':
      return AppLocalizationsNb();
    case 'ne':
      return AppLocalizationsNe();
    case 'nl':
      return AppLocalizationsNl();
    case 'nn':
      return AppLocalizationsNn();
    case 'no':
      return AppLocalizationsNo();
    case 'nr':
      return AppLocalizationsNr();
    case 'oc':
      return AppLocalizationsOc();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'qu':
      return AppLocalizationsQu();
    case 'rm':
      return AppLocalizationsRm();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sa':
      return AppLocalizationsSa();
    case 'sc':
      return AppLocalizationsSc();
    case 'sd':
      return AppLocalizationsSd();
    case 'sg':
      return AppLocalizationsSg();
    case 'si':
      return AppLocalizationsSi();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sn':
      return AppLocalizationsSn();
    case 'so':
      return AppLocalizationsSo();
    case 'sq':
      return AppLocalizationsSq();
    case 'sr':
      return AppLocalizationsSr();
    case 'ss':
      return AppLocalizationsSs();
    case 'st':
      return AppLocalizationsSt();
    case 'sv':
      return AppLocalizationsSv();
    case 'sw':
      return AppLocalizationsSw();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'tg':
      return AppLocalizationsTg();
    case 'th':
      return AppLocalizationsTh();
    case 'ti':
      return AppLocalizationsTi();
    case 'tl':
      return AppLocalizationsTl();
    case 'tn':
      return AppLocalizationsTn();
    case 'tr':
      return AppLocalizationsTr();
    case 'ts':
      return AppLocalizationsTs();
    case 'tt':
      return AppLocalizationsTt();
    case 'tw':
      return AppLocalizationsTw();
    case 'ty':
      return AppLocalizationsTy();
    case 'ug':
      return AppLocalizationsUg();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'uz':
      return AppLocalizationsUz();
    case 've':
      return AppLocalizationsVe();
    case 'vi':
      return AppLocalizationsVi();
    case 'wa':
      return AppLocalizationsWa();
    case 'wo':
      return AppLocalizationsWo();
    case 'xh':
      return AppLocalizationsXh();
    case 'yi':
      return AppLocalizationsYi();
    case 'yo':
      return AppLocalizationsYo();
    case 'zh':
      return AppLocalizationsZh();
    case 'zu':
      return AppLocalizationsZu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
