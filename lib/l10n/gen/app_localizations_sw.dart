// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appName => 'Pitch TZ';

  @override
  String get tagline => 'Weka oda. Cheza. Rudia.';

  @override
  String get navExplore => 'Gundua';

  @override
  String get navBookings => 'Oda';

  @override
  String get navTeams => 'Timu';

  @override
  String get navFavorites => 'Vipendwa';

  @override
  String get navProfile => 'Wasifu';

  @override
  String get greeting => 'Karibu 👋';

  @override
  String get searchHint => 'Tafuta eneo, kiwanja au uwanja';

  @override
  String get mapViewCta => 'Ramani ›';

  @override
  String get listLabel => 'Orodha';

  @override
  String get mapLabel => 'Ramani';

  @override
  String get askPitchAi => 'Uliza Pitch AI';

  @override
  String get aiExample =>
      '“Nitafutie kiwanja Mikocheni leo usiku chini ya 80K.”';

  @override
  String get soonBadge => 'KARIBUNI';

  @override
  String get availableNow => 'Vinapatikana sasa';

  @override
  String get allVenues => 'Viwanja vyote';

  @override
  String get exploreByArea => 'Gundua kwa eneo';

  @override
  String get moreThanPitch => 'Zaidi ya kiwanja';

  @override
  String get seeAll => 'Ona vyote';

  @override
  String get viewPitch => 'Ona Kiwanja';

  @override
  String nPitches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Viwanja $count',
      one: 'Kiwanja 1',
    );
    return '$_temp0';
  }

  @override
  String nPitchesIn(int count, String city) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Viwanja $count $city',
      one: 'Kiwanja 1 $city',
    );
    return '$_temp0';
  }

  @override
  String nPitchesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Viwanja $count vinapatikana',
      one: 'Kiwanja 1 kinapatikana',
    );
    return '$_temp0';
  }

  @override
  String get chipTonight => 'Leo usiku';

  @override
  String get chipTomorrow => 'Kesho';

  @override
  String get chipWeekend => 'Wikendi';

  @override
  String get chipNearMe => 'Karibu nami';

  @override
  String get loadingPitches => 'Tunatafuta viwanja karibu nawe…';

  @override
  String get loadingVenue => 'Inapakia uwanja…';

  @override
  String get errLoadPitches => 'Imeshindikana kupakia viwanja';

  @override
  String get errLoadVenue => 'Imeshindikana kupakia uwanja huu';

  @override
  String get tryAgain => 'Jaribu tena';

  @override
  String get refresh => 'Pakia upya';

  @override
  String get emptyVenuesTitle => 'Hakuna viwanja bado';

  @override
  String emptyVenuesMessage(String city) {
    return 'Tunaandikisha viwanja $city sasa hivi. Rudi tena hivi karibuni — viwanja vipya vitaonekana hapa vikiwa tayari.';
  }

  @override
  String get emptyResultsTitle => 'Hakuna viwanja vilivyopatikana';

  @override
  String get emptyResultsMessage =>
      'Hakuna viwanja hapa bado — viwanja vipya vitaonekana vikishaidhinishwa.';

  @override
  String get chooseCity => 'Chagua jiji lako';

  @override
  String get moreCitiesComing => 'Miji mingine inakuja.';

  @override
  String get liveBadge => 'LIVE';

  @override
  String get notifyMe => 'Nijulishe';

  @override
  String joinWaitlistTitle(String city) {
    return 'Jiunge na orodha ya $city';
  }

  @override
  String joinWaitlistMessage(String city) {
    return 'Tutakutumia ujumbe mara $city itakapoanza.';
  }

  @override
  String get cancel => 'Ghairi';

  @override
  String get join => 'Jiunge';

  @override
  String waitlistJoined(String city) {
    return 'Upo kwenye orodha ya $city — tutawasiliana nawe';
  }

  @override
  String get noCities => 'Hakuna miji inayopatikana kwa sasa.';

  @override
  String get filters => 'Vichujio';

  @override
  String get reset => 'Anza upya';

  @override
  String get location => 'Eneo';

  @override
  String get pitchType => 'Aina ya kiwanja';

  @override
  String get priceRange => 'Kiwango cha bei';

  @override
  String get amenities => 'Huduma';

  @override
  String get showPitches => 'Onyesha viwanja';

  @override
  String get chooseDate => 'Chagua tarehe';

  @override
  String get checkAvailability => 'Angalia upatikanaji';

  @override
  String get goodToKnow => 'Vizuri kujua';

  @override
  String get availableExtras => 'Vifaa vya ziada';

  @override
  String get reviews => 'Maoni';

  @override
  String nReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Maoni $count',
      one: 'Maoni 1',
    );
    return '$_temp0';
  }

  @override
  String get noReviewsYet =>
      'Hakuna maoni bado — kuwa miongoni mwa wa kwanza kucheza hapa.';

  @override
  String get venueReply => 'Jibu la uwanja';

  @override
  String get perHour => ' / saa';

  @override
  String peakHours(String price) {
    return 'Saa za lala salama (7–10 usiku): $price';
  }

  @override
  String get noHiddenFees => 'Hakuna ada za siri';

  @override
  String get liveAvailability => 'Upatikanaji wa moja kwa moja';

  @override
  String get tapSlotsHint => 'Gusa vipindi vinavyofuatana kuona muda wako';

  @override
  String get unavailable => 'Haipatikani';

  @override
  String get verifiedBadge => '✓ Imethibitishwa';

  @override
  String get availableBadge => 'Inapatikana';

  @override
  String perUnit(String unit) {
    return 'kwa $unit';
  }

  @override
  String get confirmsInstantly => 'Huthibitishwa papo hapo';

  @override
  String get freeCancellation => 'Kughairi bure hadi saa 6 kabla';

  @override
  String get bookingComingSoon => 'Kuweka oda kunakuja hivi karibuni';

  @override
  String bookingComingSoonPrice(String price) {
    return 'Oda inakuja hivi karibuni · $price';
  }

  @override
  String get bookingComingSoonToast =>
      'Kuweka oda kunakuja hivi karibuni — kwa sasa vinjari na uangalie upatikanaji ⚽';

  @override
  String get favoritesComingSoonToast =>
      'Kuhifadhi vipendwa kunakuja hivi karibuni ⭐';

  @override
  String get promoComingSoonToast => 'Hii inakuja hivi karibuni — subiri! 🎮';

  @override
  String get loginTitle => 'Karibu.\nTuanze kucheza.';

  @override
  String get loginSubtitle => 'Ingia au fungua akaunti kwa sekunde chache.';

  @override
  String get phoneNumberLabel => 'NAMBA YA SIMU';

  @override
  String get phoneHint => '754 123 456';

  @override
  String get sendCode => 'Tuma msimbo';

  @override
  String get verifyAndContinue => 'Thibitisha uendelee';

  @override
  String get pleaseWait => 'Subiri kidogo…';

  @override
  String get orContinueWith => 'AU ENDELEA NA';

  @override
  String get continueWithGoogle => 'Endelea na Google';

  @override
  String get continueWithApple => 'Endelea na Apple';

  @override
  String get skipBrowse => 'Ruka kwa sasa — vinjari viwanja';

  @override
  String get enterPhoneFirst => 'Weka namba yako ya simu kwanza';

  @override
  String signedInToast(String name) {
    return 'Karibu, $name! Umeingia.';
  }

  @override
  String get signedInGoogle => 'Umeingia na Google ✓';

  @override
  String get signedInApple => 'Umeingia na Apple ✓';

  @override
  String get demoAuthNote =>
      'Kuingia kwa majaribio — kunafanya kazi kwenye kifaa hiki hadi akaunti zitakapoanza kazi rasmi.';

  @override
  String get profileTitle => 'Wasifu';

  @override
  String get guestName => 'Mgeni';

  @override
  String get guestSubtitle => 'Unavinjari kama mgeni';

  @override
  String get signIn => 'Ingia';

  @override
  String get logOut => 'Toka';

  @override
  String get logOutConfirmTitle => 'Utoke Pitch TZ?';

  @override
  String get logOutConfirmMessage =>
      'Unaweza kuingia tena wakati wowote kwa namba yako ya simu.';

  @override
  String get loggedOutToast => 'Umetoka. Karibu tena!';

  @override
  String get language => 'Lugha';

  @override
  String get rowAccount => 'Akaunti';

  @override
  String get rowPayments => 'Njia za malipo';

  @override
  String get rowNotifications => 'Arifa';

  @override
  String get rowFavoriteAreas => 'Maeneo pendwa';

  @override
  String get rowHelp => 'Msaada';

  @override
  String get rowTerms => 'Masharti';

  @override
  String get onLabel => 'Zimewashwa';

  @override
  String get versionLabel => 'Pitch TZ · v0.1';

  @override
  String get comingSoon => 'Inakuja hivi karibuni';

  @override
  String get bookingsSoonTitle => 'Oda zinakuja hivi karibuni';

  @override
  String get bookingsSoonMessage =>
      'Kuingia na malipo vitakapoanza kazi, utasimamia mechi zako zijazo na zilizopita hapa.';

  @override
  String get teamsSoonTitle => 'Timu zinakuja hivi karibuni';

  @override
  String get teamsSoonMessage =>
      'Unda timu, pokea changamoto na panda msimamo — inakuja kwenye toleo lijalo.';

  @override
  String get favoritesSoonTitle => 'Vipendwa vinakuja hivi karibuni';

  @override
  String get favoritesSoonMessage =>
      'Hifadhi viwanja unavyovipenda akaunti zitakapoanza — vitahifadhiwa kwenye vifaa vyako vyote.';

  @override
  String get aiSoonTitle => 'Pitch AI inakuja hivi karibuni';

  @override
  String get aiSoonMessage =>
      'Hivi karibuni utaweza kuomba kiwanja kwa lugha ya kawaida — “mahali Mikocheni leo usiku chini ya 80K” — na kupata majibu papo hapo.';

  @override
  String get readyToday => 'TAYARI KWAKO LEO';

  @override
  String get liveBrowse => 'Vinjari kila uwanja ulio hewani Dar';

  @override
  String get liveAvailabilityRow => 'Angalia upatikanaji wa moja kwa moja';

  @override
  String get liveReviews => 'Soma maoni ya viwanja';

  @override
  String get liveMap => 'Gundua viwanja kwenye ramani';

  @override
  String get onbSkip => 'Ruka';

  @override
  String get onbNext => 'Endelea';

  @override
  String get onbGetStarted => 'Anza Sasa';

  @override
  String get onbSignIn => 'Ingia';

  @override
  String get ratingNew => 'Mpya';
}
