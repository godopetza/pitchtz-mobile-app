import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pitch TZ'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Book. Play. Repeat.'**
  String get tagline;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get navTeams;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Karibu 👋'**
  String get greeting;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search area, pitch or venue'**
  String get searchHint;

  /// No description provided for @mapViewCta.
  ///
  /// In en, this message translates to:
  /// **'Map view ›'**
  String get mapViewCta;

  /// No description provided for @listLabel.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listLabel;

  /// No description provided for @mapLabel.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapLabel;

  /// No description provided for @askPitchAi.
  ///
  /// In en, this message translates to:
  /// **'Ask Pitch AI'**
  String get askPitchAi;

  /// No description provided for @aiExample.
  ///
  /// In en, this message translates to:
  /// **'“Find me a pitch in Mikocheni tonight under 80K.”'**
  String get aiExample;

  /// No description provided for @soonBadge.
  ///
  /// In en, this message translates to:
  /// **'SOON'**
  String get soonBadge;

  /// No description provided for @availableNow.
  ///
  /// In en, this message translates to:
  /// **'Available now'**
  String get availableNow;

  /// No description provided for @allVenues.
  ///
  /// In en, this message translates to:
  /// **'All venues'**
  String get allVenues;

  /// No description provided for @exploreByArea.
  ///
  /// In en, this message translates to:
  /// **'Explore by area'**
  String get exploreByArea;

  /// No description provided for @moreThanPitch.
  ///
  /// In en, this message translates to:
  /// **'More than the pitch'**
  String get moreThanPitch;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @viewPitch.
  ///
  /// In en, this message translates to:
  /// **'View Pitch'**
  String get viewPitch;

  /// No description provided for @nPitches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pitch} other{{count} pitches}}'**
  String nPitches(int count);

  /// No description provided for @nPitchesIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pitch in {city}} other{{count} pitches in {city}}}'**
  String nPitchesIn(int count, String city);

  /// No description provided for @nPitchesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pitch available} other{{count} pitches available}}'**
  String nPitchesAvailable(int count);

  /// No description provided for @chipTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get chipTonight;

  /// No description provided for @chipTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get chipTomorrow;

  /// No description provided for @chipWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get chipWeekend;

  /// No description provided for @chipNearMe.
  ///
  /// In en, this message translates to:
  /// **'Near me'**
  String get chipNearMe;

  /// No description provided for @loadingPitches.
  ///
  /// In en, this message translates to:
  /// **'Finding pitches near you…'**
  String get loadingPitches;

  /// No description provided for @loadingVenue.
  ///
  /// In en, this message translates to:
  /// **'Loading venue…'**
  String get loadingVenue;

  /// No description provided for @errLoadPitches.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load pitches'**
  String get errLoadPitches;

  /// No description provided for @errLoadVenue.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load this venue'**
  String get errLoadVenue;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @emptyVenuesTitle.
  ///
  /// In en, this message translates to:
  /// **'No venues live yet'**
  String get emptyVenuesTitle;

  /// No description provided for @emptyVenuesMessage.
  ///
  /// In en, this message translates to:
  /// **'We’re onboarding venues in {city} right now. Check back soon — new pitches appear here as they go live.'**
  String emptyVenuesMessage(String city);

  /// No description provided for @emptyResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No pitches found'**
  String get emptyResultsTitle;

  /// No description provided for @emptyResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'No venues are live here yet — new pitches appear as they’re approved.'**
  String get emptyResultsMessage;

  /// No description provided for @chooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose your city'**
  String get chooseCity;

  /// No description provided for @moreCitiesComing.
  ///
  /// In en, this message translates to:
  /// **'More cities are on the way.'**
  String get moreCitiesComing;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveBadge;

  /// No description provided for @notifyMe.
  ///
  /// In en, this message translates to:
  /// **'Notify me'**
  String get notifyMe;

  /// No description provided for @joinWaitlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the {city} waitlist'**
  String joinWaitlistTitle(String city);

  /// No description provided for @joinWaitlistMessage.
  ///
  /// In en, this message translates to:
  /// **'We’ll message you the moment {city} goes live.'**
  String joinWaitlistMessage(String city);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @waitlistJoined.
  ///
  /// In en, this message translates to:
  /// **'You are on the {city} waitlist — we will be in touch'**
  String waitlistJoined(String city);

  /// No description provided for @noCities.
  ///
  /// In en, this message translates to:
  /// **'No cities available right now.'**
  String get noCities;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @pitchType.
  ///
  /// In en, this message translates to:
  /// **'Pitch type'**
  String get pitchType;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get priceRange;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @showPitches.
  ///
  /// In en, this message translates to:
  /// **'Show pitches'**
  String get showPitches;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @checkAvailability.
  ///
  /// In en, this message translates to:
  /// **'Check availability'**
  String get checkAvailability;

  /// No description provided for @goodToKnow.
  ///
  /// In en, this message translates to:
  /// **'Good to know'**
  String get goodToKnow;

  /// No description provided for @availableExtras.
  ///
  /// In en, this message translates to:
  /// **'Available extras'**
  String get availableExtras;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @nReviews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String nReviews(int count);

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet — be among the first to play here.'**
  String get noReviewsYet;

  /// No description provided for @venueReply.
  ///
  /// In en, this message translates to:
  /// **'Venue reply'**
  String get venueReply;

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **' / hour'**
  String get perHour;

  /// No description provided for @peakHours.
  ///
  /// In en, this message translates to:
  /// **'Peak hours (7–10 PM): {price}'**
  String peakHours(String price);

  /// No description provided for @noHiddenFees.
  ///
  /// In en, this message translates to:
  /// **'No hidden fees'**
  String get noHiddenFees;

  /// No description provided for @liveAvailability.
  ///
  /// In en, this message translates to:
  /// **'Live availability'**
  String get liveAvailability;

  /// No description provided for @tapSlotsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap consecutive slots to see your time'**
  String get tapSlotsHint;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @verifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'✓ Verified'**
  String get verifiedBadge;

  /// No description provided for @availableBadge.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableBadge;

  /// No description provided for @perUnit.
  ///
  /// In en, this message translates to:
  /// **'per {unit}'**
  String perUnit(String unit);

  /// No description provided for @confirmsInstantly.
  ///
  /// In en, this message translates to:
  /// **'Usually confirms instantly'**
  String get confirmsInstantly;

  /// No description provided for @freeCancellation.
  ///
  /// In en, this message translates to:
  /// **'Free cancellation up to 6 hours before'**
  String get freeCancellation;

  /// No description provided for @bookingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Booking coming soon'**
  String get bookingComingSoon;

  /// No description provided for @bookingComingSoonPrice.
  ///
  /// In en, this message translates to:
  /// **'Booking coming soon · {price}'**
  String bookingComingSoonPrice(String price);

  /// No description provided for @bookingComingSoonToast.
  ///
  /// In en, this message translates to:
  /// **'Booking opens soon — you can browse and check availability for now ⚽'**
  String get bookingComingSoonToast;

  /// No description provided for @favoritesComingSoonToast.
  ///
  /// In en, this message translates to:
  /// **'Saving favorites is coming soon ⭐'**
  String get favoritesComingSoonToast;

  /// No description provided for @promoComingSoonToast.
  ///
  /// In en, this message translates to:
  /// **'This is coming soon — stay tuned! 🎮'**
  String get promoComingSoonToast;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Karibu.\nLet\'s get you playing.'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account in seconds.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & continue'**
  String get verifyAndContinue;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get pleaseWait;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @skipBrowse.
  ///
  /// In en, this message translates to:
  /// **'Skip for now — browse pitches'**
  String get skipBrowse;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address first'**
  String get enterEmailFirst;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We emailed a 6-digit code to {email}. It’s valid for 10 minutes.'**
  String codeSentTo(String email);

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get changeEmail;

  /// No description provided for @signedInToast.
  ///
  /// In en, this message translates to:
  /// **'Karibu, {name}! You are signed in.'**
  String signedInToast(String name);

  /// No description provided for @socialSignInMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'Google & Apple sign-in are available in the mobile app.'**
  String get socialSignInMobileOnly;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestName;

  /// No description provided for @guestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browsing as a guest'**
  String get guestSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of Pitch TZ?'**
  String get logOutConfirmTitle;

  /// No description provided for @logOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in anytime with your email.'**
  String get logOutConfirmMessage;

  /// No description provided for @loggedOutToast.
  ///
  /// In en, this message translates to:
  /// **'You’ve been logged out. Karibu tena!'**
  String get loggedOutToast;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @rowAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get rowAccount;

  /// No description provided for @rowPayments.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get rowPayments;

  /// No description provided for @rowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get rowNotifications;

  /// No description provided for @rowFavoriteAreas.
  ///
  /// In en, this message translates to:
  /// **'Favorite areas'**
  String get rowFavoriteAreas;

  /// No description provided for @rowHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get rowHelp;

  /// No description provided for @rowTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get rowTerms;

  /// No description provided for @onLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get onLabel;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Pitch TZ · v0.1'**
  String get versionLabel;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @bookingsSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings are coming soon'**
  String get bookingsSoonTitle;

  /// No description provided for @bookingsSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Once sign-in and checkout go live you’ll manage your upcoming and past games here.'**
  String get bookingsSoonMessage;

  /// No description provided for @teamsSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Teams are coming soon'**
  String get teamsSoonTitle;

  /// No description provided for @teamsSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a squad, join open challenges and climb the standings — landing in a future update.'**
  String get teamsSoonMessage;

  /// No description provided for @favoritesSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites are coming soon'**
  String get favoritesSoonTitle;

  /// No description provided for @favoritesSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Save the pitches you love once accounts are live — they’ll sync across your devices.'**
  String get favoritesSoonMessage;

  /// No description provided for @aiSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Pitch AI is coming soon'**
  String get aiSoonTitle;

  /// No description provided for @aiSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Soon you’ll be able to ask for a pitch in plain language — “somewhere in Mikocheni tonight under 80K” — and get instant matches.'**
  String get aiSoonMessage;

  /// No description provided for @readyToday.
  ///
  /// In en, this message translates to:
  /// **'READY FOR YOU TODAY'**
  String get readyToday;

  /// No description provided for @liveBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse every live venue in Dar'**
  String get liveBrowse;

  /// No description provided for @liveAvailabilityRow.
  ///
  /// In en, this message translates to:
  /// **'Check real-time availability'**
  String get liveAvailabilityRow;

  /// No description provided for @liveReviews.
  ///
  /// In en, this message translates to:
  /// **'Read venue reviews'**
  String get liveReviews;

  /// No description provided for @liveMap.
  ///
  /// In en, this message translates to:
  /// **'Explore pitches on the map'**
  String get liveMap;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onbGetStarted;

  /// No description provided for @onbSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get onbSignIn;

  /// No description provided for @ratingNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ratingNew;
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
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
