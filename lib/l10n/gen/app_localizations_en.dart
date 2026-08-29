// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pitch TZ';

  @override
  String get tagline => 'Book. Play. Repeat.';

  @override
  String get navExplore => 'Explore';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navTeams => 'Teams';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get greeting => 'Karibu 👋';

  @override
  String get searchHint => 'Search area, pitch or venue';

  @override
  String get mapViewCta => 'Map view ›';

  @override
  String get listLabel => 'List';

  @override
  String get mapLabel => 'Map';

  @override
  String get askPitchAi => 'Ask Pitch AI';

  @override
  String get aiExample => '“Find me a pitch in Mikocheni tonight under 80K.”';

  @override
  String get soonBadge => 'SOON';

  @override
  String get availableNow => 'Available now';

  @override
  String get allVenues => 'All venues';

  @override
  String get exploreByArea => 'Explore by area';

  @override
  String get moreThanPitch => 'More than the pitch';

  @override
  String get seeAll => 'See all';

  @override
  String get viewPitch => 'View Pitch';

  @override
  String nPitches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pitches',
      one: '1 pitch',
    );
    return '$_temp0';
  }

  @override
  String nPitchesIn(int count, String city) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pitches in $city',
      one: '1 pitch in $city',
    );
    return '$_temp0';
  }

  @override
  String nPitchesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pitches available',
      one: '1 pitch available',
    );
    return '$_temp0';
  }

  @override
  String get chipTonight => 'Tonight';

  @override
  String get chipTomorrow => 'Tomorrow';

  @override
  String get chipWeekend => 'Weekend';

  @override
  String get chipNearMe => 'Near me';

  @override
  String get loadingPitches => 'Finding pitches near you…';

  @override
  String get loadingVenue => 'Loading venue…';

  @override
  String get errLoadPitches => 'Couldn’t load pitches';

  @override
  String get errLoadVenue => 'Couldn’t load this venue';

  @override
  String get tryAgain => 'Try again';

  @override
  String get refresh => 'Refresh';

  @override
  String get emptyVenuesTitle => 'No venues live yet';

  @override
  String emptyVenuesMessage(String city) {
    return 'We’re onboarding venues in $city right now. Check back soon — new pitches appear here as they go live.';
  }

  @override
  String get emptyResultsTitle => 'No pitches found';

  @override
  String get emptyResultsMessage =>
      'No venues are live here yet — new pitches appear as they’re approved.';

  @override
  String get chooseCity => 'Choose your city';

  @override
  String get moreCitiesComing => 'More cities are on the way.';

  @override
  String get liveBadge => 'LIVE';

  @override
  String get notifyMe => 'Notify me';

  @override
  String joinWaitlistTitle(String city) {
    return 'Join the $city waitlist';
  }

  @override
  String joinWaitlistMessage(String city) {
    return 'We’ll message you the moment $city goes live.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get join => 'Join';

  @override
  String waitlistJoined(String city) {
    return 'You are on the $city waitlist — we will be in touch';
  }

  @override
  String get noCities => 'No cities available right now.';

  @override
  String get filters => 'Filters';

  @override
  String get reset => 'Reset';

  @override
  String get location => 'Location';

  @override
  String get pitchType => 'Pitch type';

  @override
  String get priceRange => 'Price range';

  @override
  String get amenities => 'Amenities';

  @override
  String get showPitches => 'Show pitches';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get checkAvailability => 'Check availability';

  @override
  String get goodToKnow => 'Good to know';

  @override
  String get availableExtras => 'Available extras';

  @override
  String get reviews => 'Reviews';

  @override
  String nReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String get noReviewsYet =>
      'No reviews yet — be among the first to play here.';

  @override
  String get venueReply => 'Venue reply';

  @override
  String get perHour => ' / hour';

  @override
  String peakHours(String price) {
    return 'Peak hours (7–10 PM): $price';
  }

  @override
  String get noHiddenFees => 'No hidden fees';

  @override
  String get liveAvailability => 'Live availability';

  @override
  String get tapSlotsHint => 'Tap consecutive slots to see your time';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get verifiedBadge => '✓ Verified';

  @override
  String get availableBadge => 'Available';

  @override
  String perUnit(String unit) {
    return 'per $unit';
  }

  @override
  String get confirmsInstantly => 'Usually confirms instantly';

  @override
  String get freeCancellation => 'Free cancellation up to 6 hours before';

  @override
  String get bookingComingSoon => 'Booking coming soon';

  @override
  String bookingComingSoonPrice(String price) {
    return 'Booking coming soon · $price';
  }

  @override
  String get bookingComingSoonToast =>
      'Booking opens soon — you can browse and check availability for now ⚽';

  @override
  String get favoritesComingSoonToast => 'Saving favorites is coming soon ⭐';

  @override
  String get promoComingSoonToast => 'This is coming soon — stay tuned! 🎮';

  @override
  String get loginTitle => 'Karibu.\nLet\'s get you playing.';

  @override
  String get loginSubtitle => 'Sign in or create an account in seconds.';

  @override
  String get emailLabel => 'EMAIL';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get sendCode => 'Send code';

  @override
  String get verifyAndContinue => 'Verify & continue';

  @override
  String get pleaseWait => 'Please wait…';

  @override
  String get orContinueWith => 'OR CONTINUE WITH';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get skipBrowse => 'Skip for now — browse pitches';

  @override
  String get enterEmailFirst => 'Enter a valid email address first';

  @override
  String codeSentTo(String email) {
    return 'We emailed a 6-digit code to $email. It’s valid for 10 minutes.';
  }

  @override
  String get changeEmail => 'Use a different email';

  @override
  String signedInToast(String name) {
    return 'Karibu, $name! You are signed in.';
  }

  @override
  String get socialSignInMobileOnly =>
      'Google & Apple sign-in are available in the mobile app.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get guestName => 'Guest';

  @override
  String get guestSubtitle => 'Browsing as a guest';

  @override
  String get signIn => 'Sign in';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutConfirmTitle => 'Log out of Pitch TZ?';

  @override
  String get logOutConfirmMessage =>
      'You can sign back in anytime with your email.';

  @override
  String get loggedOutToast => 'You’ve been logged out. Karibu tena!';

  @override
  String get language => 'Language';

  @override
  String get rowAccount => 'Account';

  @override
  String get rowPayments => 'Payment methods';

  @override
  String get rowNotifications => 'Notifications';

  @override
  String get rowFavoriteAreas => 'Favorite areas';

  @override
  String get rowHelp => 'Help';

  @override
  String get rowTerms => 'Terms';

  @override
  String get onLabel => 'On';

  @override
  String get versionLabel => 'Pitch TZ · v0.1';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get bookingsSoonTitle => 'Bookings are coming soon';

  @override
  String get bookingsSoonMessage =>
      'Once sign-in and checkout go live you’ll manage your upcoming and past games here.';

  @override
  String get teamsSoonTitle => 'Teams are coming soon';

  @override
  String get teamsSoonMessage =>
      'Create a squad, join open challenges and climb the standings — landing in a future update.';

  @override
  String get favoritesSoonTitle => 'Favorites are coming soon';

  @override
  String get favoritesSoonMessage =>
      'Save the pitches you love once accounts are live — they’ll sync across your devices.';

  @override
  String get aiSoonTitle => 'Pitch AI is coming soon';

  @override
  String get aiSoonMessage =>
      'Soon you’ll be able to ask for a pitch in plain language — “somewhere in Mikocheni tonight under 80K” — and get instant matches.';

  @override
  String get readyToday => 'READY FOR YOU TODAY';

  @override
  String get liveBrowse => 'Browse every live venue in Dar';

  @override
  String get liveAvailabilityRow => 'Check real-time availability';

  @override
  String get liveReviews => 'Read venue reviews';

  @override
  String get liveMap => 'Explore pitches on the map';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get onbGetStarted => 'Get Started';

  @override
  String get onbSignIn => 'Sign in';

  @override
  String get ratingNew => 'New';
}
